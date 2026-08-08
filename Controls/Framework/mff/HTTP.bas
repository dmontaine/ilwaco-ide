'
' Ilwaco IDE Modifications
' copyright 2026 Donald Montaine
'
' This program is free software; you can redistribute it and/or modify
' it under the terms of the GNU Lesser General Public License as published by
' the Free Software Foundation; either version 3, or (at your option)
' any later version.
'
' This program is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU Lesser General Public License for more details.
'
' You should have received a copy of the GNU Lesser General Public License
' along with this program; if not, write to the Free Software Foundation,
' Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#include once "HTTP.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function HTTPConnection.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "host": Return Cast(Any Ptr, StrPtr(This.Host))
			Case "port": Return Cast(Any Ptr, @This.Port)
			Case "timeout" : Return Cast(Any Ptr, @This.Timeout)
			Case "abort" : Return @FAbort
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function HTTPConnection.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "host": This.Host = *Cast(ZString Ptr, Value)
			Case "port": This.Port = QInteger(Value)
			Case "timeout" : This.Timeout = QInteger(Value)
			Case "abort" : This.Abort = QBoolean(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	Private Property HTTPConnection.Abort As Boolean
		Return FAbort
	End Property
	
	Private Property HTTPConnection.Abort(Value As Boolean)
		FAbort = Value
	End Property
	
	Private Sub HTTPConnection.CallMethod(HTTPMethod As String, ByRef Request As HTTPRequest, ByRef Responce As HTTPResponce)
		FAbort = False
			Dim out As GOutputStream Ptr
			Dim inp As GInputStream Ptr
			Dim client As GSocketClient Ptr = g_socket_client_new()
			g_socket_client_set_family(client, G_SOCKET_FAMILY_IPV4)
			Dim As GError Ptr error_ = NULL
			Dim socket As GSocketConnection Ptr = g_socket_client_connect_to_host(client, Host, Port, 0, @error_)
			If socket = 0 Then
				Print "Error: " & *error_->message
				g_error_free(error_)
				Return
			End If
			Dim tls_conn As GIOStream Ptr
			If Port = 443 Then
				tls_conn = g_tls_client_connection_new(Cast(GIOStream Ptr, socket), 0, @error_)
				If tls_conn = 0 Then
					Print "Error: " & *error_->message
					g_error_free(error_)
					Return
				End If
				g_tls_client_connection_set_server_identity(G_TLS_CLIENT_CONNECTION(tls_conn), G_SOCKET_CONNECTABLE(g_network_address_new(Host, Port)))
				out = g_io_stream_get_output_stream(tls_conn)
				inp = g_io_stream_get_input_stream(tls_conn)
			Else
				out = g_io_stream_get_output_stream(G_IO_STREAM(socket))
				inp = g_io_stream_get_input_stream(G_IO_STREAM(socket))
			End If
			
			Dim body As String = Request.Body
			Dim strrequest As String
			strrequest = UCase(HTTPMethod) & " /" & Request.ResourceAddress & " HTTP/1.1" & Chr(13) & Chr(10)
			strrequest += "Host: " & Host & Chr(13) & Chr(10)
			strrequest += Request.Headers
			strrequest += "Content-Length: " & Str(Len(body)) & Chr(13) & Chr(10)
			strrequest += "Connection: close" & Chr(13) & Chr(10) & Chr(13) & Chr(10)
			strrequest += body
			
			Dim bytes_written As Long = g_output_stream_write(out, StrPtr(strrequest), Len(strrequest), 0, 0)
			
			Dim buffer As ZString * 1024
			Dim bytes_read As Long
			Do
				bytes_read = g_input_stream_read(inp, @buffer, 1024, 0, 0)
				If bytes_read > 0 Then
					Responce.Body &= bytes_read
					If OnReceive Then OnReceive(*Designer, This, Request, buffer)
				End If
			Loop Until bytes_read <= 0
			
			g_object_unref(tls_conn)
			g_object_unref(socket)
			g_object_unref(client)
	End Sub
	
	Constructor HTTPConnection
		WLet(FClassName, "HTTPConnection")
	End Constructor
	
	Destructor HTTPConnection
		
	End Destructor
End Namespace
