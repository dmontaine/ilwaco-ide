'#########################################################
'#  AgentPipe.bas                                        #
'#  This file is part of Ilwaco IDE                      #
'#  See AgentPipe.bi for the contract.                   #
'#                                                       #
'#  Protocol: newline-delimited JSON over a Unix socket, #
'#  one request/response per connection, UTF-8.          #
'#     request:  { "id": 42, "cmd": "ping", "args": {} } #
'#     success:  { "id": 42, "ok": true, "result": {} }  #
'#     failure:  { "id": 42, "ok": false,                #
'#                "error": { "code": "..","message":".."}}#
'#########################################################

'' ---------------------------------------------------------------- libc / socket
'' Declared with explicit C aliases so FB keyword clashes (socket/close/read/write)
'' and header-name drift don't matter. socklen_t is C `unsigned int` (32-bit) = ULong;
'' size_t/ssize_t are pointer-sized = UInteger/Integer on x86_64.

Extern "C"
	Declare Function c_socket  Alias "socket"  (ByVal domain As Long, ByVal typ As Long, ByVal protocol As Long) As Long
	Declare Function c_bind    Alias "bind"    (ByVal fd As Long, ByVal addr As Any Ptr, ByVal length As ULong) As Long
	Declare Function c_listen  Alias "listen"  (ByVal fd As Long, ByVal backlog As Long) As Long
	Declare Function c_accept  Alias "accept"  (ByVal fd As Long, ByVal addr As Any Ptr, ByVal length As Any Ptr) As Long
	Declare Function c_connect Alias "connect" (ByVal fd As Long, ByVal addr As Any Ptr, ByVal length As ULong) As Long
	Declare Function c_close   Alias "close"   (ByVal fd As Long) As Long
	Declare Function c_unlink  Alias "unlink"  (ByVal path As ZString Ptr) As Long
	Declare Function c_read    Alias "read"    (ByVal fd As Long, ByVal buf As Any Ptr, ByVal n As UInteger) As Integer
	Declare Function c_write   Alias "write"   (ByVal fd As Long, ByVal buf As Any Ptr, ByVal n As UInteger) As Integer
	Declare Function c_getuid  Alias "getuid"  () As ULong
End Extern

#define AGENT_AF_UNIX     1
#define AGENT_SOCK_STREAM 1

Type AgentSockAddrUn
	sun_family As UShort            '' sa_family_t (AF_UNIX)
	sun_path   As ZString * 108
End Type

'' ---------------------------------------------------------------- state

Dim Shared gAgentThread As Any Ptr              '' worker thread handle (ThreadCreate)
Dim Shared gAgentStop As Boolean                '' worker shutdown flag
Dim Shared gAgentActive As Boolean              '' listener up (StartAgentPipe..StopAgentPipe)
Dim Shared gListenFd As Long = -1               '' listening socket
Dim Shared gAgentClientConnected As Boolean     '' set only while a client is connected

'' The single in-flight command slot. The worker publishes it, g_idle_add runs
'' AgentIdleExec on the UI thread, which fills the result and signals gCmdCond.
Dim Shared gCmdMutex As Any Ptr
Dim Shared gCmdCond As Any Ptr
Dim Shared gCmdDone As Boolean
Dim Shared gCmdName As String                   '' UTF-8
Dim Shared gCmdArgs As JsonValue Ptr            '' borrowed view into the request tree (may be 0)
Dim Shared gCmdOk As Boolean
Dim Shared gCmdResult As JsonValue Ptr          '' owned; set by the UI thread on success
Dim Shared gCmdErrCode As String
Dim Shared gCmdErrMsg As String

'' Build-in-progress flag reported by get_status; the async build path (a later task) drives it.
Dim Shared gAgentBuilding As Boolean

'' ---------------------------------------------------------------- socket path

'' Prefer the per-user runtime dir (auto-cleaned on logout); fall back to /tmp.
Private Function AgentSocketPath() As String
	Dim As String rtDir = Environ("XDG_RUNTIME_DIR")
	If Len(rtDir) > 0 Then Return rtDir & "/ilwaco-agent.sock"
	Return "/tmp/ilwaco-agent-" & Str(c_getuid()) & ".sock"
End Function

'' ---------------------------------------------------------------- IDE model helpers (UI thread)
'' All of these run on the GTK UI thread (called from AgentDispatch), so touching
'' controls and the project tree is safe. The IDE stores text as WString; the pipe
'' speaks UTF-8, so ToUtf8/FromUtf8 (MFF) convert at the boundary.

'' The open project's ProjectElement, or 0 if none is open. MainNode is the global
'' project tree node; its Tag is an ExplorerElement that Is a ProjectElement.
Private Function AgentProject() As ProjectElement Ptr
	If MainNode = 0 OrElse MainNode->Tag = 0 Then Return 0
	Dim As ExplorerElement Ptr ee = MainNode->Tag
	If *ee Is ProjectElement Then Return Cast(ProjectElement Ptr, ee)
	Return 0
End Function

'' The focused code editor tab, or 0 if none. ptabCode is the active code TabControl.
Private Function AgentActiveTab() As TabWindow Ptr
	If ptabCode = 0 Then Return 0
	Return Cast(TabWindow Ptr, ptabCode->SelectedTab)
End Function

'' Collapse "." and ".." segments on an absolute Linux path -- LEXICALLY, no filesystem
'' access. This is the load-bearing half of the containment guard: without it a path like
'' ".../Project/../../etc/passwd" still text-starts with the project folder and would pass a
'' naive prefix check while the OS resolves it outside. GetFullPath does NOT collapse "..",
'' so we do it here. (Lexical only: a symlink inside the project could still point out; that
'' residual matches the opt-in, local, single-user threat model.)
Private Function AgentNormalizePath(ByRef p As UString) As UString
	If Len(p) = 0 OrElse Left(p, 1) <> "/" Then Return p     '' only meaningful for absolute paths
	Dim As UString segs(0 To 1023)
	Dim As Integer cnt = 0
	Dim As UString work = p & "/"                            '' sentinel so the last segment flushes
	Dim As UString cur = ""
	For i As Integer = 2 To Len(work)                        '' 1-based; skip the leading "/"
		Dim As UString ch = Mid(work, i, 1)
		If ch = "/" Then
			If cur = "" OrElse cur = "." Then
				'' skip empty ("//") and "."
			ElseIf cur = ".." Then
				If cnt > 0 Then cnt -= 1
			ElseIf cnt <= UBound(segs) Then
				segs(cnt) = cur : cnt += 1
			End If
			cur = ""
		Else
			cur &= ch
		End If
	Next
	Dim As UString result = ""
	For j As Integer = 0 To cnt - 1
		result &= "/" & segs(j)
	Next
	If result = "" Then result = "/"
	Return result
End Function

'' Resolve a client-supplied path (project-relative or absolute) and reject anything that
'' escapes the open project's folder. Returns "" and sets err* on rejection. Linux paths are
'' relative unless they start with "/"; containment is on the CANONICALIZED path.
Private Function AgentResolveProjectPath(ByRef rawUtf8 As String, ByRef errCode As String, ByRef errMsg As String) As UString
	errCode = "" : errMsg = ""
	Dim As ProjectElement Ptr ppe = AgentProject()
	If ppe = 0 Then errCode = "no_project" : errMsg = "No project is open." : Return ""
	Dim As UString root = GetFolderName(WGet(ppe->FileName))   '' project folder, trailing slash, absolute
	If root = "" Then errCode = "no_project" : errMsg = "Project folder not found." : Return ""
	Dim As WString Ptr rawW = FromUtf8(StrPtr(rawUtf8))
	Dim As UString candidate
	If rawW <> 0 AndAlso Len(*rawW) > 0 AndAlso Left(*rawW, 1) = "/" Then
		candidate = *rawW                                      '' absolute as given
	Else
		candidate = root & *rawW                               '' relative -> against the project folder
	End If
	If rawW <> 0 Then WDeAllocate(rawW)
	Dim As UString nres = AgentNormalizePath(candidate)
	Dim As UString nroot = AgentNormalizePath(root)            '' also strips the trailing slash
	If (nres <> nroot) AndAlso (Left(nres, Len(nroot) + 1) <> nroot & "/") Then
		errCode = "bad_path" : errMsg = "Path escapes the project folder: " & rawUtf8
		Return ""
	End If
	Return nres
End Function

'' Read a whole file as raw bytes (UTF-8 on disk); strips a BOM if present. Empty on
'' open failure -- callers check FileExists first to distinguish "missing" from "empty".
Private Function AgentReadFileBytes(ByRef path As UString) As String
	Dim As Integer fn = FreeFile_
	If Open(path For Binary Access Read As #fn) <> 0 Then Return ""
	Dim As LongInt sz = LOF(fn)
	Dim As String buf
	If sz > 0 Then
		buf = String(sz, 0)
		Get #fn, 1, buf
	End If
	Close #fn
	If Len(buf) >= 3 AndAlso buf[0] = &HEF AndAlso buf[1] = &HBB AndAlso buf[2] = &HBF Then buf = Mid(buf, 4)
	Return buf
End Function

'' Write raw bytes to a file, creating/truncating. Content is written as-is (UTF-8 from JSON,
'' no BOM -- matches the source-file convention). Output truncates/creates; the Binary reopen
'' writes the bytes. UI thread.
Private Function AgentWriteFileBytes(ByRef path As UString, ByRef content As String) As Boolean
	Dim As Integer fn = FreeFile_
	If Open(path For Output As #fn) <> 0 Then Return False      '' truncate/create
	Close #fn
	fn = FreeFile_
	If Open(path For Binary Access Write As #fn) <> 0 Then Return False
	If Len(content) > 0 Then Put #fn, 1, content
	Close #fn
	Return True
End Function

'' Register an existing on-disk file into the open project's tree, so a project save persists
'' it and a build includes it. Mirrors AddFilesToProject's non-dialog branch (folder routing via
'' GetTreeNodeChild, an ExplorerElement + tree node, mark the project node dirty). Idempotent.
Private Function AgentRegisterFileInProject(ByRef fullPath As UString) As Boolean
	Dim As TreeNode Ptr ptn = MainNode
	If ptn = 0 Then Return False
	Dim As WString Ptr fpW : WLet(fpW, fullPath)
	Dim As TreeNode Ptr tn1 = GetTreeNodeChild(ptn, *fpW)
	If ContainsFileName(tn1, *fpW) Then WDeAllocate(fpW) : Return True   '' already present
	Dim As String IconName = GetIconName(*fpW)
	Dim As TreeNode Ptr tn3 = tn1->Nodes.Add(GetFileName(*fpW), , , IconName, IconName, True)
	Dim As ExplorerElement Ptr ee = _New(ExplorerElement)
	WLet(ee->FileName, *fpW)
	tn3->Tag = ee
	If Not EndsWith(ptn->Text, "*") Then ptn->Text &= "*"   '' dirty marker on the project node
	WDeAllocate(fpW)
	Return True
End Function

'' Open (or focus) a code tab for a file. AddTab returns the existing tab if already open.
Private Sub AgentOpenTab(ByRef fullPath As UString)
	Dim As WString Ptr fpW : WLet(fpW, fullPath)
	AddTab(*fpW)
	WDeAllocate(fpW)
End Sub

'' ---------------------------------------------------------------- read-only handlers (UI thread)

Private Function AgentCmdGetStatus() As JsonValue Ptr
	Dim As JsonValue Ptr r = JsonNewObject()
	Dim As ProjectElement Ptr ppe = AgentProject()
	If ppe Then
		r->SetMember("project", JsonNewString(ToUtf8(WGet(ppe->FileName))))
		r->SetMember("main_file", JsonNewString(ToUtf8(WGet(ppe->MainFileName))))
	Else
		r->SetMember("project", JsonNewNull())
		r->SetMember("main_file", JsonNewNull())
	End If
	Dim As JsonValue Ptr arr = JsonNewArray()
	For j As Integer = 0 To TabPanels.Count - 1
		Dim As TabPanel Ptr tp = Cast(TabPanel Ptr, TabPanels.Item(j))
		If tp = 0 Then Continue For
		Dim As TabControl Ptr tc = @tp->tabCode
		For i As Integer = 0 To tc->TabCount - 1
			Dim As TabWindow Ptr tb = Cast(TabWindow Ptr, tc->Tabs[i])
			If tb Then arr->Append(JsonNewString(ToUtf8(tb->FileName)))
		Next i
	Next j
	r->SetMember("open_files", arr)
	r->SetMember("building", JsonNewBool(gAgentBuilding))
	r->SetMember("running", JsonNewBool(False))
	Return r
End Function

'' Collect every file under a project tree node into the JSON array. The explorer tree
'' is the source of truth for the open project's files (ProjectElement.Files is only
'' rebuilt from it at compile time). File nodes carry an ExplorerElement with a non-empty
'' FileName; folder nodes carry none, so we recurse through them.
Private Sub AgentCollectFiles(ByVal tn As TreeNode Ptr, ByVal arr As JsonValue Ptr, ByVal depth As Integer)
	If tn = 0 OrElse depth > 8 Then Exit Sub
	For j As Integer = 0 To tn->Nodes.Count - 1
		Dim As TreeNode Ptr child = tn->Nodes.Item(j)
		If child = 0 Then Continue For
		Dim As ExplorerElement Ptr ee = child->Tag
		If ee <> 0 AndAlso ee->FileName <> 0 AndAlso *ee->FileName <> "" Then
			arr->Append(JsonNewString(ToUtf8(*ee->FileName)))
		End If
		If child->Nodes.Count > 0 Then AgentCollectFiles(child, arr, depth + 1)   '' folder node
	Next j
End Sub

Private Function AgentCmdListFiles(ByRef ecode As String, ByRef emsg As String) As JsonValue Ptr
	Dim As ProjectElement Ptr ppe = AgentProject()
	If ppe = 0 Then ecode = "no_project" : emsg = "No project is open." : Return 0
	Dim As JsonValue Ptr r = JsonNewObject()
	Dim As JsonValue Ptr arr = JsonNewArray()
	AgentCollectFiles(MainNode, arr, 0)
	r->SetMember("files", arr)
	r->SetMember("main_file", JsonNewString(ToUtf8(WGet(ppe->MainFileName))))
	Return r
End Function

Private Function AgentCmdReadFile(ByVal args As JsonValue Ptr, ByRef ecode As String, ByRef emsg As String) As JsonValue Ptr
	If args = 0 Then ecode = "bad_args" : emsg = "read_file requires { path }." : Return 0
	Dim As String path = args->GetStr("path")
	If path = "" Then ecode = "bad_args" : emsg = "read_file requires a path." : Return 0
	Dim As UString resolved = AgentResolveProjectPath(path, ecode, emsg)
	If ecode <> "" Then Return 0
	If Not FileExists(resolved) Then ecode = "not_found" : emsg = "File not found: " & path : Return 0
	Dim As JsonValue Ptr r = JsonNewObject()
	r->SetMember("content", JsonNewString(AgentReadFileBytes(resolved)))
	Return r
End Function

Private Function AgentCmdGetActiveFile(ByRef ecode As String, ByRef emsg As String) As JsonValue Ptr
	Dim As TabWindow Ptr tb = AgentActiveTab()
	If tb = 0 Then ecode = "no_active_file" : emsg = "No editor tab is focused." : Return 0
	Dim As JsonValue Ptr r = JsonNewObject()
	r->SetMember("path", JsonNewString(ToUtf8(tb->FileName)))
	r->SetMember("content", JsonNewString(ToUtf8(tb->txtCode.Text)))
	Return r
End Function

Private Function AgentCmdGetBuildOutput() As JsonValue Ptr
	Dim As JsonValue Ptr r = JsonNewObject()
	r->SetMember("text", JsonNewString(ToUtf8(txtOutput.Text)))
	Return r
End Function

'' Open an existing .vfp project (brought forward from the project-ops task: it is the
'' agent's mechanism for loading a project, and every project-scoped tool needs one open).
'' OpenFiles routes a .vfp to AddProject, which sets MainNode; we assert that afterwards so
'' a project that fails to load reports open_failed rather than a misleading success.
Private Function AgentCmdOpenProject(ByVal args As JsonValue Ptr, ByRef ecode As String, ByRef emsg As String) As JsonValue Ptr
	If args = 0 Then ecode = "bad_args" : emsg = "open_project requires { path }." : Return 0
	Dim As String path = args->GetStr("path")
	If path = "" Then ecode = "bad_args" : emsg = "open_project requires a path." : Return 0
	Dim As WString Ptr pw = FromUtf8(StrPtr(path))
	Dim As UString vfp = GetFullPath(*pw)
	If pw <> 0 Then WDeAllocate(pw)
	If LCase(Right(vfp, 4)) <> ".vfp" Then ecode = "bad_args" : emsg = "Not a .vfp project file: " & path : Return 0
	If Not FileExists(vfp) Then ecode = "not_found" : emsg = "Project file not found: " & path : Return 0
	OpenFiles vfp
	Dim As ProjectElement Ptr ppe = AgentProject()
	If ppe = 0 Then ecode = "open_failed" : emsg = "Project did not load: " & path : Return 0
	Dim As JsonValue Ptr r = JsonNewObject()
	r->SetMember("project", JsonNewString(ToUtf8(WGet(ppe->FileName))))
	r->SetMember("main_file", JsonNewString(ToUtf8(WGet(ppe->MainFileName))))
	Return r
End Function

'' ---------------------------------------------------------------- mutation handlers (UI thread)

Private Function AgentCmdWriteFile(ByVal args As JsonValue Ptr, ByRef ecode As String, ByRef emsg As String) As JsonValue Ptr
	If args = 0 Then ecode = "bad_args" : emsg = "write_file requires { path, content }." : Return 0
	Dim As String path = args->GetStr("path")
	If path = "" Then ecode = "bad_args" : emsg = "write_file requires a path." : Return 0
	Dim As String content = args->GetStr("content")
	Dim As UString resolved = AgentResolveProjectPath(path, ecode, emsg)
	If ecode <> "" Then Return 0
	If Not AgentWriteFileBytes(resolved, content) Then ecode = "write_failed" : emsg = "Could not write: " & path : Return 0
	Dim As Boolean registered = False, opened = False
	If args->GetBool("register") Then registered = AgentRegisterFileInProject(resolved)
	If args->GetBool("open") Then AgentOpenTab(resolved) : opened = True
	Dim As JsonValue Ptr r = JsonNewObject()
	r->SetMember("path", JsonNewString(ToUtf8(resolved)))
	r->SetMember("registered", JsonNewBool(registered))
	r->SetMember("opened", JsonNewBool(opened))
	Return r
End Function

Private Function AgentCmdAddFile(ByVal args As JsonValue Ptr, ByRef ecode As String, ByRef emsg As String) As JsonValue Ptr
	If args = 0 Then ecode = "bad_args" : emsg = "add_file requires { name }." : Return 0
	If AgentProject() = 0 Then ecode = "no_project" : emsg = "No project is open." : Return 0
	Dim As String nm = args->GetStr("name")
	If nm = "" Then ecode = "bad_args" : emsg = "add_file requires a name." : Return 0
	Dim As String kind = LCase(args->GetStr("kind", "module"))
	'' Forms need designer scaffolding a stub cannot provide -- create those in the designer.
	If kind = "form" Then ecode = "unsupported" : emsg = "add_file cannot create forms; use the form designer." : Return 0
	Dim As String ext = ".bas"
	If kind = "header" Then ext = ".bi"
	Dim As String lnm = LCase(nm)
	If Right(lnm, 4) <> ".bas" AndAlso Right(lnm, 3) <> ".bi" Then nm &= ext
	Dim As UString resolved = AgentResolveProjectPath(nm, ecode, emsg)
	If ecode <> "" Then Return 0
	If FileExists(resolved) Then ecode = "exists" : emsg = "File already exists: " & nm : Return 0
	If Not AgentWriteFileBytes(resolved, "'' " & GetFileName(resolved) & Chr(10)) Then _
		ecode = "write_failed" : emsg = "Could not write: " & nm : Return 0
	Dim As Boolean registered = True, opened = True
	If args->Find("register") <> 0 Then registered = args->GetBool("register")
	If args->Find("open") <> 0 Then opened = args->GetBool("open")
	If registered Then AgentRegisterFileInProject(resolved)
	If opened Then AgentOpenTab(resolved)
	Dim As JsonValue Ptr r = JsonNewObject()
	r->SetMember("path", JsonNewString(ToUtf8(resolved)))
	r->SetMember("registered", JsonNewBool(registered))
	r->SetMember("opened", JsonNewBool(opened))
	Return r
End Function

Private Function AgentCmdSetActiveContent(ByVal args As JsonValue Ptr, ByRef ecode As String, ByRef emsg As String) As JsonValue Ptr
	If args = 0 Then ecode = "bad_args" : emsg = "set_active_file_content requires { content }." : Return 0
	Dim As TabWindow Ptr tb = AgentActiveTab()
	If tb = 0 Then ecode = "no_active_file" : emsg = "No editor tab is focused." : Return 0
	Dim As String content = args->GetStr("content")
	Dim As WString Ptr cw = FromUtf8(StrPtr(content))
	tb->txtCode.Text = *cw
	If cw <> 0 Then WDeAllocate(cw)
	tb->Modified = True
	Dim As JsonValue Ptr r = JsonNewObject()
	r->SetMember("path", JsonNewString(ToUtf8(tb->FileName)))
	Return r
End Function

Private Function AgentCmdOpenInEditor(ByVal args As JsonValue Ptr, ByRef ecode As String, ByRef emsg As String) As JsonValue Ptr
	If args = 0 Then ecode = "bad_args" : emsg = "open_in_editor requires { path }." : Return 0
	Dim As String path = args->GetStr("path")
	If path = "" Then ecode = "bad_args" : emsg = "open_in_editor requires a path." : Return 0
	Dim As UString resolved = AgentResolveProjectPath(path, ecode, emsg)
	If ecode <> "" Then Return 0
	If Not FileExists(resolved) Then ecode = "not_found" : emsg = "File not found: " & path : Return 0
	AgentOpenTab(resolved)
	Dim As JsonValue Ptr r = JsonNewObject()
	r->SetMember("path", JsonNewString(ToUtf8(resolved)))
	Return r
End Function

'' ---------------------------------------------------------------- command dispatch (UI thread)

'' Runs the mapped command on the GTK UI thread. Read-only surface so far; later
'' tasks add the mutation, build/run and project handlers here.
Private Sub AgentDispatch(ByRef cmd As String, ByVal args As JsonValue Ptr, _
		ByRef ok As Boolean, ByRef res As JsonValue Ptr, ByRef ecode As String, ByRef emsg As String)
	ok = False : res = 0 : ecode = "" : emsg = ""
	Select Case cmd
	Case "ping"
		res = JsonNewObject() : res->SetMember("pong", JsonNewBool(True)) : ok = True
	Case "get_status"
		res = AgentCmdGetStatus() : ok = True
	Case "list_files"
		res = AgentCmdListFiles(ecode, emsg) : ok = (res <> 0)
	Case "read_file"
		res = AgentCmdReadFile(args, ecode, emsg) : ok = (res <> 0)
	Case "get_active_file"
		res = AgentCmdGetActiveFile(ecode, emsg) : ok = (res <> 0)
	Case "get_build_output"
		res = AgentCmdGetBuildOutput() : ok = True
	Case "open_project"
		res = AgentCmdOpenProject(args, ecode, emsg) : ok = (res <> 0)
	Case "write_file"
		res = AgentCmdWriteFile(args, ecode, emsg) : ok = (res <> 0)
	Case "add_file"
		res = AgentCmdAddFile(args, ecode, emsg) : ok = (res <> 0)
	Case "set_active_file_content"
		res = AgentCmdSetActiveContent(args, ecode, emsg) : ok = (res <> 0)
	Case "open_in_editor"
		res = AgentCmdOpenInEditor(args, ecode, emsg) : ok = (res <> 0)
	Case Else
		ecode = "unknown_cmd" : emsg = "Unknown command: " & cmd
	End Select
End Sub

'' g_idle_add callback -- runs on the UI thread, executes the published slot,
'' fills the result and signals the waiting worker. One-shot (returns FALSE).
Private Function AgentIdleExec(ByVal user As Any Ptr) As Long
	Dim As Boolean ok
	Dim As JsonValue Ptr res
	Dim As String ecode, emsg
	AgentDispatch(gCmdName, gCmdArgs, ok, res, ecode, emsg)
	MutexLock(gCmdMutex)
	gCmdOk = ok : gCmdResult = res : gCmdErrCode = ecode : gCmdErrMsg = emsg
	gCmdDone = True
	CondSignal(gCmdCond)
	MutexUnlock(gCmdMutex)
	Return 0        '' G_SOURCE_REMOVE
End Function

'' Marshal one command onto the UI thread and block (on the worker) until it
'' completes, then build the JSON reply. args is borrowed from the request tree,
'' which the caller must keep alive until this returns.
Private Function AgentRunCommand(ByVal idNum As Double, ByRef cmd As String, ByVal args As JsonValue Ptr) As String
	MutexLock(gCmdMutex)
	gCmdName = cmd
	gCmdArgs = args
	gCmdDone = False
	gCmdOk = False
	gCmdResult = 0
	gCmdErrCode = "" : gCmdErrMsg = ""
	MutexUnlock(gCmdMutex)

	g_idle_add(Cast(GSourceFunc, @AgentIdleExec), NULL)

	MutexLock(gCmdMutex)
	While Not gCmdDone
		CondWait(gCmdCond, gCmdMutex)
	Wend
	Dim As Boolean ok = gCmdOk
	Dim As JsonValue Ptr res = gCmdResult
	Dim As String ecode = gCmdErrCode, emsg = gCmdErrMsg
	gCmdResult = 0
	MutexUnlock(gCmdMutex)

	Dim As String idStr = Str(CLngInt(idNum))
	Dim As String r
	If ok Then
		Dim As String resStr = "{}"
		If res Then resStr = JsonSerialize(res)
		r = "{""id"":" & idStr & ",""ok"":true,""result"":" & resStr & "}"
	Else
		r = "{""id"":" & idStr & ",""ok"":false,""error"":{""code"":""" & JsonEscape(ecode) & """,""message"":""" & JsonEscape(emsg) & """}}"
	End If
	If res Then Delete res
	Return r
End Function

'' ---------------------------------------------------------------- connection

'' Serve one connection: read a single newline-terminated request, dispatch it,
'' write the reply. The sidecar opens a fresh connection per request (§ protocol).
Private Sub AgentServeClient(ByVal cfd As Long)
	Dim As String acc
	Dim As UByte buf(0 To 8191)
	Do
		If InStr(acc, Chr(10)) > 0 Then Exit Do
		Dim As Integer got = c_read(cfd, @buf(0), 8192)
		If got <= 0 Then Exit Sub          '' client closed before a full request
		Dim As String chunk = String(got, 0)
		For i As Integer = 0 To got - 1
			chunk[i] = buf(i)
		Next i
		acc &= chunk
	Loop

	Dim As Integer nl = InStr(acc, Chr(10))
	Dim As String reqLine = Left(acc, nl - 1)
	Dim As JsonValue Ptr req = JsonParse(reqLine)
	Dim As String respJson
	If req = 0 OrElse req->Kind <> jkObject Then
		respJson = "{""ok"":false,""error"":{""code"":""bad_json"",""message"":""Malformed request.""}}"
	Else
		Dim As Double idNum = req->GetNum("id", 0)
		Dim As String cmd = req->GetStr("cmd")
		Dim As JsonValue Ptr args = req->Find("args")
		respJson = AgentRunCommand(idNum, cmd, args)   '' blocks until the UI thread is done with args
	End If
	If req Then Delete req

	Dim As String wbuf = respJson & Chr(10)
	c_write(cfd, StrPtr(wbuf), Len(wbuf))
End Sub

'' Worker thread: accept connections until StopAgentPipe wakes us.
Private Sub AgentWorker(ByVal param As Any Ptr)
	Do
		Dim As Long cfd = c_accept(gListenFd, NULL, NULL)
		If gAgentStop Then
			If cfd >= 0 Then c_close(cfd)
			Exit Do
		End If
		If cfd < 0 Then Continue Do
		gAgentClientConnected = True
		AgentServeClient(cfd)
		gAgentClientConnected = False
		c_close(cfd)
	Loop
End Sub

'' Unblock the worker's accept() by briefly self-connecting to the socket.
Private Sub AgentWakeAccept()
	Dim As Long fd = c_socket(AGENT_AF_UNIX, AGENT_SOCK_STREAM, 0)
	If fd < 0 Then Exit Sub
	Dim As AgentSockAddrUn addr
	addr.sun_family = AGENT_AF_UNIX
	addr.sun_path = AgentSocketPath()
	c_connect(fd, @addr, SizeOf(addr))
	c_close(fd)
End Sub

'' ---------------------------------------------------------------- public API

Sub StartAgentPipe()
	If gAgentActive Then Exit Sub
	Dim As String path = AgentSocketPath()
	c_unlink(path)                      '' clear a stale socket file from a prior crash
	gListenFd = c_socket(AGENT_AF_UNIX, AGENT_SOCK_STREAM, 0)
	If gListenFd < 0 Then Exit Sub
	Dim As AgentSockAddrUn addr
	addr.sun_family = AGENT_AF_UNIX
	addr.sun_path = path
	If c_bind(gListenFd, @addr, SizeOf(addr)) <> 0 Then
		c_close(gListenFd) : gListenFd = -1 : Exit Sub
	End If
	If c_listen(gListenFd, 4) <> 0 Then
		c_close(gListenFd) : gListenFd = -1 : c_unlink(path) : Exit Sub
	End If
	gAgentStop = False
	gCmdMutex = MutexCreate()
	gCmdCond = CondCreate()
	gAgentThread = ThreadCreate(@AgentWorker, NULL)
	gAgentActive = True
End Sub

Sub StopAgentPipe()
	If Not gAgentActive Then Exit Sub
	gAgentStop = True
	AgentWakeAccept()
	If gAgentThread Then ThreadWait(gAgentThread) : gAgentThread = 0
	If gListenFd >= 0 Then c_close(gListenFd) : gListenFd = -1
	c_unlink(AgentSocketPath())
	If gCmdCond Then CondDestroy(gCmdCond) : gCmdCond = 0
	If gCmdMutex Then MutexDestroy(gCmdMutex) : gCmdMutex = 0
	gAgentActive = False
End Sub

Function AgentPipeActive() As Boolean
	Return gAgentActive
End Function

Function AgentClientConnected() As Boolean
	Return gAgentClientConnected
End Function
