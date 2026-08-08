'###############################################################################
'#  GroupBox.bi                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TGroupBox.bi                                                              #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
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

#include once "GroupBox.bi"

Namespace My.Sys.Forms
	Property GroupBox.Caption ByRef As WString
		Return Text
	End Property
	
	Property GroupBox.Caption(ByRef Value As WString)
		Text = Value
	End Property
	
	Property GroupBox.Text ByRef As WString
			FText = WStr(gtk_frame_get_label(GTK_FRAME(widget)))
			Return *FText.vptr
	End Property
	
	Property GroupBox.Text(ByRef Value As WString)
			If widget Then gtk_frame_set_label(GTK_FRAME(widget), ToUtf8(Value))
	End Property
	
	Property GroupBox.ParentColor As Boolean
		Return FParentColor
	End Property
	
	Property GroupBox.ParentColor(Value As Boolean)
		FParentColor = Value
		If FParentColor Then
			This.BackColor = This.Parent->BackColor
			Invalidate
		End If
	End Property
	
	
	Sub GroupBox.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Operator GroupBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Constructor GroupBox
		With This
			.Child       = @This
				widget = gtk_frame_new("")
				.RegisterClass "GroupBox", @This
			WLet(FClassName, "GroupBox")
			WLet(FClassAncestor, "Button")
			FTabStop           = True
			.Width       = 121
			.Height      = 51
		End With
	End Constructor
	
	Destructor GroupBox
	End Destructor
End Namespace
