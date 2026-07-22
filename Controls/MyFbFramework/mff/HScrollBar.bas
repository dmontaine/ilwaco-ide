'###############################################################################
'#  HScrollBar.bi                                                              #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TScrollBar.bi                                                             #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "HScrollBar.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function HScrollBar.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "arrowchangesize": Return @This.FArrowChangeSize
			Case "maxvalue": Return @This.FMax
			Case "minvalue": Return @This.FMin
			Case "pagesize": Return @This.FPageSize
			Case "position": Return @This.FPosition
			Case "style": Return @This.FStyle
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function HScrollBar.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "arrowchangesize": This.ArrowChangeSize = QInteger(Value)
			Case "maxvalue": This.MaxValue = QInteger(Value)
			Case "minvalue": This.MinValue = QInteger(Value)
			Case "pagesize": This.PageSize = QInteger(Value)
			Case "position": This.Position = QInteger(Value)
			Case "style": This.Style = *Cast(ScrollBarControlStyle Ptr, Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property HScrollBar.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property HScrollBar.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property HScrollBar.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property HScrollBar.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property HScrollBar.MinValue As Integer
		Return FMin
	End Property
	
	Private Property HScrollBar.MinValue(Value As Integer)
		FMin = Value
		#ifdef __USE_GTK__
			gtk_range_set_range(gtk_range(widget), FMin, FMax)
		#else
			If Handle Then Perform(SBM_SETRANGE, FMin, FMax)
		#endif
	End Property
	
	Private Property HScrollBar.MaxValue As Integer
		Return FMax
	End Property
	
	Private Property HScrollBar.MaxValue(Value As Integer)
		FMax = Value
		#ifdef __USE_GTK__
			gtk_range_set_range(gtk_range(widget), FMin, FMax)
		#else
			If Handle Then Perform(SBM_SETRANGE, FMin, FMax)
		#endif
	End Property
	
	Private Property HScrollBar.Position As Integer
		#ifdef __USE_GTK__
			FPosition = gtk_range_get_value(gtk_range(widget))
		#else
			If Handle Then FPosition = Perform(SBM_GETPOS, 0, 0)
		#endif
		Return FPosition
	End Property
	
	Private Property HScrollBar.Position(Value As Integer)
		FPosition = Value
		#ifdef __USE_GTK__
			gtk_range_set_value(gtk_range(widget), CDbl(Value))
		#else
			If Handle Then Perform(SBM_SETPOS, FPosition, True)
		#endif
	End Property
	
	Private Property HScrollBar.ArrowChangeSize As Integer
		Return FArrowChangeSize
	End Property
	
	Private Property HScrollBar.ArrowChangeSize(Value As Integer)
		FArrowChangeSize = Value
		#ifdef __USE_GTK__
			gtk_range_set_increments(gtk_range(widget), FArrowChangeSize, FPageSize)
		#endif
	End Property
	
	Private Property HScrollBar.PageSize As Integer
		Return FPageSize
	End Property
	
	Private Property HScrollBar.PageSize(Value As Integer)
		If FPageSize > FMax Or Value = FPageSize Then Exit Property
		FPageSize = Value
		#ifdef __USE_GTK__
			gtk_range_set_increments(gtk_range(widget), FArrowChangeSize, FPageSize)
		#else
			SIF.fMask = SIF_PAGE
			SIF.nPage = FPageSize
			If Handle Then Perform(SBM_SETSCROLLINFO, True, CInt(@SIF))
		#endif
	End Property
	
		
	Private Sub HScrollBar.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator HScrollBar.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	#ifdef __USE_GTK__
		Private Sub HScrollBar.Range_ValueChanged(range As GtkRange Ptr, user_data As Any Ptr)
			Dim As HScrollBar Ptr scr = user_data
			If scr->OnScroll Then scr->OnScroll(*scr->Designer, *scr, gtk_range_get_value(range))
		End Sub
	#endif
	
	Private Constructor HScrollBar
		#ifdef __USE_GTK__
			#ifdef __USE_GTK3__
				widget = gtk_scrollbar_new(GTK_ORIENTATION_HORIZONTAL, NULL)
			#else
				widget = gtk_hscrollbar_new(NULL)
			#endif
			g_signal_connect(widget, "value-changed", G_CALLBACK(@Range_ValueChanged), @This)
			This.RegisterClass "HScrollBar", @This
		#else
			SIF.cbSize = SizeOf(SCROLLINFO)
		#endif
		MaxValue        = 100
		MinValue        = 0
		Position        = 0
		ArrowChangeSize = 1
		PageSize        = 3
		FTabIndex          = -1
		With This
			.Child       = @This
			WLet(FClassName, "HScrollBar")
			WLet(FClassAncestor, "ScrollBar")
			.Width       = 121
			.Height      = 17
		End With
	End Constructor
	
	Private Destructor HScrollBar
	End Destructor
End Namespace
