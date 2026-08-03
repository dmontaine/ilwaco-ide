'###############################################################################
'#  Application.bas                                                             #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TApplication.bi                                                           #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.1                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "Application.bi"
#include once "Form.bi"
#include once "DarkMode/DarkMode.bi"

'Provides methods and properties to manage an application, such as methods to start and stop an application, to process messages, and properties to get information about an application.
Dim Shared App As My.Application
If pApp = 0 Then pApp = @App

Namespace My
	#ifndef ReadProperty_Off
		Private Function Application.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "mainform": Return @FMainForm
			Case "version": WLet(FTemp, WStr(Version)): Return FTemp
			Case "title": Title: Return FTitle
			Case "filename": Return @This.FileName
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Application.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "mainform": This.MainForm = Value
				Case "title": This.Title = QWString(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property Application.DarkMode As Boolean
		Return FDarkMode
	End Property
	
	Private Property Application.DarkMode(Value As Boolean)
		FDarkMode = Value
		SetDarkMode Value, False
	End Property
	
	#ifndef APP_TITLE
		#define APP_TITLE ""
	#endif
	#ifndef VER_MAJOR
		#define VER_MAJOR "0"
	#endif
	#ifndef VER_MINOR
		#define VER_MINOR "0"
	#endif
	#ifndef VER_PATCH
		#define VER_PATCH "0"
	#endif
	#ifndef VER_BUILD
		#define VER_BUILD "0"
	#endif
	
	Private Function Application.Version As String
		Return GetVerInfo("FileVersion")
	End Function
	
	Private Property Application.Icon As My.Sys.Drawing.Icon
		Return FIcon
	End Property
	
	Private Property Application.Icon(value As My.Sys.Drawing.Icon)
		Dim As Integer i
		FIcon = value
	End Property
	
	Private Property Application.CurLanguagePath ByRef As WString
		If FCurLanguagePath = 0 Then WLet(FCurLanguagePath, ExePath & "/Languages/")
		Return *FCurLanguagePath
	End Property
	
	Private Property Application.CurLanguagePath(ByRef Value As WString)
		WLet(FCurLanguagePath, Value)
	End Property
	
	Private Property Application.CurLanguage ByRef As WString
		Return *FCurLanguage
	End Property
	
	Private Property Application.CurLanguage(ByRef Value As WString)
		If LCase(Value) = LCase(*FLanguage) OrElse Value = "" OrElse LCase(Value) = LCase(*FCurLanguage) Then Return
		mlKeys.Clear
		Dim As Integer i, Pos1, Pos2
		Dim As Integer Fn = FreeFile, Result
		Dim As WString * 2048 Buff, tKey
		Dim As Boolean StartGeneral = False
		Dim As UString LanguageFile = *FCurLanguagePath & Value & ".lng"
		Result = Open(LanguageFile For Input Encoding "utf-8" As #Fn)
		If Result <> 0 Then Result = Open(LanguageFile For Input Encoding "utf-16" As #Fn)
		If Result <> 0 Then Result = Open(LanguageFile For Input Encoding "utf-32" As #Fn)
		If Result <> 0 Then Result = Open(LanguageFile For Input As #Fn)
		If Result = 0 Then
			Do Until EOF(Fn)
				Line Input #Fn, Buff
				If LCase(Trim(Buff)) = "[general]" Then StartGeneral = True : Continue Do
				Pos1 = InStr(Buff, "=")
				If StartGeneral AndAlso Len(Trim(Buff, Any !"\t ")) > 0 AndAlso Pos1 > 0 Then
					Pos2 = InStr(Pos1, Buff, "|")
					tKey = Trim(Mid(Buff, 1, Pos1 - 1), Any !"\t ")
					Var Pos3 = InStr(Buff, "~")
					If Pos3 > 0 AndAlso Pos3 < Pos1 Then Buff = Replace(Buff, "~", "=")
					If Trim(Mid(Buff, Pos1 + 1), Any !"\t ") <> "" Then mlKeys.Add Trim(Left(Buff, Pos1 - 1), Any !"\t "), Trim(Mid(Buff, Pos1 + 1), Any !"\t ")
				End If
			Loop
			mlKeys.SortKeys
			Close(Fn)
			WLet(FCurLanguage, Value)
		Else
			Print ML("Open file failure!") &  " " & ML("in function") & " Application.CurLanguage. File Name: " &  LanguageFile
		End If
	End Property
	
	Private Property Application.Language ByRef As WString
		Return WGet(FLanguage)
	End Property
	
	Private Property Application.Language(ByRef Value As WString)
		WLet(FLanguage, Value)
	End Property
	
	#ifndef Application_Title_Get_Off
		Private Property Application.Title ByRef As WString
			If FTitle = 0 Then
				WLet(FTitle, GetVerInfo("ApplicationTitle"))
				If *FTitle = "" Then
						WLet(FTitle, APP_TITLE)
				End If
			End If
			Return *FTitle
		End Property
	#endif
	
	Private Property Application.Title(ByRef Value As WString)
		WLet(FTitle, Value)
	End Property
	
	Private Function Application.PrevInstance As Boolean
			Return False
	End Function
	
	Private Function Application.Path ByRef As WString
		If FPath > 0 Then Return *FPath
		Dim As WString * 256 Tx
		Dim As WString * 256 s, En
		Dim As Integer L, i, k
			Tx = Command(0)
			L = Len(Tx)
		s = .Left(Tx, L)
		WLet(FFileName, s)
		k = InStrRev(s, Any ":/\")
		If k < 1 Then
			k = 0
			WLet(FPath, "")
		Else
			WLet(FPath, Left(s, k - 1))
		End If
		En = Mid(s, k + 1, Len(s))
		k = InStr(En, ".") - 1
		If k < 1 Then k = Len(En)
		WLet(FExeName, Mid(En, 1, k))
		Return *FPath
	End Function
	
	Private Function Application.ExeName ByRef As WString
		If FExeName > 0 Then Return *FExeName
		Dim As WString * 256 Tx
		Dim As WString * 256 s, En
		Dim As Integer L, i, k
			Tx = Command(0)
			L = Len(Tx)
		s = .Left(Tx, L)
		WLet(FFileName, s)
		k = InStrRev(s, Any ":/\")
		If k < 1 Then
			k = 0
			WLet(FPath, "")
		Else
			WLet(FPath, Left(s, k - 1))
		End If
		En = Mid(s, k + 1, Len(s))
		k = InStr(En, ".") - 1
		If k < 1 Then k = Len(En)
		WLet(FExeName, Mid(En, 1, k))
		Return *FExeName
	End Function
	
	Private Function Application.FileName ByRef As WString
		Dim As WString * 256 Tx
		Dim As WString * 256 s, En
		Dim As Integer L, i, k
			Tx = Command(0)
			L = Len(Tx)
		s = .Left(Tx, L)
		WLet(FFileName, s)
		k = InStrRev(s, Any ":/\")
		If k < 1 Then
			k = 0
			WLet(FPath, "")
		Else
			WLet(FPath, Left(s, k - 1))
		End If
		En = Mid(s, k + 1, Len(s))
		k = InStr(En, ".") - 1
		If k < 1 Then k = Len(En)
		WLet(FExeName, Mid(En, 1, k))
		Return *FFileName
	End Function
	
	Private Property Application.ActiveForm As My.Sys.Forms.Form Ptr
		Return FActiveForm
	End Property
	
	Private Property Application.ActiveForm(Value As My.Sys.Forms.Form Ptr)
		FActiveForm = Value
		'		#ifdef __USE_WINAPI__
		'			If Value Then SetForegroundWindow(Value->Handle)
		'		#endif
	End Property
	
	Private Property Application.ActiveMDIChild As My.Sys.Forms.Form Ptr
		Return FActiveMDIChild
	End Property
	
	Private Property Application.ActiveMDIChild(Value As My.Sys.Forms.Form Ptr)
		FActiveMDIChild = Value
		'		#ifdef __USE_WINAPI__
		'			If Value Then SetForegroundWindow(Value->Handle)
		'		#endif
	End Property
	
	Private Property Application.MainForm As My.Sys.Forms.Form Ptr
		'        For i As Integer = 0 To FormCount -1
		'            If (Forms[i]->ExStyle AND WS_EX_APPWINDOW) = WS_EX_APPWINDOW Then
		'                FMainForm = Forms[i]
		Return FMainForm
		'            End If
		'        Next i
	End Property
	
	Private Property Application.MainForm(Value As My.Sys.Forms.Form Ptr)
		FMainForm = Value
			If FMainForm AndAlso FMainForm->Handle Then g_signal_connect(FMainForm->Handle, "delete-event", G_CALLBACK(@gtk_main_quit), NULL)
	End Property
	
	#ifndef Application_ControlCount_Get_Off
		Private Property Application.ControlCount As Integer
			GetControls
			Return FControlCount
		End Property
	#endif
	
	Private Property Application.ControlCount(Value  As Integer)
	End Property
	
	#ifndef Application_Controls_Get_Off
		Private Property Application.Controls As My.Sys.Forms.Control Ptr Ptr
			GetControls
			Return FControls
		End Property
	#endif
	
	Private Property Application.Controls(Value  As My.Sys.Forms.Control Ptr Ptr)
	End Property
	
	Private Function Application.FormCount As Integer
		GetForms
		Return FFormCount
	End Function
	
	#ifndef Application_Forms_Get_Off
		Private Property Application.Forms As My.Sys.Forms.Form Ptr Ptr
			GetForms
			Return FForms
		End Property
	#endif
	
	Private Property Application.Forms(Value  As My.Sys.Forms.Form Ptr Ptr)
	End Property
	
	'	Property Application.HintColor As Integer
	'		Return FHintColor
	'	End Property
	'
	'	Property Application.HintColor(value As Integer)
	'		Dim As Integer i
	'		FHintColor = value
	'		For i = 0 To ControlCount -1
	'			#ifndef __USE_GTK__
	'				If Controls[i]->ToolTipHandle Then SendMessage(Controls[i]->ToolTipHandle,TTM_SETTIPBKCOLOR,value,0)
	'			#endif
	'		Next i
	'	End Property
	'
	'	Property Application.HintPause As Integer
	'		Return FHintPause
	'	End Property
	'
	'	Property Application.HintPause (value As Integer)
	'		Dim As Integer i
	'		FHintPause = value
	'		For i = 0 To ControlCount -1
	'			#ifndef __USE_GTK__
	'				If Controls[i]->ToolTipHandle Then SendMessage(Controls[i]->ToolTipHandle,TTM_SETDELAYTIME,TTDT_INITIAL,value)
	'			#endif
	'		Next i
	'	End Property
	'
	'	Property Application.HintShortPause As Integer
	'		Return FHintShortPause
	'	End Property
	'
	'	Property Application.HintShortPause(value As Integer)
	'		Dim As Integer i
	'		FHintShortPause = value
	'		For i = 0 To ControlCount -1
	'			#ifndef __USE_GTK__
	'				If Controls[i]->ToolTipHandle Then SendMessage(Controls[i]->ToolTipHandle,TTM_SETDELAYTIME,TTDT_RESHOW,value)
	'			#endif
	'		Next i
	'	End Property
	'
	'	Property Application.HintHidePause As Integer
	'		Return FHintHidePause
	'	End Property
	'
	'	Property Application.HintHidePause(value As Integer)
	'		Dim As Integer i
	'		FHintHidePause = value
	'		For i = 0 To ControlCount -1
	'			#ifndef __USE_GTK__
	'				If Controls[i]->ToolTipHandle Then SendMessage(Controls[i]->ToolTipHandle,TTM_SETDELAYTIME,TTDT_AUTOPOP,value)
	'			#endif
	'		Next i
	'	End Property
	
	Private Sub Application.HelpCommand(CommandID As Integer,FData As Long)
	End Sub
	
	Private Sub Application.HelpContext(ContextID As Long)
	End Sub
	
	Private Sub Application.HelpJump(TopicID As String)
		Dim StrFmt As String
		StrFmt = "JumpID(" + Chr(34) + Chr(34) + ","+ Chr(34) + TopicID + Chr(34) + ")"+ Chr(0)
		If MainForm Then
		End If
	End Sub
	
	Private Sub Application.Run
			'gdk_threads_enter()
			gtk_main()
			'gdk_threads_leave()
	End Sub
	
	Private Sub Application.Terminate
		End 1
	End Sub
	
	#ifndef Application_DoEvents_Off
		Private Sub Application.DoEvents
				While gtk_events_pending()
					gtk_main_iteration
				Wend
		End Sub
	#endif
	
	Private Function Application.IndexOfControl(Control As My.Sys.Forms.Control Ptr) As Integer
		Dim As Integer i
		For i = 0 To ControlCount -1
			If Controls[i] = Control Then Return i
		Next i
		Return -1
	End Function
	
	
	Private Function Application.FindControl(ControlName As String) As My.Sys.Forms.Control Ptr
		Dim As Integer i
		If Controls Then
			For i = 0 To ControlCount -1
				If UCase(Controls[i]->Name) = UCase(ControlName) Then Return Controls[i]
			Next i
		End If
		Return 0
	End Function
	
	Private Function Application.IndexOfForm(Form As My.Sys.Forms.Form Ptr) As Integer
		Dim As Integer i
		If Forms Then
			For i = 0 To FormCount -1
				If Forms[i] = Form Then Return i
			Next i
		End If
		Return -1
	End Function
	
	
	Private Sub Application.GetForms
		FFormCount = 0
	End Sub
	
	#ifndef Application_GetControls_Off
		Private Sub Application.EnumControls(Control As My.Sys.Forms.Control)
			Dim As Integer i
			For i = 0 To Control.ControlCount -1
				FControlCount += 1
				FControls = _Reallocate(FControls,SizeOf(My.Sys.Forms.Control Ptr)*FControlCount)
				FControls[FControlCount -1] = Control.Controls[i]
				EnumControls(*Control.Controls[i])
			Next i
		End Sub
		
		Private Sub Application.GetControls
			Dim As Integer i
			FControlCount = 0
			For i = 0 To FormCount - 1
				EnumControls(*Forms[i])
			Next i
		End Sub
	#endif
	
	
	Private Sub Application.GetFonts
		Fonts.Clear
		'       EnumFontFamilies(DC,NULL,@EnumFontsProc,Cint(@Fonts)) 'OR
		'EnumFontFamiliesEx(DC,@LFont,@EnumFontsProc,CInt(@s), 0)
		'EnumFonts(DC,NULL,@EnumFontsProc,CInt(NULL))
	End Sub
	
	Private Operator Application.Cast As Any Ptr
		Return @This
	End Operator
	
	#ifndef Application_GetVerInfo_Off
		Private Function Application.GetVerInfo(ByRef InfoName As String) As String
				If InfoName = "ProductVersion" Then
					Return VER_MAJOR & "." & VER_MINOR & "." & VER_PATCH
				ElseIf InfoName = "FileVersion" Then
					Return VER_MAJOR & "." & VER_MINOR & "." & VER_PATCH & "." & VER_BUILD
				End If
		End Function
	#endif
	
	Private Constructor Application
		If pApp = 0 Then pApp = @This
			'g_thread_init(NULL)
					gdk_threads_init()
			generic_gtk_init()
			
			gtk_icon_theme_append_search_path(gtk_icon_theme_get_default(), ToUtf8(ExePath & "/resources"))
			gtk_icon_theme_append_search_path(gtk_icon_theme_get_default(), ToUtf8(ExePath & "/Resources"))
			'gtk_icon_theme_add_resource_path(gtk_icon_theme_get_default(), exepath & "/resources")
			'Dim As GList Ptr l = gtk_icon_theme_list_icons(gtk_icon_theme_get_default(), null)
			'while (l)
			'	If StartsWith(*Cast(Zstring ptr, l->Data), "VisualFBEditor") Then
			'		?*Cast(Zstring ptr, l->Data)
			'	End If
			'	If StartsWith(*Cast(Zstring ptr, l->Data), "Logo") Then
			'		?*Cast(Zstring ptr, l->Data)
			'	End If
			'	l = l->Next
			'Wend
		WLet(FCurLanguagePath, ExePath & "/Languages/")
		WLet(FLanguage, "English")
		WLet(FCurLanguage, "English")
		GetFonts
		This.initialized = False
		This._vinfo = 0
		ExeName
	End Constructor
	
	Private Destructor Application
		If pApp = @This Then pApp = 0
		If FForms Then _Deallocate( FForms)
		If FFileName Then _Deallocate( FFileName)
		If FExeName Then _Deallocate( FExeName)
		If FPath Then _Deallocate( FPath)
		If FTitle Then _Deallocate( FTitle)
		If FControls Then _Deallocate( FControls)
		If FCurLanguage Then _Deallocate( FCurLanguage)
		If FCurLanguagePath Then _Deallocate( FCurLanguagePath)
		If FLanguage Then _Deallocate( FLanguage)
		If This._vinfo <> 0 Then _Deallocate((This._vinfo)) : This._vinfo = 0
	End Destructor
End Namespace

#ifdef _DebugWindow_
	'Gets a handle to the debug window when the application is launched from the IDE.
	Dim Shared As Any Ptr DebugWindowHandle = Cast(Any Ptr, _DebugWindow_)
#else
	'Gets a handle to the debug window when the application is launched from the IDE.
	Dim Shared As Any Ptr DebugWindowHandle
#endif

Namespace Debug
	#ifndef Debug_Assert_Off
		#define AssertError(expression) _Assert(__FILE__, __LINE__, __FUNCTION__, __FB_QUOTE__(expression), expression, 0)
		#define AssertWarning(expression) _Assert(__FILE__, __LINE__, __FUNCTION__, __FB_QUOTE__(expression), expression, 1)
		
		Private Sub _Assert(ByRef sFile As WString, iLine As Integer, ByRef sFunction As WString, ByRef sExpression As WString, expression As Boolean, iType As Integer)
			#ifdef __FB_DEBUG__
				If Not expression Then Print sFile & "(" & Str(iLine) & "): assertion failed at " & sFunction & ": " & sExpression
				If iType = 0 Then End
			#endif
		End Sub
	#endif
	
	#ifndef Debug_Clear_Off
		Private Sub Clear
				If GTK_IS_TEXT_VIEW(DebugWindowHandle) Then gtk_text_buffer_set_text(gtk_text_view_get_buffer(GTK_TEXT_VIEW(DebugWindowHandle)), !"\0", -1)
		End Sub
	#endif
	
	#ifndef Debug_Print_Off
		Private Sub Print Overload(ByVal Msg As Integer, ByVal Msg1 As Integer = -1, ByVal Msg2 As Integer = -1, ByVal Msg3 As Integer = -1, ByVal Msg4 As Integer = -1, bWriteLog As Boolean = False, bPrintMsg As Boolean = False, bShowMsg As Boolean = False, bPrintToDebugWindow As Boolean = True)
			Dim As WString Ptr tMsgPtr
			WLet(tMsgPtr, Str(Msg))
			If Msg1 <> -1 Then WAdd(tMsgPtr, Chr(9) & Msg1)
			If Msg2 <> -1 Then WAdd(tMsgPtr, Chr(9) & Msg2)
			If Msg3 <> -1 Then WAdd(tMsgPtr, Chr(9) & Msg3)
			If Msg4 <> -1 Then WAdd(tMsgPtr, Chr(9) & Msg4)
			Print(*tMsgPtr, bWriteLog, bPrintMsg, bShowMsg, bPrintToDebugWindow)
			_Deallocate(tMsgPtr)
		End Sub
		
		Private Sub Print Overload(ByRef Msg As WString, ByRef Msg1 As Const WString = "", ByRef Msg2 As Const WString = "", ByRef Msg3 As Const WString = "", ByRef Msg4 As Const WString = "", bWriteLog As Boolean = False, bPrintMsg As Boolean = False, bShowMsg As Boolean = False, bPrintToDebugWindow As Boolean = True)
			Dim As WString Ptr tMsgPtr
			WLet(tMsgPtr, Msg)
			If Msg1 <> "" Then WAdd(tMsgPtr, Chr(9) & Msg1)
			If Msg2 <> "" Then WAdd(tMsgPtr, Chr(9) & Msg2)
			If Msg3 <> "" Then WAdd(tMsgPtr, Chr(9) & Msg3)
			If Msg4 <> "" Then WAdd(tMsgPtr, Chr(9) & Msg4)
			Print(*tMsgPtr, bWriteLog, bPrintMsg, bShowMsg, bPrintToDebugWindow)
			_Deallocate(tMsgPtr)
		End Sub
		
		Private Sub Print Overload(ByRef Msg As UString, bWriteLog As Boolean = False, bPrintMsg As Boolean = False, bShowMsg As Boolean = False, bPrintToDebugWindow As Boolean = True)
			If bWriteLog Then
				Dim As Integer Result, Fn = FreeFile_
				Result = Open(ExePath & "/DebugInfo.log" For Append Encoding "utf-8" As #Fn) 
				If Result = 0 Then
					.Print #Fn, __DATE_ISO__ & " " & Time & Chr(9) & Msg
				End If
				CloseFile_(Fn)
			End If
				If bPrintMsg OrElse bPrintToDebugWindow Then .Print Msg
			If bShowMsg Then MsgBox Msg, "Visual FB Editor"
			If bPrintToDebugWindow Then
					If 1 = 0 AndAlso GTK_IS_TEXT_VIEW(DebugWindowHandle) Then
						Dim As GtkWidget Ptr TabPageHandle = gtk_widget_get_parent(DebugWindowHandle)
						Dim As GtkWidget Ptr TabControlHandle = gtk_widget_get_parent(TabPageHandle)
						Dim As Integer Index = gtk_notebook_page_num(GTK_NOTEBOOK(TabControlHandle), TabPageHandle)
						If gtk_notebook_get_current_page(GTK_NOTEBOOK(gtk_widget_get_parent(gtk_widget_get_parent(DebugWindowHandle)))) <> Index Then
							gtk_notebook_set_current_page(GTK_NOTEBOOK(gtk_widget_get_parent(gtk_widget_get_parent(DebugWindowHandle))), Index)
						End If
						Dim As GtkTextIter _start, _end
						gtk_text_buffer_insert_at_cursor(gtk_text_view_get_buffer(GTK_TEXT_VIEW(DebugWindowHandle)), ToUtf8(Msg & Chr(13, 10)), -1)
						gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(DebugWindowHandle)), @_start, @_end)
						Dim As GtkTextMark Ptr ptextmark = gtk_text_buffer_create_mark(gtk_text_view_get_buffer(GTK_TEXT_VIEW(DebugWindowHandle)), NULL, @_end, False)
						gtk_text_view_scroll_to_mark(GTK_TEXT_VIEW(DebugWindowHandle), ptextmark, 0., False, 0., 0.)
						While gtk_events_pending()
							gtk_main_iteration()
						Wend
					End If
			End If
		End Sub
	#endif
End Namespace


Public Function ML(ByRef V As WString) ByRef As WString
	If App.CurLanguage = App.Language Then Return V
	Dim As Integer tIndex = mlKeys.IndexOfKey(V) ' For improve the speed
	If tIndex >= 0 Then
		Return mlKeys.Item(tIndex)->Text
	Else
		tIndex = mlKeys.IndexOfKey(Replace(V, "&", "")) '
		If tIndex >= 0 Then Return mlKeys.Item(tIndex)->Text Else Return V
	End If
End Function

Public Function MsgBox Alias "MsgBox" (ByRef MsgStr As WString, ByRef Caption As WString = "", MsgType As MessageType = MessageType.mtInfo, ButtonsType As ButtonsTypes = ButtonsTypes.btOK) As MessageResult __EXPORT__
	Dim As Integer Result = -1
	Dim As WString Ptr FCaption
	Dim As Integer MsgTypeIn, ButtonsTypeIn
	WLet(FCaption, Caption)
	Dim As My.Sys.Forms.Control Ptr ActiveForm
	If *FCaption = "" Then WLet(FCaption, App.Title)
	'    For i As Integer = 0 To App.FormCount -1
	'        If GetActiveWindow = App.Forms[i]->Handle Then ActiveForm = App.Forms[i]
	'        If App.Forms[i]->Handle Then App.Forms[i]->Enabled = False
	'    Next i
	'    If ActiveForm Then
	'       If ActiveForm->Handle Then
	'          Wnd = ActiveForm->Handle
	'       Else
	'          Wnd = MainHandle
	'       End If
	'    End If
		Dim As GtkWidget Ptr dialog
		Dim As GtkWindow Ptr win
		If pApp AndAlso pApp->MainForm Then
			win = GTK_WINDOW(pApp->MainForm->Handle)
		End If
		Select Case MsgType
		Case mtInfo: MsgTypeIn = GTK_MESSAGE_INFO
		Case mtWarning: MsgTypeIn = GTK_MESSAGE_WARNING
		Case mtQuestion: MsgTypeIn = GTK_MESSAGE_QUESTION
		Case mtError: MsgTypeIn = GTK_MESSAGE_ERROR
		Case mtOther: MsgTypeIn = GTK_MESSAGE_OTHER
		End Select
		Select Case ButtonsType
		Case btNone: ButtonsTypeIn = GTK_BUTTONS_NONE
		Case btOK: ButtonsTypeIn = GTK_BUTTONS_OK
		Case btYesNo: ButtonsTypeIn = GTK_BUTTONS_YES_NO
		Case btYesNoCancel: ButtonsTypeIn = GTK_BUTTONS_YES_NO
		Case btOkCancel: ButtonsTypeIn = GTK_BUTTONS_OK_CANCEL
		End Select
		dialog = gtk_message_dialog_new (win, _
		GTK_DIALOG_DESTROY_WITH_PARENT Or GTK_DIALOG_MODAL, _
		MsgTypeIn, _
		IIf(ButtonsType = btYesNoCancel, btNone, ButtonsTypeIn), _
		ToUtf8(MsgStr), _
		NULL)
		gtk_window_set_transient_for(GTK_WINDOW(dialog), win)
		gtk_window_set_title(GTK_WINDOW(dialog), ToUtf8(*FCaption))
		If ButtonsType = btYesNoCancel Then
					gtk_dialog_add_button(GTK_DIALOG(dialog), ToUtf8(*Cast(WString Ptr, GTK_STOCK_CANCEL)), GTK_RESPONSE_CANCEL)
					gtk_dialog_add_button(GTK_DIALOG(dialog), ToUtf8(*Cast(WString Ptr, GTK_STOCK_NO)), GTK_RESPONSE_NO)
					gtk_dialog_add_button(GTK_DIALOG(dialog), ToUtf8(*Cast(WString Ptr, GTK_STOCK_YES)), GTK_RESPONSE_YES)
			gtk_dialog_set_default_response(GTK_DIALOG(dialog), GTK_RESPONSE_YES)
		End If
			Result = gtk_dialog_run (GTK_DIALOG (dialog))
		Select Case Result
		Case GTK_RESPONSE_CANCEL: Result = mrCancel
		Case GTK_RESPONSE_NO: Result = mrNo
		Case GTK_RESPONSE_OK: Result = mrOK
		Case GTK_RESPONSE_YES: Result = mrYes
		End Select
			gtk_widget_destroy(dialog)
	'Do
	'    App.DoEvents
	'Loop Until Result <> -1
	'    For i As Integer = 0 To App.FormCount -1
	'        If App.Forms[i]->Handle Then App.Forms[i]->Enabled = True
	'    Next i
	WDeAllocate(FCaption)
	Return Result
End Function

Type TInputBox
		dialog As GtkWidget Ptr
		
		entry As GtkWidget Ptr
		
		sText As ZString*1024
		
		iFlag As Long
End Type

	Sub EventbuttonInputBoxSub cdecl(Gwindow As GtkWidget Ptr,  data_ As gpointer) Export
		
		Dim As TInputBox Ptr tib = data_
		
			tib->sText = *gtk_entry_get_text(Cast(Any Ptr, tib->entry))
		
		gtk_dialog_response(Cast(Any Ptr, tib->dialog) , GTK_RESPONSE_OK)
		
	End Sub
	
	Function EventEntryInputBoxFunc cdecl( Gwindow As GtkWidget Ptr, gEvent As GdkEvent Ptr, data_ As gpointer) As gboolean Export
		
		Dim As TInputBox Ptr tib = data_
		
		If tib->iFlag = 0 AndAlso Cast(GdkEventButton Ptr,gEvent)->type = GDK_BUTTON_PRESS Then
			
				gtk_entry_set_text(Cast(Any Ptr, tib->entry), "")
			
			tib->iFlag = 1
			
		End If
		
		Return False
		
	End Function

Function InputBox(ByRef sCaption As WString  = "" , ByRef sMessageText As WString = "Enter text:" , ByRef sDefaultText As WString = "" , iFlag As Long = 0 , iFlag2 As Long = 0, hParentWin As Any Ptr = 0) As UString __EXPORT__
		Dim As GtkWidget  Ptr dialog
		
		Dim As GtkWidget  Ptr label
		
		Dim As GtkWidget  Ptr entry
		
		Dim As GtkWidget  Ptr button
		
		Dim As GtkWidget  Ptr hBoxDialog , vBox , hBox1 , hBox2 , hBox3 , vboxfill
		
		dialog = gtk_dialog_new ()
		
		If hParentWin Then
			
			gtk_window_set_transient_for(GTK_WINDOW(dialog) , Cast(Any Ptr,hParentWin))
			
		End If
		
		hBoxDialog = gtk_dialog_get_action_area(GTK_DIALOG(dialog))
		
		gtk_window_set_title (GTK_WINDOW (dialog), sCaption)
		
		label = gtk_label_new (sMessageText)
		
		entry = gtk_entry_new ()
		
		button = gtk_button_new_with_label("OK")
		
		vBox = gtk_vbox_new( 0 , 5)
		
		hBox1 = gtk_hbox_new( 1 , 180)
		
		hBox2 = gtk_hbox_new( 1 , 0)
		
		hBox3 = gtk_hbox_new( 1 , 0)
		
		vboxfill = gtk_vbox_new( 0 , 0)
		
		gtk_box_pack_start(Cast(Any Ptr , vBox), hBox1 , 0 , 1, 0)
		
		gtk_box_pack_start(Cast(Any Ptr , vBox), hBox2 , 1 , 1, 0)
		
		gtk_box_pack_start(Cast(Any Ptr , vBox), hBox3 , 1 , 1, 6)
		
		gtk_box_pack_start(Cast(Any Ptr , hBoxDialog), vBox , 1 , 1, 0)
		
		gtk_box_pack_start(Cast(Any Ptr , hBox1), label , 0 , 1, 0)
		
		gtk_box_pack_start(Cast(Any Ptr , hBox1), vboxfill , 1 , 1, 0)
		
		gtk_box_pack_start(Cast(Any Ptr , hBox2), entry , 1 , 1, 0)
		
		gtk_box_pack_start(Cast(Any Ptr , hBox3), button ,1 , 1, 100)
		
		gtk_widget_set_size_request(entry, 300, 30)
		
		If Len(sDefaultText) Then
			
				gtk_entry_set_text (Cast(Any Ptr, entry) , sDefaultText)
			
		End If
		
		Dim As TInputBox Ptr tib = _New(TInputBox)
		
		tib->dialog = dialog
		
		tib->entry = entry
		
		g_signal_connect(G_OBJECT(button), "clicked", G_CALLBACK (@EventbuttonInputBoxSub),tib)
		
		If iFlag2 Then
			
			g_signal_connect(G_OBJECT(entry), "event", G_CALLBACK (@EventEntryInputBoxFunc), tib)
			
		End If
		
		#ifdef __USE_GTK4
			gtk_widget_set_visible(dialog, True)
		#else
			gtk_widget_show_all(dialog)
		#endif
		
		If gtk_dialog_run (Cast(Any Ptr ,dialog)) = GTK_RESPONSE_OK Then
			
			Function = Trim(tib->sText, Chr(0))
			
		End If
		
		_Delete(tib)
		
			gtk_widget_destroy(dialog)
End Function

#ifndef LoadFromFile_Off
	Private Function CheckUTF8NoBOM(ByRef SourceStr As String, ByVal SampleSize As Long = 0) As Boolean
		
		Dim As Integer byte_class_table(0 To 255) = { _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, _
		1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, _
		2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, _
		3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3, _
		3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3, _
		4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5, _
		5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5, _
		6,7,7,7,7,7,7,7,7,7,7,7,7,8,7,7, _
		9,10,10,10,11,4,4,4,4,4,4,4,4,4,4,4 _
		}
		
		Dim As Integer state_table(0 To 107) = { _
		0, 8, 8, 8, 8, 8, 8, 8, 8, _
		8, 0, 1, 8, 1, 2, 8, 2, 8, _
		8, 0, 1, 8, 1, 2, 2, 8, 8, _
		8, 0, 1, 1, 8, 2, 2, 8, 8, _
		8, 8, 8, 8, 8, 8, 8, 8, 8, _
		1, 8, 8, 8, 8, 8, 8, 8, 8, _
		3, 8, 8, 8, 8, 8, 8, 8, 8, _
		2, 8, 8, 8, 8, 8, 8, 8, 8, _
		4, 8, 8, 8, 8, 8, 8, 8, 8, _
		6, 8, 8, 8, 8, 8, 8, 8, 8, _
		5, 8, 8, 8, 8, 8, 8, 8, 8, _
		7, 8, 8, 8, 8, 8, 8, 8, 8 _
		}
		Dim As Integer Offset, iEnd = IIf(SampleSize= 0, Len(SourceStr) - 1, SampleSize)
		If iEnd < 2 Then Return False
		Dim As Boolean  bHasUnicode
		Dim As UInteger UnicodeCP, current = 0
		For i As Integer  = 0 To iEnd
			If Not bHasUnicode AndAlso CBool(SourceStr[i] < 0 OrElse SourceStr[i] > 126) Then bHasUnicode = True
			Offset = byte_class_table(SourceStr[i])
			current = state_table(Offset * 9 + current)
			If current = 8 Then Exit For
			'If current <> 0 AndAlso i < iEnd - 1 AndAlso (SourceStr[i] And &h80) = &h80 Then ' 非ASCII字符 Then
			'	UnicodeCP = ((SourceStr[i] And &h0F) Shl 12) Or ((SourceStr[i + 1] And &H3F) Shl 6) Or ((SourceStr[i + 2] And &H3F))
			'	Print "UnicodeCP=" & UnicodeCP & " Hex=" & Hex(UnicodeCP)
			'	If (UnicodeCP < CUInt(&HE0)) OrElse (UnicodeCP > CUInt(&HEF)) Then current = 0 : i += 3
			'End If
		Next
		Return IIf(current = 0, IIf(bHasUnicode, True, False), False)
		
	End Function
	
	Private Function LoadFromFile(ByRef FileName As WString, ByRef FileEncoding As FileEncodings = FileEncodings.Utf8BOM, ByRef NewLineType As NewLineTypes = NewLineTypes.WindowsCRLF, ByVal nCodePage As Integer = -1) As WString Ptr
		Dim As String Buff, EncodingStr, NewLineStr
		Dim As Integer Result = -1, Fn, FileSize, MaxChars
		Dim As Boolean FileLoaded
		Fn = FreeFile_
		If Open(FileName For Binary Access Read As #Fn) = 0 Then
			FileSize = LOF(Fn) + 1
			FileLoaded = IIf(FileSize > 65536, False, True)
			MaxChars = IIf(FileSize > 65536, 65536, FileSize)
			Buff = String(MaxChars, 0)
			Get #Fn, , Buff
			If (Buff[0] = &HFF AndAlso Buff[1] = &HFE AndAlso Buff[2] = 0 AndAlso Buff[3] = 0) OrElse (Buff[0] = 0 AndAlso Buff[1] = 0 AndAlso Buff[2] = &HFE AndAlso Buff[3] = &HFF) Then 'Little Endian , Big Endian
				FileEncoding = FileEncodings.Utf32BOM
				EncodingStr = "utf-32"
			ElseIf (Buff[0] = &HFF AndAlso Buff[1] = &HFE) OrElse (Buff[0] = &HFE AndAlso Buff[1] = &HFF) Then 'Little Endian
				FileEncoding = FileEncodings.Utf16BOM
				EncodingStr = "utf-16"
			ElseIf Buff[0] = &HEF AndAlso Buff[1] = &HBB AndAlso Buff[2] = &HBF Then
				FileEncoding = FileEncodings.Utf8BOM
				EncodingStr = "utf-8"
			Else
				If (CheckUTF8NoBOM(Buff)) Then
					FileEncoding = FileEncodings.Utf8
					EncodingStr = "ascii"
				Else
					FileEncoding = FileEncodings.PlainText
					EncodingStr = "ascii"
				End If
			End If
			NewLineStr = Chr(13, 10)
			NewLineType= NewLineTypes.WindowsCRLF
			For i As Integer = 0 To MaxChars
				Select Case Buff[i]
				Case 13
					If i < MaxChars AndAlso Buff[i + 1] = 10  Then
						NewLineType= NewLineTypes.WindowsCRLF
						NewLineStr = Chr(13, 10)
					Else
						NewLineType= NewLineTypes.MacOSCR
						NewLineStr = Chr(13)
					End If
					Exit For
				Case 10
					If i = 0 OrElse Buff[i - 1] <> 13 Then
						NewLineType= NewLineTypes.LinuxLF
						NewLineStr = Chr(10)
					End If
					Exit For
				End Select
			Next
			CloseFile_(Fn)
		Else
			CloseFile_(Fn)
			Debug.Print ML("in function") + " " +  __FUNCTION__ + " " +  ML("in Line") + " " + Str( __LINE__) + Chr(9) + "Open file failure: " + FileName, True
			Return 0
		End If
		If FileEncoding = FileEncodings.Utf8 OrElse FileEncoding = FileEncodings.PlainText Then
			If FileLoaded Then
				Result = 0
			Else
				Fn = FreeFile_
				Result = Open(FileName For Binary Access Read As #Fn)
			End If
		Else
			Fn = FreeFile_
			Result = Open(FileName For Input Encoding EncodingStr As #Fn)
		End If
		If Result = 0 Then
			Dim As WString Ptr pBuff = 0
			If FileEncoding = FileEncodings.Utf8 OrElse FileEncoding = FileEncodings.PlainText Then
				If Not FileLoaded Then
					Buff = String(FileSize, 0)
					Get #Fn, , Buff
					CloseFile_(Fn)
				End If
				If Trim(Buff) = "" Then Return 0
					WReAllocate(pBuff, FileSize)
					*pBuff = String(FileSize, 0)
					UTFToWChar(1, StrPtr(Buff), pBuff, @FileSize)
			Else
				WLet(pBuff, WInput(FileSize, #Fn))
				CloseFile_(Fn)
			End If
			Return pBuff
		Else
			CloseFile_(Fn)
			Debug.Print ML("in function") + " " +  __FUNCTION__ + " " +  ML("in Line") + " " + Str( __LINE__) + Chr(9) +  "Open file failure: " + FileName, True
			Return 0
		End If
	End Function
#endif

#ifndef SaveToFile_Off
	Private Function SaveToFile(ByRef FileName As WString, ByRef wData As WString, ByRef FileEncoding As FileEncodings = FileEncodings.Utf8BOM, ByRef NewLineType As NewLineTypes = NewLineTypes.WindowsCRLF, ByVal nCodePage As Integer = -1) As Boolean
		Dim As Integer Fn = FreeFile_
		Dim As Integer Result, MaxChars = Len(wData) - 1
		Dim As String FileEncodingText, NewLineStr, OldLineStr
		If FileEncoding = FileEncodings.Utf8 Then
			FileEncodingText = "ascii"
		ElseIf FileEncoding = FileEncodings.Utf8BOM Then
			FileEncodingText = "utf-8"
		ElseIf FileEncoding = FileEncodings.Utf16BOM Then
			FileEncodingText = "utf-16"
		ElseIf FileEncoding = FileEncodings.Utf32BOM Then
			FileEncodingText = "utf-32"
		Else
			FileEncodingText = "ascii"
		End If
		OldLineStr = Chr(13, 10)
		For i As Integer = 0 To MaxChars
			Select Case wData[i]
			Case 13
				If i < MaxChars AndAlso wData[i + 1] = 10  Then
					OldLineStr = Chr(13, 10)
				Else
					OldLineStr = Chr(13)
				End If
				Exit For
			Case 10
				If i = 0 OrElse wData[i - 1] <> 13 Then
					OldLineStr = Chr(10)
				End If
				Exit For
			End Select
		Next
		If NewLineType = NewLineTypes.LinuxLF Then
			NewLineStr = Chr(10)
		ElseIf NewLineType = NewLineTypes.MacOSCR Then
			NewLineStr = Chr(13)
		Else
			NewLineStr = Chr(13, 10)
		End If
		If FileEncoding = FileEncodings.Utf8 OrElse FileEncoding = FileEncodings.PlainText Then
			Result = Open(FileName For Binary Access Write As #Fn)
		Else
			Result = Open(FileName For Output Encoding FileEncodingText As #Fn)
		End If
		If  Result = 0 Then
			If FileEncoding = FileEncodings.Utf8 Then
				If NewLineStr <> OldLineStr Then
					Put #Fn, , ToUtf8(Replace(wData, OldLineStr, NewLineStr))
				Else
					Put #Fn, , ToUtf8(wData)
				End If
			ElseIf FileEncoding = FileEncodings.PlainText Then
					If NewLineStr <> OldLineStr Then
						Put #Fn, , ToUtf8(Replace(wData, OldLineStr, NewLineStr))
					Else
						Put #Fn, , ToUtf8(wData)
					End If
			Else
				If NewLineStr <> OldLineStr Then
					Print #Fn, Replace(wData, OldLineStr, NewLineStr);  'Automaticaly add a Cr LF to the ends of file for each time without ";"
				Else
					Print #Fn, wData;
				End If
			End If
			CloseFile_(Fn)
			Return True
		Else
			Debug.Print ML("in function") + " " +  __FUNCTION__ + " " +  ML("in Line") + " " + Str( __LINE__) + Chr(9) +  "Save file failure: " + FileName, True
			CloseFile_(Fn)
			Return False
		End If
	End Function
#endif


Function ByteToString(ByVal Src As UByte Ptr, ByVal Size As Long) As String
	Dim As String Dest = String(Size, 0)
	Fb_MemCopy(Dest[0], Src[0], Size)
	Return Dest
End Function

'Function ByteToString Overload(Src() As UByte) As String
'	Dim As Long Size= UBound(Src) - LBound(Src) + 1
'	Dim As String Dest = String(Size, 0)
'    Fb_MemCopy(Dest[0], @Src(0), Size)
'    Return Dest
'End Function

#ifdef __EXPORT_PROCS__
	Function ApplicationMainForm Alias "ApplicationMainForm" (App As My.Application Ptr) As My.Sys.Forms.Control Ptr __EXPORT__
		Return App->MainForm
	End Function
	
	Function ApplicationFileName Alias "ApplicationFileName"(App As My.Application Ptr) ByRef As WString __EXPORT__
		Return App->FileName
	End Function
#endif
