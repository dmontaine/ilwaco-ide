'###############################################################################
'#  Sys.bi                                                                     #
'#  This file is part of MyFBFramework                                         #
'#  Authors: José Roca (2016), Xusinboy Bekchanov                              #
'#  Windows version functions based on WinFBX/Afx/AfxWin.inc                   #
'###############################################################################
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

	#include once "crt/locale.bi"

Namespace My
	Namespace Sys
		Private Function Name As String
				Return "Linux"
		End Function
		
		Private Function Version As Long
				Return 0
		End Function
		
		Private Function Build As Long
				Return 0
		End Function
		
		Private Function Language As String
				Dim As String SysLanguage = *setlocale(LC_CTYPE, "")
				Var Pos1 = InStr(SysLanguage, "_")
				If Pos1 > 0 Then SysLanguage = Left(SysLanguage, Pos1 - 1)
				If SysLanguage = "C" Then
					SysLanguage = ""
				End If
				Return SysLanguage
		End Function
		
		Private Function Platform As Long
				Return 0
		End Function
	End Namespace
End Namespace
