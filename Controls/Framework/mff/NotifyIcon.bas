'################################################################################
'#  NotifyIcon.bas                                                              #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2025)                                          #
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

#include once "NotifyIcon.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function NotifyIcon.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "balloontipicon": Return @BalloonTipIcon
			Case "balloontipicontype": Return @FBalloonTipIconType
			Case "balloontiptext": Return FBalloonTipText.vptr
			Case "balloontiptitle": Return FBalloonTipTitle.vptr
			Case "contextmenu": Return ContextMenu
			Case "icon": Return @Icon
			Case "text": Return FText.vptr
			Case "visible": Return @FVisible
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function NotifyIcon.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value <> 0 Then
				Select Case LCase(PropertyName)
				Case "balloontipicon": This.BalloonTipIcon = QWString(Value)
				Case "balloontipicontype": This.BalloonTipIconType = *Cast(ToolTipIconType Ptr, Value)
				Case "balloontiptext": This.BalloonTipText = QWString(Value)
				Case "balloontiptitle": This.BalloonTipTitle = QWString(Value)
				Case "contextmenu": This.ContextMenu = QPopupMenu(Value)
				Case "icon": This.Icon = QWString(Value)
				Case "text": This.Text = QWString(Value)
				Case "visible": This.Visible = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property NotifyIcon.BalloonTipIconType As ToolTipIconType
		Return FBalloonTipIconType
	End Property
	
	
	Private Property NotifyIcon.BalloonTipIconType(Value As ToolTipIconType)
		FBalloonTipIconType = Value
	End Property
	
	Private Property NotifyIcon.BalloonTipText ByRef As WString
		Return *FBalloonTipText.vptr
	End Property
	
	Private Property NotifyIcon.BalloonTipText(ByRef Value As WString)
		FBalloonTipText = Value
	End Property
	
	Private Property NotifyIcon.BalloonTipTitle ByRef As WString
		Return *FBalloonTipTitle.vptr
	End Property
	
	Private Property NotifyIcon.BalloonTipTitle(ByRef Value As WString)
		FBalloonTipTitle = Value
	End Property
	
	Private Property NotifyIcon.Text ByRef As WString
		Return *FText.vptr
	End Property
	
	Private Property NotifyIcon.Text(ByRef Value As WString)
		FText = Value
	End Property
	
	Private Property NotifyIcon.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property NotifyIcon.Visible(Value As Boolean)
		'If FVisible <> Value Then
		FVisible = Value
		If Not FDesignMode Then
		End If
		'End If
	End Property
	
	Private Sub NotifyIcon.IconChanged(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Icon)
		With *Cast(NotifyIcon Ptr, Sender.Graphic)
		End With
	End Sub
	
	Private Sub NotifyIcon.BalloonTipIconChanged(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Icon)
		With *Cast(NotifyIcon Ptr, Sender.Graphic)
		End With
	End Sub
	
	Private Sub NotifyIcon.ShowBalloonTip(timeout As Integer)
	End Sub
	
	Private Sub NotifyIcon.ShowBalloonTip(timeout As Integer, ByRef tipTitle As WString, ByRef tipText As WString, tipIconType As ToolTipIconType, tipIcon As My.Sys.Drawing.Icon Ptr = 0)
	End Sub
	
	Function NotifyIcon.IsWindowsVistaOrHigher() As Boolean
			Return False
	End Function
	
	Private Constructor NotifyIcon
		WLet(FClassName, "NotifyIcon")
		Icon.Graphic = @This
		Icon.Changed = @IconChanged
		BalloonTipIcon.Graphic = @This
		BalloonTipIcon.Changed = @BalloonTipIconChanged
	End Constructor
	
	Private Destructor NotifyIcon
	End Destructor
End Namespace
