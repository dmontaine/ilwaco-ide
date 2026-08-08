'################################################################################
'#  PrintDialog.bas                                                             #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Aloberoger, Xusinboy Bekchanov                                     #
'#  Based on:                                                                   #
'#   TPrintDialog.bas                                                           #
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
