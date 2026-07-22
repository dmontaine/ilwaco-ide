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
		#ifdef __USE_GTK__
			webkit_web_view_load_uri(Cast(Any Ptr, widget), ToUtf8(*URL))
		#else
			#ifdef __USE_WEBVIEW2__
				If webviewWindow Then
					webviewWindow->lpVtbl->Navigate(webviewWindow, URL)
				Else
					Print "WebView2 window has not been created. Install the WebView2 runtime."
				End If
			#else
				Dim vUrl As VARIANT: vUrl.vt = VT_BSTR : vUrl.bstrVal = SysAllocString(URL)
				g_IWebBrowser->Navigate2(Cast(IWebBrowser2 Ptr, pIWebBrowser), @vUrl, NULL, NULL, NULL, NULL)
				VariantClear(@vUrl)
			#endif
		#endif
	End Sub
	
	Private Sub WebBrowser.GoForward()
		#ifdef __USE_GTK__
			If webkit_web_view_can_go_forward(widget) Then
				webkit_web_view_go_forward(widget)
			End If
		#else
			#ifdef __USE_WEBVIEW2__
				If webviewWindow Then
					webviewWindow->lpVtbl->GoForward(webviewWindow)
				Else
					Print "WebView2 window has not been created. Install the WebView2 runtime."
				End If
			#else
				g_IWebBrowser->GoForward(Cast(IWebBrowser2 Ptr, pIWebBrowser))
			#endif
		#endif
	End Sub
	
	Private Sub WebBrowser.GoBack()
		#ifdef __USE_GTK__
			If webkit_web_view_can_go_forward(widget) Then
				webkit_web_view_go_forward(widget)
			End If
		#else
			#ifdef __USE_WEBVIEW2__
				If webviewWindow Then
					webviewWindow->lpVtbl->GoBack(webviewWindow)
				Else
					Print "WebView2 window has not been created. Install the WebView2 runtime."
				End If
			#else
				g_IWebBrowser->GoBack(Cast(IWebBrowser2 Ptr, pIWebBrowser))
			#endif
		#endif
	End Sub
	
	Private Sub WebBrowser.Refresh()
		#ifdef __USE_GTK__
			webkit_web_view_reload_bypass_cache(widget)
		#else
			#ifdef __USE_WEBVIEW2__
				If webviewWindow Then
					webviewWindow->lpVtbl->Reload(webviewWindow)
				Else
					Print "WebView2 window has not been created. Install the WebView2 runtime."
				End If
			#else
				g_IWebBrowser->Refresh(Cast(IWebBrowser2 Ptr, pIWebBrowser))
			#endif
		#endif
	End Sub
	
	Private Function WebBrowser.GetURL() As UString
		Dim As UString sRet
		Dim As WString Ptr buf = sRet.vptr
		#ifdef __USE_GTK__
			sRet = *webkit_web_view_get_uri(widget)
			Return *buf
		#else
			#ifdef __USE_WEBVIEW2__
				If webviewWindow Then
					Dim tText As WString Ptr
					webviewWindow->lpVtbl->get_Source(webviewWindow, @tText)
					Function = *tText
					'_Deallocate(tText)
				Else
					Print "WebView2 window has not been created. Install the WebView2 runtime."
					Function = ""
				End If
			#else
				g_IWebBrowser->get_LocationURL(Cast(IWebBrowser2 Ptr, pIWebBrowser), @buf)
				Return *buf
			#endif
		#endif
	End Function
	
	Private Function WebBrowser.State() As Integer
		Dim iState As Integer
		#ifdef __USE_GTK__
			'#ifdef __USE_GTK3__
			'	Return webkit_web_view_is_loading(widget)
			'#else
			If webkit_web_view_get_load_status(widget) = 2 Then
				Return False
			Else
				Return True
			End If
			'#endif
		#else
			#ifdef __USE_WEBVIEW2__
				'webviewWindow->lpVtbl->Reload(webviewWindow)
			#else
				g_IWebBrowser->get_Busy(Cast(IWebBrowser2 Ptr, pIWebBrowser), Cast(VARIANT_BOOL Ptr, @iState))
			#endif
		#endif
		Return iState
	End Function
	
	Private Sub WebBrowser.Stop()
		#ifdef __USE_GTK__
			webkit_web_view_stop_loading(widget)
		#else
			#ifdef __USE_WEBVIEW2__
				If webviewWindow Then
					webviewWindow->lpVtbl->Stop(webviewWindow)
				Else
					Print "WebView2 window has not been created. Install the WebView2 runtime."
				End If
			#else
				g_IWebBrowser->Stop(Cast(IWebBrowser2 Ptr, pIWebBrowser))
			#endif
		#endif
	End Sub
	
	Private Function WebBrowser.GetBody(ByVal flag As Long = 0) As UString
		#ifdef __USE_GTK__
				Return ""
		#else
			#ifdef __USE_WEBVIEW2__
				If webviewWindow Then
					Dim pJavaScript As WString Ptr
					Select Case flag
					Case 0
						WLet(pJavaScript, "document.body.innerHTML")
					Case 1
						WLet(pJavaScript, "document.body.outerHTML")
					Case 2
						WLet(pJavaScript, "document.body.innerText")
					Case 3
						WLet(pJavaScript, "document.body.outerText")
					End Select
					WDeAllocate(ScriptResult)
					ScriptResult = 0
					webviewWindow->lpVtbl->ExecuteScript(webviewWindow, pJavaScript, ExecuteScriptCompletedHandler)
					Do While ScriptResult = 0
						App.DoEvents
					Loop
					_Deallocate(pJavaScript)
					Return *ScriptResult
				Else
					Print "WebView2 window has not been created. Install the WebView2 runtime."
				End If
			#else
				Dim tText As WString Ptr
				Dim As IHTMLDocument2 Ptr htmldoc2
				Dim As IDispatch Ptr doc
				g_IWebBrowser->get_Document(Cast(IWebBrowser2 Ptr, pIWebBrowser), @doc)
				Function = ""
				If doc > 0 AndAlso (doc->lpVtbl->QueryInterface(doc, @IID_IHTMLDocument2, Cast(PVOID Ptr, @htmldoc2)) = S_OK) Then
					If htmldoc2 Then
						Dim As IHTMLElement Ptr BODY
						htmldoc2->lpVtbl->get_body(htmldoc2, @BODY)
						If BODY > 0 Then
							Select Case flag
							Case 0
								BODY->lpVtbl->get_innerHTML(BODY, @tText)
							Case 1
								BODY->lpVtbl->get_outerHTML(BODY, @tText)
							Case 2
								BODY->lpVtbl->get_innerText(BODY, @tText)
							Case 3
								BODY->lpVtbl->get_outerText(BODY, @tText)
							End Select
							Function = *tText
							BODY->lpVtbl->Release(BODY)
						End If
						htmldoc2->lpVtbl->Release(htmldoc2)
					End If
					doc->lpVtbl->Release(doc)
				End If
				_Deallocate(tText)
			#endif
		#endif
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
		#ifdef __USE_GTK__
			'#ifdef __USE_GTK3__
			'	webkit_web_view_load_html(Cast(Any Ptr, widget), ToUTF8(tText))
			'#else
			webkit_web_view_load_html_string(Cast(Any Ptr, widget), ToUtf8(tText))
			'#endif
		#else
			#ifdef __USE_WEBVIEW2__
				If webviewWindow Then
					webviewWindow->lpVtbl->NavigateToString(webviewWindow, @tText)
				Else
					Print "WebView2 window has not been created. Install the WebView2 runtime."
				End If
			#else
				Dim As IHTMLDocument2 Ptr htmldoc2
				Dim As IDispatch Ptr doc
				g_IWebBrowser->get_Document(Cast(IWebBrowser2 Ptr, pIWebBrowser), @doc)
				If doc > 0 AndAlso (doc->lpVtbl->QueryInterface(doc, @IID_IHTMLDocument2, Cast(PVOID Ptr, @htmldoc2)) = S_OK) Then
					If htmldoc2 Then
						Dim As IHTMLElement Ptr BODY
						htmldoc2->lpVtbl->get_body(htmldoc2, @BODY)
						If BODY > 0 Then
							Select Case flag
							Case 0
								BODY->lpVtbl->put_innerHTML(BODY, @tText)
							Case 1
								BODY->lpVtbl->put_outerHTML(BODY, @tText)
							Case 2
								BODY->lpVtbl->put_innerText(BODY, @tText)
							Case 3
								BODY->lpVtbl->put_outerText(BODY, @tText)
							End Select
							BODY->lpVtbl->Release(BODY)
						End If
						htmldoc2->lpVtbl->Release(htmldoc2)
					End If
					doc->lpVtbl->Release(doc)
				End If
			#endif
		#endif
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
			#ifdef __USE_GTK__
				widget = webkit_web_view_new()
				webkit_web_view_load_uri(Cast(Any Ptr, widget), Cast(gchar Ptr, @"about:blank"))
			#else
				#ifdef __USE_WEBVIEW2__
					.RegisterClass "WebBrowser"
					.Style        = WS_CHILD
				#else
					hWebBrowser = LoadLibrary("atl.dll")
					If hWebBrowser Then
						Dim AtlAxWinInit As Function As Boolean
						AtlAxWinInit = Cast(Any Ptr, GetProcAddress(hWebBrowser, "AtlAxWinInit"))
						If AtlAxWinInit Then
							AtlAxWinInit()
							.RegisterClass "WebBrowser", "AtlAxWin"
						End If
						WLet(.FClassAncestor, "AtlAxWin")
					End If
					.Style        = WS_CHILD Or WS_VSCROLL Or WS_HSCROLL
				#endif
				.ExStyle      = WS_EX_CLIENTEDGE
				.ChildProc    = @WndProc
				.OnHandleIsAllocated = @HandleIsAllocated
			#endif
			.Width        = 175
			.Height       = 21
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor WebBrowser
	End Destructor
End Namespace
