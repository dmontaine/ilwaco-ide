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

#include once "ContainerControl.bi"
'#Include Once "Canvas.bi"

Namespace My.Sys.Forms
	#define QUserControl(__Ptr__) (*Cast(UserControl Ptr,__Ptr__))
	
	'Provides an empty control that can be used to create other controls. A Control authored in VisualFBEditor (Windows, Linux).
	Private Type UserControl Extends ContainerControl
	Private:
	Public:
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
		'Canvas        As My.Sys.Drawing.Canvas
		Declare Operator Cast As Control Ptr
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "UserControl.bas"
#endif
