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
#include once "Clipboard.bi"

'Provides methods to place data on and retrieve data from the system Clipboard.
Dim Shared As My.Sys.ClipboardType Clipboard
'pClipboard = @Clipboard

Namespace My.Sys
	Private Sub ClipboardType.Open
	End Sub
	
	Private Sub ClipboardType.Clear
			gtk_clipboard_clear(FClipboard)
	End Sub
	
	Private Sub ClipboardType.Close
	End Sub
	
	
	Private Sub ClipboardType.SetAsText(ByRef Value As WString)
			gtk_clipboard_set_text(FClipboard, ToUtf8(Value), -1)
	End Sub
	
	Private Function ClipboardType.GetAsText ByRef As WString
		Dim pGtkTxt As ZString Ptr = gtk_clipboard_wait_for_text(FClipboard)
		If pGtkTxt Then
		WLet(FText, *pGtkTxt)
  	              g_free(pGtkTxt)
   	         Else
    	            WLet(FText, "")
     	       End If
		If FText Then Return *FText Else Return ""
	End Function
	
	
	
	Private Property ClipboardType.FormatCount As Integer
			Return 0
	End Property
	
	Private Property ClipboardType.FormatCount(Value As Integer)
	End Property
	
	Private Property ClipboardType.Format ByRef As WString
		Dim s As String = Space(255)
		If FFormat > 0 Then Return *FFormat Else Return ""
	End Property
	
	Private Property ClipboardType.Format(ByRef Value As WString)
		WLet(FFormat, Value)
	End Property
	
	Private Constructor ClipboardType
			FClipboard = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD)
	End Constructor
	
	Private Destructor ClipboardType
		If FText Then _Deallocate( FText)
		If FFormat Then _Deallocate(FFormat)
	End Destructor
End Namespace