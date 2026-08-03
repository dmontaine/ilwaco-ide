'###############################################################################
'#  ListView.bi                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov(2018-2019)  Liu XiaLin                         #
'###############################################################################

#include once "ListView.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function ListView.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "allowcolumnreorder": Return @FAllowColumnReorder
			Case "borderselect": Return @FBorderSelect
			Case "checkboxes": Return @FCheckBoxes
			Case "columnheaderhidden": Return @FColumnHeaderHidden
			Case "fullrowselect": Return @FFullRowSelect
			Case "hovertime": Return @FHoverTime
			Case "gridlines": Return @FGridLines
			Case "images": Return Images
			Case "stateimages": Return StateImages
			Case "smallimages": Return SmallImages
			Case "groupheaderimages": Return GroupHeaderImages
			Case "labeltip": Return @FLabelTip
			Case "singleclickactivate": Return @FSingleClickActivate
			Case "sort": Return @FSortStyle
			Case "tabindex": Return @FTabIndex
			Case "hoverselection": Return @FHoverSelection
			Case "view": Return @FView
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function ListView.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "allowcolumnreorder": AllowColumnReorder = QBoolean(Value)
				Case "borderselect": BorderSelect = QBoolean(Value)
				Case "checkboxes": CheckBoxes = QBoolean(Value)
				Case "columnheaderhidden": ColumnHeaderHidden = QBoolean(Value)
				Case "fullrowselect": FullRowSelect = QBoolean(Value)
				Case "hovertime": HoverTime = QInteger(Value)
				Case "gridlines": GridLines = QBoolean(Value)
				Case "images": Images = Cast(ImageList Ptr, Value)
				Case "stateimages": StateImages = Cast(ImageList Ptr, Value)
				Case "smallimages": SmallImages = Cast(ImageList Ptr, Value)
				Case "groupheaderimages": GroupHeaderImages = Cast(ImageList Ptr, Value)
				Case "labeltip": LabelTip = QBoolean(Value)
				Case "singleclickactivate": SingleClickActivate = QBoolean(Value)
				Case "sort": Sort = *Cast(SortStyle Ptr, Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case "hoverselection": HoverSelection = QBoolean(Value)
				Case "view": This.View = *Cast(ViewStyle Ptr, Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property ListView.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property ListView.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property ListView.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property ListView.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Function ListViewItem.Index As Integer
		If Parent Then
			Return Cast(ListView Ptr, Parent)->ListItems.IndexOf(@This)
		Else
			Return -1
		End If
	End Function
	
	Private Property ListViewItem.Selected As Boolean
			'Dim As GtkTreeIter iter
			'Dim As Boolean bChecked
			'gtk_tree_model_get_iter_from_string(ListViewGetModel(Parent->Handle), @iter, Trim(Str(This.Index)))
			'gtk_tree_model_get(ListViewGetModel(Parent->Handle), @iter, 0, @bChecked, -1)
			'Return bChecked
		Return FSelected
	End Property
	
	Private Property ListViewItem.Selected(Value As Boolean)
		FSelected = Value
	End Property
	
	Private Sub ListViewItem.SelectItem
			If Parent Then
				If GTK_IS_ICON_VIEW(Parent->Handle) Then
					gtk_icon_view_select_path(GTK_ICON_VIEW(Parent->Handle), gtk_tree_path_new_from_string(Trim(Str(This.Index))))
				Else
					If gtk_tree_view_get_selection(GTK_TREE_VIEW(Parent->Handle)) Then
						gtk_tree_selection_select_iter(gtk_tree_view_get_selection(GTK_TREE_VIEW(Parent->Handle)), @TreeIter)
					End If
				End If
			End If
	End Sub
	
	Private Property ListViewItem.Text(iSubItem As Integer) ByRef As WString
			If FSubItems.Count > iSubItem Then
				Return FSubItems.Item(iSubItem)
			Else
				Return WStr("")
			End If
	End Property
	
		Private Function ListViewGetModel(widget As GtkWidget Ptr) As GtkTreeModel Ptr
			If GTK_IS_WIDGET(widget) Then
				If GTK_IS_TREE_VIEW(widget) Then
					Return gtk_tree_view_get_model(GTK_TREE_VIEW(widget))
				Else
					Return gtk_icon_view_get_model(GTK_ICON_VIEW(widget))
				End If
			End If
		End Function
	
	Private Property ListViewItem.Text(iSubItem As Integer, ByRef Value As WString)
		WLet(FText, Value)
		If Parent Then
			Dim ic As Integer = FSubItems.Count
			Dim cc As Integer = Cast(ListView Ptr, Parent)->Columns.Count
			If ic < cc Then
				For i As Integer = ic + 1 To cc
					FSubItems.Add ""
				Next i
			End If
			If iSubItem < cc Then FSubItems.Item(iSubItem) = Value
				If ListViewGetModel(Parent->Handle) Then
					gtk_list_store_set(GTK_LIST_STORE(ListViewGetModel(Parent->Handle)), @TreeIter, iSubItem + 3, ToUtf8(Value), -1)
				End If
		End If
	End Property
	
	Private Property ListViewItem.State As Integer
		Return FState
	End Property
	
	Private Property ListViewItem.State(Value As Integer)
		FState = Value
	End Property
	
	Private Property ListViewItem.Indent As Integer
		Return FIndent
	End Property
	
	Private Property ListViewItem.Indent(Value As Integer)
		FIndent = Value
	End Property
	
	Const LVIS_UNCHECKED = 4096
	Const LVIS_CHECKED = 8192
	Const LVIS_CHECKEDMASK = 12288
	
	Private Property ListViewItem.Checked As Boolean
			Dim As GtkTreeIter iter
			Dim As Boolean bChecked
			gtk_tree_model_get_iter_from_string(ListViewGetModel(Parent->Handle), @iter, Trim(Str(This.Index)))
			gtk_tree_model_get(ListViewGetModel(Parent->Handle), @iter, 0, @bChecked, -1)
			Return bChecked
		Return FChecked
	End Property
	
	Private Property ListViewItem.Checked(Value As Boolean)
		FChecked = Value
			Dim As GtkTreeIter iter
			gtk_tree_model_get_iter_from_string(ListViewGetModel(Parent->Handle), @iter, Trim(Str(This.Index)))
			gtk_list_store_set(GTK_LIST_STORE(ListViewGetModel(Parent->Handle)), @iter, 0, Value, -1)
	End Property
	
	Private Property ListViewItem.Hint ByRef As WString
		Return WGet(FHint)
	End Property
	
	Private Property ListViewItem.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	Private Property ListViewItem.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property ListViewItem.ImageIndex(Value As Integer)
		If Value <> FImageIndex Then
			FImageIndex = Value
		End If
	End Property
	
	Private Property ListViewItem.SelectedImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property ListViewItem.SelectedImageIndex(Value As Integer)
		If Value <> FSelectedImageIndex Then
			FSelectedImageIndex = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property ListViewItem.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property ListViewItem.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_HIDEBUTTON, FCommandID, MakeLong(NOT FVisible, 0))
				End With
			End If
		End If
	End Property
	
	Private Property ListViewItem.ImageKey ByRef As WString
		Return WGet(FImageKey)
	End Property
	
	Private Property ListViewItem.ImageKey(ByRef Value As WString)
		If FImageKey = 0 OrElse Value <> *FImageKey Then
			WLet(FImageKey, Value)
				If Parent AndAlso Parent->Handle Then
					Dim As GError Ptr gerr
					Dim As Integer iSize = IIf(Cast(ListView Ptr, Parent)->Images, Max(Cast(ListView Ptr, Parent)->Images->ImageWidth, Cast(ListView Ptr, Parent)->Images->ImageHeight), 16)
					If Value <> "" Then
						Dim As GtkIconTheme Ptr theme = gtk_icon_theme_get_default()
						If theme Then
							Dim As GtkIconInfo Ptr info = gtk_icon_theme_lookup_icon(theme, ToUtf8(Value), iSize, GTK_ICON_LOOKUP_USE_BUILTIN)
							If info Then
						 		Dim As GdkPixbuf Ptr pixbuf = gtk_icon_info_load_icon(info, @gerr)
						 		If pixbuf Then
						 			gtk_list_store_set(GTK_LIST_STORE(ListViewGetModel(Parent->Handle)), @TreeIter, 1, pixbuf, -1)
						 			gtk_list_store_set(GTK_LIST_STORE(ListViewGetModel(Parent->Handle)), @TreeIter, 2, ToUtf8(Value), -1)
						 			g_object_unref(pixbuf)
						 		Else
						 			Print "Icon '" & Value & "' not found"
						 		End If
							Else
								Print "Icon '" & Value & "' not found"
							End If
						Else
							Print "Default icon theme not found"
						End If
					End If
				End If
		End If
	End Property
	
	Private Property ListViewItem.SelectedImageKey ByRef As WString
		Return WGet(FImageKey)
	End Property
	
	Private Property ListViewItem.SelectedImageKey(ByRef Value As WString)
		If FSelectedImageKey = 0 OrElse Value <> *FSelectedImageKey Then
			WLet(FSelectedImageKey, Value)
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Operator ListViewItem.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ListViewItem
		FHint = 0 'CAllocate_(0)
		FText = 0 'CAllocate_(0)
		FVisible    = 1
		Text(0)    = ""
		Hint       = ""
		FImageIndex = -1
		FSelectedImageIndex = -1
		FSmallImageIndex = -1
	End Constructor
	
	Private Destructor ListViewItem
		If FHint Then _Deallocate( FHint)
		If FText Then _Deallocate( FText)
		If FImageKey Then _Deallocate( FImageKey)
		If FSelectedImageKey Then _Deallocate( FSelectedImageKey)
		If FSmallImageKey Then _Deallocate( FSmallImageKey)
	End Destructor
	
	Private Sub ListViewColumn.SelectItem
	End Sub
	
	Private Property ListViewColumn.Text ByRef As WString
		Return WGet(FText)
	End Property
	
	Private Property ListViewColumn.Text(ByRef Value As WString)
		WLet(FText, Value)
	End Property
	
	Private Property ListViewColumn.Width As Integer
		Return FWidth
	End Property
	
	Private Property ListViewColumn.Width(Value As Integer)
		FWidth = Value
		Update
	End Property
	
	Private Sub ListViewColumn.Update
				If This.Column Then gtk_tree_view_column_set_fixed_width(This.Column, Max(-1, FWidth))
	End Sub
	
	Private Property ListViewColumn.Format As ColumnFormat
		Return FFormat
	End Property
	
	Private Property ListViewColumn.Format(Value As ColumnFormat)
		FFormat = Value
	End Property
	
	Private Property ListViewColumn.Hint ByRef As WString
		Return WGet(FHint)
	End Property
	
	Private Property ListViewColumn.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	Private Property ListViewColumn.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property ListViewColumn.ImageIndex(Value As Integer)
		If Value <> FImageIndex Then
			FImageIndex = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property ListViewColumn.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property ListViewColumn.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_HIDEBUTTON, FCommandID, MakeLong(NOT FVisible, 0))
				End With
			End If
		End If
	End Property
	
	Private Property ListViewColumn.Editable As Boolean
		Return FEditable
	End Property
	
	Private Property ListViewColumn.Editable(Value As Boolean)
		If Value <> FEditable Then
			FEditable = Value
		End If
	End Property
	
	Private Operator ListViewColumn.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ListViewColumn
		FHint = 0 'CAllocate_(0)
		FText = 0 'CAllocate_(0)
		FVisible    = 1
		Text    = ""
		Hint       = ""
		FImageIndex = -1
	End Constructor
	
	Private Destructor ListViewColumn
		If FHint Then _Deallocate( FHint)
		If FText Then _Deallocate( FText)
	End Destructor
	
	Private Property ListViewItems.Count As Integer
		Return FItems.Count
	End Property
	
	Private Property ListViewItems.Count(Value As Integer)
	End Property
	
	Private Property ListViewItems.Item(Index As Integer) As ListViewItem Ptr
		If Index >= 0 AndAlso Index < FItems.Count Then
			Return FItems.Items[Index]
		End If
		Return 0
	End Property
	
	Private Property ListViewItems.Item(Index As Integer, Value As ListViewItem Ptr)
		If Index >= 0 AndAlso Index < FItems.Count Then
			FItems.Items[Index] = Value
		End If
	End Property
	
		Private Function ListViewItems.FindByIterUser_Data(User_Data As Any Ptr) As ListViewItem Ptr
			For i As Integer = 0 To Count - 1
				If Item(i)->TreeIter.user_data = User_Data Then Return Item(i)
			Next i
			Return 0
		End Function
	
	Private Function ListViewItems.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0, Index As Integer = -1) As ListViewItem Ptr
		PItem = _New( ListViewItem)
		Dim i As Integer = Index
		Dim As SortStyle iSortStyle = Cast(ListView Ptr, Parent)->Sort
		If iSortStyle <> SortStyle.ssNone Then
			For i = 0 To FItems.Count - 1
				If iSortStyle = SortStyle.ssSortAscending Then
					If Cast(ListViewItem Ptr, FItems.Item(i))->Text(0) > FCaption Then Exit For
				Else
					If Cast(ListViewItem Ptr, FItems.Item(i))->Text(0) < FCaption Then Exit For
				End If
			Next
			FItems.Insert i, PItem
		ElseIf Index = -1 Then
			FItems.Add PItem
		Else
			FItems.Insert i, PItem
		End If
		With *PItem
			.ImageIndex     = FImageIndex
			.Text(0)        = FCaption
			.State        = State
			.Indent        = Indent
		End With
			Cast(ListView Ptr, Parent)->Init
			If iSortStyle <> SortStyle.ssNone OrElse Index <> -1 Then
				gtk_list_store_insert(GTK_LIST_STORE(ListViewGetModel(Parent->Handle)), @PItem->TreeIter, i)
			Else
				gtk_list_store_append(GTK_LIST_STORE(ListViewGetModel(Parent->Handle)), @PItem->TreeIter)
			End If
			gtk_list_store_set (GTK_LIST_STORE(ListViewGetModel(Parent->Handle)), @PItem->TreeIter, 3, ToUtf8(FCaption), -1)
		If Parent Then
			PItem->Parent = Parent
			PItem->Text(0) = FCaption
		End If
		Return PItem
	End Function
	
	Private Function ListViewItems.Add(ByRef FCaption As WString = "", ByRef FImageKey As WString, State As Integer = 0, Indent As Integer = 0, Index As Integer = -1) As ListViewItem Ptr
		If Parent AndAlso Cast(ListView Ptr, Parent)->Images Then
			PItem = Add(FCaption, Cast(ListView Ptr, Parent)->Images->IndexOf(FImageKey), State, Indent, Index)
		Else
			PItem = Add(FCaption, -1, State, Indent, Index)
		End If
		If PItem Then PItem->ImageKey = FImageKey
		Return PItem
	End Function
	
	Private Function ListViewItems.Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0) As ListViewItem Ptr
		Dim As ListViewItem Ptr PItem
		PItem = _New( ListViewItem)
		FItems.Insert Index, PItem
		With *PItem
			.ImageIndex     = FImageIndex
			.Text(0)        = FCaption
			.State          = State
			.Indent         = Indent
		End With
		Return PItem
	End Function
	
	Private Sub ListViewItems.Remove(Index As Integer)
		If Count < 1 OrElse Index < 0 OrElse Index > Count - 1 Then Exit Sub
			If Parent AndAlso Parent->Handle Then
				gtk_list_store_remove(GTK_LIST_STORE(ListViewGetModel(Parent->Handle)), @This.Item(Index)->TreeIter)
			End If
		_Delete(Cast(ListViewItem Ptr, FItems.Items[Index]))
		FItems.Remove Index
	End Sub
	
	
	Private Sub ListViewItems.Sort
	End Sub
	
	Private Function ListViewItems.IndexOf(ByRef FItem As ListViewItem Ptr) As Integer
		Return FItems.IndexOf(FItem)
	End Function
	
	Private Function ListViewItems.IndexOf(ByRef Caption As WString) As Integer
		For i As Integer = 0 To Count - 1
			If LCase(QListViewItem(FItems.Items[i]).Text(0)) = LCase(Caption) Then
				Return i
			End If
		Next i
		Return -1
	End Function
	
	Private Function ListViewItems.Contains(ByRef Caption As WString) As Boolean
		Return IndexOf(Caption) <> -1
	End Function
	
	Private Sub ListViewItems.Clear
			If Parent AndAlso GTK_LIST_STORE(ListViewGetModel(Parent->Handle)) Then gtk_list_store_clear(GTK_LIST_STORE(ListViewGetModel(Parent->Handle)))
		For i As Integer = Count -1 To 0 Step -1
			_Delete( Cast(ListViewItem Ptr, FItems.Items[i]))
		Next i
		FItems.Clear
	End Sub
	
	Private Operator ListViewItems.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ListViewItems
		This.Clear
	End Constructor
	
	Private Destructor ListViewItems
			This.Clear
	End Destructor
	
	Private Property ListViewColumns.Count As Integer
		Return FColumns.Count
	End Property
	
	Private Property ListViewColumns.Count(Value As Integer)
	End Property
	
	Private Property ListViewColumns.Column(Index As Integer) As ListViewColumn Ptr
		Return QListViewColumn(FColumns.Items[Index])
	End Property
	
	Private Property ListViewColumns.Column(Index As Integer, Value As ListViewColumn Ptr)
		'QListViewColumn(FColumns.Items[Index]) = Value
	End Property
	
		Private Sub ListViewColumns.Cell_Edited(renderer As GtkCellRendererText Ptr, path As gchar Ptr, new_text As gchar Ptr, user_data As Any Ptr)
			Dim As ListViewColumn Ptr PColumn = user_data
			If PColumn = 0 Then Exit Sub
			Dim As ListView Ptr lv = Cast(ListView Ptr, PColumn->Parent)
			If lv = 0 Then Exit Sub
			If lv->OnCellEdited Then lv->OnCellEdited(*lv->Designer, *lv, Val(*path), PColumn->Index, *new_text)
		End Sub
	
		Private Sub ListViewColumns.Check(cell As GtkCellRendererToggle Ptr, path As gchar Ptr, user_data As Any Ptr)
			Dim As ListView Ptr lv = user_data
			Dim As GtkListStore Ptr model = GTK_LIST_STORE(ListViewGetModel(lv->Handle))
			Dim As GtkTreeIter iter
			Dim As gboolean active
			
			active = gtk_cell_renderer_toggle_get_active (cell)
			
			gtk_tree_model_get_iter_from_string (GTK_TREE_MODEL (model), @iter, path)
			
			If (active) Then
				'gtk_cell_renderer_set_alignment(GTK_CELL_RENDERER(cell), 0, 0)
				gtk_list_store_set (GTK_LIST_STORE (model), @iter, 0, False, -1)
			Else
				'gtk_cell_renderer_set_alignment(GTK_CELL_RENDERER(cell), 0.5, 0.5)
				gtk_list_store_set (GTK_LIST_STORE (model), @iter, 0, True, -1)
			End If
		End Sub
	
	Private Function ListViewColumns.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, Format As ColumnFormat = cfLeft, ColEditable As Boolean = False) As ListViewColumn Ptr
		Dim As ListViewColumn Ptr PColumn
		Dim As Integer Index
		PColumn = _New( ListViewColumn)
		FColumns.Add PColumn
		Index = FColumns.Count - 1
		With *PColumn
			.ImageIndex     = FImageIndex
			.Text        = FCaption
			.Index = Index
			.Width     = iWidth
			.Format = Format
			
		End With
			If Parent Then
				PColumn->Column = gtk_tree_view_column_new()
				gtk_tree_view_column_set_reorderable(PColumn->Column, Cast(ListView Ptr, Parent)->AllowColumnReorder)
				Dim As GtkCellRenderer Ptr rendertext = gtk_cell_renderer_text_new()
				If ColEditable Then
					Dim As GValue bValue '= G_VALUE_INIT
					g_value_init_(@bValue, G_TYPE_BOOLEAN)
					g_value_set_boolean(@bValue, True)
					g_object_set_property(G_OBJECT(rendertext), "editable", @bValue)
					g_value_unset(@bValue)
					'Dim bTrue As gboolean = True
					'g_object_set(rendertext, "mode", GTK_CELL_RENDERER_MODE_EDITABLE, NULL)
					'g_object_set(gtk_cell_renderer_text(rendertext), "editable-set", true, NULL)
					'g_object_set(rendertext, "editable", bTrue, NULL)
				End If
				If Index = 0 Then
					If Cast(ListView Ptr, Parent)->CheckBoxes Then
						Dim As GtkCellRenderer Ptr rendertoggle = gtk_cell_renderer_toggle_new()
						gtk_tree_view_column_pack_start(PColumn->Column, rendertoggle, False)
						gtk_tree_view_column_add_attribute(PColumn->Column, rendertoggle, ToUtf8("active"), 0)
						'gtk_cell_renderer_toggle_set_activatable(gtk_cell_renderer_toggle(rendertoggle), True)
						g_signal_connect(rendertoggle, "toggled", G_CALLBACK(@Check), Parent)
					End If
					Dim As GtkCellRenderer Ptr renderpixbuf = gtk_cell_renderer_pixbuf_new()
					gtk_tree_view_column_pack_start(PColumn->Column, renderpixbuf, False)
					gtk_tree_view_column_add_attribute(PColumn->Column, renderpixbuf, ToUtf8("icon_name"), 2)
				End If
				g_signal_connect(G_OBJECT(rendertext), "edited", G_CALLBACK (@Cell_Edited), PColumn)
				gtk_tree_view_column_pack_start(PColumn->Column, rendertext, True)
				gtk_tree_view_column_add_attribute(PColumn->Column, rendertext, ToUtf8("text"), Index + 3)
				gtk_tree_view_column_set_resizable(PColumn->Column, True)
				gtk_tree_view_column_set_title(PColumn->Column, ToUtf8(FCaption))
				If GTK_IS_TREE_VIEW(Parent->Handle) Then
					gtk_tree_view_append_column(GTK_TREE_VIEW(Parent->Handle), PColumn->Column)
				Else
					gtk_tree_view_append_column(GTK_TREE_VIEW(g_object_get_data(G_OBJECT(Parent->Handle), "@@@TreeView")), PColumn->Column)
				End If
					gtk_tree_view_column_set_fixed_width(PColumn->Column, Max(-1, iWidth))
				
			PColumn->Parent = Parent
				
		End If
		Return PColumn
	End Function
	
	Private Sub ListViewColumns.Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer, Format As ColumnFormat = cfLeft)
		Dim As ListViewColumn Ptr PColumn
		PColumn = _New( ListViewColumn)
		FColumns.Insert Index, PColumn
		With *PColumn
			.ImageIndex     = FImageIndex
			.Text        = FCaption
			.Index        = FColumns.Count - 1
			.Width     = iWidth
			.Format = Format
		End With
	End Sub
	
	Private Sub ListViewColumns.Remove(Index As Integer)
		FColumns.Remove Index
	End Sub
	
	Private Function ListViewColumns.IndexOf(ByRef FColumn As ListViewColumn Ptr) As Integer
		Return FColumns.IndexOf(FColumn)
	End Function
	
	Private Sub ListViewColumns.Clear
		For i As Integer = Count -1 To 0 Step -1
			_Delete( @QListViewColumn(FColumns.Items[i]))
			Remove i
		Next i
		FColumns.Clear
	End Sub
	
	Private Operator ListViewColumns.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ListViewColumns
		This.Clear
	End Constructor
	
	Private Destructor ListViewColumns
		This.Clear
	End Destructor
	
	Private Sub ListView.Init()
			If gtk_tree_view_get_model(GTK_TREE_VIEW(TreeViewWidget)) = NULL Then
				With This
					If .ColumnTypes Then _DeleteSquareBrackets( .ColumnTypes)
					.ColumnTypes = _New(GType[Columns.Count + 4])
					.ColumnTypes[0] = G_TYPE_BOOLEAN
					.ColumnTypes[1] = GDK_TYPE_PIXBUF
					.ColumnTypes[2] = G_TYPE_STRING
					For i As Integer = 3 To Columns.Count + 3
						.ColumnTypes[i] = G_TYPE_STRING
					Next i
				End With
				gtk_list_store_set_column_types(ListStore, Columns.Count + 3, ColumnTypes)
				gtk_tree_view_set_model(GTK_TREE_VIEW(TreeViewWidget), GTK_TREE_MODEL(ListStore))
				gtk_icon_view_set_model(GTK_ICON_VIEW(IconViewWidget), GTK_TREE_MODEL(ListStore))
				gtk_icon_view_set_pixbuf_column(GTK_ICON_VIEW(IconViewWidget), 1)
				If Columns.Count > 0 Then
					gtk_icon_view_set_text_column(GTK_ICON_VIEW(IconViewWidget), 3)
				End If
				gtk_tree_view_set_enable_tree_lines(GTK_TREE_VIEW(TreeViewWidget), True)
			End If
	End Sub
	
	Private Sub ListView.EnsureVisible(Index As Integer)
			If GTK_IS_ICON_VIEW(widget) Then
				gtk_icon_view_select_path(GTK_ICON_VIEW(widget), gtk_tree_path_new_from_string(Trim(Str(Index))))
			Else
				If TreeSelection Then
					If Index > -1 AndAlso Index < ListItems.Count Then
						Dim As GtkTreeIter iter
						gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(ListStore), @iter, Trim(Str(Index)))
						gtk_tree_view_scroll_to_cell(GTK_TREE_VIEW(widget), gtk_tree_model_get_path(GTK_TREE_MODEL(ListStore), @iter), NULL, False, 0, 0)
					End If
				End If
			End If
	End Sub
	
	Private Property ListView.ColumnHeaderHidden As Boolean
		Return FColumnHeaderHidden
	End Property
	
	Private Property ListView.ColumnHeaderHidden(Value As Boolean)
		FColumnHeaderHidden = Value
			gtk_tree_view_set_headers_visible(GTK_TREE_VIEW(TreeViewWidget), Not Value)
	End Property
	
	Private Sub ListView.ChangeLVExStyle(iStyle As Integer, Value As Boolean)
	End Sub
	
	Private Property ListView.SingleClickActivate As Boolean
		Return FSingleClickActivate
	End Property
	
	Private Property ListView.SingleClickActivate(Value As Boolean)
		FSingleClickActivate = Value
				gtk_tree_view_set_activate_on_single_click(GTK_TREE_VIEW(TreeViewWidget), Value)
				gtk_icon_view_set_activate_on_single_click(GTK_ICON_VIEW(IconViewWidget), Value)
	End Property
	
	Private Property ListView.HoverSelection As Boolean
		Return FHoverSelection
	End Property
	
	Private Property ListView.HoverSelection(Value As Boolean)
		FHoverSelection = Value
			gtk_tree_view_set_hover_selection(GTK_TREE_VIEW(TreeViewWidget), Value)
	End Property
	
	Private Property ListView.AllowColumnReorder As Boolean
		Return FAllowColumnReorder
	End Property
	
	Private Property ListView.AllowColumnReorder(Value As Boolean)
		FAllowColumnReorder = Value
			For i As Integer = 0 To Columns.Count - 1
				gtk_tree_view_column_set_reorderable(Columns.Column(i)->Column, Value)
			Next
	End Property
	
	Private Property ListView.BorderSelect As Boolean
		Return FBorderSelect
	End Property
	
	Private Property ListView.BorderSelect(Value As Boolean)
		FBorderSelect = Value
	End Property
	
	Private Property ListView.GridLines As Boolean
		Return FGridLines
	End Property
	
	Private Property ListView.GridLines(Value As Boolean)
		FGridLines = Value
			gtk_tree_view_set_grid_lines(GTK_TREE_VIEW(TreeViewWidget), IIf(Value, GTK_TREE_VIEW_GRID_LINES_BOTH, GTK_TREE_VIEW_GRID_LINES_NONE))
	End Property
	
	Private Property ListView.CheckBoxes As Boolean
		Return FCheckBoxes
	End Property
	
	Private Property ListView.CheckBoxes(Value As Boolean)
		FCheckBoxes = Value
	End Property
	
	Private Property ListView.FullRowSelect As Boolean
		Return FFullRowSelect
	End Property
	
	Private Property ListView.FullRowSelect(Value As Boolean)
		FFullRowSelect = Value
	End Property
	
	Private Property ListView.LabelTip As Boolean
		Return FLabelTip
	End Property
	
	Private Property ListView.LabelTip(Value As Boolean)
		FLabelTip = Value
	End Property
	
	Private Property ListView.MultiSelect As Boolean
		Return FMultiSelect
	End Property
	
	Private Property ListView.MultiSelect(Value As Boolean)
		FMultiSelect = Value
	End Property
	
	Private Property ListView.HoverTime As Integer
		Return FHoverTime
	End Property
	
	Private Property ListView.HoverTime(Value As Integer)
		FHoverTime = Value
	End Property
	
	Private Property ListView.View As ViewStyle
		Return FView
	End Property
	
	Private Property ListView.View(Value As ViewStyle)
		FView = Value
			If FView = ViewStyle.vsDetails Then
				If widget <> TreeViewWidget Then
					widget = TreeViewWidget
					gtk_widget_hide(IconViewWidget)
					If gtk_widget_get_parent(IconViewWidget) = scrolledwidget Then
						g_object_ref(IconViewWidget)
						gtk_container_remove(GTK_CONTAINER(scrolledwidget), IconViewWidget)
					End If
					gtk_container_add(GTK_CONTAINER(scrolledwidget), widget)
					gtk_tree_view_set_model(GTK_TREE_VIEW(widget), gtk_icon_view_get_model(GTK_ICON_VIEW(IconViewWidget)))
					gtk_widget_show(widget)
				End If
			Else
				If widget <> IconViewWidget Then
					widget = IconViewWidget
					gtk_widget_hide(TreeViewWidget)
					If gtk_widget_get_parent(TreeViewWidget) = scrolledwidget Then
						g_object_ref(TreeViewWidget)
						gtk_container_remove(gtk_container(scrolledwidget), TreeViewWidget)
					End If
					gtk_container_add(gtk_container(scrolledwidget), widget)
					gtk_icon_view_set_model(gtk_icon_view(widget), gtk_tree_view_get_model(gtk_tree_view(TreeViewWidget)))
					If scrolledwidget Then g_object_set_data(G_OBJECT(scrolledwidget), "@@@Control2", @This)
					If widget Then 
						g_object_set_data(G_OBJECT(widget), "@@@Control2", @This)
						g_object_set_data(G_OBJECT(widget), "@@@TreeView", TreeViewWidget)
						This.RegisterClass "ListView", @This
					End If
					gtk_widget_show(Widget)
				End If
				Select Case FView
				Case vsIcon: gtk_icon_view_set_item_orientation(GTK_ICON_VIEW(widget), GTK_ORIENTATION_VERTICAL): gtk_icon_view_set_columns(GTK_ICON_VIEW(widget), -1)
				Case vsSmallIcon: gtk_icon_view_set_item_orientation(GTK_ICON_VIEW(widget), GTK_ORIENTATION_HORIZONTAL): gtk_icon_view_set_columns(GTK_ICON_VIEW(widget), -1)
				Case vsList, vsTile, vsMax: gtk_icon_view_set_item_orientation(GTK_ICON_VIEW(widget), GTK_ORIENTATION_HORIZONTAL): gtk_icon_view_set_columns(GTK_ICON_VIEW(widget), 1)
				End Select
			End If
	End Property
	
	Private Property ListView.SelectedItem As ListViewItem Ptr
			Dim As GtkTreeIter iter
			If GTK_IS_ICON_VIEW(widget) Then
				Dim As GList Ptr list = gtk_icon_view_get_selected_items(GTK_ICON_VIEW(widget))
				Dim As GtkTreePath Ptr path
				Dim i As Integer
				If (list) Then
					path = list->data
					i = gtk_tree_path_get_indices(path)[0]
				End If
				g_list_free_full(list, Cast(GDestroyNotify, @gtk_tree_path_free))
				Return ListItems.Item(i)
			Else
				If gtk_tree_selection_get_selected(TreeSelection, NULL, @iter) Then
					Return ListItems.FindByIterUser_Data(iter.user_data)
				End If
			End If
		Return 0
	End Property
	
	Private Property ListView.SelectedItemIndex As Integer
			Dim As GtkTreeIter iter
			If GTK_IS_ICON_VIEW(widget) Then
				Dim As GList Ptr list = gtk_icon_view_get_selected_items(GTK_ICON_VIEW(widget))
				Dim As GtkTreePath Ptr path
				Dim i As Integer = -1
				If (list) Then
					path = list->data
					i = gtk_tree_path_get_indices(path)[0]
				End If
				g_list_free_full(list, Cast(GDestroyNotify, @gtk_tree_path_free))
				Return i
			ElseIf GTK_IS_TREE_SELECTION(TreeSelection) Then
				If gtk_tree_selection_get_selected(TreeSelection, NULL, @iter) Then
					Dim As Integer i
					Dim As GtkTreePath Ptr path
					
					path = gtk_tree_model_get_path(GTK_TREE_MODEL(ListStore), @iter)
					i = gtk_tree_path_get_indices(path)[0]
					gtk_tree_path_free(path)
					'				Dim As ListViewItem Ptr lvi = ListItems.FindByIterUser_Data(iter.User_Data)
					'				If lvi <> 0 Then Return lvi->Index
					Return i
				End If
			End If
		Return -1
	End Property
	
	Private Property ListView.SelectedItemIndex(Value As Integer)
			If GTK_IS_ICON_VIEW(widget) Then
				gtk_icon_view_select_path(GTK_ICON_VIEW(widget), gtk_tree_path_new_from_string(Trim(Str(Value))))
			Else
				If TreeSelection Then
					If Value = -1 Then
						gtk_tree_selection_unselect_all(TreeSelection)
					ElseIf Value > -1 AndAlso Value < ListItems.Count Then
						Dim As GtkTreeIter iter
						gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(ListStore), @iter, Trim(Str(Value)))
						gtk_tree_selection_select_iter(TreeSelection, @iter)
						gtk_tree_view_scroll_to_cell(GTK_TREE_VIEW(widget), gtk_tree_model_get_path(GTK_TREE_MODEL(ListStore), @iter), NULL, False, 0, 0)
					End If
				End If
			End If
	End Property
	
	Private Property ListView.SelectedItem(Value As ListViewItem Ptr)
		Value->SelectItem
	End Property
	
	Private Property ListView.SelectedColumn As ListViewColumn Ptr
		Return 0
	End Property
	
	Private Property ListView.Sort As SortStyle
		Return FSortStyle
	End Property
	
	Private Property ListView.Sort(Value As SortStyle)
		FSortStyle = Value
	End Property
	
	Private Property ListView.SelectedColumn(Value As ListViewColumn Ptr)
	End Property
	
	Private Property ListView.ShowHint As Boolean
		Return FShowHint
	End Property
	
	Private Property ListView.ShowHint(Value As Boolean)
		FShowHint = Value
	End Property
	
	Private Sub ListView.WndProc(ByRef Message As Message)
	End Sub
	
	
	Private Sub ListView.ProcessMessage(ByRef Message As Message)
		'?message.msg, GetMessageName(message.msg)
			Dim As GdkEvent Ptr e = Message.Event
			Select Case Message.Event->type
			Case GDK_MAP
				Init
			Case GDK_BUTTON_RELEASE
				If SelectedItemIndex <> -1 Then
					If OnItemClick Then OnItemClick(*Designer, This, SelectedItemIndex)
				End If
			Case GDK_2BUTTON_PRESS, GDK_DOUBLE_BUTTON_PRESS
				If SelectedItemIndex <> -1 Then
					If OnItemDblClick Then OnItemDblClick(*Designer, This, SelectedItemIndex)
				End If
			Case GDK_KEY_PRESS
				If SelectedItemIndex <> -1 Then
					If OnItemKeyDown Then OnItemKeyDown(*Designer, This, SelectedItemIndex, Message.Event->key.keyval, Message.Event->key.state)
				End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	
	Private Operator ListView.Cast As Control Ptr
		Return @This
	End Operator
	
		Private Sub ListView.ListView_RowActivated(tree_view As GtkTreeView Ptr, path As GtkTreePath Ptr, column As GtkTreeViewColumn Ptr, user_data As Any Ptr)
			Dim As ListView Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeModel Ptr model
				Dim As GtkTreeIter iter
				model = gtk_tree_view_get_model(tree_view)
				If gtk_tree_model_get_iter(model, @iter, path) Then
					If lv->OnItemActivate Then lv->OnItemActivate(*lv->Designer, *lv, Val(*gtk_tree_model_get_string_from_iter(model, @iter)))
				End If
			End If
		End Sub
		
		Private Sub ListView.ListView_ItemActivated(icon_view As GtkIconView Ptr, path As GtkTreePath Ptr, user_data As Any Ptr)
			Dim As ListView Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeModel Ptr model
				Dim As GtkTreeIter iter
				model = gtk_icon_view_get_model(icon_view)
				If gtk_tree_model_get_iter(model, @iter, path) Then
					If lv->OnItemActivate Then lv->OnItemActivate(*lv->Designer, *lv, Val(*gtk_tree_model_get_string_from_iter(model, @iter)))
				End If
			End If
		End Sub
		
		Private Sub ListView.ListView_SelectionChanged(selection As GtkTreeSelection Ptr, user_data As Any Ptr)
			Dim As ListView Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeIter iter
				Dim As GtkTreeModel Ptr model
				If gtk_tree_selection_get_selected(selection, @model, @iter) Then
					Dim As Integer SelectedIndex = Val(*gtk_tree_model_get_string_from_iter(model, @iter))
					If lv->PrevIndex <> SelectedIndex AndAlso lv->PrevIndex <> -1 Then
						Dim bCancel As Boolean
						If lv->OnSelectedItemChanging Then lv->OnSelectedItemChanging(*lv->Designer, *lv, lv->PrevIndex, bCancel)
						If bCancel Then
							lv->SelectedItemIndex = lv->PrevIndex
							Exit Sub
						End If
					End If
					If lv->OnSelectedItemChanged Then lv->OnSelectedItemChanged(*lv->Designer, *lv, SelectedIndex)
					lv->PrevIndex = SelectedIndex
				End If
			End If
		End Sub
		
		Private Sub ListView.IconView_SelectionChanged(iconview As GtkIconView Ptr, user_data As Any Ptr)
			Dim As ListView Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeIter iter
				Dim As GList Ptr list = gtk_icon_view_get_selected_items(iconview)
				Dim As GtkTreePath Ptr path
				Dim SelectedIndex As Integer
				If (list) Then
					path = list->data
					SelectedIndex = gtk_tree_path_get_indices(path)[0]
				End If
				g_list_free_full(list, Cast(GDestroyNotify, @gtk_tree_path_free))
				If lv->PrevIndex <> SelectedIndex AndAlso lv->PrevIndex <> -1 Then
					Dim bCancel As Boolean
					If lv->OnSelectedItemChanging Then lv->OnSelectedItemChanging(*lv->Designer, *lv, lv->PrevIndex, bCancel)
					If bCancel Then
						lv->SelectedItemIndex = lv->PrevIndex
						Exit Sub
					End If
				End If
				If lv->OnSelectedItemChanged Then lv->OnSelectedItemChanged(*lv->Designer, *lv, SelectedIndex)
				lv->PrevIndex = SelectedIndex
			End If
		End Sub
		
		Private Sub ListView.ListView_Map(widget As GtkWidget Ptr, user_data As Any Ptr)
			Dim As ListView Ptr lv = user_data
			lv->Init
		End Sub
		
		Private Function ListView.ListView_Scroll(self As GtkAdjustment Ptr, user_data As Any Ptr) As Boolean
			Dim As ListView Ptr lv = user_data
			If lv->OnEndScroll Then lv->OnEndScroll(*lv->Designer, *lv)
			Return True
		End Function
	
	Private Constructor ListView
			ListStore = gtk_list_store_new(3, G_TYPE_BOOLEAN, GDK_TYPE_PIXBUF, G_TYPE_STRING)
			scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
			gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
			'widget = gtk_tree_view_new_with_model(gtk_tree_model(ListStore))
			TreeViewWidget = gtk_tree_view_new()
			IconViewWidget = gtk_icon_view_new()
			widget = TreeViewWidget
			gtk_container_add(GTK_CONTAINER(scrolledwidget), widget)
			TreeSelection = gtk_tree_view_get_selection(GTK_TREE_VIEW(widget))
				g_signal_connect(gtk_scrollable_get_hadjustment(GTK_SCROLLABLE(widget)), "value-changed", G_CALLBACK(@ListView_Scroll), @This)
				g_signal_connect(gtk_scrollable_get_vadjustment(GTK_SCROLLABLE(widget)), "value-changed", G_CALLBACK(@ListView_Scroll), @This)
			g_signal_connect(GTK_TREE_VIEW(widget), "map", G_CALLBACK(@ListView_Map), @This)
			g_signal_connect(GTK_TREE_VIEW(widget), "row-activated", G_CALLBACK(@ListView_RowActivated), @This)
			g_signal_connect(GTK_ICON_VIEW(IconViewWidget), "item-activated", G_CALLBACK(@ListView_ItemActivated), @This)
			g_signal_connect(GTK_ICON_VIEW(IconViewWidget), "selection-changed", G_CALLBACK(@IconView_SelectionChanged), @This)
			g_signal_connect(G_OBJECT(TreeSelection), "changed", G_CALLBACK (@ListView_SelectionChanged), @This)
			gtk_tree_view_set_enable_tree_lines(GTK_TREE_VIEW(widget), True)
			gtk_tree_view_set_grid_lines(GTK_TREE_VIEW(widget), GTK_TREE_VIEW_GRID_LINES_BOTH)
			ColumnTypes = _New( GType[3])
			ColumnTypes[0] = G_TYPE_BOOLEAN
			ColumnTypes[1] = GDK_TYPE_PIXBUF
			ColumnTypes[2] = G_TYPE_STRING
			This.RegisterClass "ListView", @This
		BorderStyle = BorderStyles.bsClient
		ListItems.Parent = @This
		Columns.Parent = @This
		FView = vsDetails
		DoubleBuffered = True
		FEnabled = True
		FGridLines = True
		FFullRowSelect = True
		FVisible = True
		FTabIndex          = -1
		FTabStop = True
		With This
			.Child             = @This
			WLet(FClassName, "ListView")
			.Width             = 121
			.Height            = 121
		End With
	End Constructor
	
	Private Destructor ListView
			ListItems.Clear
			If ColumnTypes Then _DeleteSquareBrackets( ColumnTypes)
				If GTK_IS_WIDGET(TreeViewWidget) AndAlso TreeViewWidget <> widget Then 
						gtk_widget_destroy(TreeViewWidget)
				End If
				If GTK_IS_WIDGET(IconViewWidget) AndAlso IconViewWidget <> widget Then 
						gtk_widget_destroy(IconViewWidget)
				End If
	End Destructor
End Namespace
