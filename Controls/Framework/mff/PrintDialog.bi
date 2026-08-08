'################################################################################
'#  PrintDialog.bi                                                              #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Aloberoger, Xusinboy Bekchanov                                     #
'#  Based on:                                                                   #
'#   TPrintDialog.bi                                                            #
'#   GUITK-S Windows GUI FB Wrapper Library                                     #
'#   Copyright (c) Aloberoger                                                   #
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

#include once "Dialogs.bi"

'Lets users select a printer and choose which sections of the document to print from an application (Windows only).
Private Type PrintDialog Extends Dialog
Private:
	xLeft As Integer        = -1                        ' Default to center
	xTop As Integer         = -1
Public:
	Width As Integer                                    ' Not used
	Height As Integer                                   ' Not used
	Caption As String       = ""
	
	xSetupDialog As Integer = False                     ' SetupDialog or PrintDialog
	PrinterName As String
	AllowToFile As Integer      = True
	AllowToNetwork As Integer   = True
	ShowHelpButton As Integer   = False
	HelpFile As String      = ""
	FromPage As Integer     = 1
	ToPage As Integer       = 3
	
	'Declare Property Left() As Integer
	'Declare Property Left(value As Integer)
	'Declare Property Top() As Integer
	'Declare Property Top(value As Integer)
	Declare Property SetupDialog() As Integer
	Declare Property SetupDialog(value As Integer)
	
	Declare Function Execute() As Boolean
	Declare Constructor
	
End Type

#ifndef __USE_MAKE__
	#include once "PrintDialog.bas"
#endif
