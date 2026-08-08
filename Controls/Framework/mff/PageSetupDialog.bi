'################################################################################
'#  PageSetupDialog.bi                                                          #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Aloberoger, Xusinboy Bekchanov                                     #
'#  Based on:                                                                   #
'#   TPageSetupDLG.bi                                                           #
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
#include once "Printer.bi"

'Enables users to change page-related print settings, including margins and paper orientation (Windows only).
Private Type PageSetupDialog Extends Dialog
Private:
	xLeft As Integer        = -1                        ' Default to center
	xTop As Integer         = -1                        ' ditto
	xWidth As Integer                                    ' Not used
	xHeight As Integer                                   ' Not used
	xPrinterName As String
Public:
	Caption As String       = ""
	
	Metric As Integer       = True                      ' mm (True) or inches?
	Orientation As PrinterOrientation
	PaperWidth As Single                                ' Converted to mm: ptPaperSize AS POINT (in 100ths of mm)
	PaperHeight As Single
	PaperSize As PrinterPaperSize
	MinLeftMargin As Single                             '|
	MinTopMargin As Single                              '| rtMinMargin AS RECT
	MinRightMargin As Single                            '| Converted to mm
	MinBottomMargin As Single                           '|
	LeftMargin As Single                                '|
	TopMargin As Single                                 '| rtMargin AS RECT
	RightMargin As Single                               '| Converted to mm
	BottomMargin As Single                              '|
	
	'Declare Property Left() As Integer
	'Declare Property Left(value As Integer)
	Declare Property PrinterName() As String
	Declare Property PrinterName(value As String)
	'Declare Property Top() As Integer
	'Declare Property Top(value As Integer)
	
	Declare Function Execute() As Boolean
	Declare Constructor
End Type

#ifndef __USE_MAKE__
	#include once "PageSetupDialog.bas"
#endif
