'###############################################################################
'#  Panel.bi                                                                   #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TPanel.bi                                                                 #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
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

#include once "Panel.bi"
'#Include Once "Canvas.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function Panel.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "tabindex": Return @FTabIndex
			Case "transparent": Return @FTransparent
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Panel.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "tabindex": TabIndex = QInteger(Value)
				Case "transparent": This.Transparent = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property Panel.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property Panel.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property Panel.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property Panel.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property Panel.Text ByRef As WString
		Return WGet(FText)
	End Property
	
	Private Property Panel.Text(ByRef Value As WString)
		Base.Text = Value
	End Property
	
	Private Property Panel.BevelInner As Bevel
		Return FBevelInner
	End Property
	
	Private Property Panel.BevelInner(Value As Bevel)
		FBevelInner = Value
		Invalidate
	End Property
	
	Private Property Panel.BevelOuter As Bevel
		Return FBevelOuter
	End Property
	
	Private Property Panel.BevelOuter(Value As Bevel)
		FBevelOuter = Value
		Invalidate
	End Property
	
	Private Property Panel.BevelWidth As Integer
		Return FBevelWidth
	End Property
	
	Private Property Panel.BevelWidth(Value As Integer)
		FBevelWidth = Value
		Invalidate
	End Property
	
	Private Property Panel.BorderWidth As Integer
		Return FBorderWidth
	End Property
	
	Private Property Panel.BorderWidth(Value As Integer)
		FBorderWidth = Value
		Invalidate
	End Property
	
	
	
	Private Sub Panel.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	
	Property Panel.Visible As Boolean
		Return Base.Visible
	End Property
	
	Property Panel.Visible(Value As Boolean)
		Base.Visible = Value
	End Property
	
	Private Property Panel.Transparent As Boolean
		Return FTransparent
	End Property
	
	Private Property Panel.Transparent(Value As Boolean)
		FTransparent = Value
	End Property
	
	Private Operator Panel.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Sub Panel.CreateWnd
		Base.CreateWnd
	End Sub
	
	Private Sub Panel.GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
		With Sender
			If .Ctrl->Child Then
					'If GTK_IS_IMAGE(QForm(.Ctrl->Child).ImageWidget) Then
					'	Select Case ImageType
					'	Case 0
					'		gtk_image_set_from_pixbuf(GTK_IMAGE(QForm(.Ctrl->Child).ImageWidget), .Bitmap.Handle)
					'	Case 1
					'		gtk_image_set_from_pixbuf(GTK_IMAGE(QForm(.Ctrl->Child).ImageWidget), .Icon.Handle)
					'	End Select
					'End If
			End If
		End With
	End Sub
	
	Private Constructor Panel
		With This
				'widget = gtk_scrolled_window_new(null, null)
				'widget = gtk_layout_new(null, null)
				'widget = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0)
				'gtk_container_add(GTK_CONTAINER(widget), box)
				widget = gtk_layout_new(NULL, NULL)
				'gtk_container_add(GTK_CONTAINER(widget), layoutwidget)
				'gtk_box_pack_end(Gtk_Box(widget), layoutwidget, true, true, 0)
				
				'gtk_widget_set_events(widget, _
				'         GDK_EXPOSURE_MASK Or _
				'         GDK_SCROLL_MASK Or _
				'        GDK_STRUCTURE_MASK Or _
				'       GDK_KEY_PRESS_MASK Or _
				'      GDK_KEY_RELEASE_MASK Or _
				'     GDK_FOCUS_CHANGE_MASK Or _
				'    GDK_LEAVE_NOTIFY_MASK Or _
				'   GDK_BUTTON_PRESS_MASK Or _
				'  GDK_BUTTON_RELEASE_MASK Or _
				' GDK_POINTER_MOTION_MASK Or _
				'GDK_POINTER_MOTION_HINT_MASK)
				
				'widget = gtk_fixed_new()
				'gtk_scrolled_window_set_policy(gtk_scrolled_window(widget), GTK_POLICY_EXTERNAL, GTK_POLICY_EXTERNAL)
				'gtk_scrolled_window_set_propagate_natural_width(gtk_scrolled_window(widget), true)
				'widget = gtk_fixed_new()
				.RegisterClass "Panel", @This
			FBorderWidth = 0
			'FBevelWidth=2
			'PopupMenu.Ctrl = This
			.Child          = @This
			.Canvas.Ctrl    = @This
			.Graphic.Ctrl   = @This
			.Graphic.OnChange = @GraphicChange
			FTabIndex          = -1
			WLet(FClassName, "Panel")
			.Width       = 121
			.Height      = 41
			.ShowCaption = False
		End With
	End Constructor
	
	Private Destructor Panel
	End Destructor
End Namespace
