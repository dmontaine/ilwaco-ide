'################################################################################
'#  Brush.bi                                                                    #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   TBrush.bi                                                                  #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#   Version 1.0.0                                                              #
'#  Modified by Xusinboy Bekchanov (2018-2019), Liu XiaLin (2020)               #
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

#include once "Object.bi"

	Dim Shared As Integer darkBkColorTitle = BGR(10, 10, 10) 
	Dim Shared As Integer darkBkColorMenu = BGR(41, 41, 41)
	Dim Shared As Integer darkBkColorGreen = BGR(55, 166, 96)
	Dim Shared As Integer darkBkColorBlue = BGR(89, 143, 236)
	Dim Shared As Integer darkBkColor = &H303030
	Dim Shared As Integer darkBkColorDark =&H414141
	Dim Shared As Integer darkHlBkColor = &H626262
	Dim Shared As Integer darkTextColor = BGR(255, 255, 255) 

Namespace My.Sys.Drawing
		Private Enum BrushStyles
			bsSolid
			bsClear
			bsHatch
			bsPattern
		End Enum
		
		Private Enum HatchStyles
			hsHorizontal
			hsVertical
			hsFDiagonal
			hsDiagonal
			hsCross
			hsDiagCross
		End Enum
	
	'Defines objects used to fill the interiors of graphical shapes such as rectangles, ellipses, pies, polygons, and paths (Windows only).
	Private Type Brush Extends My.Sys.Object
	Private:
		FColor       As Integer
		FStyle       As BrushStyles
		FHatchStyle  As HatchStyles
		Declare Sub Create
	Public:
		Parent As My.Sys.Object Ptr
		#ifndef ReadProperty_Off
			Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		#endif
		Declare Property Color As Integer
		Declare Property Color(Value As Integer)
		Declare Property Style As BrushStyles
		Declare Property Style(Value As BrushStyles)
		Declare Property HatchStyle As HatchStyles
		Declare Property HatchStyle(Value As HatchStyles)
		Declare Operator Cast As Any Ptr
		OnCreate As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Brush)
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "Brush.bas"
#endif
