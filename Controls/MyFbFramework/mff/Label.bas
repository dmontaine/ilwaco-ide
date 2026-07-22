'###############################################################################
'#  Label.bi                                                                   #
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

#include once "Label.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function Label.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "alignment": Return @FAlignment
			Case "autosize": Return @FAutoSize
			Case "border": Return @FBorder
			Case "canvas": Return @Canvas
			Case "caption": Return Cast(Any Ptr, This.FText.vptr)
			Case "centerimage": Return @FCenterImage
			Case "realsizeimage": Return @FRealSizeImage
			Case "style": Return @FStyle
			Case "tabindex": Return @FTabIndex
			Case "text": Return Cast(Any Ptr, This.FText.vptr)
			Case "transparent": Return @FTransparent
			Case "graphic": Return Cast(Any Ptr, @This.Graphic)
			Case "wordwraps": Return @FWordWraps
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Label.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "alignment": If Value <> 0 Then This.Alignment = *Cast(AlignmentConstants Ptr, Value)
			Case "autosize": If Value <> 0 Then This.AutoSize = QBoolean(Value)
			Case "border": If Value <> 0 Then This.Border = *Cast(LabelBorder Ptr, Value)
			Case "caption": If Value <> 0 Then This.Caption = *Cast(WString Ptr, Value)
			Case "centerimage": If Value <> 0 Then This.CenterImage = QBoolean(Value)
			Case "realsizeimage": If Value <> 0 Then This.RealSizeImage = QBoolean(Value)
			Case "style": If Value <> 0 Then This.Style = *Cast(LabelStyle Ptr, Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case "text": If Value <> 0 Then This.Text = *Cast(WString Ptr, Value)
			Case "transparent": If Value <> 0 Then This.Transparent = QBoolean(Value)
			Case "graphic": This.Graphic = QWString(Value)
			Case "wordwraps": This.WordWraps = QBoolean(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property Label.Caption ByRef As WString
		Return Text
	End Property
	
	Private Property Label.Caption(ByRef Value As WString)
		Text = Value
	End Property
	
	Private Property Label.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property Label.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property Label.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property Label.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property Label.Transparent As Boolean
		Return FTransparent
	End Property
	
	Private Property Label.Transparent(Value As Boolean)
		FTransparent = Value
	End Property
	
	Private Property Label.Text ByRef As WString
		Return Base.Text
	End Property
	
	Private Property Label.Text(ByRef Value As WString)
		Base.Text = Value
		#ifdef __USE_GTK__
			gtk_label_set_text(GTK_LABEL(widget), ToUtf8(Value))
		#elseif 0
			If FHandle Then
				(*env)->CallVoidMethod(env, FHandle, GetMethodID("android/widget/TextView", "setText", "(Ljava/lang/CharSequence;)V"), (*env)->NewStringUTF(env, ToUtf8(FText)))
			End If
		#endif
		SetAutoSize
	End Property
	
	Private Property Label.Border As LabelBorder
		Return FBorder
	End Property
	
	Private Sub Label.ChangeLabelStyle
		If Style <> lsText Then
		Else
				Select Case FAlignment
				Case AlignmentConstants.taLeft
					#ifdef __USE_GTK3__
						gtk_label_set_xalign(GTK_LABEL (widget), 0.0)
					#else
						gtk_label_set_justify(GTK_LABEL(widget), GTK_JUSTIFY_LEFT)
						gtk_misc_set_alignment(GTK_MISC(widget), 0, 0)
					#endif
				Case AlignmentConstants.taCenter
					#ifdef __USE_GTK3__
						gtk_label_set_xalign(GTK_LABEL (widget), 0.5)
					#else
						gtk_label_set_justify(GTK_LABEL(widget), GTK_JUSTIFY_CENTER)
						gtk_misc_set_alignment(GTK_MISC(widget), 0.5, 0)
					#endif
				Case AlignmentConstants.taRight
					#ifdef __USE_GTK3__
						gtk_label_set_xalign(GTK_LABEL (widget), 1.0)
					#else
						gtk_label_set_justify(GTK_LABEL(widget), GTK_JUSTIFY_RIGHT)
						gtk_misc_set_alignment(GTK_MISC(widget), 1, 0)
					#endif
				End Select
		End If
		RecreateWnd
	End Sub
	
	Private Sub Label.CalculateSize(ByRef Size As My.Sys.Drawing.Size)
		Size.Width = This.Width
		Size.Height = This.Height
		If CBool(Font.Orientation = 0) AndAlso FAutoSize Then
			#ifdef __USE_GTK__
				Size.Width = Canvas.TextWidth(FText)
				Size.Height = Canvas.TextHeight(FText)
			#elseif 0
				
			#elseif 0
				If FHandle Then
					Dim Sz As ..Size
					Dim As HDC Dc = GetDC(Handle)
					If Dc > 0 Then
						Dim As .HANDLE PrevFont = SelectObject(Dc, Cast(HFONT, SendMessage(FHandle, WM_GETFONT, 0, 0)))
						GetTextExtentPoint32(Dc, FText.vptr, Len(FText), @Sz)
						Size.Width = Sz.cx
						Size.Height = Sz.cy
						SelectObject(Dc, PrevFont)
					End If
				End If
			#endif
		End If
	End Sub
	
	Private Sub Label.SetAutoSize
		If FAutoSize Then
			Dim Size As My.Sys.Drawing.Size
			CalculateSize Size
			SetBounds This.Left, This.Top, Size.Width, Size.Height
		End If
	End Sub
	
	Private Property Label.Border(Value As LabelBorder)
		If Value <> FBorder Then
			FBorder = Value
			ChangeLabelStyle
		End If
	End Property
	
	Private Property Label.Style As LabelStyle
		Return FStyle
	End Property
	
	Private Property Label.Style(Value As LabelStyle)
		If Value <> FStyle Then
			FStyle = Value
			ChangeLabelStyle
		End If
	End Property
	
	Private Property Label.RealSizeImage As Boolean
		Return FRealSizeImage
	End Property
	
	Private Property Label.RealSizeImage(Value As Boolean)
		If Value <> FRealSizeImage Then
			FRealSizeImage = Value
			ChangeLabelStyle
		End If
	End Property
	
	Private Property Label.CenterImage As Boolean
		Return FCenterImage
	End Property
	
	Private Property Label.CenterImage(Value As Boolean)
		If Value <> FCenterImage Then
			FCenterImage = Value
			ChangeLabelStyle
		End If
	End Property
	
	Private Property Label.Alignment As AlignmentConstants
		Return FAlignment
	End Property
	
	Private Property Label.Alignment(Value As AlignmentConstants)
		If Value <> FAlignment Then
			FAlignment = Value
			ChangeLabelStyle
		End If
	End Property
	
	Private Property Label.AutoSize As Boolean
		Return FAutoSize
	End Property
	
	Private Property Label.AutoSize(Value As Boolean)
		If Value <> FAutoSize Then
			FAutoSize = Value
			SetAutoSize
		End If
	End Property
	
	Private Property Label.WordWraps As Boolean
		Return FWordWraps
	End Property
	
	Private Property Label.WordWraps(Value As Boolean)
		If Value <> FWordWraps Then
			FWordWraps = Value
			#ifdef __USE_GTK__
				gtk_label_set_line_wrap(GTK_LABEL(widget), Value)
			#else
				ChangeLabelStyle
			#endif
		End If
	End Property
	
	Private Sub Label.GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
		With Sender
			If .Ctrl->Child Then
			End If
		End With
	End Sub
	
	
	Private Sub Label.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator Label.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor Label
		#ifdef __USE_GTK__
			widget = gtk_label_new("")
			#ifdef __USE_GTK3__
				gtk_label_set_xalign (GTK_LABEL (widget), 0.0)
			#else
				gtk_misc_set_alignment(GTK_MISC(widget), 0, 0)
			#endif
			gtk_label_set_line_wrap(GTK_LABEL(widget), True)
			#ifdef __USE_GTK3__
				eventboxwidget = gtk_event_box_new()
				gtk_container_add(GTK_CONTAINER(eventboxwidget), widget)
			#endif
			This.RegisterClass "Label", @This
		#elseif 0
			AStyle(0)           = 0
			AStyle(1)           = SS_BITMAP
			AStyle(2)           = SS_ICON
			AStyle(3)           = SS_ICON
			AStyle(4)           = SS_ENHMETAFILE
			AStyle(5)           = SS_OWNERDRAW
			AAlignment(0)       = SS_LEFT
			AAlignment(1)       = SS_CENTER
			AAlignment(2)       = SS_RIGHT
			ABorder(0)          = 0
			ABorder(1)          = SS_SIMPLE
			ABorder(2)          = SS_SUNKEN
			ACenterImage(0)     = SS_RIGHTJUST
			ACenterImage(1)     = SS_CENTERIMAGE
			ARealSizeImage(0)   = 0
			ARealSizeImage(1)   = SS_REALSIZEIMAGE
			AWordWraps(0)       = SS_ENDELLIPSIS
			AWordWraps(1)       = 0
		#endif
		Graphic.Ctrl = @This
		Graphic.OnChange = @GraphicChange
		FRealSizeImage   = 1
		FWordWraps       = True
		FAlignment       = 0
		FTabIndex        = -1
		With This
			.Child       = @This
			WLet(FClassName, "Label")
			.Width       = 90
			.Height      = ScaleY(Max(8, Font.Size) /72*96+6)  '中文字号VS英文字号(磅)VS像素值的对应关系：八号＝5磅(5pt) ==(5/72)*96=6.67 =6px
		End With
	End Constructor
	
	Private Destructor Label
	End Destructor
End Namespace
