'###############################################################################
'#  Animate.bas                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Based on:                                                                  #
'#   TAnimate.bas                                                              #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#   Updated and added cross-platform code                                     #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                    #
'###############################################################################

#include once "Animate.bi"
Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function Animate.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "autoplay": Return @FAutoPlay
			Case "autosize": Return @FAutoSize
			Case "center": Return @FCenter
			Case "commonavi": Return @FCommonAvi
			Case "file": Return FFile
			Case "repeat": Return @FRepeat
			Case "startframe": Return @FStartFrame
			Case "stopframe": Return @FStopFrame
			Case "timers": Return @FTimers
			Case "ratiofixed": Return @FRatioFixed
			Case "rate": Return @FRate
			Case "transparency": Return @FTransparent
			Case "position": Return @FPosition
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Animate.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "autoplay": AutoPlay = QBoolean(Value)
			Case "autosize": AutoSize = QBoolean(Value)
			Case "center": Center = QBoolean(Value)
			Case "commonavi": CommonAvi = *Cast(CommonAVIs Ptr, Value)
			Case "file": File = QWString(Value)
			Case "repeat": Repeat = QInteger(Value)
			Case "startframe": StartFrame = QLong(Value)
			Case "stopframe": StopFrame = QLong(Value)
			Case "timers": Timers = QBoolean(Value)
			Case "rate": Rate = QDouble(Value)
			Case "transparency": Transparency = QBoolean(Value)
			Case "position": Position = QDouble(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property Animate.Center As Boolean
		Return FCenter
	End Property
	
	Private Property Animate.Center(Value As Boolean)
		If FCenter <> Value Then FCenter = Value Else Return
	End Property
	
	Private Property Animate.Transparency As Boolean
		Return FTransparent
	End Property
	
	Private Property Animate.Transparency(Value As Boolean)
		If FTransparent <> Value Then FTransparent = Value Else Return
	End Property
	
	Private Property Animate.Timers As Boolean
		Return FTimers
	End Property
	
	Private Property Animate.Timers(Value As Boolean)
		If FTimers <> Value Then FTimers = Value Else Return
	End Property
	
	Private Property Animate.File ByRef As WString
	Static EmptyWString As WString * 1
		If FFile> 0 Then Return *FFile Else Return EmptyWString
	End Property
	
	Private Property Animate.File(ByRef Value As WString)
		FFile = _Reallocate(FFile, (Len(Value) + 1) * SizeOf(WString))
		*FFile = Value
			pixbuf_animation = gdk_pixbuf_animation_new_from_file(ToUtf8(*FFile), NULL)
	End Property
	
	Private Property Animate.Repeat As Integer
		Return FRepeat
	End Property
	
	Private Property Animate.Repeat(Value As Integer)
		FRepeat = Value
	End Property
	
	Private Property Animate.AutoPlay As Boolean
		Return FAutoPlay
	End Property
	
	Private Property Animate.AutoPlay(Value As Boolean)
		If FAutoPlay <> Value Then FAutoPlay = Value Else Return
	End Property
	
	Private Property Animate.AutoSize As Boolean
		Return FAutoSize
	End Property
	
	Private Property Animate.AutoSize(Value As Boolean)
		FAutoSize = Value
	End Property
	
	Private Property Animate.CommonAvi As CommonAVIs
		Return FCommonAvi
	End Property
	
	Private Property Animate.CommonAvi(Value As CommonAVIs)
		FCommonAvi = Value
	End Property
	
	Private Property Animate.Volume As Long
		Return FVolume
	End Property
	
	Private Property Animate.Volume(Value As Long)
		If FVolume <> Value Then FVolume = Value Else Return
	End Property
	
	Private Property Animate.Balance As Long
		Return FBalance
	End Property
	
	Private Property Animate.Balance(Value As Long)
		If FBalance <> Value Then FBalance = Value Else Return
		FBalance = Value
	End Property
	
	Private Property Animate.FullScreenMode As Boolean
			Return CBool(FFullScreenMode)
	End Property
	
	Private Property Animate.FullScreenMode(Value As Boolean)
	End Property
	
	Private Property Animate.Rate As Double
		Return FRate
	End Property
	
	Private Property Animate.Rate(Value As Double)
		If FRate <> Value Then FRate = Value Else Return
	End Property
	
	Private Property Animate.Position As Double
		Return FPosition
	End Property
	
	Private Property Animate.Position(Value As Double)
		If FPosition <> Value Then FPosition = Value Else Return
	End Property
	
	Private Property Animate.StartFrame As Long
		Return FStartFrame
	End Property
	
	Private Property Animate.StartFrame(Value As Long)
		FStartFrame = Value
		If FStartFrame < 0 Then FStartFrame = 0
		If FPlay Then This.Stop
		Play
	End Property
	
	Private Property Animate.StopFrame As Long
		Return FStopFrame
	End Property
	
	Private Property Animate.StopFrame(Value As Long)
		FStopFrame = Value
		If FStopFrame > FFrameCount - 1 OrElse FStopFrame< 1 Then FStopFrame = FFrameCount
		If FPlay Then This.Stop
		Play
	End Property
	
	Private Function Animate.FrameCount As Long
		Return FFrameCount
	End Function
	
	Private Function Animate.OpenMode As Integer
		Return FOpenMode
	End Function
	
	Private Sub Animate.SetMoviePosition(ByVal ALeft As Long, ByVal ATop As  Long, ByVal AWidth As Long, ByVal AHeight As Long)
	End Sub
	
	Private Property Animate.FrameHeight As Long
		Return FFrameHeight
	End Property
	
	Private Property Animate.FrameHeight(Value As Long)
		FFrameHeight = Value
		This.Height = UnScaleY(Value)
	End Property
	
	Private Property Animate.FrameWidth As Long
		Return FFrameWidth
	End Property
	
	Private Property Animate.FrameWidth(Value As Long)
		FFrameWidth = Value
		This.Width = UnScaleX(Value)
	End Property
	
	Private Function Animate.FrameHeightOriginal As Long
		Return FFrameHeightOrig
	End Function
	
	Private Function Animate.FrameWidthOriginal As Long
		Return FFrameWidthOrig
	End Function
	
	Private Function Animate.Ratio As Double
		Return FRatio
	End Function
	
	Private Property Animate.RatioFixed As Boolean
		Return FRatioFixed
	End Property
	
	Private Property Animate.RatioFixed(Value As Boolean)
		FRatioFixed = Value
	End Property
	
	
	'https://learn.microsoft.com/en-us/windows/win32/directshow/event-notification-codes.
	Private Sub Animate.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Function Animate.OpenFile(ByRef FileName As WString = "") As Integer
		FErrorInfo = ""
		FOpenMode = 0: FRate= 1
		If Trim(FileName) <> "" Then WLet(FFile, FileName)
			If OnOpen Then OnOpen(*Designer, This)
			If pixbuf_animation <> 0 Then
				FFrameWidth = gdk_pixbuf_animation_get_width(pixbuf_animation)
				FFrameHeight = gdk_pixbuf_animation_get_height(pixbuf_animation)
			End If
			FOpenMode= 1
			If FAutoPlay Then
				Play
			Else
				'					gtk_image_set_from_pixbuf(gtk_image(widget), gdk_pixbuf_animation_get_static_image(pixbuf_animation))
			End If
		Return FOpenMode
	End Function
	
	Private Function Animate.GetErrorInfo As String
		Return FErrorInfo
	End Function
	
	Private Function Animate.IsPlaying As Boolean
			Return FPlay
	End Function
	
	Private Sub Animate.Play
		FErrorInfo = ""
			If pixbuf_animation <> 0 Then
				Dim As GTimeVal gTime
				g_get_current_time(@gTime)
				iter = gdk_pixbuf_animation_get_iter(pixbuf_animation, @gTime)
				If OnStart Then OnStart(*Designer, This)
				FPlay = True
				Timer_cb(@This)
			End If
	End Sub
	
	Private Sub Animate.Stop
		FErrorInfo = ""
			If OnStop Then OnStop(*Designer, This)
			FPlay = False
	End Sub
	
	Private Sub Animate.Pause
		FErrorInfo = ""
		Rate = 1
			If OnPause Then OnPause(*Designer, This)
			FPlay = False
	End Sub
	Private Sub Animate.Close
		FErrorInfo = ""
			If OnClose Then OnClose(*Designer, This)
			FOpenMode= 0
			FPlay = False
	End Sub
	
	Private Operator Animate.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
		Private Function Animate.Timer_cb(ByVal user_data As gpointer) As gboolean
			Dim As Animate Ptr anim = user_data
			If anim->FPlay Then
				Dim As GTimeVal gTime
				g_get_current_time(@gTime)
				gdk_pixbuf_animation_iter_advance(anim->iter, @gTime)
				g_timeout_add(gdk_pixbuf_animation_iter_get_delay_time(anim->iter), Cast(GSourceFunc, @Timer_cb), user_data)
				gtk_widget_queue_draw(anim->widget)
			End If
			Return False
		End Function
		
		Private Function Animate.DesignDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As Any Ptr) As Boolean
			Dim As Animate Ptr anim = data1
				Dim As Integer AllocatedWidth = gtk_widget_get_allocated_width(widget), AllocatedHeight = gtk_widget_get_allocated_height(widget)
			If anim->FDesignMode Then
				cairo_rectangle(cr, 0.0, 0.0, AllocatedWidth, AllocatedHeight)
				Dim As Double Ptr dashed = _Allocate(SizeOf(Double) * 2)
				dashed[0] = 3.0
				dashed[1] = 3.0
				Dim As Integer len1 = SizeOf(dashed) / SizeOf(dashed[0])
				cairo_set_dash(cr, dashed, len1, 1)
				cairo_set_source_rgb(cr, 0.0, 0.0, 0.0)
				cairo_stroke(cr)
			End If
			If anim->pixbuf_animation <> 0 Then
				cairo_set_operator (cr, CAIRO_OPERATOR_SOURCE)
				
				Dim As GdkPixbuf Ptr pixbuf
				
				Dim As Integer imgw, imgh
				imgw = gdk_pixbuf_animation_get_width(anim->pixbuf_animation)
				imgh = gdk_pixbuf_animation_get_height(anim->pixbuf_animation)
				If anim->AutoSize Then
					If AllocatedWidth <> imgw OrElse AllocatedHeight <> imgh Then
						gtk_widget_set_size_request(anim->eventboxwidget, imgw, imgh)
					End If
				End If
				
				pixbuf = gdk_pixbuf_animation_iter_get_pixbuf(anim->iter)
				If anim->Center Then
					gdk_cairo_set_source_pixbuf(cr, pixbuf, (AllocatedWidth - imgw) / 2, (AllocatedHeight - imgh) / 2)
				Else
					gdk_cairo_set_source_pixbuf(cr, pixbuf, 0, 0)
				End If
				cairo_paint(cr)
			End If
			
			Return False
		End Function
		
		Private Function Animate.DesignExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As Any Ptr) As Boolean
				Dim As cairo_t Ptr cr = gdk_cairo_create(Event->window)
				DesignDraw(widget, cr, data1)
				cairo_destroy(cr)
			Return False
		End Function
		
		Private Sub Animate.Screen_Changed(widget As GtkWidget Ptr, old_screen As GdkScreen Ptr, userdata As gpointer)
			Dim As Animate Ptr anim = userdata
			/' To check If the display supports Alpha channels, Get the colormap '/
			Dim As GdkScreen Ptr pScreen = gtk_widget_get_screen(widget)
				Dim As GdkVisual Ptr VisualOrColormap = gdk_screen_get_rgba_visual(pScreen)
			If (VisualOrColormap <> 0) Then
				Print "Your screen does not support alpha channels!"
					'VisualOrColormap = gdk_screen_get_rgb_visual(pScreen)
				anim->SupportsAlpha = False
			Else
				anim->SupportsAlpha = True
			End If
			/' Now we have a colormap appropriate for the screen, use it '/
				gtk_widget_set_visual(widget, VisualOrColormap)
		End Sub
	
	Private Constructor Animate
		Dim As Boolean Result
			widget = gtk_image_new()
			eventboxwidget = gtk_event_box_new()
			gtk_container_add(GTK_CONTAINER(eventboxwidget), widget)
			gtk_widget_set_app_paintable(widget, True)
					g_signal_connect(widget, "draw", G_CALLBACK(@DesignDraw), @This)
			g_signal_connect(G_OBJECT(widget), "screen-changed", G_CALLBACK(@Screen_Changed), @This)
			This.RegisterClass "Animate", @This
		FRepeat         = -1
		FRate           = 1
		FStopFrame      = -1
		FStartFrame     = 0
		FCenter = True
		FRatioFixed = True
		FTransparent = True
		FAutoSize = True
		FAutoPlay = True
		FTimers = True
		With This
			WLet(FClassName, "Animate")
			.Child             = @This
			.Width             = 100
			.Height            = 80
		End With
	End Constructor
	
	Private Destructor Animate
		If FFile Then _Deallocate( FFile)
	End Destructor
End Namespace
