'###############################################################################
'#  AgentPipe.bas — Ilwaco IDE (Linux/GTK3 port)                               #
'#                                                                             #
'#  Unix-domain-socket server inside ilwaco that receives commands from the    #
'#  ilwaco-mcp sidecar. Ported from Astoria IDE's Win32 named-pipe server.    #
'#                                                                             #
'#  Protocol: newline-delimited JSON, UTF-8, one in-flight request.            #
'#     request:  { "id": 42, "cmd": "ping", "args": { ... } }                  #
'#     success:  { "id": 42, "ok": true, "result": { ... } }                   #
'#     failure:  { "id": 42, "ok": false,                                      #
'#                 "error": { "code": "unknown_cmd", "message": "..." } }      #
'###############################################################################

# include once "crt/unistd.bi"
# include once "crt/sys/socket.bi"
# include once "crt/sys/linux/socket.bi"
# include once "crt/fcntl.bi"
# include once "crt/pthread.bi"
# include once "crt/errno.bi"

'' Unix-domain sockets: the bundled fbc headers define AF_UNIX/SOCK_STREAM but
'' not sockaddr_un, so we declare that struct ourselves.
Type sockaddr_un Field = 1
	sun_family As UShort
	sun_path As ZString * 108
End Type

Const AGENT_SOCK_PATH = "/tmp/ilwaco-agent.sock"

Dim Shared gAgentActive As Boolean              '' listener up
Dim Shared gAgentStop As Boolean                '' worker shutdown flag
Dim Shared gAgentThread As Any Ptr              '' worker thread handle
Dim Shared gAgentListenFd As Integer = -1       '' listening socket

'' ---------------------------------------------------------------- GTK idle dispatch
'' The GTK/GDK functions are available at link time through the framework lib.
'' We use Cptr-cast to avoid needing the precise GSourceFunc type.

Declare Function idle_add Alias "g_idle_add"(ByVal func As Any Ptr, ByVal data As Any Ptr) As ULong

'' ---------------------------------------------------------------- IDE helpers
'' Functions called by AgentPipe that aren't forward-declared elsewhere.

Function GetOpenProjectNode() As TreeNode Ptr
	Dim As ProjectElement Ptr ppe
	Dim As TreeNode Ptr pn
	GetMainFile(False, ppe, pn)
	Return pn
End Function
'' These IDE functions live later in Main.bas; declare them so AgentPipe can call them.

Declare Function GetTreeNodeChild(tn As TreeNode Ptr, ByRef FileName As WString) As TreeNode Ptr
Declare Function ContainsFileName(tn As TreeNode Ptr, ByRef FileName As WString) As Boolean

'' ---------------------------------------------------------------- file helpers
'' Simple UString wrappers around FB's WString file functions (Linux).

Function FileExistsU(ByRef Path As UString) As Boolean
	Return FileExists(Path)
End Function

Function FolderExistsU(ByRef Path As UString) As Boolean
	Return FolderExists(Path)
End Function

Function CopyFileU(ByRef Src As UString, ByRef Dest As UString) As Boolean
	Return FileCopy(Src, Dest) = 0
End Function

Function GetFullPathU(ByRef Path As WString) As UString
	Dim As UString result = Path
	If Len(Path) > 0 AndAlso Path[0] <> Asc("/") Then
		'' Make it absolute relative to ExePath
		result = ExePath & "/" & Path
	End If
	'' Collapse .. and .
	'' (a proper implementation would use realpath(); for now, keep it simple)
	Return result
End Function

Function GetFolderNameU(ByRef Path As WString) As UString
	Dim As UString p = Path
	For i As Integer = Len(p) - 1 To 0 Step -1
		If p[i] = Asc("/") OrElse p[i] = Asc("\\") Then Return Left(p, i)
	Next
	Return p
End Function

Function EnsureDirectoryExists(ByRef Path As UString) As Boolean
	If FolderExistsU(Path) Then Return True
	'' Recursively create parent directories
	Dim As UString parent = GetFolderNameU(Path)
	If parent <> Path AndAlso parent <> "" Then
		If Not EnsureDirectoryExists(parent) Then Return False
	End If
	MkDir Path
	Return FolderExistsU(Path)
End Function

'' ---------------------------------------------------------------- UTF-8 helpers
'' WString is UTF-32 on Linux FB. These convert at the pipe/JSON boundary.

Function WStrToUtf8(ByRef w As WString) As String
	If Len(w) = 0 Then Return ""
	Dim As String s = ""
	For i As Integer = 0 To Len(w) - 1
		Dim As UInteger cp = w[i]
		If cp < &H80 Then
			s &= Chr(cp)
		ElseIf cp < &H800 Then
			s &= Chr(&HC0 Or (cp Shr 6)) & Chr(&H80 Or (cp And &H3F))
		ElseIf cp < &H10000 Then
			s &= Chr(&HE0 Or (cp Shr 12)) & Chr(&H80 Or ((cp Shr 6) And &H3F)) & Chr(&H80 Or (cp And &H3F))
		ElseIf cp < &H110000 Then
			s &= Chr(&HF0 Or (cp Shr 18)) & Chr(&H80 Or ((cp Shr 12) And &H3F)) & Chr(&H80 Or ((cp Shr 6) And &H3F)) & Chr(&H80 Or (cp And &H3F))
		End If
	Next i
	Return s
End Function

Function Utf8ToWStr(ByRef s As String) As WString Ptr
	Dim As WString Ptr w
	If Len(s) = 0 Then WLet(w, "") : Return w
	Dim As String tmp = ""
	Dim As Integer i = 0
	While i < Len(s)
		Dim As UInteger cp
		Dim As Integer b = s[i]
		If b < &H80 Then
			cp = b : i += 1
		ElseIf (b And &HE0) = &HC0 Then
			If i + 1 >= Len(s) Then Exit While
			cp = (CUInt(b And &H1F) Shl 6) Or CUInt(s[i + 1] And &H3F) : i += 2
		ElseIf (b And &HF0) = &HE0 Then
			If i + 2 >= Len(s) Then Exit While
			cp = (CUInt(b And &H0F) Shl 12) Or (CUInt(s[i + 1] And &H3F) Shl 6) Or CUInt(s[i + 2] And &H3F) : i += 3
		ElseIf (b And &HF8) = &HF0 Then
			If i + 3 >= Len(s) Then Exit While
			cp = (CUInt(b And &H07) Shl 18) Or (CUInt(s[i + 1] And &H3F) Shl 12) Or (CUInt(s[i + 2] And &H3F) Shl 6) Or CUInt(s[i + 3] And &H3F) : i += 4
		Else
			i += 1 : Continue While   '' invalid byte, skip
		End If
		tmp &= WChr(cp)
	Wend
	WLet(w, tmp)
	Return w
End Function

'' ---------------------------------------------------------------- command slot
'' Single in-flight slot (same pattern as Astoria). Worker publishes here,
'' schedules UI execution, waits for completion; UI thread executes and signals.

Dim Shared gCmdPending As Boolean
Dim Shared gCmdName As String                   '' UTF-8
Dim Shared gCmdArgs As JsonValue Ptr            '' borrowed view (may be 0)
Dim Shared gCmdOk As Boolean
Dim Shared gCmdResult As JsonValue Ptr          '' owned; set by UI thread
Dim Shared gCmdErrCode As String
Dim Shared gCmdErrMsg As String
Dim Shared gCmdDoneFd(0 To 1) As Integer = {-1, -1}  '' pipe: read end, write end

Dim Shared gAgentBuilding As Boolean

'' ---------------------------------------------------------------- read-only helpers

'' The open project's ProjectElement, or 0 if none is open.
Private Function AgentProject() As ProjectElement Ptr
	Dim As TreeNode Ptr tn = GetOpenProjectNode()
	If tn = 0 OrElse tn->Tag = 0 Then Return 0
	Return Cast(ProjectElement Ptr, tn->Tag)
End Function

Private Function AgentResolveProjectPath(ByRef rawUtf8 As String, ByRef errCode As String, ByRef errMsg As String) As UString
	errCode = "" : errMsg = ""
	Dim As ProjectElement Ptr ppe = AgentProject()
	If ppe = 0 Then errCode = "no_project" : errMsg = "No project is open." : Return ""
	Dim As UString root = GetFolderNameU(WGet(ppe->FileName))
	If root = "" Then errCode = "no_project" : errMsg = "Project folder not found." : Return ""
	Dim As WString Ptr rawW = Utf8ToWStr(rawUtf8)
	Dim As UString resolved = GetFullPathU(*rawW)
	If Len(*rawW) > 0 AndAlso Left(*rawW, 1) <> "/" Then
		resolved = GetFullPathU(root & *rawW)
	End If
	WDeAllocate(rawW)
	'' Containment check
	If Left(resolved, Len(root)) <> root Then
		errCode = "bad_path" : errMsg = "Path escapes the project folder: " & rawUtf8
		Return ""
	End If
	Return resolved
End Function

Private Function AgentReadFileBytes(ByRef path As UString) As String
	Dim As Integer fn = FreeFile
	If Open(path For Binary Access Read As #fn) <> 0 Then Return ""
	Dim As LongInt sz = LOF(fn)
	Dim As String buf
	If sz > 0 Then buf = String(sz, 0) : Get #fn, 1, buf
	Close #fn
	If Len(buf) >= 3 AndAlso buf[0] = &HEF AndAlso buf[1] = &HBB AndAlso buf[2] = &HBF Then buf = Mid(buf, 4)
	Return buf
End Function

Private Function AgentWriteFileBytes(ByRef path As UString, ByRef content As String) As Boolean
	Dim As Integer fn = FreeFile
	If Open(path For Output As #fn) <> 0 Then Return False
	Close #fn
	If Open(path For Binary Access Write As #fn) <> 0 Then Return False
	If Len(content) > 0 Then Put #fn, 1, content
	Close #fn
	Return True
End Function

Private Function AgentRegisterFileInProject(ByRef fullPath As UString) As Boolean
	Dim As TreeNode Ptr tnP = GetOpenProjectNode()
	If tnP = 0 Then Return False
	Dim As WString Ptr fpW
	WLet(fpW, fullPath)
	Dim As TreeNode Ptr tnFolder = GetTreeNodeChild(tnP, *fpW)
	If ContainsFileName(tnFolder, *fpW) Then WDeAllocate(fpW) : Return True
	Dim As String iconName = GetIconName(*fpW)
	Dim As TreeNode Ptr tn3 = tnFolder->Nodes.Add(GetFileName(*fpW), , , iconName, iconName, True)
	Dim As ExplorerElement Ptr ee = _New(ExplorerElement)
	WLet(ee->FileName, *fpW)
	tn3->Tag = ee
	If Not EndsWith(tnP->Text, "*") Then tnP->Text &= "*"
	If Not tnP->IsExpanded Then tnP->Expand
	If Not tnFolder->IsExpanded Then tnFolder->Expand
	WDeAllocate(fpW)
	Return True
End Function

'' ---------------------------------------------------------------- build helpers

Private Function AgentHasBuildErrors() As Boolean
	For i As Integer = 0 To lvProblems.ListItems.Count - 1
		Dim As ListViewItem Ptr it = lvProblems.ListItems.Item(i)
		If it AndAlso LCase(it->ImageKey) = "error" Then Return True
	Next
	Return False
End Function

Private Function AgentBuildErrorsArray() As JsonValue Ptr
	Dim As JsonValue Ptr arr = JsonNewArray()
	For i As Integer = 0 To lvProblems.ListItems.Count - 1
		Dim As ListViewItem Ptr it = lvProblems.ListItems.Item(i)
		If it = 0 Then Continue For
		Dim As JsonValue Ptr e = JsonNewObject()
		e->SetMember("severity", JsonNewString(LCase(WStrToUtf8(it->ImageKey))))
		e->SetMember("message", JsonNewString(WStrToUtf8(it->Text(0))))
		Dim As String lnStr = Trim(WStrToUtf8(it->Text(1)))
		If lnStr <> "" Then e->SetMember("line", JsonNewNumber(Val(lnStr))) Else e->SetMember("line", JsonNewNull())
		e->SetMember("file", JsonNewString(WStrToUtf8(it->Text(2))))
		arr->Append(e)
	Next
	Return arr
End Function

Private Function AgentHandleBuildCmd(ByRef cmd As String, ByRef idJson As String) As String
	If gAgentBuilding Then
		Return "{""id"":" & idJson & ",""ok"":false,""error"":{""code"":""busy"",""message"":""A build or run is already in progress.""}}"
	End If
	gAgentBuilding = True

	Dim As String param
	Dim As Boolean isRun = False
	Select Case cmd
	Case "syntax_check" : param = "Check"
	Case "run"          : param = "" : isRun = True
	Case Else           : param = ""   '' build
	End Select

	Dim As Integer result = Compile(param, False)
	Dim As Boolean buildOk = (result <> 0) AndAlso (Not AgentHasBuildErrors())
	Dim As JsonValue Ptr res = JsonNewObject()

	If cmd = "syntax_check" Then
		res->SetMember("ok", JsonNewBool(buildOk))
		res->SetMember("errors", AgentBuildErrorsArray())
	ElseIf cmd = "run" Then
		res->SetMember("build_ok", JsonNewBool(buildOk))
		res->SetMember("errors", AgentBuildErrorsArray())
		If buildOk Then
			'' Launch the executable (no output capture on Linux yet — v1).
			'' TODO: capture stdout via fork+pipe for console targets.
			Dim As ProjectElement Ptr proj
			Dim As TreeNode Ptr node
			Dim As UString mainFile = GetMainFile(False, proj, node)
			If mainFile <> "" Then
				Dim As UString compileLine, firstLine = GetFirstCompileLine(mainFile, proj, compileLine)
				Dim As UString exe = GetExeFileName(mainFile, compileLine & " " & firstLine)
				If FileExists(exe) Then
					res->SetMember("started", JsonNewBool(True))
					res->SetMember("console", JsonNewBool(InStr(LCase(firstLine & " " & compileLine), "-s gui") = 0))
					res->SetMember("note", JsonNewString("Run not yet captured on Linux; executable launched."))
				Else
					res->SetMember("started", JsonNewBool(False))
					res->SetMember("note", JsonNewString("Executable not found after build."))
				End If
			Else
				res->SetMember("started", JsonNewBool(False))
				res->SetMember("note", JsonNewString("No main file."))
			End If
		Else
			res->SetMember("started", JsonNewBool(False))
			res->SetMember("note", JsonNewString("Build failed; program not run."))
		End If
	Else   '' build
		res->SetMember("ok", JsonNewBool(buildOk))
		res->SetMember("exit_code", JsonNewNumber(IIf(buildOk, 0, 1)))
		res->SetMember("output", JsonNewString(WStrToUtf8(txtOutput.Text)))
		res->SetMember("errors", AgentBuildErrorsArray())
	End If

	gAgentBuilding = False
	Dim As String resp = "{""id"":" & idJson & ",""ok"":true,""result"":" & JsonSerialize(res) & "}"
	Delete res
	Return resp
End Function

'' ---------------------------------------------------------------- AI template

Private Function AgentAiToolFolder(ByRef toolLabel As String) As UString
	Select Case toolLabel
	Case "Claude Code":     Return "ClaudeCode"
	Case "Cursor":          Return "Cursor"
	Case "ChatGPT (Codex)": Return "ChatGPT"
	Case "OpenCode":        Return "OpenCode"
	Case "Kun (Deepseek)":  Return "Kun"
	Case Else:              Return ""
	End Select
End Function

Private Sub AgentStampTemplateFile(ByRef srcFile As UString, ByRef destFile As UString, ByRef projectName As String, ByRef authorName As String, ByRef licenseName As String, ByRef descriptionText As String)
	Dim As Integer fnIn = FreeFile
	If Open(srcFile For Binary Access Read As #fnIn) <> 0 Then Exit Sub
	Dim As Integer fileSize = LOF(fnIn)
	Dim As String contents = String(fileSize, 0)
	If fileSize > 0 Then Get #fnIn, 1, contents
	Close #fnIn
	Dim As String authorForToken = Trim(authorName)
	If authorForToken = "" Then authorForToken = "the author"
	contents = Replace(contents, "{{PROJECT}}", projectName)
	contents = Replace(contents, "{{AUTHOR}}", authorForToken)
	contents = Replace(contents, "{{YEAR}}", Format(Now, "yyyy"))
	contents = Replace(contents, "{{DATE}}", Format(Now, "yyyy-mm-dd"))
	contents = Replace(contents, "{{LICENSE}}", licenseName)
	contents = Replace(contents, "{{DESCRIPTION}}", descriptionText)
	Dim As Integer fnOut = FreeFile
	If Open(destFile For Binary Access Write As #fnOut) = 0 Then
		If Len(contents) > 0 Then Put #fnOut, 1, contents
		Close #fnOut
	End If
End Sub

Private Sub AgentCopyTemplateTree(ByRef srcFolder As UString, ByRef destFolder As UString, ByRef projectName As String, ByRef authorName As String, ByRef licenseName As String, ByRef descriptionText As String)
	If Not EnsureDirectoryExists(destFolder) Then Exit Sub
	Dim As WStringList names
	Dim As UInteger attr
	Dim As String f = Dir(srcFolder & "/" & "*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, attr)
	Do While f <> ""
		If f <> "." AndAlso f <> ".." AndAlso f <> ".gitkeep" Then names.Add f
		f = Dir(attr)
	Loop
	For i As Integer = 0 To names.Count - 1
		Dim As UString itemName = names.Item(i)
		Dim As UString srcItem = srcFolder & "/" & itemName
		Dim As UString destItem = destFolder & "/" & itemName
		If FolderExistsU(srcItem) Then
			AgentCopyTemplateTree(srcItem, destItem, projectName, authorName, licenseName, descriptionText)
		Else
			AgentStampTemplateFile(srcItem, destItem, projectName, authorName, licenseName, descriptionText)
		End If
	Next i
End Sub

Private Function AgentStampAiTemplate(ByRef destFolder As UString, ByRef toolFolder As UString, ByRef projectName As String) As Boolean
	If toolFolder = "" Then Return False
	Dim As UString srcFolder = ExePath & "/Templates/AI/" & toolFolder
	If Not FolderExistsU(srcFolder) Then Return False
	AgentCopyTemplateTree(srcFolder, destFolder, projectName, "", "", "")
	Return True
End Function

Private Function AgentTemplateMainFile(ByRef templateName As String) As UString
	Dim As UString folder = ExePath & "/Templates/Projects/" & templateName
	If Not FolderExistsU(folder) Then Return ""
	Dim As UInteger attr
	Dim As String f = Dir(folder & "/" & "*", fbReadOnly Or fbHidden Or fbSystem Or fbDirectory Or fbArchive, attr)
	Do While f <> ""
		If (attr And fbDirectory) = 0 AndAlso f <> "." AndAlso f <> ".." Then Return f
		f = Dir(attr)
	Loop
	Return ""
End Function

'' ---------------------------------------------------------------- UI-thread dispatch

Sub AgentPipe_ExecutePendingOnUi()
	If Not gCmdPending Then Exit Sub
	gCmdPending = False
	gCmdOk = False
	gCmdResult = 0
	gCmdErrCode = ""
	gCmdErrMsg = ""
	Select Case gCmdName
	Case "ping"
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("pong", JsonNewBool(True))
		res->SetMember("app", JsonNewString("Ilwaco IDE"))
		gCmdOk = True
		gCmdResult = res

	Case "get_status"
		Dim As JsonValue Ptr res = JsonNewObject()
		Dim As ProjectElement Ptr ppe = AgentProject()
		If ppe Then
			res->SetMember("project", JsonNewString(WStrToUtf8(WGet(ppe->FileName))))
			res->SetMember("main_file", JsonNewString(WStrToUtf8(WGet(ppe->MainFileName))))
		Else
			res->SetMember("project", JsonNewNull())
			res->SetMember("main_file", JsonNewNull())
		End If
		Dim As JsonValue Ptr openArr = JsonNewArray()
		For j As Integer = 0 To ptabCode->TabCount - 1
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->Tabs[j])
			If tb Then openArr->Append(JsonNewString(WStrToUtf8(tb->FileName)))
		Next j
		res->SetMember("open_files", openArr)
		res->SetMember("building", JsonNewBool(gAgentBuilding))
		res->SetMember("running", JsonNewBool(Running))
		gCmdOk = True
		gCmdResult = res

	Case "list_files"
		Dim As ProjectElement Ptr ppe = AgentProject()
		If ppe = 0 Then
			gCmdErrCode = "no_project" : gCmdErrMsg = "No project is open."
			'' Signal completion before exit
			Dim As Byte dummy = 1
			write_(gCmdDoneFd(1), @dummy, 1)
			Exit Sub
		End If
		Dim As JsonValue Ptr filesArr = JsonNewArray()
		Dim As TreeNode Ptr projectNode = GetOpenProjectNode()
		Dim As UString projectRoot = GetFolderNameU(WGet(ppe->FileName))
		For j As Integer = 0 To projectNode->Nodes.Count - 1
			Dim As TreeNode Ptr child = projectNode->Nodes.Item(j)
			If child->Tag Then
				Dim As ExplorerElement Ptr eeDirect = Cast(ExplorerElement Ptr, child->Tag)
				Dim As UString relDirect = Replace(Mid(WGet(eeDirect->FileName), Len(projectRoot) + 1), "\", "/")
				filesArr->Append(JsonNewString(WStrToUtf8(relDirect)))
			Else
				For k As Integer = 0 To child->Nodes.Count - 1
					Dim As TreeNode Ptr fileNode = child->Nodes.Item(k)
					If fileNode->Tag Then
						Dim As ExplorerElement Ptr eeNested = Cast(ExplorerElement Ptr, fileNode->Tag)
						Dim As UString relNested = Replace(Mid(WGet(eeNested->FileName), Len(projectRoot) + 1), "\", "/")
						filesArr->Append(JsonNewString(WStrToUtf8(relNested)))
					End If
				Next k
			End If
		Next j
		Dim As String mainFile = WStrToUtf8(Replace(Mid(WGet(ppe->MainFileName), Len(projectRoot) + 1), "\", "/"))
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("files", filesArr)
		If mainFile <> "" Then res->SetMember("main_file", JsonNewString(mainFile)) Else res->SetMember("main_file", JsonNewNull())
		gCmdOk = True
		gCmdResult = res

	Case "read_file"
		Dim As String rawPath
		If gCmdArgs Then rawPath = gCmdArgs->GetStr("path")
		If rawPath = "" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "read_file requires a 'path'."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As String ec, em
		Dim As UString full = AgentResolveProjectPath(rawPath, ec, em)
		If ec <> "" Then
			gCmdErrCode = ec : gCmdErrMsg = em
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		If Not FileExistsU(full) Then
			gCmdErrCode = "not_found" : gCmdErrMsg = "File not found: " & rawPath
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("content", JsonNewString(AgentReadFileBytes(full)))
		gCmdOk = True
		gCmdResult = res

	Case "get_active_file"
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then
			gCmdErrCode = "no_active_file" : gCmdErrMsg = "No editor tab is active."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("path", JsonNewString(WStrToUtf8(tb->FileName)))
		res->SetMember("content", JsonNewString(WStrToUtf8(tb->txtCode.Text)))
		gCmdOk = True
		gCmdResult = res

	Case "get_build_output"
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("text", JsonNewString(WStrToUtf8(txtOutput.Text)))
		gCmdOk = True
		gCmdResult = res

	Case "get_errors"
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("errors", AgentBuildErrorsArray())
		gCmdOk = True
		gCmdResult = res

	Case "open_project"
		Dim As String rawPath
		If gCmdArgs Then rawPath = gCmdArgs->GetStr("path")
		If rawPath = "" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "open_project requires a 'path'."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As WString Ptr rawW = Utf8ToWStr(rawPath)
		Dim As UString full = GetFullPathU(*rawW)
		WDeAllocate(rawW)
		If Right(LCase(full), 4) <> ".vfp" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "open_project path must be a .vfp file."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		If Not FileExistsU(full) Then
			gCmdErrCode = "not_found" : gCmdErrMsg = "Project not found: " & rawPath
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As WString Ptr fw
		WLet(fw, full)
		OpenFiles(*fw)
		WDeAllocate(fw)
		Dim As JsonValue Ptr res = JsonNewObject()
		Dim As ProjectElement Ptr ppe = AgentProject()
		If ppe Then res->SetMember("project", JsonNewString(WStrToUtf8(WGet(ppe->FileName)))) Else res->SetMember("project", JsonNewString(WStrToUtf8(full)))
		gCmdOk = True
		gCmdResult = res

	Case "create_project"
		Dim As String nm, template, aiTool
		If gCmdArgs Then
			nm = Trim(gCmdArgs->GetStr("name"))
			template = Trim(gCmdArgs->GetStr("template"))
			aiTool = Trim(gCmdArgs->GetStr("ai_tool"))
		End If
		If template = "" Then template = "Console Application"
		If nm = "" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "create_project needs a valid 'name'."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As UString templateVfp = ExePath & "/Templates/Projects/" & template & ".vfp"
		Dim As UString mainFile = AgentTemplateMainFile(template)
		If Not FileExistsU(templateVfp) OrElse mainFile = "" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "Unknown project template: " & template
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As WString Ptr ppW
		WLet(ppW, *ProjectsPath)
		Dim As UString projectsRoot = GetFullPath(*ppW)
		WDeAllocate(ppW)
		Dim As UString newFolder = projectsRoot & "/" & nm
		If FolderExistsU(newFolder) Then
			gCmdErrCode = "exists" : gCmdErrMsg = "A project folder named '" & nm & "' already exists."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		If Not EnsureDirectoryExists(newFolder) Then
			gCmdErrCode = "write_failed" : gCmdErrMsg = "Could not create the project folder."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As UString srcMain = ExePath & "/Templates/Projects/" & template & "/" & mainFile
		Dim As UString destMain = newFolder & "/" & mainFile
		If Not CopyFileU(srcMain, destMain) Then
			gCmdErrCode = "write_failed" : gCmdErrMsg = "Could not copy the template main file."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As String vfpText = AgentReadFileBytes(templateVfp)
		Dim As String outVfp
		Dim As Integer p = 1
		While p <= Len(vfpText)
			Dim As Integer nl = InStr(p, vfpText, Chr(10))
			Dim As String ln
			If nl = 0 Then ln = Mid(vfpText, p) : p = Len(vfpText) + 1 Else ln = Mid(vfpText, p, nl - p) : p = nl + 1
			Dim As String bare = ln
			If Right(bare, 1) = Chr(13) Then bare = Left(bare, Len(bare) - 1)
			If Left(bare, 6) = "*File=" Then
				ln = "*File=" & mainFile & Chr(13)
			ElseIf Left(bare, 12) = "ProjectName=" Then
				ln = "ProjectName=""" & nm & """" & Chr(13)
			End If
			outVfp &= ln
			If nl <> 0 Then outVfp &= Chr(10)
		Wend
		Dim As String aiToolMeta = aiTool
		If aiToolMeta = "" Then aiToolMeta = "Claude Code"
		outVfp &= "AIFriendly=true" & Chr(13) & Chr(10)
		outVfp &= "AITool=""" & aiToolMeta & """" & Chr(13) & Chr(10)
		Dim As UString newVfp = newFolder & "/" & nm & ".vfp"
		If Not AgentWriteFileBytes(newVfp, outVfp) Then
			gCmdErrCode = "write_failed" : gCmdErrMsg = "Could not write the project file."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As UString aiFolder = AgentAiToolFolder(aiToolMeta)
		Dim As Boolean aiStamped = AgentStampAiTemplate(newFolder, aiFolder, nm)
		Dim As WString Ptr vfpW
		WLet(vfpW, newVfp)
		OpenFiles(*vfpW)
		WDeAllocate(vfpW)
		Dim As WString Ptr mfW
		WLet(mfW, destMain)
		Dim As TabWindow Ptr mtb = GetTab(*mfW)
		If mtb = 0 Then mtb = AddTab(*mfW)
		If mtb Then
			mtb->FileEncoding = FileEncodings.Utf8
			mtb->SelectTab
		End If
		WDeAllocate(mfW)
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("project", JsonNewString(WStrToUtf8(newVfp)))
		res->SetMember("main_file", JsonNewString(WStrToUtf8(destMain)))
		res->SetMember("ai_friendly", JsonNewBool(True))
		res->SetMember("ai_tool", JsonNewString(aiToolMeta))
		res->SetMember("ai_template_stamped", JsonNewBool(aiStamped))
		gCmdOk = True
		gCmdResult = res

	Case "set_active_file_content"
		Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then
			gCmdErrCode = "no_active_file" : gCmdErrMsg = "No editor tab is active."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As String content
		Dim As Boolean hasContent = False
		If gCmdArgs Then
			Dim As JsonValue Ptr cv = gCmdArgs->Find("content")
			If cv AndAlso cv->Kind = jkString Then content = cv->StrValue : hasContent = True
		End If
		If Not hasContent Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "set_active_file_content requires 'content'."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As WString Ptr wtext = Utf8ToWStr(content)
		tb->txtCode.Text = *wtext
		WDeAllocate(wtext)
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("path", JsonNewString(WStrToUtf8(tb->FileName)))
		gCmdOk = True
		gCmdResult = res

	Case "open_in_editor"
		Dim As String rawPath
		If gCmdArgs Then rawPath = gCmdArgs->GetStr("path")
		If rawPath = "" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "open_in_editor requires a 'path'."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As String ec, em
		Dim As UString full = AgentResolveProjectPath(rawPath, ec, em)
		If ec <> "" Then
			gCmdErrCode = ec : gCmdErrMsg = em
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		If Not FileExistsU(full) Then
			gCmdErrCode = "not_found" : gCmdErrMsg = "File not found: " & rawPath
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As WString Ptr fw
		WLet(fw, full)
		Dim As TabWindow Ptr tb = GetTab(*fw)
		If tb = 0 Then tb = AddTab(*fw)
		If tb Then tb->SelectTab
		WDeAllocate(fw)
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("path", JsonNewString(WStrToUtf8(full)))
		gCmdOk = True
		gCmdResult = res

	Case "write_file"
		Dim As String rawPath, content
		Dim As Boolean doRegister, doOpen
		If gCmdArgs Then
			rawPath = gCmdArgs->GetStr("path")
			content = gCmdArgs->GetStr("content")
			doRegister = gCmdArgs->GetBool("register")
			doOpen = gCmdArgs->GetBool("open")
		End If
		If rawPath = "" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "write_file requires a 'path'."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As String ec, em
		Dim As UString full = AgentResolveProjectPath(rawPath, ec, em)
		If ec <> "" Then
			gCmdErrCode = ec : gCmdErrMsg = em
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		EnsureDirectoryExists(GetFolderNameU(full))
		If Not AgentWriteFileBytes(full, content) Then
			gCmdErrCode = "write_failed" : gCmdErrMsg = "Could not write file: " & rawPath
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As Boolean registered = False, opened = False
		If doRegister Then registered = AgentRegisterFileInProject(full)
		'' Keep existing editor buffer authoritative
		Dim As WString Ptr existingW
		WLet(existingW, full)
		Dim As TabWindow Ptr existingTb = GetTab(*existingW)
		If existingTb Then
			Dim As WString Ptr existingText = Utf8ToWStr(content)
			existingTb->txtCode.Text = *existingText
			existingTb->FileEncoding = FileEncodings.Utf8
			WDeAllocate(existingText)
		End If
		WDeAllocate(existingW)
		If doOpen Then
			Dim As WString Ptr fw
			WLet(fw, full)
			Dim As TabWindow Ptr tb = existingTb
			If tb = 0 Then tb = AddTab(*fw)
			If tb Then tb->SelectTab
			opened = (tb <> 0)
			WDeAllocate(fw)
		End If
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("path", JsonNewString(WStrToUtf8(full)))
		res->SetMember("registered", JsonNewBool(registered))
		res->SetMember("opened", JsonNewBool(opened))
		gCmdOk = True
		gCmdResult = res

	Case "add_file"
		Dim As String nm, kind
		Dim As Boolean doRegister = True, doOpen = True
		If gCmdArgs Then
			nm = gCmdArgs->GetStr("name")
			kind = LCase(gCmdArgs->GetStr("kind"))
			If gCmdArgs->Find("register") Then doRegister = gCmdArgs->GetBool("register")
			If gCmdArgs->Find("open") Then doOpen = gCmdArgs->GetBool("open")
		End If
		If nm = "" Then
			gCmdErrCode = "bad_args" : gCmdErrMsg = "add_file requires a 'name'."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As String tmplFile, ext
		Select Case kind
		Case "module", "" : tmplFile = "Module.bas"      : ext = ".bas"
		Case "header"     : tmplFile = "Include File.bi" : ext = ".bi"
		Case "form"       : tmplFile = "Form.frm"        : ext = ".frm"
		Case Else
			gCmdErrCode = "bad_args" : gCmdErrMsg = "add_file 'kind' must be module, header, or form."
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End Select
		Dim As String fileName = nm
		If Right(LCase(fileName), Len(ext)) <> ext Then fileName &= ext
		Dim As String ec, em
		Dim As UString full = AgentResolveProjectPath(fileName, ec, em)
		If ec <> "" Then
			gCmdErrCode = ec : gCmdErrMsg = em
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		If FileExistsU(full) Then
			gCmdErrCode = "exists" : gCmdErrMsg = "File already exists: " & fileName
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As UString tmplPath = ExePath & "/Templates/Files/" & tmplFile
		If Not CopyFileU(tmplPath, full) Then
			gCmdErrCode = "write_failed" : gCmdErrMsg = "Could not create file from template: " & fileName
			Dim As Byte dummy = 1 : write_(gCmdDoneFd(1), @dummy, 1) : Exit Sub
		End If
		Dim As Boolean registered = False, opened = False
		If doRegister Then registered = AgentRegisterFileInProject(full)
		If doOpen Then
			Dim As WString Ptr fw
			WLet(fw, full)
			Dim As Boolean bIsForm = (kind = "form")
			Dim As TabWindow Ptr tb = AddTab(*fw, bIsForm)
			If tb Then tb->SelectTab
			opened = (tb <> 0)
			WDeAllocate(fw)
		End If
		Dim As JsonValue Ptr res = JsonNewObject()
		res->SetMember("path", JsonNewString(WStrToUtf8(full)))
		res->SetMember("registered", JsonNewBool(registered))
		res->SetMember("opened", JsonNewBool(opened))
		gCmdOk = True
		gCmdResult = res

	Case "__save_dirty"
		'' Internal: flush dirty editors to disk before build
		For j As Integer = 0 To ptabCode->TabCount - 1
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, ptabCode->Tabs[j])
			If tb <> 0 AndAlso tb->Modified Then
				If tb->FileEncoding = FileEncodings.Utf8BOM Then tb->FileEncoding = FileEncodings.Utf8
				tb->Save
			End If
		Next j
		gCmdOk = True

	Case Else
		gCmdErrCode = "unknown_cmd"
		gCmdErrMsg = "Unknown command: " & gCmdName
	End Select
	'' Signal the worker thread that we're done
	Dim As Byte dummy = 1
	write_(gCmdDoneFd(1), @dummy, 1)
End Sub

'' ---------------------------------------------------------------- idle callback
'' Called from GTK main loop to execute the pending command on the UI thread.

Function agent_idle_cb(userdata As Any Ptr) As Long
	AgentPipe_ExecutePendingOnUi()
	Return 0   '' G_SOURCE_REMOVE — run once
End Function

'' ---------------------------------------------------------------- worker thread

Private Function AgentIdJson(req As JsonValue Ptr) As String
	If req = 0 Then Return "null"
	Dim As JsonValue Ptr idv = req->Find("id")
	If idv = 0 Then Return "null"
	Return JsonSerialize(idv)
End Function

Private Sub AgentWriteLine(fd As Integer, ByRef reqLine As String)
	Dim As String outBuf = reqLine & Chr(10)
	Dim As Byte Ptr p = Cast(Byte Ptr, StrPtr(outBuf))
	Dim As Integer remaining = Len(outBuf)
	While remaining > 0
		Dim As Integer n = write_(fd, p, remaining)
		If n <= 0 Then Exit While
		p += n : remaining -= n
	Wend
End Sub

Private Function AgentReadLine(fd As Integer, ByRef acc As String) As Boolean
	Dim As UByte buf(0 To 4095)
	Dim As Integer n = read_(fd, @buf(0), 4096)
	If n <= 0 Then Return False
	Dim As String chunk = String(n, 0)
	For i As Integer = 0 To n - 1
		chunk[i] = buf(i)
	Next i
	acc &= chunk
	Return True
End Function

Private Sub AgentHandleLine(fd As Integer, ByRef reqLine As String)
	If Len(reqLine) > 0 AndAlso reqLine[Len(reqLine) - 1] = 13 Then reqLine = Left(reqLine, Len(reqLine) - 1)
	If Len(Trim(reqLine)) = 0 Then Exit Sub

	Dim As JsonValue Ptr req = JsonParse(reqLine)
	Dim As String idJson = AgentIdJson(req)
	Dim As String resp

	If req = 0 OrElse req->Kind <> jkObject Then
		If req Then Delete req
		resp = "{""id"":null,""ok"":false,""error"":{""code"":""bad_json"",""message"":""Request is not a valid JSON object.""}}"
		AgentWriteLine(fd, resp)
		Exit Sub
	End If

	'' Long-running builds run on worker thread (Compile self-marshals UI writes)
	Dim As String cmdEarly = req->GetStr("cmd")
	If cmdEarly = "build" OrElse cmdEarly = "syntax_check" OrElse cmdEarly = "run" Then
		'' Flush dirty editors first on UI thread
		gCmdName = "__save_dirty"
		gCmdArgs = 0
		'' Drain any stale byte in the done pipe
		Dim As Byte drainBuf(0 To 15)
		While read_(gCmdDoneFd(0), @drainBuf(0), 16) > 0 : Wend
		gCmdPending = True
		idle_add(@agent_idle_cb, 0)
		Dim As Byte dummy
		read_(gCmdDoneFd(0), @dummy, 1)   '' wait for UI thread
		If gAgentStop Then Delete req : Exit Sub
		resp = AgentHandleBuildCmd(cmdEarly, idJson)
		Delete req
		AgentWriteLine(fd, resp)
		Exit Sub
	End If

	'' Publish into slot and marshal to UI thread
	gCmdName = req->GetStr("cmd")
	gCmdArgs = req->Find("args")
	'' Drain stale byte
	Dim As Byte drainBuf2(0 To 15)
	While read_(gCmdDoneFd(0), @drainBuf2(0), 16) > 0 : Wend
	gCmdPending = True
	idle_add(@agent_idle_cb, 0)

	'' Wait for UI thread — or shutdown
	Dim As Byte dummy
	Dim As Integer rd = read_(gCmdDoneFd(0), @dummy, 1)
	If rd <= 0 Then   '' pipe closed (shutdown)
		Delete req
		Exit Sub
	End If

	If gCmdOk Then
		Dim As String resultJson = "{}"
		If gCmdResult Then resultJson = JsonSerialize(gCmdResult)
		resp = "{""id"":" & idJson & ",""ok"":true,""result"":" & resultJson & "}"
	Else
		resp = "{""id"":" & idJson & ",""ok"":false,""error"":{""code"":""" & JsonEscape(gCmdErrCode) & _
			""",""message"":""" & JsonEscape(gCmdErrMsg) & """}}"
	End If
	If gCmdResult Then Delete gCmdResult : gCmdResult = 0
	gCmdArgs = 0
	Delete req
	AgentWriteLine(fd, resp)
End Sub

'' ---------------------------------------------------------------- worker thread entry

Private Sub AgentPipeThread_(param As Any Ptr)
	'' Remove any stale socket file
	unlink(AGENT_SOCK_PATH)

	gAgentListenFd = socket_(AF_UNIX, SOCK_STREAM, 0)
	If gAgentListenFd < 0 Then
		gAgentActive = False
		Exit Sub
	End If

	Dim As sockaddr_un addr
	addr.sun_family = AF_UNIX
	Dim As ZString * 108 pathCopy = AGENT_SOCK_PATH
	memcpy(@addr.sun_path, @pathCopy, Len(AGENT_SOCK_PATH) + 1)

	If bind(gAgentListenFd, Cast(sockaddr Ptr, @addr), SizeOf(sockaddr_un)) < 0 Then
		close_(gAgentListenFd)
		gAgentListenFd = -1
		gAgentActive = False
		Exit Sub
	End If

	'' Make the socket accessible

	If listen(gAgentListenFd, 1) < 0 Then
		close_(gAgentListenFd)
		unlink(AGENT_SOCK_PATH)
		gAgentListenFd = -1
		gAgentActive = False
		Exit Sub
	End If

	While Not gAgentStop
		Dim As Integer clientFd = accept(gAgentListenFd, NULL, NULL)
		If clientFd < 0 Then
			If gAgentStop Then Exit While
			Continue While
		End If
		If gAgentStop Then
			close_(clientFd)
			Exit While
		End If

		Dim As String acc
		Do While Not gAgentStop
			If Not AgentReadLine(clientFd, acc) Then Exit Do
			Do
				Dim As Integer nl = InStr(acc, Chr(10))
				If nl = 0 Then Exit Do
				Dim As String reqLine = Left(acc, nl - 1)
				acc = Mid(acc, nl + 1)
				AgentHandleLine(clientFd, reqLine)
			Loop
		Loop
		close_(clientFd)
	Wend

	close_(gAgentListenFd)
	unlink(AGENT_SOCK_PATH)
	gAgentListenFd = -1
	gAgentActive = False
End Sub

'' ---------------------------------------------------------------- lifecycle

Sub StartAgentPipe()
	If gAgentActive Then Exit Sub
	'' Create the completion-signal pipe
	If gCmdDoneFd(0) = -1 Then
		If pipe_(@gCmdDoneFd(0)) <> 0 Then Exit Sub
	End If
	gAgentStop = False
	gAgentActive = True
	gAgentThread = ThreadCreate_(@AgentPipeThread_, 0)
End Sub

Sub StopAgentPipe()
	If Not gAgentActive Then Exit Sub
	gAgentStop = True
	'' Wake up blocking accept() by connecting to our own socket
	If gAgentListenFd >= 0 Then
		Dim As Integer wakeFd = socket_(AF_UNIX, SOCK_STREAM, 0)
		If wakeFd >= 0 Then
			Dim As sockaddr_un addr
			addr.sun_family = AF_UNIX
			Dim As ZString * 108 pathCopy = AGENT_SOCK_PATH
			memcpy(@addr.sun_path, @pathCopy, Len(AGENT_SOCK_PATH) + 1)
			connect(wakeFd, Cast(sockaddr Ptr, @addr), SizeOf(sockaddr_un))
			close_(wakeFd)
		End If
	End If
	If gAgentThread Then
		ThreadWait(gAgentThread)
		gAgentThread = 0
	End If
	'' Close completion pipe
	If gCmdDoneFd(0) >= 0 Then close_(gCmdDoneFd(0)) : gCmdDoneFd(0) = -1
	If gCmdDoneFd(1) >= 0 Then close_(gCmdDoneFd(1)) : gCmdDoneFd(1) = -1
	gAgentActive = False
End Sub

Function AgentPipeActive() As Boolean
	Return gAgentActive
End Function
