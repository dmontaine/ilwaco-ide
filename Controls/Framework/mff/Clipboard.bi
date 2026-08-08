'******************************************************************************
'* ClipboardType
'* This file is part of MyFBFramework
'* Based on:
'*  TClipboard
'*  FreeBasic Windows GUI ToolKit
'*  Copyright (c) 2007-2008 Nastase Eodor
'*  nastase_eodor@yahoo.com
'* Updated and added cross-platform
'* by Xusinboy Bekchanov (2018-2019)
'******************************************************************************
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

Namespace My.Sys
	'Provides static methods that facilitate transferring data to and from the system Clipboard (Windows, Linux).
	Private Type ClipboardType
	Private:
		FFormatCount As Integer
		FFormat      As WString Ptr
		FText        As WString Ptr
			FClipboard As GtkClipboard Ptr
	Public:
		Declare Sub Open
		Declare Sub Clear
		Declare Sub Close
		Declare Sub SetAsText(ByRef Value As WString)
		Declare Function GetAsText ByRef As WString
		Declare Property FormatCount As Integer
		Declare Property FormatCount(Value As Integer)
		Declare Property Format ByRef As WString
		Declare Property Format(ByRef Value As WString)
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

'Common Shared As My.Sys.ClipboardType Ptr pClipboard

#ifndef __USE_MAKE__
	#include once "Clipboard.bas"
#endif
