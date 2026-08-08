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
			gtk_button_set_label(GTK_BUTTON(widget), ToUtf8(Value))
	End Property
	
	Private Property CheckBox.Checked As Boolean
		If FHandle Then
				FChecked = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(widget))
		End If
		Return FChecked
	End Property
	
	Private Property CheckBox.Checked(Value As Boolean)
		FChecked = Value
		If FHandle Then
				gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(widget), Value)
		End If
	End Property
	
	Private Sub CheckBox.HandleIsAllocated(ByRef Sender As Control)
	End Sub
	
	
	
	Private Sub CheckBox.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator CheckBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
		Private Sub CheckBox.CheckBox_Toggled(widget As GtkToggleButton Ptr, user_data As Any Ptr)
			Dim As CheckBox Ptr but = user_data
			If but->OnClick Then but->OnClick(*but->Designer, *but)
		End Sub
	
	Private Constructor CheckBox
		With This
			.Child                  = @This
				widget = gtk_check_button_new_with_label("")
				.RegisterClass "CheckBox", @This
				g_signal_connect(widget, "toggled", G_CALLBACK(@CheckBox_Toggled), @This)
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
