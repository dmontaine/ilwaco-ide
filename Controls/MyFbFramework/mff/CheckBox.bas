'################################################################################
'#  CheckBox.bas                                                                #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   TCheckBox.bi                                                               #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#   Version 1.0.0                                                              #
'#  Updated and added cross-platform                                            #
'#  by Xusinboy Bekchanov (2018-2019), Liu XiaLin                               #
'################################################################################

#include once "CheckBox.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function CheckBox.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "alignment": Return @FAlignment
			Case "autosize": Return @FAutoSize
			Case "caption": Return FText.vptr
			Case "text": Return FText.vptr
			Case "checked": Return @FChecked
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function CheckBox.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "alignment": Alignment = *Cast(CheckAlignmentConstants Ptr, Value)
			Case "autosize": AutoSize = QBoolean(Value)
			Case "caption": This.Caption = QWString(Value)
			Case "text": This.Text = QWString(Value)
			Case "checked": Checked = QBoolean(Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property CheckBox.Alignment As CheckAlignmentConstants
		Return FAlignment
	End Property
	
	Private Property CheckBox.Alignment(Value As CheckAlignmentConstants)
		If Value <> FAlignment Then
			FAlignment = Value
		End If
	End Property
	
	Private Property CheckBox.AutoSize As Boolean
		Return FAutoSize
	End Property
	
	Private Property CheckBox.AutoSize(Value As Boolean)
		FAutoSize = Value
	End Property
	
	Private Property CheckBox.Caption ByRef As WString
		Return Text
	End Property
	
	Private Property CheckBox.Caption(ByRef Value As WString)
		Text = Value
	End Property
	
	Private Property CheckBox.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property CheckBox.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property CheckBox.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property CheckBox.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property CheckBox.Text ByRef As WString
		Return Base.Text
	End Property
	
	Private Property CheckBox.Text(ByRef Value As WString)
		Base.Text = Value
		#ifdef __USE_GTK__
			gtk_button_set_label(GTK_BUTTON(widget), ToUtf8(Value))
		#elseif 0
			If FHandle Then
				(*env)->CallVoidMethod(env, FHandle, GetMethodID(*FClassAncestor, "setText", "(Ljava/lang/CharSequence;)V"), (*env)->NewStringUTF(env, ToUtf8(FText)))
			End If
		#elseif 0
			If FAutoSize Then AutoSize = True
		#endif
	End Property
	
	Private Property CheckBox.Checked As Boolean
		If FHandle Then
			#ifdef __USE_GTK__
				FChecked = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(widget))
			#elseif 0
				FChecked = Perform(BM_GETCHECK, 0, 0)
			#elseif 0
				FChecked = (*env)->CallBooleanMethod(env, FHandle, GetMethodID(*FClassAncestor, "isChecked", "()Z"))
			#elseif 0
				FChecked = GetChecked(Trim(Str(FHandle)) & "checkbox")
			#endif
		End If
		Return FChecked
	End Property
	
	Private Property CheckBox.Checked(Value As Boolean)
		FChecked = Value
		If FHandle Then
			#ifdef __USE_GTK__
				gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(widget), Value)
			#elseif 0
				Perform(BM_SETCHECK, FChecked, 0)
			#elseif 0
				(*env)->CallVoidMethod(env, FHandle, GetMethodID(*FClassAncestor, "setChecked", "(Z)V"), _Abs(Value))
			#elseif 0
				SetChecked(Trim(Str(FHandle)) & "checkbox", Value)
			#endif
		End If
	End Property
	
	Private Sub CheckBox.HandleIsAllocated(ByRef Sender As Control)
	End Sub
	
	
	#ifdef __USE_WASM__
		Private Function CheckBox.GetContent() As UString
			Return "<input type=""checkbox"" id=""" & Trim(Str(@This)) & "checkbox""/>" & !"\r" & "<label for=""" & Trim(Str(@This)) & "checkbox"" id=""" & Trim(Str(@This)) & "label"">" & FText & "</label>"
		End Function
	#endif
	
	Private Sub CheckBox.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator CheckBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	#ifdef __USE_GTK__
		Private Sub CheckBox.CheckBox_Toggled(widget As GtkToggleButton Ptr, user_data As Any Ptr)
			Dim As CheckBox Ptr but = user_data
			If but->OnClick Then but->OnClick(*but->Designer, *but)
		End Sub
	#endif
	
	Private Constructor CheckBox
		With This
			.Child                  = @This
			#ifdef __USE_GTK__
				widget = gtk_check_button_new_with_label("")
				.RegisterClass "CheckBox", @This
				g_signal_connect(widget, "toggled", G_CALLBACK(@CheckBox_Toggled), @This)
			#elseif 0
				.RegisterClass "CheckBox", "Button"
				WLet(FClassAncestor, "Button")
				.ChildProc              = @WndProc
			#elseif 0
				WLet(FClassAncestor, "android/widget/CheckBox")
			#elseif 0
				WLet(FClassAncestor, "div")
				FType = ""
				FElementStyle = "overflow: hidden; display: flex; align-items: center"
			#endif
			WLet(FClassName, "CheckBox")
			FTabIndex = -1
			FTabStop = True
			.OnHandleIsAllocated    = @HandleIsAllocated
			.Width                  = 90
			.Height                 = 17
			.FTabIndex              = -1
			.FTabStop               = True
		End With
	End Constructor
	
	Private Destructor CheckBox
	End Destructor
End Namespace
