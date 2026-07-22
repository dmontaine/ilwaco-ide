'###############################################################################
'#  ComboBoxEdit.bi                                                            #
'#  This file is part of MyFBFramework                                         #
'#  Based on:                                                                  #
'#   TComboBox.bi                                                              #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "ComboBoxEdit.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function ComboBoxEdit.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "dropdowncount": Return @FDropDownCount
			Case "integralheight": Return @FIntegralHeight
			Case "itemheight": Return @FItemHeight
			Case "newindex": Return @FNewIndex
			Case "selcolor": Return @FSelColor
			Case "sort": Return @FSort
			Case "style": Return @FStyle
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function ComboBoxEdit.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "designmode": DesignMode = QBoolean(Value): If FDesignMode Then This.AddItem *FName: This.ItemIndex = 0
			Case "dropdowncount": DropDownCount = QInteger(Value)
			Case "integralheight": This.IntegralHeight = QBoolean(Value)
			Case "itemheight": This.ItemHeight = QInteger(Value)
			Case "selcolor": This.SelColor = QInteger(Value)
			Case "sort": This.Sort = QBoolean(Value)
			Case "style": This.Style = *Cast(ComboBoxEditStyle Ptr, Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Function ComboBoxEdit.NewIndex As Integer
		Return FNewIndex
	End Function
	
	Private Sub ComboBoxEdit.Undo
	End Sub
	
	Private Sub ComboBoxEdit.PasteFromClipboard
		#ifdef __USE_GTK__
			If GTK_IS_EDITABLE(gtk_bin_get_child(GTK_BIN(widget))) Then
				gtk_editable_paste_clipboard(GTK_EDITABLE(gtk_bin_get_child(GTK_BIN(widget))))
			End If
		#elseif 0
			If FEditHandle Then SendMessage(FEditHandle, WM_PASTE, 0, 0)
		#endif
	End Sub
	
	Private Sub ComboBoxEdit.CopyToClipboard
		#ifdef __USE_GTK__
			If GTK_IS_EDITABLE(gtk_bin_get_child(GTK_BIN(widget))) Then
				gtk_editable_copy_clipboard(GTK_EDITABLE(gtk_bin_get_child(GTK_BIN(widget))))
			End If
		#elseif 0
			If FEditHandle Then SendMessage(FEditHandle, WM_COPY, 0, 0)
		#endif
	End Sub
	
	Private Sub ComboBoxEdit.CutToClipboard
		#ifdef __USE_GTK__
			If GTK_IS_EDITABLE(gtk_bin_get_child(GTK_BIN(widget))) Then
				gtk_editable_cut_clipboard(GTK_EDITABLE(gtk_bin_get_child(GTK_BIN(widget))))
			End If
		#elseif 0
			If FEditHandle Then SendMessage(FEditHandle, WM_CUT, 0, 0)
		#endif
	End Sub
	
	Private Sub ComboBoxEdit.SelectAll
		#ifdef __USE_GTK__
			If GTK_IS_EDITABLE(gtk_bin_get_child(GTK_BIN(widget))) Then
				gtk_editable_select_region(GTK_EDITABLE(gtk_bin_get_child(GTK_BIN(widget))), 0, -1)
			End If
		#elseif 0
			If FEditHandle Then SendMessage(FEditHandle, EM_SETSEL, 0, -1)
		#endif
	End Sub
	
	Private Property ComboBoxEdit.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property ComboBoxEdit.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property ComboBoxEdit.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property ComboBoxEdit.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Sub ComboBoxEdit.ShowDropDown(Value As Boolean)
		#ifdef __USE_GTK__
			gtk_combo_box_popup(GTK_COMBO_BOX(widget))
		#elseif 0
			Perform CB_SHOWDROPDOWN, Value, 0
		#endif
	End Sub
	
	
	Private Sub ComboBoxEdit.RegisterClass
	End Sub
	
	Private Property ComboBoxEdit.SelColor As Integer
		Return FSelColor
	End Property
	
	Private Property ComboBoxEdit.SelColor(Value As Integer)
		FSelColor = Value
		Invalidate
	End Property
	
	Private Property ComboBoxEdit.Style As ComboBoxEditStyle
		Return FStyle
	End Property
	
	Private Property ComboBoxEdit.Style(Value As ComboBoxEditStyle)
		If Value <> FStyle Then
			FStyle = Value
			#ifdef __USE_GTK__
				Dim As GtkWidget Ptr Ctrlwidget = IIf(FStyle <= 1, DropDownWidget, DropDownListWidget)
				If widget = Ctrlwidget Then Exit Property
				If Ctrlwidget = DropDownWidget Then
					widget = DropDownWidget
						gtk_widget_hide(DropDownListWidget)
					If gtk_widget_get_parent(DropDownListWidget) = eventboxwidget Then
						g_object_ref(DropDownListWidget)
						gtk_container_remove(GTK_CONTAINER(eventboxwidget), DropDownListWidget)
					End If
					gtk_container_add(GTK_CONTAINER(eventboxwidget), widget)
					If widget Then
						g_object_set_data(G_OBJECT(widget), "@@@Control2", @This)
						g_object_set_data(G_OBJECT(gtk_bin_get_child(GTK_BIN(DropDownWidget))), "@@@Control2", @This)
					End If
					Dim As GtkTreeIter Iter
					If gtk_tree_model_get_iter_first(gtk_combo_box_get_model(GTK_COMBO_BOX(widget)), @Iter) = False Then
						This.Clear
						This.AddItem *FName: This.ItemIndex = 0
					End If
						gtk_widget_show(widget)
				Else
					widget = DropDownListWidget
						gtk_widget_hide(DropDownWidget)
					If gtk_widget_get_parent(DropDownWidget) = eventboxwidget Then
						g_object_ref(DropDownWidget)
						gtk_container_remove(GTK_CONTAINER(eventboxwidget), DropDownWidget)
					End If
					gtk_container_add(GTK_CONTAINER(eventboxwidget), widget)
						gtk_widget_show(widget)
				End If
			#elseif 0
				Base.Style = WS_CHILD Or WS_VSCROLL Or CBS_HASSTRINGS Or CBS_AUTOHSCROLL Or AStyle(abs_(FStyle)) Or ASortStyle(abs_(FSort)) Or AIntegralHeight(abs_(FIntegralHeight))
			#endif
		End If
	End Property
	
	Private Property ComboBoxEdit.DropDownCount As Integer
		Return FDropDownCount
	End Property
	
	Private Property ComboBoxEdit.DropDownCount(Value As Integer)
		FDropDownCount = Value
	End Property
	
	Private Property ComboBoxEdit.IntegralHeight As Boolean
		Return FIntegralHeight
	End Property
	
	Private Property ComboBoxEdit.IntegralHeight(Value As Boolean)
		FIntegralHeight = Value
	End Property
	
	Private Property ComboBoxEdit.ItemCount As Integer
		Return Items.Count
	End Property
	
	Private Property ComboBoxEdit.ItemCount(Value As Integer)
	End Property
	
	Private Property ComboBoxEdit.ItemHeight As Integer
		Return FItemHeight
	End Property
	
	Private Property ComboBoxEdit.ItemHeight(Value As Integer)
		FItemHeight = Value
	End Property
	
	Private Property ComboBoxEdit.ItemIndex As Integer
		#ifdef __USE_GTK__
			If widget Then FItemIndex = gtk_combo_box_get_active (GTK_COMBO_BOX(widget))
		#elseif 0
			If Handle Then FItemIndex = Perform(CB_GETCURSEL, 0, 0)
		#elseif 0
			If FHandle Then FItemIndex = GetSelectedIndex(FHandle)
		#endif
		Return FItemIndex
	End Property
	
	Private Property ComboBoxEdit.ItemIndex(Value As Integer)
		FItemIndex = Value
		#ifdef __USE_GTK__
			If widget Then gtk_combo_box_set_active (GTK_COMBO_BOX(widget), Value)
		#elseif 0
			If Handle Then Perform(CB_SETCURSEL, FItemIndex, 0)
			If OnChange Then OnChange(*Designer, This)
		#elseif 0
			If FHandle Then
				SetSelectedIndex(FHandle, Value)
				If OnChange Then OnChange(*Designer, This)
			End If
		#endif
	End Property
	
	Private Property ComboBoxEdit.Text ByRef As WString
		If FStyle >= cbDropDownList Then
			If This.ItemIndex > -1 Then
				FText = This.Item(This.ItemIndex)
			Else
				FText = ""
			End If
		Else
			#ifdef __USE_GTK__
				FText = WStr(*gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(widget)))
			#else
				'If This.ItemIndex > -1 Then
				'	FText = This.Item(This.ItemIndex)
				'Else
					Base.Text
				'End If
			#endif
		End If
		Return WGet(FText.vptr)
	End Property
	
	Private Property ComboBoxEdit.Text(ByRef Value As WString)
		Base.Text = Value
		#ifdef __USE_GTK__
			If widget Then
				If widget = DropDownWidget Then
					Dim As GtkEntry Ptr entry = GTK_ENTRY(gtk_bin_get_child(GTK_BIN(widget)))
					If Value = "" Then
						gtk_entry_set_text(entry, !"\0")
					Else
						gtk_entry_set_text(entry, ToUtf8(Value))
					End If
				Else
					gtk_combo_box_set_active (GTK_COMBO_BOX(widget), IndexOf(Value))
				End If
			End If
		#elseif 0
			If FStyle > 1 Then
				If FHandle Then Perform(CB_SELECTSTRING, -1, Cast(LPARAM, FText.vptr))
			Else
				'If FHandle Then SetWindowText(FHandle, FText)
				If FHandle Then Perform(WM_SETTEXT, 0, Cast(LPARAM, FText.vptr))
			End If
			If Items.Count > 0 Then
				Dim As Integer Index = IndexOf(Value)
				If Index >= 0 Then ItemIndex = Index
			End If
		#elseif 0
			If FHandle Then SetSelectedIndex(FHandle, IndexOf(Value))
		#endif
	End Property
	
	Private Property ComboBoxEdit.Sort As Boolean
		Return FSort
	End Property
	
	Private Property ComboBoxEdit.Sort(Value As Boolean)
		If Value <> FSort Then
			FSort = Value
			#ifdef __USE_GTK__
				
			#elseif 0
				ChangeStyle CBS_SORT, Value
				'Base.Style = WS_CHILD OR WS_VSCROLL OR CBS_HASSTRINGS OR CBS_AUTOHSCROLL OR AStyle(Abs_(FStyle)) OR ASortStyle(Abs_(FSort)) OR AIntegralHeight(Abs_(FIntegralHeight))
			#endif
		End If
	End Property
	
	Private Property ComboBoxEdit.ItemData(FIndex As Integer) As Any Ptr
		Return Items.Object(FIndex)
	End Property
	
	Private Property ComboBoxEdit.ItemData(FIndex As Integer, Value As Any Ptr)
		Items.Object(FIndex) = Value
	End Property
	
	Private Property ComboBoxEdit.Item(FIndex As Integer) ByRef As WString
		Dim As Integer L
			WLet(FItemText, Items.Item(FIndex))
		If FItemText = 0 Then Return "" Else Return *FItemText
	End Property
	
	Private Property ComboBoxEdit.Item(FIndex As Integer, ByRef FItem As WString)
		'Items.Item(FIndex) = FItem  'not refresh
		Dim As Integer CurrentIndex = ItemIndex
		RemoveItem(FIndex)
		InsertItem(FIndex, FItem)
		If CurrentIndex = FIndex Then ItemIndex = CurrentIndex
	End Property
	
	Private Sub ComboBoxEdit.UpdateListHeight
		If Style <> cbSimple Then
		End If
	End Sub
	
	Private Sub ComboBoxEdit.AddItem(ByRef FItem As WString)
		Dim i As Integer
		If FSort Then
			For i = 0 To Items.Count - 1
				If Items.Item(i) > FItem Then Exit For
			Next
			Items.Insert i, FItem
			FNewIndex = i
		Else
			Items.Add(FItem)
			FNewIndex = Items.Count - 1
		End If
		#ifdef __USE_GTK__
			If widget Then
				If FSort Then
					gtk_combo_box_text_insert_text(GTK_COMBO_BOX_TEXT(widget), i, ToUtf8(FItem))
				Else
					gtk_combo_box_text_append_text(GTK_COMBO_BOX_TEXT(widget), ToUtf8(FItem))
				End If
			End If
		#elseif 0
			If FHandle Then
				Perform(CB_ADDSTRING, 0, CInt(@FItem))
				UpdateListHeight
			End If
		#endif
	End Sub
	
	Private Sub ComboBoxEdit.RemoveItem(FIndex As Integer)
		Items.Remove(FIndex)
		#ifdef __USE_GTK__
			If widget Then
				gtk_combo_box_text_remove(GTK_COMBO_BOX_TEXT(widget), FIndex)
			End If
		#elseif 0
			If FHandle Then
				Perform(CB_DELETESTRING, FIndex, 0)
				UpdateListHeight
			End If
		#endif
	End Sub
	
	Private Sub ComboBoxEdit.InsertItem(FIndex As Integer, ByRef FItem As WString)
		If FSort Then
			AddItem FItem
			Exit Sub
		End If
		Items.Insert(FIndex, FItem)
		FNewIndex = FIndex
		#ifdef __USE_GTK__
			gtk_combo_box_text_insert_text(GTK_COMBO_BOX_TEXT(widget), FIndex, ToUtf8(FItem))
		#elseif 0
			If FHandle Then
				Perform(CB_INSERTSTRING, FIndex, CInt(@FItem))
				UpdateListHeight
			End If
		#endif
	End Sub
	
	Private Function ComboBoxEdit.IndexOf(ByRef FItem As WString) As Integer
		Return Items.IndexOf(FItem) ' Perform(CB_FINDSTRING, -1, CInt(@FItem))
	End Function
	
	Private Function ComboBoxEdit.Contains(ByRef FItem As WString) As Boolean
		Return IndexOf(FItem) <> -1
	End Function
	
	Private Function ComboBoxEdit.IndexOfData(pData As Any Ptr) As Integer
		Return Items.IndexOfObject(pData)
	End Function
	
	
	
	Private Sub ComboBoxEdit.GetChilds
	End Sub
	
	
	#ifdef __USE_WASM__
		Private Function ComboBoxEdit.GetContent() As UString
			Dim As UString FContent
			For i As Integer = 0 To Items.Count - 1
				FContent &= "<option value=""" & Str(i) & """>" & Items.Item(i) & "</option>"
			Next
			Return FContent
		End Function
	#endif
	
	Private Sub ComboBoxEdit.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Sub ComboBoxEdit.Clear
		ItemCount = 0
		Items.Clear
		#ifdef __USE_GTK__
			#ifdef __USE_GTK3__
				gtk_combo_box_text_remove_all(GTK_COMBO_BOX_TEXT(widget))
			#else
				Dim As GtkListStore Ptr store
				store = GTK_LIST_STORE (gtk_combo_box_get_model (GTK_COMBO_BOX (widget)))
				gtk_list_store_clear (store)
			#endif
		#elseif 0
			Perform(CB_RESETCONTENT, 0, 0)
		#endif
	End Sub
	
	Private Sub ComboBoxEdit.SaveToFile(ByRef File As WString)
		Dim As Integer F, i
		Dim As WString Ptr s
		F = FreeFile_
		Open File For Output Encoding "utf-8" As #F
		For i = 0 To ItemCount -1
		Next i
		CloseFile_(F)
	End Sub
	
	Private Sub ComboBoxEdit.LoadFromFile(ByRef FileName As WString)
		Dim As Integer F, i
		Dim As WString * 1024 s
		F = FreeFile_
		This.Clear
		Open FileName For Input Encoding "utf-8" As #F
		While Not EOF(F)
			Line Input #F, s
			This.AddItem s
		Wend
		CloseFile_(F)
	End Sub
	
	Private Operator ComboBoxEdit.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	#ifdef __USE_GTK__
		Private Sub ComboBoxEdit.ComboBoxEdit_Popup(widget As GtkComboBox Ptr, user_data As Any Ptr)
			Dim As ComboBoxEdit Ptr cbo = user_data
			cbo->FSelected = False
			If cbo->OnDropDown Then cbo->OnDropDown(*cbo->Designer, *cbo)
		End Sub
		
		Private Function ComboBoxEdit.ComboBoxEdit_Popdown(widget As GtkComboBox Ptr, user_data As Any Ptr) As Boolean
			Dim As ComboBoxEdit Ptr cbo = user_data
			If cbo->FSelected = False Then
				If cbo->OnSelectCanceled Then cbo->OnSelectCanceled(*cbo->Designer, *cbo)
			End If
			If cbo->OnCloseUp Then cbo->OnCloseUp(*cbo->Designer, *cbo)
			Return False
		End Function
		
		Private Sub ComboBoxEdit.ComboBoxEdit_Changed(widget As GtkComboBox Ptr, user_data As Any Ptr)
			Dim As ComboBoxEdit Ptr cbo = user_data
			cbo->FSelected = True
			If cbo->OnSelected Then cbo->OnSelected(*cbo->Designer, *cbo, cbo->ItemIndex)
			If cbo->OnChange Then cbo->OnChange(*cbo->Designer, *cbo)
		End Sub
		
		Private Sub ComboBoxEdit.Entry_Activate(entry As GtkEntry Ptr, user_data As Any Ptr)
			Dim As ComboBoxEdit Ptr cbo = user_data
			Dim As Control Ptr btn = cbo->GetForm()->FDefaultButton
			If cbo->OnActivate Then cbo->OnActivate(*cbo->Designer, *cbo)
			If btn AndAlso btn->OnClick Then btn->OnClick(*btn->Designer, *btn)
		End Sub
		
		Private Sub ComboBoxEdit.Entry_Changed(entry As GtkEntry Ptr, user_data As Any Ptr)
			Dim As ComboBoxEdit Ptr cbo = user_data
			If cbo->OnChange Then cbo->OnChange(*cbo->Designer, *cbo)
		End Sub
	#endif
	
	Private Constructor ComboBoxEdit
		#ifdef __USE_GTK__
			DropDownWidget = gtk_combo_box_text_new_with_entry()
			DropDownListWidget = gtk_combo_box_text_new()
			widget = DropDownListWidget
			eventboxwidget = gtk_event_box_new()
			gtk_container_add(GTK_CONTAINER(eventboxwidget), widget)
			g_signal_connect(gtk_bin_get_child(GTK_BIN(DropDownWidget)), "activate", G_CALLBACK(@Entry_Activate), @This)
			g_signal_connect(gtk_bin_get_child(GTK_BIN(DropDownWidget)), "changed", G_CALLBACK(@Entry_Changed), @This)
			g_signal_connect(GTK_COMBO_BOX(widget), "changed", G_CALLBACK(@ComboBoxEdit_Changed), @This)
			g_signal_connect(GTK_COMBO_BOX(widget), "popup", G_CALLBACK(@ComboBoxEdit_Popup), @This)
			g_signal_connect(GTK_COMBO_BOX(widget), "popdown", G_CALLBACK(@ComboBoxEdit_Popdown), @This)
			Base.RegisterClass "ComboBoxEdit", @This
		#elseif 0
			ASortStyle(abs_(True))   = CBS_SORT
			AStyle(0)          = CBS_SIMPLE
			AStyle(1)          = CBS_DROPDOWN
			AStyle(2)          = CBS_DROPDOWNLIST
			AStyle(3)          = CBS_DROPDOWNLIST Or CBS_OWNERDRAWFIXED
			AStyle(4)          = CBS_DROPDOWNLIST Or CBS_OWNERDRAWVARIABLE
			AIntegralHeight(0) = CBS_NOINTEGRALHEIGHT
			AIntegralHeight(1) = 0
		#endif
		FStyle              = cbDropDownList
		'ItemHeight          = 13
		FDropDownCount      = 8
		FSelColor           = &H800000
		FIntegralHeight     = 0
		FItemIndex          = -1
		FTabIndex           = -1
		FTabStop            = True
		'Items.Parent        = @This
		With This
			.Child          = @This
			'.ChildProc     = @WindowProc
			'ComboBoxEdit.RegisterClass
			WLet(FClassName, "ComboBoxEdit")
			WLet(FClassAncestor, "ComboBox")
			.Width          = 121
			#ifdef __USE_GTK__
				.Height        = 20
			#else
				.Height        = 17
			#endif
		End With
	End Constructor
	
	Private Destructor ComboBoxEdit
		WDeAllocate(FItemText)
		#ifdef __USE_GTK__
				If GTK_IS_WIDGET(DropDownWidget) Then
						gtk_widget_destroy(DropDownWidget)
					DropDownWidget = 0
				End If
				If GTK_IS_WIDGET(DropDownListWidget) Then
						gtk_widget_destroy(DropDownListWidget)
					DropDownListWidget = 0
				End If
			widget = 0
			'			If This.Parent AndAlso This.Parent->Widget Then
			'				gtk_container_remove(gtk_container(This.Parent->Widget), gtk_widget(Widget))
			'			End If
		#elseif 0
			UnregisterClass "ComboBoxEdit", GetModuleHandle(NULL)
		#endif
	End Destructor
End Namespace
