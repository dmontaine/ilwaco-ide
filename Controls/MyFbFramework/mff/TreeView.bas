'################################################################################
'#  TreeView.bi                                                                 #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov(2018-2019)  Liu XiaLin                          #
'################################################################################

#include once "TreeView.bi"

Namespace My.Sys.Forms
	Private Sub TreeNode.SelectItem
			If Parent AndAlso Parent->Handle Then gtk_tree_selection_select_iter(gtk_tree_view_get_selection(GTK_TREE_VIEW(Parent->Handle)), @TreeIter)
	End Sub
	
	Private Sub TreeNode.Collapse
			If Parent AndAlso Parent->Handle AndAlso gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle)) Then
				Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle)), @TreeIter))
				gtk_tree_view_collapse_row(GTK_TREE_VIEW(Parent->Handle), TreePath)
				gtk_tree_path_free(TreePath)
			End If
	End Sub
	
	Private Sub TreeNode.Expand
			If Parent AndAlso Parent->Handle AndAlso gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle)) Then
				Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle)), @TreeIter))
				gtk_tree_view_expand_row(GTK_TREE_VIEW(Parent->Handle), TreePath, False)
				gtk_tree_path_free(TreePath)
			End If
	End Sub
	
	Private Function TreeNode.IsExpanded As Boolean
			If Parent AndAlso Parent->Handle AndAlso gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle)) Then
				Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle)), @TreeIter))
				Var bResult = gtk_tree_view_row_expanded(GTK_TREE_VIEW(Parent->Handle), TreePath)
				gtk_tree_path_free(TreePath)
				Return bResult
			End If
		Return False
	End Function
	
	Private Property TreeNode.Bold As Boolean
			Return FBold
		Return FBold
	End Property
	
	Private Property TreeNode.Bold(Value As Boolean)
		FBold = Value
	End Property
	
	Private Function TreeNode.Index As Integer
		If FParentNode <> 0 Then
			Return FParentNode->Nodes.IndexOf(@This)
		ElseIf Parent <> 0 Then
			Return Cast(TreeView Ptr, Parent)->Nodes.IndexOf(@This)
		Else
			Return -1
		End If
	End Function
	
	Private Function TreeNode.ToString ByRef As WString
		Return This.Name
	End Function
	
	Private Property TreeNode.Text ByRef As WString
	Static EmptyWString As WString * 1
		If FText > 0 Then Return *FText Else Return EmptyWString
	End Property
	
	Private Property TreeNode.Text(ByRef Value As WString)
		WLet(FText, Value)
			If Parent AndAlso gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle)) Then
				gtk_tree_store_set(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle))), @TreeIter, 1, ToUtf8(Value), -1)
			End If
	End Property
	
	Private Property TreeNode.IsUpdated As Boolean
		Return FIsUpdated
	End Property
	
	Private Property TreeNode.IsUpdated(Value As Boolean)
		FIsUpdated = Value
	End Property
	
	Private Property TreeNode.Checked As Boolean
		Return FChecked
	End Property
	
	Private Property TreeNode.Checked(Value As Boolean)
		FChecked = Value
	End Property
	
	Private Property TreeNode.Hint ByRef As WString
	Static EmptyWString As WString * 1
		If FHint > 0 Then Return *FHint Else Return EmptyWString
	End Property
	
	Private Property TreeNode.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	Private Property TreeNode.Name ByRef As WString
	Static EmptyWString As WString * 1
		If FName > 0 Then Return *FName Else Return EmptyWString
	End Property
	
	Private Property TreeNode.Name(ByRef Value As WString)
		WLet(FName, Value)
	End Property
	
	Private Property TreeNode.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property TreeNode.ImageIndex(Value As Integer)
		FImageIndex = Value
			If Parent AndAlso Cast(TreeView Ptr, Parent)->Images AndAlso gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle)) Then
				gtk_tree_store_set(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle))), @TreeIter, 0, ToUtf8(Cast(TreeView Ptr, Parent)->Images->Items.Get(FImageIndex)), -1)
			End If
	End Property
	
	Private Property TreeNode.ImageKey ByRef As WString
	Static EmptyWString As WString * 1
		If FImageKey > 0 Then Return *FImageKey Else Return EmptyWString
	End Property
	
	Private Property TreeNode.ImageKey(ByRef Value As WString)
		If FImageKey = 0 OrElse Value <> *FImageKey Then
			WLet(FImageKey, Value)
			If Parent AndAlso Parent->Handle AndAlso Cast(TreeView Ptr, Parent)->Images Then
				FImageIndex = Cast(TreeView Ptr, Parent)->Images->IndexOf(*FImageKey)
					If gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle)) Then
						gtk_tree_store_set(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle))), @TreeIter, 0, ToUtf8(Cast(TreeView Ptr, Parent)->Images->Items.Get(FImageIndex)), -1)
					End If
			End If
		End If
	End Property
	
	Private Property TreeNode.SelectedImageIndex As Integer
		Return FSelectedImageIndex
	End Property
	
	Private Property TreeNode.SelectedImageIndex(Value As Integer)
		FSelectedImageIndex = Value
		If Parent AndAlso Parent->Handle Then
				If CInt(Cast(TreeView Ptr, Parent)->SelectedImages) AndAlso CInt(Cast(TreeView Ptr, Parent)->SelectedNode = @This) AndAlso CInt(gtk_tree_view_get_model(gtk_tree_view(Parent->Handle))) Then
					gtk_tree_store_set(gtk_tree_store(gtk_tree_view_get_model(gtk_tree_view(Parent->Handle))), @TreeIter, 0, ToUtf8(Cast(TreeView Ptr, Parent)->SelectedImages->Items.Get(FSelectedImageIndex)), -1)
				End If
		End If
	End Property
	
	Private Property TreeNode.ParentNode As TreeNode Ptr
		Return FParentNode
	End Property
	
	Private Property TreeNode.ParentNode(Value As TreeNode Ptr)
		FParentNode = Value
	End Property
	
	Private Property TreeNode.SelectedImageKey ByRef As WString
	Static EmptyWString As WString * 1
		If FSelectedImageKey > 0 Then Return *FSelectedImageKey Else Return EmptyWString
	End Property
	
	Private Property TreeNode.SelectedImageKey(ByRef Value As WString)
		WLet(FSelectedImageKey, Value)
		If Parent AndAlso Parent->Handle AndAlso Cast(TreeView Ptr, Parent)->SelectedImages Then
			FSelectedImageIndex = Cast(TreeView Ptr, Parent)->SelectedImages->IndexOf(*FSelectedImageKey)
				If CInt(Cast(TreeView Ptr, Parent)->SelectedNode = @This) AndAlso CInt(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle))) Then
					gtk_tree_store_set(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle))), @TreeIter, 0, ToUtf8(Cast(TreeView Ptr, Parent)->SelectedImages->Items.Get(FSelectedImageIndex)), -1)
				End If
		End If
	End Property
	
	Private Property TreeNode.Visible As Boolean
		Return FVisible
	End Property
	
	Private Sub TreeNode.AddItems(Node As TreeNode Ptr)
		Dim As Integer iIndex
		Dim As TreeNodeCollection Ptr pNodes
		If Node->ParentNode <> 0 Then
			pNodes = @(Node->ParentNode->Nodes)
		Else
			pNodes = @(QTreeView(Node->Parent).Nodes)
		End If
			For i As Integer = 0 To Node->Index - 1
				If pNodes->Item(i)->Visible Then
					iIndex = iIndex + 1
				End If
			Next
			If Node->Parent AndAlso Node->Parent->Handle AndAlso gtk_tree_view_get_model(GTK_TREE_VIEW(Node->Parent->Handle)) Then
				If Node->ParentNode Then
					gtk_tree_store_insert(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Node->Parent->Handle))), @Node->TreeIter, @Node->ParentNode->TreeIter, iIndex)
				Else
					gtk_tree_store_insert(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Node->Parent->Handle))), @Node->TreeIter, NULL, iIndex)
				End If
				gtk_tree_store_set(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Node->Parent->Handle))), @Node->TreeIter, 1, ToUtf8(WGet(Node->FText)), -1)
				Node->ImageIndex = Node->ImageIndex
				For j As Integer = 0 To Node->Nodes.Count - 1
					If Node->Nodes.Item(j)->Visible Then AddItems Node->Nodes.Item(j)
				Next
			End If
	End Sub
	
	Private Property TreeNode.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Parent Then
				With This
					If Value Then
						AddItems @This
					Else
							If Parent AndAlso Parent->Handle Then
								If GTK_IS_TREE_VIEW(Parent->Handle) Then
									gtk_tree_store_remove(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle))), @This.TreeIter)
									This.TreeIter.user_data = 0
								End If
							End If
					End If
				End With
			End If
		End If
	End Property
	
	Private Operator TreeNode.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor TreeNode
		Nodes.Clear
		Nodes.Parent = Parent
		Nodes.ParentNode = @This
		Text = ""
		FVisible    = 1
		FImageIndex = -1
		FSelectedImageIndex = -1
	End Constructor
	
	Private Function TreeNode.IsDisposed As Boolean
		Return FIsDisposed
	End Function
	
	Private Destructor TreeNode
		Nodes.Clear
		FIsDisposed = True
			If Parent AndAlso Parent->Handle Then
				If GTK_IS_TREE_VIEW(Parent->Handle) Then
					gtk_tree_store_remove(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle))), @This.TreeIter)
					This.TreeIter.user_data = 0
				End If
			End If
		If FHint Then _Deallocate(FHint)
		If FName Then _Deallocate(FName)
		If FText Then _Deallocate(FText)
		If FSelectedImageKey Then _Deallocate(FSelectedImageKey)
		If FImageKey Then _Deallocate(FImageKey)
	End Destructor
	
	Private Constructor TreeNodeCollection
		This.Clear
	End Constructor
	
	Private Destructor TreeNodeCollection
		This.Clear
	End Destructor
	
		Private Function TreeNodeCollection.FindByIterUser_Data(User_Data As Any Ptr) As TreeNode Ptr
			If ParentNode AndAlso ParentNode->TreeIter.user_data = User_Data Then Return ParentNode
			For i As Integer = 0 To Count - 1
				PNode = Item(i)->Nodes.FindByIterUser_Data(User_Data)
				If PNode <> 0 Then Return PNode
			Next i
			Return 0
		End Function
	
	Private Property TreeNodeCollection.Count As Integer
		Return FNodes.Count
	End Property
	
	Private Property TreeNodeCollection.Count(Value As Integer)
	End Property
	
	Private Property TreeNodeCollection.Item(Index As Integer) As TreeNode Ptr
		If Index >= 0 AndAlso Index < FNodes.Count Then
			Return FNodes.Items[Index]
		End If
	End Property
	
	Private Property TreeNodeCollection.Item(Index As Integer, Value As TreeNode Ptr)
		If Index >= 0 AndAlso Index < FNodes.Count Then
			FNodes.Items[Index] = Value 'David Change
		End If
	End Property
	
	Private Function TreeNodeCollection.Add(ByRef iText As WString = "", ByRef iKey As WString = "", ByRef iHint As WString = "", iImageIndex As Integer = -1, iSelectedImageIndex As Integer = -1, bSorted As Boolean = False) As PTreeNode
		Dim PNode As PTreeNode
		PNode = _New( TreeNode)
		PNode->FDynamic = True
		Dim iIndex As Integer = -1
		If Cast(TreeView Ptr, Parent)->Sorted Or bSorted Then
			For i As Integer = 0 To FNodes.Count - 1
				If LCase(Item(i)->Text) > LCase(iText) Then
					iIndex = i
					Exit For
				End If
			Next
		End If
		If iIndex = -1 Then FNodes.Add PNode Else FNodes.Insert iIndex, PNode
		With *PNode
			.Text         = iText
			.Name         = iKey
			.ImageIndex     = iImageIndex
			.SelectedImageIndex     = iSelectedImageIndex
			.Hint           = iHint
			.Parent         = Parent
			.Nodes.Parent         = Parent
			.ParentNode        = Cast(TreeNode Ptr, ParentNode)
				If Parent AndAlso Parent->Handle AndAlso gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle)) AndAlso (FParentNode = 0 OrElse FParentNode->TreeIter.user_data <> 0) Then
					If .ParentNode Then
						gtk_tree_store_insert(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle))), @.TreeIter, @.ParentNode->TreeIter, iIndex)
					Else
						gtk_tree_store_insert(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle))), @.TreeIter, NULL, iIndex)
					End If
					gtk_tree_store_set(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle))), @.TreeIter, 1, ToUtf8(iText), -1)
					.ImageIndex = .ImageIndex
				End If
		End With
		Return PNode
	End Function
	
	Private Function TreeNodeCollection.Add(ByRef iText As WString = "", ByRef iKey As WString = "", ByRef iHint As WString = "", ByRef iImageKey As WString, ByRef iSelectedImageKey As WString, bSorted As Boolean = False) As PTreeNode
		Dim As TreeNode Ptr PNode
		If Parent AndAlso Cast(TreeView Ptr, Parent)->Images AndAlso Cast(TreeView Ptr, Parent)->SelectedImages Then
			PNode = This.Add(iText, iKey, iHint, Cast(TreeView Ptr, Parent)->Images->IndexOf(iImageKey), Cast(TreeView Ptr, Parent)->SelectedImages->IndexOf(iSelectedImageKey), bSorted)
		Else
			PNode = This.Add(iText, iKey, iHint, -1, -1, bSorted)
		End If
		If PNode Then PNode->ImageKey = iImageKey: PNode->SelectedImageKey = iSelectedImageKey
		Return PNode
	End Function
	
	Private Function TreeNodeCollection.Insert(Index As Integer, ByRef iText As WString = "", ByRef iKey As WString = "", ByRef iHint As WString = "", iImageIndex As Integer = -1, iSelectedImageIndex As Integer = -1) As PTreeNode
		Dim PNode As PTreeNode
		PNode = _New( TreeNode)
		PNode->FDynamic = True
		FNodes.Insert Index, PNode
		With *PNode
			.Text         = iText
			.Name         = iKey
			.ImageIndex     = iImageIndex
			.SelectedImageIndex     = iSelectedImageIndex
			.Hint           = iHint
			.Parent         = Parent
			.Nodes.Parent         = Parent
			.ParentNode        = ParentNode
				If Parent AndAlso gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle)) Then
					If .ParentNode Then
						gtk_tree_store_insert(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle))), @.TreeIter, @.ParentNode->TreeIter, Index)
					Else
						gtk_tree_store_insert(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle))), @.TreeIter, NULL, Index)
					End If
					gtk_tree_store_set(GTK_TREE_STORE(gtk_tree_view_get_model(GTK_TREE_VIEW(Parent->Handle))), @.TreeIter, 1, ToUtf8(iText), -1)
				End If
		End With
		Return PNode
	End Function
	
	Private Function TreeNodeCollection.Insert(Index As Integer, ByRef iText As WString = "", ByRef iKey As WString = "", ByRef iHint As WString = "", ByRef iImageKey As WString, ByRef iSelectedImageKey As WString) As PTreeNode
		Dim PNode As PTreeNode
		If Parent AndAlso Cast(TreeView Ptr, Parent)->Images AndAlso Cast(TreeView Ptr, Parent)->SelectedImages Then
			PNode = This.Insert(Index, iText, iKey, iHint, Cast(TreeView Ptr, Parent)->Images->IndexOf(iImageKey), Cast(TreeView Ptr, Parent)->SelectedImages->IndexOf(iSelectedImageKey))
		Else
			PNode = This.Insert(Index, iText, iKey, iHint, -1, -1)
		End If
		If PNode Then PNode->ImageKey         = iImageKey: PNode->SelectedImageKey         = iSelectedImageKey
		Return PNode
	End Function
	
	Private Sub TreeNodeCollection.Remove(Index As Integer)
		'				gtk_tree_store_remove(Cast(TreeView Ptr, Parent)->TreeStore, @This.Item(Index)->TreeIter)
		'				TreeView_DeleteItem(Parent->Handle, Item(Index)->Handle)
		_Delete(Item(Index))
		FNodes.Remove Index
	End Sub
	Private Sub TreeNode.EditLabel
	End Sub
	
	Private Function TreeNodeCollection.IndexOf(ByRef FNode As TreeNode Ptr) As Integer
		Return FNodes.IndexOf(FNode)
	End Function
	
	Private Function TreeNodeCollection.IndexOf(ByRef Text As WString) As Integer
		For i As Integer = 0 To Count - 1
			If Item(i)->Text = Text Then Return i
		Next i
		Return -1
	End Function
	
	Private Function TreeNodeCollection.IndexOfKey(ByRef Key As WString) As Integer
		For i As Integer = 0 To Count - 1
			If Item(i)->Name = Key Then Return i
		Next i
		Return -1
	End Function
	
	Private Function TreeNodeCollection.Contains(ByRef FNode As TreeNode Ptr) As Boolean
		Return IndexOf(FNode) <> -1
	End Function
	
	Private Function TreeNodeCollection.Contains(ByRef Text As WString) As Boolean
		Return IndexOf(Text) <> -1
	End Function
	
	Private Function TreeNodeCollection.ContainsKey(ByRef Key As WString) As Boolean
		Return IndexOfKey(Key) <> -1
	End Function
	
	Private Property TreeNodeCollection.ParentNode As PTreeNode
		Return FParentNode
	End Property
	
	Private Property TreeNodeCollection.ParentNode(Value As PTreeNode)
		FParentNode = Value
	End Property
	
	Private Sub TreeNodeCollection.Clear
		For i As Integer = FNodes.Count - 1 To 0 Step -1
			If Cast(TreeNode Ptr, FNodes.Items[i])->FDynamic Then _Delete( Cast(TreeNode Ptr, FNodes.Items[i]))
		Next i
		'				Remove i
		FNodes.Clear
	End Sub
	
	#ifndef ReadProperty_Off
		Private Function TreeView.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "editlabels": Return @FEditLabels
			Case "hideselection": Return @FHideSelection
			Case "images": Return Images
			Case "sorted": Return @FSorted
			Case "showhint": Return @FShowHint
			Case "selectedimages": Return SelectedImages
			Case "selectednode": Return SelectedNode
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function TreeView.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "editlabels": EditLabels = QBoolean(Value)
				Case "hideselection": HideSelection = QBoolean(Value)
				Case "images": Images = Value
				Case "sorted": Sorted = QBoolean(Value)
				Case "showhint": ShowHint = QBoolean(Value)
				Case "selectedimages": SelectedImages = Value
				Case "selectednode": SelectedNode = Value
				Case "tabindex": TabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property TreeView.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property TreeView.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property TreeView.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property TreeView.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	
	Private Sub TreeView.CollapseAll
			gtk_tree_view_collapse_all(GTK_TREE_VIEW(widget))
	End Sub
	
	Private Sub TreeView.ExpandAll
			gtk_tree_view_expand_all(GTK_TREE_VIEW(widget))
	End Sub
	
	Private Property TreeView.HideSelection As Boolean
		Return FHideSelection
	End Property
	
	Private Property TreeView.HideSelection(Value As Boolean)
		FHideSelection = Value
	End Property
	
	Private Property TreeView.EditLabels As Boolean
		Return FEditLabels
	End Property
	
	Private Property TreeView.EditLabels(Value As Boolean)
		FEditLabels = Value
			Dim As GValue bValue '= G_VALUE_INIT
			g_value_init_(@bValue, G_TYPE_BOOLEAN)
			g_value_set_boolean(@bValue, Value)
			g_object_set_property(G_OBJECT(rendertext), "editable", @bValue)
			g_object_set_property(G_OBJECT(rendertext), "editable-set", @bValue)
			g_value_unset(@bValue)
	End Property
	
	Private Property TreeView.SelectedNode As TreeNode Ptr
			Dim As GtkTreeIter iter
			If gtk_tree_selection_get_selected(TreeSelection, NULL, @iter) Then
				Return Nodes.FindByIterUser_Data(iter.user_data)
			End If
		Return 0
	End Property
	
	Private Property TreeView.SelectedNode(Value As TreeNode Ptr)
			If TreeSelection Then gtk_tree_selection_select_iter(TreeSelection, @Value->TreeIter)
	End Property
	
	Private Function TreeView.DraggedNode As TreeNode Ptr
			Dim As GtkTreePath Ptr path
			Dim As GtkTreeViewDropPosition Pos1
			Dim As GtkTreeIter iter
			gtk_tree_view_get_drag_dest_row(gtk_tree_view(widget), @path, @Pos1)
			If path <> 0 AndAlso gtk_tree_model_get_iter(gtk_tree_model(TreeStore), @iter, path) Then
				Return Nodes.FindByIterUser_Data(iter.User_Data)
			End If
		Return 0
	End Function
	
	Private Property TreeView.ShowHint As Boolean
		Return FShowHint
	End Property
	
	Private Property TreeView.ShowHint(Value As Boolean)
		FShowHint = Value
	End Property
	
	Private Property TreeView.Sorted As Boolean
		Return FSorted
	End Property
	
	Private Property TreeView.Sorted(Value As Boolean)
		FSorted = Value
			If Value Then
				gtk_tree_sortable_set_sort_column_id(GTK_TREE_SORTABLE(TreeStore), GTK_TREE_SORTABLE_DEFAULT_SORT_COLUMN_ID, GTK_SORT_ASCENDING)
			Else
				gtk_tree_sortable_set_sort_column_id(GTK_TREE_SORTABLE(TreeStore), GTK_TREE_SORTABLE_UNSORTED_SORT_COLUMN_ID, GTK_SORT_ASCENDING)
			End If
	End Property
	
	
	
	Private Sub TreeView.ProcessMessage(ByRef Message As Message)
			Dim As GdkEvent Ptr e = Message.Event
			Select Case Message.Event->type
			Case GDK_BUTTON_RELEASE
				If SelectedNode <> 0 Then
					If OnNodeClick Then OnNodeClick(*Designer, This, *SelectedNode)
				End If
				Case GDK_2BUTTON_PRESS, GDK_DOUBLE_BUTTON_PRESS
				If SelectedNode <> 0 Then
					If OnNodeDblClick Then OnNodeDblClick(*Designer, This, *SelectedNode)
				End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	
	Private Operator TreeView.Cast As Control Ptr
		Return @This
	End Operator
	
		Private Sub TreeView.TreeView_RowActivated(tree_view As GtkTreeView Ptr, path As GtkTreePath Ptr, column As GtkTreeViewColumn Ptr, user_data As Any Ptr)
			Dim As TreeView Ptr tv = Cast(Any Ptr, user_data)
			If tv Then
				Dim As GtkTreeModel Ptr model
				Dim As GtkTreeIter iter
				model = gtk_tree_view_get_model(tree_view)
				If gtk_tree_model_get_iter(model, @iter, path) Then
					If tv->OnNodeActivate Then tv->OnNodeActivate(*tv->Designer, *tv, *tv->Nodes.FindByIterUser_Data(iter.user_data))
				End If
			End If
		End Sub
		
		Private Sub TreeView.TreeView_SelectionChanged(selection As GtkTreeSelection Ptr, user_data As Any Ptr)
			Dim As TreeView Ptr tv = Cast(Any Ptr, user_data)
			If tv Then
				Dim As GtkTreeIter iter
				Dim As GtkTreeModel Ptr model
				If GTK_IS_TREE_STORE(tv->TreeStore) Then
					If gtk_tree_selection_get_selected(selection, @model, @iter) Then
						Dim As TreeNode Ptr SelNode = tv->Nodes.FindByIterUser_Data(iter.user_data)
						If tv->PrevNode <> 0 AndAlso tv->PrevNode->IsDisposed = False AndAlso tv->PrevNode <> SelNode Then
							Dim bCancel As Boolean
							If tv->OnSelChanging Then tv->OnSelChanging(*tv->Designer, *tv, *tv->PrevNode, bCancel)
							If bCancel Then
								tv->SelectedNode = tv->PrevNode
								Exit Sub
							End If
							'									gtk_tree_store_set(tv->TreeStore, @tv->PrevNode->TreeIter, 0, ToUTF8(tv->Images->Items.Get(tv->PrevNode->ImageKey)), -1)
							'								ElseIf tv->PrevNode->ImageIndex > -1 Then
							'									gtk_tree_store_set(tv->TreeStore, @tv->PrevNode->TreeIter, 0, ToUTF8(tv->Images->Items.Get(tv->PrevNode->ImageIndex)), -1)
						End If
						'								gtk_tree_store_set(tv->TreeStore, @SelNode->TreeIter, 0, ToUTF8(tv->SelectedImages->Items.Get(SelNode->SelectedImageKey)), -1)
						'							ElseIf SelNode->SelectedImageIndex > -1 Then
						'								gtk_tree_store_set(tv->TreeStore, @SelNode->TreeIter, 0, ToUTF8(tv->SelectedImages->Items.Get(SelNode->SelectedImageIndex)), -1)
						If tv->OnSelChanged Then tv->OnSelChanged(*tv->Designer, *tv, *SelNode)
						tv->PrevNode = SelNode
					End If
				End If
			End If
		End Sub
		
		Private Function TreeView.TreeView_ButtonRelease(widget As GtkWidget Ptr, e As GdkEvent Ptr, user_data As Any Ptr) As Boolean
			Dim As TreeView Ptr tv = user_data
			Dim Message As Message
			If e->button.button = 3 AndAlso tv->ContextMenu Then
				If tv->ContextMenu->Handle Then
					Message = Type(tv, widget, e, False)
					tv->ContextMenu->Popup(e->button.x, e->button.y, @Message)
				End If
			End If
			Return False
		End Function
		
		Private Function TreeView.TreeView_QueryTooltip(widget As GtkWidget Ptr, x As gint, y As gint, keyboard_mode As Boolean, tooltip As GtkTooltip Ptr, user_data As Any Ptr) As Boolean
			Dim As TreeView Ptr tv = user_data
			Dim As GtkTreeIter iter
			Dim As GtkTreePath Ptr path
			Dim As GtkTreeModel Ptr model
			If Not gtk_tree_view_get_tooltip_context(GTK_TREE_VIEW(widget), @x, @y, keyboard_mode, @model, @path, @iter) Then
				Return False
			End If
			Dim As TreeNode Ptr tn = tv->Nodes.FindByIterUser_Data(iter.user_data)
			gtk_tooltip_set_text(tooltip, ToUtf8(tn->Hint))
			gtk_tree_view_set_tooltip_row(GTK_TREE_VIEW(widget), tooltip, path)
			Return True
		End Function
		
		Private Sub TreeView.Cell_Editing(cell As GtkCellRenderer Ptr, editable As GtkCellEditable Ptr, path As Const gchar Ptr, user_data As Any Ptr)
			Dim As TreeView Ptr tv = user_data
			Dim As GtkTreeIter iter
			Dim As GtkTreeModel Ptr model = gtk_tree_view_get_model(GTK_TREE_VIEW(tv->Handle))
			If gtk_tree_model_get_iter(model, @iter, gtk_tree_path_new_from_string(path)) Then
				Dim As TreeNode Ptr tn = tv->Nodes.FindByIterUser_Data(iter.user_data)
				Dim As Boolean bCancel
				If tv->OnBeforeLabelEdit Then tv->OnBeforeLabelEdit(*tv->Designer, *tv, *tn, tn->Text, bCancel)
				If bCancel Then
					gtk_cell_renderer_stop_editing(cell, True)
				End If
			End If
		End Sub
		
		Private Sub TreeView.Cell_Edited(renderer As GtkCellRendererText Ptr, path As gchar Ptr, new_text As gchar Ptr, user_data As Any Ptr)
			Dim As TreeView Ptr tv = user_data
			Dim As GtkTreeIter iter
			Dim As GtkTreeModel Ptr model = gtk_tree_view_get_model(GTK_TREE_VIEW(tv->Handle))
			If gtk_tree_model_get_iter(model, @iter, gtk_tree_path_new_from_string(path)) Then
				Dim As TreeNode Ptr tn = tv->Nodes.FindByIterUser_Data(iter.user_data)
				Dim As Boolean bCancel
				If tv->OnAfterLabelEdit Then tv->OnAfterLabelEdit(*tv->Designer, *tv, *tn, *new_text, bCancel)
				If Not bCancel Then
					gtk_tree_store_set(GTK_TREE_STORE(model), @iter, 1, ToUtf8(*new_text), -1)
				End If
			End If
		End Sub
		
		Private Function TreeView.TestCollapseRow(tree_view As GtkTreeView Ptr, iter As GtkTreeIter Ptr, path As GtkTreePath Ptr, user_data As Any Ptr) As Boolean
			Dim As TreeView Ptr tv = user_data
			If tv Then
				Dim bCancel As Boolean
				If tv->OnNodeCollapsing Then tv->OnNodeCollapsing(*tv->Designer, *tv, *tv->Nodes.FindByIterUser_Data(iter->user_data), bCancel)
				If bCancel Then Return True
			End If
			Return False
		End Function
		
		Private Function TreeView.TestExpandRow(tree_view As GtkTreeView Ptr, iter As GtkTreeIter Ptr, path As GtkTreePath Ptr, user_data As Any Ptr) As Boolean
			Dim As TreeView Ptr tv = user_data
			If tv Then
				Dim bCancel As Boolean
				If tv->OnNodeExpanding Then tv->OnNodeExpanding(*tv->Designer, *tv, *tv->Nodes.FindByIterUser_Data(iter->user_data), bCancel)
				If bCancel Then Return True
			End If
			Return False
		End Function
		
		Private Function TreeView.RowCollapsed(tree_view As GtkTreeView Ptr, iter As GtkTreeIter Ptr, path As GtkTreePath Ptr, user_data As Any Ptr) As Boolean
			Dim As TreeView Ptr tv = user_data
			If tv Then
				If tv->OnNodeCollapsed Then tv->OnNodeCollapsed(*tv->Designer, *tv, *tv->Nodes.FindByIterUser_Data(iter->user_data))
			End If
			Return False
		End Function
		
		Private Function TreeView.RowExpanded(tree_view As GtkTreeView Ptr, iter As GtkTreeIter Ptr, path As GtkTreePath Ptr, user_data As Any Ptr) As Boolean
			Dim As TreeView Ptr tv = user_data
			If tv Then
				If tv->OnNodeExpanded Then tv->OnNodeExpanded(*tv->Designer, *tv, *tv->Nodes.FindByIterUser_Data(iter->user_data))
			End If
			Return False
		End Function
	
	Private Constructor TreeView
		Nodes.Clear
		Nodes.Parent = @This
		FEnabled = True
		FVisible = True
		With This
			.Child             = @This
				Dim As GtkTreeViewColumn Ptr col = gtk_tree_view_column_new()
				Dim As GtkCellRenderer Ptr renderpixbuf = gtk_cell_renderer_pixbuf_new()
				rendertext = gtk_cell_renderer_text_new()
				scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
				gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
				TreeStore = gtk_tree_store_new(2, G_TYPE_STRING, G_TYPE_STRING)
				widget = gtk_tree_view_new_with_model(GTK_TREE_MODEL(TreeStore))
				gtk_container_add(GTK_CONTAINER(scrolledwidget), widget)
				TreeSelection = gtk_tree_view_get_selection(GTK_TREE_VIEW(widget))
				
				gtk_tree_view_column_pack_start(col, renderpixbuf, False)
				gtk_tree_view_column_add_attribute(col, renderpixbuf, ToUtf8("icon_name"), 0)
				'gtk_tree_view_append_column(GTK_TREE_VIEW(widget), colpixbuf)
				
				gtk_tree_view_column_pack_start(col, rendertext, True)
				gtk_tree_view_column_add_attribute(col, rendertext, ToUtf8("text"), 1)
				gtk_tree_view_append_column(GTK_TREE_VIEW(widget), col)
				
				gtk_tree_view_set_headers_visible(GTK_TREE_VIEW(widget), False)
				gtk_tree_view_set_enable_tree_lines(GTK_TREE_VIEW(widget), True)
					gtk_widget_set_has_tooltip(widget, True)
				
				g_signal_connect(G_OBJECT(rendertext), "edited", G_CALLBACK(@Cell_Edited), @This)
				g_signal_connect(G_OBJECT(rendertext), "editing-started", G_CALLBACK(@Cell_Editing), @This)
				g_signal_connect(GTK_TREE_VIEW(widget), "button-release-event", G_CALLBACK(@TreeView_ButtonRelease), @This)
				g_signal_connect(widget, "row-activated", G_CALLBACK(@TreeView_RowActivated), @This)
				g_signal_connect(widget, "query-tooltip", G_CALLBACK(@TreeView_QueryTooltip), @This)
				g_signal_connect(G_OBJECT(TreeSelection), "changed", G_CALLBACK (@TreeView_SelectionChanged), @This)
				g_signal_connect(GTK_TREE_VIEW(widget), "test-collapse-row", G_CALLBACK(@TestCollapseRow), @This)
				g_signal_connect(GTK_TREE_VIEW(widget), "test-expand-row", G_CALLBACK(@TestExpandRow), @This)
				g_signal_connect(GTK_TREE_VIEW(widget), "row-collapsed", G_CALLBACK(@RowCollapsed), @This)
				g_signal_connect(GTK_TREE_VIEW(widget), "row-expanded", G_CALLBACK(@RowExpanded), @This)
				This.RegisterClass "TreeView", @This
			BorderStyle = BorderStyles.bsClient
			WLet(FClassName, "TreeView")
			FTabIndex          = -1
			FTabStop = True
			.Width             = 121
			.Height            = 121
		End With
	End Constructor
	
	Private Destructor TreeView
		Nodes.Clear
			
	End Destructor
End Namespace
