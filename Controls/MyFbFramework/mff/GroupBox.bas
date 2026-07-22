'###############################################################################
'#  GroupBox.bi                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TGroupBox.bi                                                              #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "GroupBox.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function GroupBox.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "caption": Return FText.vptr
			Case "text": Return FText.vptr
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function GroupBox.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "caption": This.Caption = QWString(Value)
			Case "text": This.Text = QWString(Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property GroupBox.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property GroupBox.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property GroupBox.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property GroupBox.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property GroupBox.Caption ByRef As WString
		Return Text
	End Property
	
	Private Property GroupBox.Caption(ByRef Value As WString)
		Text = Value
	End Property
	
	Private Property GroupBox.Text ByRef As WString
		#ifdef __USE_GTK__
			FText = WStr(gtk_frame_get_label(GTK_FRAME(widget)))
			Return *FText.vptr
		#else
			Return Base.Text
		#endif
	End Property
	
	Private Property GroupBox.Text(ByRef Value As WString)
		Base.Text = Value
		#ifdef __USE_GTK__
			If widget Then gtk_frame_set_label(GTK_FRAME(widget), ToUtf8(Value))
		#endif
	End Property
	
	Private Property GroupBox.ParentColor As Boolean
		Return FParentColor
	End Property
	
	Private Property GroupBox.ParentColor(Value As Boolean)
		FParentColor = Value
		If FParentColor Then
			This.BackColor = This.Parent->BackColor
			Invalidate
		End If
	End Property
	
	
	#ifdef __USE_WASM__
		Private Function GroupBox.GetContent() As UString
			Return "<legend id=""" & Trim(Str(@This)) & "legend"">" & FText & "</legend>"
		End Function
	#endif
	
	
	Private Sub GroupBox.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator GroupBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor GroupBox
		With This
			.Child       = @This
			#ifdef __USE_GTK__
				widget = gtk_frame_new("")
				.RegisterClass "GroupBox", @This
			#elseif 0
				.RegisterClass "GroupBox", "Button"
				.ChildProc   = @WndProc
				WLet(FClassAncestor, "Button")
			#elseif 0
				WLet(FClassAncestor, "fieldset")
			#endif
			WLet(FClassName, "GroupBox")
			FTabIndex          = -1
			FTabStop           = True
			#ifdef __USE_GTK__
				.BackColor       = -1
			#elseif 0
				.BackColor       = GetSysColor(COLOR_BTNFACE)
				FDefaultBackColor = .BackColor
				.OnHandleIsAllocated    = @HandleIsAllocated
			#endif
			.Width       = 121
			.Height      = 51
		End With
	End Constructor
	
	Private Destructor GroupBox
	End Destructor
End Namespace
