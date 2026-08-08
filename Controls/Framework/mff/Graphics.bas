'###############################################################################
'#  Graphics.bi                                                                 #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TGraphics.bi                                                               #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
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

#include once "Graphics.bi"
'#ifdef __FB_WIN32__
'	#include once "win/wingdi.bi"
'#endif
#include once "Graphics.bi"

Private Function ColorToRGB(FColor As Integer) As Integer
	If FColor < 0 Then
			Return FColor
	Else
		Return FColor
	End If
End Function

Private Function RGBAToBGR(FColor As UInteger) As Integer
		Return BGR(GetRed(FColor), GetGreen(FColor), GetBlue(FColor))
End Function

Private Function BGRToRGBA(FColor As UInteger) As UInteger
		Return RGBA(GetRed(FColor), GetGreen(FColor), GetBlue(FColor), 255)
End Function

	Private Function ShiftColor(ByVal clrFirst As Long, ByVal clrSecond As Long, ByVal lAlpha As Long) As Long
		Dim lShiftColor As Long
			Dim clrFore(3)         As ULong = {GetRed(clrFirst), GetGreen(clrFirst), GetBlue(clrFirst)}
			Dim clrBack(3)         As ULong = {GetRed(clrSecond), GetGreen(clrSecond), GetBlue(clrSecond)}
			
			clrFore(0) = (clrFore(0) * lAlpha + clrBack(0) * (255 - lAlpha)) / 255
			clrFore(1) = (clrFore(1) * lAlpha + clrBack(1) * (255 - lAlpha)) / 255
			clrFore(2) = (clrFore(2) * lAlpha + clrBack(2) * (255 - lAlpha)) / 255
			
			lShiftColor = RGB(clrFore(0), clrFore(1), clrFore(2))
			lShiftColor = (Cast(ULong, 100 / 100 * 255) Shl 24) + (Cast(ULong, GetRed(lShiftColor)) Shl 16) + (Cast(ULong, GetGreen(lShiftColor)) Shl 8) + (Cast(ULong, GetBlue(lShiftColor)))
		
		Return lShiftColor
		
	End Function
	
	Private Function IsDarkColor(lColor As Long) As Boolean
		Dim bBGRA(0 To 3) As Byte
		
		IsDarkColor = ((CLng(bBGRA(0)) + (CLng(bBGRA(1) * 3)) + CLng(bBGRA(2))) / 2) < 382
	End Function
	

Public Function RGBtoARGB(ByVal RGBColor As ULong, ByVal Opacity As Long) As ULong
		Return ShiftColor(RGBColor, clWhite, Opacity / 100 * 255)
		'Return ((Cast(ULong, Opacity / 100 * 255) Shl 24) + (Cast(ULong, Abs(GetRed(RGBColor))) Shl 16) + (Cast(ULong, Abs(GetGreen(RGBColor))) Shl 8) + (Cast(ULong, Abs(GetBlue(RGBColor)))))
	'Return Color_MakeARGB(Opacity / 100 * 255, GetRed(RGBColor), GetGreen(RGBColor), GetBlue(RGBColor))
	Return 0
End Function

Private Function GetRed(FColor As Long) As Integer
	Return CUInt(FColor) And 255
End Function

Private Function GetGreen(FColor As Long) As Integer
	Return CUInt(FColor) Shr 8 And 255
End Function

Private Function GetBlue(FColor As Long) As Integer
	Return CUInt(FColor) Shr 16 And 255
End Function

Private Function GetRedD(FColor As Long) As Double
	Return Abs(CUInt(FColor) And 255) / 255.0
End Function

Private Function GetGreenD(FColor As Long) As Double
	Return Abs(CUInt(FColor) Shr 8 And 255) / 255.0
End Function

Private Function GetBlueD(FColor As Long) As Double
	Return Abs(CUInt(FColor) Shr 16 And 255) / 255.0
End Function
'End Namespace
