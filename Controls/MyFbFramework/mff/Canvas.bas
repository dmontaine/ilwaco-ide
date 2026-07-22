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
				#ifdef __USE_GTK__
				Case "handle": Return Handle
				#else
				Case "handle": Return @Handle
				#endif
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
				If Handle <> 0 Then
					cairo_set_source_rgb(Handle, GetRedD(FFillColor), GetGreenD(FFillColor), GetBlueD(FFillColor))
				End If
			
		End If
	End Property
	
	Private Property Canvas.FillMode As BrushFillMode
		Return FFillMode
	End Property
	
	Private Property Canvas.FillMode(Value As BrushFillMode)
		If FFillMode <> Value Then
			FFillMode = Value
				' 补齐 Cairo 的 FillMode 支持 (交替填充与环绕填充)
				If Handle <> 0 Then
					If FFillMode = BrushFillMode.bmOpaque Then
						cairo_set_fill_rule(Handle, CAIRO_FILL_RULE_EVEN_ODD)
					Else
						cairo_set_fill_rule(Handle, CAIRO_FILL_RULE_WINDING)
					End If
				End If
		End If
	End Property
	
	Private Property Canvas.HatchStyle As HatchStyles
		Return FHatchStyle
	End Property
	
	Private Property Canvas.HatchStyle(Value As HatchStyles)
		If FHatchStyle <> Value Then
			FHatchStyle = Value
				' 补齐 Cairo 的 HatchStyle 设置（记录状态，绘制时根据状态模拟图案）
				''TODO: Cairo 无原生 Hatch，需基于 Surface Pattern 模拟实现
		End If
	End Property
	
	Private Property Canvas.FillStyles As BrushStyles
		Return FFillStyles
	End Property
	
	Private Property Canvas.FillStyles(Value As BrushStyles)
		'https://learn.microsoft.com/zh-cn/windows/win32/gdiplus/-gdiplus-brushes-and-filled-shapes-about
		'If FFillStyles <> Value Then
		FFillStyles = Value
			' 补齐 Cairo 的 FillStyles 设置记录
			''TODO: Cairo 需根据 FillStyles 在绘制时应用不同的 Source (Pattern)
		'End If
	End Property
	
	Private Property Canvas.Width As Integer
		If ParentControl Then
			Return ParentControl->Width
		Else
				''TODO Cairo/GTK 等其他环境后备
				Return 0
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
		If FDrawWidth <> Value Then
			FDrawWidth = Value
				If Handle <> 0 Then cairo_set_line_width(Handle, FDrawWidth)
		End If
	End Property
	
	Private Property Canvas.DrawColor As Integer
		Return Pen.Color
	End Property
	
	Private Property Canvas.DrawColor(Value As Integer)
		If FDrawColor <> Value Then
			FDrawColor = Value
			Pen.Color = Value
				If Handle <> 0 Then cairo_set_source_rgb(Handle, GetRedD(FDrawColor), GetGreenD(FDrawColor), GetBlueD(FDrawColor))
		End If
	End Property
	
	Private Property Canvas.DrawStyle As PenStyle
		Return Pen.Style
	End Property
	'https://learn.microsoft.com/zh-cn/windows/win32/api/gdipluspen/nf-gdipluspen-pen-setdashstyle
	Private Property Canvas.DrawStyle(Value As PenStyle)
		If FDrawStyle <> Value Then
			FDrawStyle = Value
			Pen.Style = Value
				If Handle <> 0 Then
					Select Case Value
					Case PenStyle.psDash
						Dim As Double dashes(1) = {10.0, 5.0}
						cairo_set_dash(Handle, @dashes(0), 2, 0)
					Case PenStyle.psDot
						Dim As Double dashes(1) = {2.0, 4.0}
						cairo_set_dash(Handle, @dashes(0), 2, 0)
					Case PenStyle.psDashDot
						Dim As Double dashes(3) = {10.0, 5.0, 2.0, 5.0}
						cairo_set_dash(Handle, @dashes(0), 4, 0)
					Case PenStyle.psDashDotDot
						Dim As Double dashes(5) = {10.0, 5.0, 2.0, 5.0, 2.0, 5.0}
						cairo_set_dash(Handle, @dashes(0), 6, 0)
					Case Else ' Solid
						cairo_set_dash(Handle, 0, 0, 0)
					End Select
				End If
		End If
	End Property
	
	Private Sub Canvas.Cls(x As Double = 0, y As Double = 0, x1 As Double = 0, y1 As Double = 0)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If ParentControl > 0 Then
			#ifdef __USE_CAIRO__
				cairo_set_source_rgb(Handle, GetRed(FBackColor), GetGreen(FBackColor), GetBlue(FBackColor))
			#elseif 0
				Dim As HBRUSH B = CreateSolidBrush(FBackColor)
				If FUseDirect2D AndAlso pRenderTarget <> 0 Then
					Dim As D2D1_COLOR_F Color1
					Color1.r = GetRed(FBackColor) / 255.0
					Color1.g = GetGreen(FBackColor) / 255.0
					Color1.b = GetBlue(FBackColor) / 255.0
					Color1.a = 1.0
					pRenderTarget->lpVtbl->Clear(pRenderTarget, @Color1)
				ElseIf Not UsingGdip Then
					
				Else
					GdipGraphicsClear(GdipGraphics, RGBtoARGB(FBackColor, 255))
					DeleteObject B
					
				End If
			#endif
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
			#ifdef __USE_CAIRO__
				.cairo_rectangle(Handle, ScaleX(R.Left) - 0.5, ScaleY(R.Top) - 0.5, ScaleX(R.Right - R.Left) - 0.5, ScaleY(R.Bottom - R.Top) - 0.5)
				cairo_set_source_rgb(Handle, GetRedD(FBackColor), GetGreenD(FBackColor), GetBlueD(FBackColor))
				cairo_fill_preserve(Handle)
			#elseif 0
				If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				Else
					.FillRect Handle, Cast(..Rect Ptr, @R), B
				End If
				DeleteObject B
			#endif
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
		#ifdef __USE_CAIRO__
			cairo_set_source_rgb(Handle, GetRed(Value) / 255.0, GetGreen(Value) / 255.0, GetBlue(Value) / 255.0)
			cairo_rectangle(Handle, ScaleX(xy.X) * imgScaleX + imgOffsetX - 0.5, ScaleY(xy.Y) * imgScaleY + imgOffsetY - 0.5, 1, 1)
			cairo_fill(Handle)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				' 使用 DrawLine 绘制 1px 点
				Dim As D2D1_POINT_2F pt = Type<D2D1_POINT_2F>(ScaleX(xy.X) * imgScaleX + imgOffsetX, ScaleY(xy.Y) * imgScaleY + imgOffsetY)
				pRenderTarget->lpVtbl->DrawLine(pRenderTarget, pt, pt, pBrushBorder, DrawWidth, pStrokeStyle)
			Else
				.SetPixel(Handle, ScaleX(xy.X) * imgScaleX + imgOffsetX, ScaleY(xy.Y) * imgScaleY + imgOffsetY, Value)
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Property
	
	Private Function Canvas.GetDevice As Any Ptr
		Dim As Any Ptr Handle_
		If Not HandleSetted Then
			If ParentControl Then
				#ifdef __USE_GTK__
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
				#elseif 1
					If ParentControl->Handle Then
						If Clip Then
							DeviceContextHandle = GetDCEx(ParentControl->Handle, 0, DCX_PARENTCLIP Or DCX_CACHE)
						Else
							DeviceContextHandle = GetDC(ParentControl->Handle)
						End If
						cairoSurface = cairo_win32_surface_create(DeviceContextHandle)
						Handle_ = cairo_create(cairoSurface)
						cairo_set_antialias(cairoSurface, CAIRO_ANTIALIAS_BEST)
						cairo_set_line_cap(cairoSurface, CAIRO_LINE_CAP_ROUND)
						cairo_set_line_join(cairoSurface, CAIRO_LINE_JOIN_ROUND)
					End If
				#elseif 0
					If ParentControl->Handle Then
						If FUseDirect2D AndAlso pRenderTarget <> 0 Then
							pRenderTarget->lpVtbl->BeginDraw(pRenderTarget)
						Else
							If Clip Then
								Handle_ = GetDCEx(ParentControl->Handle, 0, DCX_PARENTCLIP Or DCX_CACHE)
							Else
								Handle_ = GetDC(ParentControl->Handle)
							End If
							SelectObject(Handle_, Font.Handle)
							SelectObject(Handle_, Pen.Handle)
							SelectObject(Handle_, Brush.Handle)
							SetROP2 Handle_, Pen.Mode
							If UsingGdip Then
								If GdipGraphics Then Return GdipGraphics 'GdipDeleteGraphics(GdipGraphics)
								GdipCreateFromHDC(Handle, @GdipGraphics)
								If  GdipGraphics = NULL Then
									Print Date & " " & Time & Chr(9) & __FUNCTION__ & Chr(9) & " (Line " & __LINE__ & ") " & "Initial GdipGraphics failure! "
								Else
									GdipSetSmoothingMode(GdipGraphics, SmoothingModeAntiAlias)
									GdipSetCompositingQuality(GdipGraphics, &H3) 'CompositingQualityGammaCorrected
									GdipSetInterpolationMode(GdipGraphics, 7)
								End If
								'Handle_ = GdipGraphics
							End If
						End If
					End If
				#endif
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
		#ifdef __USE_GTK__
			If layout Then g_object_unref(layout)
				If pcontext Then g_object_unref(pcontext)
				If Handle_ AndAlso G_IS_OBJECT(Handle_) Then cairo_destroy(Handle_)
				This.Handle = 0
				HandleSetted = False
		#elseif 1
			If Not HandleSetted Then Exit Sub
			cairo_destroy(Handle_)
			cairo_surface_destroy(cairoSurface)
			If ParentControl AndAlso DeviceContextHandle Then
				ReleaseDC ParentControl->Handle, DeviceContextHandle
			End If
			This.Handle = 0
		#elseif 0
			If Not HandleSetted Then Exit Sub
			If ParentControl AndAlso Handle_ Then
				'If ParentControl->DoubleBuffered Then
				'	BitBlt(Handle_, 0, 0, R.Right - R.left, R.Bottom - R.top, memDC, 0, 0, SRCCOPY)
				'	DeleteObject(CompatibleBmp)
				'	DeleteDC(memDC)
				'End If
				If pRenderTarget <> 0 Then
					pRenderTarget->lpVtbl->EndDraw(pRenderTarget, 0, 0)
					ReleaseDirect2D
				Else
					If HandleSetted Then Exit Sub
					ReleaseDC ParentControl->Handle, Handle_
				End If
			End If
		#endif
		'HandleSetted = False
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
		#ifdef __USE_CAIRO__
			cairo_move_to(Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				FMoveToX = ScaleX(x) * imgScaleX + imgOffsetX : FMoveToY = ScaleY(y) * imgScaleY + imgOffsetY
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				FMoveToX = ScaleX(x) * imgScaleX + imgOffsetX : FMoveToY = ScaleY(y) * imgScaleY + imgOffsetY
			Else
				.MoveToEx Handle, ScaleX(x) * imgScaleX + imgOffsetX , ScaleY(y) * imgScaleY + imgOffsetY, 0
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.LineTo(x As Double, y As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		Dim As Double FMoveToXNew = ScaleX(x) * imgScaleX + imgOffsetX - 0.5
		Dim As Double FMoveToYNew = ScaleY(y) * imgScaleY + imgOffsetY - 0.5
		#ifdef __USE_CAIRO__
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_line_to(Handle, FMoveToXNew, FMoveToYNew)
			cairo_stroke(Handle)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				If pBrushBorder <> 0 Then pRenderTarget->lpVtbl->DrawLine(pRenderTarget, Type<D2D1_POINT_2F>(FMoveToX, FMoveToY), Type<D2D1_POINT_2F>(FMoveToXNew, FMoveToYNew), pBrushBorder, DrawWidth)
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				GdipDrawLine GdipGraphics, GdipPen, FMoveToX, FMoveToY, FMoveToXNew, FMoveToYNew
			Else
				.LineTo Handle, FMoveToXNew, FMoveToYNew
			End If
		#endif
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
			#ifdef __USE_CAIRO__
				cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
				cairo_move_to(Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5)
				cairo_line_to(Handle, ScaleX(x1) * imgScaleX + imgOffsetX - 0.5, ScaleY(y1) * imgScaleY + imgOffsetY - 0.5)
				cairo_stroke(Handle)
			#elseif 0
				If FUseDirect2D AndAlso pRenderTarget <> 0 Then
					If pBrushBorder <> 0 Then pRenderTarget->lpVtbl->DrawLine(pRenderTarget, Type<D2D1_POINT_2F>(ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY), Type<D2D1_POINT_2F>(ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY), pBrushBorder, DrawWidth)
				ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
					GdipDrawLine GdipGraphics, GdipPen, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY
				Else
					.MoveToEx Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, 0
					.LineTo Handle, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY
				End If
			#endif
			If FillColorBk <> -1 Then Pen.Color = OldPenColor
		End If
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	#ifndef Canvas_Rectangle_Double_Double_Double_Double_Off
		Private Sub Canvas.Rectangle Overload(x As Double, y As Double, x1 As Double, y1 As Double)
			Dim As Any Ptr Handle_
			If Not HandleSetted Then Handle_ = GetDevice
			#ifdef __USE_CAIRO__
				cairo_move_to (Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5)
				cairo_line_to (Handle, ScaleX(x1) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5)
				cairo_line_to (Handle, ScaleX(x1) * imgScaleX + imgOffsetX - 0.5, ScaleY(y1) * imgScaleY + imgOffsetY - 0.5)
				cairo_line_to (Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y1) * imgScaleY + imgOffsetY - 0.5)
				cairo_line_to (Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5)
				cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
				cairo_fill_preserve(Handle)
				cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
				cairo_stroke(Handle)
			#elseif 0
				If FUseDirect2D AndAlso pRenderTarget <> 0 Then
					If pBrushFill <> 0 Then pRenderTarget->lpVtbl->FillRectangle(pRenderTarget, @Type<D2D1_RECT_F>(ScaleX(x) * imgScaleX + imgOffsetX , ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX , ScaleY(y1) * imgScaleY + imgOffsetY), Cast(ID2D1Brush Ptr, pBrushFill))
					If pBrushBorder <> 0 Then pRenderTarget->lpVtbl->DrawRectangle(pRenderTarget, @Type<D2D1_RECT_F>(ScaleX(x) * imgScaleX + imgOffsetX , ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX , ScaleY(y1) * imgScaleY + imgOffsetY), Cast(ID2D1Brush Ptr, pBrushBorder), DrawWidth, pStrokeStyle)
				ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
					If GdipBrush Then GdipFillRectangle(GdipGraphics, GdipBrush, ScaleX(x) * imgScaleX + imgOffsetX , ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1 - x) * imgScaleX, ScaleY(y1 - y) * imgScaleY)
					GdipDrawRectangle(GdipGraphics, GdipPen,  ScaleX(x) * imgScaleX + imgOffsetX , ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1 - x) * imgScaleX, ScaleY(y1 - y) * imgScaleY)
				Else
					.Rectangle Handle, ScaleX(x) * imgScaleX + imgOffsetX , ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX , ScaleY(y1) * imgScaleY + imgOffsetY
				End If
			#endif
			If Not HandleSetted Then ReleaseDevice Handle_
		End Sub
	#endif
	
	Private Sub Canvas.Rectangle(R As Rect)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		#ifdef __USE_CAIRO__
			.cairo_rectangle(Handle, ScaleX(R.Left) * imgScaleX + imgOffsetX - 0.5, ScaleY(R.Top) * imgScaleY + imgOffsetY - 0.5, ScaleX(R.Right - R.Left) * imgScaleY - 0.5, ScaleY(R.Bottom - R.Top) * imgScaleY - 0.5)
			cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
			cairo_fill_preserve(Handle)
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				' 先填充再描边（与其他后端行为一致）
				Dim As D2D1_RECT_F rc = Type<D2D1_RECT_F>(ScaleX(R.Left) * imgScaleX + imgOffsetX, ScaleY(R.Top) * imgScaleY + imgOffsetY, ScaleX(R.Right - R.Left) * imgScaleX, ScaleY(R.Bottom - R.Top) * imgScaleY)
				If pBrushFill Then pRenderTarget->lpVtbl->FillRectangle(pRenderTarget, @rc, Cast(ID2D1Brush Ptr, pBrushFill))
				If pBrushBorder Then pRenderTarget->lpVtbl->DrawRectangle(pRenderTarget, @rc, Cast(ID2D1Brush Ptr, pBrushBorder), DrawWidth, pStrokeStyle)
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				If GdipBrush Then GdipFillRectangle(GdipGraphics, GdipBrush, ScaleX(R.Left) * imgScaleX + imgOffsetX, ScaleY(R.Top) * imgScaleY + imgOffsetY, ScaleX(R.Right - R.Left) * imgScaleX, ScaleY(R.Bottom - R.Top) * imgScaleY)
				GdipDrawRectangle(GdipGraphics, GdipPen, ScaleX(R.Left) * imgScaleX + imgOffsetX, ScaleY(R.Top) * imgScaleY + imgOffsetY, ScaleX(R.Right - R.Left) * imgScaleX , ScaleY(R.Bottom - R.Top) * imgScaleY)
			Else
				.Rectangle Handle, ScaleX(R.Left) * imgScaleX + imgOffsetX, ScaleY(R.Top) * imgScaleY + imgOffsetY, ScaleX(R.Right) * imgScaleX + imgOffsetX, ScaleY(R.Bottom) * imgScaleY + imgOffsetY
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Ellipse Overload(x As Double, y As Double, x1 As Double, y1 As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		#ifdef __USE_CAIRO__
			cairo_move_to Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5
			cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
			cairo_arc(Handle, ScaleX(x + (x1 - x) / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + (y1 - y) / 2) * imgScaleY + imgOffsetY - 0.5, ScaleX((x1 - x) / 2) * imgScaleX, 0, 2 * G_PI)
			cairo_fill_preserve(Handle)
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				If pBrushFill <> 0 Then pRenderTarget->lpVtbl->FillEllipse(pRenderTarget, @Type<D2D1_ELLIPSE>(Type<D2D1_POINT_2F>(ScaleX(x + (x1 - x) / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + (y1 - y) / 2) * imgScaleY + imgOffsetY - 0.5), ScaleX((x1 - x) / 2) * imgScaleX, ScaleY((y1 - y) / 2) * imgScaleY), Cast(ID2D1Brush Ptr, pBrushFill))
				If pBrushBorder <> 0 Then pRenderTarget->lpVtbl->DrawEllipse(pRenderTarget, @Type<D2D1_ELLIPSE>(Type<D2D1_POINT_2F>(ScaleX(x + (x1 - x) / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y + (y1 - y) / 2) * imgScaleY + imgOffsetY - 0.5), ScaleX((x1 - x) / 2) * imgScaleX, ScaleY((y1 - y) / 2) * imgScaleY), Cast(ID2D1Brush Ptr, pBrushBorder), DrawWidth, NULL)
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				If GdipBrush Then GdipFillEllipse(GdipGraphics, GdipBrush, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX((x1)) * imgScaleX, ScaleY((y1)) * imgScaleY)
				GdipDrawEllipse(GdipGraphics, GdipPen, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX, ScaleY(y1) * imgScaleY)
			Else
				.Ellipse(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY)
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Ellipse(R As Rect)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		#ifdef __USE_CAIRO__
			cairo_move_to Handle, ScaleX(R.Left) * imgScaleX + imgOffsetX - 0.5, ScaleY(R.Top) * imgScaleY + imgOffsetY - 0.5
			cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
			cairo_arc(Handle, ScaleX(R.Left + (R.Right - R.Left) / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(R.Top + (R.Bottom - R.Top) / 2) * imgScaleY + imgOffsetY - 0.5, ScaleX((R.Right - R.Left) / 2) * imgScaleX, 0, 2 * G_PI)
			cairo_fill_preserve(Handle)
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				If pBrushFill <> 0 Then pRenderTarget->lpVtbl->FillEllipse(pRenderTarget, @Type<D2D1_ELLIPSE>(Type<D2D1_POINT_2F>(ScaleX(R.Left + (R.Right - R.Left) / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(R.Top + (R.Bottom - R.Top) / 2) * imgScaleY + imgOffsetY - 0.5), ScaleX((R.Right - R.Left) / 2) * imgScaleX, ScaleY((R.Bottom - R.Top) / 2) * imgScaleY), Cast(ID2D1Brush Ptr, pBrushFill))
				If pBrushBorder <> 0 Then pRenderTarget->lpVtbl->DrawEllipse(pRenderTarget, @Type<D2D1_ELLIPSE>(Type<D2D1_POINT_2F>(ScaleX(R.Left + (R.Right - R.Left) / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(R.Top + (R.Bottom - R.Top) / 2) * imgScaleY + imgOffsetY - 0.5), ScaleX((R.Right - R.Left) / 2) * imgScaleX, ScaleY((R.Bottom - R.Top) / 2) * imgScaleY), Cast(ID2D1Brush Ptr, pBrushBorder), DrawWidth, NULL)
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				If GdipBrush Then GdipFillEllipse(GdipGraphics, GdipBrush, ScaleX(R.Left) * imgScaleX + imgOffsetX, ScaleY(R.Top) * imgScaleY + imgOffsetY, ScaleX(R.Right - R.Left) * imgScaleX, ScaleY(R.Bottom - R.Top) * imgScaleY)
				GdipDrawEllipse(GdipGraphics, GdipPen, ScaleX(R.Left) * imgScaleX + imgOffsetX, ScaleY(R.Top) * imgScaleY + imgOffsetY, ScaleX(R.Right - R.Left) * imgScaleX, ScaleY(R.Bottom - R.Top) * imgScaleY)
			Else
				.Ellipse Handle, ScaleX(R.Left) * imgScaleX + imgOffsetX, ScaleY(R.Top) * imgScaleY + imgOffsetY, ScaleX(R.Right) * imgScaleX + imgOffsetX, ScaleY(R.Bottom) * imgScaleY + imgOffsetY
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Circle(x As Double, y As Double, Radial As Double, FillColorBK As Integer = -1)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		'Special code for VB6
		If FillColorBK = -1 Then FillColorBK = FFillColor
		Dim As Integer OldFillColor = Brush.Color
		Brush.Color = FillColorBK
		#ifdef __USE_CAIRO__
			cairo_move_to Handle, ScaleX(x + Radial / 2) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5
			cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
			cairo_arc(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(Radial) / 2 * imgScaleX, 0, 2 * G_PI)
			cairo_fill_preserve(Handle)
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				If pBrushFill <> 0 Then pRenderTarget->lpVtbl->FillEllipse(pRenderTarget, @Type<D2D1_ELLIPSE>(Type<D2D1_POINT_2F>(ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5), ScaleX(Radial) * imgScaleX, ScaleY(Radial) * imgScaleY), Cast(ID2D1Brush Ptr, pBrushFill))
				If pBrushBorder <> 0 Then pRenderTarget->lpVtbl->DrawEllipse(pRenderTarget, @Type<D2D1_ELLIPSE>(Type<D2D1_POINT_2F>(ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5), ScaleX(Radial) * imgScaleX, ScaleY(Radial) * imgScaleY), Cast(ID2D1Brush Ptr, pBrushBorder), DrawWidth, NULL)
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				If GdipBrush Then GdipFillEllipse(GdipGraphics, GdipBrush, ScaleX(x - Radial / 2) * imgScaleX + imgOffsetX, ScaleY(y - Radial / 2) * imgScaleY + imgOffsetY, ScaleX(Radial) * imgScaleX, ScaleY(Radial) * imgScaleY)
				GdipDrawEllipse GdipGraphics, GdipPen, ScaleX(x - Radial / 2) * imgScaleX + imgOffsetX, ScaleY(y - Radial / 2) * imgScaleY + imgOffsetY, ScaleX(Radial) * imgScaleX, ScaleY(Radial) * imgScaleY
			Else
				.Ellipse Handle, ScaleX(x - Radial / 2) * imgScaleX + imgOffsetX, ScaleY(y - Radial / 2) * imgScaleY + imgOffsetY, ScaleX(x + Radial / 2) * imgScaleX + imgOffsetX, ScaleY(y + Radial / 2) * imgScaleY + imgOffsetY
			End If
		#endif
		Brush.Color = OldFillColor
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.RoundRect Overload(x As Double, y As Double, x1 As Double, y1 As Double, nWidth As Integer, nHeight As Integer)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		#ifdef __USE_CAIRO__
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
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)   '添加描边
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				If pBrushFill <> 0 Then pRenderTarget->lpVtbl->FillRoundedRectangle(pRenderTarget, @Type<D2D1_ROUNDED_RECT>(Type<D2D1_RECT_F>(ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY), ScaleX(nWidth) * imgScaleX / 2, ScaleY(nHeight) * imgScaleY / 2), Cast(ID2D1Brush Ptr, pBrushFill))
				If pBrushBorder <> 0 Then pRenderTarget->lpVtbl->DrawRoundedRectangle(pRenderTarget, @Type<D2D1_ROUNDED_RECT>(Type<D2D1_RECT_F>(ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY), ScaleX(nWidth) * imgScaleX / 2, ScaleY(nHeight) * imgScaleY / 2), Cast(ID2D1Brush Ptr, pBrushBorder), DrawWidth, pStrokeStyle)
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				Dim As GpPath Ptr gPath
				GdipCreatePath(FillMode, @gPath)
				Dim As Single rx = nWidth / 2, ry = nHeight / 2
				' 右上角
				GdipAddPathArc(gPath, ScaleX(x1 - nWidth) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(nWidth) * imgScaleX, ScaleY(nHeight) * imgScaleY, 270, 90)
				' 右角
				GdipAddPathArc(gPath, ScaleX(x1 - nWidth) * imgScaleX + imgOffsetX, ScaleY(y1 - nHeight) * imgScaleY + imgOffsetY, ScaleX(nWidth) * imgScaleX, ScaleY(nHeight) * imgScaleY, 0, 90)
				' 左下角
				GdipAddPathArc(gPath, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y1 - nHeight) * imgScaleY + imgOffsetY, ScaleX(nWidth) * imgScaleX, ScaleY(nHeight) * imgScaleY, 90, 90)
				' 左上角
				GdipAddPathArc(gPath, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(nWidth) * imgScaleX, ScaleY(nHeight) * imgScaleY, 180, 90)
				GdipClosePathFigure(gPath)
				If GdipBrush Then GdipFillPath(GdipGraphics, GdipBrush, gPath)
				GdipDrawPath(GdipGraphics, GdipPen, gPath)
				GdipDeletePath(gPath)
			Else
				.RoundRect Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(nWidth) * imgScaleX , ScaleY(nHeight) * imgScaleY
				
			End If
			
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Polygon(Points() As Point, Count As Long)
		If Count < 3 Then Return
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		#ifdef __USE_CAIRO__
			cairo_move_to(Handle, ScaleX(Points(0).X) * imgScaleX + imgOffsetX - 0.5, ScaleY(Points(0).Y) * imgScaleY + imgOffsetY - 0.5)
			For i As Integer = 1 To Count - 1
				cairo_line_to(Handle, ScaleX(Points(i).X) * imgScaleX + imgOffsetX - 0.5, ScaleY(Points(i).Y) * imgScaleY + imgOffsetY - 0.5)
			Next
			cairo_close_path(Handle) ' 闭合
			cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
			cairo_fill_preserve(Handle)
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				Dim pGeometry As ID2D1PathGeometry Ptr
				If pD2D1Factory->lpVtbl->CreatePathGeometry(pD2D1Factory, @pGeometry) = S_OK Then
					Dim pSink As ID2D1GeometrySink Ptr
					If pGeometry->lpVtbl->Open(pGeometry, @pSink) = S_OK Then
						Dim pD2DPoints(0 To Count - 1) As D2D1_POINT_2F
						pSink->lpVtbl->SetFillMode(pSink, D2D1_FILL_MODE_WINDING)
						For i As Integer = 0 To Count - 1
							pD2DPoints(i) = Type<D2D1_POINT_2F>(ScaleX(Points(i).X) * imgScaleX + imgOffsetX, ScaleY(Points(i).Y) * imgScaleY + imgOffsetY)
						Next
						pSink->lpVtbl->BeginFigure(pSink, pD2DPoints(0), D2D1_FIGURE_BEGIN_FILLED)
						pSink->lpVtbl->AddLines(pSink, @pD2DPoints(1), Count - 1)
						pSink->lpVtbl->EndFigure(pSink, D2D1_FIGURE_END_CLOSED)
						pSink->lpVtbl->Close(pSink)
						pSink->lpVtbl->Release(pSink)
						pRenderTarget->lpVtbl->DrawGeometry(pRenderTarget, Cast(ID2D1Geometry Ptr, pGeometry), Cast(ID2D1Brush Ptr, pBrushBorder), DrawWidth, pStrokeStyle)
						pRenderTarget->lpVtbl->FillGeometry(pRenderTarget, Cast(ID2D1Geometry Ptr, pGeometry), Cast(ID2D1Brush Ptr, pBrushFill), NULL) 'pBrushOpacity
					End If
					pGeometry->lpVtbl->Release(pGeometry)
				End If
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				Dim tGpPoints(Count - 1) As GpPointF
				For i As Integer = 0 To Count - 1
					tGpPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX
					tGpPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				If GdipBrush Then GdipFillPolygon GdipGraphics, GdipBrush, @tGpPoints(0), Count, FillMode
				GdipDrawPolygon GdipGraphics, GdipPen, Cast(GpPointF Ptr, @tGpPoints(0)), Count
			Else
				Dim tPoints(Count - 1) As Point
				For i As Integer = 0 To Count - 1
					tPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX : tPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				.Polygon Handle, Cast(..Point Ptr, @tPoints(0)), Count
			End If
		#else
			Print "The function is not ready in this OS."  & "   Canvas.Polygon(Points() As Point, Count As Long)"
		#endif
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
		Dim As Single sx = ScaleX(x) * imgScaleX + imgOffsetX, sy = ScaleY(y) * imgScaleY + imgOffsetY
		Dim As Single sw = ScaleX(x1 - x) * imgScaleX, sh = ScaleY(y1 - y) * imgScaleY
		If sw <= 0 OrElse sh <= 0 Then Return
		
		Dim As Double cx = sx + sw / 2, cy = sy + sh / 2
		Dim As Double sX_ = ScaleX(nXRadial1) * imgScaleX + imgOffsetX, sY_ = ScaleY(nYRadial1) * imgScaleY + imgOffsetY
		Dim As Double eX_ = ScaleX(nXRadial2) * imgScaleX + imgOffsetX, eY_ = ScaleY(nYRadial2) * imgScaleY + imgOffsetY
		
		Dim As Double startAngle = Atan2(sY_ - cy, sX_ - cx)
		Dim As Double endAngle = Atan2(eY_ - cy, eX_ - cx)
		Dim As Double sweepAngle = endAngle - startAngle
		If sweepAngle <= 0 Then sweepAngle += 2 * G_PI
		
		#ifdef __USE_CAIRO__
			cairo_move_to(Handle, sX_, sY_)
			Dim As Double r = Min(sw, sh) / 2
			' 如果是椭圆需要 Save/Scale/Restore，此处简化采用半径较小的圆
			cairo_arc(Handle, cx, cy, r, startAngle, endAngle)
			cairo_close_path(Handle) ' 闭合弦
			cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
			cairo_fill_preserve(Handle)
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				Dim pGeometry As ID2D1PathGeometry Ptr
				If pD2D1Factory->lpVtbl->CreatePathGeometry(pD2D1Factory, @pGeometry) = S_OK Then
					'If pGeometry = 0 Then Print __FUNCTION__ & " Line: " & __LINE__ & ": can not run CreatePathGeometry! pD2D1Factory=" & pD2D1Factory : Return
					Dim pSink As ID2D1GeometrySink Ptr
					If pGeometry->lpVtbl->Open(pGeometry, @pSink) = S_OK Then
						Dim As D2D1_ARC_SEGMENT arcSeg
						arcSeg.point = Type<D2D1_POINT_2F>(eX_, eY_)
						arcSeg.size = Type<D2D1_SIZE_F>(sw / 2, sh / 2)
						arcSeg.rotationAngle = 0
						arcSeg.sweepDirection = D2D1_SWEEP_DIRECTION_CLOCKWISE
						arcSeg.arcSize = IIf(sweepAngle > G_PI, D2D1_ARC_SIZE_LARGE, D2D1_ARC_SIZE_SMALL)
						
						pSink->lpVtbl->SetFillMode(pSink, D2D1_FILL_MODE_WINDING)
						' 从弧的起点开始，画弧到终点，然后闭合图形（自动连回起点形成弦）
						pSink->lpVtbl->BeginFigure(pSink, Type<D2D1_POINT_2F>(sX_, sY_), D2D1_FIGURE_BEGIN_FILLED)
						pSink->lpVtbl->AddArc(pSink, @arcSeg)
						pSink->lpVtbl->EndFigure(pSink, D2D1_FIGURE_END_CLOSED)
						pSink->lpVtbl->Close(pSink)
						pSink->lpVtbl->Release(pSink)
						If pBrushFill Then pRenderTarget->lpVtbl->FillGeometry(pRenderTarget, Cast(ID2D1Geometry Ptr, pGeometry), Cast(ID2D1Brush Ptr, pBrushFill), NULL)
						pRenderTarget->lpVtbl->DrawGeometry(pRenderTarget, Cast(ID2D1Geometry Ptr, pGeometry), Cast(ID2D1Brush Ptr, pBrushBorder), DrawWidth, pStrokeStyle)
					End If
					pGeometry->lpVtbl->Release(pGeometry)
				End If
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				Dim As Double startAngleDeg = startAngle * 180.0 / G_PI
				Dim As Double sweepAngleDeg = sweepAngle * 180.0 / G_PI
				
				' GDI+ 没有直接的 GdipDrawChord，需要用 Path 实现
				Dim As GpPath Ptr path
				GdipCreatePath(0, @path)
				GdipAddPathArc(path, sx, sy, sw, sh, startAngleDeg, sweepAngleDeg)
				GdipClosePathFigure(path) ' 闭合
				
				If GdipBrush Then GdipFillPath(GdipGraphics, GdipBrush, path)
				GdipDrawPath(GdipGraphics, GdipPen, path)
				GdipDeletePath(path)
			Else
				.Chord(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(nXRadial1) * imgScaleX, ScaleY(nYRadial1) * imgScaleY, ScaleX(nXRadial2) * imgScaleX, ScaleY(nYRadial2) * imgScaleY)
			End If
		#else
			Print "The function is not ready in this OS." & "  Canvas.Chord(x As Double, y As Double, x1 As Double, y1 As Double, nXRadial1 As Double, nYRadial1 As Double, nXRadial2 As Double, nYRadial2 As Double))"
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Pie(x As Double, y As Double, x1 As Double, y1 As Double, nXRadial1 As Double, nYRadial1 As Double, nXRadial2 As Double, nYRadial2 As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		
		Dim As Single sx = ScaleX(x) * imgScaleX + imgOffsetX, sy = ScaleY(y) * imgScaleY + imgOffsetY
		Dim As Single sw = ScaleX(x1 - x) * imgScaleX, sh = ScaleY(y1 - y) * imgScaleY
		If sw <= 0 OrElse sh <= 0 Then Return
		
		Dim As Double cx = sx + sw / 2, cy = sy + sh / 2
		Dim As Double sX_ = ScaleX(nXRadial1) * imgScaleX + imgOffsetX, sY_ = ScaleY(nYRadial1) * imgScaleY + imgOffsetY
		Dim As Double eX_ = ScaleX(nXRadial2) * imgScaleX + imgOffsetX, eY_ = ScaleY(nYRadial2) * imgScaleY + imgOffsetY
		
		Dim As Double startAngle = Atan2(sY_ - cy, sX_ - cx)
		Dim As Double endAngle = Atan2(eY_ - cy, eX_ - cx)
		Dim As Double sweepAngle = endAngle - startAngle
		If sweepAngle <= 0 Then sweepAngle += 2 * G_PI
		#ifdef __USE_CAIRO__
			Dim As Double r = Min(sw, sh) / 2
			cairo_move_to(Handle, cx, cy) ' 移动到圆心
			cairo_line_to(Handle, sX_, sY_) ' 连线到弧起点
			cairo_arc(Handle, cx, cy, r, startAngle, endAngle)
			cairo_close_path(Handle) ' 闭合回圆心
			cairo_set_source_rgb(Handle, GetRedD(Brush.Color), GetGreenD(Brush.Color), GetBlueD(Brush.Color))
			cairo_fill_preserve(Handle)
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				Dim pGeometry As ID2D1PathGeometry Ptr
				If pD2D1Factory->lpVtbl->CreatePathGeometry(pD2D1Factory, @pGeometry) = S_OK Then
					'If pGeometry = 0 Then Print __FUNCTION__ & " Line: " & __LINE__ & ": can not run CreatePathGeometry! pD2D1Factory=" & pD2D1Factory : Return
					Dim pSink As ID2D1GeometrySink Ptr
					If pGeometry->lpVtbl->Open(pGeometry, @pSink) = S_OK Then
						Dim As D2D1_ARC_SEGMENT arcSeg
						arcSeg.point = Type<D2D1_POINT_2F>(eX_,eY_)
						arcSeg.size = Type<D2D1_SIZE_F>(sw / 2, sh / 2)
						arcSeg.rotationAngle = 0
						arcSeg.sweepDirection = D2D1_SWEEP_DIRECTION_CLOCKWISE
						arcSeg.arcSize = IIf(sweepAngle > G_PI, D2D1_ARC_SIZE_LARGE, D2D1_ARC_SIZE_SMALL)
						
						pSink->lpVtbl->SetFillMode(pSink, D2D1_FILL_MODE_WINDING)
						pSink->lpVtbl->BeginFigure(pSink, Type<D2D1_POINT_2F>(cx, cy), D2D1_FIGURE_BEGIN_FILLED)
						pSink->lpVtbl->AddLine(pSink, Type<D2D1_POINT_2F>(sX_, sY_))
						pSink->lpVtbl->AddArc(pSink, @arcSeg)
						pSink->lpVtbl->EndFigure(pSink, D2D1_FIGURE_END_CLOSED) ' 闭合回圆心
						pSink->lpVtbl->Close(pSink)
						pSink->lpVtbl->Release(pSink)
						If pBrushFill Then pRenderTarget->lpVtbl->FillGeometry(pRenderTarget, Cast(ID2D1Geometry Ptr, pGeometry), Cast(ID2D1Brush Ptr, pBrushFill), NULL)
						pRenderTarget->lpVtbl->DrawGeometry(pRenderTarget, Cast(ID2D1Geometry Ptr, pGeometry), Cast(ID2D1Brush Ptr, pBrushBorder), DrawWidth, pStrokeStyle)
					End If
					pGeometry->lpVtbl->Release(pGeometry)
				End If
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				Dim As Double startAngleDeg = startAngle * 180.0 / G_PI
				Dim As Double sweepAngleDeg = sweepAngle * 180.0 / G_PI
				If GdipBrush Then GdipFillPie(GdipGraphics, GdipBrush, sx, sy, sw, sh, startAngleDeg, sweepAngleDeg)
				GdipDrawPie(GdipGraphics, GdipPen, sx, sy, sw, sh, startAngleDeg, sweepAngleDeg)
			Else
				.Pie(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(nXRadial1) * imgScaleX, ScaleY(nYRadial1) * imgScaleY, ScaleX(nXRadial2) * imgScaleX , ScaleY(nYRadial2) * imgScaleY)
			End If
		#else
			Print "The function is not ready in this OS." & "  Canvas.Pie(x As Double, y As Double, x1 As Double, y1 As Double, nXRadial1 As Double, nYRadial1 As Double, nXRadial2 As Double, nYRadial2 As Double)"
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Arc(x As Double, y As Double, x1 As Double, y1 As Double, xStart As Double, yStart As Double, xEnd As Double, yEnd As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		
		Dim As Single sx = ScaleX(x) * imgScaleX + imgOffsetX, sy = ScaleY(y) * imgScaleY + imgOffsetY
		Dim As Single sw = ScaleX(x1 - x) * imgScaleX, sh = ScaleY(y1 - y) * imgScaleY
		If sw <= 0 OrElse sh <= 0 Then Return ' 防止除零
		
		Dim As Double cx = sx + sw / 2, cy = sy + sh / 2
		Dim As Double sX_ = ScaleX(xStart) * imgScaleX + imgOffsetX, sY_ = ScaleY(yStart) * imgScaleY + imgOffsetY
		Dim As Double eX_ = ScaleX(xEnd) * imgScaleX + imgOffsetX, eY_ = ScaleY(yEnd) * imgScaleY + imgOffsetY
		
		' 计算起始角和扫掠角 (弧度)
		Dim As Double startAngle = Atan2(sY_ - cy, sX_ - cx)
		Dim As Double endAngle = Atan2(eY_ - cy, eX_ - cx)
		Dim As Double sweepAngle = endAngle - startAngle
		If sweepAngle <= 0 Then sweepAngle += 2 * G_PI ' 保证逆时针/顺时针一致性
		
		#ifdef __USE_CAIRO__
			' Cairo 的逻辑已在之前提供，此处省略或保留原有
			cairo_move_to Handle, ScaleX(x) * imgScaleX + imgOffsetX - 0.5, ScaleY(y) * imgScaleY + imgOffsetY - 0.5
			cairo_arc(Handle, cx, cy, Min(sw, sh) / 2, startAngle, endAngle)
			cairo_stroke(Handle)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				Dim pGeometry As ID2D1PathGeometry Ptr
				If pD2D1Factory->lpVtbl->CreatePathGeometry(pD2D1Factory, @pGeometry) = S_OK Then
					'If pGeometry = 0 Then Print __FUNCTION__ & " Line: " & __LINE__ & ": can not run CreatePathGeometry! pD2D1Factory=" & pD2D1Factory : Return
					Dim pSink As ID2D1GeometrySink Ptr
					If pGeometry->lpVtbl->Open(pGeometry, @pSink) = S_OK Then
						Dim As D2D1_ARC_SEGMENT arcSeg
						arcSeg.point = Type<D2D1_POINT_2F>(eX_, eY_) ' 终点
						arcSeg.size = Type<D2D1_SIZE_F>(sw / 2, sh / 2)
						arcSeg.rotationAngle = 0
						arcSeg.sweepDirection = D2D1_SWEEP_DIRECTION_CLOCKWISE
						arcSeg.arcSize = IIf(sweepAngle > G_PI, D2D1_ARC_SIZE_LARGE, D2D1_ARC_SIZE_SMALL)
						
						pSink->lpVtbl->SetFillMode(pSink, D2D1_FILL_MODE_WINDING)
						pSink->lpVtbl->BeginFigure(pSink, Type<D2D1_POINT_2F>(sX_, sY_), D2D1_FIGURE_BEGIN_FILLED)
						pSink->lpVtbl->AddArc(pSink, @arcSeg)
						pSink->lpVtbl->EndFigure(pSink, D2D1_FIGURE_END_OPEN)
						pSink->lpVtbl->Close(pSink)
						pSink->lpVtbl->Release(pSink)
						pRenderTarget->lpVtbl->DrawGeometry(pRenderTarget, Cast(ID2D1Geometry Ptr, pGeometry), Cast(ID2D1Brush Ptr, pBrushBorder),DrawWidth, pStrokeStyle)
					End If
					pGeometry->lpVtbl->Release(pGeometry)
				End If
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				' GDI+ 需要角度制
				Dim As Double startAngleDeg = startAngle * 180.0 / G_PI
				Dim As Double sweepAngleDeg = sweepAngle * 180.0 / G_PI
				GdipDrawArc(GdipGraphics, GdipPen, sx, sy, sw, sh, startAngleDeg, sweepAngleDeg)
			Else
				.Arc(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(xStart) * imgScaleX + imgOffsetX, ScaleY(yStart) * imgScaleY + imgOffsetY, ScaleX(xEnd) * imgScaleX + imgOffsetX, ScaleY(yEnd) * imgScaleY + imgOffsetY)
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.ArcTo(x As Double, y As Double, x1 As Double, y1 As Double, nXRadial1 As Double, nYRadial1 As Double, nXRadial2 As Double, nYRadial2 As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		
		Dim As Single sx = ScaleX(x) * imgScaleX + imgOffsetX, sy = ScaleY(y) * imgScaleY + imgOffsetY
		Dim As Single sw = ScaleX(x1 - x) * imgScaleX, sh = ScaleY(y1 - y) * imgScaleY
		If sw <= 0 OrElse sh <= 0 Then Return
		
		Dim As Double cx = sx + sw / 2, cy = sy + sh / 2
		Dim As Double sX_ = ScaleX(nXRadial1) * imgScaleX + imgOffsetX, sY_ = ScaleY(nYRadial1) * imgScaleY + imgOffsetY
		Dim As Double eX_ = ScaleX(nXRadial2) * imgScaleX + imgOffsetX, eY_ = ScaleY(nYRadial2) * imgScaleY + imgOffsetY
		
		Dim As Double startAngle = Atan2(sY_ - cy, sX_ - cx)
		Dim As Double endAngle = Atan2(eY_ - cy, eX_ - cx)
		Dim As Double sweepAngle = endAngle - startAngle
		If sweepAngle <= 0 Then sweepAngle += 2 * G_PI
		
		#ifdef __USE_CAIRO__
			Dim As Double r = Min(sw, sh) / 2
			cairo_move_to(Handle, FMoveToX, FMoveToY)
			cairo_line_to(Handle, sX_, sY_) ' 连线到弧起点
			cairo_arc(Handle, cx, cy, r, startAngle, endAngle)
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
			' 更新当前点
			FMoveToX = eX_: FMoveToY = eY_
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				Dim pGeometry As ID2D1PathGeometry Ptr
				If pD2D1Factory->lpVtbl->CreatePathGeometry(pD2D1Factory, @pGeometry) = S_OK Then
					'If pGeometry = 0 Then Print __FUNCTION__ & " Line: " & __LINE__ & ": can not run CreatePathGeometry! pD2D1Factory=" & pD2D1Factory : Return
					Dim pSink As ID2D1GeometrySink Ptr
					If pGeometry->lpVtbl->Open(pGeometry,@pSink) = S_OK Then
						Dim As D2D1_ARC_SEGMENT arcSeg
						arcSeg.point = Type<D2D1_POINT_2F>(eX_, eY_) ' 终点
						arcSeg.size = Type<D2D1_SIZE_F>(sw / 2, sh / 2)
						arcSeg.rotationAngle = 0
						arcSeg.sweepDirection = D2D1_SWEEP_DIRECTION_CLOCKWISE
						arcSeg.arcSize = IIf(sweepAngle > G_PI, D2D1_ARC_SIZE_LARGE, D2D1_ARC_SIZE_SMALL)
						
						pSink->lpVtbl->SetFillMode(pSink, D2D1_FILL_MODE_WINDING)
						pSink->lpVtbl->BeginFigure(pSink, Type<D2D1_POINT_2F>(sX_, sY_), D2D1_FIGURE_BEGIN_FILLED)
						pSink->lpVtbl->AddArc(pSink, @arcSeg)
						pSink->lpVtbl->EndFigure(pSink, D2D1_FIGURE_END_OPEN)
						pSink->lpVtbl->Close(pSink)
						pSink->lpVtbl->Release(pSink)
						pRenderTarget->lpVtbl->DrawGeometry(pRenderTarget, Cast(ID2D1Geometry Ptr, pGeometry), Cast(ID2D1Brush Ptr, pBrushBorder),DrawWidth, pStrokeStyle)
					End If
					pGeometry->lpVtbl->Release(pGeometry)
				End If
				' 更新点到弧终点
				FMoveToX = eX_: FMoveToY = eY_
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				Dim As Double startAngleDeg = startAngle * 180.0 / G_PI
				Dim As Double sweepAngleDeg = sweepAngle * 180.0 / G_PI
				GdipDrawLine(GdipGraphics, GdipPen, FMoveToX, FMoveToY, sX_, sY_)
				GdipDrawArc(GdipGraphics, GdipPen, sx, sy, sw, sh, startAngleDeg, sweepAngleDeg)
				FMoveToX = eX_: FMoveToY = eY_
			Else
				.ArcTo Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y)*imgScaleY + imgOffsetY, ScaleX(x1) * imgScaleX + imgOffsetX, ScaleY(y1) * imgScaleY + imgOffsetY, ScaleX(nXRadial1) * imgScaleX , ScaleY(nYRadial1) * imgScaleY, ScaleX(nXRadial2) * imgScaleX, ScaleY(nYRadial2) * imgScaleY
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.AngleArc(x As Double, y As Double, Radius As Double, startAngle As Double, sweepAngle As Double)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		Dim As Single cx = ScaleX(x) * imgScaleX + imgOffsetX
		Dim As Single cy = ScaleY(y) * imgScaleY + imgOffsetY
		Dim As Single r = ScaleX(Radius) * imgScaleX ' 假设各向同性缩放
		
		#ifdef __USE_CAIRO__
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			' Cairo的角度是弧度，且Y轴向下为正，因此负的sweepAngle对应GDI的正sweepAngle
			cairo_arc(Handle, cx, cy, r, -startAngle * G_PI / 180.0, -(startAngle + sweepAngle) * G_PI / 180.0)
			cairo_stroke(Handle)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				Dim pGeometry As ID2D1PathGeometry Ptr
				If pD2D1Factory->lpVtbl->CreatePathGeometry(pD2D1Factory, @pGeometry) = S_OK Then
					'If pGeometry = 0 Then Print __FUNCTION__ & " Line: " & __LINE__ & ": can not run CreatePathGeometry! pD2D1Factory=" & pD2D1Factory : Return
					Dim pSink As ID2D1GeometrySink Ptr
					If pGeometry->lpVtbl->Open(pGeometry, @pSink) = S_OK Then
						Dim As Single startRad = startAngle * G_PI / 180.0
						Dim As Single endRad = (startAngle + sweepAngle) * G_PI / 180.0
						
						' 计算起点和终点
						Dim As D2D1_POINT_2F startPoint = Type<D2D1_POINT_2F>(cx + r * Cos(startRad), cy - r * Sin(startRad))
						Dim As D2D1_POINT_2F endPoint = Type<D2D1_POINT_2F>(cx + r * Cos(endRad), cy - r * Sin(endRad))
						
						Dim As D2D1_ARC_SEGMENT arcSeg
						arcSeg.point = endPoint
						arcSeg.size = Type<D2D1_SIZE_F>(r, r)
						arcSeg.rotationAngle = 0
						arcSeg.sweepDirection = IIf(sweepAngle >= 0, D2D1_SWEEP_DIRECTION_COUNTER_CLOCKWISE, D2D1_SWEEP_DIRECTION_CLOCKWISE)
						arcSeg.arcSize = IIf(Abs(sweepAngle) > 180, D2D1_ARC_SIZE_LARGE, D2D1_ARC_SIZE_SMALL)
						
						pSink->lpVtbl->BeginFigure(pSink, startPoint, D2D1_FIGURE_BEGIN_FILLED)
						pSink->lpVtbl->AddArc(pSink, @arcSeg)
						pSink->lpVtbl->EndFigure(pSink, D2D1_FIGURE_END_OPEN)
						pSink->lpVtbl->Close(pSink)
						pSink->lpVtbl->Release(pSink)
						pRenderTarget->lpVtbl->DrawGeometry(pRenderTarget, Cast(ID2D1Geometry Ptr, pGeometry), Cast(ID2D1Brush Ptr, pBrushBorder),DrawWidth, pStrokeStyle)
					End If
					pGeometry->lpVtbl->Release(pGeometry)
				End If
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				' 修复GDI+边界框：需转换为外接矩形
				Dim As Single sx = cx - r, sy = cy - r
				Dim As Single sw = r * 2, sh = r * 2
				GdipDrawArc(GdipGraphics, GdipPen, sx, sy, sw, sh, startAngle, sweepAngle)
			Else
				.MoveToEx Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, 0
				.AngleArc Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, ScaleX(Radius) * imgScaleX, startAngle, sweepAngle
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Polyline(Points() As Point, Count As Long)
		If Count < 2 Then Return
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		#ifdef __USE_CAIRO__
			cairo_move_to(Handle, ScaleX(Points(0).X) * imgScaleX + imgOffsetX - 0.5, ScaleY(Points(0).Y) * imgScaleY + imgOffsetY - 0.5)
			For i As Integer = 1 To Count - 1
				cairo_line_to(Handle, ScaleX(Points(i).X) * imgScaleX + imgOffsetX - 0.5, ScaleY(Points(i).Y) * imgScaleY + imgOffsetY - 0.5)
			Next
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle) ' 折线不闭合不填充
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				Dim pGeometry As ID2D1PathGeometry Ptr
				If pD2D1Factory->lpVtbl->CreatePathGeometry(pD2D1Factory, @pGeometry) = S_OK Then
					Dim pSink As ID2D1GeometrySink Ptr
					If pGeometry->lpVtbl->Open(pGeometry, @pSink) = S_OK Then
						Dim pD2DPoints(0 To Count - 1) As D2D1_POINT_2F
						pSink->lpVtbl->SetFillMode(pSink, D2D1_FILL_MODE_WINDING)
						For i As Integer = 0 To Count - 1
							pD2DPoints(i) = Type<D2D1_POINT_2F>(ScaleX(Points(i).X) * imgScaleX + imgOffsetX, ScaleY(Points(i).Y) * imgScaleY + imgOffsetY)
						Next
						pSink->lpVtbl->BeginFigure(pSink, pD2DPoints(0), D2D1_FIGURE_BEGIN_FILLED)
						pSink->lpVtbl->AddLines(pSink, @pD2DPoints(1), Count - 1)
						pSink->lpVtbl->EndFigure(pSink, D2D1_FIGURE_END_CLOSED)
						pSink->lpVtbl->Close(pSink)
						pSink->lpVtbl->Release(pSink)
						pRenderTarget->lpVtbl->DrawGeometry(pRenderTarget, Cast(ID2D1Geometry Ptr, pGeometry), Cast(ID2D1Brush Ptr, pBrushBorder), DrawWidth, pStrokeStyle)
					End If
					pGeometry->lpVtbl->Release(pGeometry)
				End If
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				Dim tGpPoints(Count - 1) As GpPointF
				For i As Integer = 0 To Count - 1
					tGpPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX
					tGpPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				GdipDrawLines GdipGraphics, GdipPen, Cast(GpPointF Ptr, @tGpPoints(0)), Count
			Else
				Dim tPoints(Count - 1) As Point
				For i As Integer = 0 To Count - 1
					tPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX : tPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				.Polyline Handle, Cast(..Point Ptr, @tPoints(0)), Count
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.PolylineTo(Points() As Point, Count As Long)
		If Count < 2 Then Return
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		#ifdef __USE_CAIRO__
			cairo_move_to(Handle, FMoveToX, FMoveToY)
			For i As Integer = 0 To Count - 1
				Dim As Double px = ScaleX(Points(i).X) * imgScaleX + imgOffsetX - 0.5
				Dim As Double py = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY - 0.5
				cairo_line_to(Handle, px, py)
			Next
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
			FMoveToX = ScaleX(Points(Count-1).X) * imgScaleX + imgOffsetX - 0.5
			FMoveToY = ScaleY(Points(Count - 1).Y) * imgScaleY + imgOffsetY - 0.5
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				Dim pGeometry As ID2D1PathGeometry Ptr
				If pD2D1Factory->lpVtbl->CreatePathGeometry(pD2D1Factory, @pGeometry) = S_OK Then
					Dim pSink As ID2D1GeometrySink Ptr
					If pGeometry->lpVtbl->Open(pGeometry, @pSink) = S_OK Then
						Dim pD2DPoints(0 To Count - 1) As D2D1_POINT_2F
						pSink->lpVtbl->SetFillMode(pSink, D2D1_FILL_MODE_WINDING)
						For i As Integer = 0 To Count - 1
							pD2DPoints(i) = Type<D2D1_POINT_2F>(ScaleX(Points(i).X) * imgScaleX + imgOffsetX, ScaleY(Points(i).Y) * imgScaleY + imgOffsetY)
						Next
						pSink->lpVtbl->BeginFigure(pSink, pD2DPoints(0), D2D1_FIGURE_BEGIN_FILLED)
						pSink->lpVtbl->AddLines(pSink, @pD2DPoints(1), Count - 1)
						pSink->lpVtbl->EndFigure(pSink, D2D1_FIGURE_END_CLOSED)
						pSink->lpVtbl->Close(pSink)
						pSink->lpVtbl->Release(pSink)
						pRenderTarget->lpVtbl->DrawGeometry(pRenderTarget, Cast(ID2D1Geometry Ptr, pGeometry), Cast(ID2D1Brush Ptr, pBrushBorder), DrawWidth, pStrokeStyle)
					End If
					pGeometry->lpVtbl->Release(pGeometry)
				End If
				FMoveToX = ScaleX(Points(Count - 1).X) * imgScaleX + imgOffsetX
				FMoveToY = ScaleY(Points(Count - 1).Y) * imgScaleY + imgOffsetY
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				' 修复：PolylineTo应闭合，需加入起点(FMoveToX, FMoveToY)
				Dim tGpPoints(Count) As GpPointF ' 多一个起点
				tGpPoints(0).X = FMoveToX: tGpPoints(0).Y = FMoveToY
				For i As Integer = 0 To Count - 1
					tGpPoints(i+1).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX
					tGpPoints(i+1).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				GdipDrawLines GdipGraphics, GdipPen, Cast(GpPointF Ptr, @tGpPoints(0)), Count + 1
				FMoveToX = tGpPoints(Count).X: FMoveToY = tGpPoints(Count).Y
			Else
				Dim tPoints(Count - 1) As Point
				For i As Integer = 0 To Count - 1
					tPoints(i).X = ScaleX(Points(i).X)*imgScaleX + imgOffsetX : tPoints(i).Y = ScaleY(Points(i).Y)*imgScaleY + imgOffsetY
				Next
				.PolylineTo Handle, Cast(..Point Ptr, @tPoints(0)), Count
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.PolyBeizer(Points() As Point, Count As Long)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		
		#ifdef __USE_CAIRO__
			If Count < 4 Then Return
			cairo_move_to(Handle, ScaleX(Points(0).X) * imgScaleX + imgOffsetX - 0.5, ScaleY(Points(0).Y) * imgScaleY + imgOffsetY - 0.5)
			Dim i As Integer = 1
			While i + 2 <= Count - 1
				cairo_curve_to(Handle, _
				ScaleX(Points(i).X) * imgScaleX + imgOffsetX - 0.5, ScaleY(Points(i).Y) * imgScaleY + imgOffsetY - 0.5, _
				ScaleX(Points(i + 1).X) * imgScaleX + imgOffsetX - 0.5, ScaleY(Points(i + 1).Y) * imgScaleY + imgOffsetY - 0.5, _
				ScaleX(Points(i + 2).X) * imgScaleX + imgOffsetX - 0.5, ScaleY(Points(i + 2).Y) * imgScaleY + imgOffsetY - 0.5)
				i += 3
			Wend
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				Dim pGeometry As ID2D1PathGeometry Ptr
				If pD2D1Factory->lpVtbl->CreatePathGeometry(pD2D1Factory, @pGeometry) = S_OK Then
					'If pGeometry = 0 Then Print __FUNCTION__ & " Line: " & __LINE__ & ": can not run CreatePathGeometry! pD2D1Factory=" & pD2D1Factory : Return
					Dim pSink As ID2D1GeometrySink Ptr
					If pGeometry->lpVtbl->Open(pGeometry, @pSink) = S_OK Then
						Dim pBegin As D2D1_POINT_2F = Type<D2D1_POINT_2F>(ScaleX(Points(0).X)*imgScaleX + imgOffsetX, ScaleY(Points(0).Y)*imgScaleY + imgOffsetY)
						pSink->lpVtbl->BeginFigure(pSink, pBegin, D2D1_FIGURE_BEGIN_FILLED)
						Dim i As Integer = 1
						While i + 2 <= Count - 1
							Dim bezSeg As D2D1_BEZIER_SEGMENT
							bezSeg.point1 = Type<D2D1_POINT_2F>(ScaleX(Points(i).X)*imgScaleX + imgOffsetX, ScaleY(Points(i).Y)*imgScaleY + imgOffsetY)
							bezSeg.point2 = Type<D2D1_POINT_2F>(ScaleX(Points(i + 1).X)*imgScaleX + imgOffsetX, ScaleY(Points(i + 1).Y)*imgScaleY + imgOffsetY)
							bezSeg.point3 = Type<D2D1_POINT_2F>(ScaleX(Points(i + 2).X)*imgScaleX + imgOffsetX, ScaleY(Points(i + 2).Y)*imgScaleY + imgOffsetY)
							pSink->lpVtbl->AddBezier(pSink, @bezSeg)
							i += 3
						Wend
						
						pSink->lpVtbl->EndFigure(pSink, D2D1_FIGURE_END_OPEN)
						pSink->lpVtbl->Close(pSink)
						pSink->lpVtbl->Release(pSink)
						pRenderTarget->lpVtbl->DrawGeometry(pRenderTarget, Cast(ID2D1Geometry Ptr, pGeometry), Cast(ID2D1Brush Ptr, pBrushBorder),DrawWidth, pStrokeStyle)
					End If
					pGeometry->lpVtbl->Release(pGeometry)
				End If
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				Dim tGpPoints(Count - 1) As GpPointF
				For i As Integer = 0 To Count - 1
					tGpPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX
					tGpPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				If GdipBrush Then GdipFillClosedCurve(GdipGraphics, GdipBrush, Cast(GpPointF Ptr, @tGpPoints(0)), Count)
				GdipDrawBeziers(GdipGraphics, GdipPen, Cast(GpPointF Ptr, @tGpPoints(0)), Count)
			Else
				Dim tPoints(Count - 1) As Point
				For i As Integer = 0 To Count - 1
					tPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX : tPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				.PolyBezier Handle, Cast(..Point Ptr, @tPoints(0)), Count
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.PolyBeizerTo(Points() As Point, Count As Long)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		#ifdef __USE_CAIRO__
			If Count < 3 Then Return
			cairo_move_to(Handle, FMoveToX, FMoveToY)
			Dim i As Integer = 0
			While i + 2 <= Count - 1
				cairo_curve_to(Handle, _
				ScaleX(Points(i).X)*imgScaleX + imgOffsetX - 0.5, ScaleY(Points(i).Y)*imgScaleY + imgOffsetY - 0.5, _
				ScaleX(Points(i + 1).X)*imgScaleX + imgOffsetX - 0.5, ScaleY(Points(i + 1).Y)*imgScaleY + imgOffsetY - 0.5, _
				ScaleX(Points(i + 2).X)*imgScaleX + imgOffsetX - 0.5, ScaleY(Points(i + 2).Y)*imgScaleY + imgOffsetY - 0.5)
				i += 3
			Wend
			cairo_set_source_rgb(Handle, GetRedD(Pen.Color), GetGreenD(Pen.Color), GetBlueD(Pen.Color))
			cairo_stroke(Handle)
			FMoveToX = ScaleX(Points(Count - 1).X)*imgScaleX + imgOffsetX - 0.5
			FMoveToY = ScaleY(Points(Count - 1).Y)*imgScaleY + imgOffsetY - 0.5
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				Dim pGeometry As ID2D1PathGeometry Ptr
				If pD2D1Factory->lpVtbl->CreatePathGeometry(pD2D1Factory, @pGeometry) = S_OK Then
					'If pGeometry = 0 Then Print __FUNCTION__ & " Line: " & __LINE__ & ": can not run CreatePathGeometry! pD2D1Factory=" & pD2D1Factory : Return
					Dim pSink As ID2D1GeometrySink Ptr
					If pGeometry->lpVtbl->Open(pGeometry, @pSink) = S_OK Then
						Dim pBegin As D2D1_POINT_2F = Type<D2D1_POINT_2F>(ScaleX(Points(0).X)*imgScaleX + imgOffsetX, ScaleY(Points(0).Y)*imgScaleY + imgOffsetY)
						pSink->lpVtbl->BeginFigure(pSink, pBegin, D2D1_FIGURE_BEGIN_FILLED)
						Dim i As Integer = 1
						While i + 2 <= Count - 1
							Dim bezSeg As D2D1_BEZIER_SEGMENT
							bezSeg.point1 = Type<D2D1_POINT_2F>(ScaleX(Points(i).X)*imgScaleX + imgOffsetX, ScaleY(Points(i).Y)*imgScaleY + imgOffsetY)
							bezSeg.point2 = Type<D2D1_POINT_2F>(ScaleX(Points(i + 1).X)*imgScaleX + imgOffsetX, ScaleY(Points(i + 1).Y)*imgScaleY + imgOffsetY)
							bezSeg.point3 = Type<D2D1_POINT_2F>(ScaleX(Points(i + 2).X)*imgScaleX + imgOffsetX, ScaleY(Points(i + 2).Y)*imgScaleY + imgOffsetY)
							pSink->lpVtbl->AddBezier(pSink, @bezSeg)
							i += 3
						Wend
						
						pSink->lpVtbl->EndFigure(pSink, D2D1_FIGURE_END_OPEN)
						pSink->lpVtbl->Close(pSink)
						pSink->lpVtbl->Release(pSink)
						pRenderTarget->lpVtbl->DrawGeometry(pRenderTarget, Cast(ID2D1Geometry Ptr, pGeometry), Cast(ID2D1Brush Ptr, pBrushBorder), DrawWidth, pStrokeStyle)
					End If
					pGeometry->lpVtbl->Release(pGeometry)
				End If
				FMoveToX = ScaleX(Points(Count - 1).X)*imgScaleX + imgOffsetX
				FMoveToY = ScaleY(Points(Count - 1).Y)*imgScaleY + imgOffsetY
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				Dim tGpPoints(Count - 1) As GpPointF
				For i As Integer = 0 To Count - 1
					tGpPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX
					tGpPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				'GdipFillPolygon GdipGraphics, GdipPen, Cast(GpPointF Ptr, @tGpPoints(0)), Count
				GdipDrawBeziers GdipGraphics, GdipPen, Cast(GpPointF Ptr, @tGpPoints(0)), Count
			Else
				Dim tPoints(Count - 1) As Point
				For i As Integer = 0 To Count - 1
					tPoints(i).X = ScaleX(Points(i).X) * imgScaleX + imgOffsetX : tPoints(i).Y = ScaleY(Points(i).Y) * imgScaleY + imgOffsetY
				Next
				.PolyBezierTo Handle, Cast(..Point Ptr, @tPoints(0)), Count
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.SetPixel(x As Double, y As Double, PixelColor As Integer)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		Dim As Single px = ScaleX(x) * imgScaleX + imgOffsetX
		Dim As Single py = ScaleY(y) * imgScaleY + imgOffsetY
		#ifdef __USE_CAIRO__
			' 修复：RGB顺序和数值(0-1)
			cairo_set_source_rgb(Handle, GetRed(PixelColor) / 255.0, GetGreen(PixelColor) / 255.0, GetBlue(PixelColor) / 255.0)
			cairo_rectangle(Handle, px, py, 1, 1)
			cairo_fill(Handle)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
				' D2D使用1x1矩形填充模拟
				Dim As Double iRed = GetRed(PixelColor) / 255.0, iGreen = GetGreen(PixelColor) / 255.0, iBlue = GetBlue(PixelColor) / 255.0
				Dim As ID2D1SolidColorBrush Ptr pPixelBrush = 0
				pRenderTarget->lpVtbl->CreateSolidColorBrush(pRenderTarget, @Type<D2D1_COLOR_F>(iRed, iGreen, iBlue, 1.0), 0, @pPixelBrush)
				If pPixelBrush Then
					pRenderTarget->lpVtbl->FillRectangle(pRenderTarget, @Type<D2D1_RECT_F>(px, py, px + 1, py + 1), Cast(ID2D1Brush Ptr, pPixelBrush))
					pPixelBrush->lpVtbl->Release(pPixelBrush)
				End If
			ElseIf UsingGdip AndAlso GdipGraphics <> 0 Then
				' GDI+ 同样用1x1矩形模拟
				Dim As GpBrush Ptr pPixelBrush = 0
				GdipCreateSolidFill(RGBtoARGB(PixelColor, FillOpacity), Cast(GpSolidFill Ptr Ptr, @pPixelBrush))
				If pPixelBrush Then
					GdipFillRectangle(GdipGraphics, pPixelBrush, px, py, 1, 1)
					GdipDeleteBrush(pPixelBrush)
				End If
			Else
				.SetPixel Handle, px, py, PixelColor
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Function Canvas.GetPixel(x As Double, y As Double) As Integer
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		#ifdef __USE_CAIRO__
			Dim As cairo_surface_t Ptr surface = cairo_get_target(Handle)
			If surface <> 0 Then
				Dim As Integer fmt = cairo_image_surface_get_format(surface)
				If fmt = CAIRO_FORMAT_ARGB32 OrElse fmt = CAIRO_FORMAT_RGB24 Then
					Dim As Integer px = ScaleX(x) * imgScaleX + imgOffsetX
					Dim As Integer py = ScaleY(y) * imgScaleY + imgOffsetY
					Dim As Integer w = cairo_image_surface_get_width(surface)
					Dim As Integer h = cairo_image_surface_get_height(surface)
					If px >= 0 AndAlso py >= 0 AndAlso px < w AndAlso py < h Then
						Dim As Integer stride = cairo_image_surface_get_stride(surface)
						Dim As UByte Ptr dataPtr = cairo_image_surface_get_data(surface)
						If dataPtr <> 0 Then
							Dim As Integer idx = py * stride + px * 4
							Function = RGB(dataPtr[idx + 2], dataPtr[idx + 1], dataPtr[idx])
							If Not HandleSetted Then ReleaseDevice Handle_
							Return 0
						End If
					End If
				End If
			End If
			Function = 0
		#elseif 0
			Function = .GetPixel(Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY)
		#else
			Function = 0
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Function
	
	#ifdef __USE_CAIRO__
		Private Sub Canvas.SetHandle(CanvasHandle As cairo_t Ptr)
			Handle = CanvasHandle
			HandleSetted = True
		End Sub
	#endif
	
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
		Dim As Double StartX = ScaleX(x) * imgScaleX + imgOffsetX
		Dim As Double StartY = ScaleY(y) * imgScaleY + imgOffsetY
		#ifdef __USE_GTK__
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
				cairo_rectangle (Handle, StartX- 0.5, StartY- 0.5, extend2.width, extend2.height)
				cairo_fill (Handle)
			End If
			cairo_move_to(Handle, StartX + 0.5, StartY + extend2.height + 0.5)
			If FG = -1 Then
				iRed = Abs(GetRed(Font.Color) / 255.0): iGreen = Abs(GetGreen(Font.Color) / 255.0): iBlue = Abs(GetBlue(Font.Color) / 255.0)
			Else
				iRed = Abs(GetRed(FG) / 255.0): iGreen = Abs(GetGreen(FG) / 255.0): iBlue = Abs(GetBlue(FG) / 255.0)
			End If
			iRed = Abs(GetRed(FG) / 255.0): iGreen = Abs(GetGreen(FG) / 255.0): iBlue = Abs(GetBlue(FG) / 255.0)
			cairo_set_source_rgb(Handle, iRed, iGreen, iBlue)
			pango_cairo_show_layout_line(Handle, pl)
		#elseif 0
			If FUseDirect2D AndAlso pRenderTarget <> 0 Then
					Dim As ..Size Sz = Type<..Size>(TextWidth(s), TextHeight(s))
					Dim As D2D1_RECT_F Rc = Type<D2D1_RECT_F>(StartX - 1, StartY - 1, StartX + ScaleX(Sz.cx) * imgScaleX + 1, StartY + ScaleY(Sz.cy) * imgScaleY + 1)
					Dim ClrFG As D2D1_COLOR_F
					If FG = -1 Then
						ClrFG = Type<D2D1_COLOR_F>(Abs(GetRed(Font.Color) / 255.0), Abs(GetGreen(Font.Color) / 255.0), Abs(GetBlue(Font.Color) / 255.0), 1.0)
					Else
						ClrFG = Type<D2D1_COLOR_F>(Abs(GetRed(FG) / 255.0), Abs(GetGreen(FG) / 255.0), Abs(GetBlue(FG) / 255.0), 1.0)
					End If
					If pBrushBorder <> 0 Then
						pBrushBorder->lpVtbl->SetColor(pBrushBorder, @ClrFG)
					Else
						pRenderTarget->lpVtbl->CreateSolidColorBrush(pRenderTarget, @ClrFG, 0, @pBrushBorder)
					End If
					If BK <> -1 Then
						Dim Clr As D2D1_COLOR_F  = Type<D2D1_COLOR_F>(Abs(GetRed(BK) / 255.0), Abs(GetGreen(BK) / 255.0), Abs(GetBlue(BK) / 255.0), 1.0)
						Dim pBrushBK As ID2D1SolidColorBrush Ptr = 0
						pRenderTarget->lpVtbl->CreateSolidColorBrush(pRenderTarget, @Clr, 0, @pBrushBK)
						If pBrushBK <> 0 Then
							pRenderTarget->lpVtbl->FillRectangle(pRenderTarget, @Rc, Cast(ID2D1Brush Ptr, pBrushBK))
							pRenderTarget->lpVtbl->DrawRectangle(pRenderTarget, @Rc, Cast(ID2D1Brush Ptr, pBrushBK), 1, NULL)
							pBrushBK->lpVtbl->Release(pBrushBK)
						End If
					End If
					pRenderTarget->lpVtbl->DrawText(pRenderTarget, @s, Len(s), pTextFormat, @Rc, Cast(ID2D1Brush Ptr, pBrushBorder))
			Else
				SetBkMode Handle, TRANSPARENT
				If FG = -1 Then SetTextColor(Handle, Font.Color) Else SetTextColor(Handle, FG)
				If BK = -1 Then
					Brush = GetStockObject(NULL_BRUSH)
				Else
					SetBkColor(Handle, BK)
					SetBkMode(Handle, OPAQUE)
				End If
				SelectObject(Handle, Font.Handle)
				.TextOut(Handle, StartX, StartY, @s, Len(s))
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Function Canvas.Get(x As Double, y As Double, nWidth As Integer, nHeight As Integer, ByRef ImageSource As My.Sys.Drawing.BitmapType) As Any Ptr
		#ifdef __USE_WASM__
			Return 0
		#else
			Return Get(x, y, nWidth , nHeight, ImageSource.Handle)
		#endif
	End Function
	
	Private Function Canvas.Get(x As Double, y As Double, nWidth As Integer, nHeight As Integer, ByVal ImageSource As Any Ptr) As Any Ptr
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		#ifdef __USE_GTK__
			Dim As GdkPixbuf Ptr ImageDest
			If nWidth <> 0 AndAlso nHeight <> 0 Then
				ImageDest = gdk_pixbuf_new(GDK_COLORSPACE_RGB, True, 8 , nWidth, nHeight)
				If ImageDest Then
					gdk_pixbuf_copy_area(ImageSource, x, y, nWidth, nHeight, ImageDest, 0, 0)
					Return ImageDest
				End If
			End If
			Return 0
		#elseif 0
			Dim As GpImage Ptr pImage1
			Dim As GpImage Ptr pImage2
			Dim As HBITMAP     ImageDest
			GdipCreateBitmapFromHBITMAP(ImageSource, NULL, Cast(GpBitmap Ptr Ptr, @pImage1))
			GdipCloneBitmapArea (x, y, nWidth, nHeight, 0, Cast(GpBitmap Ptr , pImage1) , Cast(GpBitmap Ptr Ptr, @pImage2))
			If UsingGdip Then
				' // Free the image
				If pImage1 Then GdipDisposeImage pImage1
				Return pImage2
			Else
				GdipCreateHBITMAPFromBitmap(Cast(GpBitmap Ptr , pImage2) , @ImageDest, 0)
				If pImage1 Then GdipDisposeImage pImage1
				If pImage2 Then GdipDisposeImage pImage2
				Return ImageDest
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
		Return 0
	End Function
	
	Private Sub Canvas.DrawAlpha(x As Double, y As Double, nWidth As Double = -1, nHeight As Double = -1, ByRef Image As My.Sys.Drawing.BitmapType, iSourceAlpha As Integer = 255)
		If nWidth = -1 Then nWidth = ScaleX(Image.Width)
		If nHeight = -1 Then nHeight = ScaleY(Image.Height)
			DrawAlpha(x, y, nWidth, nHeight, Image.Handle, iSourceAlpha)
	End Sub
	
	
	Private Sub Canvas.DrawAlpha(x As Double, y As Double, nWidth As Double = -1, nHeight As Double = -1, ByVal Image As Any Ptr, iSourceAlpha As Integer = 255)
		If Image = 0 Then Return                      ' 快速过滤无效图像
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			Dim As cairo_surface_t Ptr image_surface
			#ifdef __USE_GTK3__
				image_surface = gdk_cairo_surface_create_from_pixbuf(Image, 1, NULL)
			#else
				Dim As Integer image_width = gdk_pixbuf_get_width(Image)
				Dim As Integer image_height = gdk_pixbuf_get_height(Image)
				Dim As Integer stride = cairo_format_stride_for_width(CAIRO_FORMAT_ARGB32, image_width)
				
				image_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, image_width, image_height)
				If cairo_surface_status(image_surface) <> CAIRO_STATUS_SUCCESS Then
					Return
				End If
				
				Dim As UByte Ptr cairo_data = cairo_image_surface_get_data(image_surface)
				Dim As Const UByte Ptr pixbuf_data = gdk_pixbuf_get_pixels(Image)
				Dim As Integer pixbuf_rowstride = gdk_pixbuf_get_rowstride(Image)
				Dim As Integer n_channels = gdk_pixbuf_get_n_channels(Image)
				
				For y As Integer = 0 To image_height - 1
					Dim As UByte Ptr cairo_row = cairo_data + y * stride
					Dim As Const UByte Ptr pixbuf_row = pixbuf_data + y * pixbuf_rowstride
					
					For x As Integer = 0 To image_width - 1
						Dim As UByte r, g, b, a
						
						r = pixbuf_row[x * n_channels]
						g = pixbuf_row[x * n_channels + 1]
						b = pixbuf_row[x * n_channels + 2]
						a = IIf(n_channels = 4, pixbuf_row[x * n_channels + 3], 255)
						
						cairo_row[x * 4] = b
						cairo_row[x * 4 + 1] = g
						cairo_row[x * 4 + 2] = r
						cairo_row[x * 4 + 3] = a
					Next
				Next
				
				cairo_surface_mark_dirty(image_surface)
			#endif
			' 修正 Cairo 缩放和 Alpha 透明度
			Dim As Double draw_width = nWidth
			Dim As Double draw_height = nHeight
			If draw_width = -1 Then draw_width = cairo_image_surface_get_width(image_surface)
			If draw_height = -1 Then draw_height = cairo_image_surface_get_height(image_surface)
			
			Dim As Double img_w = cairo_image_surface_get_width(image_surface)
			Dim As Double img_h = cairo_image_surface_get_height(image_surface)
			
			cairo_save(Handle)
			cairo_translate(Handle, x, y)
			If draw_width <> img_w OrElse draw_height <> img_h Then
				cairo_scale(Handle, draw_width / img_w, draw_height / img_h)
			End If
			cairo_set_source_surface(Handle, image_surface, 0, 0)
			cairo_paint_with_alpha(Handle, CSng(iSourceAlpha) / 255.0)
			cairo_restore(Handle)
			
			cairo_surface_destroy(image_surface)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Draw(x As Double, y As Double, Image As Any Ptr)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			' 补充 Cairo 后端 Draw 实现
			Dim As cairo_surface_t Ptr image_surface
			#ifdef __USE_GTK3__
				image_surface = gdk_cairo_surface_create_from_pixbuf(Image, 1, NULL)
			#else
				Dim As Integer image_width = gdk_pixbuf_get_width(Image)
				Dim As Integer image_height = gdk_pixbuf_get_height(Image)
				Dim As Integer stride = cairo_format_stride_for_width(CAIRO_FORMAT_ARGB32, image_width)
				image_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, image_width, image_height)
				If cairo_surface_status(image_surface) = CAIRO_STATUS_SUCCESS Then
					Dim As UByte Ptr cairo_data = cairo_image_surface_get_data(image_surface)
					Dim As Const UByte Ptr pixbuf_data = gdk_pixbuf_get_pixels(Image)
					Dim As Integer pixbuf_rowstride = gdk_pixbuf_get_rowstride(Image)
					Dim As Integer n_channels = gdk_pixbuf_get_n_channels(Image)
					For yy As Integer = 0 To image_height - 1
						Dim As UByte Ptr cairo_row = cairo_data + yy * stride
						Dim As Const UByte Ptr pixbuf_row = pixbuf_data + yy * pixbuf_rowstride
						For xx As Integer = 0 To image_width - 1
							cairo_row[xx * 4] = pixbuf_row[xx * n_channels + 2]
							cairo_row[xx * 4 + 1] = pixbuf_row[xx * n_channels + 1]
							cairo_row[xx * 4 + 2] = pixbuf_row[xx * n_channels]
							cairo_row[xx * 4 + 3] = IIf(n_channels = 4, pixbuf_row[xx * n_channels + 3], 255)
						Next
					Next
					cairo_surface_mark_dirty(image_surface)
				End If
			#endif
			cairo_set_source_surface(Handle, image_surface, x, y)
			cairo_paint(Handle)
			cairo_surface_destroy(image_surface)
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.Draw(x As Double, y As Double, ByRef Image As My.Sys.Drawing.BitmapType)
		#ifndef __USE_WASM__
			This.Draw(x, y, Image.Handle)
		#endif
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
				' Cairo 基于 Alpha 通道绘制，不支持动态高性能颜色键剔除，降级为 Draw
				This.Draw(x, y, Image)
			If Not HandleSetted Then ReleaseDevice Handle_
		End Sub
		
		Private Sub Canvas.DrawTransparent(x As Double, y As Double, ByRef Image As My.Sys.Drawing.BitmapType, cTransparentColor As UInteger = 0)
			#ifndef __USE_WASM__
				DrawTransparent ScaleX(x), ScaleY(y), Image.Handle, cTransparentColor
			#endif
		End Sub
	#endif
	
	Private Sub Canvas.DrawStretch(x As Double, y As Double, nWidth As Integer, nHeight As Integer, Image As Any Ptr)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
			' 补充 Cairo DrawStretch 实现
			Dim As cairo_surface_t Ptr image_surface
			#ifdef __USE_GTK3__
				image_surface = gdk_cairo_surface_create_from_pixbuf(Image, 1, NULL)
			#else
				Dim As Integer image_width = gdk_pixbuf_get_width(Image)
				Dim As Integer image_height = gdk_pixbuf_get_height(Image)
				Dim As Integer stride = cairo_format_stride_for_width(CAIRO_FORMAT_ARGB32, image_width)
				image_surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, image_width, image_height)
				If cairo_surface_status(image_surface) = CAIRO_STATUS_SUCCESS Then
					Dim As UByte Ptr cairo_data = cairo_image_surface_get_data(image_surface)
					Dim As Const UByte Ptr pixbuf_data = gdk_pixbuf_get_pixels(Image)
					Dim As Integer pixbuf_rowstride = gdk_pixbuf_get_rowstride(Image)
					Dim As Integer n_channels = gdk_pixbuf_get_n_channels(Image)
					For yy As Integer = 0 To image_height - 1
						Dim As UByte Ptr cairo_row = cairo_data + yy * stride
						Dim As Const UByte Ptr pixbuf_row = pixbuf_data + yy * pixbuf_rowstride
						For xx As Integer = 0 To image_width - 1
							cairo_row[xx * 4] = pixbuf_row[xx * n_channels + 2]
							cairo_row[xx * 4 + 1] = pixbuf_row[xx * n_channels + 1]
							cairo_row[xx * 4 + 2] = pixbuf_row[xx * n_channels]
							cairo_row[xx * 4 + 3] = IIf(n_channels = 4, pixbuf_row[xx * n_channels + 3], 255)
						Next
					Next
					cairo_surface_mark_dirty(image_surface)
				End If
			#endif
			Dim As Double img_w = cairo_image_surface_get_width(image_surface)
			Dim As Double img_h = cairo_image_surface_get_height(image_surface)
			If img_w > 0 AndAlso img_h > 0 Then
				cairo_save(Handle)
				cairo_translate(Handle, x, y)
				cairo_scale(Handle, nWidth / img_w, nHeight / img_h)
				cairo_set_source_surface(Handle, image_surface, 0, 0)
				cairo_paint(Handle)
				cairo_restore(Handle)
			End If
			cairo_surface_destroy(image_surface)
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
		#ifdef __USE_CAIRO__
			' Cairo 无原生 FloodFill，需通过 Surface 像素级操作实现
			' 简化实现：获取当前 Surface，执行泛洪填充算法
			Dim As cairo_surface_t Ptr surface = cairo_get_target(Handle)
			If surface <> 0 Then
				Dim As Integer fmt = cairo_image_surface_get_format(surface)
				If fmt = CAIRO_FORMAT_ARGB32 OrElse fmt = CAIRO_FORMAT_RGB24 Then
					Dim As Integer w = cairo_image_surface_get_width(surface)
					Dim As Integer h = cairo_image_surface_get_height(surface)
					Dim As Integer stride = cairo_image_surface_get_stride(surface)
					Dim As UByte Ptr dataPtr = cairo_image_surface_get_data(surface)
					If dataPtr <> 0 Then
						Dim As Integer px = ScaleX(x) * imgScaleX + imgOffsetX
						Dim As Integer py = ScaleY(y) * imgScaleY + imgOffsetY
						If px >= 0 AndAlso py >= 0 AndAlso px < w AndAlso py < h Then
							Dim As UByte fR = GetRed(FillColorBK), fG = GetGreen(FillColorBK), fB = GetBlue(FillColorBK)
							' 获取种子点颜色
							Dim As Integer idx = py * stride + px * 4
							Dim As UByte tB = dataPtr[idx], tG = dataPtr[idx + 1], tR = dataPtr[idx + 2]
							If tR <> fR OrElse tG <> fG OrElse tB <> fB Then
								' 简单栈式泛洪填充 (BFS)
								Dim As Integer qHead = 0, qTail = 0
								Dim maxQ As Integer = w * h
								Dim qX() As Integer, qY() As Integer
								ReDim qX(maxQ - 1), qY(maxQ - 1)
								qX(qTail) = px: qY(qTail) = py: qTail += 1
								While qHead < qTail
									Dim As Integer cx = qX(qHead), CY = qY(qHead): qHead += 1
									Dim As Integer cIdx = CY * stride + cx * 4
									If dataPtr[cIdx] <> tB OrElse dataPtr[cIdx + 1] <> tG OrElse dataPtr[cIdx + 2] <> tR Then Continue While
									dataPtr[cIdx] = fB: dataPtr[cIdx + 1] = fG: dataPtr[cIdx + 2] = fR
									If cx > 0 Then qX(qTail) = cx - 1: qY(qTail) = CY: qTail += 1
									If cx < w - 1 Then qX(qTail) = cx + 1: qY(qTail) = CY: qTail += 1
									If CY > 0 Then qX(qTail) = cx: qY(qTail) = CY - 1: qTail += 1
									If CY < h - 1 Then qX(qTail) = cx: qY(qTail) = CY + 1: qTail += 1
								Wend
								Erase qX, qY
								cairo_surface_mark_dirty(surface)
							End If
						End If
					End If
				End If
			End If
		#elseif 0
			.ExtFloodFill Handle, ScaleX(x) * imgScaleX + imgOffsetX, ScaleY(y) * imgScaleY + imgOffsetY, FillColorBK, FillStyleBK
		#else
			Print "The function is not ready in this OS."  & " Canvas.FloodFill(x As Double, y As Double, FillColorBK As Integer = -1, FillStyleBK As FillStyle)"
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.FillRect(R As Rect, FillColorBK As Integer = -1)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		If FillColorBK = -1 Then FillColorBK = FBackColor
		#ifdef __USE_CAIRO__
			cairo_set_source_rgb(Handle, GetRed(FillColorBK), GetGreen(FillColorBK), GetBlue(FillColorBK))
			cairo_rectangle(Handle, ScaleX(R.Left) * imgScaleX + imgOffsetX - 0.5, ScaleY(R.Top) * imgScaleX + imgOffsetX - 0.5, ScaleX(R.Right - R.Left) - 0.5, ScaleY(R.Bottom - R.Top) - 0.5)
			cairo_fill_preserve(Handle)
		#elseif 0
			Static As HBRUSH B
			If B Then DeleteObject B
			R.Left = ScaleX(R.Left) * imgScaleX + imgOffsetX
			R.Top = ScaleY(R.Top) * imgScaleY + imgOffsetY
			R.Right = ScaleX(R.Right) * imgScaleX + imgOffsetX
			R.Bottom = ScaleY(R.Bottom) * imgScaleY + imgOffsetY
			If FillColorBK <> -1 Then
				If FUseDirect2D AndAlso pRenderTarget <> 0 Then
					Dim As Double iRed, iGreen, iBlue
					iRed = Abs(GetRed(FillColorBK) / 255.0): iGreen = Abs(GetGreen(FillColorBK) / 255.0): iBlue = Abs(GetBlue(FillColorBK) / 255.0)
					Dim clr As D2D1_COLOR_F = Type<D2D1_COLOR_F>(iRed, iGreen, iBlue, 1.0)
					If pBrushFill = 0 Then
						pRenderTarget->lpVtbl->CreateSolidColorBrush(pRenderTarget, @clr, 0, @pBrushFill)
					Else
						pBrushFill->lpVtbl->SetColor(pBrushFill, @clr)
					End If
					If pBrushOpacity = 0 Then pBrushOpacity = Cast(ID2D1Brush Ptr, pBrushFill)
					If pBrushFill <> 0 Then pRenderTarget->lpVtbl->FillRectangle(pRenderTarget, @Type<D2D1_RECT_F>(ScaleX(R.Left) * imgScaleX + imgOffsetX - 0.5, ScaleY(R.Top) * imgScaleX + imgOffsetX - 0.5, ScaleX(R.Right - R.Left) - 0.5, ScaleY(R.Bottom - R.Top) - 0.5), Cast(ID2D1Brush Ptr,  pBrushFill))
				ElseIf Not UsingGdip Then
					B = CreateSolidBrush(FillColorBK)
					.FillRect Handle, Cast(..Rect Ptr, @R), B
				Else
					GdipFillRectangle(GdipGraphics, GdipBrush, R.Left, R.Top, R.Right, R.Bottom)
				End If
			Else
				If FUseDirect2D AndAlso pRenderTarget <> 0 Then
					If pBrushFill <> 0 Then pRenderTarget->lpVtbl->FillRectangle(pRenderTarget, @Type<D2D1_RECT_F>(ScaleX(R.Left) * imgScaleX + imgOffsetX - 0.5, ScaleY(R.Top) * imgScaleX + imgOffsetX - 0.5, ScaleX(R.Right - R.Left) - 0.5, ScaleY(R.Bottom - R.Top) - 0.5), Cast(ID2D1Brush Ptr, pBrushFill))
				ElseIf Not UsingGdip Then
					.FillRect Handle, Cast(..Rect Ptr, @R), Brush.Handle
				Else
					GdipFillRectangle(GdipGraphics, GdipBrush, R.Left, R.Top, R.Right, R.Bottom)
				End If
			End If
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Sub Canvas.DrawFocusRect(R As Rect)
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		#ifdef __USE_CAIRO__
			Dim As Double x1 = ScaleX(R.Left) * imgScaleX + imgOffsetX
			Dim As Double y1 = ScaleY(R.Top) * imgScaleY + imgOffsetY
			Dim As Double x2 = ScaleX(R.Right) * imgScaleX + imgOffsetX
			Dim As Double y2 = ScaleY(R.Bottom) * imgScaleY + imgOffsetY
			cairo_save(Handle)
			cairo_set_line_width(Handle, 1)
			cairo_set_dash(Handle, @Type<Double>(1), 2, 0)
			cairo_set_source_rgb(Handle, 0, 0, 0)
			cairo_rectangle(Handle, x1, y1, x2 - x1, y2 - y1)
			cairo_stroke(Handle)
			cairo_restore(Handle)
		#elseif 0
			R.Left = ScaleX(R.Left) * imgScaleX + imgOffsetX
			R.Top = ScaleY(R.Top) * imgScaleY + imgOffsetY
			R.Right = ScaleX(R.Right) * imgScaleX + imgOffsetX
			R.Bottom = ScaleY(R.Bottom) * imgScaleY + imgOffsetY
			.DrawFocusRect Handle, Cast(..Rect Ptr, @R)
		#else
			Print "The function is not ready in this OS."  & " DrawFocusRect(R As Rect)"
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Sub
	
	Private Function Canvas.TextWidth(ByRef sText As WString) As Integer
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		#ifdef __USE_GTK__
			Dim As PangoRectangle extend
			pango_layout_set_text(layout, ToUtf8(sText), Len(ToUtf8(sText)))
			pango_cairo_update_layout(Handle, layout)
			#ifdef pango_version
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(layout, 0)
			#else
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(layout, 0)
			#endif
			pango_layout_line_get_pixel_extents(pl, NULL, @extend)
			Function = UnScaleX(extend.width)
		#elseif 0
			Function = 0
		#elseif 0
			Dim Sz As ..Size
			GetTextExtentPoint32(Handle, @sText, Len(sText), @Sz)
			Function = UnScaleX(Sz.cx)
		#elseif 1
			Dim As cairo_text_extents_t extents
			cairo_text_extents(Handle, StrPtr(sText), @extents)
			Return extents.width
			
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Function
	
	Private Function Canvas.TextHeight(ByRef sText As WString) As Integer
		Dim As Any Ptr Handle_
		If Not HandleSetted Then Handle_ = GetDevice
		#ifdef __USE_GTK__
			Dim As PangoRectangle extend
			pango_layout_set_text(layout, ToUtf8(sText), Len(ToUtf8(sText)))
			pango_cairo_update_layout(Handle, layout)
			#ifdef pango_version
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(layout, 0)
			#else
				Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(layout, 0)
			#endif
			pango_layout_line_get_pixel_extents(pl, NULL, @extend)
			Function = UnScaleY(extend.height)
		#elseif 0
			Function = 0
		#elseif 0
			Dim Sz As ..Size
			GetTextExtentPoint32(Handle, @sText, Len(sText), @Sz)
			Function = UnScaleY(Sz.cy)
		#elseif 1
			Dim As cairo_text_extents_t extents
			cairo_text_extents(Handle, StrPtr(sText), @extents)
			Return extents.height
		#endif
		If Not HandleSetted Then ReleaseDevice Handle_
	End Function
	
	Private Operator Canvas.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Sub Canvas.Font_Create(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Font)
		With *Cast(Canvas Ptr, Sender.Parent)
			#ifdef __USE_GTK__
				'cairo_select_font_face(.Handle, Sender.Name, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
				'cairo_set_font_size(.Handle, Sender.Size)
				'
				'Dim As PangoFontDescription Ptr desc
				'desc = pango_font_description_from_string (Sender.Name & " " & Trim(Str(Sender.Size)))
				'pango_layout_set_font_description(.layout, desc)
				'pango_font_description_free(desc)
				'
				'Dim As PangoRectangle extend
				'pango_layout_set_text(.layout, ToUtf8("|"), 1)
				'pango_cairo_update_layout(.Handle, .layout)
				'#ifdef pango_version
				'	Dim As PangoLayoutLine Ptr pl = pango_layout_get_line_readonly(.layout, 0)
				'#else
				'	Dim As PangoLayoutLine Ptr pl = pango_layout_get_line(.layout, 0)
				'#endif
				'pango_layout_line_get_pixel_extents(pl, NULL, @extend)
				'.dwCharX = .UnScaleX(extend.width)
				'.dwCharY = .UnScaleY(extend.height)
			#else
				Dim As HDC hd = GetDC(.ParentControl->Handle)
				SelectObject(hd, .Font.Handle)
				GetTextMetrics(hd, @.tm)
				ReleaseDC(.ParentControl->Handle, hd)
				.dwCharX = .UnScaleX(.tm.tmAveCharWidth)
				.dwCharY = .UnScaleY(.tm.tmHeight)
				If .FUseDirect2D AndAlso .pRenderTarget <> 0 Then
					If .pTextFormat Then .pTextFormat->lpVtbl->Release(.pTextFormat): .pTextFormat = 0
					If pDWriteFactory <> NULL Then
						Dim As Long hr = pDWriteFactory->lpVtbl->CreateTextFormat(pDWriteFactory, @Sender.Name, 0, DWRITE_FONT_WEIGHT_THIN, DWRITE_FONT_STYLE_NORMAL, DWRITE_FONT_STRETCH_NORMAL, Sender.Size * .ydpi / 72 * 96, @"", @.pTextFormat)
						If hr <> 0 Or .pTextFormat = NULL Then
							Print Date & " " & Time & Chr(9) & __FUNCTION__ & Chr(9) & " (Line " & __LINE__ & ") " & "ERROR: Failed to create text format"
							Return
						End If
					End If
				End If
			#endif
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
		#ifdef __USE_CAIRO__
			If Handle Then ReleaseDevice
		#elseif 0
			If Handle Then ReleaseDevice
			' // Shutdown Gdiplus
			If GdipPen Then GdipDeletePen(GdipPen)
			If GdipBrush Then GdipDeleteBrush(GdipBrush)
			If GdipGraphics Then GdipDeleteGraphics(GdipGraphics)
			If GdipToken Then GdiplusShutdown GdipToken
			ReleaseDirect2D
			For i As Integer = pID2D1BitmapList.Count - 1  To 0 Step -1
				If pID2D1BitmapList.Object(i) <> 0 Then 
					pTargetBitmap = Cast(ID2D1Bitmap Ptr, pID2D1BitmapList.Object(i))
					If pTargetBitmap Then pTargetBitmap->lpVtbl->Release(pTargetBitmap): pTargetBitmap = 0
				End If
				pID2D1BitmapList.Remove i
			Next
		#endif
	End Destructor
End Namespace
