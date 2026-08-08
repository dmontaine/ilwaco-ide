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

Namespace My.Sys.Forms
	Type SystemInformation
	Private:
		FWidth As Integer
		FHeight As Integer
		Declare Static Function GetSize(iWidth As Integer, iHeight As Integer) As My.Sys.Drawing.Size
	Public:
		Declare Static Function DragSize As My.Sys.Drawing.Size
	   Declare Static Function ScreenWidth As Integer
       Declare Static Function ScreenHeight As Integer
       Declare Static Function MouseButtons As Integer
       Declare Static Function DoubleClickSize As My.Sys.Drawing.Size
       Declare Static Function WorkingArea As My.Sys.Drawing.Rect
       Declare Static Function BorderSize As My.Sys.Drawing.Size
       Declare Static Function MaxWindowTrackSize As My.Sys.Drawing.Size
		
	End Type
End Namespace

#include once "SystemInformation.bas"