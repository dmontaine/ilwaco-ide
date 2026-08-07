'###############################################################################
'#  CommandButton.bi                                                           #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TButton.bi                                                                #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "CommandButton.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function CommandButton.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "cancel": Return Cast(Any Ptr, @FCancel)
			Case "caption": Return Cast(Any Ptr, This.FText.vptr)
			Case "default": Return Cast(Any Ptr, @FDefault)
			Case "style": Return @FStyle
			Case "tabindex": Return @FTabIndex
			Case "text": Return Cast(Any Ptr, This.FText.vptr)
			Case "graphic": Return @Graphic
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function CommandButton.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "cancel": If Value <> 0 Then This.Cancel = QBoolean(Value)
			Case "caption": If Value <> 0 Then This.Text = QWString(Value)
			Case "default": If Value <> 0 Then This.Default = QBoolean(Value)
			Case "style": If Value <> 0 Then This.Style = *Cast(ButtonStyle Ptr, Value)
			Case "tabindex": If Value <> 0 Then This.TabIndex = QInteger(Value)
			Case "text": If Value <> 0 Then This.Text = QWString(Value)
			Case "graphic": If Value <> 0 Then This.Graphic = QWString(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property CommandButton.Caption ByRef As WString
		Return This.Text
	End Property
	
	Private Property CommandButton.Caption(ByRef Value As WString)
		This.Text = Value
	End Property
	
	Private Property CommandButton.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property CommandButton.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property CommandButton.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property CommandButton.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property CommandButton.Text ByRef As WString
		Return Base.Text
	End Property
	
	Private Property CommandButton.Text(ByRef Value As WString)
		Base.Text = Value
			gtk_label_set_text_with_mnemonic(GTK_LABEL(gtk_bin_get_child(GTK_BIN(widget))), ToUtf8(Replace(Value, "&", "_")))
	End Property
	
	Private Property CommandButton.Cancel As Boolean
		Return FCancel
	End Property
	
	Private Property CommandButton.Cancel(Value As Boolean)
		If Value <> FCancel Then
			FCancel = Value
			Dim As Control Ptr frm = This.GetForm
			If frm Then
				If Value Then
					frm->FCancelButton = @This
				ElseIf frm->FCancelButton = @This Then
					frm->FCancelButton = 0
				End If
			End If
		End If
	End Property
	
	Private Property CommandButton.Default As Boolean
		Return FDefault
	End Property
	
	Private Property CommandButton.Default(Value As Boolean)
		If Value <> FDefault Then
			FDefault = Value
				gtk_widget_set_can_default(widget, Value)
			Dim As Control Ptr frm = This.GetForm
			If frm Then
				If Value Then
					frm->FDefaultButton = @This
				ElseIf frm->FDefaultButton = @This Then
					frm->FDefaultButton = 0
				End If
			End If
		End If
	End Property
	
	#ifndef CommandButton_Style_Get_Off
		Private Property CommandButton.Style As ButtonStyle
			Return FStyle
		End Property
	#endif
	
	Private Property CommandButton.Style(Value As ButtonStyle)
		If Value <> FStyle Then
			FStyle = Value
		End If
	End Property
	
	Private Sub CommandButton.GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
		With Sender
			If .Ctrl->Child Then
			End If
		End With
	End Sub
	
	
	#ifndef CommandButton_EnumMenuItems_Off
		Private Function CommandButton.EnumMenuItems(Item As MenuItem, ByRef List As List) As Boolean
			For i As Integer = 0 To Item.Count -1
				List.Add Item.Item(i)
				EnumMenuItems *Item.Item(i),List
			Next i
			Return True
		End Function
	#endif
	
	Private Sub CommandButton.ProcessMessage(ByRef msg As Message)
		Base.ProcessMessage(msg)
	End Sub
	
	Private Operator CommandButton.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
		Private Sub CommandButton.Clicked(widget As GtkButton Ptr, user_data As Any Ptr)
			Dim As CommandButton Ptr but = user_data
			If but->OnClick Then but->OnClick(*but->Designer, *but)
		End Sub
	
	Private Constructor CommandButton
			widget = gtk_button_new_with_label("")
			g_signal_connect(widget, "clicked", G_CALLBACK(@Clicked), @This)
		Graphic.Ctrl  = @This
		Graphic.OnChange = @GraphicChange
		FTabIndex            = -1
		FTabStop = True
		With This
			.Child       = @This
			WLet(FClassName, "CommandButton")
				.RegisterClass "CommandButton", @This
			.Width       = 75
			.Height      = 25
		End With
	End Constructor
	
	Private Destructor CommandButton
	End Destructor
End Namespace
