'################################################################################
'#  SearchBox.bas                                                               #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2024)                                          #
'################################################################################

#include once "SearchBox.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function SearchBox.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function SearchBox.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "tabindex": TabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property SearchBox.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property SearchBox.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property SearchBox.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property SearchBox.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	
	Private Sub SearchBox.ProcessMessage(ByRef message As Message)
		Base.ProcessMessage(message)
	End Sub
	
	
	Private Operator SearchBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor SearchBox
		With This
					WidgetEntry = gtk_search_entry_new()
				WidgetTextView = gtk_text_view_new()
				gtk_entry_set_activates_default(GTK_ENTRY(WidgetEntry), True)
				gtk_entry_set_width_chars(GTK_ENTRY(WidgetEntry), 0)
				g_signal_connect(GTK_ENTRY(WidgetEntry), "activate", G_CALLBACK(@Entry_Activate), @This)
				g_signal_connect(GTK_ENTRY(WidgetEntry), "changed", G_CALLBACK(@Entry_Changed), @This)
				g_signal_connect(GTK_WIDGET(WidgetEntry), "focus-in-event", G_CALLBACK(@Entry_FocusInEvent), @This)
				g_signal_connect(GTK_WIDGET(WidgetEntry), "focus-out-event", G_CALLBACK(@Entry_FocusOutEvent), @This)
				g_signal_connect(GTK_WIDGET(WidgetEntry), "copy-clipboard", G_CALLBACK(@Entry_CopyClipboard), @This)
				g_signal_connect(GTK_WIDGET(WidgetEntry), "cut-clipboard", G_CALLBACK(@Entry_CutClipboard), @This)
				g_signal_connect(GTK_WIDGET(WidgetEntry), "paste-clipboard", G_CALLBACK(@Entry_PasteClipboard), @This)
				g_signal_connect(GTK_WIDGET(WidgetTextView), "copy-clipboard", G_CALLBACK(@Entry_CopyClipboard), @This)
				g_signal_connect(GTK_WIDGET(WidgetTextView), "cut-clipboard", G_CALLBACK(@Entry_CutClipboard), @This)
				g_signal_connect(GTK_WIDGET(WidgetTextView), "paste-clipboard", G_CALLBACK(@Entry_PasteClipboard), @This)
					g_signal_connect(gtk_scrollable_get_hadjustment(GTK_SCROLLABLE(WidgetTextView)), "value-changed", G_CALLBACK(@Adjustment_ValueChanged), @This)
					g_signal_connect(gtk_scrollable_get_vadjustment(GTK_SCROLLABLE(WidgetTextView)), "value-changed", G_CALLBACK(@Adjustment_ValueChanged), @This)
				g_signal_connect(GTK_TEXT_VIEW(WidgetTextView), "preedit-changed", G_CALLBACK(@Preedit_Changed), @This)
				g_signal_connect(GTK_ENTRY(WidgetEntry), "preedit-changed", G_CALLBACK(@Preedit_Changed), @This)
				g_signal_connect(gtk_text_view_get_buffer(GTK_TEXT_VIEW(WidgetTextView)), "changed", G_CALLBACK(@TextBuffer_Changed), @This)
				WidgetScrolledWindow = gtk_scrolled_window_new(NULL, NULL)
				gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(WidgetScrolledWindow), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
				gtk_scrolled_window_set_shadow_type(GTK_SCROLLED_WINDOW(WidgetScrolledWindow), GTK_SHADOW_OUT)
				gtk_container_add(GTK_CONTAINER(WidgetScrolledWindow), WidgetTextView)
				scrolledwidget = WidgetScrolledWindow
				widget = WidgetTextView
				This.RegisterClass "SearchBox", @This
				scrolledwidget = 0
				widget = WidgetEntry
				This.RegisterClass "SearchBox", @This
			FHideSelection    = False
			FTabIndex          = -1
			FTabStop           = True
			WLet(FClassName, "SearchBox")
			Child       = @This
			Width       = 121
			Height      = ScaleY(Font.Size / 72 * 96 + 6) '21
		End With
	End Constructor
	
	Private Destructor SearchBox
	End Destructor
End Namespace
