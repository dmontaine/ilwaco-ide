'###############################################################################
'#  ContainerControl.bi                                                        #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                    #
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
	#define QContainerControl(__Ptr__) (*Cast(ContainerControl Ptr,__Ptr__))
	
	'Provides the base class for the containers (Windows, Linux, Android, Web).
	Private Type ContainerControl Extends Control
	Private:
	Protected:
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
	Public:
			'Function registers a window class for subsequent use in calls to the create window (Windows, Linux)
			Declare Function RegisterClass(ByRef wClassName As WString, Obj As Any Ptr, WndProcAddr As Any Ptr = 0) As Boolean
		#ifndef ReadProperty_Off
			'Reads value from the name of property (Windows, Linux, Android, Web).
			Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			'Writes value to the name of property (Windows, Linux, Android, Web).
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		#endif
		'Determines whether a control is automatically resized to display its entire contents (Windows, Linux).
		Declare Virtual Property AutoSize As Boolean
		Declare Virtual Property AutoSize(Value As Boolean)
		'Returns/sets a value that determines whether an object is visible or hidden (Windows, Linux, Web).
		Declare Virtual Property Visible As Boolean
		Declare Virtual Property Visible(Value As Boolean)
		Declare Operator Cast As Control Ptr
		Declare Operator Cast As Any Ptr
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

#ifdef __EXPORT_PROCS__
	Declare Function ControlIsContainer Alias "ControlIsContainer"(Ctrl As My.Sys.Forms.Control Ptr) As Boolean
#endif

#ifndef __USE_MAKE__
	#include once "ContainerControl.bas"
#endif
