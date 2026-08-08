'################################################################################
'#  NotifyIcon.bi                                                               #
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

#include once "Component.bi"
#include once "Menus.bi"

Namespace My.Sys.Forms
	#define QNotifyIcon(__Ptr__) (*Cast(NotifyIcon Ptr, __Ptr__))
	
	Enum ToolTipIconType
		None = 0 'Not a standard icon.
		Info = 1 'An information icon.
		Warning = 2 'A warning icon.
		Error = 3 'An error icon.
		User = 4 'A user icon.
	End Enum
	
	
	'Specifies a component that creates an icon in the notification area (Windows only).
	Private Type NotifyIcon Extends My.Sys.ComponentModel.Component
	Private:
		FBalloonTipIconType As ToolTipIconType
		FBalloonTipText As UString
		FBalloonTipTitle As UString
		FText As UString
		FVisible As Boolean
		Declare Static Sub IconChanged(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Icon)
		Declare Static Sub BalloonTipIconChanged(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Icon)
		Declare Function IsWindowsVistaOrHigher() As Boolean
	Public:
		#ifndef ReadProperty_Off
			'Reads value from the name of property (Windows, Linux, Android, Web).
			Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			'Writes value to the name of property (Windows, Linux, Android, Web).
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		#endif
		Icon            As My.Sys.Drawing.Icon
		BalloonTipIcon  As My.Sys.Drawing.Icon
		ContextMenu     As PopupMenu Ptr
		Declare Property BalloonTipIconType As ToolTipIconType
		Declare Property BalloonTipIconType(Value As ToolTipIconType)
		Declare Property BalloonTipText ByRef As WString
		Declare Property BalloonTipText(ByRef Value As WString)
		Declare Property BalloonTipTitle ByRef As WString
		Declare Property BalloonTipTitle(ByRef Value As WString)
		Declare Property Text ByRef As WString
		Declare Property Text(ByRef Value As WString)
		Declare Property Visible As Boolean
		Declare Property Visible(Value As Boolean)
		Declare Sub ShowBalloonTip(timeout As Integer)
		Declare Sub ShowBalloonTip(timeout As Integer, ByRef tipTitle As WString, ByRef tipText As WString, tipIconType As ToolTipIconType, tipIcon As My.Sys.Drawing.Icon Ptr = 0)
		Declare Constructor
		Declare Destructor
		OnBalloonTipClicked As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon)
		OnBalloonTipClosed As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon)
		OnBalloonTipShown As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon)
		'Occurs when the notify icon is clicked (Windows only).
		OnClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon)
		'Occurs when the notify icon is double-clicked (Windows, Linux, Web).
		OnDblClick As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon)
		'Occurs when the mouse pointer is moved over the notify icon (Windows only).
		OnMouseMove  As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		'Occurs when the mouse pointer is over the notify icon and a mouse button is pressed (Windows only).
		OnMouseDown  As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
		'Occurs when the mouse pointer is over the notify icon and a mouse button is released (Windows only).
		OnMouseUp    As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NotifyIcon, MouseButton As Integer, x As Integer, y As Integer, Shift As Integer)
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "NotifyIcon.bas"
#endif
