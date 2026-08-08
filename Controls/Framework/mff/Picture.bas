'###############################################################################
'#  Picture.bas                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Liu ZiQI                                           #
'#  Based on:                                                                  #
'#   TStatic.bi                                                                #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Created by Liu ZiQI (2019)                                                 #
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
'https://blog.csdn.net/mmmvp/article/details/365155

#include once "Picture.bi"
Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function Picture.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "autosize": Return @FAutoSize
			Case "centerimage": Return @FCenterImage
			Case "graphic": Return Cast(Any Ptr, @This.Graphic)
			Case "realsizeimage": Return @FRealSizeImage
			Case "stretchimage": Return @FStretchImage
			Case "transparent": Return @FTransparent
			Case "style": Return @FPictureStyle
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Picture.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "autosize": This.AutoSize = QBoolean(Value)
				Case "centerimage": This.CenterImage = QBoolean(Value)
				Case "stretchimage": This.StretchImage = *Cast(StretchMode Ptr, Value)
				Case "graphic": This.Graphic = QWString(Value)
				Case "realsizeimage": This.RealSizeImage = QBoolean(Value)
				Case "transparent": This.Transparent = QBoolean(Value)
				Case "style": This.Style = *Cast(PictureStyle Ptr, Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property Picture.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property Picture.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property Picture.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property Picture.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property Picture.AutoSize As Boolean
		Return FAutoSize
	End Property
	
	Private Property Picture.AutoSize(Value As Boolean)
		If Value <> FAutoSize Then
			Base.AutoSize = Value
		End If
		RecreateWnd
	End Property
	
	Private Property Picture.StretchImage As StretchMode
		Return FStretchImage
	End Property
	
	Private Property Picture.StretchImage(Value As StretchMode)
		If Value <> FStretchImage Then
			FStretchImage = Value
		End If
	End Property
	
	Private Property Picture.Style As PictureStyle
		Return FPictureStyle
	End Property
	
	Private Property Picture.Style(Value As PictureStyle)
		If Value <> FPictureStyle Then
			FPictureStyle = Value
		End If
		RecreateWnd
	End Property
	
	Private Property Picture.RealSizeImage As Boolean
		Return FRealSizeImage
	End Property
	
	Private Property Picture.RealSizeImage(Value As Boolean)
		If Value <> FRealSizeImage Then
			FRealSizeImage = Value
			RecreateWnd
		End If
	End Property
	
	Private Property Picture.CenterImage As Boolean
		Return FCenterImage
	End Property
	
	Private Property Picture.CenterImage(Value As Boolean)
		If Value <> FCenterImage Then
			FCenterImage = Value
			Graphic.CenterImage = Value
			RecreateWnd
		End If
	End Property
	
	Private Sub Picture.GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
		With Sender
			If .Ctrl->Child Then
					If GTK_IS_IMAGE(QPicture(.Ctrl->Child).ImageWidget) Then
						Select Case ImageType
						Case 0
							gtk_image_set_from_pixbuf(GTK_IMAGE(QPicture(.Ctrl->Child).ImageWidget), .Bitmap.Handle)
						Case 1
							gtk_image_set_from_pixbuf(GTK_IMAGE(QPicture(.Ctrl->Child).ImageWidget), .Icon.Handle)
						End Select
					End If
			End If
		End With
	End Sub
	
	
	
	Private Sub Picture.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Property Picture.Transparent As Boolean
		Return FTransparent
	End Property
	
	Private Property Picture.Transparent(Value As Boolean)
		FTransparent = Value
	End Property
	
	Private Operator Picture.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor Picture
			ImageWidget = gtk_image_new()
			widget = gtk_layout_new(NULL, NULL)
			If GTK_IS_WIDGET(ImageWidget) Then gtk_layout_put(GTK_LAYOUT(widget), ImageWidget, 0, 0)
			This.RegisterClass "Picture", @This
		This.Canvas.Ctrl    = @This
		Graphic.Ctrl = @This
		Graphic.OnChange = @GraphicChange
		FRealSizeImage   = False
		FCenterImage = True
		FPictureStyle = PictureStyle.ssBitmap
		With This
			.Child       = @This
			WLet(FClassName, "Picture")
			FTabIndex          = -1
			.Width       = 80
			.Height      = 60
			.ShowCaption = False
		End With
	End Constructor
	Private Destructor Picture
			If GTK_IS_WIDGET(ImageWidget) Then
					gtk_widget_destroy(ImageWidget)
			End If
	End Destructor
End Namespace

