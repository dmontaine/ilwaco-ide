'################################################################################
'#  SearchBox.bi                                                                #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2024)                                          #
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

#include once "TextBox.bi"
#include once "Panel.bi"

Namespace My.Sys.Forms
	#define QSearchBox(__Ptr__) (*Cast(SearchBox Ptr, __Ptr__))
	
	'`SearchBox` is a Control within the MyFbFramework, part of the freeBasic framework.
	'`SearchBox` - The SearchBar is a control made to have a search entry (Windows, Linux).
	Private Type SearchBox Extends TextBox
	Private:
	Protected:
		Declare Virtual Sub ProcessMessage(ByRef message As Message)
	Public:
		#ifndef ReadProperty_Off
			'Deserializes from persistence stream
			Declare Virtual Function ReadProperty(PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			'Serializes to persistence stream
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		#endif
		Declare Property TabIndex As Integer
		'Controls focus order in tab sequence
		Declare Property TabIndex(Value As Integer)
		Declare Property TabStop As Boolean
		'Determines if control accepts focus via Tab key
		Declare Property TabStop(Value As Boolean)
		Declare Operator Cast As My.Sys.Forms.Control Ptr
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "SearchBox.bas"
#endif
