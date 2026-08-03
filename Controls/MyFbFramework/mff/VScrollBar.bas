'###############################################################################
'#  VScrollBar.bi                                                              #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TScrollBar.bi                                                             #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "VScrollBar.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function VScrollBar.ReadProperty(PropertyName As String) As Any Ptr
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
		Private Function VScrollBar.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
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
	
	Private Property VScrollBar.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property VScrollBar.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property VScrollBar.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property VScrollBar.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property VScrollBar.MinValue As Integer
		Return FMin
	End Property
	
	Private Property VScrollBar.MinValue(Value As Integer)
		FMin = Value
			gtk_range_set_range(GTK_RANGE(widget), FMin, FMax)
	End Property
	
	Private Property VScrollBar.MaxValue As Integer
		Return FMax
	End Property
	
	Private Property VScrollBar.MaxValue(Value As Integer)
		FMax = Value
			gtk_range_set_range(gtk_range(widget), FMin, FMax)
	End Property
	
	Private Property VScrollBar.Position As Integer
			FPosition = gtk_range_get_value(gtk_range(widget))
		Return FPosition
	End Property
	
	Private Property VScrollBar.Position(Value As Integer)
		FPosition = Value
			gtk_range_set_value(gtk_range(widget), CDbl(Value))
	End Property
	
	Private Property VScrollBar.ArrowChangeSize As Integer
		Return FArrowChangeSize
	End Property
	
	Private Property VScrollBar.ArrowChangeSize(Value As Integer)
		FArrowChangeSize = Value
			gtk_range_set_increments(gtk_range(widget), FArrowChangeSize, FPageSize)
	End Property
	
	Private Property VScrollBar.PageSize As Integer
		Return FPageSize
	End Property
	
	Private Property VScrollBar.PageSize(Value As Integer)
		If FPageSize > FMax Or Value = FPageSize Then Exit Property
		FPageSize = Value
			gtk_range_set_increments(gtk_range(widget), FArrowChangeSize, FPageSize)
	End Property
	
		
	Private Sub VScrollBar.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator VScrollBar.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
		Private Sub VScrollBar.Range_ValueChanged(range As GtkRange Ptr, user_data As Any Ptr)
			Dim As VScrollBar Ptr scr = user_data
			If scr->OnScroll Then scr->OnScroll(*scr->Designer, *scr, gtk_range_get_value(range))
		End Sub
	
	Private Constructor VScrollBar
				widget = gtk_scrollbar_new(GTK_ORIENTATION_VERTICAL, NULL)
			g_signal_connect(widget, "value-changed", G_CALLBACK(@Range_ValueChanged), @This)
			This.RegisterClass "VScrollBar", @This
		MaxValue        = 100
		MinValue        = 0
		Position        = 0
		ArrowChangeSize = 1
		PageSize        = 3
		FTabIndex          = -1
		With This
			.Child       = @This
			WLet(FClassName, "VScrollBar")
			WLet(FClassAncestor, "ScrollBar")
			.Width       = 17
			.Height      = 121
		End With
	End Constructor
	
	Private Destructor VScrollBar
	End Destructor
End Namespace
