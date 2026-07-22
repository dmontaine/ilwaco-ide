'################################################################################
'#  TreeListView.bi                                                             #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov(2018-2019)  Liu XiaLin                          #
'################################################################################

#include once "TreeListView.bi"
#include once "TextBox.bi"

Namespace My.Sys.Forms
	
	Private Sub TreeListViewItem.Collapse
			If Parent AndAlso Parent->Handle AndAlso Cast(TreeListView Ptr, Parent)->TreeStore Then
				If Visible Then
					Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(GTK_TREE_MODEL(Cast(TreeListView Ptr, Parent)->TreeStore), @TreeIter))
					gtk_tree_view_collapse_row(GTK_TREE_VIEW(Parent->Handle), TreePath)
					gtk_tree_path_free(TreePath)
				End If
			End If
		FExpanded = False
	End Sub
	
	Private Sub TreeListViewItem.Expand
			If Parent AndAlso Parent->Handle AndAlso Cast(TreeListView Ptr, Parent)->TreeStore Then
				If Visible Then
					Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(GTK_TREE_MODEL(Cast(TreeListView Ptr, Parent)->TreeStore), @TreeIter))
					gtk_tree_view_expand_row(GTK_TREE_VIEW(Parent->Handle), TreePath, False)
					gtk_tree_path_free(TreePath)
				End If
			End If
		FExpanded = True
	End Sub
	
	Private Function TreeListViewItem.IsExpanded As Boolean
			If Parent AndAlso Parent->Handle AndAlso Cast(TreeListView Ptr, Parent)->TreeStore Then
				Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(GTK_TREE_MODEL(Cast(TreeListView Ptr, Parent)->TreeStore), @TreeIter))
				Var bResult = gtk_tree_view_row_expanded(GTK_TREE_VIEW(Parent->Handle), TreePath)
				gtk_tree_path_free(TreePath)
				Return bResult
			End If
	End Function
	
	Private Function TreeListViewItem.Index As Integer
		If FParentItem <> 0 Then
			Return FParentItem->Nodes.IndexOf(@This)
		ElseIf Parent <> 0 Then
			Return Cast(TreeListView Ptr, Parent)->Nodes.IndexOf(@This)
		Else
			Return -1
		End If
	End Function
	
	Private Sub TreeListViewItem.SelectItem
			If Parent AndAlso Cast(TreeListView Ptr, Parent)->TreeSelection Then
				gtk_tree_selection_select_iter(Cast(TreeListView Ptr, Parent)->TreeSelection, @TreeIter)
			End If
	End Sub
	
	Private Property TreeListViewItem.Text(iSubItem As Integer) ByRef As WString
		If FSubItems.Count > iSubItem Then
			Return FSubItems.Item(iSubItem)
		Else
			Return WStr("")
		End If
	End Property
	
	Private Property TreeListViewItem.Text(iSubItem As Integer, ByRef Value As WString)
		WLet(FText, Value)
		For i As Integer = FSubItems.Count To iSubItem
			FSubItems.Add ""
		Next i
		FSubItems.Item(iSubItem) = Value
		If Parent Then
				If Cast(TreeListView Ptr, Parent)->TreeStore Then
					gtk_tree_store_set (Cast(TreeListView Ptr, Parent)->TreeStore, @TreeIter, iSubItem + 1, ToUtf8(Value), -1)
				End If
		End If
	End Property
	
	Private Property TreeListViewItem.State As Integer
		Return FState
	End Property
	
	Private Property TreeListViewItem.State(Value As Integer)
		FState = Value
	End Property
	
	Private Property TreeListViewItem.Indent As Integer
		Return FIndent
	End Property
	
	Private Property TreeListViewItem.Indent(Value As Integer)
		FIndent = Value
	End Property
	
	Private Property TreeListViewItem.Hint ByRef As WString
		Return WGet(FHint)
	End Property
	
	Private Property TreeListViewItem.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	
	Private Property TreeListViewItem.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property TreeListViewItem.ImageIndex(Value As Integer)
		If Value <> FImageIndex Then
			FImageIndex = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property TreeListViewItem.SelectedImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property TreeListViewItem.SelectedImageIndex(Value As Integer)
		If Value <> FSelectedImageIndex Then
			FSelectedImageIndex = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property TreeListViewItem.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property TreeListViewItem.ParentItem As TreeListViewItem Ptr
		Return FParentItem
	End Property
	
	Private Property TreeListViewItem.ParentItem(Value As TreeListViewItem Ptr)
		FParentItem = Value
	End Property
	
	Private Property TreeListViewItem.ImageKey ByRef As WString
	Static EmptyWString As WString * 1
		If FImageKey > 0 Then Return *FImageKey Else Return EmptyWString
	End Property
	
	Private Property TreeListViewItem.ImageKey(ByRef Value As WString)
		If FImageKey = 0 OrElse Value <> *FImageKey Then
			WLet(FImageKey, Value)
				If Parent AndAlso Parent->Handle Then
					gtk_tree_store_set (Cast(TreeListView Ptr, Parent)->TreeStore, @TreeIter, 0, ToUtf8(Value), -1)
				End If
		End If
	End Property
	
	Private Property TreeListViewItem.SelectedImageKey ByRef As WString
	Static EmptyWString As WString * 1
		If FSelectedImageKey > 0 Then Return *FSelectedImageKey Else Return EmptyWString
	End Property
	
	Private Property TreeListViewItem.SelectedImageKey(ByRef Value As WString)
		If FSelectedImageKey = 0 OrElse Value <> *FSelectedImageKey Then
			WLet(FSelectedImageKey, Value)
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	
	Private Sub TreeListViewItem.AddItems(Node As TreeListViewItem Ptr)
			If Node->ParentItem = 0 OrElse Node->ParentItem->Visible Then
				Dim As Integer iIndex
				Dim As TreeListViewItems Ptr pNodes
				If Node->ParentItem <> 0 Then
					pNodes = @(Node->ParentItem->Nodes)
				Else
					pNodes = @(QTreeListView(Node->Parent).Nodes)
				End If
				For i As Integer = 0 To Node->Index - 1
					If pNodes->Item(i)->Visible Then
						iIndex = iIndex + 1
					End If
				Next
				If Node->Parent AndAlso Cast(TreeListView Ptr, Node->Parent)->TreeStore Then
					Cast(TreeListView Ptr, Node->Parent)->Init
					If Node->ParentItem <> 0 Then
						gtk_tree_store_insert (Cast(TreeListView Ptr, Node->Parent)->TreeStore, @Node->TreeIter, @(Node->ParentItem->TreeIter), iIndex)
					Else
						gtk_tree_store_insert (Cast(TreeListView Ptr, Node->Parent)->TreeStore, @Node->TreeIter, NULL, iIndex)
					End If
					gtk_tree_store_set (Cast(TreeListView Ptr, Node->Parent)->TreeStore, @Node->TreeIter, 1, ToUtf8(Node->Text(0)), -1)
					For j As Integer = 1 To Cast(TreeListView Ptr, Node->Parent)->Columns.Count - 1
						gtk_tree_store_set (Cast(TreeListView Ptr, Node->Parent)->TreeStore, @Node->TreeIter, j + 1, ToUtf8(Node->Text(j)), -1)
					Next
					For j As Integer = 0 To Node->Nodes.Count - 1
						If Node->Nodes.Item(j)->Visible Then AddItems Node->Nodes.Item(j)
					Next
				End If
			End If
	End Sub
	
	Private Property TreeListViewItem.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Value Then
				AddItems @This
			Else
					If Parent AndAlso Parent->Handle Then
						gtk_tree_store_remove(Cast(TreeListView Ptr, Parent)->TreeStore, @This.TreeIter)
					End If
			End If
		End If
	End Property
	
	Private Operator TreeListViewItem.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor TreeListViewItem
		Nodes.Parent = Parent
		Nodes.ParentItem = @This
		FHint = 0 'CAllocate_(0)
		FText = 0 'CAllocate_(0)
		FVisible    = 1
		Text(0)    = ""
		Hint       = ""
		FImageIndex = -1
		FSelectedImageIndex = -1
		FSmallImageIndex = -1
	End Constructor
	
	Private Destructor TreeListViewItem
		Nodes.Clear
			If Parent AndAlso Parent->Handle Then
				gtk_tree_store_remove(Cast(TreeListView Ptr, Parent)->TreeStore, @This.TreeIter)
			End If
		WDeAllocate(FHint)
		WDeAllocate(FText)
		WDeAllocate(FImageKey)
		WDeAllocate(FSelectedImageKey)
		WDeAllocate(FSmallImageKey)
	End Destructor
	
	Private Sub TreeListViewColumn.SelectItem
	End Sub
	
	Private Property TreeListViewColumn.Text ByRef As WString
		Return WGet(FText)
	End Property
	
	Private Property TreeListViewColumn.Text(ByRef Value As WString)
		WLet(FText, Value)
	End Property
	
	Private Property TreeListViewColumn.Width As Integer
			If This.Column Then FWidth = gtk_tree_view_column_get_width(This.Column)
		Return FWidth
	End Property
	
	Private Property TreeListViewColumn.Width(Value As Integer)
		FWidth = Value
		Update
	End Property
	
	Private Sub TreeListViewColumn.Update
				If This.Column Then gtk_tree_view_column_set_fixed_width(This.Column, Max(-1, FWidth))
	End Sub
	
	Private Property TreeListViewColumn.Format As ColumnFormat
		Return FFormat
	End Property
	
	Private Property TreeListViewColumn.Format(Value As ColumnFormat)
		FFormat = Value
	End Property
	
	Private Property TreeListViewColumn.Hint ByRef As WString
		Return WGet(FHint)
	End Property
	
	Private Property TreeListViewColumn.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	
	Private Property TreeListViewColumn.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property TreeListViewColumn.ImageIndex(Value As Integer)
		If Value <> FImageIndex Then
			FImageIndex = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property TreeListViewColumn.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property TreeListViewColumn.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_HIDEBUTTON, FCommandID, MakeLong(NOT FVisible, 0))
				End With
			End If
		End If
	End Property
	
	Private Property TreeListViewColumn.Editable As Boolean
		Return FEditable
	End Property
	
	Private Property TreeListViewColumn.Editable(Value As Boolean)
		If Value <> FEditable Then
			FEditable = Value
			If Index = 0 Then
				
			End If
				Dim As GValue bValue '= G_VALUE_INIT
				g_value_init_(@bValue, G_TYPE_BOOLEAN)
				g_value_set_boolean(@bValue, Value)
				g_object_set_property(G_OBJECT(rendertext), "editable", @bValue)
				g_object_set_property(G_OBJECT(rendertext), "editable-set", @bValue)
				g_value_unset(@bValue)
		End If
	End Property
	
	Private Operator TreeListViewColumn.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor TreeListViewColumn
		FHint = 0 'CAllocate_(0)
		FText = 0 'CAllocate_(0)
		FVisible    = 1
		Text    = ""
		Hint       = ""
		FImageIndex = -1
	End Constructor
	
	Private Destructor TreeListViewColumn
		If FHint Then _Deallocate( FHint)
		If FText Then _Deallocate( FText)
	End Destructor
	
	Private Property TreeListViewItems.Count As Integer
		Return FItems.Count
	End Property
	
	Private Property TreeListViewItems.Count(Value As Integer)
		If Parent Then
			With *Cast(TreeListView Ptr, Parent)
				If Value >= .Nodes.Count Then
					For i As Integer = .Nodes.Count To Value - 1
						.Nodes.Add
					Next
				Else
					For i As Integer = .Nodes.Count - 1 To Value Step -1
						.Nodes.Remove i
					Next
				End If
			End With
			If Parent->Handle Then
			End If
		End If
	End Property
	
	Private Property TreeListViewItems.Item(Index As Integer) As TreeListViewItem Ptr
		If Index >= 0 AndAlso Index < FItems.Count Then
			Return FItems.Items[Index]
		End If
	End Property
	
	Private Property TreeListViewItems.Item(Index As Integer, Value As TreeListViewItem Ptr)
		If Index >= 0 AndAlso Index < FItems.Count Then
			FItems.Items[Index] = Value 'David Change
		End If
	End Property
	
		Private Function TreeListViewItems.FindByIterUser_Data(User_Data As Any Ptr) As TreeListViewItem Ptr
			If ParentItem AndAlso ParentItem->TreeIter.user_data = User_Data Then Return ParentItem
			For i As Integer = 0 To Count - 1
				PItem = Item(i)->Nodes.FindByIterUser_Data(User_Data)
				If PItem <> 0 Then Return PItem
			Next i
			Return 0
		End Function
	
	Private Property TreeListViewItems.ParentItem As TreeListViewItem Ptr
		Return FParentItem
	End Property
	
	Private Property TreeListViewItems.ParentItem(Value As TreeListViewItem Ptr)
		FParentItem = Value
	End Property
	
	Private Function TreeListViewItems.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0) As TreeListViewItem Ptr
		PItem = _New( TreeListViewItem)
		PItem->FDynamic = True
		FItems.Add PItem
		With *PItem
			.ImageIndex     = FImageIndex
			Var MinColumnsCount = 0
			If InStr(FCaption, Chr(9)) > 0 Then
				Dim As UString Captions(Any)
				Split(FCaption, Chr(9), Captions())
				MinColumnsCount = Min(UBound(Captions), Cast(TreeListView Ptr, Parent)->Columns.Count - 1)
				For j As Integer = 0 To MinColumnsCount
					.Text(j)        = Captions(j)
				Next
			Else
				.Text(0)        = FCaption
			End If
			.State        = State
			If ParentItem Then
				.Indent        = ParentItem->Indent + 1
			Else
				.Indent        = 0
			End If
			.Parent         = Parent
			.Nodes.Parent         = Parent
			.ParentItem        = ParentItem
			If FItems.Count = 1 AndAlso ParentItem Then
				ParentItem->State = IIf(ParentItem->IsExpanded, 2, 1)
			End If
				If Parent AndAlso Cast(TreeListView Ptr, Parent)->TreeStore Then
					Cast(TreeListView Ptr, Parent)->Init
					If ParentItem <> 0 Then
						gtk_tree_store_append (Cast(TreeListView Ptr, Parent)->TreeStore, @PItem->TreeIter, @.ParentItem->TreeIter)
					Else
						gtk_tree_store_append (Cast(TreeListView Ptr, Parent)->TreeStore, @PItem->TreeIter, NULL)
					End If
					gtk_tree_store_set (Cast(TreeListView Ptr, Parent)->TreeStore, @PItem->TreeIter, 1, ToUtf8(.Text(0)), -1)
					For j As Integer = 1 To MinColumnsCount
						gtk_tree_store_set (Cast(TreeListView Ptr, Parent)->TreeStore, @PItem->TreeIter, j + 1, ToUtf8(.Text(j)), -1)
					Next j
				End If
				PItem->Text(0) = .Text(0)
		End With
		Return PItem
	End Function
	
	Private Function TreeListViewItems.Add(ByRef FCaption As WString = "", ByRef FImageKey As WString, State As Integer = 0, Indent As Integer = 0) As TreeListViewItem Ptr
		If Parent AndAlso Cast(TreeListView Ptr, Parent)->Images Then
			PItem = Add(FCaption, Cast(TreeListView Ptr, Parent)->Images->IndexOf(FImageKey), State, Indent)
		Else
			PItem = Add(FCaption, -1, State, Indent)
		End If
		If PItem Then PItem->ImageKey = FImageKey
		Return PItem
	End Function
	
	Private Function TreeListViewItems.Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0) As TreeListViewItem Ptr
		Dim As TreeListViewItem Ptr PItem
		PItem = _New( TreeListViewItem)
		PItem->FDynamic = True
		FItems.Insert Index, PItem
		With *PItem
			.ImageIndex     = FImageIndex
			.Text(0)        = FCaption
			.State          = State
			If ParentItem Then
				.Indent        = ParentItem->Indent + 1
			Else
				.Indent        = 0
			End If
			.Parent         = Parent
			.Nodes.Parent         = Parent
			.ParentItem        = Cast(TreeListViewItem Ptr, ParentItem)
			If FItems.Count = 1 AndAlso ParentItem Then
				ParentItem->State = IIf(ParentItem->IsExpanded, 2, 1)
			End If
				If Parent AndAlso Cast(TreeListView Ptr, Parent)->TreeStore Then
					Cast(TreeListView Ptr, Parent)->Init
					If ParentItem <> 0 Then
						gtk_tree_store_insert(Cast(TreeListView Ptr, Parent)->TreeStore, @PItem->TreeIter, @.ParentItem->TreeIter, Index)
					Else
						gtk_tree_store_insert(Cast(TreeListView Ptr, Parent)->TreeStore, @PItem->TreeIter, NULL, Index)
					End If
					gtk_tree_store_set(Cast(TreeListView Ptr, Parent)->TreeStore, @PItem->TreeIter, 1, ToUtf8(FCaption), -1)
				End If
				PItem->Text(0) = FCaption
		End With
		Return PItem
	End Function
	
	Private Sub TreeListViewItems.Remove(Index As Integer)
		'				'gtk_tree_store_remove(Cast(TreeListView Ptr, Parent)->TreeStore, @This.Item(Index)->TreeIter)
		'				Delete_( Cast(TreeListViewItem Ptr, FItems.Items[Index]))
		'				'Item(Index)->Visible = False
		'				Delete_( Cast(TreeListViewItem Ptr, FItems.Items[Index]))
		If Count < 1 OrElse Index < 0 OrElse Index > Count - 1 Then Exit Sub
		If Cast(TreeListViewItem Ptr, FItems.Items[Index])->FDynamic Then _Delete( Cast(TreeListViewItem Ptr, FItems.Items[Index]))
		FItems.Remove Index
	End Sub
	
	
	Private Sub TreeListViewItems.Sort
	End Sub
	
	Private Function TreeListViewItems.IndexOf(ByRef FItem As TreeListViewItem Ptr) As Integer
		Return FItems.IndexOf(FItem)
	End Function
	
	Private Function TreeListViewItems.IndexOf(ByRef Caption As WString) As Integer
		For i As Integer = 0 To Count - 1
			If QTreeListViewItem(FItems.Items[i]).Text(0) = Caption Then
				Return i
			End If
		Next i
		Return -1
	End Function
	
	Private Function TreeListViewItems.Contains(ByRef Caption As WString) As Boolean
		Return IndexOf(Caption) <> -1
	End Function
	
	Private Sub TreeListViewItems.Clear
		If FParentItem = 0 Then
		End If
		For i As Integer = Count - 1 To 0 Step -1
			If Cast(TreeListViewItem Ptr, FItems.Items[i])->FDynamic Then _Delete(Cast(TreeListViewItem Ptr, FItems.Items[i]))
		Next i
		FItems.Clear
		If ParentItem Then ParentItem->State = 0
	End Sub
	
	Private Operator TreeListViewItems.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor TreeListViewItems
		'This.Clear
	End Constructor
	
	Private Destructor TreeListViewItems
		This.Clear
	End Destructor
	
	Private Property TreeListViewColumns.Count As Integer
		Return FColumns.Count
	End Property
	
	Private Property TreeListViewColumns.Count(Value As Integer)
	End Property
	
	Private Property TreeListViewColumns.Column(Index As Integer) As TreeListViewColumn Ptr
		Return QListViewColumn(FColumns.Items[Index])
	End Property
	
	Private Property TreeListViewColumns.Column(Index As Integer, Value As TreeListViewColumn Ptr)
		'QListViewColumn(FColumns.Items[Index]) = Value
	End Property
	
		Private Sub TreeListViewColumns.Cell_Edited(renderer As GtkCellRendererText Ptr, path As gchar Ptr, new_text As gchar Ptr, user_data As Any Ptr)
			Dim As TreeListViewColumn Ptr PColumn = user_data
			If PColumn = 0 Then Exit Sub
			Dim As TreeListView Ptr lv = Cast(TreeListView Ptr, PColumn->Parent)
			If lv = 0 Then Exit Sub
			Dim As GtkTreeIter iter
			Dim As GtkTreeModel Ptr model = gtk_tree_view_get_model(GTK_TREE_VIEW(lv->Handle))
			If gtk_tree_model_get_iter(model, @iter, gtk_tree_path_new_from_string(path)) Then
				Dim Cancel As Boolean
				If lv->OnCellEdited Then lv->OnCellEdited(*lv->Designer, *lv, lv->Nodes.FindByIterUser_Data(iter.user_data), PColumn->Index, *new_text, Cancel)
				If Not Cancel Then
					lv->Nodes.FindByIterUser_Data(iter.user_data)->Text(PColumn->Index) = *new_text
					'gtk_tree_store_set(lv->TreeStore, @iter, PColumn->Index + 1, ToUtf8(*new_text), -1)
				End If
			End If
		End Sub
		
		Private Sub TreeListViewColumns.Cell_Editing(cell As GtkCellRenderer Ptr, editable As GtkCellEditable Ptr, path As Const gchar Ptr, user_data As Any Ptr)
			Dim As TreeListViewColumn Ptr PColumn = user_data
			If PColumn = 0 Then Exit Sub
			Dim As TreeListView Ptr lv = Cast(TreeListView Ptr, PColumn->Parent)
			If lv = 0 Then Exit Sub
			Dim As GtkTreeIter iter
			Dim As GtkTreeModel Ptr model = gtk_tree_view_get_model(GTK_TREE_VIEW(lv->Handle))
			Dim As TextBox txt
			If gtk_tree_model_get_iter(model, @iter, gtk_tree_path_new_from_string(path)) Then
				Dim Cancel As Boolean
				txt.Handle = Cast(GtkWidget Ptr, editable)
				If lv->OnCellEditing Then lv->OnCellEditing(*lv->Designer, *lv, lv->Nodes.FindByIterUser_Data(iter.user_data), PColumn->Index, @txt, Cancel)
				txt.Handle = 0
				If Cancel Then
					gtk_cell_editable_editing_done(editable)
				End If
			End If
		End Sub
	
	Private Function TreeListViewColumns.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, Format As ColumnFormat = cfLeft, ColEditable As Boolean = False) As TreeListViewColumn Ptr
		Dim As TreeListViewColumn Ptr PColumn
		Dim As Integer Index
		PColumn = _New( TreeListViewColumn)
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
				With *Cast(TreeListView Ptr, Parent)
					If .ColumnTypes Then _DeleteSquareBrackets( .ColumnTypes)
					.ColumnTypes = _New( GType[Index + 2])
					For i As Integer = 0 To Index + 1
						.ColumnTypes[i] = G_TYPE_STRING
					Next i
				End With
				PColumn->Column = gtk_tree_view_column_new()
				PColumn->rendertext = gtk_cell_renderer_text_new()
				If ColEditable Then
					Dim As GValue bValue '= G_VALUE_INIT
					g_value_init_(@bValue, G_TYPE_BOOLEAN)
					g_value_set_boolean(@bValue, True)
					g_object_set_property(G_OBJECT(PColumn->rendertext), "editable", @bValue)
					g_object_set_property(G_OBJECT(PColumn->rendertext), "editable-set", @bValue)
					g_value_unset(@bValue)
					'g_object_set(rendertext, "mode", GTK_CELL_RENDERER_MODE_EDITABLE, NULL)
					'g_object_set(gtk_cell_renderer_text(rendertext), "editable-set", true, NULL)
					'g_object_set(rendertext, "editable", bTrue, NULL)
				End If
				If Index = 0 Then
					Dim As GtkCellRenderer Ptr renderpixbuf = gtk_cell_renderer_pixbuf_new()
					gtk_tree_view_column_pack_start(PColumn->Column, renderpixbuf, False)
					gtk_tree_view_column_add_attribute(PColumn->Column, renderpixbuf, ToUtf8("icon_name"), 0)
				End If
				g_signal_connect(G_OBJECT(PColumn->rendertext), "edited", G_CALLBACK (@Cell_Edited), PColumn)
				g_signal_connect(G_OBJECT(PColumn->rendertext), "editing-started", G_CALLBACK (@Cell_Editing), PColumn)
				gtk_tree_view_column_pack_start(PColumn->Column, PColumn->rendertext, True)
				gtk_tree_view_column_add_attribute(PColumn->Column, PColumn->rendertext, ToUtf8("text"), Index + 1)
				gtk_tree_view_column_set_resizable(PColumn->Column, True)
				gtk_tree_view_column_set_title(PColumn->Column, ToUtf8(FCaption))
				gtk_tree_view_append_column(GTK_TREE_VIEW(Cast(TreeListView Ptr, Parent)->Handle), PColumn->Column)
					gtk_tree_view_column_set_fixed_width(PColumn->Column, Max(-1, iWidth))
			End If
		If Parent Then
			PColumn->Parent = Parent
				
		End If
		Return PColumn
	End Function
	
	Private Sub TreeListViewColumns.Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer, Format As ColumnFormat = cfLeft)
		Dim As TreeListViewColumn Ptr PColumn
		PColumn = _New( TreeListViewColumn)
		FColumns.Insert Index, PColumn
		With *PColumn
			.ImageIndex = FImageIndex
			.Text       = FCaption
			.Index      = FColumns.Count - 1
			.Width      = iWidth
			.Format     = Format
		End With
	End Sub
	
	Private Sub TreeListViewColumns.Remove(Index As Integer)
		FColumns.Remove Index
	End Sub
	
	Private Function TreeListViewColumns.IndexOf(ByRef FColumn As TreeListViewColumn Ptr) As Integer
		Return FColumns.IndexOf(FColumn)
	End Function
	
	Private Sub TreeListViewColumns.Clear
		For i As Integer = Count -1 To 0 Step -1
			_Delete( @QTreeListViewColumn(FColumns.Items[i]))
			Remove i
		Next i
		FColumns.Clear
	End Sub
	
	Private Operator TreeListViewColumns.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor TreeListViewColumns
		This.Clear
	End Constructor
	
	Destructor TreeListViewColumns
		This.Clear
	End Destructor
	
	#ifndef ReadProperty_Off
		Private Function TreeListView.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "columnheaderhidden": Return @FColumnHeaderHidden
			Case "images": Return Images
			Case "gridlines": Return @FGridLines
			Case "multiselect": Return @FMultiSelect
			Case "singleclickactivate": Return @FSingleClickActivate
			Case "sortorder": Return @FSortStyle
			Case "stateimages": Return StateImages
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function TreeListView.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "columnheaderhidden": This.ColumnHeaderHidden = QBoolean(Value)
				Case "images": This.Images = Value
				Case "gridlines": This.GridLines = QBoolean(Value)
				Case "multiselect": This.MultiSelect = QBoolean(Value)
				Case "singleclickactivate": This.SingleClickActivate = QBoolean(Value)
				Case "sortorder": This.SortOrder = *Cast(SortStyle Ptr, Value)
				Case "stateimages": This.StateImages = Value
				Case "tabindex": This.TabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property TreeListView.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property TreeListView.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property TreeListView.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property TreeListView.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Sub TreeListView.Init()
			If gtk_tree_view_get_model(GTK_TREE_VIEW(widget)) = NULL Then
				gtk_tree_store_set_column_types(TreeStore, Columns.Count + 1, ColumnTypes)
				gtk_tree_view_set_model(GTK_TREE_VIEW(widget), GTK_TREE_MODEL(TreeStore))
				gtk_tree_view_set_enable_tree_lines(GTK_TREE_VIEW(widget), True)
			End If
	End Sub
		
	Private Sub TreeListView.EnsureVisible(Index As Integer)
			If GTK_IS_ICON_VIEW(widget) Then
				gtk_icon_view_select_path(GTK_ICON_VIEW(widget), gtk_tree_path_new_from_string(Trim(Str(Index))))
			Else
				If TreeSelection Then
					If Index > -1 AndAlso Index < Nodes.Count Then
						Dim As GtkTreeIter iter
						gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(TreeStore), @iter, Trim(Str(Index)))
						gtk_tree_view_scroll_to_cell(GTK_TREE_VIEW(widget), gtk_tree_model_get_path(GTK_TREE_MODEL(TreeStore), @iter), NULL, False, 0, 0)
					End If
				End If
			End If
	End Sub
	
	Private Property TreeListView.OwnerData As Boolean
		Return FOwnerData
	End Property
	
	Private Property TreeListView.OwnerData(Value As Boolean)
		FOwnerData = Value
	End Property
	
	Private Property TreeListView.OwnerDraw As Boolean
		Return FOwnerDraw
	End Property
	
	Private Property TreeListView.OwnerDraw(Value As Boolean)
		FOwnerDraw = Value
	End Property
	
	Private Property TreeListView.ColumnHeaderHidden As Boolean
		Return FColumnHeaderHidden
	End Property
	
	Private Property TreeListView.ColumnHeaderHidden(Value As Boolean)
		FColumnHeaderHidden = Value
			gtk_tree_view_set_headers_visible(GTK_TREE_VIEW(widget), Not Value)
	End Property
	
	Private Property TreeListView.GridLines As Boolean
		Return FGridLines
	End Property
	
	Private Property TreeListView.GridLines(Value As Boolean)
		FGridLines = Value
			gtk_tree_view_set_grid_lines(GTK_TREE_VIEW(widget), IIf(Value, GTK_TREE_VIEW_GRID_LINES_BOTH, GTK_TREE_VIEW_GRID_LINES_NONE))
	End Property
	
	Private Property TreeListView.EditLabels As Boolean
		Return FEditLabels
	End Property
	
	Private Property TreeListView.EditLabels(Value As Boolean)
		FEditLabels = Value
			'				Columns.Column(0)->Editable = Value
	End Property
	
	Private Property TreeListView.MultiSelect As Boolean
		Return FMultiSelect
	End Property
	
	Private Property TreeListView.MultiSelect(Value As Boolean)
		FMultiSelect = Value
	End Property
	
	Private Sub TreeListView.ChangeLVExStyle(iStyle As Integer, Value As Boolean)
	End Sub
	
	Private Property TreeListView.SingleClickActivate As Boolean
		Return FSingleClickActivate
	End Property
	
	Private Property TreeListView.SingleClickActivate(Value As Boolean)
		FSingleClickActivate = Value
				gtk_tree_view_set_activate_on_single_click(GTK_TREE_VIEW(widget), Value)
	End Property
	
	Private Property TreeListView.SelectedItem As TreeListViewItem Ptr
			Dim As GtkTreeIter iter
			If gtk_tree_selection_get_selected(TreeSelection, NULL, @iter) Then
				Return Nodes.FindByIterUser_Data(iter.user_data)
			End If
		Return 0
	End Property
	
	Private Property TreeListView.SelectedItemIndex As Integer
			Dim As GtkTreeIter iter
			If gtk_tree_selection_get_selected(TreeSelection, NULL, @iter) Then
				Dim As TreeListViewItem Ptr lvi = Nodes.FindByIterUser_Data(iter.user_data)
				If lvi <> 0 Then Return lvi->Index
			End If
		Return -1
	End Property
	
	Private Property TreeListView.SelectedItemIndex(Value As Integer)
			If TreeSelection Then
				If Value = -1 Then
					gtk_tree_selection_unselect_all(TreeSelection)
				ElseIf Value > -1 AndAlso Value < Nodes.Count Then
					gtk_tree_selection_select_iter(TreeSelection, @Nodes.Item(Value)->TreeIter)
					gtk_tree_view_scroll_to_cell(GTK_TREE_VIEW(widget), gtk_tree_model_get_path(GTK_TREE_MODEL(TreeStore), @Nodes.Item(Value)->TreeIter), NULL, False, 0, 0)
				End If
			End If
	End Property
	
	Private Property TreeListView.SelectedItem(Value As TreeListViewItem Ptr)
		Value->SelectItem
	End Property
	
	Private Property TreeListView.SelectedColumn As TreeListViewColumn Ptr
		Return 0
	End Property
	
	
	Private Property TreeListView.SortColumn As TreeListViewColumn Ptr
		Return FSortColumn
	End Property
	
	Private Property TreeListView.SortColumn(Value As TreeListViewColumn Ptr)
		FSortColumn = Value
	End Property
	
	Private Property TreeListView.SortOrder As SortStyle
		Return FSortStyle
	End Property
	
	Private Property TreeListView.SortOrder(Value As SortStyle)
		FSortStyle = Value
	End Property
	
	Private Sub TreeListView.Sort
		
	End Sub
	
	Private Property TreeListView.SelectedColumn(Value As TreeListViewColumn Ptr)
	End Property
	
	Private Property TreeListView.ShowHint As Boolean
		Return FShowHint
	End Property
	
	Private Property TreeListView.ShowHint(Value As Boolean)
		FShowHint = Value
	End Property
	
	Private Sub TreeListView.WndProc(ByRef Message As Message)
	End Sub
	
	
	Private Sub TreeListView.ProcessMessage(ByRef Message As Message)
		'?message.msg, GetMessageName(message.msg)
			Dim As GdkEvent Ptr e = Message.Event
			Select Case Message.Event->type
			Case GDK_MAP
				Init
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	
	Private Operator TreeListView.Cast As Control Ptr
		Return @This
	End Operator
	
		Private Sub TreeListView.TreeListView_RowActivated(tree_view As GtkTreeView Ptr, path As GtkTreePath Ptr, column As GtkTreeViewColumn Ptr, user_data As Any Ptr)
			Dim As TreeListView Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeModel Ptr model
				Dim As GtkTreeIter iter
				model = gtk_tree_view_get_model(tree_view)
				
				If gtk_tree_model_get_iter(model, @iter, path) Then
					If lv->OnItemActivate Then lv->OnItemActivate(*lv->Designer, *lv, lv->Nodes.FindByIterUser_Data(iter.user_data))
				End If
			End If
		End Sub
		
		Private Sub TreeListView.TreeListView_SelectionChanged(selection As GtkTreeSelection Ptr, user_data As Any Ptr)
			Dim As TreeListView Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeIter iter
				Dim As GtkTreeModel Ptr model
				If gtk_tree_selection_get_selected(selection, @model, @iter) Then
					If lv->OnSelectedItemChanged Then lv->OnSelectedItemChanged(*lv->Designer, *lv, lv->Nodes.FindByIterUser_Data(iter.user_data))
				End If
			End If
		End Sub
		
		Private Sub TreeListView.TreeListView_Map(widget As GtkWidget Ptr, user_data As Any Ptr)
			Dim As TreeListView Ptr lv = user_data
			lv->Init
		End Sub
		
		Private Function TreeListView.TreeListView_TestExpandRow(tree_view As GtkTreeView Ptr, iter As GtkTreeIter Ptr, path As GtkTreePath Ptr, user_data As Any Ptr) As Boolean
			Dim As TreeListView Ptr lv = user_data
			If lv Then
				Dim As GtkTreeModel Ptr model
				model = gtk_tree_view_get_model(tree_view)
				If lv->OnItemExpanding Then lv->OnItemExpanding(*lv->Designer, *lv, lv->Nodes.FindByIterUser_Data(iter->user_data))
			End If
			Return False
		End Function
		
	
	Private Sub TreeListView.CollapseAll
			gtk_tree_view_collapse_all(GTK_TREE_VIEW(widget))
	End Sub
	
	Private Sub TreeListView.ExpandAll
			gtk_tree_view_expand_all(GTK_TREE_VIEW(widget))
	End Sub
	
		Private Sub TreeListView.TreeListView_Scroll(self As GtkAdjustment Ptr, user_data As Any Ptr)
			Dim As TreeListView Ptr lv = user_data
			If lv->OnEndScroll Then lv->OnEndScroll(*lv->Designer, *lv)
		End Sub
	
	Private Constructor TreeListView
			TreeStore = gtk_tree_store_new(1, G_TYPE_STRING)
			scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
			gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
			'widget = gtk_tree_view_new_with_model(gtk_tree_model(ListStore))
			widget = gtk_tree_view_new()
			gtk_container_add(GTK_CONTAINER(scrolledwidget), widget)
			TreeSelection = gtk_tree_view_get_selection(GTK_TREE_VIEW(widget))
				g_signal_connect(gtk_scrollable_get_hadjustment(GTK_SCROLLABLE(widget)), "value-changed", G_CALLBACK(@TreeListView_Scroll), @This)
				g_signal_connect(gtk_scrollable_get_vadjustment(GTK_SCROLLABLE(widget)), "value-changed", G_CALLBACK(@TreeListView_Scroll), @This)
			g_signal_connect(GTK_TREE_VIEW(widget), "map", G_CALLBACK(@TreeListView_Map), @This)
			g_signal_connect(GTK_TREE_VIEW(widget), "row-activated", G_CALLBACK(@TreeListView_RowActivated), @This)
			g_signal_connect(GTK_TREE_VIEW(widget), "test-expand-row", G_CALLBACK(@TreeListView_TestExpandRow), @This)
			g_signal_connect(G_OBJECT(TreeSelection), "changed", G_CALLBACK (@TreeListView_SelectionChanged), @This)
			gtk_tree_view_set_enable_tree_lines(GTK_TREE_VIEW(widget), True)
			gtk_tree_view_set_grid_lines(GTK_TREE_VIEW(widget), GTK_TREE_VIEW_GRID_LINES_BOTH)
			ColumnTypes = _New( GType[1])
			ColumnTypes[0] = G_TYPE_STRING
			This.RegisterClass "TreeListView", @This
		'Nodes.Clear
		Nodes.Parent = @This
		Columns.Parent = @This
		DoubleBuffered = True
		FEnabled = True
		FGridLines = True
		FVisible = True
		FTabIndex          = -1
		FTabStop = True
		With This
			.Child             = @This
			WLet(FClassName, "TreeListView")
			.Width             = 121
			.Height            = 121
		End With
	End Constructor
	
	Private Destructor TreeListView
		'Nodes.Clear
		'Columns.Clear
			If ColumnTypes Then _DeleteSquareBrackets( ColumnTypes)
	End Destructor
End Namespace
