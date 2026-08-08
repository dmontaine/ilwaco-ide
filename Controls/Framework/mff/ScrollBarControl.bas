'###############################################################################
'#  ScrollBarControl.bi                                                        #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TScrollBar.bi                                                             #
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

#include once "ScrollBarControl.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function ScrollBarControl.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "arrowchangesize": Return @This.FArrowChangeSize
			Case "maxvalue": Return @This.FMax
			Case "minvalue": Return @This.FMin
			Case "pagesize": Return @This.FPageSize
			Case "position": Return @This.FPosition
			Case "style": Return @This.FStyle
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function ScrollBarControl.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "arrowchangesize": This.ArrowChangeSize = QInteger(Value)
			Case "maxvalue": This.MaxValue = QInteger(Value)
			Case "minvalue": This.MinValue = QInteger(Value)
			Case "pagesize": This.PageSize = QInteger(Value)
			Case "position": This.Position = QInteger(Value)
			Case "style": This.Style = *Cast(ScrollBarControlStyle Ptr, Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property ScrollBarControl.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property ScrollBarControl.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property ScrollBarControl.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property ScrollBarControl.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property ScrollBarControl.Style As ScrollBarControlStyle
		Return FStyle
	End Property
	
	Private Property ScrollBarControl.Style(Value As ScrollBarControlStyle)
		Dim As ScrollBarControlStyle OldStyle
		Dim As Integer iWidth, iHeight
		OldStyle = FStyle
		If Value <> FStyle Then
			If OldStyle = sbHorizontal Then
				iHeight = Height
				iWidth = This.Width
					gtk_orientable_set_orientation(gtk_orientable(widget), GTK_ORIENTATION_VERTICAL)
				Height = iWidth
				This.Width  = iHeight
			Else
				iWidth = This.Width
				iHeight = Height
					gtk_orientable_set_orientation(GTK_ORIENTABLE(widget), GTK_ORIENTATION_HORIZONTAL)
				This.Width = iHeight
				Height  = iWidth
			End If
			FStyle = Value
			If This.Parent Then This.Parent->RequestAlign
		End If
	End Property
	
	Private Property ScrollBarControl.MinValue As Integer
		Return FMin
	End Property
	
	Private Property ScrollBarControl.MinValue(Value As Integer)
		FMin = Value
			gtk_range_set_range(GTK_RANGE(widget), FMin, FMax)
	End Property
	
	Private Property ScrollBarControl.MaxValue As Integer
		Return FMax
	End Property
	
	Private Property ScrollBarControl.MaxValue(Value As Integer)
		FMax = Value
			gtk_range_set_range(GTK_RANGE(widget), FMin, FMax)
	End Property
	
	Private Property ScrollBarControl.Position As Integer
			FPosition = gtk_range_get_value(GTK_RANGE(widget))
		Return FPosition
	End Property
	
	Private Property ScrollBarControl.Position(Value As Integer)
		FPosition = Value
			gtk_range_set_value(GTK_RANGE(widget), CDbl(Value))
		If OnScroll Then OnScroll(*Designer, This, FPosition)
	End Property
	
	Private Property ScrollBarControl.ArrowChangeSize As Integer
		Return FArrowChangeSize
	End Property
	
	Private Property ScrollBarControl.ArrowChangeSize(Value As Integer)
		FArrowChangeSize = Value
			gtk_range_set_increments(GTK_RANGE(widget), FArrowChangeSize, FPageSize)
	End Property
	
	Private Property ScrollBarControl.PageSize As Integer
		Return FPageSize
	End Property
	
	Private Property ScrollBarControl.PageSize(Value As Integer)
		If FPageSize > FMax Or Value = FPageSize Then Exit Property
		FPageSize = Value
			gtk_range_set_increments(GTK_RANGE(widget), FArrowChangeSize, FPageSize)
	End Property
	
	
	Private Sub ScrollBarControl.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator ScrollBarControl.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
		Private Sub ScrollBarControl.Range_ValueChanged(range As GtkRange Ptr, user_data As Any Ptr)
			Dim As ScrollBarControl Ptr scr = user_data
			If scr->OnScroll Then scr->OnScroll(*scr->Designer, *scr, gtk_range_get_value(range))
		End Sub
	
	Private Constructor ScrollBarControl
				widget = gtk_scrollbar_new(GTK_ORIENTATION_HORIZONTAL, NULL)
			g_signal_connect(widget, "value-changed", G_CALLBACK(@Range_ValueChanged), @This)
			This.RegisterClass "ScrollBarControl", @This
		MaxValue        = 100
		MinValue        = 0
		Position        = 0
		ArrowChangeSize = 1
		PageSize        = 3
		FTabIndex       = -1
		With This
			.Child      = @This
			WLet(FClassName, "ScrollBarControl")
			WLet(FClassAncestor, "ScrollBar")
			.Width      = 121
			.Height     = 17
		End With
	End Constructor
	
	Private Destructor ScrollBarControl
	End Destructor
End Namespace
