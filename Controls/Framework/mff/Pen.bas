'###############################################################################
'#  Pen.bi                                                                     #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TPen.bi                                                                   #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Modified by Xusinboy Bekchanov (2018-2019)                                 #
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

#include once "Pen.bi"

Namespace My.Sys.Drawing
	#ifndef ReadProperty_Off
		Private Function Pen.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "color": Return @FColor
			Case "style": Return @FStyle
			Case "mode": Return @FMode
			Case "size": Return @FSize
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Pen.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "color": This.Color = QInteger(Value)
			Case "style": This.Style = *Cast(PenStyle Ptr, Value)
			Case "mode": This.Mode = *Cast(PenMode Ptr, Value)
			Case "size": This.Size = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	#ifndef Pen_Color_Get_Off
		Private Property Pen.Color As ULong
			Return FColor
		End Property
	#endif
	
	#ifndef Pen_Color_Set_Off
		Private Property Pen.Color(Value As ULong)
			FColor = Value
			Create
		End Property
	#endif
	
	Private Property Pen.Style As PenStyle
		Return FStyle
	End Property
	
	Private Property Pen.Style(Value As PenStyle)
		FStyle = Value
		Create
	End Property
	
	Private Property Pen.Mode As PenMode
		Return FMode
	End Property
	
	Private Property Pen.Mode(Value As PenMode)
		FMode = Value
		Create
	End Property
	
	Private Property Pen.Size As Integer
		Return FSize
	End Property
	
	#ifndef Pen_Size_Set_Off
		Private Property Pen.Size(Value As Integer)
			FSize = Value
			Create
		End Property
	#endif
	
	#ifndef Pen_Create_Off
		Private Sub Pen.Create
		End Sub
	#endif
	
	Private Operator Pen.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor Pen
		FSize  = 1
		FColor = 0
		FMode  = pmCopy
		FStyle = psSolid
		'Create
		WLet(FClassName, "Pen")
	End Constructor
	
	Private Destructor Pen
	End Destructor
End Namespace
