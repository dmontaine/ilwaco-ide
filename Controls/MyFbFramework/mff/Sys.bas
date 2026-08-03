'###############################################################################
'#  Sys.bi                                                                     #
'#  This file is part of MyFBFramework                                         #
'#  Authors: José Roca (2016), Xusinboy Bekchanov                              #
'#  Windows version functions based on WinFBX/Afx/AfxWin.inc                   #
'###############################################################################

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
