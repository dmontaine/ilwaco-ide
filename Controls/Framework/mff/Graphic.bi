'###############################################################################
'#  Graphic.bi                                                                 #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TGraphic.bi                                                               #
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

#include once "Control.bi"

Namespace My.Sys.Drawing
	Private Enum ImageTypes
		Bitmap = 0
		Icon = 0
		Cursor = 0
	End Enum
	
	Private Enum StretchMode
		smNone, smStretch, smStretchProportional
	End Enum
	
	#define QGraphic(__Ptr__) (*Cast(GraphicType Ptr,__Ptr__))
	
	'A class that provides functionality for the Bitmap, Icon and Cursor descended classes (Windows, Linux, Web).
	Private Type GraphicType Extends My.Sys.Object
	Private:
		FResName As WString Ptr
		Declare Static Sub BitmapChanged(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.BitmapType)
		Declare Static Sub IconChanged(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Icon)
		Declare Static Sub CursorChanged(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Cursor)
	Public:
		Ctrl         As My.Sys.Forms.Control Ptr
		Bitmap       As My.Sys.Drawing.BitmapType
		Icon         As My.Sys.Drawing.Icon
		Cursor       As My.Sys.Drawing.Cursor
		Image        As Any Ptr
		ImageType    As ImageTypes
		StretchImage As StretchMode
		CenterImage  As Boolean
		Visible      As Boolean = True
		ScaleFactor  As Double  = 1
		StartX       As Integer
		StartY       As Integer
		#ifndef ReadProperty_Off
			Declare Virtual Function ReadProperty(PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		#endif
		Declare Function ToString() ByRef As WString
		Declare Function LoadFromFile(ByRef File As WString, cxDesired As Integer = 0, cyDesired As Integer = 0) As Boolean
		Declare Function SaveToFile(ByRef File As WString) As Boolean
		Declare Function LoadFromResourceID(ResID As Integer, ModuleHandle As Any Ptr = 0, cxDesired As Integer = 0, cyDesired As Integer = 0) As Boolean
		Declare Function LoadFromResourceName(ResName As String, ModuleHandle As Any Ptr = 0, cxDesired As Integer = 0, cyDesired As Integer = 0) As Boolean 'David Change
		Declare Constructor
		Declare Destructor
		Declare Operator Let(ByRef Value As WString)
		Declare Operator Let(ByRef Value As My.Sys.Drawing.BitmapType)
		Declare Operator Let(ByRef Value As My.Sys.Drawing.Icon)
		Declare Operator Let(ByRef Value As My.Sys.Drawing.Cursor)
		OnChange As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As GraphicType, Image As Any Ptr, ImageType As Integer)
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "Graphic.bas"
#endif
