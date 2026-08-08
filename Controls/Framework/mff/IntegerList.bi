'###############################################################################
'#  IntegerList.bi                                                             #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TStringList.bi                                                            #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Adapted to Integer by Xusinboy Bekchanov (2018-2019)                       #
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

#include once "List.bi"

#define QIntegerListItem(__Ptr__) (*Cast(IntegerListItem Ptr,__Ptr__))
#define QIntegerList(__Ptr__) (*Cast(IntegerList Ptr,__Ptr__))

Private Type IntegerListItem Extends Object
Private:
	FValue   As Integer
Public:
	Declare Property Value As Integer
	Declare Property Value(V As Integer)
	Object  As Any Ptr
	Declare Operator Cast As Any Ptr
	Declare Operator Cast As String
	Declare Operator Let(V As Any Ptr)
	Declare Operator Let(V As Integer)
	Declare Constructor
	Declare Destructor
End Type

'Represents a list of integers that can be accessed by index. Provides methods to search, sort, and manipulate lists (Windows, Linux, Android, Web).
Private Type IntegerList Extends Object
Private:
	FCount   As Integer
	FItems   As List
Public:
	Declare Property Count As Integer
	Declare Property Count(Value As Integer)
	Declare Property Item(Index As Integer) As Integer
	Declare Property Item(Index As Integer, FItem As Integer)
	Declare Property Object(Index As Integer) As Any Ptr
	Declare Property Object(Index As Integer, FObj As Any Ptr)
	Declare Sub Add(iItem As Integer, Obj As Any Ptr = 0)
	Declare Sub Insert(Index As Integer, FItem As Integer, FObj As Any Ptr = 0)
	Declare Sub Exchange(Index1 As Integer, Index2 As Integer)
	Declare Sub Remove(Index As Integer)
	Declare Function Get(iItem As Integer, Obj As Any Ptr = 0) As Any Ptr
	Declare Sub Set(iItem As Integer, Obj As Any Ptr)
	Declare Sub Sort
	Declare Sub Clear
	Declare Function IndexOf(FItem As Integer) As Integer
	Declare Function IndexOfObject(FObj As Any Ptr) As Integer
	Declare Function Contains(FItem As Integer) As Boolean
	Declare Operator Cast As Any Ptr
	Declare Operator [](Index As Integer) As Integer
	Declare Constructor
	Declare Destructor
End Type

#ifndef __USE_MAKE__
	#include once "IntegerList.bas"
#endif
