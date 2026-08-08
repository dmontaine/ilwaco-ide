'###############################################################################
'#  ImageBox.bi                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TStatic.bi                                                                #
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

#include once "ImageBox.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function ImageBox.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "autosize": Return @FAutoSize
			Case "centerimage": Return @FCenterImage
			Case "realsizeimage": Return @FRealSizeImage
			Case "style": Return @FImageStyle
			Case "graphic": Return Cast(Any Ptr, @This.Graphic)
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function ImageBox.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "autosize": If Value <> 0 Then This.AutoSize = QBoolean(Value)
			Case "centerimage": If Value <> 0 Then This.CenterImage = QBoolean(Value)
			Case "realsizeimage": If Value <> 0 Then This.RealSizeImage = QBoolean(Value)
			Case "style": If Value <> 0 Then This.Style = *Cast(ImageBoxStyle Ptr, Value)
			Case "graphic": This.Graphic = QWString(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property ImageBox.AutoSize As Boolean
		Return FAutoSize
	End Property
	
	Private Property ImageBox.AutoSize(Value As Boolean)
		FAutoSize = Value
		RecreateWnd
	End Property
	
	Private Property ImageBox.DesignMode As Boolean
		Return FDesignMode
	End Property
	
		Private Function ImageBox.DesignDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As Any Ptr) As Boolean
				Dim As Integer AllocatedWidth = gtk_widget_get_allocated_width(widget), AllocatedHeight = gtk_widget_get_allocated_height(widget)
			cairo_rectangle(cr, 0.0, 0.0, AllocatedWidth, AllocatedHeight)
			Dim As Double Ptr dashed = _Allocate(SizeOf(Double) * 2)
			dashed[0] = 3.0
			dashed[1] = 3.0
			Dim As Integer len1 = SizeOf(dashed) / SizeOf(dashed[0])
			cairo_set_dash(cr, dashed, len1, 1)
			cairo_set_source_rgb(cr, 0.0, 0.0, 0.0)
			cairo_stroke(cr)
			Return False
		End Function
		
		Private Function ImageBox.DesignExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As Any Ptr) As Boolean
			Dim As cairo_t Ptr cr = gdk_cairo_create(Event->window)
			DesignDraw(widget, cr, data1)
			cairo_destroy(cr)
			Return False
		End Function
	
	Private Property ImageBox.DesignMode(Value As Boolean)
		FDesignMode = Value
		If Value Then
					g_signal_connect(widget, "draw", G_CALLBACK(@DesignDraw), @This)
		End If
	End Property
		
	Private Property ImageBox.Style As ImageBoxStyle
		Return FImageStyle
	End Property
	
	Private Property ImageBox.Style(Value As ImageBoxStyle)
		'If Value <> FImageStyle Then
			FImageStyle = Value
			RecreateWnd
		'End If
	End Property
	
	Private Property ImageBox.RealSizeImage As Boolean
		Return FRealSizeImage
	End Property
	
	Private Property ImageBox.RealSizeImage(Value As Boolean)
		If Value <> FRealSizeImage Then
			FRealSizeImage = Value
			RecreateWnd
		End If
	End Property
	
	Private Property ImageBox.CenterImage As Boolean
		Return FCenterImage
	End Property
	
	Private Property ImageBox.CenterImage(Value As Boolean)
		If Value <> FCenterImage Then
			FCenterImage = Value
			RecreateWnd
		End If
	End Property
	
	Private Sub ImageBox.GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
		With Sender
			If .Ctrl->Child Then
					Select Case ImageType
					Case 0
						gtk_image_set_from_pixbuf(GTK_IMAGE(.Ctrl->widget), .Bitmap.Handle)
					Case 1
						gtk_image_set_from_pixbuf(GTK_IMAGE(.Ctrl->widget), .Icon.Handle)
					End Select
			End If
		End With
	End Sub
	
	
	
	Private Sub ImageBox.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator ImageBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor ImageBox
			widget = gtk_image_new()
			eventboxwidget = gtk_event_box_new()
			gtk_container_add(GTK_CONTAINER(eventboxwidget), widget)
			This.RegisterClass "ImageBox", @This
		FImageStyle = 0
		Graphic.Ctrl = @This
		Graphic.OnChange = @GraphicChange
		FRealSizeImage   = 0
		FCenterImage   = True
		With This
			.Child       = @This
			WLet(FClassName, "ImageBox")
			.Width       = 90
			.Height      = 17
		End With
	End Constructor
	
	Private Destructor ImageBox
	End Destructor
End Namespace
