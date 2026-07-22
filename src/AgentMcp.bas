'###############################################################################
'#  AgentMcp.bas -- ilwaco-mcp                                                  #
'#                                                                             #
'#  The MCP sidecar. A FreeBASIC console app that speaks MCP / JSON-RPC 2.0    #
'#  over stdio to an MCP client (Claude Code, Claude Desktop, ...) and         #
'#  forwards each tools/call to the running Ilwaco IDE over a Unix-domain      #
'#  socket.  Ported from Astoria IDE's astoria-mcp.exe.                        #
'#                                                                             #
'#  Build: fbc AgentMcp.bas -x ../ilwaco-mcp -i . -i ../Controls/MyFbFramework #
'###############################################################################

# include once "crt/unistd.bi"
# include once "crt/sys/socket.bi"
# include once "crt/sys/linux/socket.bi"
# include once "crt/stdio.bi"
# include once "crt/string.bi"

'' JsonLite lives next to this file in src/
# include once "JsonLite.bi"

Const AGENT_SOCK_PATH = "/tmp/ilwaco-agent.sock"
Const MCP_SERVER_NAME = "ilwaco-ide"
Const MCP_SERVER_VERSION = "0.1.0"
Const MCP_DEFAULT_PROTOCOL = "2024-11-05"

'' Unix-domain socket address (not in bundled fbc headers)
Type sockaddr_un Field = 1
	sun_family As UShort
	sun_path As ZString * 108
End Type

Dim Shared gPipeReqId As LongInt     '' monotonic id for pipe requests
Dim Shared gClientName As String     '' MCP client identity from initialize

'' ---------------------------------------------------------------- client mapping

Function ClientToAiTool(ByRef clientName As String) As String
	Dim As String c = LCase(clientName)
	If InStr(c, "opencode") > 0 Then Return "OpenCode"
	If InStr(c, "cursor") > 0 Then Return "Cursor"
	If InStr(c, "codex") > 0 OrElse InStr(c, "chatgpt") > 0 OrElse InStr(c, "openai") > 0 Then Return "ChatGPT (Codex)"
	If InStr(c, "kun") > 0 OrElse InStr(c, "deepseek") > 0 Then Return "Kun (Deepseek)"
	If InStr(c, "claude") > 0 Then Return "Claude Code"
	Return "Claude Code"
End Function

'' ---------------------------------------------------------------- pipe client

Function PipeCall(ByRef reqJson As String, ByRef respJson As String) As Boolean
	Dim As Integer fd = socket_(AF_UNIX, SOCK_STREAM, 0)
	If fd < 0 Then Return False

	Dim As sockaddr_un addr
	addr.sun_family = AF_UNIX
	Dim As ZString * 108 pathCopy = AGENT_SOCK_PATH
	memcpy(@addr.sun_path, @pathCopy, Len(AGENT_SOCK_PATH) + 1)

	If connect(fd, Cast(sockaddr Ptr, @addr), SizeOf(sockaddr_un)) < 0 Then
		close(fd)
		Return False
	End If

	'' Send request
	Dim As String wbuf = reqJson & Chr(10)
	write_(fd, StrPtr(wbuf), Len(wbuf))

	'' Read response
	respJson = ""
	Dim As UByte buf(0 To 8191)
	Do
		Dim As Integer got = read_(fd, @buf(0), 8192)
		If got <= 0 Then Exit Do
		Dim As String chunk = String(got, 0)
		For i As Integer = 0 To got - 1
			chunk[i] = buf(i)
		Next i
		respJson &= chunk
		If InStr(respJson, Chr(10)) > 0 Then Exit Do
	Loop
	close_(fd)

	Dim As Integer nl = InStr(respJson, Chr(10))
	If nl > 0 Then respJson = Left(respJson, nl - 1)
	Return True
End Function

Function PipeCallEnsuring(ByRef reqJson As String, ByRef respJson As String) As Boolean
	If PipeCall(reqJson, respJson) Then Return True
	'' v1: no auto-launch on Linux. Just retry a few times.
	For i As Integer = 1 To 6
		Sleep 500, 1
		If PipeCall(reqJson, respJson) Then Return True
	Next
	Return False
End Function

'' ---------------------------------------------------------------- tool table

Type McpTool
	name As String
	description As String
	schema As String
End Type

Dim Shared gTools(0 To 14) As McpTool

Sub InitTools()
	Dim As String noArgs = "{""type"":""object"",""properties"":{}}"
	Dim As String pathReq = "{""type"":""object"",""properties"":{""path"":{""type"":""string"",""description"":""Project-relative or absolute path inside the project folder.""}},""required"":[""path""]}"
	gTools(0).name = "get_status"
	gTools(0).description = "Health check and current IDE context: open project, main file, open editor tabs, and whether a build or program is running."
	gTools(0).schema = noArgs
	gTools(1).name = "list_files"
	gTools(1).description = "List the files in the open Ilwaco project (read from its .vfp manifest), with the main file identified."
	gTools(1).schema = noArgs
	gTools(2).name = "read_file"
	gTools(2).description = "Read a file from the open project. The path is project-relative or an absolute path inside the project folder; paths outside the project are rejected."
	gTools(2).schema = pathReq
	gTools(3).name = "get_active_file"
	gTools(3).description = "Get the path and full text of the currently focused editor tab."
	gTools(3).schema = noArgs
	gTools(4).name = "get_build_output"
	gTools(4).description = "Get the raw text of the IDE Output/messages pane from the last build or run."
	gTools(4).schema = noArgs
	gTools(5).name = "write_file"
	gTools(5).description = "Create or overwrite a file in the open project. Optionally register it in the project (.vfp) and open it in an editor tab."
	gTools(5).schema = "{""type"":""object"",""properties"":{""path"":{""type"":""string"",""description"":""Project-relative or absolute path inside the project folder.""},""content"":{""type"":""string""},""register"":{""type"":""boolean"",""description"":""Add the file to the project manifest (default false).""},""open"":{""type"":""boolean"",""description"":""Open the file in an editor tab (default false).""}},""required"":[""path"",""content""]}"
	gTools(6).name = "add_file"
	gTools(6).description = "Add a new source file to the open project from the matching template."
	gTools(6).schema = "{""type"":""object"",""properties"":{""name"":{""type"":""string"",""description"":""File name, with or without extension.""},""kind"":{""type"":""string"",""enum"":[""module"",""header"",""form""],""description"":""module (.bas), header (.bi), or form (.frm). Default module.""},""register"":{""type"":""boolean""},""open"":{""type"":""boolean""}},""required"":[""name""]}"
	gTools(7).name = "set_active_file_content"
	gTools(7).description = "Replace the full text of the currently focused editor tab."
	gTools(7).schema = "{""type"":""object"",""properties"":{""content"":{""type"":""string""}},""required"":[""content""]}"
	gTools(8).name = "open_in_editor"
	gTools(8).description = "Open (or focus) an editor tab for a project file."
	gTools(8).schema = pathReq
	gTools(9).name = "build"
	gTools(9).description = "Compile the open project. Blocks until the build finishes; returns success, exit code, raw build output, and structured errors[]."
	gTools(9).schema = "{""type"":""object"",""properties"":{""all"":{""type"":""boolean"",""description"":""Build all projects (default false).""}}}"
	gTools(10).name = "syntax_check"
	gTools(10).description = "Parse-only syntax check of the open project (no executable produced). Returns success and structured errors[]."
	gTools(10).schema = noArgs
	gTools(11).name = "run"
	gTools(11).description = "Build the open project and run it. Blocks until the program exits for console targets."
	gTools(11).schema = noArgs
	gTools(12).name = "get_errors"
	gTools(12).description = "Structured errors[] (file, line, severity, message) parsed from the last build."
	gTools(12).schema = noArgs
	gTools(13).name = "create_project"
	gTools(13).description = "Create a new project from a template under the configured Projects folder and open it."
	gTools(13).schema = !"{\"type\":\"object\",\"properties\":{\"name\":{\"type\":\"string\"},\"template\":{\"type\":\"string\"},\"ai_tool\":{\"type\":\"string\"}},\"required\":[\"name\"]}"
	gTools(14).name = "open_project"
	gTools(14).description = "Open an existing project by its .vfp path (switches the IDE to that project)."
	gTools(14).schema = "{""type"":""object"",""properties"":{""path"":{""type"":""string"",""description"":""Path to a .vfp project file.""}},""required"":[""path""]}"
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

Function IsKnownTool(ByRef nm As String) As Boolean
	For i As Integer = 0 To UBound(gTools)
		If gTools(i).name = nm Then Return True
	Next i
	Return False
End Function

'' ---------------------------------------------------------------- JSON-RPC

Function RpcIdJson(req As JsonValue Ptr) As String
	If req = 0 Then Return "null"
	Dim As JsonValue Ptr idv = req->Find("id")
	If idv = 0 Then Return "null"
	Return JsonSerialize(idv)
End Function

Sub SendResult(ByRef idJson As String, ByRef resultJson As String)
	Print "{""jsonrpc"":""2.0"",""id"":" & idJson & ",""result"":" & resultJson & "}"
End Sub

Sub SendError(ByRef idJson As String, code As Integer, ByRef message As String)
	Print "{""jsonrpc"":""2.0"",""id"":" & idJson & ",""error"":{""code"":" & Str(code) & _
		",""message"":""" & JsonEscape(message) & """}}"
End Sub

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
		Dim As JsonValue Ptr ci = params->Find("clientInfo")
		If ci Then gClientName = ci->GetStr("name")
	End If
	Dim As String r = "{""protocolVersion"":""" & JsonEscape(ver) & """,""capabilities"":{""tools"":{}}," & _
		"""serverInfo"":{""name"":""" & MCP_SERVER_NAME & """,""version"":""" & MCP_SERVER_VERSION & """}}"
	SendResult(idJson, r)
End Sub

Sub HandleToolsCall(req As JsonValue Ptr, ByRef idJson As String)
	Dim As JsonValue Ptr params = req->Find("params")
	If params = 0 Then
		SendError(idJson, -32602, "tools/call requires params.")
		Exit Sub
	End If
	Dim As String toolName = params->GetStr("name")
	If toolName = "" Then
		SendError(idJson, -32602, "tools/call requires a tool name.")
		Exit Sub
	End If

	Dim As String argsJson = "{}"
	Dim As JsonValue Ptr argsV = params->Find("arguments")
	If toolName = "create_project" Then
		Dim As Boolean ownArgs = False
		If argsV = 0 Then argsV = JsonNewObject() : ownArgs = True
		If argsV->Find("ai_tool") = 0 Then argsV->SetMember("ai_tool", JsonNewString(ClientToAiTool(gClientName)))
		argsJson = JsonSerialize(argsV)
		If ownArgs Then Delete argsV
	ElseIf argsV Then
		argsJson = JsonSerialize(argsV)
	End If

	gPipeReqId += 1
	Dim As String pipeReq = "{""id"":" & Str(gPipeReqId) & ",""cmd"":""" & JsonEscape(toolName) & """,""args"":" & argsJson & "}"

	Dim As String pipeResp
	If Not PipeCallEnsuring(pipeReq, pipeResp) Then
		SendToolText(idJson, "Ilwaco IDE is not reachable. Make sure the IDE is running and AI agent control is enabled.", True)
		Exit Sub
	End If

	Dim As JsonValue Ptr resp = JsonParse(pipeResp)
	If resp = 0 Then
		SendToolText(idJson, "Malformed response from Ilwaco IDE.", True)
		Exit Sub
	End If
	If resp->GetBool("ok") Then
		Dim As JsonValue Ptr r = resp->Find("result")
		Dim As String text = "{}"
		If r Then text = JsonSerialize(r)
		SendToolText(idJson, text, False)
	Else
		Dim As JsonValue Ptr e = resp->Find("error")
		Dim As String code, message
		If e Then
			code = e->GetStr("code")
			message = e->GetStr("message")
		End If
		If message = "" Then message = "Command failed."
		SendToolText(idJson, "[" & code & "] " & message, True)
	End If
	Delete resp
End Sub

Sub HandleMessage(ByRef reqLn As String)
	'' Tolerate a leading UTF-8 BOM
	If Len(reqLn) >= 3 AndAlso reqLn[0] = &HEF AndAlso reqLn[1] = &HBB AndAlso reqLn[2] = &HBF Then reqLn = Mid(reqLn, 4)
	Dim As JsonValue Ptr req = JsonParse(reqLn)
	If req = 0 OrElse req->Kind <> jkObject Then
		If req Then Delete req
		SendError("null", -32700, "Parse error.")
		Exit Sub
	End If

	Dim As String method = req->GetStr("method")
	Dim As Boolean hasId = (req->Find("id") <> 0)
	Dim As String idJson = RpcIdJson(req)

	If Not hasId Then
		Delete req
		Exit Sub   '' notifications: no response
	End If

	Select Case method
	Case "initialize"
		HandleInitialize(req, idJson)
	Case "tools/list"
		SendResult(idJson, "{""tools"":" & ToolsListJson() & "}")
	Case "tools/call"
		HandleToolsCall(req, idJson)
	Case "ping"
		SendResult(idJson, "{}")
	Case Else
		SendError(idJson, -32601, "Method not found: " & method)
	End Select
	Delete req
End Sub

'' ---------------------------------------------------------------- entry

InitTools()

Dim As ZString * 8192 buf
Do While fgets(@buf, 8192, stdin) <> NULL
	Dim As String reqLn = buf
	'' Trim trailing newline
	If Len(reqLn) > 0 AndAlso reqLn[Len(reqLn) - 1] = 10 Then reqLn = Left(reqLn, Len(reqLn) - 1)
	If Len(reqLn) > 0 AndAlso reqLn[Len(reqLn) - 1] = 13 Then reqLn = Left(reqLn, Len(reqLn) - 1)
	If Len(Trim(reqLn)) = 0 Then Continue Do
	HandleMessage(reqLn)
Loop
