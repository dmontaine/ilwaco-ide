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

'' ---------------------------------------------------------------- socket path

'' Prefer the per-user runtime dir (auto-cleaned on logout); fall back to /tmp.
Private Function AgentSocketPath() As String
	Dim As String rtDir = Environ("XDG_RUNTIME_DIR")
	If Len(rtDir) > 0 Then Return rtDir & "/ilwaco-agent.sock"
	Return "/tmp/ilwaco-agent-" & Str(c_getuid()) & ".sock"
End Function

'' ---------------------------------------------------------------- command dispatch (UI thread)

'' Runs the mapped command on the GTK UI thread. Task 0 knows only `ping`; later
'' tasks add the read-only, mutation, build/run and project handlers here.
Private Sub AgentDispatch(ByRef cmd As String, ByVal args As JsonValue Ptr, _
		ByRef ok As Boolean, ByRef res As JsonValue Ptr, ByRef ecode As String, ByRef emsg As String)
	ok = False : res = 0 : ecode = "" : emsg = ""
	Select Case cmd
	Case "ping"
		ok = True
		res = JsonNewObject()
		res->SetMember("pong", JsonNewBool(True))
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
