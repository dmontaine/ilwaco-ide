'###############################################################################
'#  TextBox.bi                                                                 #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TEdit.bi                                                                  #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "TextBox.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function TextBox.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "alignment": Return @FAlignment
			Case "borderstyle": Return @FBorderStyle
				'Case "caretpos": Return @CaretPos
			Case "charcase": Return @FCharCase
			Case "ctl3d": Return @FCtl3D
			Case "hideselection": Return @FHideSelection
			Case "leftmargin": Return @FLeftMargin
			Case "maskchar": Return FMaskChar
			Case "masked": Return @FMasked
			Case "maxlength": Return @FMaxLength
			Case "modified": Return @FModified
			Case "multiline": Return @FMultiline
			Case "numbersonly": Return @FNumbersOnly
			Case "oemconvert": Return @FOEMConvert
			Case "readonly": Return @FReadOnly
			Case "rightmargin": Return @FRightMargin
			Case "scrollbars": Return @FScrollBars
			Case "selstart": Return @FSelStart
			Case "sellength": Return @FSelLength
			Case "selend": Return @FSelEnd
			Case "seltext": Return FSelText
			Case "tabindex": Return @FTabIndex
			Case "topline": Return @FTopLine
			Case "wantreturn": Return @FWantReturn
			Case "wanttab": Return @FWantTab
			Case "wordwraps": Return @FWordWraps
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function TextBox.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "alignment": Alignment = *Cast(AlignmentConstants Ptr, Value)
				Case "borderstyle": BorderStyle = *Cast(BorderStyles Ptr, Value)
				Case "caretpos": CaretPos = *Cast(My.Sys.Drawing.Point Ptr, Value)
				Case "charcase": CharCase = *Cast(CharCases Ptr, Value)
				Case "ctl3d": Ctl3D = QBoolean(Value)
				Case "hideselection": HideSelection = QBoolean(Value)
				Case "leftmargin": LeftMargin = QInteger(Value)
				Case "maskchar": MaskChar = QWString(Value)
				Case "masked": Masked = QBoolean(Value)
				Case "maxlength": MaxLength = QInteger(Value)
				Case "modified": Modified = QBoolean(Value)
				Case "multiline": Multiline = QBoolean(Value)
				Case "numbersonly": NumbersOnly = QBoolean(Value)
				Case "oemconvert": OEMConvert = QBoolean(Value)
				Case "readonly": ReadOnly = QBoolean(Value)
				Case "rightmargin": RightMargin = QInteger(Value)
				Case "scrollbars": ScrollBars = *Cast(ScrollBarsType Ptr, Value)
				Case "selstart": SelStart = QInteger(Value)
				Case "sellength": SelLength = QInteger(Value)
				Case "selend": SelEnd = QInteger(Value)
				Case "seltext": SelText = QWString(Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case "topline": TopLine = QInteger(Value)
				Case "wantreturn": WantReturn = QBoolean(Value)
				Case "wanttab": WantTab = QBoolean(Value)
				Case "wordwraps": WordWraps = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property TextBox.Alignment As AlignmentConstants
		Return FAlignment
	End Property
	
	Private Property TextBox.Alignment(Value As AlignmentConstants)
		If Value <> FAlignment Then
			FAlignment = Value
				Select Case Value
				Case taLeft:
					gtk_entry_set_alignment(GTK_ENTRY(WidgetEntry), 0.0)
					gtk_text_view_set_justification(GTK_TEXT_VIEW(WidgetTextView), GTK_JUSTIFY_LEFT)
				Case taCenter:
					gtk_entry_set_alignment(GTK_ENTRY(WidgetEntry), 0.5)
					gtk_text_view_set_justification(GTK_TEXT_VIEW(WidgetTextView), GTK_JUSTIFY_CENTER)
				Case taRight:
					gtk_entry_set_alignment(GTK_ENTRY(WidgetEntry), 1.0)
					gtk_text_view_set_justification(GTK_TEXT_VIEW(WidgetTextView), GTK_JUSTIFY_RIGHT)
				End Select
		End If
	End Property
	
	Private Property TextBox.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property TextBox.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property TextBox.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property TextBox.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Sub TextBox.ScrollToCaret()
			If GTK_IS_TEXT_VIEW(widget) Then
				gtk_text_view_scroll_to_mark(GTK_TEXT_VIEW(widget), gtk_text_buffer_get_insert(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))), 0.0, True, 0.5, 0.5)
			End If
	End Sub
	
	Private Sub TextBox.ScrollToEnd()
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter iter
				gtk_text_buffer_get_end_iter(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @iter)
				gtk_text_view_scroll_to_iter(GTK_TEXT_VIEW(widget), @iter, 0.0, False, 0.0, 0.0)
			End If
	End Sub
	
	Private Sub TextBox.ScrollToLine(LineNumber As Integer)
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter iter
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @iter, LineNumber)
				gtk_text_view_scroll_to_iter(GTK_TEXT_VIEW(widget), @iter, 0.0, False, 0.0, 0.0)
			End If
	End Sub
	
	Private Property TextBox.LeftMargin() As Integer
			If GTK_IS_TEXT_VIEW(widget) Then
				FLeftMargin = gtk_text_view_get_left_margin(GTK_TEXT_VIEW(widget))
			End If
		Return FLeftMargin
	End Property
	
	Private Property TextBox.LeftMargin(Value As Integer)
		FLeftMargin = Value
			If GTK_IS_TEXT_VIEW(widget) Then
				gtk_text_view_set_left_margin(GTK_TEXT_VIEW(widget), Value)
			End If
	End Property
	
	Private Property TextBox.RightMargin() As Integer
			If GTK_IS_TEXT_VIEW(widget) Then
				FRightMargin = gtk_text_view_get_right_margin(GTK_TEXT_VIEW(widget))
			End If
		Return FRightMargin
	End Property
	
	Private Property TextBox.RightMargin(Value As Integer)
		FRightMargin = Value
			If GTK_IS_TEXT_VIEW(widget) Then
				gtk_text_view_set_right_margin(GTK_TEXT_VIEW(widget), Value)
			End If
	End Property
	
	Private Property TextBox.WantReturn() As Boolean
		Return FWantReturn
	End Property
	
	Private Property TextBox.WantReturn(Value As Boolean)
		FWantReturn = Value
	End Property
	
	Private Property TextBox.WantTab() As Boolean
		Return FWantTab
	End Property
	
	Private Property TextBox.WantTab(Value As Boolean)
		FWantTab = Value
			If GTK_IS_TEXT_VIEW(widget) Then
				gtk_text_view_set_accepts_tab(GTK_TEXT_VIEW(widget), Value)
			End If
	End Property
	
	Private Property TextBox.Multiline() As Boolean
		Return FMultiline
	End Property
	
	Private Property TextBox.Multiline(Value As Boolean)
		FMultiline = Value
			ChangeWidget
	End Property
	
	Private Sub TextBox.AddLine(ByRef wsLine As WString)
		InsertLine(LinesCount - 1, wsLine)
	End Sub
	
	#ifndef TextBox_InsertLine_Off
		Private Sub TextBox.InsertLine(Index As Integer, ByRef wsLine As WString)
			Dim As Integer iStart, LineLen
				If GTK_IS_TEXT_VIEW(widget) Then
					Dim As GtkTextIter _startline
					gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, Index)
					gtk_text_buffer_insert(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, ToUtf8(wsLine & Chr(13) & Chr(10)), -1)
				End If
		End Sub
	#endif
	
	Private Sub TextBox.RemoveLine(Index As Integer)
		Const Empty = ""
		Dim As Integer iStart, iEnd
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter _startline, _endline
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, Index)
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_endline, Index + 1)
				gtk_text_buffer_delete(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, @_endline)
			End If
	End Sub
	
	Private Property TextBox.Text ByRef As WString
			If GTK_IS_WIDGET(widget) Then
				If GTK_IS_TEXT_VIEW(widget) Then
					Dim As GtkTextBuffer Ptr buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))
					Dim As GtkTextIter _start, _end
					gtk_text_buffer_get_bounds(buffer, @_start, @_end)
					FText = WStr(*gtk_text_buffer_get_text(buffer, @_start, @_end, True))
				Else
						FText = WStr(*gtk_entry_get_text(GTK_ENTRY(widget)))
				End If
			End If
			Return *FText.vptr
	End Property
	
	Private Property TextBox.Text(ByRef Value As WString)
		Base.Text = Value
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextBuffer Ptr buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))
				If Value = "" Then
					gtk_text_buffer_set_text(buffer, !"\0", -1)
				Else
					gtk_text_buffer_set_text(buffer, ToUtf8(Value), -1)
				End If
			Else
				If Value = "" Then
						gtk_entry_set_text(GTK_ENTRY(widget), !"\0")
				Else
						gtk_entry_set_text(GTK_ENTRY(widget), ToUtf8(Value))
				End If
			End If
	End Property
	
	Private Property TextBox.Text_ ByRef As UString
			If GTK_IS_WIDGET(widget) Then
				If GTK_IS_TEXT_VIEW(widget) Then
					Dim As GtkTextBuffer Ptr buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))
					Dim As GtkTextIter _start, _end
					gtk_text_buffer_get_bounds(buffer, @_start, @_end)
					FText = WStr(*gtk_text_buffer_get_text(buffer, @_start, @_end, True))
				Else
						FText = WStr(*gtk_entry_get_text(GTK_ENTRY(widget)))
				End If
			End If
			FText_.Resize FText.m_Length
			*FText_.m_Data = *FText.m_Data
			Return FText_
	End Property
	
	Private Sub TextBox.OnTextChanged(ByRef Sender As UString)
		Dim As Control Ptr Owner = Cast(Control Ptr, Sender.m_Owner)
		Owner->Text = Sender
			If GTK_IS_TEXT_VIEW(Owner->widget) Then
				Dim As GtkTextBuffer Ptr buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(Owner->widget))
				If Sender = "" Then
					gtk_text_buffer_set_text(buffer, !"\0", -1)
				Else
					gtk_text_buffer_set_text(buffer, ToUtf8(Sender), -1)
				End If
			Else
				If Sender = "" Then
						gtk_entry_set_text(GTK_ENTRY(Owner->widget), !"\0")
				Else
						gtk_entry_set_text(GTK_ENTRY(Owner->widget), ToUtf8(Sender))
				End If
			End If
	End Sub
	
	Private Property TextBox.Text_(ByRef Value As UString)
		FText_ = Value
	End Property
	
	Private Function TextBox.GetTextLength() As Integer
			If FMultiline Then
				Dim As GtkTextBuffer Ptr buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))
				Return gtk_text_buffer_get_char_count(buffer)
			Else
				Return gtk_entry_get_text_length(GTK_ENTRY(widget))
			End If
	End Function
	
	Private Property TextBox.BorderStyle As BorderStyles
		Return FBorderStyle
	End Property
	
	Private Property TextBox.BorderStyle(Value As BorderStyles)
		FBorderStyle = Value
			If GTK_IS_TEXT_VIEW(widget) Then
				If FBorderStyle Then
					gtk_scrolled_window_set_shadow_type(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_SHADOW_OUT)
				Else
					gtk_scrolled_window_set_shadow_type(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_SHADOW_NONE)
				End If
			End If
	End Property
	
	Private Property TextBox.ReadOnly As Boolean
		Return FReadOnly
	End Property
	
	Private Property TextBox.ReadOnly(Value As Boolean)
		FReadOnly = Value
			gtk_text_view_set_editable(GTK_TEXT_VIEW(WidgetTextView), Not Value)
			gtk_editable_set_editable(GTK_EDITABLE(WidgetEntry), Not Value)
	End Property
	
	Private Property TextBox.Ctl3D As Boolean
		Return FCtl3D
	End Property
	
	Private Property TextBox.Ctl3D(Value As Boolean)
		If Value <> FCtl3D Then
			FCtl3D = Value
			RecreateWnd
		End If
	End Property
	
	Private Property TextBox.HideSelection As Boolean
		Return FHideSelection
	End Property
	
	Private Property TextBox.HideSelection(Value As Boolean)
		FHideSelection = Value
	End Property
	
	Private Property TextBox.OEMConvert As Boolean
		Return FOEMConvert
	End Property
	
	Private Property TextBox.OEMConvert(Value As Boolean)
		If Value <> FOEMConvert Then
			FOEMConvert = Value
			RecreateWnd
		End If
	End Property
	
	Private Property TextBox.CharCase As CharCases
		Return FCharCase
	End Property
	
	Private Property TextBox.CharCase(Value As CharCases)
		If FCharCase <> Value Then
			FCharCase = Value
					Select Case FCharCase
					Case ecNone: gtk_entry_set_input_hints(GTK_ENTRY(WidgetEntry), GTK_INPUT_HINT_NONE): gtk_text_view_set_input_hints(GTK_TEXT_VIEW(WidgetTextView), GTK_INPUT_HINT_NONE)
					Case ecLower: gtk_entry_set_input_hints(GTK_ENTRY(WidgetEntry), GTK_INPUT_HINT_LOWERCASE): gtk_text_view_set_input_hints(GTK_TEXT_VIEW(WidgetTextView), GTK_INPUT_HINT_LOWERCASE)
					Case ecUpper: gtk_entry_set_input_hints(GTK_ENTRY(WidgetEntry), GTK_INPUT_HINT_UPPERCASE_CHARS): gtk_text_view_set_input_hints(GTK_TEXT_VIEW(WidgetTextView), GTK_INPUT_HINT_UPPERCASE_CHARS)
					End Select
		End If
	End Property
	
	Private Property TextBox.Masked As Boolean
		Return FMasked
	End Property
	
	Private Property TextBox.Masked(Value As Boolean)
		FMasked = Value
			If GTK_IS_ENTRY(widget) Then
				gtk_entry_set_visibility(GTK_ENTRY(widget), Not Value)
			End If
	End Property
	
	Private Property TextBox.MaskChar ByRef As WString
		If FMaskChar > 0 Then Return *FMaskChar Else Return ""
	End Property
	
	Private Property TextBox.MaskChar(ByRef Value As WString)
		WLet(FMaskChar, Value)
			If GTK_IS_ENTRY(widget) Then
				gtk_entry_set_invisible_char(GTK_ENTRY(widget), Asc(Value))
			End If
	End Property
	
	Private Property TextBox.NumbersOnly As Boolean
		Return FNumbersOnly
	End Property
	
	Private Property TextBox.NumbersOnly(Value As Boolean)
		FNumbersOnly = Value
			
	End Property
	
	Private Property TextBox.TopLine As Integer
			If GTK_IS_TEXT_VIEW(widget) Then
				For i As Integer = 0 To LinesCount - 1
					Dim As GtkTextIter _startline
					gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, i)
					If gtk_text_view_starts_display_line(GTK_TEXT_VIEW(widget), @_startline) Then
						Return i
					End If
				Next
			End If
		Return FTopLine
	End Property
	
	Private Property TextBox.TopLine(Value As Integer)
		FTopLine = Value
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter _topline
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_topline, Value)
				gtk_text_view_forward_display_line(GTK_TEXT_VIEW(widget), @_topline)
			End If
	End Property
	
	Private Sub TextBox.InputFilter(ByRef Value As WString)
		FInputFilter = _Reallocate(FInputFilter, (Len(Value) + 1) * SizeOf(WString))
		*FInputFilter = Value
	End Sub
	
	Private Sub TextBox.LoadFromFile(ByRef File As WString)
		Dim Result As Integer
		Dim Fn As Integer = FreeFile_
		Result = Open(File For Input Encoding "utf-32" As #Fn)
		If Result <> 0 Then Result = Open(File For Input Encoding "utf-16" As #Fn)
		If Result <> 0 Then Result = Open(File For Input Encoding "utf-8" As #Fn)
		If Result <> 0 Then Result = Open(File For Input As #Fn)
		If Result = 0 Then
			FText = WInput(LOF(Fn), #Fn)
				If GTK_IS_TEXT_VIEW(widget) Then
					Dim As GtkTextBuffer Ptr buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))
					If FText = "" Then
						gtk_text_buffer_set_text(buffer, !"\0", -1)
					Else
						gtk_text_buffer_set_text(buffer, ToUtf8(FText), -1)
					End If
				Else
					If FText = "" Then
						gtk_entry_set_text(GTK_ENTRY(widget), !"\0")
					Else
						gtk_entry_set_text(GTK_ENTRY(widget), ToUtf8(FText))
					End If
				End If
		End If
		CloseFile_(Fn)
	End Sub
	
	Private Sub TextBox.SaveToFile(ByRef FILE As WString)
		Dim As Integer Fn = FreeFile_
		If Open(FILE For Output Encoding "utf-8" As #Fn) = 0 Then
			Print #Fn, Text;
		End If
		CloseFile_(Fn)
	End Sub
	
	Private Function TextBox.GetLineLength(Index As Integer = -1) As Integer
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter _startline, _endline
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, Index)
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_endline, Index + 1)
				Return Len(WStr(*gtk_text_buffer_get_text(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, @_endline, True)))
			End If
		Return -1
	End Function
	
	Private Function TextBox.GetLineFromCharIndex(Index As Integer = -1) As Integer
			If GTK_IS_TEXT_VIEW(widget) Then
				For i As Integer = 0 To LinesCount - 1
					Dim As GtkTextIter _startline, _endline
					gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, i)
					gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_endline, i + 1)
					If Index >= gtk_text_iter_get_offset(@_startline) AndAlso Index <= gtk_text_iter_get_offset(@_endline) Then
						Return i
					End If
				Next
			End If
		Return -1
	End Function
	
	Private Function TextBox.GetCharIndexFromLine(Index As Integer) As Integer
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter _startline
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, Index)
				Return gtk_text_iter_get_offset(@_startline)
			Else
				Return 0
			End If
		Return -1
	End Function
	
	Private Property TextBox.Lines(Index As Integer) ByRef As WString
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter _startline, _endline
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, Index)
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_endline, Index + 1)
				WLet(FLine, WStr(*gtk_text_buffer_get_text(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, @_endline, True)))
				Return *FLine
			ElseIf Index = 0 Then
				Return Text
			End If
		Return ""
	End Property
	
	Private Property TextBox.Lines(Index As Integer, ByRef Value As WString)
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter _startline, _endline
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, Index)
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_endline, Index + 1)
				gtk_text_buffer_delete(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, @_endline)
				gtk_text_buffer_insert(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, ToUtf8(Value & Chr(13) & Chr(10)), -1)
			ElseIf Index = 0 Then
				Text = Value
			End If
	End Property
	
	Private Sub TextBox.GetSel(ByRef iSelStart As Integer, ByRef iSelEnd As Integer)
			If widget Then
				If GTK_IS_TEXT_VIEW(widget) Then
					Dim As GtkTextIter _start, _end
					Dim As GtkTextBuffer Ptr buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))
					gtk_text_buffer_get_selection_bounds(buffer, @_start, @_end)
					iSelStart = gtk_text_iter_get_offset(@_start)
					iSelEnd = gtk_text_iter_get_offset(@_end)
				Else
					Dim As gint gSelStart, gSelEnd
					gtk_editable_get_selection_bounds(GTK_EDITABLE(widget), @gSelStart, @gSelEnd)
					iSelStart = gSelStart
					iSelEnd = gSelEnd
				End If
			End If
	End Sub
	
	Private Sub TextBox.GetSel(ByRef iSelStartRow As Integer, ByRef iSelStartCol As Integer, ByRef iSelEndRow As Integer, ByRef iSelEndCol As Integer)
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter _start, _end, _startline, _endline
				gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
				Dim As Integer StartCharIndex = gtk_text_iter_get_offset(@_start)
				Dim As Integer EndCharIndex = gtk_text_iter_get_offset(@_end)
				iSelStartRow = GetLineFromCharIndex(StartCharIndex)
				iSelEndRow = GetLineFromCharIndex(EndCharIndex)
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, iSelStartRow)
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_endline, iSelEndRow)
				iSelStartCol = StartCharIndex - gtk_text_iter_get_offset(@_startline)
				iSelEndCol = EndCharIndex - gtk_text_iter_get_offset(@_endline)
			Else
				Dim As gint gSelStartCol, gSelEndCol
				gtk_editable_get_selection_bounds(GTK_EDITABLE(widget), @gSelStartCol, @gSelEndCol)
				iSelStartCol = gSelStartCol
				iSelEndCol = gSelEndCol
				iSelStartRow = 0
				iSelEndRow = 0
			End If
	End Sub
	
	Private Sub TextBox.SetSel(iSelStart As Integer, iSelEnd As Integer)
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter _start, _end
				Dim As GtkTextBuffer Ptr buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))
				gtk_text_buffer_get_iter_at_offset(buffer, @_start, iSelStart)
				gtk_text_buffer_get_iter_at_offset(buffer, @_end, iSelEnd)
				gtk_text_buffer_select_range(buffer, @_start, @_end)
			Else
				Dim As gint gSelStart = iSelStart, gSelEnd = iSelEnd
				gtk_editable_select_region(GTK_EDITABLE(widget), gSelStart, gSelEnd)
			End If
	End Sub
	
	Private Sub TextBox.SetSel(iSelStartRow As Integer, iSelStartCol As Integer, iSelEndRow As Integer, iSelEndCol As Integer)
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter _start, _end, _startline, _endline
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, iSelStartRow)
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_endline, iSelEndRow)
				gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, gtk_text_iter_get_offset(@_startline) + iSelStartCol)
				gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_end, gtk_text_iter_get_offset(@_endline) + iSelEndCol)
				gtk_text_buffer_select_range(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
			ElseIf iSelStartRow = 0 Then
				Dim As gint gSelStartCol = iSelStartCol, gSelEndCol = iSelEndCol
				gtk_editable_select_region(GTK_EDITABLE(widget), gSelStartCol, gSelEndCol)
			End If
	End Sub
	
	#ifndef TextBox_LinesCount_Off
		Private Function TextBox.LinesCount As Integer
				If GTK_IS_TEXT_VIEW(widget) Then
					If Text <> "" Then
						Return 1
					End If
				Else
					Return gtk_text_buffer_get_line_count(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)))
				End If
			Return 0
		End Function
	#endif
	
	Private Property TextBox.CaretPos As My.Sys.Drawing.Point
		Dim As Integer x, y
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter _start, _end, _startline
				gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
				Dim As Integer CurCharIndex = gtk_text_iter_get_offset(@_start)
				Dim As Integer CurLineIndex = GetLineFromCharIndex(CurCharIndex)
				gtk_text_buffer_get_iter_at_line(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_startline, CurLineIndex)
				Return Type(CurCharIndex - gtk_text_iter_get_offset(@_startline), CurLineIndex)
			Else
				Return Type(gtk_editable_get_position(GTK_EDITABLE(widget)), 0)
			End If
		Return Type(0, 0)
	End Property
	
	Private Property TextBox.CaretPos(value As My.Sys.Drawing.Point)
	End Property
	
	Private Property TextBox.ScrollBars As ScrollBarsType
		Return FScrollBars
	End Property
	
	Private Property TextBox.ScrollBars(Value As ScrollBarsType)
		FScrollBars = Value
			ChangeWidget
	End Property
	
	Private Property TextBox.WordWraps As Boolean
		Return FWordWraps
	End Property
	
		Private Sub TextBox.ChangeWidget()
			Dim As GtkWidget Ptr Ctrlwidget = IIf(CInt(FMultiline) Or CInt(FWordWraps) Or CInt(FScrollBars), WidgetTextView, WidgetEntry)
			If widget = Ctrlwidget Then Exit Sub
			Dim As GtkTextBuffer Ptr buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(WidgetTextView))
			If CInt(FMultiline) Or CInt(FWordWraps) Or CInt(FScrollBars) Then
				widget = WidgetTextView
				scrolledwidget = WidgetScrolledWindow
				gtk_widget_hide(WidgetEntry)
				gtk_widget_set_no_show_all(WidgetEntry, True)
				If CInt(gtk_widget_get_parent(scrolledwidget) = 0) AndAlso CInt(This.Parent) AndAlso CInt(This.Parent->layoutwidget) Then
					gtk_layout_put(GTK_LAYOUT(This.Parent->layoutwidget), scrolledwidget, FLeft, FTop)
				End If
				If scrolledwidget Then g_object_set_data(G_OBJECT(scrolledwidget), "@@@Control2", @This)
				If widget Then g_object_set_data(G_OBJECT(widget), "@@@Control2", @This)
				SetBounds(FLeft, FTop, FWidth, FHeight)
					gtk_text_buffer_set_text(buffer, *gtk_entry_get_text(GTK_ENTRY(WidgetEntry)), -1)
				gtk_widget_show_all(scrolledwidget)
			Else
				widget = WidgetEntry
				gtk_widget_hide(scrolledwidget)
				gtk_widget_set_no_show_all(scrolledwidget, True)
				SetBounds(FLeft, FTop, FWidth, FHeight)
				Dim As GtkTextIter _start, _end
				gtk_text_buffer_get_bounds(buffer, @_start, @_end)
					gtk_entry_set_text(GTK_ENTRY(widget), *gtk_text_buffer_get_text(buffer, @_start, @_end, True))
				gtk_widget_show(WidgetEntry)
				scrolledwidget = 0
			End If
		End Sub
	
	Private Property TextBox.WordWraps(Value As Boolean)
		Dim As Integer s, e
		GetSel(s, e)
		FWordWraps = Value
			ChangeWidget
			If Value Then
				gtk_text_view_set_wrap_mode(GTK_TEXT_VIEW(widget), GTK_WRAP_WORD)
			Else
				gtk_text_view_set_wrap_mode(GTK_TEXT_VIEW(widget), GTK_WRAP_NONE)
			End If
		ScrollBars = IIf(Value, ScrollBarsType.Vertical, ScrollBarsType.Both)
		SetSel(s, e)
		ScrollToCaret()
	End Property
	
	Private Property TextBox.SelStart As Integer
		Dim As Integer LStart
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter _start, _end
				gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
				FSelStart = gtk_text_iter_get_offset(@_start)
			Else
				FSelStart = gtk_editable_get_position(GTK_EDITABLE(widget))
			End If
		Return FSelStart
	End Property
	
	Private Property TextBox.SelStart(Value As Integer)
		FSelStart = Value
			If GTK_IS_EDITABLE(widget) Then
				gtk_editable_set_position(GTK_EDITABLE(widget), Value)
			Else
				Dim As GtkTextIter _start
				Dim As Integer Value_ = Value
				Dim length As Integer = gtk_text_buffer_get_char_count(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)))
				If Value_ < 0 Then Value_ = 0
				If Value_ > length Then Value_ = length
				gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, Value_)
				gtk_text_buffer_select_range(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_start)
			End If
	End Property
	
	Private Property TextBox.SelLength As Integer
		Dim As Integer LStart, LEnd
			If GTK_IS_EDITABLE(widget) Then
				Dim As gint gStart, gEnd
				gtk_editable_get_selection_bounds(GTK_EDITABLE(widget), @gStart, @gEnd)
				LStart = gStart
				LEnd = gEnd
			Else
				Dim As GtkTextIter _start, _end
				gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
				LStart = gtk_text_iter_get_offset(@_start)
				LEnd = gtk_text_iter_get_offset(@_end)
			End If
		FSelLength = LEnd - LStart
		Return FSelLength
	End Property
	
	Private Property TextBox.SelLength(Value As Integer)
		Dim As Integer LStart, LEnd, FEnd
		FSelLength = Value
			If GTK_IS_EDITABLE(widget) Then
				Dim As gint gStart, gEnd
				gtk_editable_get_selection_bounds(GTK_EDITABLE(widget), @gStart, @gEnd)
				gEnd = gStart + Value
				gtk_editable_select_region(GTK_EDITABLE(widget), gStart, gEnd)
			Else
				Dim As GtkTextIter _start, _end, _endnew
				gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
				LStart = gtk_text_iter_get_offset(@_start)
				LEnd = gtk_text_iter_get_offset(@_end)
				FEnd = LStart + Value
				gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_endnew, FEnd)
				gtk_text_buffer_select_range(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_endnew)
			End If
	End Property
	
	Private Property TextBox.SelEnd As Integer
		Dim As Integer LStart, LEnd
			If GTK_IS_EDITABLE(widget) Then
				Dim As gint gStart, gEnd
				gtk_editable_get_selection_bounds(GTK_EDITABLE(widget), @gStart, @gEnd)
				LEnd = gEnd
			Else
				Dim As GtkTextIter _start, _end
				gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
				LEnd = gtk_text_iter_get_offset(@_end)
			End If
		FSelEnd = LEnd
		Return FSelEnd
	End Property
	
	Private Property TextBox.SelEnd(Value As Integer)
		Dim As Integer LStart, LEnd, FEnd
		FSelEnd = Value
			If GTK_IS_EDITABLE(widget) Then
				Dim As gint gStart, gEnd
				gtk_editable_get_selection_bounds(GTK_EDITABLE(widget), @gStart, @gEnd)
				gEnd = FSelEnd
				gtk_editable_select_region(GTK_EDITABLE(widget), gStart, gEnd)
			Else
				Dim As GtkTextIter _start, _end, _endnew
				gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
				gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_endnew, FSelEnd)
				gtk_text_buffer_select_range(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_endnew)
			End If
	End Property
	
	Private Property TextBox.SelText ByRef As WString
		Dim As Integer LStart, LEnd
			If GTK_IS_EDITABLE(widget) Then
				Dim As gint gStart, gEnd
				gtk_editable_get_selection_bounds(GTK_EDITABLE(widget), @gStart, @gEnd)
				WLet(FSelText, WStr(*gtk_editable_get_chars(GTK_EDITABLE(widget), gStart, gEnd)))
			Else
				Dim As GtkTextIter _start, _end
				gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
				WLet(FSelText, WStr(*gtk_text_buffer_get_text(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end, True)))
			End If
		Return *FSelText
	End Property
	
	Private Property TextBox.SelText(ByRef Value As WString)
		FSelText = _Reallocate(FSelText, (Len(Value) + 1) * SizeOf(WString))
		*FSelText = Value
			If GTK_IS_TEXT_VIEW(widget) Then
				Dim As GtkTextIter _start, _end
				gtk_text_buffer_insert_at_cursor(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), ToUtf8(Value), -1)
				gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
				Dim As GtkTextMark Ptr ptextmark = gtk_text_buffer_create_mark(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), NULL, @_end, False)
				gtk_text_view_scroll_to_mark(GTK_TEXT_VIEW(widget), ptextmark, 0., False, 0., 0.)
			Else
				Dim As gint Pos1 = gtk_editable_get_position(GTK_EDITABLE(widget))
				gtk_editable_insert_text(GTK_EDITABLE(widget), ToUtf8(*FSelText), -1, @Pos1)
			End If
	End Property
	
	Private Property TextBox.MaxLength As Integer
		Return FMaxLength
	End Property
	
	Private Property TextBox.MaxLength(Value As Integer)
		FMaxLength = Value
			If GTK_IS_ENTRY(widget) Then
				gtk_entry_set_max_length(GTK_ENTRY(widget), Value)
			End If
	End Property
	
	Private Property TextBox.Modified As Boolean
			If GTK_IS_TEXT_VIEW(widget) Then
				FModified = gtk_text_buffer_get_modified(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)))
			End If
		Return FModified
	End Property
	
	Private Property TextBox.Modified(Value As Boolean)
		FModified = Value
			If GTK_IS_TEXT_VIEW(widget) Then
				gtk_text_buffer_set_modified(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), FModified)
			End If
	End Property
	
	
	
	Private Sub TextBox.ProcessMessage(ByRef message As Message)
			Dim As GdkEvent Ptr e = message.Event
			Select Case message.Event->type
			Case GDK_KEY_PRESS
				If FWantReturn = False AndAlso Asc(*e->key.string) = 13 Then
					If OnActivate Then OnActivate(*Designer, This)
					message.Result = True
				End If
			End Select
		Base.ProcessMessage(message)
	End Sub
	
	Private Sub TextBox.Clear
		Text = ""
	End Sub
	
	Private Sub TextBox.ClearUndo
	End Sub
	
	Private Function TextBox.CanUndo As Boolean
			Return 0
	End Function
	
	Private Sub TextBox.Undo
	End Sub
	
	Private Sub TextBox.PasteFromClipboard
			If GTK_IS_EDITABLE(widget) Then
				gtk_editable_paste_clipboard(GTK_EDITABLE(widget))
			Else
				gtk_text_buffer_paste_clipboard(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), gtk_clipboard_get(GDK_SELECTION_CLIPBOARD), 0, True)
			End If
	End Sub
	
	'	Sub TextBox.Delete
	'		#ifdef __USE_GTK__
	'			If gtk_is_editable(widget) Then
	'				If gtk_editable_get_selection_bounds(gtk_editable(widget), 0, 0) Then
	'					gtk_editable_delete_selection(gtk_editable(widget))
	'				Else
	'					Dim As Integer pos1 = gtk_editable_get_position(gtk_editable(widget))
	'					gtk_editable_delete_text(gtk_editable(widget), pos1, pos1 + 1)
	'				End If
	'			Else
	'
	'			End If
	'		#else
	'			If FHandle Then Perform(WM_KEYDOWN, WM_DELETE, 0)
	'		#endif
	'	End Sub
	
	Private Sub TextBox.CopyToClipboard
			If GTK_IS_EDITABLE(widget) Then
				gtk_editable_copy_clipboard(GTK_EDITABLE(widget))
			Else
				gtk_text_buffer_copy_clipboard(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), gtk_clipboard_get(GDK_SELECTION_CLIPBOARD))
			End If
	End Sub
	
	Private Sub TextBox.CutToClipboard
			If GTK_IS_EDITABLE(widget) Then
				gtk_editable_cut_clipboard(GTK_EDITABLE(widget))
			Else
				gtk_text_buffer_cut_clipboard(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), gtk_clipboard_get(GDK_SELECTION_CLIPBOARD), True)
			End If
	End Sub
	
	Private Sub TextBox.SelectAll
			If GTK_IS_EDITABLE(widget) Then
				gtk_editable_select_region(GTK_EDITABLE(widget), 0, -1)
			Else
				Dim As GtkTextIter _start, _end
				gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, 0)
				gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_end, gtk_text_buffer_get_char_count(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))))
				gtk_text_buffer_select_range(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
			End If
	End Sub
	
	Private Operator TextBox.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
		Private Sub TextBox.Entry_Changed(entry As GtkEntry Ptr, user_data As Any Ptr)
			Dim As TextBox Ptr txt = user_data
			If txt AndAlso txt->OnChange Then txt->OnChange(*txt->Designer, *txt)
		End Sub
		
		Private Sub TextBox.TextBuffer_Changed(TextBuffer As GtkTextBuffer Ptr, user_data As Any Ptr)
			Dim As TextBox Ptr txt = user_data
			If txt Then
				If CInt(txt->FMaxLength > 0) AndAlso CInt(GTK_IS_TEXT_VIEW(txt->widget)) AndAlso CInt(Len(txt->Text) > txt->FMaxLength) Then
					txt->Text = .Left(txt->Text, txt->FMaxLength)
				Else
					If txt->OnChange Then txt->OnChange(*txt->Designer, *txt)
				End If
			End If
		End Sub
		
		Private Sub TextBox.Entry_Activate(entry As GtkEntry Ptr, user_data As Any Ptr)
			Dim As TextBox Ptr txt = user_data
			Dim As Control Ptr btn = txt->GetForm()->FDefaultButton
			If txt->OnActivate Then txt->OnActivate(*txt->Designer, *txt)
			If btn AndAlso btn->OnClick Then btn->OnClick(*btn->Designer, *btn)
		End Sub
		
		Private Function TextBox.Entry_FocusInEvent(widget As GtkWidget Ptr, Event As GdkEventFocus Ptr, user_data As Any Ptr) As Boolean
			Dim As TextBox Ptr txt = user_data
			If txt AndAlso txt->OnGotFocus Then txt->OnGotFocus(*txt->Designer, *txt)
			Return False
		End Function
		
		Private Function TextBox.Entry_FocusOutEvent(widget As GtkWidget Ptr, Event As GdkEventFocus Ptr, user_data As Any Ptr) As Boolean
			Dim As TextBox Ptr txt = user_data
			If txt AndAlso txt->OnLostFocus Then txt->OnLostFocus(*txt->Designer, *txt)
			Return False
		End Function
		
		Private Sub TextBox.Entry_CopyClipboard(widget As GtkWidget Ptr, user_data As Any Ptr)
			Dim As TextBox Ptr txt = user_data
			If txt AndAlso txt->OnCopy Then txt->OnCopy(*txt->Designer, *txt)
		End Sub
		
		Private Sub TextBox.Entry_CutClipboard(widget As GtkWidget Ptr, user_data As Any Ptr)
			Dim As TextBox Ptr txt = user_data
			If txt AndAlso txt->OnCut Then txt->OnCut(*txt->Designer, *txt)
		End Sub
		
		Private Sub TextBox.Entry_PasteClipboard(widget As GtkWidget Ptr, user_data As Any Ptr)
			Dim As TextBox Ptr txt = user_data
			Dim Action As Integer = 1
			If txt AndAlso txt->OnPaste Then txt->OnPaste(*txt->Designer, *txt, Action)
		End Sub
		
		Private Sub TextBox.TextView_SetScrollAdjustments(textview As GtkTextView Ptr, arg1 As GtkAdjustment Ptr, arg2 As GtkAdjustment Ptr, user_data As Any Ptr)
			Dim As TextBox Ptr txt = user_data
			If GTK_IS_WIDGET(arg1) Then g_signal_connect(arg1, "value-changed", G_CALLBACK(@Adjustment_ValueChanged), txt)
			If GTK_IS_WIDGET(arg2) Then g_signal_connect(arg2, "value-changed", G_CALLBACK(@Adjustment_ValueChanged), txt)
		End Sub
		
		Private Sub TextBox.Adjustment_ValueChanged(adjustment As GtkAdjustment Ptr, user_data As Any Ptr)
			Dim As TextBox Ptr txt = user_data
			If txt AndAlso txt->OnScroll Then txt->OnScroll(*txt->Designer, *txt)
		End Sub
		
		Private Sub TextBox.Preedit_Changed(self As GtkWidget Ptr, preedit As gchar Ptr, user_data As Any Ptr)
			Dim As TextBox Ptr txt = user_data
			If txt AndAlso txt->OnUpdate Then txt->OnUpdate(*txt->Designer, *txt, WStr(*preedit))
		End Sub
		
		Private Sub TextBox.Entry_InsertText(self As GtkEditable Ptr, new_text As gchar Ptr, new_text_length As gint, position As gint Ptr, user_data As Any Ptr)
			Dim As TextBox Ptr txt = user_data
			If txt->CharCase <> ecNone Then
				g_signal_handlers_block_by_func(G_OBJECT (self), G_CALLBACK(@Entry_InsertText), user_data)
				Dim As gint pos1 = gtk_editable_get_position(self)
				gtk_editable_insert_text(self, ToUtf8(IIf(txt->CharCase = ecLower, LCase(*new_text), UCase(*new_text))), new_text_length, position)
				g_signal_handlers_unblock_by_func(G_OBJECT (self), G_CALLBACK(@Entry_InsertText), user_data)
				g_signal_stop_emission_by_name(G_OBJECT(self), "insert_text")
			End If
		End Sub
	
	Private Constructor TextBox
			WidgetEntry = gtk_entry_new()
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
			This.RegisterClass "TextBox", @This
			scrolledwidget = 0
			widget = WidgetEntry
			This.RegisterClass "TextBox", @This
		FBorderStyle      = 1
		FHideSelection    = 1
		FCtl3D            = True
		WLet(FMaskChar, "")
		FText_ = ""
		FText_.m_Owner = @This
		FText_.OnChange = @OnTextChanged
		FEnabled = True
		FTabIndex          = -1
		FWantReturn        = True
		FTabStop = True
		With This
			WLet(FClassName, "TextBox")
			.Child       = @This
			.Width       = 121
			.Height      = ScaleY(Font.Size / 72 * 96 + 6) '21
			'.Cursor      = LoadCursor(NULL, IDC_IBEAM)
		End With
	End Constructor
	
	Private Destructor TextBox
		If FSelText <> 0 Then _Deallocate(FSelText)
		If FLine <> 0 Then _Deallocate(FLine)
		If FMaskChar <> 0 Then _Deallocate(FMaskChar)
		FText = ""
	End Destructor
End Namespace


