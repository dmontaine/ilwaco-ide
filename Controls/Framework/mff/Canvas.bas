'################################################################################
'#  Canvas.bas                                                                   #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   TCanvas.bi                                                                 #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#   Version 1.0.0                                                              #
'################################################################################

#include once "Canvas.bi"

Namespace My.Sys.Drawing
	#ifndef ReadProperty_Off
		Private Function Canvas.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "pen": Return @Pen
			Case "brush": Return @Brush
			Case "font": Return @Font
			Case "clip": Return @Clip
			Case "copymode": Return @CopyMode
				Case "handle": Return Handle
			Case "height": iTemp = This.Height: Return @iTemp
			Case "width": iTemp = This.Width: Return @iTemp
			Case "usedirect2d": Return @FUseDirect2D
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Canvas.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "clip": This.Clip = QBoolean(Value)
			Case "copymode": This.CopyMode = QInteger(Value)
			Case "usedirect2d": UseDirect2D = QBoolean(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property Canvas.BackColor As Integer
		Return FBackColor
	End Property
	
	Private Property Canvas.BackColor(Value As Integer)
		FBackColor = Value
		FillColor = FBackColor
	End Property
	
	Private Property Canvas.FillColor As Integer
		Return FFillColor
	End Property
	
	Private Property Canvas.FillColor(Value As Integer)
		If FFillColor <> Value Then
			FFillColor = Value
		End If
	End Property
	
	Private Property Canvas.FillMode As BrushFillMode
		Return FFillMode
	End Property
	
	Private Property Canvas.FillMode(Value As BrushFillMode)
		If FFillMode <> Value Then
			FFillMode = Value
		End If
	End Property
	
	Private Property Canvas.HatchStyle As HatchStyles
		Return FHatchStyle
	End Property
	
	Private Property Canvas.HatchStyle(Value As HatchStyles)
		If FHatchStyle <> Value Then
			FHatchStyle = Value
		End If
	End Property
	
	Private Property Canvas.FillStyles As BrushStyles
		Return FFillStyles
	End Property
	
	Private Property Canvas.FillStyles(Value As BrushStyles)
		'https://learn.microsoft.com/zh-cn/windows/win32/gdiplus/-gdiplus-brushes-and-filled-shapes-about
		'If FFillStyles <> Value Then
		FFillStyles = Value
		'End If
	End Property
	
	Private Property Canvas.Width As Integer
		If ParentControl Then
			Return ParentControl->Width
		Else
		End If
	End Property
	
	Private Property Canvas.Height As Integer
		If ParentControl Then
			Return ParentControl->Height
		Else
		End If
	End Property
	
	Private Property Canvas.ScaleWidth As Integer
		Return FScaleWidth
	End Property
	
	Private Property Canvas.ScaleHeight As Integer
		Return FScaleHeight
	End Property
	
	Private Property Canvas.DrawWidth As Integer
		Return Pen.Size
	End Property
	
	Private Property Canvas.DrawWidth(Value As Integer)
	End Property
	
	Private Property Canvas.DrawColor As Integer
		Return Pen.Color
	End Property
	
	Private Property Canvas.DrawColor(Value As Integer)
	End Property
	
	Private Property Canvas.DrawStyle As PenStyle
		Return Pen.Style
	End Property
	'https://learn.microsoft.com/zh-cn/windows/win32/api/gdipluspen/nf-gdipluspen-pen-setdashstyle
	Private Property Canvas.DrawStyle(Value As PenStyle)
	End Property
	
	Private Sub Canvas.Cls(x As Double = 0, y As Double = 0, x1 As Double = 0, y1 As Double = 0)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If ParentControl > 0 Then
				cairo_set_source_rgb(Handle, GetRed(FBackColor), GetGreen(FBackColor), GetBlue(FBackColor))
			Dim As Rect R
			If x = x1 AndAlso y = y1 AndAlso x = y Then
				R.Left = 0
				R.Top = 0
				R.Right = ScaleX(ParentControl->Width)
				R.Bottom = ScaleY(ParentControl->Height)
				'Remove Scale
				imgScaleX = 1
				imgScaleY = 1
				imgOffsetX = 0
				imgOffsetY = 0
				FDrawWidth = 1
				FScaleWidth = ScaleX(This.Width)
				FScaleHeight =  ScaleY(This.Height)
			Else
				R.Left = ScaleX(x) * imgScaleX + imgOffsetX
				R.Top = ScaleY(y) * imgScaleY + imgOffsetY
				R.Right = ScaleX(x1) * imgScaleX + imgOffsetX
				R.Bottom = ScaleY(y1) * imgScaleY + imgOffsetY
			End If
				.cairo_rectangle(Handle, ScaleX(R.Left) - 0.5, ScaleY(R.Top) - 0.5, ScaleX(R.Right - R.Left) - 0.5, ScaleY(R.Bottom - R.Top) - 0.5)
				cairo_set_source_rgb(Handle, GetRedD(FBackColor), GetGreenD(FBackColor), GetBlueD(FBackColor))
				cairo_fill_preserve(Handle)
		End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	Private Property Canvas.Ctrl As My.Sys.ComponentModel.Component Ptr
		Return ParentControl
	End Property
	
	Private Property Canvas.Ctrl(Value As My.Sys.ComponentModel.Component Ptr)
		ParentControl = Value
		If ParentControl Then
			'			ParentControl->Canvas = @This
			'			If *Ctrl Is My.Sys.Forms.Control Then
			'				Brush.Color = Cast(My.Sys.Forms.Control Ptr, Ctrl)->BackColor
			'			End If
		End If
	End Property
	
	Private Property Canvas.Pixel(xy As Point) As Integer
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Return 0
		If Not HandleSetted Then ReleaseDevice Handle_
	End Property
	
	Private Property Canvas.Pixel(xy As Point, Value As Integer)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			cairo_set_source_rgb(Handle, GetRed(Value) / 255.0, GetBlue(Value) / 255.0, GetGreen(Value) / 255.0)
			.cairo_rectangle(Handle, ScaleX(xy.X) * imgScaleX + imgOffsetX - 0.5, ScaleY(xy.Y) * imgScaleY + imgOffsetY - 0.5, 1, 1)
			cairo_fill(Handle)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Property
	
	Private Function Canvas.GetDevice As Any Ptr
		Dim As Any Ptr Handle_
		If Not HandleSetted Then
			If ParentControl Then
					If ParentControl->Handle Then
						pcontext = gtk_widget_create_pango_context(ParentControl->Handle)
						layout = pango_layout_new(pcontext)
						pango_layout_set_font_description(layout, Font.Handle)
						If Not HandleSetted Then
							If ParentControl->layoutwidget Then
									Handle_ = gdk_cairo_create(gtk_layout_get_bin_window(GTK_LAYOUT(ParentControl->layoutwidget)))
							End If
						End If
					End If
			End If
			Handle = Handle_
		Else
			Handle_ = Handle
		End If
		HandleSetted = True
		Return Handle_
	End Function
	
	Private Sub Canvas.ReleaseDevice(Handle As Any Ptr = 0)
		Dim As Any Ptr Handle_ = Handle
		If Handle_ = 0 Then Handle_ = This.Handle
			If layout Then g_object_unref(layout)
				If pcontext Then g_object_unref(pcontext)
				If Handle_ AndAlso G_IS_OBJECT(Handle_) Then cairo_destroy(Handle_)
				This.Handle = 0
				HandleSetted = False
	End Sub
	
	Private Sub Canvas.Scale(x As Double, y As Double, x1 As Double, y1 As Double)
		If ParentControl Then
			imgScaleX = Min(ParentControl->Width, ParentControl->Height) / (x1 - x)
			imgScaleY = Min(ParentControl->Width, ParentControl->Height) / (y1 - y)
			imgOffsetX = ScaleX(IIf(ParentControl->Width > ParentControl->Height, (ParentControl->Width - ParentControl->Height) / 2 - x * imgScaleX, -x * imgScaleX))
			imgOffsetY = ScaleY(IIf(ParentControl->Height > ParentControl->Width, (ParentControl->Height - ParentControl->Width) / 2 - y * imgScaleY, -y * imgScaleY))
			FScaleWidth = ScaleX(x1 - x)
			FScaleHeight = ScaleY(y1 - y)
		Else
			imgScaleX = 1
			imgScaleY = 1
			imgOffsetX = 0
			imgOffsetY = 0
			FDrawWidth = 1
			FScaleWidth = ScaleX(This.Width)
			FScaleHeight = ScaleY( This.Height)
		End If
	End Sub
	
	Private Sub Canvas.MoveTo(x As Double, y As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			cairo_move_to(Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.LineTo(x As Double, y As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		Dim As Double FMoveToXNew = ScaleX(x) * imgScaleX + imgOffsetX - 0.5
		Dim As Double FMoveToYNew = ScaleY(y) * imgScaleY + imgOffsetY - 0.5
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_line_to(Handle, FMoveToXNew, FMoveToYNew)
			cairo_stroke(Handle)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Line(x As Double, y As Double, x1 As Double, y1 As Double, FillColorBk As Integer = -1, BoxBF As String = "" )
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		FMoveToX = x1: FMoveToY = y1
		If BoxBF <> "" Then
			If BoxBF = "F" Then
				'Special code for VB6
				Dim As Integer OldFillColor = Brush.Color
				If FillColorBk <> Brush.Color Then
					If FillColorBk = -1 Then FillColorBk = FBackColor
					Brush.Color = FillColorBk
				End If
					Rectangle(x, y, x1, y1)
				If FillColorBk <> OldFillColor Then
					Brush.Color = OldFillColor
				End If
			Else
					Rectangle(x, y, x1, y1)
			End If
		Else
			Dim As Integer OldPenColor
			If FillColorBk <> -1 Then
				OldPenColor = Pen.Color
				Pen.Color = FillColorBk
			End If
				cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
				cairo_move_to(Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5)
				cairo_line_to(Handle, ScaleX(x1) * imgScaleX + imgOffsetX - 0.5, ScaleY(y1) * imgScaleY + imgOffsetY - 0.5)
				cairo_stroke(Handle)
			If FillColorBk <> -1 Then Pen.Color = OldPenColor
		End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	#ifndef Canvas_Rectangle_Double_Double_Double_Double_Off
		Private Sub Canvas.Rectangle Overload(x As Double, y As Double, x1 As Double, y1 As Double)
			Dim As Any Ptr Handle_
			If Not HandleSetted Then Handle_ = GetDevice
				cairo_move_to (Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5)
				cairo_line_to (Handle, ScaleX(x1) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5)
				cairo_line_to (Handle, ScaleX(x1) * imgScaleX + imgOffsetX - 0.5, ScaleY(y1) * imgScaleY + imgOffsetY - 0.5)
				cairo_line_to (Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y1) * imgScaleY + imgOffsetY - 0.5)
				cairo_line_to (Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5)
				cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
				cairo_fill_preserve(Handle)
				cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
				cairo_stroke(Handle)
			If Not HandleSetted Then ReleaseDevice Handle_
		End Sub
	#endif
	
	Private Sub Canvas.Rectangle(R As Rect)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			.cairo_rectangle(Handle, ScaleX(R.Left) * imgScaleX + imgOffsetX - 0.5, ScaleY(R.Top) * imgScaleY + imgOffsetY - 0.5, ScaleX(R.Right - R.Left) * imgScaleY - 0.5, ScaleY(R.Bottom - R.Top) * imgScaleY - 0.5)
			cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
			cairo_fill_preserve(Handle)
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Ellipse Overload(x As Double, y As Double, x1 As Double, y1 As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			cairo_move_to Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5
			cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
			cairo_arc(Handle, ScaleX(x + (x1 - x) / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + (y1 - y) / 2) * imgScaleY + imgOffsetY - 0.5, ScaleX((x1 - x) / 2) * imgScaleX, 0, 2 * G_PI)
			cairo_fill_preserve(Handle)
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Ellipse(R As Rect)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			cairo_move_to Handle, ScaleX(R.Left) * imgScaleX + imgOffsetX - 0.5, ScaleY(R.Top) * imgScaleY + imgOffsetY - 0.5
			cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
			cairo_arc(Handle, ScaleX(R.Left + (R.Right - R.Left) / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(R.Top + (R.Bottom - R.Top) / 2) * imgScaleY + imgOffsetY - 0.5, ScaleX((R.Right - R.Left) / 2) * imgScaleX, 0, 2 * G_PI)
			cairo_fill_preserve(Handle)
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Circle(x As Double, y As Double, Radial As Double, FillColorBK As Integer = -1)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		'Special code for VB6
		If FillColorBK = -1 Then FillColorBK = FFillColor
		Dim As Integer OldFillColor = Brush.Color
		Brush.Color = FillColorBK
			cairo_move_to Handle, ScaleX(x + Radial / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5
			cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
			cairo_arc(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(Radial) / 2 * imgScaleX, 0, 2 * G_PI)
			cairo_fill_preserve(Handle)
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
		Brush.Color = OldFillColor
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.RoundRect Overload(x As Double, y As Double, x1 As Double, y1 As Double, nWidth As Integer, nHeight As Integer)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Var radius = x1 - x
			cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
			cairo_move_to Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + nWidth / 2) * imgScaleY + imgOffsetY - 0.5
			cairo_arc (Handle, ScaleX(x + radius) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + nWidth / 2) * imgScaleY + imgOffsetY - 0.5, ScaleX(nWidth / 2) * imgScaleX, G_PI, -G_PI / 2)
			cairo_line_to (Handle, ScaleX(x + nWidth - nWidth / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5)
			cairo_arc (Handle, ScaleX(x + nWidth - nWidth / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + nWidth / 2) * imgScaleY + imgOffsetY - 0.5, ScaleX(nWidth / 2) * imgScaleX, -G_PI / 2, 0)
			cairo_line_to (Handle, ScaleX(x + nWidth) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + nHeight - nWidth / 2) * imgScaleY + imgOffsetY - 0.5)
			cairo_arc (Handle, ScaleX(x + (nWidth - nWidth / 2)) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + nHeight - nWidth / 2) * imgScaleY + imgOffsetY - 0.5, ScaleX(nWidth / 2) * imgScaleX, 0, G_PI / 2)
			cairo_line_to (Handle, ScaleX(x + nWidth / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + nHeight) * imgScaleY + imgOffsetY - 0.5)
			cairo_arc (Handle, ScaleX(x + nWidth / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + nHeight - nWidth / 2) * imgScaleY + imgOffsetY - 0.5, ScaleX(nWidth / 2) * imgScaleX, G_PI / 2, G_PI)
			cairo_close_path Handle
			cairo_fill_preserve(Handle)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Polygon(Points() As Point, Count As Long)
		If Count < 3 Then Return
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Print "The function is not ready in this OS."  & "   Canvas.Polygon(Points() As Point, Count As Long)"
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.RoundRect(R As Rect, nWidth As Integer, nHeight As Integer)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		This.RoundRect R.Left, R.Top, R.Right, R.Bottom, nWidth, nHeight
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Chord(x As Double, y As Double, x1 As Double, y1 As Double, nXRadial1 As Double, nYRadial1 As Double, nXRadial2 As Double, nYRadial2 As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Print "The function is not ready in this OS." & "  Canvas.Chord(x As Double, y As Double, x1 As Double, y1 As Double, nXRadial1 As Double, nYRadial1 As Double, nXRadial2 As Double, nYRadial2 As Double))"
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Pie(x As Double, y As Double, x1 As Double, y1 As Double, nXRadial1 As Double, nYRadial1 As Double, nXRadial2 As Double, nYRadial2 As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Print "The function is not ready in this OS." & "  Canvas.Pie(x As Double, y As Double, x1 As Double, y1 As Double, nXRadial1 As Double, nYRadial1 As Double, nXRadial2 As Double, nYRadial2 As Double)"
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Arc(x As Double, y As Double, x1 As Double, y1 As Double, xStart As Double, yStart As Double, xEnd As Double, yEnd As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			cairo_move_to Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5
			cairo_arc(Handle, ScaleX(x + (x1 - x) / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + (y1 - y) / 2) * imgScaleY + imgOffsetY - 0.5, ScaleX((x1 - x) / 2) * imgScaleX, 0, G_PI * 1)
			cairo_fill_preserve(Handle)
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.ArcTo(x As Double, y As Double, x1 As Double, y1 As Double, nXRadial1 As Double, nYRadial1 As Double, nXRadial2 As Double, nYRadial2 As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.AngleArc(x As Double, y As Double, Radius As Double, StartAngle As Double, SweepAngle As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Polyline(Points() As Point, Count As Long)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.PolylineTo(Points() As Point, Count As Long)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.PolyBeizer(Points() As Point, Count As Long)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.PolyBeizerTo(Points() As Point, Count As Long)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.SetPixel(x As Double, y As Double, PixelColor As Integer)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			cairo_set_source_rgb(Handle, GetRed(PixelColor) / 255.0, GetBlue(PixelColor) / 255.0, GetGreen(PixelColor) / 255.0)
			.cairo_rectangle(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, 1, 1)
			cairo_fill(Handle)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Function Canvas.GetPixel(x As Double, y As Double) As Integer
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Function = 0
			Print "The function is not ready in this OS."  & " Canvas.GetPixel(x As Double, y As Double) As Integer"
		If Not HandleSetted Then ReleaseDevice Handle_
	End Function
	
		Private Sub Canvas.SetHandle(CanvasHandle As cairo_t Ptr)
			Handle = CanvasHandle
			HandleSetted = True
		End Sub
	
	Private Property Canvas.UseDirect2D As Boolean
		Return FUseDirect2D
	End Property
	
	
	Private Property Canvas.UseDirect2D(Value As Boolean)
		FUseDirect2D = Value
		Dim As Long hr = 0
	End Property
	
	Private Sub Canvas.UnSetHandle()
		HandleSetted = False
	End Sub
	
	Private Sub Canvas.TextOut(x As Double, y As Double, ByRef s As WString, FG As Integer = -1, BK As Integer = -1)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Dim As PangoRectangle extend2
			Dim As Double iRed, iGreen, iBlue
			pango_layout_set_text(layout, ToUtf8(s), Len(ToUtf8(s)))
			pango_cairo_update_layout(Handle, layout)
			#ifdef pango_version
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(layout, 0)
			#else
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(layout, 0)
			#endif
			pango_layout_line_get_pixel_extents(pl, NULL, @extend2)
			If BK <> -1 Then
				iRed = Abs(GetRed(BK) / 255.0): iGreen = Abs(GetGreen(BK) / 255.0): iBlue = Abs(GetBlue(BK) / 255.0)
				cairo_set_source_rgb(Handle, iRed, iGreen, iBlue)
				.cairo_rectangle (Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, extend2.width, extend2.height)
				cairo_fill (Handle)
			End If
			cairo_move_to(Handle, ScaleX(x) * imgScaleX + imgOffsetX + 0.5, ScaleY(y) * imgScaleY + imgOffsetY + extend2.height + 0.5)
			If FG = -1 Then
				iRed = Abs(GetRed(Font.Color) / 255.0): iGreen = Abs(GetGreen(Font.Color) / 255.0): iBlue = Abs(GetBlue(Font.Color) / 255.0)
			Else
				iRed = Abs(GetRed(FG) / 255.0): iGreen = Abs(GetGreen(FG) / 255.0): iBlue = Abs(GetBlue(FG) / 255.0)
			End If
			iRed = Abs(GetRed(FG) / 255.0): iGreen = Abs(GetGreen(FG) / 255.0): iBlue = Abs(GetBlue(FG) / 255.0)
			cairo_set_source_rgb(Handle, iRed, iGreen, iBlue)
			pango_cairo_show_layout_line(Handle, pl)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Function Canvas.Get(x As Double, y As Double, nWidth As Integer, nHeight As Integer, ByRef ImageSource As My.Sys.Drawing.BitmapType) As Any Ptr
			Return Get(x, y, nWidth , nHeight, ImageSource.Handle)
	End Function
	
	Private Function Canvas.Get(x As Double, y As Double, nWidth As Integer, nHeight As Integer, ByVal ImageSource As Any Ptr) As Any Ptr
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Dim As GdkPixbuf Ptr ImageDest
			If nWidth <> 0 AndAlso nHeight <> 0 Then
				ImageDest = gdk_pixbuf_new(GDK_COLORSPACE_RGB, True, 8 , nWidth, nHeight)
				If ImageDest Then
					gdk_pixbuf_copy_area(ImageSource, x, y, nWidth, nHeight, ImageDest, 0, 0)
					Return ImageDest
				End If
			End If
			Return 0
		If Not HandleSetted Then ReleaseDevice Handle_
		Return 0
	End Function
	
	Private Sub Canvas.DrawAlpha(x As Double, y As Double, nWidth As Double = -1, nHeight As Double = -1, ByRef Image As My.Sys.Drawing.BitmapType, iSourceAlpha As Integer = 255)
		If nWidth = -1 Then nWidth = ScaleX(Image.Width)
		If nHeight = -1 Then nHeight = ScaleY(Image.Height)
			DrawAlpha(x, y, nWidth, nHeight, Image.Handle, iSourceAlpha)
	End Sub
	
	
	Private Sub Canvas.DrawAlpha(x As Double, y As Double, nWidth As Double = -1, nHeight As Double = -1, ByVal Image As Any Ptr, iSourceAlpha As Integer = 255)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Dim As cairo_surface_t Ptr image_surface
				image_surface = gdk_cairo_surface_create_from_pixbuf(Image, 1, NULL)
			cairo_set_source_surface(Handle, image_surface, x, y)
			cairo_paint(Handle)
			cairo_surface_destroy(image_surface)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Draw(x As Double, y As Double, Image As Any Ptr)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Print "The function is not ready in this OS."  & " Canvas.Draw(x As Double, y As Double, Image As Any Ptr)"
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Draw(x As Double, y As Double, ByRef Image As My.Sys.Drawing.BitmapType)
			This.Draw(x, y, Image.Handle)
	End Sub
	
	Private Sub Canvas.Draw(x As Double, y As Double, ByRef Image As My.Sys.Drawing.Icon)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Print "The function is not ready in this OS."  & " Draw(x As Double, y As Double, ByRef Image As My.Sys.Drawing.Icon)"
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	#ifndef Canvas_DrawTransparent_Off
		Private Sub Canvas.DrawTransparent(x As Double, y As Double, Image As Any Ptr, cTransparentColor As UInteger = 0)
			Dim As Any Ptr Handle_
			If Not HandleSetted Then Handle_ = GetDevice
				Print "The function is not ready in this OS."  & " DrawTransparent(x As Double, y As Double, Image As Any Ptr, cTransparentColor As UInteger = 0)"
			If Not HandleSetted Then ReleaseDevice Handle_
		End Sub
		
		Private Sub Canvas.DrawTransparent(x As Double, y As Double, ByRef Image As My.Sys.Drawing.BitmapType, cTransparentColor As UInteger = 0)
				DrawTransparent ScaleX(x), ScaleY(y), Image.Handle, cTransparentColor
		End Sub
	#endif
	
	Private Sub Canvas.DrawStretch(x As Double, y As Double, nWidth As Integer, nHeight As Integer, Image As Any Ptr)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Print "The function is not ready in this OS."  & " Canvas.DrawStretch(x As Double, y As Double, nWidth As Integer, nHeight As Integer, Image As Any Ptr)"
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.CopyRect(Dest As Rect, Canvas As Canvas, Source As Rect)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.FloodFill(x As Double, y As Double, FillColorBK As Integer = -1, FillStyleBK As FillStyle)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If FillColorBK = -1 Then FillColorBK = FBackColor
			Print "The function is not ready in this OS."  & " Canvas.FloodFill(x As Double, y As Double, FillColorBK As Integer = -1, FillStyleBK As FillStyle)"
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.FillRect(R As Rect, FillColorBK As Integer = -1)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If FillColorBK = -1 Then FillColorBK = FBackColor
			cairo_set_source_rgb(Handle, GetRed(FillColorBK), GetBlue(FillColorBK), GetGreen(FillColorBK))
			.cairo_rectangle(Handle, ScaleX(R.Left) * imgScaleX + imgOffsetX - 0.5, ScaleY(R.Top) * imgScaleX + imgOffsetX - 0.5, ScaleX(R.Right - R.Left) - 0.5, ScaleY(R.Bottom - R.Top) - 0.5)
			cairo_fill_preserve(Handle)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.DrawFocusRect(R As Rect)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Print "The function is not ready in this OS."  & " DrawFocusRect(R As Rect)"
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Function Canvas.TextWidth(ByRef FText As WString) As Integer
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Dim As PangoRectangle extend
			pango_layout_set_text(layout, ToUtf8(FText), Len(ToUtf8(FText)))
			pango_cairo_update_layout(Handle, layout)
			#ifdef pango_version
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(layout, 0)
			#else
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(layout, 0)
			#endif
			pango_layout_line_get_pixel_extents(pl, NULL, @extend)
			Function = UnScaleX(extend.width)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Function
	
	Private Function Canvas.TextHeight(ByRef FText As WString) As Integer
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Dim As PangoRectangle extend
			pango_layout_set_text(layout, ToUtf8(FText), Len(ToUtf8(FText)))
			pango_cairo_update_layout(Handle, layout)
			#ifdef pango_version
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(layout, 0)
			#else
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(layout, 0)
			#endif
			pango_layout_line_get_pixel_extents(pl, NULL, @extend)
			Function = UnScaleY(extend.height)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Function
	
	Private Operator Canvas.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Sub Canvas.Font_Create(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Font)
		With *Cast(Canvas Ptr, Sender.Parent)
				If .layout Then pango_layout_set_font_description (.layout, Sender.Handle)
		End With
	End Sub
	
	Private Sub Canvas.Pen_Create(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Pen)
	End Sub
	
	Private Sub Canvas.Brush_Create(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Brush)
	End Sub
	
	Private Constructor Canvas
		Clip = False
		WLet(FClassName, "Canvas")
		Font.Parent = @This
		Font.OnCreate = @Font_Create
		Pen.Parent = @This
		Pen.OnCreate = @Pen_Create
		Brush.Parent = @This
		Brush.OnCreate = @Brush_Create
		Brush.Style = BrushStyles.bsSolid
		imgScaleX = 1
		imgScaleY = 1
		FDrawWidth = 1
		FScaleWidth = ScaleX(This.Width)
		FScaleHeight = ScaleY(This.Height)
		FillOpacity = 50
		BackColorOpacity = 100
	End Constructor
	
	Private Destructor Canvas
			If Handle Then ReleaseDevice
	End Destructor
End Namespace

