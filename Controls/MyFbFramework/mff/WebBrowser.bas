'################################################################################
'#  WebBrowser.bas                                                              #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2018-2023)                                     #
'################################################################################

#include once "WebBrowser.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function WebBrowser.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function WebBrowser.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "tabindex": TabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property WebBrowser.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property WebBrowser.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property WebBrowser.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property WebBrowser.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Sub WebBrowser.Navigate(ByVal URL As WString Ptr)
			webkit_web_view_load_uri(Cast(Any Ptr, widget), ToUtf8(*URL))
	End Sub
	
	Private Sub WebBrowser.GoForward()
			If webkit_web_view_can_go_forward(widget) Then
				webkit_web_view_go_forward(widget)
			End If
	End Sub
	
	Private Sub WebBrowser.GoBack()
			If webkit_web_view_can_go_forward(widget) Then
				webkit_web_view_go_forward(widget)
			End If
	End Sub
	
	Private Sub WebBrowser.Refresh()
			webkit_web_view_reload_bypass_cache(widget)
	End Sub
	
	Private Function WebBrowser.GetURL() As UString
		Dim As UString sRet
		Dim As WString Ptr buf = sRet.vptr
			sRet = *webkit_web_view_get_uri(widget)
			Return *buf
	End Function
	
	Private Function WebBrowser.State() As Integer
		Dim iState As Integer
			'#ifdef __USE_GTK3__
			'	Return webkit_web_view_is_loading(widget)
			'#else
			If webkit_web_view_get_load_status(widget) = 2 Then
				Return False
			Else
				Return True
			End If
			'#endif
		Return iState
	End Function
	
	Private Sub WebBrowser.Stop()
			webkit_web_view_stop_loading(widget)
	End Sub
	
	Private Function WebBrowser.GetBody(ByVal flag As Long = 0) As UString
				Return ""
	End Function
	
	Private Function WebBrowser.ExecuteScript(ByRef JavaScript As WString, bWait As Boolean = False) ByRef As WString
		If Trim(JavaScript) = "" Then Return ""
		WLet(ScriptResult,"")
		#ifdef __USE_WEBVIEW2__
			If webviewWindow Then
				WDeAllocate(ScriptResult)
				ScriptResult = 0
				webviewWindow->lpVtbl->ExecuteScript(webviewWindow, @JavaScript, ExecuteScriptCompletedHandler)
				If bWait Then
					Do While ScriptResult = 0
						App.DoEvents
					Loop
				End If
			End If
		#endif
		Return *ScriptResult
	End Function
	
	Private Sub WebBrowser.SetBody(ByRef tText As WString, ByVal flag As Long = 0)
			'#ifdef __USE_GTK3__
			'	webkit_web_view_load_html(Cast(Any Ptr, widget), ToUTF8(tText))
			'#else
			webkit_web_view_load_html_string(Cast(Any Ptr, widget), ToUtf8(tText))
			'#endif
	End Sub
	
	
	Private Sub WebBrowser.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator WebBrowser.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
	Private Constructor WebBrowser
		With This
			WLet(FClassName, "WebBrowser")
			FText = "about:blank"
			FTabIndex          = -1
			FTabStop           = True
				widget = webkit_web_view_new()
				webkit_web_view_load_uri(Cast(Any Ptr, widget), Cast(gchar Ptr, @"about:blank"))
			.Width        = 175
			.Height       = 21
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor WebBrowser
	End Destructor
End Namespace
