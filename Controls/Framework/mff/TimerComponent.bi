'################################################################################
'#  TimerComponent.bi                                                           #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                     #
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

#include once "Component.bi"
#include once "IntegerList.bi"

Using My.Sys.ComponentModel

Dim Shared TimersList As IntegerList

Namespace My.Sys.Forms
	
	'A control which can execute code at regular intervals by causing a Timer event (Windows, Linux).
	Private Type TimerComponent Extends Component
	Private:
		FEnabled As Boolean
		FInterval As Integer
			Declare Static Function TimerProc(ByVal user_data As gpointer) As gboolean
	Public:
		ID            As Integer
		#ifndef ReadProperty_Off
			Declare Function ReadProperty(PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			Declare Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		#endif
		Declare Property Enabled As Boolean
		Declare Property Enabled(Value As Boolean)
		Declare Property Interval As Integer
		Declare Property Interval(Value As Integer)
		Declare Operator Cast As Any Ptr
		Declare Constructor
		Declare Destructor
		OnTimer As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "TimerComponent.bas"
#endif
