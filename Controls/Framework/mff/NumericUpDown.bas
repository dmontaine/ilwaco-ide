'###############################################################################
'#  NumericUpDown.bi                                                                  #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TUpDown.bi                                                                #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "NumericUpDown.bi"
'Const UDN_DELTAPOS = (UDN_FIRST - 1)

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function NumericUpDown.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "arrowkeys": FBooleanTemp = UpDownControl.ArrowKeys: Return @FBooleanTemp
			Case "decimalplaces": Return @FDecimalPlaces
			Case "increment": FDoubleTemp = UpDownControl.Increment: Return @FDoubleTemp
			Case "maxvalue": FIntegerTemp = UpDownControl.MaxValue: Return @FIntegerTemp
			Case "minvalue": FIntegerTemp = UpDownControl.MinValue: Return @FIntegerTemp
			Case "position": FDoubleTemp = UpDownControl.Position: Return @FDoubleTemp
			Case "style": Return @FStyle
			Case "tabindex": Return @FTabIndex
			Case "text": Text: Return @FText
			Case "thousands": FBooleanTemp = UpDownControl.Thousands: Return @FBooleanTemp
			Case "updownwidth": FIntegerTemp = UpDownControl.Width: Return @FIntegerTemp
			Case "wrap": FBooleanTemp = UpDownControl.Wrap: Return @FBooleanTemp
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function NumericUpDown.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "arrowkeys": ArrowKeys = QBoolean(Value)
				Case "decimalplaces": DecimalPlaces = QInteger(Value)
				Case "increment": Increment = QDouble(Value)
				Case "maxvalue": MaxValue = QInteger(Value)
				Case "minvalue": MinValue = QInteger(Value)
				Case "position": Position  = QDouble(Value)
				Case "style": Style = *Cast(UpDownOrientation Ptr, Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case "text": Text = QWString(Value)
				Case "thousands": Thousands = QBoolean(Value)
				Case "updownwidth": UpDownWidth = QInteger(Value)
				Case "wrap": Wrap = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property NumericUpDown.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property NumericUpDown.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property NumericUpDown.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property NumericUpDown.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property NumericUpDown.MinValue As Double
		If FDecimalPlaces > 0 Then Return UpDownControl.MinValue / FScaleFactor Else Return UpDownControl.MinValue
	End Property
	
	Private Property NumericUpDown.MinValue(Value As Double)
		UpDownControl.MinValue = IIf(FDecimalPlaces > 0,  Value * FScaleFactor, Value)
	End Property
	
	Private Property NumericUpDown.MaxValue As Double
		If FDecimalPlaces > 0 Then Return UpDownControl.MaxValue / FScaleFactor Else Return UpDownControl.MaxValue
	End Property
	
	Private Property NumericUpDown.MaxValue(Value As Double)
		UpDownControl.MaxValue = IIf(FDecimalPlaces > 0,  Value * FScaleFactor, Value)
	End Property
	
	Private Property NumericUpDown.Position As Double
		If FDecimalPlaces > 0 Then Return UpDownControl.Position / FScaleFactor Else Return UpDownControl.Position
	End Property
	
	Private Property NumericUpDown.Position(Value As Double)
		UpDownControl.Position = IIf(FDecimalPlaces > 0,  Value * FScaleFactor, Value)
	End Property
	
	Private Property NumericUpDown.Increment As Double
		If FDecimalPlaces > 0 Then Return UpDownControl.Increment / FScaleFactor Else Return UpDownControl.Increment
	End Property
	
	Private Property NumericUpDown.Increment(Value As Double)
		UpDownControl.Increment = IIf(FDecimalPlaces > 0,  Value * FScaleFactor, Value)
	End Property
	
	Private Property NumericUpDown.DecimalPlaces As Integer
		Return FDecimalPlaces
	End Property
	
	Private Property NumericUpDown.DecimalPlaces(Value As Integer)
		FDecimalPlaces = Value
		FScaleFactor = Val(Mid("1000000", 1, FDecimalPlaces + 1))
		'If FDecimalPlaces > 1 Then UpDownControl.Increment = FScaleFactor / Val(Mid("1000000", 1, FDecimalPlaces))
	End Property
	Private Property NumericUpDown.Text ByRef As WString
			FText = UpDownControl.Text
		Return FText
	End Property
	
	Private Property NumericUpDown.Text(ByRef Value As WString)
		Dim As Integer DotPos = InStr(Value, ".")
		If DotPos > 0 Then
			FDecimalPlaces = Len(Value) - DotPos
			FScaleFactor = Val(Mid("1000000", 1, FDecimalPlaces))
		Else
			FDecimalPlaces = 0: FScaleFactor = 1
		End If
		If UpDownControl.Text <> Value Then
			UpDownControl.Text = IIf(FDecimalPlaces > 0, WStr(Val(Value) * FScaleFactor), Value)
		End If
		Base.Text = IIf(FDecimalPlaces > 0, WStr(Val(Value) / FScaleFactor), Value)
	End Property
	
	Private Property NumericUpDown.Thousands As Boolean
		Return UpDownControl.Thousands
	End Property
	
	Private Property NumericUpDown.Thousands(Value As Boolean)
		UpDownControl.Thousands = Value
	End Property
	
	Private Property NumericUpDown.ArrowKeys As Boolean
		Return UpDownControl.ArrowKeys
	End Property
	
	Private Property NumericUpDown.ArrowKeys(Value As Boolean)
		UpDownControl.ArrowKeys = Value
	End Property
	
	Private Property NumericUpDown.Wrap As Boolean
		Return UpDownControl.Wrap
	End Property
	
	Private Property NumericUpDown.Wrap(Value As Boolean)
		UpDownControl.Wrap = Value
	End Property
	
	Private Property NumericUpDown.Style As UpDownOrientation
		Return FStyle
	End Property
	
	Private Property NumericUpDown.Style(Value As UpDownOrientation)
		FStyle = Value
		UpDownControl.Associate = 0
		UpDownControl.Style = FStyle
		UpDownControl.Associate = @This
	End Property
	
	Private Property NumericUpDown.UpDownWidth As Integer
		Return UpDownControl.Width
	End Property
	
	Private Property NumericUpDown.UpDownWidth(Value As Integer)
		UpDownControl.Width = Value
		MoveUpDownControl
	End Property
	
	Private Sub NumericUpDown.SelectAll
			'If GTK_IS_EDITABLE(widget) Then
			'	gtk_editable_select_region(GTK_EDITABLE(widget), 0, -1)
			'Else
			'	Dim As GtkTextIter _start, _end
			'	gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, 0)
			'	gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_end, gtk_text_buffer_get_char_count(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))))
			'	gtk_text_buffer_select_range(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
			'End If
	End Sub
	
		Private Sub NumericUpDown.SpinButton_ValueChanged(self As GtkSpinButton Ptr, user_data As Any Ptr)
			Dim As NumericUpDown Ptr nud = user_data
			If nud->OnChange Then nud->OnChange(*nud->Designer, *nud)
		End Sub
	
	Private Sub NumericUpDown.MoveUpDownControl
	End Sub
	
	Private Sub NumericUpDown.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator NumericUpDown.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor NumericUpDown
			widget = UpDownControl.Handle
			g_signal_connect(widget, "value_changed", G_CALLBACK(@SpinButton_ValueChanged), @This)
		With This
			.Child             = @This
			UpDownControl.Associate = @This
			.Add @UpDownControl
			FTabIndex          = -1
			FTabStop         = True
			WLet(FClassName, "NumericUpDown")
			WLet(FClassAncestor, "Edit")
		End With
	End Constructor
	
	Private Destructor NumericUpDown
		If GTK_IS_WIDGET(widget) Then
			g_signal_handlers_disconnect_by_func(widget, G_CALLBACK(@SpinButton_ValueChanged), @This)
		End If
		widget = 0
	End Destructor
End Namespace
