'###############################################################################
'#  ProgressBar.bi                                                             #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TProgressBar.bi                                                           #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "ProgressBar.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function ProgressBar.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "marquee": Return @FMarquee
			Case "maxvalue": Return @FMaxValue
			Case "minvalue": Return @FMinValue
			Case "orientation": Return @FOrientation
			Case "position": Return @FPosition
			Case "smooth": Return @FSmooth
			Case "stepvalue": Return @FStep
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function ProgressBar.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "marquee": Marquee = QBoolean(Value)
				Case "maxvalue": MaxValue = QInteger(Value)
				Case "minvalue": MinValue = QInteger(Value)
				Case "orientation": Orientation = *Cast(ProgressBarOrientation Ptr, Value)
				Case "smooth": Smooth = QBoolean(Value)
				Case "stepvalue": StepValue = QInteger(Value)
				Case "position": Position = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Sub ProgressBar.SetRange(AMin As Integer, AMax As Integer)
		If AMax < AMin Then Exit Sub
		If Not CInt(FMode32) And ((AMin < 0) Or (AMin > 85535) Or (AMax < 0) Or (AMax > 85535)) Then Exit Sub
		If (FMinValue <> AMin) Or (FMaxValue <> AMax) Then
		End If
		FMinValue = AMin
		FMaxValue = AMax
	End Sub
	
		Private Function ProgressBar.progress_cb(ByVal user_data As gpointer) As gboolean
			Dim As ProgressBar Ptr prb = Cast(ProgressBar Ptr, user_data)
			gtk_progress_bar_pulse(GTK_PROGRESS_BAR(prb->widget))
			If prb->progress_bar_timer_id = 0 Then
				Return False
				'Return G_SOURCE_REMOVE
			Else
				Return True
			End If
		End Function

	Private Sub ProgressBar.SetMarquee(MarqueeOn As Boolean, Interval As Integer)
		FMarqueeOn = MarqueeOn
		FMarqueeInterval = Interval
			If FMarqueeOn Then
				progress_bar_timer_id = g_timeout_add(FMarqueeInterval, Cast(GSourceFunc, @progress_cb), @This)
			Else
				progress_bar_timer_id = 0
			End If
	End Sub
	
	Private Sub ProgressBar.StopMarquee()
		FMarqueeOn = False
			If progress_bar_timer_id <> 0 Then
				'g_source_remove_ progress_bar_timer_id
				progress_bar_timer_id = 0
			End If
	End Sub
	
	Private Property ProgressBar.MinValue As Integer
		Return FMinValue
	End Property
	
	Private Property ProgressBar.MinValue(Value As Integer)
		FMinValue = Value
		SetRange(FMinValue,FMaxValue)
	End Property
	
	Private Property ProgressBar.MaxValue As Integer
		Return FMaxValue
	End Property
	
	Private Property ProgressBar.MaxValue(Value As Integer)
		FMaxValue = Value
		SetRange(FMinValue,FMaxValue)
	End Property
	
	Private Property ProgressBar.Position As Integer
			FPosition = FMinValue + (FMaxValue - FMinValue) * gtk_progress_bar_get_fraction(gtk_progress_bar(widget))
		Return FPosition
	End Property
	
	Private Property ProgressBar.Position(Value As Integer)
		If Not CInt(FMode32) And ((Value < 0) Or (Value  > 65535)) Then Exit Property
		FPosition = Value
			If FMaxValue <> FMinValue Then
				gtk_progress_bar_set_fraction(gtk_progress_bar(widget), FPosition / (FMaxValue - FMinValue))
			End If
	End Property
	
	Private Property ProgressBar.StepValue As Integer
		Return FStep
	End Property
	
	Private Property ProgressBar.StepValue(Value As Integer)
		If Value <> FStep Then
			FStep = Value
				If FMaxValue <> FMinValue Then
					gtk_progress_bar_set_pulse_step(gtk_progress_bar(widget), FStep / (FMaxValue - FMinValue))
				End If
		End If
	End Property
	
	Private Property ProgressBar.Smooth As Boolean
		Return FSmooth
	End Property
	
	Private Property ProgressBar.Smooth(Value As Boolean)
		If FSmooth <> Value Then
			FSmooth = Value
		End If
	End Property
	
	Private Property ProgressBar.Marquee As Boolean
		Return FMarquee
	End Property
	
	Private Property ProgressBar.Marquee(Value As Boolean)
		If FMarquee <> Value Then
			FMarquee = Value
		End If
	End Property
	
	Private Property ProgressBar.Orientation As ProgressBarOrientation
		Return FOrientation
	End Property
	
	Private Property ProgressBar.Orientation(Value As ProgressBarOrientation)
		Dim As Integer OldOrientation, iWidth, iHeight
		OldOrientation = FOrientation
		If FOrientation <> Value Then
			FOrientation = Value
			If OldOrientation = 0 Then
				iWidth = This.Width
				iHeight = This.Height
						gtk_orientable_set_orientation(gtk_orientable(widget), GTK_ORIENTATION_VERTICAL)
				This.Width = iHeight
				This.Height = iWidth
			Else
				iWidth = This.Width
				iHeight = This.Height
						gtk_orientable_set_orientation(gtk_orientable(widget), GTK_ORIENTATION_HORIZONTAL)
				This.Width = iHeight
				This.Height = iWidth
			End If
		End If
	End Property
	
	
	
	Private Sub ProgressBar.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Sub ProgressBar.StepIt
			If FMarquee Then
				gtk_progress_bar_pulse(GTK_PROGRESS_BAR(widget))
			Else
				Position = Position + FStep
			End If
	End Sub
	
	Private Sub ProgressBar.StepBy(Delta As Integer)
			If FMarquee Then
				gtk_progress_bar_pulse(GTK_PROGRESS_BAR(widget))
			Else
				Position = Position + Delta
			End If
	End Sub
	
	Private Operator ProgressBar.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor ProgressBar
			widget = gtk_progress_bar_new()
		FMinValue  = 0
		FMaxValue  = 100
		FStep      = 10
		FMarquee = False
		With This
			.Child             = @This
			WLet(FClassName, "ProgressBar")
			.Width             = 150
		End With
	End Constructor
	
	Private Destructor ProgressBar
	End Destructor
End Namespace
