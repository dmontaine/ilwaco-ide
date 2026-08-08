'################################################################################
'#  UserControl.bi                                                              #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov                                                 #
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

#include once "UserControl.bi"
'#Include Once "Canvas.bi"

Namespace My.Sys.Forms
	Private Sub UserControl.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator UserControl.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor UserControl
		With This
				widget = gtk_layout_new(NULL, NULL)
				.RegisterClass "UserControl", @This
			Canvas.Ctrl    = @This
			.Child       = @This
			WLet(FClassName, "UserControl")
			.Width       = 121
			.Height      = 41
		End With
	End Constructor
	
	Private Destructor UserControl
	End Destructor
End Namespace
