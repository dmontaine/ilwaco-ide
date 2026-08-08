'###############################################################################
'#  ListItems.bi                                                               #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor                                                     #
'#  Based on:                                                                  #
'#   TListItems.bi                                                             #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
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

#include once "WStringList.bi"
'#include once "Control.bi"

#define QListItems(__Ptr__) (*Cast(ListItems Ptr,__Ptr__))

Private Type ListItems Extends Object
Private:
	FItems As WStringList
Public:
	'Parent   As My.Sys.Forms.Control Ptr
	Declare Property Count As Integer
	Declare Property Count(Value As Integer)
	Declare Property Text ByRef As WString
	Declare Property Text(ByRef Value As WString)
	Declare Property Item(Index As Integer) ByRef As WString
	Declare Property Item(Index As Integer, ByRef Value As WString)
	Declare Property Object(Index As Integer) As Any Ptr
	Declare Property Object(Index As Integer, Value As Any Ptr)
	Declare Sub Add(ByRef FString As WString, FData As Any Ptr = 0)
	Declare Sub Insert(FIndex As Integer, ByRef FString As WString, FData As Any Ptr = 0)
	Declare Sub Remove(FIndex As Integer)
	Declare Sub Exchange(FIndex1 As Integer, FIndex2 As Integer)
	Declare Sub Sort
	Declare Sub Clear
	Declare Sub SaveToFile(ByRef File As WString)
	Declare Sub LoadFromFile(ByRef File As WString)
	Declare Function IndexOf(ByRef FString As WString) As Integer
	Declare Function IndexOfObject(FData As Any Ptr) As Integer
	Declare Function Contains(ByRef FString As WString) As Boolean
	Declare Operator Cast As Any Ptr
	Declare Constructor
	Declare Destructor
End Type

#ifndef __USE_MAKE__
	#include once "ListItems.bas"
#endif
