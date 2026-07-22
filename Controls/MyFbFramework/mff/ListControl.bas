'###############################################################################
'#  ListControl.bi                                                             #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TListBox.bi                                                               #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.2.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "ListControl.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function ListControl.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "borderstyle": Return @FBorderStyle
			Case "multicolumn": Return @FMultiColumn
			Case "ctl3d": Return @FCtl3D
			Case "integralheight": Return @FIntegralHeight
			Case "itemheight": Return @FItemHeight
			Case "itemindex": Return @FItemIndex
			Case "horizontalscrollbar": Return @FHorizontalScrollBar
			Case "verticalscrollbar": Return @FVerticalScrollBar
			Case "newindex": Return @FNewIndex
			Case "selectionmode": Return @FSelectionMode
			Case "selcount": Return @FSelCount
			Case "sort": Return @FSort
			Case "style": Return @FStyle
			Case "tabindex": Return @FTabIndex
			Case "topindex": Return @FTopIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function ListControl.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "borderstyle": BorderStyle = *Cast(BorderStyles Ptr, Value)
			Case "multicolumn": MultiColumn = QBoolean(Value)
			Case "ctl3d": Ctl3D = QBoolean(Value)
			Case "integralheight": IntegralHeight = QBoolean(Value)
			Case "itemheight": ItemHeight = QInteger(Value)
			Case "horizontalscrollbar": HorizontalScrollBar = QBoolean(Value)
			Case "verticalscrollbar": VerticalScrollBar = QBoolean(Value)
			Case "selectionmode": SelectionMode = *Cast(SelectionModes Ptr, Value)
			Case "sort": Sort = QBoolean(Value)
			Case "style": Style = *Cast(ListControlStyle Ptr, Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case "topindex": TopIndex = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Function ListControl.NewIndex As Integer
		Return FNewIndex
	End Function
	
	Private Property ListControl.HorizontalScrollBar As Boolean
		Return FHorizontalScrollBar
	End Property
	
	Private Property ListControl.HorizontalScrollBar(Value As Boolean)
		FHorizontalScrollBar = Value
	End Property
	
	Private Property ListControl.VerticalScrollBar As Boolean
		Return FVerticalScrollBar
	End Property
	
	Private Property ListControl.VerticalScrollBar(Value As Boolean)
		FVerticalScrollBar = Value
	End Property
	
	Private Property ListControl.Selected(Index As Integer) As Boolean
			Dim As GtkTreeIter iter
			gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(ListStore), @iter, Trim(Str(Index)))
			TreeSelection = gtk_tree_view_get_selection(GTK_TREE_VIEW(widget))
			Return gtk_tree_selection_iter_is_selected(TreeSelection, @iter)
	End Property
	
	Private Property ListControl.Selected(Index As Integer, Value As Boolean)
			Dim As GtkTreeIter iter
			gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(ListStore), @iter, Trim(Str(Index)))
			If Value Then
				gtk_tree_selection_select_iter(TreeSelection, @iter)
			Else
				gtk_tree_selection_unselect_iter(TreeSelection, @iter)
			End If
	End Property
	
	Private Sub ListControl.SelectAll
			If widget Then
				gtk_tree_selection_select_all(TreeSelection)
			End If
	End Sub
	
	Private Sub ListControl.UnSelectAll
			gtk_tree_selection_unselect_all(TreeSelection)
	End Sub
	
	Private Property ListControl.SelectionMode As SelectionModes
		Return FSelectionMode
	End Property
	
	Private Property ListControl.SelectionMode(Value As SelectionModes)
		FSelectionMode = Value
			Select Case FSelectionMode
			Case 0: gtk_tree_selection_set_mode(gtk_tree_view_get_selection(GTK_TREE_VIEW(widget)), GTK_SELECTION_NONE)
			Case 1: gtk_tree_selection_set_mode(gtk_tree_view_get_selection(GTK_TREE_VIEW(widget)), GTK_SELECTION_SINGLE)
			Case 2: gtk_tree_selection_set_mode(gtk_tree_view_get_selection(GTK_TREE_VIEW(widget)), GTK_SELECTION_MULTIPLE)
				Case 3: gtk_tree_selection_set_mode(gtk_tree_view_get_selection(GTK_TREE_VIEW(widget)), GTK_SELECTION_MULTIPLE)
			End Select
	End Property
	
	Private Property ListControl.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property ListControl.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property ListControl.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property ListControl.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property ListControl.MultiColumn As Boolean
		Return FMultiColumn
	End Property
	
	Private Property ListControl.MultiColumn(Value As Boolean)
		If Value <> FMultiColumn Then
			FMultiColumn = Value
		End If
	End Property
	
	Private Property ListControl.IntegralHeight As Boolean
		Return FIntegralHeight
	End Property
	
	Private Property ListControl.IntegralHeight(Value As Boolean)
		If Value <> FIntegralHeight Then
			FIntegralHeight = Value
		End If
	End Property
	
	Private Property ListControl.Style As ListControlStyle
		Return FStyle
	End Property
	
	Private Property ListControl.Style(Value As ListControlStyle)
		If Value <> FStyle Then
			FStyle = Value
		End If
	End Property
	
	Private Property ListControl.Ctl3D As Boolean
		Return FCtl3D
	End Property
	
	Private Property ListControl.Ctl3D(Value As Boolean)
		If Value <> FCtl3D Then
			FCtl3D = Value
		End If
	End Property
	
	Private Property ListControl.ItemCount As Integer
		Return Items.Count
	End Property
	
	Private Property ListControl.ItemCount(Value As Integer)
	End Property
	
	Private Property ListControl.ItemHeight As Integer
		Return FItemHeight
	End Property
	
	Private Property ListControl.ItemHeight(Value As Integer)
		FItemHeight = Value
	End Property
	
	Private Property ListControl.TopIndex As Integer
		Return FTopIndex
	End Property
	
	Private Property ListControl.TopIndex(Value As Integer)
		FTopIndex = Value
	End Property
	
	Private Property ListControl.ItemIndex As Integer
			Dim As GtkTreeIter iter
			If SelectionMode = SelectionModes.smMultiSimple Or SelectionMode = SelectionModes.smMultiExtended Then
				FSelCount = gtk_tree_selection_count_selected_rows(TreeSelection)
				If FSelCount > 0 Then
					Dim As GtkTreeModel Ptr model = GTK_TREE_MODEL(ListStore)
					Dim As GList Ptr list = gtk_tree_selection_get_selected_rows(TreeSelection, @model)
					Dim As GtkTreePath Ptr path
					If list Then
						path = list->data
						FItemIndex = gtk_tree_path_get_indices(path)[0]
					End If
					g_list_foreach(list, Cast(GFunc, @gtk_tree_path_free), NULL)
					g_list_free(list)
				Else
					FItemIndex = -1
				End If
			Else
				If gtk_tree_selection_get_selected(TreeSelection, NULL, @iter) Then
					Dim As Integer i
					Dim As GtkTreePath Ptr path
					path = gtk_tree_model_get_path(GTK_TREE_MODEL(ListStore), @iter)
					FItemIndex = gtk_tree_path_get_indices(path)[0]
					gtk_tree_path_free(path)
				End If
			End If
		Return FItemIndex
	End Property
	
	Private Property ListControl.ItemIndex(Value As Integer)
		FItemIndex = Value
			If ListStore Then
				If Value = -1 Then
					gtk_tree_selection_unselect_all(gtk_tree_view_get_selection(GTK_TREE_VIEW(widget)))
				ElseIf Value > -1 AndAlso Value < Items.Count Then
					Dim As GtkTreeIter iter
					gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(ListStore), @iter, Trim(Str(Value)))
					gtk_tree_selection_select_iter(gtk_tree_view_get_selection(GTK_TREE_VIEW(widget)), @iter)
					gtk_tree_view_scroll_to_cell(GTK_TREE_VIEW(widget), gtk_tree_model_get_path(GTK_TREE_MODEL(ListStore), @iter), NULL, False, 0, 0)
				End If
			End If
	End Property
	
	Private Property ListControl.SelCount As Integer
			FSelCount = gtk_tree_selection_count_selected_rows(TreeSelection)
		Return FSelCount
	End Property
	
	Private Property ListControl.SelCount(Value As Integer)
		FSelCount = Value
	End Property
	
	Private Property ListControl.SelItems As Integer Ptr
			FSelCount = gtk_tree_selection_count_selected_rows(TreeSelection)
			ReDim AItems(FSelCount)
			Dim As GtkTreeModel Ptr model = GTK_TREE_MODEL(ListStore)
			Dim As GList Ptr list = gtk_tree_selection_get_selected_rows(TreeSelection, @model)
			Dim As GtkTreePath Ptr path
			Dim i As Integer
			While (list)
				path = list->data
				AItems(i) = gtk_tree_path_get_indices(path)[0]
				list = list->next
				i += 1
			Wend
			g_list_foreach(list, Cast(GFunc, @gtk_tree_path_free), NULL)
			g_list_free(list)
			Return @AItems(0)
		Return FSelItems
	End Property
	
	Private Property ListControl.SelItems(Value As Integer Ptr)
		FSelItems = Value
	End Property
	
	Private Property ListControl.Text ByRef As WString
		If Handle Then
			FText = Items.Item(ItemIndex)
		End If
		Return *FText.vptr
	End Property
	
	Private Property ListControl.Text(ByRef Value As WString)
		FText = Value
			ItemIndex = Items.IndexOf(Value)
	End Property
	
	Private Property ListControl.Sort As Boolean
		Return FSort
	End Property
	
	Private Property ListControl.Sort(Value As Boolean)
		If Value <> FSort Then
			FSort = Value
		End If
	End Property
	
	Private Property ListControl.ItemData(FIndex As Integer) As Any Ptr
		Return Items.Object(FIndex)
	End Property
	
	Private Property ListControl.ItemData(FIndex As Integer, Obj As Any Ptr)
		Items.Object(FIndex) = Obj
	End Property
	
	Private Property ListControl.Item(FIndex As Integer) ByRef As WString
			FText = Items.Item(FIndex)
			Return *FText.vptr
	End Property
	
	Private Property ListControl.Item(FIndex As Integer, ByRef FItem As WString)
		Items.Item(FIndex) = FItem
	End Property
	
	Private Sub ListControl.AddItem(ByRef FItem As WString, Obj As Any Ptr = 0)
		Dim i As Integer
		If FSort Then
			For i = 0 To Items.Count - 1
				If Items.Item(i) > FItem Then Exit For
			Next
			Items.Insert i, FItem, Obj
			FNewIndex = i
		Else
			Items.Add(FItem, Obj)
			FNewIndex = Items.Count - 1
		End If
			Dim As GtkTreeIter iter
			gtk_list_store_append (ListStore, @iter)
			gtk_list_store_set(ListStore, @iter, 0, ToUtf8(FItem), -1)
	End Sub
	
	Private Sub ListControl.RemoveItem(FIndex As Integer)
		Items.Remove(FIndex)
			Dim As GtkTreeIter iter
			gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(ListStore), @iter, Trim(Str(FIndex)))
			gtk_list_store_remove(ListStore, @iter)
	End Sub
	
	Private Sub ListControl.InsertItem(FIndex As Integer, ByRef FItem As WString, Obj As Any Ptr = 0)
		If FSort Then
			AddItem FItem, Obj
			Exit Sub
		End If
		Items.Insert(FIndex, FItem, Obj)
		FNewIndex = FIndex
			Dim As GtkTreeIter iter
			gtk_list_store_insert(ListStore, @iter, FIndex)
			gtk_list_store_set (ListStore, @iter, 0, ToUtf8(FItem), -1)
	End Sub
	
	Private Sub ListControl.Clear
		Items.Clear
			gtk_list_store_clear(ListStore)
	End Sub
	Private Function ListControl.IndexOf(ByRef FItem As WString) As Integer
			Return Items.IndexOf(FItem)
	End Function
	
	Private Function ListControl.IndexOfData(Obj As Any Ptr) As Integer
		Return Items.IndexOfObject(Obj)
	End Function
	
		Private Sub ListControl.SelectionChanged(selection As GtkTreeSelection Ptr, user_data As Any Ptr)
			Dim As ListControl Ptr lst = Cast(Any Ptr, user_data)
			If lst Then
				If lst->OnChange Then lst->OnChange(*lst->Designer, *lst)
			End If
		End Sub
	
	
	Private Sub ListControl.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Sub ListControl.SaveToFile(ByRef File As WString)
		Dim As Integer F, i
		Dim As WString Ptr s
		F = FreeFile_
		Open File For Output Encoding "utf-8" As #F
		For i = 0 To ItemCount - 1
				Print #F, Items.Item(i)
		Next i
		CloseFile_(F)
	End Sub
	
	Private Sub ListControl.LoadFromFile(ByRef FileName As WString)
		Dim As Integer F, i
		Dim As WString * 1024 s
		F = FreeFile_
		Clear
		Open FileName For Input Encoding "utf-8" As #F
		While Not EOF(F)
			Line Input #F, s
				AddItem s
		Wend
		CloseFile_(F)
	End Sub
	
	Private Operator ListControl.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor ListControl
		With This
				Dim As GtkTreeViewColumn Ptr col = gtk_tree_view_column_new()
				Dim As GtkCellRenderer Ptr rendertext = gtk_cell_renderer_text_new()
				scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
				gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
				gtk_scrolled_window_set_shadow_type(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_SHADOW_OUT)
				ListStore = gtk_list_store_new(1, G_TYPE_STRING)
				widget = gtk_tree_view_new_with_model(GTK_TREE_MODEL(ListStore))
				gtk_container_add(GTK_CONTAINER(scrolledwidget), widget)
				TreeSelection = gtk_tree_view_get_selection(GTK_TREE_VIEW(widget))
				g_signal_connect(G_OBJECT(TreeSelection), "changed", G_CALLBACK (@SelectionChanged), @This)
				
				gtk_tree_view_column_pack_start(col, rendertext, True)
				gtk_tree_view_column_add_attribute(col, rendertext, ToUtf8("text"), 0)
				gtk_tree_view_append_column(GTK_TREE_VIEW(widget), col)
				
				gtk_tree_view_set_headers_visible(GTK_TREE_VIEW(widget), False)
				
				.RegisterClass "ListControl", @This
			FCtl3D             = False
			FTabIndex          = -1
			FTabStop           = True
			FBorderStyle       = 1
			FHorizontalScrollBar = True
			FVerticalScrollBar  = True
			'Items.Parent       = @This
			
			WLet(FClassName, "ListControl")
			.Child       = @This
			.Width       = 121
			.Height      = ScaleY(Font.Size / 72 * 96 + 6)
		End With
	End Constructor
	
	Private Destructor ListControl
		If Items Then Items.Clear
	End Destructor
End Namespace
