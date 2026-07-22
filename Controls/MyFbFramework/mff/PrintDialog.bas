'################################################################################
'#  PrintDialog.bas                                                             #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Aloberoger, Xusinboy Bekchanov                                     #
'#  Based on:                                                                   #
'#   TPrintDialog.bas                                                           #
'#   GUITK-S Windows GUI FB Wrapper Library                                     #
'#   Copyright (c) Aloberoger                                                   #
'################################################################################

#include once "PrintDialog.bi"

'Property PrintDialog.Left() As Integer: Return xLeft: End Property
'Property PrintDialog.Left(value As Integer): xLeft=value: End Property
'Property PrintDialog.Top() As Integer: Return xTop: End Property
'Property PrintDialog.Top(value As Integer): xTop=value: End Property
Private Property PrintDialog.SetupDialog() As Integer: Return xSetupDialog: End Property
Private Property PrintDialog.SetupDialog(value As Integer)
	If value Then xSetupDialog=True Else xSetupDialog=False
End Property

' Handles either a Print Setup dialog or Printer dialog
Private Function PrintDialog.Execute() As Boolean
	Return False
End Function

Private Constructor PrintDialog
	WLet(FClassName, "PrintDialog")
End Constructor
