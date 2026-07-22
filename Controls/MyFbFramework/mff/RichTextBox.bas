'################################################################################
'#  RichTextBox.bi                                                              #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov(2018-2019)  Liu XiaLin                          #
'################################################################################

#include once "RichTextBox.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function RichTextBox.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "editstyle": Return @FEditStyle
			Case "selalignment": FSelIntVal = SelAlignment: Return @FSelIntVal
			Case "selbackcolor": FSelIntVal = SelBackColor: Return @FSelIntVal
			Case "selbold": FSelBoolVal = SelBold: Return @FSelBoolVal
			Case "selbullet": FSelBoolVal = SelBullet: Return @FSelBoolVal
			Case "selcharoffset": FSelIntVal = SelCharOffset: Return @FSelIntVal
			Case "selcharset": FSelIntVal = SelCharSet: Return @FSelIntVal
			Case "selcolor": FSelIntVal = SelColor: Return @FSelIntVal
			Case "selfontname": WLet(FSelWStrVal, SelFontName): Return FSelWStrVal
			Case "selfontsize": FSelIntVal = SelFontSize: Return @FSelIntVal
			Case "selindent": FSelIntVal = SelIndent: Return @FSelIntVal
			Case "selitalic": FSelBoolVal = SelItalic: Return @FSelBoolVal
			Case "selprotected": FSelBoolVal = SelProtected: Return @FSelBoolVal
			Case "selrightindent": FSelIntVal = SelRightIndent: Return @FSelIntVal
			Case "selhangingindent": FSelIntVal = SelHangingIndent: Return @FSelIntVal
			Case "seltabcount": FSelIntVal = SelTabCount: Return @FSelIntVal
			Case "selunderline": FSelBoolVal = SelUnderline: Return @FSelBoolVal
			Case "selstrikeout": FSelBoolVal = SelStrikeout: Return @FSelBoolVal
			Case "tabindex": Return @FTabIndex
			Case "textrtf": TextRTF: Return FTextRTF.vptr
			Case "zoom": Return @FZoom
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function RichTextBox.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "editstyle": EditStyle = QBoolean(Value)
				Case "selalignment": SelAlignment = *Cast(AlignmentConstants Ptr, Value)
				Case "selbackcolor": SelBackColor = QInteger(Value)
				Case "selbold": SelBold = QBoolean(Value)
				Case "selbullet": SelBullet = QBoolean(Value)
				Case "selcharoffset": SelCharOffset = QInteger(Value)
				Case "selcharset": SelCharSet = QInteger(Value)
				Case "selcolor": SelColor = QInteger(Value)
				Case "selfontname": SelFontName = QWString(Value)
				Case "selfontsize": SelFontSize = QInteger(Value)
				Case "selindent": SelIndent = QInteger(Value)
				Case "selitalic": SelItalic = QBoolean(Value)
				Case "selprotected": SelProtected = QBoolean(Value)
				Case "selrightindent": SelRightIndent = QInteger(Value)
				Case "selhangingindent": SelHangingIndent = QInteger(Value)
				Case "seltabcount": SelTabCount = QInteger(Value)
				Case "selunderline": SelUnderline = QBoolean(Value)
				Case "selstrikeout": SelStrikeout = QBoolean(Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case "textrtf": TextRTF = QWString(Value)
				Case "zoom": Zoom = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property RichTextBox.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property RichTextBox.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property RichTextBox.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property RichTextBox.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Function RichTextBox.GetTextRange(cpMin As Integer, cpMax As Integer) ByRef As WString
	Static EmptyWString As WString * 1
		Dim cpMax2 As Integer = cpMax
			Dim As GtkTextIter _start, _end
			gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, cpMin)
			gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_end, cpMax)
			WLet(FSelText, WStr(*gtk_text_buffer_get_text(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end, True)))
		If FTextRange> 0 Then Return *FTextRange Else Return EmptyWString
	End Function
	
	Private Property RichTextBox.SelAlignment As AlignmentConstants
			Dim As Integer iAlignment = GetIntProperty("justification")
			Return IIf(iAlignment = GTK_JUSTIFY_CENTER, AlignmentConstants.taCenter, IIf(iAlignment = GTK_JUSTIFY_RIGHT, AlignmentConstants.taRight, AlignmentConstants.taLeft))
		Return 0
	End Property
	
	Private Property RichTextBox.SelAlignment(Value As AlignmentConstants)
			SetIntProperty "justification", IIf(Value = AlignmentConstants.taLeft, GTK_JUSTIFY_LEFT, IIf(Value = AlignmentConstants.taCenter, GTK_JUSTIFY_CENTER, IIf(Value = AlignmentConstants.taRight, GTK_JUSTIFY_RIGHT, 0)))
	End Property
	
	Private Property RichTextBox.SelBullet As Boolean
			Dim As GtkTextIter FStart, FEnd
			gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @FStart, @FEnd)
			Dim As Boolean bBullet
			Dim As GSList Ptr list = gtk_text_iter_get_tags(@FStart)
			While(list)
			Dim As GtkTextTag Ptr TextTag = list->data
			Dim intval1 As gint, intval2 As gint, ptab_array As PangoTabArray Ptr
			g_object_get(TextTag, "indent", @intval1, "left-margin", @intval2, "tabs", @ptab_array, NULL)
			If intval1 <> -14 AndAlso intval2 = -14 AndAlso ptab_array <> 0 Then bBullet = True
			list = g_slist_next(list)
		Wend
		g_slist_free(list)
		Return bBullet
		Return 0
	End Property
	
	Private Property RichTextBox.SelBullet(Value As Boolean)
			Dim As GtkTextTagTable Ptr TextTagTable = gtk_text_buffer_get_tag_table(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)))
			Dim As GtkTextTag Ptr NeedTextTag, NotNeedTextTag, TrueTextTag, FalseTextTag
			Dim As String NeedTagName, TrueTagName = "Bullet1", FalseTagName = "Bullet0"
			TrueTextTag = gtk_text_tag_table_lookup(TextTagTable, TrueTagName)
			FalseTextTag = gtk_text_tag_table_lookup(TextTagTable, FalseTagName)
			If Value Then
				NeedTextTag = TrueTextTag
				NotNeedTextTag = FalseTextTag
				NeedTagName = TrueTagName
			Else
				NeedTextTag = FalseTextTag
				NotNeedTextTag = TrueTextTag
				NeedTagName = FalseTagName
			End If
			Dim As GtkTextIter FStart, FEnd
			gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @FStart, @FEnd)
			If NeedTextTag = 0 Then
				NeedTextTag = gtk_text_tag_new(NeedTagName)
				If Value Then
					Dim As PangoTabArray Ptr ptab_array = pango_tab_array_new(2, True)
					pango_tab_array_set_tab(ptab_array, 0, PANGO_TAB_LEFT, 0)
					pango_tab_array_set_tab(ptab_array, 1, PANGO_TAB_LEFT, 14)
					g_object_set(NeedTextTag, "indent", -14, "left-margin", 14, "wrap-mode", GTK_WRAP_WORD, "tabs", ptab_array, NULL)
				Else
					g_object_set(NeedTextTag, "indent", 0, "left-margin", 0, "wrap-mode", GTK_WRAP_WORD, "tabs", 0, NULL)
				End If
				gtk_text_tag_table_add(TextTagTable, NeedTextTag)
			Else
				gtk_text_buffer_remove_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), NeedTextTag, @FStart, @FEnd)
			End If
			If NotNeedTextTag <> 0 Then gtk_text_buffer_remove_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), NotNeedTextTag, @FStart, @FEnd)
			gtk_text_buffer_apply_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), NeedTextTag, @FStart, @FEnd)
	End Property
	
	Private Property RichTextBox.SelIndent As Integer
			Return gtk_text_view_get_indent(GTK_TEXT_VIEW(widget))
		Return 0
	End Property
	
	Private Property RichTextBox.SelIndent(Value As Integer)
			gtk_text_view_set_indent(GTK_TEXT_VIEW(widget), Value)
	End Property
	
	Private Property RichTextBox.SelRightIndent As Integer
			Return GetIntProperty("right-margin")
		Return 0
	End Property
	
	Private Property RichTextBox.SelRightIndent(Value As Integer)
			SetIntProperty("right-margin", Value)
	End Property
	
	Private Property RichTextBox.SelHangingIndent As Integer
			Return GetIntProperty("indent") - SelIndent
		Return 0
	End Property
	
	Private Property RichTextBox.SelHangingIndent(Value As Integer)
			SetIntProperty("indent", SelIndent + Value)
	End Property
	
	Private Property RichTextBox.SelTabCount As Integer
			Dim As GtkTextIter FStart, FEnd
			gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @FStart, @FEnd)
			Dim As PangoTabArray Ptr ptab_array
			Dim As GSList Ptr list = gtk_text_iter_get_tags(@FStart)
			While(list)
			Dim As GtkTextTag Ptr TextTag = list->data
			list = g_slist_next(list)
			g_object_get(TextTag, "tabs", @ptab_array, NULL)
			If ptab_array <> 0 Then Exit While
		Wend
		g_slist_free(list)
		If ptab_array = 0 Then Return 0
		Dim As Integer sTabCount = pango_tab_array_get_size(ptab_array)
		pango_tab_array_free(ptab_array)
		Return sTabCount
		Return 0
	End Property
	
	Private Property RichTextBox.SelTabCount(Value As Integer)
			Dim As GtkTextIter FStart, FEnd
			gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @FStart, @FEnd)
			Dim As PangoTabArray Ptr ptab_array
			Dim As GSList Ptr list = gtk_text_iter_get_tags(@FStart)
			While(list)
			Dim As GtkTextTag Ptr TextTag = list->data
			list = g_slist_next(list)
			g_object_get(TextTag, "tabs", @ptab_array, NULL)
			If ptab_array <> 0 Then Exit While
		Wend
		g_slist_free(List)
		If ptab_array = 0 Then
			ptab_array = pango_tab_array_new(Value, True)
		Else
			pango_tab_array_resize(ptab_array, Value)
		End If
		Dim As GtkTextTag Ptr TextTag = gtk_text_tag_new("Tabs")
		g_object_set(TextTag, "tabs", ptab_array, NULL)
		gtk_text_buffer_apply_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), TextTag, @FStart, @FEnd)
		g_object_unref(TextTag)
	End Property
	
	Private Property RichTextBox.SelTabs(sElement As Integer) As Integer
			If sElement >= 0 AndAlso sElement < SelTabCount Then
				Dim As GtkTextIter FStart, FEnd
				gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @FStart, @FEnd)
				Dim As PangoTabArray Ptr ptab_array
				Dim As GSList Ptr list = gtk_text_iter_get_tags(@FStart)
				While(list)
				Dim As GtkTextTag Ptr TextTag = list->data
				list = g_slist_next(list)
				g_object_get(TextTag, "tabs", @ptab_array, NULL)
				If ptab_array <> 0 Then Exit While
			Wend
			g_slist_free(list)
			If ptab_array = 0 Then Return 0
			Dim As gint Value
			pango_tab_array_get_tab(ptab_array, sElement, PANGO_TAB_LEFT, @Value)
			Return Value
		End If
		Return 0
	End Property
	
	Private Property RichTextBox.SelTabs(sElement As Integer, Value As Integer)
			If sElement >= 0 AndAlso sElement < SelTabCount Then
				Dim As GtkTextIter FStart, FEnd
				gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @FStart, @FEnd)
				Dim As PangoTabArray Ptr ptab_array
				Dim As GSList Ptr list = gtk_text_iter_get_tags(@FStart)
				While(list)
				Dim As GtkTextTag Ptr TextTag = list->data
				list = g_slist_next(list)
				g_object_get(TextTag, "tabs", @ptab_array, NULL)
				If ptab_array <> 0 Then Exit While
			Wend
			g_slist_free(list)
			If ptab_array = 0 Then ptab_array = pango_tab_array_new(sElement + 1, True)
			pango_tab_array_set_tab(ptab_array, sElement, PANGO_TAB_LEFT, Value)
			gtk_text_view_set_tabs(GTK_TEXT_VIEW(widget), ptab_array)
			Dim As GtkTextTag Ptr TextTag = gtk_text_tag_new("Tabs")
			g_object_set(TextTag, "tabs", ptab_array, NULL)
			gtk_text_buffer_apply_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), TextTag, @FStart, @FEnd)
			g_object_unref(TextTag)
		End If
	End Property
	
	Private Property RichTextBox.SelBackColor As Integer
			Return BGRToRGBA(ValInt(GetStrProperty("background")))
		Return 0
	End Property
	
	Private Property RichTextBox.SelBackColor(Value As Integer)
			'SetStrProperty "background", "#" & Hex(RGBAToBGR(Value), 6), True
			SetStrProperty "background", "#" & Hex(Value, 6), True
	End Property
	
	Private Property RichTextBox.SelColor As Integer
			Return BGRToRGBA(ValInt(GetStrProperty("foreground")))
		Return 0
	End Property
	
	Private Property RichTextBox.SelColor(Value As Integer)
			'SetStrProperty "foreground", "#" & Hex(RGBAToBGR(Value), 6), True
			SetStrProperty "foreground", "#" & Hex(Value, 6), True
	End Property
	
	Private Property RichTextBox.SelFontName ByRef As WString
			Return GetStrProperty("family")
		Return Font.Name
	End Property
	
	Private Property RichTextBox.SelFontName(ByRef Value As WString)
			SetStrProperty("family", Value)
	End Property
	
	Private Property RichTextBox.SelFontSize As Integer
			Return GetIntProperty("size")
		Return 0
	End Property
	
	Private Property RichTextBox.SelFontSize(Value As Integer)
			SetIntProperty "size", Value
	End Property
	
		Private Function RichTextBox.GetStrProperty(sProperty As String) ByRef As WString
	Static EmptyWString As WString * 1
			Dim As GtkTextIter FStart, FEnd
			gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @FStart, @FEnd)
			Dim As GSList Ptr list = gtk_text_iter_get_tags(@FStart)
			While (list)
				Dim As GtkTextTag Ptr TextTag = list->data
				Dim As gchar Ptr strval
				g_object_get(TextTag, sProperty, @strval, NULL)
				If *strval <> "" Then WLet(FSelWStrVal, WStr(*strval))
				list = g_slist_next(list)
			Wend
			g_slist_free(list)
			If FSelWStrVal > 0 Then Return *FSelWStrVal Else Return EmptyWString
		End Function
		
		Private Sub RichTextBox.SetStrProperty(sProperty As String, ByRef Value As WString, WithoutPrevValue As Boolean = False)
			Dim As GtkTextTagTable Ptr TextTagTable = gtk_text_buffer_get_tag_table(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)))
			Dim As GtkTextTag Ptr NeedTextTag, NotNeedTextTag
			Dim As String NeedTagName = sProperty & Value, NotNeedTagName = sProperty & IIf(WithoutPrevValue, WStr(""), GetStrProperty(sProperty))
			NeedTextTag = gtk_text_tag_table_lookup(TextTagTable, NeedTagName)
			NotNeedTextTag = gtk_text_tag_table_lookup(TextTagTable, NotNeedTagName)
			Dim As GtkTextIter FStart, FEnd
			gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @FStart, @FEnd)
			If NeedTextTag = 0 Then
				NeedTextTag = gtk_text_tag_new(NeedTagName)
				g_object_set(NeedTextTag, sProperty, ToUtf8(Value), NULL)
				gtk_text_tag_table_add(TextTagTable, NeedTextTag)
			Else
				gtk_text_buffer_remove_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), NeedTextTag, @FStart, @FEnd)
			End If
			If NotNeedTextTag <> 0 Then gtk_text_buffer_remove_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), NotNeedTextTag, @FStart, @FEnd)
			gtk_text_buffer_apply_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), NeedTextTag, @FStart, @FEnd)
		End Sub
		
		Private Function RichTextBox.GetIntProperty(sProperty As String) As Integer
			Dim As GtkTextIter FStart, FEnd
			gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @FStart, @FEnd)
			Dim As Integer iResult
			Dim As GSList Ptr list = gtk_text_iter_get_tags(@FStart)
			While (list)
				Dim As GtkTextTag Ptr TextTag = list->data
				Dim As gint intval
				g_object_get(TextTag, sProperty, @intval, NULL)
				If intval <> 0 Then iResult = intval
				list = g_slist_next(list)
			Wend
			g_slist_free(list)
			Return iResult
		End Function
		
		Private Sub RichTextBox.SetIntProperty(sProperty As String, Value As Integer)
			Dim As GtkTextTagTable Ptr TextTagTable = gtk_text_buffer_get_tag_table(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)))
			Dim As GtkTextTag Ptr NeedTextTag, NotNeedTextTag
			Dim As String NeedTagName = sProperty & Str(Value), NotNeedTagName = sProperty & Str(GetIntProperty(sProperty))
			NeedTextTag = gtk_text_tag_table_lookup(TextTagTable, NeedTagName)
			NotNeedTextTag = gtk_text_tag_table_lookup(TextTagTable, NotNeedTagName)
			Dim As GtkTextIter FStart, FEnd
			gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @FStart, @FEnd)
			If NeedTextTag = 0 Then
				NeedTextTag = gtk_text_tag_new(NeedTagName)
				g_object_set(NeedTextTag, sProperty, Value, NULL)
				gtk_text_tag_table_add(TextTagTable, NeedTextTag)
			Else
				gtk_text_buffer_remove_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), NeedTextTag, @FStart, @FEnd)
			End If
			If NotNeedTextTag <> 0 Then gtk_text_buffer_remove_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), NotNeedTextTag, @FStart, @FEnd)
			gtk_text_buffer_apply_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), NeedTextTag, @FStart, @FEnd)
		End Sub
		
		Private Function RichTextBox.GetBoolProperty(sProperty As String, NeedValue As Integer) As Boolean
			Dim As GtkTextTagTable Ptr TextTagTable = gtk_text_buffer_get_tag_table(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)))
			Dim As GtkTextTag Ptr NeedTextTag
			Dim As String NeedTagName = sProperty & Str(NeedValue)
			NeedTextTag = gtk_text_tag_table_lookup(TextTagTable, NeedTagName)
			If NeedTextTag = 0 Then Return False
			Dim As GtkTextIter FStart, FEnd
			gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @FStart, @FEnd)
			Dim As Boolean bResult
			Dim As GSList Ptr list = gtk_text_iter_get_tags(@FStart)
			While (list)
				Dim As GtkTextTag Ptr TextTag = list->data
				If NeedTextTag = TextTag Then bResult = True: Exit While
				list = g_slist_next(list)
			Wend
			g_slist_free(list)
			Return bResult
		End Function
		
		Private Sub RichTextBox.SetBoolProperty(sProperty As String, Value As Boolean, TrueValue As Integer, FalseValue As Integer, StartChar As Integer = -1, EndChar As Integer = -1)
			Dim As GtkTextTagTable Ptr TextTagTable = gtk_text_buffer_get_tag_table(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)))
			Dim As GtkTextTag Ptr NeedTextTag, NotNeedTextTag, TrueTextTag, FalseTextTag
			Dim As String NeedTagName, TrueTagName = sProperty & Str(TrueValue), FalseTagName = sProperty & Str(FalseValue)
			TrueTextTag = gtk_text_tag_table_lookup(TextTagTable, TrueTagName)
			FalseTextTag = gtk_text_tag_table_lookup(TextTagTable, FalseTagName)
			If Value Then
				NeedTextTag = TrueTextTag
				NotNeedTextTag = FalseTextTag
				NeedTagName = TrueTagName
			Else
				NeedTextTag = FalseTextTag
				NotNeedTextTag = TrueTextTag
				NeedTagName = FalseTagName
			End If
			Dim As GtkTextIter FStart, FEnd
			If StartChar = -1 OrElse EndChar = -1 Then
				gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @FStart, @FEnd)
			Else
				Dim As GtkTextBuffer Ptr buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))
				gtk_text_buffer_get_iter_at_offset(buffer, @FStart, StartChar)
				gtk_text_buffer_get_iter_at_offset(buffer, @FEnd, EndChar)
			End If
			If NeedTextTag = 0 Then
				NeedTextTag = gtk_text_tag_new(NeedTagName)
				g_object_set(NeedTextTag, sProperty, IIf(Value, TrueValue, FalseValue), NULL)
				gtk_text_tag_table_add(TextTagTable, NeedTextTag)
			Else
				gtk_text_buffer_remove_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), NeedTextTag, @FStart, @FEnd)
			End If
			If NotNeedTextTag <> 0 Then gtk_text_buffer_remove_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), NotNeedTextTag, @FStart, @FEnd)
			gtk_text_buffer_apply_tag(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), NeedTextTag, @FStart, @FEnd)
		End Sub
	
	Private Property RichTextBox.SelBold As Boolean
			Return GetBoolProperty("weight", PANGO_WEIGHT_BOLD)
		Return 0
	End Property
	
	Private Property RichTextBox.SelBold(Value As Boolean)
			SetBoolProperty "weight", Value, PANGO_WEIGHT_BOLD, PANGO_WEIGHT_NORMAL
	End Property
	
	Private Property RichTextBox.SelItalic As Boolean
			Return GetBoolProperty("style", PANGO_STYLE_ITALIC)
		Return 0
	End Property
	
	Private Property RichTextBox.SelItalic(Value As Boolean)
			SetBoolProperty "style", Value, PANGO_STYLE_ITALIC, PANGO_STYLE_NORMAL
	End Property
	
	Private Property RichTextBox.SelUnderline As Boolean
			Return GetBoolProperty("underline", PANGO_UNDERLINE_SINGLE)
		Return 0
	End Property
	
	Private Property RichTextBox.SelUnderline(Value As Boolean)
			SetBoolProperty "style", Value, PANGO_UNDERLINE_SINGLE, PANGO_UNDERLINE_NONE
	End Property
	
	Private Property RichTextBox.SelStrikeout As Boolean
			Return GetBoolProperty("strikethrough", True)
		Return 0
	End Property
	
	Private Property RichTextBox.SelStrikeout(Value As Boolean)
			SetBoolProperty "strikethrough", Value, True, False
	End Property
	
	Private Property RichTextBox.SelProtected As Boolean
			Return GetBoolProperty("editable", True)
		Return 0
	End Property
	
	Private Property RichTextBox.SelProtected(Value As Boolean)
			SetBoolProperty "editable", Value, True, False
	End Property
	
	Private Property RichTextBox.SelCharOffset As Integer
			Return GetIntProperty("rise")
		Return 0
	End Property
	
	Private Property RichTextBox.SelCharOffset(Value As Integer)
			SetIntProperty("rise", Value)
	End Property
	
	Private Property RichTextBox.SelCharSet As Integer
		Return 0
	End Property
	
	Private Property RichTextBox.SelCharSet(Value As Integer)
	End Property
	
	Private Function RichTextBox.GetCharIndexFromPos(p As My.Sys.Drawing.Point) As Integer
			Dim As GtkTextIter TextIter
			gtk_text_view_get_iter_at_position(GTK_TEXT_VIEW(widget), @TextIter, 0, p.X, p.Y)
			Return gtk_text_iter_get_offset(@TextIter)
	End Function
	
	Private Property RichTextBox.Zoom As Integer
		Return FZoom
	End Property
	
	Private Property RichTextBox.Zoom(Value As Integer)
		FZoom = Value
	End Property
	
	Private Function RichTextBox.BottomLine As Integer
			Return 0
	End Function
	
	Private Function RichTextBox.CanRedo As Boolean
			Return 0
	End Function
	
	Private Sub RichTextBox.Undo
	End Sub
	
	Private Sub RichTextBox.Redo
	End Sub
	
	Private Function RichTextBox.Find(ByRef Value As WString) As Boolean
			Dim As GtkTextIter _start, _end, match_start, match_end
			gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, 0)
			gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_end, gtk_text_buffer_get_char_count(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))))
			Dim As Boolean bResult = gtk_text_iter_forward_search(@_start, ToUtf8(Value), GTK_TEXT_SEARCH_TEXT_ONLY, @match_start, @match_end, @_end)
			If bResult Then gtk_text_buffer_select_range(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @match_start, @match_end)
			Return bResult
	End Function
	
	Private Function RichTextBox.FindNext(ByRef Value As WString = "") As Boolean
			Dim As GtkTextIter _start, _end, sel_start, sel_end, match_start, match_end
			gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, 0)
			gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_end, gtk_text_buffer_get_char_count(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))))
			gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @sel_start, @sel_end)
			Dim As Boolean bResult = gtk_text_iter_forward_search(@sel_end, ToUtf8(Value), GTK_TEXT_SEARCH_TEXT_ONLY, @match_start, @match_end, @_end)
			If bResult Then gtk_text_buffer_select_range(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @match_start, @match_end)
			Return bResult
	End Function
	
	Private Function RichTextBox.FindPrev(ByRef Value As WString = "") As Boolean
			Dim As GtkTextIter _start, _end, sel_start, sel_end, match_start, match_end
			gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, 0)
			gtk_text_buffer_get_iter_at_offset(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_end, gtk_text_buffer_get_char_count(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))))
			gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @sel_start, @sel_end)
			Dim As Boolean bResult = gtk_text_iter_backward_search(@sel_start, ToUtf8(Value), GTK_TEXT_SEARCH_TEXT_ONLY, @match_start, @match_end, @_start)
			If bResult Then gtk_text_buffer_select_range(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @match_start, @match_end)
			Return bResult
	End Function
	
	
	Private Sub RichTextBox.ProcessMessage(ByRef message As Message)
		Base.ProcessMessage(message)
	End Sub
	
	Private Property RichTextBox.EditStyle As Boolean
		Return FEditStyle
	End Property
	
	Private Property RichTextBox.EditStyle(Value As Boolean)
		FEditStyle = Value
	End Property
	
	Private Property RichTextBox.SelText ByRef As WString
	Static EmptyWString As WString * 1
		Dim As Integer LStart, LEnd
			Dim As GtkTextIter _start, _end
			gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
			WLet(FSelText, WStr(*gtk_text_buffer_get_text(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end, True)))
		If FSelText > 0 Then Return *FSelText Else Return EmptyWString
	End Property
	
	Private Property RichTextBox.SelText(ByRef Value As WString)
		FSelText = _Reallocate(FSelText, (Len(Value) + 1) * SizeOf(WString))
		*FSelText = Value
			Dim As GtkTextIter _start, _end
			gtk_text_buffer_insert_at_cursor(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), ToUtf8(Value), -1)
	End Property
	
	
	Private Property RichTextBox.TextRTF As UString
		Return FTextRTF
	End Property
	
	Private Property RichTextBox.TextRTF(Value As UString)
		FTextRTF = Value
			If StartsWith(Value, "{\rtf") OrElse StartsWith(Value, "{\urtf") Then
				Dim As GtkTextBuffer Ptr buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget))
				Dim iter As GtkTextIter
				gtk_text_buffer_set_text(buffer, !"\0", -1)
				gtk_text_buffer_get_end_iter(buffer, @iter)
				Dim in_tag As Boolean = False
				Dim count As Integer = 0
				Dim start_bold As Integer = -1
				Dim start_italic As Integer = -1
				Dim rtf_tag As String
				Dim c As UString
				Dim Buff As UString
				For i As Integer = 1 To Len(Value)
					c = Mid(Value, i, 1)
					If CBool(c = "\") OrElse (CBool(c = " ") AndAlso in_tag) OrElse CBool(c = "}") Then
						If Buff <> "" Then
							gtk_text_buffer_insert(buffer, @iter, ToUtf8(Buff), -1)
							Buff = ""
						End If
						If in_tag Then
							If rtf_tag = "b" Then
								start_bold = count
							ElseIf rtf_tag = "i" Then
								start_italic = count
							ElseIf rtf_tag = "par" Then
								gtk_text_buffer_insert(buffer, @iter, Chr(13, 10), 2)
								count += 1
							End If
						End If
						If start_bold > -1 AndAlso ((in_tag AndAlso CBool(rtf_tag = "b0")) OrElse CBool(c = "}")) Then
							SetBoolProperty "weight", True, PANGO_WEIGHT_BOLD, PANGO_WEIGHT_NORMAL, start_bold, count
							start_bold = -1
						End If
						If start_italic > -1 AndAlso ((in_tag AndAlso CBool(rtf_tag = "i0")) OrElse CBool(c = "}")) Then
							SetBoolProperty "style", True, PANGO_STYLE_ITALIC, PANGO_STYLE_NORMAL, start_italic, count
							start_italic = -1
						End If
						rtf_tag = ""
						in_tag = c = "\"
					ElseIf c = "{" Or c = "}" Then
						Continue For
					ElseIf in_tag Then
						If c = !"\n" Then
							Continue For
						End If
						rtf_tag += c
					Else
						Buff += c
						count += 1
					End If
				Next
			Else
				Base.Text = Value
			End If
	End Property
	
	Private Function RichTextBox.AddImageFromFile(ByRef File As WString) As Boolean
		Dim As My.Sys.Drawing.BitmapType Bitm
		Bitm.LoadFromFile(File)
		Return AddImage(Bitm)
	End Function
	
	Private Function RichTextBox.AddImage(ByRef ResName As WString) As Boolean
		Dim As My.Sys.Drawing.BitmapType Bitm
		Bitm.LoadFromResourceName(ResName)
		Return AddImage(Bitm)
	End Function
	
	Private Function RichTextBox.AddImage(ByRef Ico As My.Sys.Drawing.Icon) As Boolean
		Dim As My.Sys.Drawing.BitmapType Bitm
			Bitm.Handle = Ico.Handle
		Return AddImage(Bitm)
	End Function
	
	Private Function RichTextBox.AddImage(ByRef Cur As My.Sys.Drawing.Cursor) As Boolean
		Dim As My.Sys.Drawing.BitmapType Bitm
		Return AddImage(Bitm)
	End Function
	
	Private Function RichTextBox.AddImage(ByRef Bitm As My.Sys.Drawing.BitmapType) As Boolean
			Dim As GtkWidget Ptr img
			Dim As GtkTextIter _start, _end
			gtk_text_buffer_get_selection_bounds(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
			gtk_text_buffer_delete(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, @_end)
			'ChildAnchor = gtk_text_buffer_create_child_anchor(gtk_text_view_get_buffer(gtk_text_view(widget)), @_start)
			'img = gtk_image_new_from_pixbuf(Bitm.Handle)
			'gtk_text_view_add_child_at_anchor(gtk_text_view(widget), img, ChildAnchor)
			gtk_text_buffer_insert_pixbuf(gtk_text_view_get_buffer(GTK_TEXT_VIEW(widget)), @_start, Bitm.Handle)
			'gtk_widget_show(img)
		Return True
	End Function
	
	Private Sub RichTextBox.LoadFromFile(ByRef Value As WString, bRTF As Boolean)
	End Sub
	
	Private Sub RichTextBox.SaveToFile(ByRef Value As WString, bRTF As Boolean)
	End Sub
	
	Private Function RichTextBox.SelPrint(ByRef Canvas As My.Sys.Drawing.Canvas) As Boolean
			Return False
	End Function
	
	
	Private Operator RichTextBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor RichTextBox
		With This
				widget = gtk_text_view_new()
			.FHideSelection    = False
			FTabIndex          = -1
			FTabStop           = True
			WLet(.FClassName, "RichTextBox")
			.Child       = @This
			.DoubleBuffered = True
			.SetBounds 0, 0, 121, 121
		End With
	End Constructor
	
	Private Destructor RichTextBox
		If FFindText Then _Deallocate(FFindText)
		If FTextRange Then _Deallocate(FTextRange)
		If FSelWStrVal Then _Deallocate(FSelWStrVal)
	End Destructor
End Namespace
