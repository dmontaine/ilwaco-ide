'###############################################################################
'#  PagePanel.bi                                                               #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov                                                #
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

#include once "ContainerControl.bi"
#include once "Graphic.bi"
#include once "NumericUpDown.bi"
#include once "Panel.bi"
#include once "CommandButton.bi"

Namespace My.Sys.Forms
	#define QPagePanel(__Ptr__) (*Cast(PagePanel Ptr, __Ptr__))
	
	'Used to group collections of controls (Windows, Linux, Android, Web).
	Private Type PagePanel Extends ContainerControl
	Private:
		FSelectedPanelIndex As Integer
		FTransparent As Boolean
		Declare Static Sub GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
	Protected:
			Declare Static Function Overlay_get_child_position(self As GtkOverlay Ptr, widget As GtkWidget Ptr, allocation As GdkRectangle Ptr, user_data As Any Ptr) As Boolean
		NumericUpDownControl As NumericUpDown
			UpDownButton As CommandButton
			Declare Sub UpDownButton_Click(ByRef Sender As Control)
		mnuContext As PopupMenu
		mnuShowPanel As MenuItem
		Declare Sub NumericUpDownControl_Change(ByRef Sender As NumericUpDown)
		Declare Sub MenuItem_Click(ByRef Sender As MenuItem)
		Declare Sub MoveNumericUpDownControl
		Declare Virtual Sub ProcessMessage(ByRef Message As Message)
	Public:
		#ifndef ReadProperty_Off
			Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		#endif
		'Returns/sets a graphic to be displayed in a control (Windows, Linux).
		Graphic As My.Sys.Drawing.GraphicType
		Declare Property SelectedPanel As Control Ptr
		Declare Property SelectedPanel(Value As Control Ptr)
		Declare Property SelectedPanelIndex As Integer
		Declare Property SelectedPanelIndex(Value As Integer)
		Declare Property TabIndex As Integer
		Declare Property TabIndex(Value As Integer)
		Declare Property TabStop As Boolean
		Declare Property TabStop(Value As Boolean)
		Declare Property Transparent As Boolean
		Declare Property Transparent(Value As Boolean)
		Declare Sub Add(Ctrl As Control Ptr, Index As Integer = -1)
		Declare Sub CreateWnd
		Declare Operator Cast As Control Ptr
		Declare Constructor
		Declare Destructor
		OnSelChange    As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As PagePanel, NewIndex As Integer)
		OnSelChanging  As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As PagePanel, NewIndex As Integer)
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "PagePanel.bas"
#endif
