'###############################################################################
'#  RadioButton.bi                                                             #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TRadioButton.bi                                                           #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "RadioButton.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function RadioButton.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "alignment": Return @FAlignment
			Case "caption": Return Cast(Any Ptr, This.FText.vptr)
			Case "checked": Return @FChecked
			Case "tabindex": Return @FTabIndex
			Case "text": Return Cast(Any Ptr, This.FText.vptr)
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function RadioButton.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "alignment": Alignment = *Cast(CheckAlignmentConstants Ptr, Value)
			Case "caption": If Value <> 0 Then This.Caption = *Cast(WString Ptr, Value)
			Case "checked": Checked = QBoolean(Value)
			Case "tabindex": If Value <> 0 Then TabIndex = QInteger(Value)
			Case "text": If Value <> 0 Then This.Text = *Cast(WString Ptr, Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property RadioButton.Alignment As CheckAlignmentConstants
		Return FAlignment
	End Property
	
	Private Property RadioButton.Alignment(Value As CheckAlignmentConstants)
		If Value <> FAlignment Then
			FAlignment = Value
		End If
	End Property
	
	Private Property RadioButton.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property RadioButton.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property RadioButton.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property RadioButton.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property RadioButton.Caption ByRef As WString
		Return Text
	End Property
	
	Private Property RadioButton.Caption(ByRef Value As WString)
		Text = Value
	End Property
	
	Private Property RadioButton.Parent As Control Ptr
		Return Base.Parent
	End Property
	
	Private Property RadioButton.Parent(Value As Control Ptr)
		#ifdef __USE_GTK__
			For i As Integer = 0 To Value->ControlCount - 1
				If Value->Controls[i]->ClassName = "RadioButton" Then
					#ifdef __USE_GTK3__
						gtk_radio_button_join_group(GTK_RADIO_BUTTON(widget), GTK_RADIO_BUTTON(Value->Controls[i]->widget))
					#else
						gtk_radio_button_set_group(GTK_RADIO_BUTTON(widget), gtk_radio_button_get_group(GTK_RADIO_BUTTON(Value->Controls[i]->widget)))
					#endif
					Exit For
				End If
			Next
		#endif
		Base.Parent = Value
	End Property
	Private Property RadioButton.Text ByRef As WString
		Return Base.Text
	End Property
	
	Private Property RadioButton.Text(ByRef Value As WString)
		Base.Text = Value
		#ifdef __USE_GTK__
			gtk_label_set_text_with_mnemonic(GTK_LABEL(gtk_bin_get_child(GTK_BIN(widget))), ToUtf8(Replace(Value, "&", "_")))
		#elseif 0
			If FHandle Then
				(*env)->CallVoidMethod(env, FHandle, GetMethodID(*FClassAncestor, "setText", "(Ljava/lang/CharSequence;)V"), (*env)->NewStringUTF(env, ToUtf8(FText)))
			End If
		#endif
	End Property
	
	Private Property RadioButton.Checked As Boolean
		If FHandle Then
			#ifdef __USE_GTK__
				FChecked = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(widget))
			#elseif 0
				FChecked = Perform(BM_GETCHECK, 0, 0)
			#elseif 0
				FChecked = (*env)->CallBooleanMethod(env, FHandle, GetMethodID(*FClassAncestor, "isChecked", "()Z"))
			#elseif 0
				FChecked = GetChecked(Trim(Str(FHandle)) & "radio")
			#endif
		End If
		Return FChecked
	End Property
	
	Private Property RadioButton.Checked(Value As Boolean)
		FChecked = Value
		If FHandle Then
			#ifdef __USE_GTK__
				gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(widget), Value)
			#elseif 0
				Perform(BM_SETCHECK, FChecked, 0)
				If FChecked Then
					If FParent Then
						For i As Integer = 0 To This.Parent->ControlCount - 1
							If This.Parent->Controls[i]->ClassName = "RadioButton" Then
								If This.Parent->Controls[i] <> @This Then
									This.Parent->Controls[i]->Perform(BM_SETCHECK, 0, 0)
								End If
							End If
						Next
					End If
				End If
			#elseif 0
				(*env)->CallVoidMethod(env, FHandle, GetMethodID(*FClassAncestor, "setChecked", "(Z)V"), _Abs(Value))
			#elseif 0
				SetChecked(Trim(Str(FHandle)) & "radio", Value)
			#endif
		End If
	End Property
	
	Private Sub RadioButton.HandleIsAllocated(ByRef Sender As Control)
	End Sub
	
	
	#ifdef __USE_WASM__
		Private Function RadioButton.GetContent() As UString
			Return "<input type=""radio"" id=""" & Trim(Str(@This)) & "radio"" name=""" & IIf(FParent, FParent->Name, "") & """ value=""" & *FName & """/>" & !"\r" & "<label for=""" & Trim(Str(@This)) & "radio"" id=""" & Trim(Str(@This)) & "label"">" & FText & "</label>"
		End Function
	#endif
	
	Private Sub RadioButton.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator RadioButton.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	#ifdef __USE_GTK__
		Private Sub RadioButton.RadioButton_Toggled(widget As GtkToggleButton Ptr, user_data As Any Ptr)
			Dim As RadioButton Ptr but = user_data
			If but->OnClick Then but->OnClick(*but->Designer, *but)
		End Sub
	#endif
	
	Private Constructor RadioButton
		With This
			.Child       = @This
			#ifdef __USE_GTK__
				widget = gtk_radio_button_new_with_label (NULL, "")
				g_signal_connect(widget, "toggled", G_CALLBACK(@RadioButton_Toggled), @This)
				.RegisterClass "RadioButton", @This
			#elseif 0
				.RegisterClass "RadioButton","Button"
				.ChildProc   = @WndProc
				.ExStyle     = 0
				.Style       = WS_CHILD Or BS_AUTORADIOBUTTON
				.BackColor       = GetSysColor(COLOR_BTNFACE)
				FDefaultBackColor = .BackColor
				.DoubleBuffered = True
				WLet(FClassAncestor, "Button")
			#elseif 0
				WLet(FClassAncestor, "android/widget/RadioButton")
			#elseif 0
				WLet(FClassAncestor, "div")
				FType = ""
				FElementStyle = "display: flex; align-items: center"
			#endif
			.OnHandleIsAllocated = @HandleIsAllocated
			FTabIndex          = -1
			FTabStop = True
			WLet(FClassName, "RadioButton")
			.Width       = 90
			.Height      = 17
		End With
	End Constructor
	
	Private Destructor RadioButton
	End Destructor
End Namespace
