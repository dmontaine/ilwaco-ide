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

'' Build-in-progress flag reported by get_status; the async build path drives it.
Dim Shared gAgentBuilding As Boolean
'' The Compile() parameter for the pending async build ("" build / "Check" syntax check).
'' Set on the UI thread before the build thread is spawned; the single-slot model guarantees no
'' other command runs until the build completes, so the build thread reads it safely at start.
Dim Shared gAgentCompileParam As String
'' Set for the "run" command: launch the program once the build finishes clean. NOT done by passing
'' "Run" to Compile() -- that calls RunPr on the build thread, whose Shell() blocks for the whole
'' lifetime of the launched program (with a --hold terminal, until the user closes the window), so
'' the agent's request would never complete. The finalizer starts it on its own thread instead.
Dim Shared gAgentRunAfterBuild As Boolean

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
	If Not EndsWith(ptn->Text, "*") Then ptn->Text = ptn->Text & "*"   '' dirty marker on the project node
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

'' Add a .vfp to the explorer, make it the active (main) project, and track it as recent -- what
'' OpenFiles' .vfp branch does (AddProject + RecentProject) PLUS SetMainNode. AddProject only
'' auto-sets MainNode when none is open, so without the SetMainNode a create/open while another
'' project is already open would leave the OLD project "main" and every project-scoped tool would
'' keep acting on it. Returns the new project node, or 0 if it did not load. UI thread.
Private Function AgentOpenProjectNode(ByRef vfp As UString) As TreeNode Ptr
	Dim As TreeNode Ptr ptn = AddProject(vfp)
	If ptn = 0 Then Return 0
	SetMainNode ptn
	WLet(RecentProject, vfp)
	Return ptn
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
	If AgentOpenProjectNode(vfp) = 0 Then ecode = "open_failed" : emsg = "Project did not load: " & path : Return 0
	Dim As ProjectElement Ptr ppe = AgentProject()
	If ppe = 0 Then ecode = "open_failed" : emsg = "Project did not load: " & path : Return 0
	Dim As JsonValue Ptr r = JsonNewObject()
	r->SetMember("project", JsonNewString(ToUtf8(WGet(ppe->FileName))))
	r->SetMember("main_file", JsonNewString(ToUtf8(WGet(ppe->MainFileName))))
	Return r
End Function

'' Create a new project from a template under ProjectsPath, then open it. Headless equivalent of
'' the New Project dialog (frmNewProject.frm), mirroring its copy flow so the two paths stay in step:
''   Templates/Projects/<Template>.vfp is the manifest; Templates/Projects/<Template>/ holds its files.
'' FolderCopy flattens the template folder into the new project folder, so the manifest's
'' "<Template>/…" path prefixes are stripped. The project is named after its folder.
'' AI EXTENSION POINT: when Ilwaco's AI features return, this is where the "Make project AI friendly"
'' stamping goes (AIFriendly/AITool keys + the AI template), matching what the dialog will write. It is
'' deferred, not dropped -- keep this handler and frmNewProject writing the same keys so they never drift.
Private Function AgentCmdCreateProject(ByVal args As JsonValue Ptr, ByRef ecode As String, ByRef emsg As String) As JsonValue Ptr
	If args = 0 Then ecode = "bad_args" : emsg = "create_project requires { name }." : Return 0
	Dim As String nm = Trim(args->GetStr("name"))
	If nm = "" Then ecode = "bad_args" : emsg = "create_project requires a name." : Return 0
	'' The name is a bare folder name: no path separators, no "..", so it can only land under ProjectsPath.
	If InStr(nm, "/") > 0 OrElse InStr(nm, "\") > 0 OrElse InStr(nm, "..") > 0 Then
		ecode = "bad_args" : emsg = "Project name must be a bare name, not a path." : Return 0
	End If
	Dim As String template = Trim(args->GetStr("template", "Console Application"))
	If template = "" Then template = "Console Application"

	Dim As UString templatesDir = ExePath & Slash & "Templates" & Slash & "Projects" & Slash
	Dim As UString templateFolder = templatesDir & template
	Dim As UString templateVfp = templatesDir & template & ".vfp"
	If Not FileExists(templateVfp) Then ecode = "bad_args" : emsg = "Unknown project template: " & template : Return 0

	Dim As UString projectsRoot = GetFullPath(*ProjectsPath)
	If Not FolderExists(projectsRoot) Then MkDir projectsRoot     '' first project on a fresh install
	Dim As UString newFolder = GetFullPath(*ProjectsPath & Slash & nm)
	If FolderExists(newFolder) Then ecode = "exists" : emsg = "A project folder named '" & nm & "' already exists." : Return 0

	'' Copy the template's files (if it ships a folder), then its manifest to <name>.vfp beside them.
	If FolderExists(templateFolder) Then
		FolderCopy(templateFolder, newFolder)
	Else
		MkDir newFolder
	End If
	If Not FolderExists(newFolder) Then ecode = "write_failed" : emsg = "Could not create the project folder." : Return 0
	Dim As UString newVfp = newFolder & Slash & GetFileName(newFolder) & ".vfp"
	FileCopy_(templateVfp, newVfp)
	If Not FileExists(newVfp) Then ecode = "write_failed" : emsg = "Could not create the project file." : Return 0

	'' Strip the "<Template>/" prefix FolderCopy flattened away, or the manifest points at nothing.
	Dim As String manifest = AgentReadFileBytes(newVfp)
	manifest = Replace(manifest, template & Slash, "")
	If Not AgentWriteFileBytes(newVfp, manifest) Then ecode = "write_failed" : emsg = "Could not write the project file." : Return 0

	'' Open it and make it the active project (same helper open_project uses).
	If AgentOpenProjectNode(newVfp) = 0 Then ecode = "open_failed" : emsg = "Project created but did not load: " & nm : Return 0
	Dim As ProjectElement Ptr ppe = AgentProject()
	If ppe = 0 Then ecode = "open_failed" : emsg = "Project created but did not load: " & nm : Return 0
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

'' ---------------------------------------------------------------- build / run / errors (async)
'' The build runs the SAME code the menu runs -- Compile() -- which is designed to run OFF the UI
'' thread (it does its own ThreadsEnter/ThreadsLeave around every widget touch). So we cannot run it
'' inside the g_idle callback (that would freeze the GTK loop and deadlock ThreadsEnter). Instead:
''   UI thread (AgentStartBuild):  save dirty tabs, set gAgentBuilding, spawn a build thread, return
''                                 async=True so AgentIdleExec does NOT complete the slot yet.
''   build thread (AgentBuildThread): run Compile(param); when it returns, g_idle_add the finalizer.
''   UI thread (AgentBuildFinalize):  read the Problems list into the result, clear gAgentBuilding,
''                                    launch the program if this was "run" and the build was clean,
''                                    complete the command slot and wake the still-waiting pipe worker.
'' The single-slot model means no other agent command runs meanwhile, so gAgentCompileParam and the
'' slot are ours exclusively until the finalizer signals gCmdDone.

'' Read the live Problems list (lvProblems) into a JSON array of {severity,message,file,line}, and
'' return the error/warning counts by ref. Compile() populates lvProblems: Text(0)=message,
'' Text(1)=line, Text(2)=file; severity was set as the item's image key, which is not cleanly
'' readable back, so we re-derive it from the message text exactly as Compile's own fallback does
'' (an fbc diagnostic line contains "error" or "warning"). We skip locationless rows (no file and
'' line <= 0): those are fbc's version banner and summary lines, not real diagnostics -- the same
'' effect as Astoria matching only "file(line) error/warning" lines. A locationless failure (e.g. a
'' bare linker error) is therefore not listed here; it is still visible via get_build_output. UI thread.
Private Function AgentProblemsArray(ByRef nerr As Integer, ByRef nwarn As Integer) As JsonValue Ptr
	nerr = 0 : nwarn = 0
	Dim As JsonValue Ptr arr = JsonNewArray()
	For i As Integer = 0 To lvProblems.ListItems.Count - 1
		Dim As ListViewItem Ptr it = lvProblems.ListItems.Item(i)
		If it = 0 Then Continue For
		Dim As UString fileName = it->Text(2)
		Dim As Integer lineNo = Val(it->Text(1))
		If fileName = "" AndAlso lineNo <= 0 Then Continue For   '' banner / summary line, not a diagnostic
		Dim As UString msg = it->Text(0)
		Dim As UString sev = "info"
		If InStr(LCase(msg), "error") > 0 Then
			sev = "error" : nerr += 1
		ElseIf InStr(LCase(msg), "warning") > 0 Then
			sev = "warning" : nwarn += 1
		End If
		Dim As JsonValue Ptr e = JsonNewObject()
		e->SetMember("severity", JsonNewString(ToUtf8(sev)))
		e->SetMember("message", JsonNewString(ToUtf8(msg)))
		e->SetMember("file", JsonNewString(ToUtf8(fileName)))
		e->SetMember("line", JsonNewNumber(lineNo))
		arr->Append(e)
	Next i
	Return arr
End Function

'' get_errors -- read-only, synchronous: the structured diagnostics from the most recent build.
Private Function AgentCmdGetErrors() As JsonValue Ptr
	Dim As Integer nerr, nwarn
	Dim As JsonValue Ptr arr = AgentProblemsArray(nerr, nwarn)
	Dim As JsonValue Ptr r = JsonNewObject()
	r->SetMember("errors", arr)
	r->SetMember("error_count", JsonNewNumber(nerr))
	r->SetMember("warning_count", JsonNewNumber(nwarn))
	Return r
End Function

'' g_idle_add finalizer -- runs on the UI thread after the build thread's Compile() returns.
'' Builds the result from the Problems list, clears the building flag, and completes the slot the
'' pipe worker is still blocked on. One-shot (returns G_SOURCE_REMOVE).
Private Function AgentBuildFinalize(ByVal user As Any Ptr) As Long
	Dim As Integer nerr, nwarn
	Dim As JsonValue Ptr arr = AgentProblemsArray(nerr, nwarn)
	Dim As JsonValue Ptr r = JsonNewObject()
	r->SetMember("success", JsonNewBool(nerr = 0))
	r->SetMember("error_count", JsonNewNumber(nerr))
	r->SetMember("warning_count", JsonNewNumber(nwarn))
	r->SetMember("errors", arr)
	gAgentBuilding = False
	'' "run" = build, then launch on its own thread -- exactly what the Run menu item does
	'' (ThreadCreate_(@RunProgram)). Launching from here rather than from Compile("Run") is what
	'' lets the agent's request complete now, while the program keeps running in its terminal.
	If gAgentRunAfterBuild Then
		gAgentRunAfterBuild = False
		If nerr = 0 Then ThreadCounter(ThreadCreate_(@RunProgram, NULL))
	End If
	MutexLock(gCmdMutex)
	gCmdOk = True : gCmdResult = r : gCmdErrCode = "" : gCmdErrMsg = ""
	gCmdDone = True
	CondSignal(gCmdCond)
	MutexUnlock(gCmdMutex)
	Return 0        '' G_SOURCE_REMOVE
End Function

'' Build worker thread: run the compile (same call the menu makes), then schedule the finalizer on
'' the UI thread. Compile() manages its own widget marshalling. A "run" is a plain build here; the
'' launch happens in the finalizer, so this thread never waits on the launched program.
Private Sub AgentBuildThread(ByVal param As Any Ptr)
	Compile(gAgentCompileParam)
	g_idle_add(Cast(GSourceFunc, @AgentBuildFinalize), NULL)
End Sub

'' Kick an async build. UI thread. Maps the command to a Compile() parameter, saves dirty tabs
'' silently (SaveAll, never the mode-3 save-picker modal that would stall a headless agent), flags
'' building, and spawns the build thread. Sets async=True on success so the slot completes later in
'' AgentBuildFinalize; on a synchronous failure leaves async=False and sets err* for a normal reply.
Private Sub AgentStartBuild(ByRef cmd As String, ByRef ecode As String, ByRef emsg As String, ByRef async As Boolean)
	async = False
	If AgentProject() = 0 Then ecode = "no_project" : emsg = "No project is open." : Exit Sub
	Dim As String p = ""
	If cmd = "syntax_check" Then p = "Check"
	SaveAll()
	gAgentCompileParam = p
	gAgentRunAfterBuild = (cmd = "run")
	gAgentBuilding = True
	Dim As Any Ptr th = ThreadCreate_(@AgentBuildThread, NULL)
	If th = 0 Then
		gAgentBuilding = False
		gAgentRunAfterBuild = False
		ecode = "build_failed" : emsg = "Could not start the build thread."
		Exit Sub
	End If
	ThreadCounter(th)
	async = True
End Sub

'' ---------------------------------------------------------------- command dispatch (UI thread)

'' Runs the mapped command on the GTK UI thread. Read-only surface so far; later
'' tasks add the mutation, build/run and project handlers here.
Private Sub AgentDispatch(ByRef cmd As String, ByVal args As JsonValue Ptr, _
		ByRef ok As Boolean, ByRef res As JsonValue Ptr, ByRef ecode As String, ByRef emsg As String, _
		ByRef async As Boolean)
	ok = False : res = 0 : ecode = "" : emsg = "" : async = False
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
	Case "create_project"
		res = AgentCmdCreateProject(args, ecode, emsg) : ok = (res <> 0)
	Case "write_file"
		res = AgentCmdWriteFile(args, ecode, emsg) : ok = (res <> 0)
	Case "add_file"
		res = AgentCmdAddFile(args, ecode, emsg) : ok = (res <> 0)
	Case "set_active_file_content"
		res = AgentCmdSetActiveContent(args, ecode, emsg) : ok = (res <> 0)
	Case "open_in_editor"
		res = AgentCmdOpenInEditor(args, ecode, emsg) : ok = (res <> 0)
	Case "get_errors"
		res = AgentCmdGetErrors() : ok = True
	Case "build", "syntax_check", "run"
		AgentStartBuild(cmd, ecode, emsg, async)
		'' async=True -> the slot completes later in AgentBuildFinalize (ok/res set there);
		'' async=False -> a synchronous failure (ecode set), replied normally below.
		ok = (ecode = "")
	Case Else
		ecode = "unknown_cmd" : emsg = "Unknown command: " & cmd
	End Select
End Sub

'' g_idle_add callback -- runs on the UI thread, executes the published slot,
'' fills the result and signals the waiting worker. One-shot (returns FALSE).
Private Function AgentIdleExec(ByVal user As Any Ptr) As Long
	Dim As Boolean ok, async
	Dim As JsonValue Ptr res
	Dim As String ecode, emsg
	AgentDispatch(gCmdName, gCmdArgs, ok, res, ecode, emsg, async)
	'' Async command (build/run): the slot is completed later by AgentBuildFinalize once the build
	'' thread finishes. Leave gCmdDone False so the pipe worker keeps waiting; do not signal here.
	If async Then Return 0
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
