' courtesy https://www.freebasic.net/forum/viewtopic.php?t=4199&hilit=Simple+Web+Server
' Simple Web Server, (c) Anselme Dewavrin 2006 - dewavrin@yahoo.com
' Feel free to use it, provided you mention my name.
' based on the example provided with freebasic tweaked by thrive4 march 2024.
' Improved by Xusinboy Bekchanov, 2024.

#include once "HTTPServer.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function HTTPServer.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "address": Return Cast(Any Ptr, StrPtr(This.Address))
			Case "homedir": Return Cast(Any Ptr, StrPtr(This.HomeDir))
			Case "port": Return Cast(Any Ptr, @This.Port)
			Case "onreceive": Return Cast(Any Ptr, This.OnReceive)
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function HTTPServer.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "address": This.Address = *Cast(ZString Ptr, Value)
			Case "homedir": This.HomeDir = *Cast(ZString Ptr, Value)
			Case "port": This.Port = QInteger(Value)
			Case "onreceive": This.OnReceive = Value
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	' multithreaded socket handling
	Private Sub HTTPServer.Del(ByVal client As CLIENT Ptr)
	End Sub
	
	Private Function HTTPServer.Quit() As Integer
		Dim client As CLIENT Ptr
		isrunning = False
		
			Function = 0
	End Function
	
	' thread waiting for data to arrive, parsing HTTP GET requests and sending responses
	Private Sub HTTPServer.Receive(ByVal client As CLIENT Ptr)
		
		Dim PacketBuffer(BuffSize) As Byte
		Dim As Integer  ReceivedLen = 0
		Dim As Byte Ptr ReceivedBuffer = 0
		Dim As String   stNL   = Chr(13) & Chr(10)
		Dim As String   stNLNL = stNL & stNL
		
		Dim FileBuffer() As Byte 'fix for fb0.16beta, thx v1ctor
		Dim SendBuffer() As Byte 'fix for fb0.16beta, thx v1ctor
		Dim FileHandle As UByte
		
		
		Cast(HTTPServer Ptr, client->server)->Del(client)
	End Sub
	
	
	Private Sub HTTPServer.Accept(server As HTTPServer Ptr)
		
		server->isrunning = False
	End Sub
	
	
	Private Function HTTPServer.Run() As Integer
		Function = True
	End Function
	
	Constructor HTTPServer
		WLet(FClassName, "HTTPServer")
	End Constructor
	
	Destructor HTTPServer
		If isrunning Then
			Quit
		End If
	End Destructor
End Namespace
