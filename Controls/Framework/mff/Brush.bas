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

#include once "Brush.bi"


Namespace My.Sys.Drawing
	#ifndef ReadProperty_Off
		Private Function Brush.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "color": Return @FColor
			Case "style": Return @FStyle
			Case "hatchstyle": Return @FHatchStyle
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Brush.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "color": This.Color = QInteger(Value)
			Case "style": This.Style = *Cast(BrushStyles Ptr, Value)
			Case "hatchstyle": This.HatchStyle = *Cast(HatchStyles Ptr, Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	#ifndef Brush_Color_Get_Off
		Private Property Brush.Color As Integer
			Return FColor
		End Property
	#endif
	
	Private Property Brush.Color(Value As Integer)
		FColor = Value
		Create
	End Property
	
	Private Property Brush.Style As BrushStyles
		Return FStyle
	End Property
	
	Private Property Brush.Style(Value As BrushStyles)
		FStyle = Value
		Create
	End Property
	
	Private Property Brush.HatchStyle As HatchStyles
		Return FHatchStyle
	End Property
	
	Private Property Brush.HatchStyle(Value As HatchStyles)
		FHatchStyle = Value
		Create
	End Property
	
	Private Sub Brush.Create
	End Sub
	
	
	Private Operator Brush.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor Brush
		FColor = &HFFFFFF
		FStyle = bsSolid
		'Create
		WLet(FClassName, "Brush")
	End Constructor
	
	Private Destructor Brush
	End Destructor
End Namespace
