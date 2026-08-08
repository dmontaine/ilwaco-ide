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

#include once "ContainerControl.bi"

Namespace My.Sys.Forms
	#define QScrollControl(__Ptr__) (*Cast(ScrollControl Ptr, __Ptr__))
	
	'Defines a class that support auto-scrolling behavior (Windows, Linux).
	Private Type ScrollControl Extends ContainerControl
	Private:
		OldClientHeight As Integer
		OldClientWidth As Integer
		OldMaxHeight As Integer
		OldMaxWidth As Integer
		InRecalculate As Boolean
			
	Protected:
		Dim As Integer FHorizontalArrowChangeSize
		Dim As Integer FVerticalArrowChangeSize
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
	Public:
		#ifndef ReadProperty_Off
			Declare Function ReadProperty(PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			Declare Function WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		#endif
		Declare Property TabIndex As Integer
		Declare Property TabIndex(Value As Integer)
		Declare Property TabStop As Boolean
		Declare Property TabStop(Value As Boolean)
		Declare Sub Add(Ctrl As Control Ptr, Index As Integer = -1)
		Declare Sub RecalculateScrollBars
		Declare Operator Cast As Control Ptr
		Declare Constructor
		Declare Destructor
		OnScroll As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ScrollControl)
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "ScrollControl.bas"
#endif
