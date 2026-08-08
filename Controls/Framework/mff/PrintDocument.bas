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
#include once "PrintDocument.bi"

Namespace My.Sys.ComponentModel
	#ifndef ReadProperty_Off
		Private Function PrintDocument.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "documentname": Return DocumentName.vptr
			Case "printersettings": Return @PrinterSettings
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function PrintDocument.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "documentname": DocumentName = QWString(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Constructor PrintDocumentPage
		WLet(FClassName, "PrintDocumentPage")
	End Constructor
	
	Private Destructor PrintDocumentPage
	End Destructor
	
	Private Function PrintDocumentPages.Add(Index As Integer = -1) As PrintDocumentPage Ptr
		Dim As PrintDocumentPage Ptr NewPage = _New(PrintDocumentPage)
		If Index > -1 Then
			FItems.Insert Index, NewPage
		Else
			FItems.Add NewPage
		End If
		Return NewPage
	End Function
	
	Private Sub PrintDocumentPages.Clear
		For i As Integer = Count - 1 To 0 Step -1
			_Delete(Cast(PrintDocumentPage Ptr, FItems.Items[i]))
		Next i
		FItems.Clear
	End Sub
	
	Private Property PrintDocumentPages.Count As Integer
		Return FItems.Count
	End Property
	
	Private Function PrintDocumentPages.Contains(PageItem As PrintDocumentPage Ptr) As Boolean
		Return IndexOf(PageItem) <> -1
	End Function
	
	Private Function PrintDocumentPages.IndexOf(PageItem As PrintDocumentPage Ptr) As Integer
		Return FItems.IndexOf(PageItem)
	End Function
	
	Private Function PrintDocumentPages.Insert(Index As Integer, PageItem As PrintDocumentPage Ptr) As PrintDocumentPage Ptr
		FItems.Insert(Index, PageItem)
		Return PageItem
	End Function
	
	Private Property PrintDocumentPages.Item(Index As Integer) As PrintDocumentPage Ptr
		Return Cast(PrintDocumentPage Ptr, FItems.Item(Index))
	End Property
	
	Private Property PrintDocumentPages.Item(Index As Integer, Value As PrintDocumentPage Ptr)
		FItems.Item(Index) = Value
	End Property
	
	Private Sub PrintDocumentPages.Remove(Index As Integer)
		_Delete(Item(Index))
		FItems.Remove Index
	End Sub
	
	Private Constructor PrintDocumentPages
		This.Clear
	End Constructor
	
	Private Destructor PrintDocumentPages
		This.Clear
	End Destructor
	
	
	Private Sub PrintDocument.Print
		If PrinterSettings.Name = "" Then
			If PrinterSettings.ChoosePrinter() = "" Then
				Return
			End If
		End If
		
		If PrinterSettings.Handle = 0 Then Return
		
	End Sub
	
	Private Sub PrintDocument.Repaint
		Dim As Boolean HasMorePages
		Pages.Clear
		Do
			HasMorePages = False
			Dim As PrintDocumentPage Ptr NewPage = Pages.Add
			NewPage->Canvas.HandleSetted = True
			If OnPrintPage Then OnPrintPage(*Designer, This, NewPage->Canvas, HasMorePages)
			NewPage->Canvas.Handle = 0
			NewPage->Canvas.HandleSetted = False
		Loop While HasMorePages
	End Sub
	
	Constructor PrintDocument
		WLet(FClassName, "PrintDocument")
		PrinterSettings.Name = PrinterSettings.DefaultPrinter
	End Constructor
	
	Destructor PrintDocument
	End Destructor
End Namespace
