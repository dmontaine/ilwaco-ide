'###############################################################################
'#  Splitter.bi                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TSplitter.bi                                                              #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
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

Namespace My.Sys.Forms
	#define QSplitter(__Ptr__) (*Cast(Splitter Ptr, __Ptr__))
	
	Private Enum SplitterAlignmentConstants
		alNone
		alLeft
		alRight
		alTop
		alBottom
	End Enum
	
	'`Splitter` is a Control within the MyFbFramework, part of the freeBasic framework.
	'`Splitter` - Represents a splitter control that enables the user to resize docked controls (Windows, Linux).
	Private Type Splitter Extends Control
	Private:
		FOldParentProc  As Any Ptr
			Declare Static Function OnDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As gpointer) As Boolean
			Declare Static Function OnExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As gpointer) As Boolean
	Protected:
		Declare Sub DrawTrackSplit(x As Integer, y As Integer)
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
	Public:
		#ifndef ReadProperty_Off
			'Deserializes properties from persistence stream
			Declare Function ReadProperty(PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			'Serializes properties to persistence stream
			Declare Function WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		#endif
			Dim As Boolean bCursor
		'Sets minimum space required on both sides of the splitter
		MinExtra As Integer
		Declare Operator Cast As Control Ptr
		Declare Property Align As SplitterAlignmentConstants
		'Determines splitter orientation and docking behavior (Left/Right/Top/Bottom)
		Declare Property Align(Value As SplitterAlignmentConstants)
		'Allows custom splitter appearance rendering
		OnPaint As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Splitter)
		'Raised during active resizing operations
		OnMoving As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Splitter)
		'Triggered after splitter completes resizing
		OnMoved As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Splitter)
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "Splitter.bas"
#endif
