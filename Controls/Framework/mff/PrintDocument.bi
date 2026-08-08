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
#include once "Canvas.bi"
#include once "Printer.bi"
#include once "List.bi"

Namespace My.Sys.ComponentModel
	Type PrintDocumentPage Extends Object
		Canvas As My.Sys.Drawing.Canvas
		Declare Constructor
		Declare Destructor
	End Type
	
	Type PrintDocumentPages Extends Object
	Private:
		FItems As List
	Public:
		Declare Function Add(Index As Integer = -1) As PrintDocumentPage Ptr
		Declare Sub Clear
		Declare Function Contains(PageItem As PrintDocumentPage Ptr) As Boolean
		Declare Property Count As Integer
		Declare Function IndexOf(PageItem As PrintDocumentPage Ptr) As Integer
		Declare Function Insert(Index As Integer, PageItem As PrintDocumentPage Ptr) As PrintDocumentPage Ptr
		Declare Property Item(Index As Integer) As PrintDocumentPage Ptr
		Declare Property Item(Index As Integer, Value As PrintDocumentPage Ptr)
		Declare Sub Remove(Index As Integer)
		Declare Constructor
		Declare Destructor
	End Type
	
	'Defines a reusable object that sends output to a printer (Windows only).
	Type PrintDocument Extends Component
	Private:
	Public:
		#ifndef ReadProperty_Off
			Declare Function ReadProperty(PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			Declare Function WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		#endif
		DocumentName As UString
		Pages As PrintDocumentPages
		PrinterSettings As Printer
		Declare Sub Print
		Declare Sub Repaint
		OnPrintPage As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As PrintDocument, ByRef Canvas As My.Sys.Drawing.Canvas, ByRef HasMorePages As Boolean)
		Declare Constructor
		Declare Destructor
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "PrintDocument.bas"
#endif
