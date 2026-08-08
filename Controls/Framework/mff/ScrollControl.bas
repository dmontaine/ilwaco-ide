'###############################################################################
'#  ScrollControl.bi                                                           #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov                                                #
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

#include once "ScrollControl.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function ScrollControl.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function ScrollControl.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "tabindex": TabIndex = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property ScrollControl.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property ScrollControl.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property ScrollControl.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property ScrollControl.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Sub ScrollControl.RecalculateScrollBars
	End Sub
	
	
	Private Sub ScrollControl.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Sub ScrollControl.Add(Ctrl As Control Ptr, Index As Integer = -1)
		Base.Add(Ctrl, Index)
	End Sub
	
	Private Operator ScrollControl.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor ScrollControl
			widget = gtk_scrolled_window_new(NULL, NULL)
			gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(widget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
			'g_signal_connect(widget, "value-changed", G_CALLBACK(@Range_ValueChanged), @This)
			This.RegisterClass "ScrollControl", @This
		FTabIndex       = -1
		With This
			.Child      = @This
			WLet(FClassName, "ScrollControl")
			FHorizontalArrowChangeSize = 10
			FVerticalArrowChangeSize = 10
			.Width      = 121
			.Height     = 41
		End With
	End Constructor
	
	Private Destructor ScrollControl
	End Destructor
End Namespace
