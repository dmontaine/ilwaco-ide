'################################################################################
'#  PageSetupDialog.bas                                                         #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Aloberoger, Xusinboy Bekchanov                                     #
'#  Based on:                                                                   #
'#   TPageSetupDLG.bas                                                          #
'#   GUITK-S Windows GUI FB Wrapper Library                                     #
'#   Copyright (c) Aloberoger                                                   #
'################################################################################

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
