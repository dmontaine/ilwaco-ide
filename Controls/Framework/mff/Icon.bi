'###############################################################################
'#  Icon.bi                                                                    #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TIcon.bi                                                                  #
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

#include once "Object.bi"
#include once "Bitmap.bi"
		#include once "gtk/gtk.bi"
			#include once "glib-object.bi"

Namespace My.Sys.Drawing
	'Represents a icon, which is a small bitmap image that is used to represent an object (Windows, Linux).
	Private Type Icon Extends My.Sys.Object
	Private:
		FWidth  As Integer
		FHeight As Integer
		FResName As WString Ptr
	Public:
		Graphic As Any Ptr
			Handle As GdkPixbuf Ptr
		Declare Function ReadProperty(ByRef PropertyName As String) As Any Ptr
		Declare Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		Declare Property ResName ByRef As WString
		Declare Property ResName(ByRef Value As WString)
		Declare Property Width As Integer
		Declare Property Width(Value As Integer)
		Declare Property Height As Integer
		Declare Property Height(Value As Integer)
		Declare Function LoadFromFile(ByRef File As WString, cx As Integer = 0, cy As Integer = 0) As Boolean
		Declare Function SaveToFile(ByRef File As WString) As Boolean
		Declare Function LoadFromResourceName(ByRef ResName As WString, ModuleHandle As Any Ptr = 0, cx As Integer = 0, cy As Integer = 0) As Boolean
		Declare Function LoadFromResourceID(ResID As Integer, ModuleHandle As Any Ptr = 0, cx As Integer = 0, cy As Integer = 0) As Boolean
		Declare Function ToString() ByRef As WString
		Declare Operator Cast As Any Ptr
		Declare Operator Cast As WString Ptr
		Declare Operator Let(ByRef Value As WString)
		Declare Operator Let(Value As Integer)
		Declare Operator Let(Value As Icon)
			Declare Operator Let(Value As GdkPixbuf Ptr)
		Declare Constructor
		Declare Destructor
		Changed As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Icon)
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "Icon.bas"
#endif
