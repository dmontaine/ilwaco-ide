'################################################################################
'#  PageSetupDialog.bas                                                         #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Aloberoger, Xusinboy Bekchanov                                     #
'#  Based on:                                                                   #
'#   TPageSetupDLG.bas                                                          #
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

#include once "PageSetupDialog.bi"

'Property PageSetupDialog.Left() As Integer: Return xLeft: End Property
'Property PageSetupDialog.Left(value As Integer): xLeft=value: End Property
Private Property PageSetupDialog.PrinterName() As String: Return xPrinterName: End Property
Private Property PageSetupDialog.PrinterName(value As String): End Property            ' Read only
'Property PageSetupDialog.Top() As Integer: Return xTop: End Property
'Property PageSetupDialog.Top(value As Integer): xTop=value: End Property


Private Function PageSetupDialog.Execute() As Boolean
	Return False
End Function

Private Constructor PageSetupDialog
	WLet(FClassName, "PageSetupDialog")
	Orientation = PrinterOrientation.poPortait
	LeftMargin = 30
	TopMargin = 20
	RightMargin = 15
	BottomMargin = 20
	PaperWidth = 297
	PaperHeight = 210
	PaperSize = PrinterPaperSize.ppsA4
End Constructor
