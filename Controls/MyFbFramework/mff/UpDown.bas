'###############################################################################
'#  UpDown.bi                                                                  #
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

#include once "UpDown.bi"
'Const UDN_DELTAPOS = (UDN_FIRST - 1)

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function UpDown.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "alignment": Return @FAlignment
			Case "arrowkeys": Return @FArrowKeys
			Case "associate": Return FAssociate
			Case "increment": Return @FIncrement
			Case "maxvalue": Return @FMaxValue
			Case "minvalue": Return @FMinValue
			Case "position": Return @FPosition
			Case "style": Return @FStyle
			Case "tabindex": Return @FTabIndex
			Case "text": Text: Return FText.vptr
			Case "thousands": Return @FThousands
			Case "wrap": Return @FWrap
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function UpDown.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "alignment": Alignment = *Cast(UpDownAlignment Ptr, Value)
				Case "arrowkeys": ArrowKeys = QBoolean(Value)
				Case "associate": Associate = Value
				Case "increment": Increment = QInteger(Value)
				Case "maxvalue": MaxValue = QInteger(Value)
				Case "minvalue": MinValue = QInteger(Value)
				Case "position": Position = QInteger(Value)
				Case "style": Style = *Cast(UpDownOrientation Ptr, Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case "text": Text = QWString(Value)
				Case "thousands": Thousands = QInteger(Value)
				Case "wrap": Wrap = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property UpDown.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property UpDown.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property UpDown.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property UpDown.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property UpDown.MinValue As Integer
		Return FMinValue
	End Property
	
	Private Property UpDown.MinValue(Value As Integer)
		FMinValue = Value
		#ifdef __USE_GTK__
			gtk_spin_button_set_range(GTK_SPIN_BUTTON(widget), FMinValue, FMaxValue)
		#else
			If Handle Then
				If FMinValue < 0 OrElse FMaxValue < 0 Then
					SendMessage(Handle, UDM_SETRANGE32, FMinValue, FMaxValue)
				Else
					SendMessage(Handle, UDM_SETRANGE, 0, MAKELPARAM(FMaxValue, FMinValue))
				End If
			End If
		#endif
	End Property
	
	Private Property UpDown.MaxValue As Integer
		Return FMaxValue
	End Property
	
	Private Property UpDown.MaxValue(Value As Integer)
		FMaxValue = Value
		#ifdef __USE_GTK__
			gtk_spin_button_set_range(GTK_SPIN_BUTTON(widget), FMinValue, FMaxValue)
		#else
			If Handle Then 
				If FMinValue < 0 OrElse FMaxValue < 0 Then
					SendMessage(Handle, UDM_SETRANGE32, FMinValue, FMaxValue)
				Else
					SendMessage(Handle, UDM_SETRANGE, 0, MAKELONG(FMaxValue, FMinValue))
				End If
			End If
		#endif
	End Property
	
	Private Property UpDown.Position As Integer
		#ifdef __USE_GTK__
			FPosition = gtk_spin_button_get_value(GTK_SPIN_BUTTON(widget))
		#else
			If Handle Then
				'FPosition = LoWord(SendMessage(Handle, UDM_GETPOS, 0, 0))
				FPosition = SendMessage(Handle, UDM_GETPOS32, 0, 0)
			End If
		#endif
		Return FPosition
	End Property
	
	Private Property UpDown.Position(Value As Integer)
		FPosition = Value
		#ifdef __USE_GTK__
			gtk_spin_button_set_value(GTK_SPIN_BUTTON(widget), FPosition)
		#else
			If Handle Then
				If FPosition < 0 Then
					SendMessage(Handle, UDM_SETPOS32, 0, FPosition)
				Else
					SendMessage(Handle, UDM_SETPOS, 0, MAKELONG(FPosition, 0))
				End If
				If FAssociate Then
					FAssociate->Text = Str(Position)
				End If
			End If
		#endif
	End Property
	
	Private Property UpDown.Increment As Integer
		Return FIncrement
	End Property
	
	Private Property UpDown.Increment(Value As Integer)
		If Value <> FIncrement Then
			FIncrement = Value
			#ifdef __USE_GTK__
				gtk_spin_button_set_increments(GTK_SPIN_BUTTON(widget), FIncrement, FIncrement)
			#else
				If Handle Then
					SendMessage(Handle, UDM_GETACCEL, 1, CInt(@FUDAccel(0)))
					FUDAccel(0).nInc = Value
					SendMessage(Handle, UDM_SETACCEL, 1, CInt(@FUDAccel(0)))
				End If
			#endif
		End If
	End Property
	
	Private Property UpDown.Text ByRef As WString
		FText = Str(Position)
		Return *FText.vptr
	End Property
	
	Private Property UpDown.Text(ByRef Value As WString)
		Position = Val(Value)
	End Property
	
	Private Property UpDown.Thousands As Boolean
		Return FThousands
	End Property
	
	Private Property UpDown.Thousands(Value As Boolean)
		If FThousands <> Value Then
			FThousands = Value
		End If
	End Property
	
	Private Property UpDown.Wrap As Boolean
		Return FWrap
	End Property
	
	Private Property UpDown.Wrap(Value As Boolean)
		If FWrap <> Value Then
			FWrap = Value
			#ifdef __USE_GTK__
				gtk_spin_button_set_wrap(GTK_SPIN_BUTTON(widget), FWrap)
			#else
				Base.Style = WS_CHILD Or UDS_SETBUDDYINT Or AStyle(abs_(FStyle)) Or AAlignment(abs_(FAlignment)) Or AWrap(abs_(FWrap)) Or AArrowKeys(abs_(FArrowKeys)) Or AAThousand(abs_(FThousands))
			#endif
		End If
	End Property
	
	Private Property UpDown.Style As UpDownOrientation
		Return FStyle
	End Property
	
	Private Property UpDown.Style(Value As UpDownOrientation)
		Dim As Integer OldStyle,Temp
		OldStyle = FStyle
		If FStyle <> Value Then
			FStyle = Value
			If OldStyle = 0 Then
				Temp = This.Width
				This.Width = Height
				Height = Temp
			Else
				Temp = This.Height
				This.Height = Width
				Width = Temp
			End If
		End If
	End Property
	
	Private Property UpDown.Alignment As UpDownAlignment
		Return FAlignment
	End Property
	
	Private Property UpDown.Alignment(Value As UpDownAlignment)
		If FAlignment <> Value Then
			FAlignment = Value
		End If
	End Property
	
	Private Property UpDown.Associate As Control Ptr
		Return FAssociate
	End Property
	
	Private Property UpDown.Associate(Value As Control Ptr)
		FAssociate = Value
		If FAssociate Then
			If UCase(FAssociate->ClassName) = "TEXTBOX" Then
				FAssociate->Text = WStr(Position)
			Else
			End If
		End If
	End Property
	
	Private Property UpDown.ArrowKeys As Boolean
		Return FArrowKeys
	End Property
	
	Private Property UpDown.ArrowKeys(Value As Boolean)
		FArrowKeys = Value
	End Property
	
	
	Private Sub UpDown.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator UpDown.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor UpDown
		Dim As Boolean Result
		#ifdef __USE_GTK__
			widget = gtk_spin_button_new_with_range(0, 100, 1)
			
		#else
			Dim As INITCOMMONCONTROLSEX ICC
			ICC.dwSize = SizeOf(ICC)
			ICC.dwICC  = ICC_UPDOWN_CLASS
			Result = INITCOMMONCONTROLSEX(@ICC)
			If Not Result Then InitCommonControls
			AStyle(0)        = 0
			AStyle(1)        = UDS_HORZ
			AAlignment(0)    = UDS_ALIGNRIGHT
			AAlignment(1)    = UDS_ALIGNLEFT
			AWrap(0)         = 0
			AWrap(1)         = UDS_WRAP
			AArrowKeys(0)    = 0
			AArrowKeys(1)    = UDS_ARROWKEYS
			AAThousand(0)    = UDS_NOTHOUSANDS
			AAThousand(1)    = 0
		#endif
		FMinValue        = 0
		FMaxValue        = 100
		FArrowKeys       = True
		FIncrement       = 1
		FAlignment       = 0
		FStyle           = 0
		FThousands       = True
		FTabIndex          = -1
		FTabStop         = True
		With This
			.Child             = @This
			WLet(FClassName, "UpDown")
		End With
	End Constructor
	
	Private Destructor UpDown
	End Destructor
End Namespace
