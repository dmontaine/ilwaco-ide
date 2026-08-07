'#########################################################
'#  AgentMcp.bas  ->  ilwaco-mcp                          #
'#  This file is part of Ilwaco IDE                       #
'#                                                        #
'#  The MCP sidecar (Layer A). A FreeBASIC console app    #
'#  that speaks MCP / JSON-RPC 2.0 over stdio to an MCP   #
'#  client (Claude Code/Desktop, ...) and forwards each   #
'#  tools/call to the running Ilwaco IDE over the local   #
'#  Unix-domain socket. This is the ONLY component that   #
'#  tracks the MCP spec; the IDE socket stays a dumb      #
'#  command channel.                                      #
'#                                                        #
'#  stdio transport (MCP spec): newline-delimited JSON,   #
'#  one object per line. We use raw libc read/write on    #
'#  fd 0/1 so nothing reinterprets the byte stream.       #
'#  Linux/GTK counterpart of Astoria's astoria-mcp.exe.   #
'#########################################################

#include once "JsonLite.bi"

'' ---------------------------------------------------------------- libc
Extern "C"
	Declare Function c_socket   Alias "socket"   (ByVal domain As Long, ByVal typ As Long, ByVal protocol As Long) As Long
	Declare Function c_connect  Alias "connect"  (ByVal fd As Long, ByVal addr As Any Ptr, ByVal length As ULong) As Long
	Declare Function c_close    Alias "close"    (ByVal fd As Long) As Long
	Declare Function c_read     Alias "read"     (ByVal fd As Long, ByVal buf As Any Ptr, ByVal n As UInteger) As Integer
	Declare Function c_write    Alias "write"    (ByVal fd As Long, ByVal buf As Any Ptr, ByVal n As UInteger) As Integer
	Declare Function c_getuid   Alias "getuid"   () As ULong
	Declare Function c_readlink Alias "readlink" (ByVal path As ZString Ptr, ByVal buf As ZString Ptr, ByVal bufsiz As UInteger) As Integer
	Declare Function c_system   Alias "system"   (ByVal command As ZString Ptr) As Long
	Declare Function c_usleep   Alias "usleep"   (ByVal usec As ULong) As Long
End Extern

#define AGENT_AF_UNIX     1
#define AGENT_SOCK_STREAM 1

Type AgentSockAddrUn
	sun_family As UShort
	sun_path   As ZString * 108
End Type

Const MCP_SERVER_NAME     = "ilwaco-ide"
Const MCP_SERVER_VERSION  = "0.1.0"
Const MCP_DEFAULT_PROTOCOL = "2024-11-05"

Dim Shared gStdinAcc As String       '' leftover bytes between ReadStdinLine calls
Dim Shared gPipeReqId As LongInt     '' monotonic id for socket requests

'' Per-user socket path -- must match AgentSocketPath in AgentPipe.bas.
Function AgentSocketPath() As String
	Dim As String rtDir = Environ("XDG_RUNTIME_DIR")
	If Len(rtDir) > 0 Then Return rtDir & "/ilwaco-agent.sock"
	Return "/tmp/ilwaco-agent-" & Str(c_getuid()) & ".sock"
End Function

'' ---------------------------------------------------------------- stdio

'' One newline-delimited line from stdin (raw UTF-8 bytes). False at end of stream.
'' A trailing CR is stripped for CRLF-writing clients.
Function ReadStdinLine(ByRef outLine As String) As Boolean
	Do
		Dim As Integer nl = InStr(gStdinAcc, Chr(10))
		If nl > 0 Then
			outLine = Left(gStdinAcc, nl - 1)
			If Len(outLine) > 0 AndAlso outLine[Len(outLine) - 1] = 13 Then outLine = Left(outLine, Len(outLine) - 1)
			gStdinAcc = Mid(gStdinAcc, nl + 1)
			Return True
		End If
		Dim As UByte buf(0 To 8191)
		Dim As Integer got = c_read(0, @buf(0), 8192)
		If got <= 0 Then
			If Len(gStdinAcc) > 0 Then outLine = gStdinAcc : gStdinAcc = "" : Return True
			Return False
		End If
		Dim As String chunk = String(got, 0)
		For i As Integer = 0 To got - 1
			chunk[i] = buf(i)
		Next i
		gStdinAcc &= chunk
	Loop
End Function

Sub WriteStdoutLine(ByRef s As String)
	Dim As String wbuf = s & Chr(10)
	c_write(1, StrPtr(wbuf), Len(wbuf))
End Sub

'' Diagnostics go to stderr, which MCP clients log or ignore -- never stdout.
Sub LogErr(ByRef s As String)
	Dim As String wbuf = "[ilwaco-mcp] " & s & Chr(10)
	c_write(2, StrPtr(wbuf), Len(wbuf))
End Sub

'' ---------------------------------------------------------------- socket client

'' One request/response round-trip to the IDE over the Unix socket. Returns False if the
'' socket can't be reached (IDE not running, or AI agent control disabled). `complete` is a
'' SEPARATE result: True only when a whole newline-terminated reply came back. The two are not
'' the same -- False means the request never left (safe to retry); a reachable socket that
'' closes without a full reply is `True`/`complete=False` (NOT safe to blindly retry, since the
'' command may already have run).
Function PipeCall(ByRef reqJson As String, ByRef respJson As String, ByRef complete As Boolean) As Boolean
	complete = False
	Dim As Long fd = c_socket(AGENT_AF_UNIX, AGENT_SOCK_STREAM, 0)
	If fd < 0 Then Return False
	Dim As AgentSockAddrUn addr
	addr.sun_family = AGENT_AF_UNIX
	addr.sun_path = AgentSocketPath()
	If c_connect(fd, @addr, SizeOf(addr)) <> 0 Then
		c_close(fd)
		Return False
	End If
	Dim As String wbuf = reqJson & Chr(10)
	c_write(fd, StrPtr(wbuf), Len(wbuf))
	respJson = ""
	Dim As UByte buf(0 To 8191)
	Do
		Dim As Integer got = c_read(fd, @buf(0), 8192)
		If got <= 0 Then Exit Do
		Dim As String chunk = String(got, 0)
		For i As Integer = 0 To got - 1
			chunk[i] = buf(i)
		Next i
		respJson &= chunk
		If InStr(respJson, Chr(10)) > 0 Then Exit Do
	Loop
	c_close(fd)
	Dim As Integer nl = InStr(respJson, Chr(10))
	If nl > 0 Then
		respJson = Left(respJson, nl - 1)
		complete = True
	End If
	Return True
End Function

'' ------------------------------------------------------------ auto-launch
'' If the IDE isn't running, start it (owner's choice). ilwaco sits next to this sidecar.
'' The socket still only comes up if the user has left "Allow AI agent control" ticked, so a
'' launch does not by itself grant access -- it just spares the user from starting the IDE.

Dim Shared gIdeDir As String     '' directory containing this sidecar (== the IDE's folder)

Function SelfDir() As String
	If Len(gIdeDir) > 0 Then Return gIdeDir
	Dim As ZString * 4096 buf
	Dim As Integer n = c_readlink("/proc/self/exe", @buf, 4095)
	If n <= 0 Then gIdeDir = "." : Return gIdeDir
	buf[n] = 0
	Dim As String self = *Cast(ZString Ptr, @buf)
	Dim As Integer cut = InStrRev(self, "/")
	If cut > 0 Then gIdeDir = Left(self, cut - 1) Else gIdeDir = "."
	Return gIdeDir
End Function

'' True if any ilwaco process is running. Avoids launching a duplicate when the IDE is up but
'' the socket is down (toggle off). pgrep -x matches the exact process name; system() returns
'' the child's exit status shifted, so a 0 return means pgrep found a match.
Function IdeIsRunning() As Boolean
	Return (c_system("pgrep -x ilwaco >/dev/null 2>&1") = 0)
End Function

'' Launch the IDE (non-blocking, detached from our stdio which carries the MCP stream). The
'' child inherits our environment (so an LD_LIBRARY_PATH the client set for the shim carries
'' through). --mcp-agent tells the IDE not to show interactive startup modals.
Sub LaunchIde()
	Dim As String exe = SelfDir() & "/ilwaco"
	Dim As String cmd = """" & exe & """ --mcp-agent >/dev/null 2>&1 &"
	c_system(StrPtr(cmd))
End Sub

'' PipeCall with auto-launch: if the IDE isn't reachable, start it (unless already running)
'' and poll the socket until it comes up or we give up. An incomplete reply is NOT retried
'' (retrying re-sends the request, only safe while False means the request never left).
Function PipeCallEnsuring(ByRef reqJson As String, ByRef respJson As String, ByRef complete As Boolean) As Boolean
	If PipeCall(reqJson, respJson, complete) Then Return True
	If IdeIsRunning() Then
		For i As Integer = 1 To 6                    '' ~3s: up but socket down (starting / toggle off)
			c_usleep(500000)
			If PipeCall(reqJson, respJson, complete) Then Return True
		Next
	Else
		LaunchIde()
		For i As Integer = 1 To 60                   '' ~30s for startup + splash
			c_usleep(500000)
			If PipeCall(reqJson, respJson, complete) Then Return True
		Next
	End If
	Return False
End Function

'' ---------------------------------------------------------------- tool table
'' MCP tool name == socket cmd name 1:1. Adding a tool = one row here + a Case on the IDE side.
'' Advertises the tools the IDE implements today: read-only + project + mutation + build/run/errors.
'' (the deferred designer_* tools arrive with their IDE-side handlers later.)
Type McpTool
	name As String
	description As String
	schema As String     '' inputSchema (JSON Schema), embedded verbatim
End Type

Dim Shared gTools(0 To 14) As McpTool

Sub InitTools()
	Dim As String noArgs = "{""type"":""object"",""properties"":{}}"
	Dim As String pathReq = "{""type"":""object"",""properties"":{""path"":{""type"":""string"",""description"":""Project-relative or absolute path inside the project folder.""}},""required"":[""path""]}"
	gTools(0).name = "get_status"
	gTools(0).description = "Health check and current IDE context: open project, main file, open editor tabs, and whether a build or program is running."
	gTools(0).schema = noArgs
	gTools(1).name = "list_files"
	gTools(1).description = "List the files in the open Ilwaco project (from its explorer tree), with the main file identified."
	gTools(1).schema = noArgs
	gTools(2).name = "read_file"
	gTools(2).description = "Read a file from the open project. The path is project-relative or an absolute path inside the project folder; paths outside the project are rejected. Also returns a ""version"" token you can pass to write_file as expected_version."
	gTools(2).schema = pathReq
	gTools(3).name = "get_active_file"
	gTools(3).description = "Get the path and full text of the currently focused editor tab, plus a ""version"" token for the content and whether the tab has unsaved changes. Pass the version back to set_active_file_content to make your edit conditional on nothing having changed."
	gTools(3).schema = noArgs
	gTools(4).name = "get_build_output"
	gTools(4).description = "Get the raw text of the IDE Output/messages pane from the last build or run."
	gTools(4).schema = noArgs
	gTools(5).name = "open_project"
	gTools(5).description = "Open an existing Ilwaco project by its .vfp path (switches the IDE to that project)."
	gTools(5).schema = "{""type"":""object"",""properties"":{""path"":{""type"":""string"",""description"":""Path to a .vfp project file.""}},""required"":[""path""]}"
	gTools(6).name = "write_file"
	gTools(6).description = "Create or overwrite a file in the open project. Optionally register it in the project and open it in an editor tab. Paths outside the project are rejected. Refused with ""dirty_buffer"" if the file is open in the editor with unsaved changes -- edit the buffer with set_active_file_content instead. Returns a ""version"" token."
	gTools(6).schema = "{""type"":""object"",""properties"":{""path"":{""type"":""string"",""description"":""Project-relative or absolute path inside the project folder.""},""content"":{""type"":""string""},""register"":{""type"":""boolean"",""description"":""Add the file to the project (default false).""},""open"":{""type"":""boolean"",""description"":""Open the file in an editor tab (default false).""},""expected_version"":{""type"":""string"",""description"":""Version token from a previous read_file. If given and the file has changed since, the write is refused.""}},""required"":[""path"",""content""]}"
	gTools(7).name = "add_file"
	gTools(7).description = "Add a new source file (module .bas or header .bi) to the open project, registered and opened by default. Forms are not supported here; create them in the designer."
	gTools(7).schema = "{""type"":""object"",""properties"":{""name"":{""type"":""string"",""description"":""File name, with or without extension.""},""kind"":{""type"":""string"",""enum"":[""module"",""header""],""description"":""module (.bas) or header (.bi). Default module.""},""register"":{""type"":""boolean""},""open"":{""type"":""boolean""}},""required"":[""name""]}"
	gTools(8).name = "set_active_file_content"
	gTools(8).description = "Replace the full text of the currently focused editor tab. This overwrites the WHOLE buffer, so pass expected_version (from get_active_file) to be refused with ""version_mismatch"" rather than silently discarding edits made since you read it."
	gTools(8).schema = "{""type"":""object"",""properties"":{""content"":{""type"":""string""},""expected_version"":{""type"":""string"",""description"":""Version token from a previous get_active_file. If given and the buffer has changed since, the edit is refused.""}},""required"":[""content""]}"
	gTools(9).name = "open_in_editor"
	gTools(9).description = "Open (or focus) an editor tab for a project file."
	gTools(9).schema = "{""type"":""object"",""properties"":{""path"":{""type"":""string"",""description"":""Project-relative or absolute path inside the project folder.""}},""required"":[""path""]}"
	gTools(10).name = "build"
	gTools(10).description = "Compile the open project (saving dirty tabs first) and wait for it to finish. Returns success plus error/warning counts and the diagnostics list."
	gTools(10).schema = noArgs
	gTools(11).name = "syntax_check"
	gTools(11).description = "Syntax-check the open project (compile with -c, no executable) and wait for it to finish. Returns success plus error/warning counts and the diagnostics list."
	gTools(11).schema = noArgs
	gTools(12).name = "run"
	gTools(12).description = "Build the open project and, if it succeeds, launch it in a terminal. Waits for the build, not for the program: it returns as soon as the program has been started, with the build's success plus error/warning counts and the diagnostics list. The program's own output appears in its terminal window, not in this reply."
	gTools(12).schema = noArgs
	gTools(13).name = "get_errors"
	gTools(13).description = "Get the structured diagnostics from the most recent build: a list of {severity, message, file, line} plus error/warning counts."
	gTools(13).schema = noArgs
	gTools(14).name = "create_project"
	gTools(14).description = "Create a new project from a template under the configured Projects folder and open it. The project is named after its folder."
	gTools(14).schema = "{""type"":""object"",""properties"":{""name"":{""type"":""string"",""description"":""Project name (also the folder name); no path or extension.""},""template"":{""type"":""string"",""enum"":[""Console Application"",""GTK Application"",""GUI Application"",""Dynamic Library"",""Static Library"",""Control Library""],""description"":""Default Console Application.""}},""required"":[""name""]}"
End Sub

Function ToolsListJson() As String
	Dim As String s = "["
	For i As Integer = 0 To UBound(gTools)
		If i > 0 Then s &= ","
		s &= "{""name"":""" & JsonEscape(gTools(i).name) & """,""description"":""" & _
			JsonEscape(gTools(i).description) & """,""inputSchema"":" & gTools(i).schema & "}"
	Next i
	Return s & "]"
End Function

'' ---------------------------------------------------------------- JSON-RPC

Function RpcIdJson(req As JsonValue Ptr) As String
	If req = 0 Then Return "null"
	Dim As JsonValue Ptr idv = req->Find("id")
	If idv = 0 Then Return "null"
	Return JsonSerialize(idv)
End Function

Sub SendResult(ByRef idJson As String, ByRef resultJson As String)
	WriteStdoutLine("{""jsonrpc"":""2.0"",""id"":" & idJson & ",""result"":" & resultJson & "}")
End Sub

Sub SendError(ByRef idJson As String, code As Integer, ByRef message As String)
	WriteStdoutLine("{""jsonrpc"":""2.0"",""id"":" & idJson & ",""error"":{""code"":" & Str(code) & _
		",""message"":""" & JsonEscape(message) & """}}")
End Sub

'' A tools/call result carrying text content (isError distinguishes a tool-level failure from a
'' protocol error, per the MCP spec).
Sub SendToolText(ByRef idJson As String, ByRef text As String, isError As Boolean)
	Dim As String r = "{""content"":[{""type"":""text"",""text"":""" & JsonEscape(text) & """}]"
	If isError Then r &= ",""isError"":true"
	r &= "}"
	SendResult(idJson, r)
End Sub

Sub HandleInitialize(req As JsonValue Ptr, ByRef idJson As String)
	Dim As String ver = MCP_DEFAULT_PROTOCOL
	Dim As JsonValue Ptr params = req->Find("params")
	If params Then
		Dim As String rv = params->GetStr("protocolVersion")
		If rv <> "" Then ver = rv
	End If
	Dim As String r = "{""protocolVersion"":""" & JsonEscape(ver) & """,""capabilities"":{""tools"":{}}," & _
		"""serverInfo"":{""name"":""" & MCP_SERVER_NAME & """,""version"":""" & MCP_SERVER_VERSION & """}}"
	SendResult(idJson, r)
End Sub

Sub HandleToolsCall(req As JsonValue Ptr, ByRef idJson As String)
	Dim As JsonValue Ptr params = req->Find("params")
	If params = 0 Then SendError(idJson, -32602, "tools/call requires params.") : Exit Sub
	Dim As String toolName = params->GetStr("name")
	If toolName = "" Then SendError(idJson, -32602, "tools/call requires a tool name.") : Exit Sub

	'' Serialize the arguments object (default {}) straight through to the socket.
	Dim As String argsJson = "{}"
	Dim As JsonValue Ptr argsV = params->Find("arguments")
	If argsV Then argsJson = JsonSerialize(argsV)

	gPipeReqId += 1
	Dim As String pipeReq = "{""id"":" & Str(gPipeReqId) & ",""cmd"":""" & JsonEscape(toolName) & """,""args"":" & argsJson & "}"

	Dim As String pipeResp
	Dim As Boolean bComplete
	If Not PipeCallEnsuring(pipeReq, pipeResp, bComplete) Then
		SendToolText(idJson, "Ilwaco IDE is not reachable. If it just launched, make sure " & _
			"Tools > Options > Allow AI agent control is ticked, then retry.", True)
		Exit Sub
	End If
	If Not bComplete Then
		SendToolText(idJson, "Ilwaco IDE accepted this request but closed the connection without a " & _
			"complete reply (" & Str(Len(pipeResp)) & " bytes). The command MAY ALREADY HAVE RUN -- " & _
			"check the IDE before retrying, because retrying is not safe for anything that writes files.", True)
		Exit Sub
	End If

	Dim As JsonValue Ptr resp = JsonParse(pipeResp)
	If resp = 0 Then SendToolText(idJson, "Malformed response from Ilwaco IDE.", True) : Exit Sub
	If resp->GetBool("ok") Then
		Dim As JsonValue Ptr r = resp->Find("result")
		Dim As String text = "{}"
		If r Then text = JsonSerialize(r)
		SendToolText(idJson, text, False)
	Else
		Dim As JsonValue Ptr e = resp->Find("error")
		Dim As String code, message
		If e Then code = e->GetStr("code") : message = e->GetStr("message")
		If message = "" Then message = "Command failed."
		SendToolText(idJson, "[" & code & "] " & message, True)
	End If
	Delete resp
End Sub

Sub HandleMessage(ByRef reqLn As String)
	'' Tolerate a leading UTF-8 BOM some writers prepend to the first line.
	Dim As String ln = reqLn
	If Len(ln) >= 3 AndAlso ln[0] = &HEF AndAlso ln[1] = &HBB AndAlso ln[2] = &HBF Then ln = Mid(ln, 4)
	Dim As JsonValue Ptr req = JsonParse(ln)
	If req = 0 OrElse req->Kind <> jkObject Then
		If req Then Delete req
		SendError("null", -32700, "Parse error.")
		Exit Sub
	End If
	Dim As String method = req->GetStr("method")
	Dim As Boolean hasId = (req->Find("id") <> 0)
	Dim As String idJson = RpcIdJson(req)
	'' Notifications (no id) never get a response.
	If Not hasId Then Delete req : Exit Sub
	Select Case method
	Case "initialize"  : HandleInitialize(req, idJson)
	Case "tools/list"  : SendResult(idJson, "{""tools"":" & ToolsListJson() & "}")
	Case "tools/call"  : HandleToolsCall(req, idJson)
	Case "ping"        : SendResult(idJson, "{}")
	Case Else          : SendError(idJson, -32601, "Method not found: " & method)
	End Select
	Delete req
End Sub

'' ---------------------------------------------------------------- entry

InitTools()
LogErr("ilwaco-mcp " & MCP_SERVER_VERSION & " started; socket " & AgentSocketPath())

Dim As String reqLn
Do While ReadStdinLine(reqLn)
	If Len(Trim(reqLn)) = 0 Then Continue Do
	HandleMessage(reqLn)
Loop
LogErr("stdin closed; exiting")
