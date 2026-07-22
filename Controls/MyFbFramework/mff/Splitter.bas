'###############################################################################
'#  Splitter.bi                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TSplitter.bi                                                              #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "Splitter.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function Splitter.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "align": Return @FAlign
			Case "minextra": Return @MinExtra
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Splitter.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "align": This.Align = *Cast(SplitterAlignmentConstants Ptr, Value)
			Case "minextra": This.MinExtra = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	
	Private Property Splitter.Align As SplitterAlignmentConstants
		Return Base.Align
	End Property
	
	Private Sub Splitter.DrawTrackSplit(x As Integer, y As Integer)
	End Sub
	
	Private Property Splitter.Align(value As SplitterAlignmentConstants)
		Base.Align = *Cast(DockStyle Ptr, @value)
		Select Case value
		Case 1, 2
			This.Cursor = crSizeWE
			This.Width = 3
		Case 3, 4
			This.Cursor = crSizeNS
			This.Height = 3
		Case Else
			This.Cursor = crArrow
		End Select
	End Property
	
	
	Private Sub Splitter.ProcessMessage(ByRef Message As Message)
		Static As Long xOrig, yOrig, xCur, yCur, i, down1
			Dim As GdkDisplay Ptr display = gdk_display_get_default()
				Dim As GdkDeviceManager Ptr device_manager = gdk_display_get_device_manager(display)
				Dim As GdkDevice Ptr device = gdk_device_manager_get_client_pointer(device_manager)
			Dim As GdkEvent Ptr e = Message.event
			Select Case Message.event->Type
			Case GDK_BUTTON_PRESS
			down1 = 1
					gdk_device_get_position (device, NULL, @xOrig, @yOrig)
			'SetCapture Handle 'Parent->Handle
			'            x1 = loword(message.lparam)
			'            y1 = hiword(message.lparam)
			'                  DrawTrackSplit(x1, FTop)
			'                  DrawTrackSplit(FLeft, y1)
			'            Down = 1
			Case GDK_MOTION_NOTIFY
			'        int wnd_x = g_OrigWndPos.x +
			If down1 = 1 Then
				i = This.Parent->IndexOf(@This)
						gdk_device_get_position (device, NULL, @xCur, @yCur)
					If This.Parent->ControlCount Then
						This.Parent->UpdateLock
						Select Case Align
						Case SplitterAlignmentConstants.alLeft
							If i > 0 Then This.Parent->Controls[i - 1]->Width = This.Parent->Controls[i - 1]->Width - UnScaleX(xOrig) + UnScaleX(xCur)
						Case SplitterAlignmentConstants.alRight
							If i > 0 Then This.Parent->Controls[i - 1]->Width = This.Parent->Controls[i - 1]->Width + UnScaleX(xOrig) - UnScaleX(xCur)
						Case SplitterAlignmentConstants.alTop
							If i > 0 Then This.Parent->Controls[i - 1]->Height = This.Parent->Controls[i - 1]->Height - UnScaleY(yOrig) + UnScaleY(yCur)
						Case SplitterAlignmentConstants.alBottom
							If i > 0 Then This.Parent->Controls[i - 1]->Height = This.Parent->Controls[i - 1]->Height + UnScaleY(yOrig) - UnScaleY(yCur)
						End Select
						xOrig = xCur
						yOrig = yCur
						If OnMoving Then OnMoving(*Designer, This)
						This.Parent->RequestAlign
							If i > 0 Then This.Parent->Controls[i-1]->RequestAlign 
							'#Else
							'		This.Parent->RequestAlign
						This.Parent->UpdateUnLock
						This.Parent->Repaint
						'This.Parent->Update
						'Parent->Update
					End If
			End If
			'             x = loword(message.lparam)
			'             y = hiword(message.lparam)
			'             if down then
			'                select case Align
			'                case 1,2
			'                    DrawTrackSplit(x,FTop)
			'                    DrawTrackSplit(x1,FTop)
			'                case 3,4
			'                    DrawTrackSplit(FLeft,y)
			'                    DrawTrackSplit(FLeft,y1)
			'                end select
			'             end if
			'             x1 = loword(Message.lParam)
			'             y1 = hiword(Message.lParam)
			Case GDK_BUTTON_RELEASE
			down1 = 0
			'            dim as integer i
			'            if Down then
			'                select case Align
			'                case 1,2
			'                     DrawTrackSplit(x1,FTop)
			'                case 3,4
			'                     DrawTrackSplit(FLeft,y1)
			'                end select
			'                down = 0
			'                x = loword(Message.lParam)
			'                y = hiword(Message.lParam)
			'                i = Parent->IndexOf(Control)
			'                ReleaseCapture
			'                Parent->ChildProc = FOldParentProc
			'                Message.Captured  = 0
			'                       This.Left = x - This.Left
			'                   ElseIf Align = 2 Then
			'                       This.Left = This.Left - x
			'                   ElseIf Align = 3 Then
			'                       Top = y - Top
			'                   ElseIf Align = 4 Then
			'                       Top = Top - y
			'                   Parent->RequestAlign
			'                   if onMoved then onMoved(This)
			'            ReleaseCapture
			'            x = Message.lParamLo
			'            y = Message.lParamHi
			'            i = Parent->IndexOf(This)
			'            Parent->ChildProc = FOldParentProc
			'            Message.Captured  = NULL
			'                   This.Left = x - This.Left
			'               ElseIf Align = 2 Then
			'                   'This.Left = This.Left - x
			'                    ?x1 - x, x1, x
			'               ElseIf Align = 3 Then
			'                   Top = y - Top
			'               ElseIf Align = 4 Then
			'                   Top = Top - y
			'               Parent->RequestAlign
			If OnMoved Then OnMoved(*Designer, This)
		End Select
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator Splitter.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
		Private Function Splitter.OnDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As gpointer) As Boolean
			Dim As Splitter Ptr spl = data1
			If Not spl->bCursor Then
				spl->bCursor = True
				spl->Align = spl->Align
			End If
			Return False
		End Function
		
		Private Function Splitter.OnExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As gpointer) As Boolean
			Dim As cairo_t Ptr cr = gdk_cairo_create(Event->window)
			OnDraw(widget, cr, data1)
			cairo_destroy(cr)
			Return False
		End Function
	
	Private Constructor Splitter
		With This
			.Child     = @This
				'widget = gtk_separator_new(GTK_ORIENTATION_VERTICAL)
				'widget = gtk_drawing_area_new()
				widget = gtk_layout_new(NULL, NULL)
				gtk_widget_set_events(widget, _
				GDK_EXPOSURE_MASK Or _
				GDK_SCROLL_MASK Or _
				GDK_STRUCTURE_MASK Or _
				GDK_KEY_PRESS_MASK Or _
				GDK_KEY_RELEASE_MASK Or _
				GDK_FOCUS_CHANGE_MASK Or _
				GDK_LEAVE_NOTIFY_MASK Or _
				GDK_BUTTON_PRESS_MASK Or _
				GDK_BUTTON_RELEASE_MASK Or _
				GDK_POINTER_MOTION_MASK Or _
				GDK_POINTER_MOTION_HINT_MASK)
				'gtk_scrolled_window_set_policy(gtk_scrolled_window(widget), GTK_POLICY_EXTERNAL, GTK_POLICY_EXTERNAL)
				.RegisterClass "Splitter", @This
					g_signal_connect(widget, "draw", G_CALLBACK(@OnDraw), @This)
			WLet(FClassName, "Splitter")
			WLet(FClassAncestor, "")
			.Width     = 3
			.Align     = SplitterAlignmentConstants.alLeft
		End With
	End Constructor
	
	Private Destructor Splitter
	End Destructor
End Namespace
