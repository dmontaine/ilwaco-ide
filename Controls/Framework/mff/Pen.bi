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

#include once "Object.bi"

Namespace My.Sys.Drawing
		Private Enum PenStyle
			psSolid
			psDash
			psDot
			psDashDot
			psDashDotDot
			psClear
			psInsideFrame
		End Enum
		
		Private Enum PenMode
			pmBlack
			pmWhite
			pmNop
			pmNot
			pmCopy
			pmNotCopy
			pmMergePenNot
			pmMaskPenNot
			pmMergeNotPen
			pmMaskNotPen
			pmMerge
			pmNotMerge
			pmMask
			pmNotMask
			pmXor
			pmNotXor
		End Enum
	
	'Defines an object used to draw lines and curves (Windows only).
	Private Type Pen Extends My.Sys.Object
	Private:
		FColor  As Integer
		FStyle  As PenStyle
		FMode   As PenMode
		FSize   As Integer
		Declare Sub Create
	Public:
		Parent As My.Sys.Object Ptr
		#ifndef ReadProperty_Off
			Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		#endif
		Declare Property Color As ULong
		Declare Property Color(Value As ULong)
		Declare Property Style As PenStyle
		Declare Property Style(Value As PenStyle)
		Declare Property Mode As PenMode
		Declare Property Mode(Value As PenMode)
		Declare Property Size As Integer
		Declare Property Size(Value As Integer)
		Declare Operator Cast As Any Ptr
		OnCreate As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Pen)
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "Pen.bas"
#endif
