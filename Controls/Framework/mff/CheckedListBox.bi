'###############################################################################
'#  CheckedListBox.bi                                                          #
'#  This file is part of MyFBFramework                                         #
'#  Based on:                                                                  #
'#   TListBox.bi                                                               #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Modified by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                      #
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

#include once "ListControl.bi"

Namespace My.Sys.Forms
	#define QCheckedListBox(__Ptr__) (*Cast(CheckedListBox Ptr,__Ptr__))
	
	'`CheckedListBox` is a Control within the MyFbFramework, part of the freeBasic framework.
	'`CheckedListBox` - Displays a ListBox in which a check box is displayed to the left of each item (Windows, Linux).
	Private Type CheckedListBox Extends ListControl
	Private:
		FRadioCheck As Boolean
			As GtkCellRenderer Ptr rendertoggle
	Protected:
			Declare Static Sub Check(cell As GtkCellRendererToggle Ptr, path As gchar Ptr, model As GtkListStore Ptr)
	Public:
		#ifndef ReadProperty_Off
			'Loads persisted check states
			Declare Virtual Function ReadProperty(PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			'Persists check states to storage
			Declare Virtual Function WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		#endif
		'Gets/Sets checked state of specific item
		Declare Property Checked(Index As Integer) As Boolean
		'Gets/Sets checked state of specific item
		Declare Property Checked(Index As Integer, Value As Boolean)
		Declare Property RadioCheck As Boolean
		'Uses radio buttons instead of checkboxes
		Declare Property RadioCheck(Value As Boolean)
		'Adds new item with check state
		Declare Sub AddItem(ByRef FItem As WString, Obj As Any Ptr = 0)
		'Inserts checked item at position
		Declare Sub InsertItem(FIndex As Integer, ByRef FItem As WString, Obj As Any Ptr = 0)
		'Saves items with check states to file
		Declare Sub SaveToFile(ByRef FileName As WString)
		'Loads items with check states from file
		Declare Sub LoadFromFile(ByRef FileName As WString)
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "CheckedListBox.bas"
#endif
