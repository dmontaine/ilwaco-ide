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
			For i As Integer = 0 To Value->ControlCount - 1
				If Value->Controls[i]->ClassName = "RadioButton" Then
						gtk_radio_button_join_group(GTK_RADIO_BUTTON(widget), GTK_RADIO_BUTTON(Value->Controls[i]->widget))
					Exit For
				End If
			Next
		Base.Parent = Value
	End Property
	Private Property RadioButton.Text ByRef As WString
		Return Base.Text
	End Property
	
	Private Property RadioButton.Text(ByRef Value As WString)
		Base.Text = Value
			gtk_label_set_text_with_mnemonic(GTK_LABEL(gtk_bin_get_child(GTK_BIN(widget))), ToUtf8(Replace(Value, "&", "_")))
	End Property
	
	Private Property RadioButton.Checked As Boolean
		If FHandle Then
				FChecked = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(widget))
		End If
		Return FChecked
	End Property
	
	Private Property RadioButton.Checked(Value As Boolean)
		FChecked = Value
		If FHandle Then
				gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(widget), Value)
		End If
	End Property
	
	Private Sub RadioButton.HandleIsAllocated(ByRef Sender As Control)
	End Sub
	
	
	
	Private Sub RadioButton.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator RadioButton.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
		Private Sub RadioButton.RadioButton_Toggled(widget As GtkToggleButton Ptr, user_data As Any Ptr)
			Dim As RadioButton Ptr but = user_data
			If but->OnClick Then but->OnClick(*but->Designer, *but)
		End Sub
	
	Private Constructor RadioButton
		With This
			.Child       = @This
				widget = gtk_radio_button_new_with_label (NULL, "")
				g_signal_connect(widget, "toggled", G_CALLBACK(@RadioButton_Toggled), @This)
				.RegisterClass "RadioButton", @This
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
