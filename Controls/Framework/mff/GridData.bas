'################################################################################
'#  GridData.bi                                                             #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov(2018-2019)  Liu XiaLin                          #
'################################################################################
#include once "GridData.bi"
#include once "Application.bi"
#include once "vbcompat.bi"

Namespace My.Sys.Forms
	
	Private Sub GridDataItem.Collapse
			If Parent AndAlso Parent->Handle AndAlso Cast(GridData Ptr, Parent)->TreeStore Then
				Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(GTK_TREE_MODEL(Cast(GridData Ptr, Parent)->TreeStore), @TreeIter))
				gtk_tree_view_collapse_row(GTK_TREE_VIEW(Parent->Handle), TreePath)
				gtk_tree_path_free(TreePath)
			End If
		FExpanded = False
	End Sub
	
	Private Sub GridDataItem.Expand
			If Parent AndAlso Parent->Handle AndAlso Cast(GridData Ptr, Parent)->TreeStore Then
				Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(GTK_TREE_MODEL(Cast(GridData Ptr, Parent)->TreeStore), @TreeIter))
				gtk_tree_view_expand_row(GTK_TREE_VIEW(Parent->Handle), TreePath, False)
				gtk_tree_path_free(TreePath)
			End If
		FExpanded = True
	End Sub
	
	Private Function GridDataItem.IsExpanded As Boolean
			If Parent AndAlso Parent->Handle AndAlso Cast(GridData Ptr, Parent)->TreeStore Then
				Dim As GtkTreePath Ptr TreePath = gtk_tree_path_new_from_string(gtk_tree_model_get_string_from_iter(GTK_TREE_MODEL(Cast(GridData Ptr, Parent)->TreeStore), @TreeIter))
				FExpanded = gtk_tree_view_row_expanded(GTK_TREE_VIEW(Parent->Handle), TreePath)
			End If
			Return FExpanded
	End Function
	
	Private Function GridDataItem.Index As Integer
		If FParentItem <> 0 Then
			Return FParentItem->Items.IndexOf(@This)
		ElseIf Parent <> 0 Then
			Return Cast(GridData Ptr, Parent)->ListItems.IndexOf(@This)
		Else
			Return -1
		End If
	End Function
	
	Private Sub GridDataItem.SelectItem
			If Parent AndAlso Cast(GridData Ptr, Parent)->TreeSelection Then
				gtk_tree_selection_select_iter(Cast(GridData Ptr, Parent)->TreeSelection, @TreeIter)
			End If
	End Sub
	
	Private Property GridDataItem.BackColor(iSubItem As Integer)As Integer
		If FSubItems.Count>0 AndAlso FSubItems.Count > iSubItem Then
			If mCellBackColor(iSubItem)<=0 Then mCellBackColor(iSubItem)=Parent->BackColor
			Return mCellBackColor(iSubItem)
		Else
			Return clWhite
		End If
	End Property
	Private Property GridDataItem.BackColor(iSubItem As Integer,Value As Integer)
		If FSubItems.Count > iSubItem Then mCellBackColor(iSubItem) = Value
	End Property
	
	Private Property GridDataItem.ForeColor(iSubItem As Integer)As Integer
		If FSubItems.Count > iSubItem Then
			If mCellForeColor(iSubItem)<=0 Then mCellForeColor(iSubItem)=clBlack
			Return mCellForeColor(iSubItem)
		Else
			Return clBlack
		End If
	End Property
	Private Property GridDataItem.ForeColor(iSubItem As Integer,Value As Integer)
		If FSubItems.Count > iSubItem Then mCellForeColor(iSubItem) = Value
	End Property
	
	Private Property GridDataItem.Text(iSubItem As Integer) ByRef As WString
		If FSubItems.Count > iSubItem Then
			Return FSubItems.Item(iSubItem)
		Else
			Return WStr("")
		End If
	End Property
	Private Property GridDataItem.Text(iSubItem As Integer, ByRef Value As WString)
		WLet(FText, Value)
		For i As Integer = FSubItems.Count To iSubItem
			FSubItems.Add ""
		Next
		FSubItems.Item(iSubItem) =Value
		If iSubItem=0 Then  'Init
			ReDim mCellBackColor(0 To FSubItems.Count)
			ReDim mCellForeColor(0 To FSubItems.Count)
		ElseIf UBound(mCellBackColor)< FSubItems.Count Then
			ReDim Preserve mCellBackColor(FSubItems.Count)
			ReDim Preserve mCellForeColor(FSubItems.Count)
		End If
		If Parent Then
				If Cast(GridData Ptr, Parent)->TreeStore Then
					gtk_tree_store_set (Cast(GridData Ptr, Parent)->TreeStore, @TreeIter, iSubItem + 1, ToUtf8(Value), -1)
				End If
		End If
	End Property
	
	Private Property GridDataItem.State As Integer
		Return FState
	End Property
	
	Private Property GridDataItem.State(Value As Integer)
		FState = Value
	End Property
	
	Private Property GridDataItem.Locked(Value As Boolean)
		FLocked = Value
	End Property
	Private Property GridDataItem.Locked As Boolean
		Return FLocked
	End Property
	
	Private Property GridDataItem.Indent As Integer
		Return FIndent
	End Property
	
	Private Property GridDataItem.Indent(Value As Integer)
		FIndent = Value
	End Property
	
	Private Property GridDataItem.Hint ByRef As WString
		Return WGet(FHint)
	End Property
	
	Private Property GridDataItem.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	Private Property GridDataItem.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property GridDataItem.ImageIndex(Value As Integer)
		If Value <> FImageIndex Then
			FImageIndex = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property GridDataItem.SelectedImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property GridDataItem.SelectedImageIndex(Value As Integer)
		If Value <> FSelectedImageIndex Then
			FSelectedImageIndex = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property GridDataItem.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property GridDataItem.ParentItem As GridDataItem Ptr
		Return FParentItem
	End Property
	
	Private Property GridDataItem.ParentItem(Value As GridDataItem Ptr)
		FParentItem = Value
	End Property
	
	Private Property GridDataItem.ImageKey ByRef As WString
		If FImageKey > 0 Then Return *FImageKey Else Return ""
	End Property
	
	Private Property GridDataItem.ImageKey(ByRef Value As WString)
		If FImageKey = 0 OrElse Value <> *FImageKey Then
			WLet(FImageKey, Value)
				If Parent AndAlso Parent->Handle Then
					gtk_tree_store_set (Cast(GridData Ptr, Parent)->TreeStore, @TreeIter, 0, ToUtf8(Value), -1)
				End If
		End If
	End Property
	
	Private Property GridDataItem.SelectedImageKey ByRef As WString
		If FSelectedImageKey > 0 Then Return *FSelectedImageKey Else Return ""
	End Property
	
	Private Property GridDataItem.SelectedImageKey(ByRef Value As WString)
		If FSelectedImageKey = 0 OrElse Value <> *FSelectedImageKey Then
			WLet(FSelectedImageKey, Value)
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property GridDataItem.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
		End If
	End Property
	
	Private Operator GridDataItem.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor GridDataItem
		Items.Clear
		Items.Parent = Parent
		Items.ParentItem = @This
		FHint = 0
		FText = 0
		FVisible    = 1
		Text(0)    = ""
		Hint       = ""
		FImageIndex = -1
		FSelectedImageIndex = -1
		FSmallImageIndex = -1
		ReDim mCellBackColor(0)
		ReDim mCellForeColor(0)
	End Constructor
	
	Private Destructor GridDataItem
		Items.Clear
		WDeAllocate(FHint)
		WDeAllocate(FText)
		WDeAllocate(FImageKey)
		WDeAllocate(FSelectedImageKey)
		WDeAllocate(FSmallImageKey)
		Erase mCellBackColor
		Erase mCellForeColor
	End Destructor
	
	Private Sub GridDataColumn.SelectItem
	End Sub
	
	Private Property GridDataColumn.Text ByRef As WString
		Return WGet(FText)
	End Property
	
	Private Property GridDataColumn.Text(ByRef Value As WString)
		WLet(FText, Value)
	End Property
	
	Private Property GridDataColumn.ColWidth As Integer
		Return FColWidth
	End Property
	
	Private Property GridDataColumn.ColWidth(Value As Integer)
		FColWidth = Value
				If This.Column Then gtk_tree_view_column_set_fixed_width(This.Column, Max(-1, Value))
	End Property
	
	Private Property GridDataColumn.ControlType As Integer
		If FControlType < 0 Or FControlType > CT_TextBox Then FControlType = CT_TextBox
		Return FControlType
	End Property
	
	Private Property GridDataColumn.ControlType(Value As Integer)
		If Value < 0 Or Value> CT_TextBox Then Value = CT_TextBox
		FControlType = Value
	End Property
	
	Private Property GridDataColumn.DataType As Integer
		If FDataType < 0 Or FDataType> DT_String Then FDataType = DT_String
		Return FDataType
	End Property
	Private Property GridDataColumn.DataType(Value As Integer)
		If Value < 0 Or Value > DT_String Then Value= DT_String
		FDataType = Value
	End Property
	
	Private Property GridDataColumn.Locked(Value As Boolean)
		FLocked = Value
	End Property
	
	Private Property GridDataColumn.Locked As Boolean
		Return FLocked
	End Property
	
	Private Property GridDataColumn.SortOrder(Value As SortStyle)
		FSortOrder = Value
	End Property
	
	Private Property GridDataColumn.SortOrder As SortStyle
		Return FSortOrder
	End Property
	
	Private Property GridDataColumn.MultiLine As Boolean
		Return FMultiLine
	End Property
	
	Private Property GridDataColumn.MultiLine(Value As Boolean)
		FMultiLine = Value
	End Property
	
	Private Property GridDataColumn.Format As ColumnFormat
		Return FFormat
	End Property
	
	Private Property GridDataColumn.Format(Value As ColumnFormat)
		FFormat = Value
	End Property
	
	Private Property GridDataColumn.FormatHeader As ColumnFormat
		Return FFormatHeader
	End Property
	
	Private Property GridDataColumn.FormatHeader(Value As ColumnFormat)
		FFormatHeader = Value
	End Property
	
	Private Property GridDataColumn.Hint ByRef As WString
		Return WGet(FHint)
	End Property
	
	Private Property GridDataColumn.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	Private Property GridDataColumn.GridEditComboItem ByRef As WString
		If FGridEditComboItem > 0 Then Return *FGridEditComboItem Else Return ""
	End Property
	
	Private Property GridDataColumn.GridEditComboItem(ByRef Value As WString)
		WLet(FGridEditComboItem, Value)
	End Property
	
	Private Property GridDataColumn.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property GridDataColumn.ImageIndex(Value As Integer)
		If Value <> FImageIndex Then
			FImageIndex = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property GridDataColumn.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property GridDataColumn.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_HIDEBUTTON, FCommandID, MakeLong(NOT FVisible, 0))
				End With
			End If
		End If
	End Property
	
	Private Operator GridDataColumn.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor GridDataColumn
		FHint = 0
		FText = 0
		FVisible    = 1
		Text    = ""
		Hint       = ""
		FImageIndex = -1
		FGridEditComboItem =0
	End Constructor
	
	Private Destructor GridDataColumn
		If FHint Then _Deallocate(FHint)
		If FText Then _Deallocate(FText)
		If FGridEditComboItem Then _Deallocate(FGridEditComboItem)
	End Destructor
	
	Private Property GridDataItems.Count As Integer
		Return FItems.Count
	End Property
	
	Private Property GridDataItems.Count(Value As Integer)
	End Property
	
	Private Property GridDataItems.Item(Index As Integer) As GridDataItem Ptr
		If Index >= 0 AndAlso Index < FItems.Count Then
			Return FItems.Items[Index]
		End If
	End Property
	
	Private Property GridDataItems.Item(Index As Integer, Value As GridDataItem Ptr)
		If Index >= 0 AndAlso Index < FItems.Count Then
			FItems.Items[Index] = Value
		End If
	End Property
	
		Private Function GridDataItems.FindByIterUser_Data(User_Data As Any Ptr) As GridDataItem Ptr
			If ParentItem AndAlso ParentItem->TreeIter.user_data = User_Data Then Return ParentItem
			For i As Integer = 0 To FItems.Count - 1
				PItem = Item(i)->Items.FindByIterUser_Data(User_Data)
				If PItem <> 0 Then Return PItem
			Next i
			Return 0
		End Function
	
	Private Property GridDataItems.ParentItem As GridDataItem Ptr
		Return FParentItem
	End Property
	
	Private Property GridDataItems.ParentItem(Value As GridDataItem Ptr)
		FParentItem = Value
	End Property
	
	Private Function GridDataItems.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, tLocked As Boolean=False, Indent As Integer = 0) As GridDataItem Ptr
		PItem = _New(GridDataItem)
		FItems.Add PItem
		With *PItem
			.ImageIndex     = FImageIndex
			.Text(0)        = FCaption
			.State        = State
			.Locked         = tLocked
			If ParentItem Then
				.Indent        = ParentItem->Indent + 1
			Else
				.Indent        = 0
			End If
			.Parent         = Parent
			.Items.Parent         = Parent
			.ParentItem        = ParentItem
			If FItems.Count = 1 AndAlso ParentItem Then
				ParentItem->State = IIf(ParentItem->IsExpanded, 2, 1)
			End If
				If Parent AndAlso Cast(GridData Ptr, Parent)->TreeStore Then
					Cast(GridData Ptr, Parent)->Init
					If ParentItem <> 0 Then
						gtk_tree_store_append (Cast(GridData Ptr, Parent)->TreeStore, @PItem->TreeIter, @.ParentItem->TreeIter)
					Else
						gtk_tree_store_append (Cast(GridData Ptr, Parent)->TreeStore, @PItem->TreeIter, NULL)
					End If
					gtk_tree_store_set (Cast(GridData Ptr, Parent)->TreeStore, @PItem->TreeIter, 1, ToUtf8(FCaption), -1)
				End If
				PItem->Text(0) = FCaption
		End With
		Return PItem
	End Function
	
	Private Function GridDataItems.Add(ByRef FCaption As WString = "", ByRef FImageKey As WString, State As Integer = 0, tLocked As Boolean=False, Indent As Integer = 0) As GridDataItem Ptr
		If Parent AndAlso Cast(GridData Ptr, Parent)->Images Then
			PItem = Add(FCaption, Cast(GridData Ptr, Parent)->Images->IndexOf(FImageKey), State, tLocked, Indent)
		Else
			PItem = Add(FCaption, -1, State, tLocked, Indent)
		End If
		If PItem Then PItem->ImageKey = FImageKey
		Return PItem
	End Function
	
	Private Function GridDataItems.Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, tLocked As Boolean=False, Indent As Integer = 0) As GridDataItem Ptr
		Dim As GridDataItem Ptr PItem
		PItem = _New(GridDataItem)
		FItems.Insert Index, PItem
		With *PItem
			.ImageIndex     = FImageIndex
			.Text(0)        = FCaption
			.State          = State
			.Locked         = tLocked
			If ParentItem Then
				.Indent        = ParentItem->Indent + 1
			Else
				.Indent        = 0
			End If
			.Parent         = Parent
			.Items.Parent         = Parent
			.ParentItem        = Cast(GridDataItem Ptr, ParentItem)
			If FItems.Count = 1 AndAlso ParentItem Then
				ParentItem->State = IIf(ParentItem->IsExpanded, 2, 1)
			End If
		End With
		Return PItem
	End Function
	
	Private Sub GridDataItems.Remove(Index As Integer)
		If FItems.Count < 1 OrElse Index < 0 OrElse Index > FItems.Count - 1 Then Exit Sub
			If Parent AndAlso Parent->Handle Then
				gtk_tree_store_remove(Cast(GridData Ptr, Parent)->TreeStore, @This.Item(Index)->TreeIter)
			End If
		FItems.Remove Index
	End Sub
	
	'	#IfNDef __USE_GTK__
	'		Private Function CompareFunc(lParam1 As LPARAM, lParam2 As LPARAM, lParamSort As LPARAM) As Long
	'			Return 0
	'		End Function
	'	#EndIf
	
	'    Private Sub GridDataItems.Sort
	'		#IfNDef __USE_GTK__
	'			If Parent AndAlso Parent->Handle Then
	'				Parent->Perform LVM_SORTITEMS, 0, @CompareFunc
	'				ListView_SortItems
	'			End If
	'		#EndIf
	'    End Sub
	
	Private Function GridDataItems.IndexOf(ByRef FItem As GridDataItem Ptr) As Integer
		Return FItems.IndexOf(FItem)
	End Function
	
	Private Function GridDataItems.IndexOf(ByRef Caption As WString, ByVal WholeWords As Boolean = True, ByVal MatchCase As Boolean = True) As Integer
		For i As Integer = 0 To FItems.Count - 1
			If WholeWords Then
				If MatchCase Then
					If QGridDataItem(FItems.Items[i]).Text(0) = Caption Then Return i
				Else
					If LCase(QGridDataItem(FItems.Items[i]).Text(0)) = LCase(Caption) Then Return i
				End If
			Else
				If MatchCase Then
					If InStr(QGridDataItem(FItems.Items[i]).Text(0), Caption) Then Return i
				Else
					If InStr(LCase(QGridDataItem(FItems.Items[i]).Text(0)), LCase(Caption)) Then Return i
				End If
			End If
		Next i
		Return -1
	End Function
	
	Private Function GridDataItems.Contains(ByRef Caption As WString, ByVal WholeWords As Boolean = True, ByVal MatchCase As Boolean = True) As Boolean
		Return IndexOf(Caption, WholeWords, MatchCase) <> -1
	End Function
	
	Private Sub GridDataItems.Clear
		If FItems.Count<1 Then Exit Sub
			If Parent AndAlso Cast(GridData Ptr, Parent)->TreeStore Then gtk_tree_store_clear(Cast(GridData Ptr, Parent)->TreeStore)
		
	End Sub
	
	Private Operator GridDataItems.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor GridDataItems
		This.Clear
	End Constructor
	
	Private Destructor GridDataItems
		This.Clear
	End Destructor
	
	Private Property GridDataColumns.Count As Integer
		Return FColumns.Count
	End Property
	
	Private Property GridDataColumns.Count(Value As Integer)
	End Property
	
	Private Property GridDataColumns.Column(Index As Integer) As GridDataColumn Ptr
		Return QGridDataColumn(FColumns.Items[Index])
	End Property
	
	Private Property GridDataColumns.Column(Index As Integer, Value As GridDataColumn Ptr)
		'QGridDataColumn(FColumns.Items[Index]) = Value
		FColumns.Items[Index] = Value
	End Property
	
		Private Sub GridDataColumns.Cell_Edited(renderer As GtkCellRendererText Ptr, path As gchar Ptr, new_text As gchar Ptr, user_data As Any Ptr)
			Dim As GridDataColumn Ptr PColumn = user_data
			If PColumn = 0 Then Exit Sub
			Dim As GridData Ptr lv = Cast(GridData Ptr, PColumn->Parent)
			If lv = 0 Then Exit Sub
			Dim As GtkTreeIter iter
			Dim As GtkTreeModel Ptr model = gtk_tree_view_get_model(GTK_TREE_VIEW(lv->Handle))
			If gtk_tree_model_get_iter(model, @iter, gtk_tree_path_new_from_string(path)) Then
				If lv->OnCellEdited Then lv->OnCellEdited(*lv->Designer, *lv, lv->ListItems.FindByIterUser_Data(iter.user_data), PColumn->Index, *new_text)
				'gtk_tree_store_set(lv->TreeStore, @iter, PColumn->Index + 1, ToUtf8(*new_text), -1)
			End If
		End Sub
		
		Private Sub GridDataColumns.Cell_Editing(cell As GtkCellRenderer Ptr, editable As GtkCellEditable Ptr, path As Const gchar Ptr, user_data As Any Ptr)
			Dim As GridDataColumn Ptr PColumn = user_data
			If PColumn = 0 Then Exit Sub
			Dim As GridData Ptr lv = Cast(GridData Ptr, PColumn->Parent)
			If lv = 0 Then Exit Sub
			Dim As GtkTreeIter iter
			Dim As GtkTreeModel Ptr model = gtk_tree_view_get_model(GTK_TREE_VIEW(lv->Handle))
			Dim As Control Ptr CellEditor
			If gtk_tree_model_get_iter(model, @iter, gtk_tree_path_new_from_string(path)) Then
				If lv->OnCellEditing Then lv->OnCellEditing(*lv->Designer, *lv, lv->ListItems.FindByIterUser_Data(iter.user_data), PColumn->Index, CellEditor)
				If CellEditor <> 0 Then editable = GTK_CELL_EDITABLE(CellEditor->Handle)
			End If
		End Sub
	
	Private Function GridDataColumns.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, tFormat As ColumnFormat = cfLeft, tDataType As GridDataTypeEnum = DT_String, tLocked As Boolean = False, tControlType As GridControlTypeEnum = CT_TextBox, ByRef tComboItem As WString = "", tSortOrder As SortStyle = SortStyle.ssSortAscending) As GridDataColumn Ptr
		Dim As GridDataColumn Ptr PColumn
		Dim As Integer Index
		PColumn = _New(GridDataColumn)
		FColumns.Add PColumn
		Index = FColumns.Count - 1
		With *PColumn
			.ImageIndex     = FImageIndex
			.Text        = FCaption
			.Index = Index
			.ColWidth     = IIf(iWidth < 0, 100, iWidth)
			.Format = tFormat
			.DataType = tDataType
			.Locked = tLocked
			.ControlType = tControlType
			.SortOrder = tSortOrder
			.GridEditComboItem= tComboItem
		End With
			If Parent Then
				With *Cast(GridData Ptr, Parent)
					If .ColumnTypes Then _DeleteSquareBrackets(.ColumnTypes)
					.ColumnTypes = _New(GType[Index + 2])
					For i As Integer = 0 To Index + 1
						.ColumnTypes[i] = G_TYPE_STRING
					Next i
				End With
				PColumn->Column = gtk_tree_view_column_new()
				Dim As GtkCellRenderer Ptr rendertext = gtk_cell_renderer_text_new ()
				'				If ColEditable Then
				'					Dim As GValue bValue '= G_VALUE_INIT
				'					g_value_init_(@bValue, G_TYPE_BOOLEAN)
				'					g_value_set_boolean(@bValue, True)
				'					g_object_set_property(G_OBJECT(rendertext), "editable", @bValue)
				'					g_object_set_property(G_OBJECT(rendertext), "editable-set", @bValue)
				'					g_value_unset(@bValue)
				'					'Dim bTrue As gboolean = True
				'					'g_object_set(rendertext, "mode", GTK_CELL_RENDERER_MODE_EDITABLE, NULL)
				'					'g_object_set(gtk_cell_renderer_text(rendertext), "editable-set", true, NULL)
				'					'g_object_set(rendertext, "editable", bTrue, NULL)
				'				End If
				If Index = 0 Then
					Dim As GtkCellRenderer Ptr renderpixbuf = gtk_cell_renderer_pixbuf_new()
					gtk_tree_view_column_pack_start(PColumn->Column, renderpixbuf, False)
					gtk_tree_view_column_add_attribute(PColumn->Column, renderpixbuf, ToUtf8("icon_name"), 0)
				End If
				g_signal_connect(G_OBJECT(rendertext), "edited", G_CALLBACK (@Cell_Edited), PColumn)
				g_signal_connect(G_OBJECT(rendertext), "editing-started", G_CALLBACK (@Cell_Editing), PColumn)
				gtk_tree_view_column_pack_start(PColumn->Column, rendertext, True)
				gtk_tree_view_column_add_attribute(PColumn->Column, rendertext, ToUtf8("text"), Index + 1)
				gtk_tree_view_column_set_resizable(PColumn->Column, True)
				gtk_tree_view_column_set_title(PColumn->Column, ToUtf8(FCaption))
				gtk_tree_view_append_column(GTK_TREE_VIEW(Cast(GridData Ptr, Parent)->Handle), PColumn->Column)
					gtk_tree_view_column_set_fixed_width(PColumn->Column, Max(-1, iWidth))
			End If
		If Parent Then
			PColumn->Parent = Parent
				
		End If
		Return PColumn
	End Function
	
	Private Sub GridDataColumns.Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, tFormat As ColumnFormat = cfLeft, tDataType As GridDataTypeEnum = DT_String, tLocked As Boolean = False, tControlType As GridControlTypeEnum = CT_TextBox, ByRef tComboItem As WString = "", tSortOrder As SortStyle= SortStyle.ssSortAscending)
		Dim As GridDataColumn Ptr PColumn
		PColumn = _New(GridDataColumn)
		FColumns.Insert Index, PColumn
		With *PColumn
			.ImageIndex     = FImageIndex
			.Text        = FCaption
			.Index        = FColumns.Count - 1
			.ColWidth     = IIf(iWidth < 0, 100, iWidth)
			.Format = tFormat
			.DataType =tDataType
			.Locked = tLocked
			.ControlType = tControlType
			.SortOrder = tSortOrder
			.GridEditComboItem= tComboItem
		End With
	End Sub
	
	Private Sub GridDataColumns.Remove(Index As Integer)
		FColumns.Remove Index
	End Sub
	
	Private Function GridDataColumns.IndexOf(ByRef FColumn As GridDataColumn Ptr) As Integer
		Return FColumns.IndexOf(FColumn)
	End Function
	
	Private Sub GridDataColumns.Clear
		On Error Goto ErrorHandler
		If FColumns.Count>0 Then
			For i As Integer = FColumns.Count -1 To 0 Step -1
				_Delete(Cast(GridDataColumn Ptr, FColumns.Items[i]))
				FColumns.Remove i
			Next
			FColumns.Clear
		End If
		Exit Sub
		ErrorHandler:
		MsgBox ErrDescription(Err) & " (" & Err & ") " & _
		"in line " & Erl() & " " & _
		"in Private Function " & ZGet(Erfn()) & " " & _
		"in module " & ZGet(Ermn())
	End Sub
	
	Private Operator GridDataColumns.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor GridDataColumns
		This.Clear
	End Constructor
	
	Private Destructor GridDataColumns
		This.Clear
	End Destructor
	
	Private Sub GridData.Init()
			If gtk_tree_view_get_model(GTK_TREE_VIEW(widget)) = NULL Then
				gtk_tree_store_set_column_types(TreeStore, Columns.Count + 1, ColumnTypes)
				gtk_tree_view_set_model(GTK_TREE_VIEW(widget), GTK_TREE_MODEL(TreeStore))
				gtk_tree_view_set_enable_tree_lines(GTK_TREE_VIEW(widget), True)
			End If
	End Sub
	
	Private Sub GridData.EnsureVisible(Index As Integer)
			If GTK_IS_ICON_VIEW(widget) Then
				gtk_icon_view_select_path(GTK_ICON_VIEW(widget), gtk_tree_path_new_from_string(Trim(Str(Index))))
			Else
				If TreeSelection Then
					If Index > -1 AndAlso Index < ListItems.Count Then
						Dim As GtkTreeIter iter
						gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(TreeStore), @iter, Trim(Str(Index)))
						gtk_tree_view_scroll_to_cell(GTK_TREE_VIEW(widget), gtk_tree_model_get_path(GTK_TREE_MODEL(TreeStore), @iter), NULL, False, 0, 0)
					End If
				End If
			End If
	End Sub
	
	Private Property GridData.ColumnHeaderHidden As Boolean
		Return FColumnHeaderHidden
	End Property
	
	Private Property GridData.ColumnHeaderHidden(Value As Boolean)
		FColumnHeaderHidden = Value
			gtk_tree_view_set_headers_visible(GTK_TREE_VIEW(widget), Not Value)
	End Property
	
	Private Property GridData.SingleClickActivate As Boolean
		Return FSingleClickActivate
	End Property
	
	Private Property GridData.SingleClickActivate(Value As Boolean)
		FSingleClickActivate = Value
				gtk_tree_view_set_activate_on_single_click(GTK_TREE_VIEW(widget), Value)
	End Property
	
	Private Property GridData.View As ViewStyle
		Return FView
	End Property
	
	Private Property GridData.View(Value As ViewStyle)
		FView = Value
	End Property
	
	Private Property GridData.SelectedItem As GridDataItem Ptr
			Dim As GtkTreeIter iter
			If gtk_tree_selection_get_selected(TreeSelection, NULL, @iter) Then
				Return ListItems.FindByIterUser_Data(iter.User_Data)
			End If
		Return 0
	End Property
	
	Private Property GridData.SelectedItemIndex As Integer
			Dim As GtkTreeIter iter
			If gtk_tree_selection_get_selected(TreeSelection, NULL, @iter) Then
				Dim As GridDataItem Ptr lvi = ListItems.FindByIterUser_Data(iter.user_data)
				If lvi <> 0 Then Return lvi->Index
			End If
		Return -1
	End Property
	
	Private Property GridData.SelectedItemIndex(Value As Integer)
			If TreeSelection Then
				If Value = -1 Then
					gtk_tree_selection_unselect_all(TreeSelection)
				ElseIf Value > -1 AndAlso Value < ListItems.Count Then
					gtk_tree_selection_select_iter(TreeSelection, @ListItems.Item(Value)->TreeIter)
					gtk_tree_view_scroll_to_cell(GTK_TREE_VIEW(widget), gtk_tree_model_get_path(GTK_TREE_MODEL(TreeStore), @ListItems.Item(Value)->TreeIter), NULL, False, 0, 0)
				End If
			End If
	End Property
	
	
	Private Sub GridData.SetGridLines(tFocusRect As Integer=-1,tDrawMode As Integer=-1,_
		tColorLine As Integer=-1,tColorLineHeader As Integer=-1,tColorEditBack As Integer=-1,tColorSelected As Integer=-1,_
		tColorHover As Integer=-1,tWidth As Integer=-1,PenMode As Integer=-1)
		If tFocusRect<>-1 Then mGridFocusRect = tFocusRect
		If tDrawMode<>-1 Then mGridLineDrawMode = tDrawMode
		If tColorLine<>-1 Then mGridColorLine = tColorLine
		If tColorLineHeader<>-1 Then mGridColorLineHeader = tColorLineHeader
		If tColorEditBack<>-1 Then mGridColorEditBack = tColorEditBack
		If tWidth<>-1 Then mGridLineWidth = tWidth
		If PenMode<>-1 Then mGridLinePenMode = PenMode
		If tColorSelected<>-1 Then mGridColorSelected=tColorSelected
		If tColorHover<>-1 Then mGridColorHover=tColorHover
	End Sub
	
	Private Property GridData.RowHeightHeader As Integer
		Return  mRowHeightHeader
	End Property
	Private Property GridData.RowHeightHeader(Value As Integer)
		'Must call RowHeightHeader First for the header height. It is not working after Columns.Add
		
		'    Dim As Integer FSizeHeaderSave =mFSizeHeader
		'    Dim As HDC GridDCHeader = GetDc(mHandleHeader)
		mRowHeightHeader=IIf(Value<18,18,Value)
		'    'mRowHeight=(18+(mFSize-8)*1.45
		'mFSize=(mRowHeight-18)/1.45+8
		mFSizeHeader=IIf(Value<18,8,(mRowHeightHeader-18)/1.45+8)
		'    If mFontHandleHeader Then DeleteObject(mFontHandleHeader)
		'    mFontHandleHeader=CreateFontW(-MulDiv(mFSizeHeader,mFCyPixelsHeader,72),0,mFOrientationHeader*mFSizeHeader,mFOrientationHeader*mFSizeHeader,mFBoldsHeader(Abs_(mFBoldHeader)),mFItalicHeader,mFUnderlineHeader,mFStrikeOutHeader,mFCharSetHeader,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FF_DONTCARE,*mFNameHeader)
		'    SendMessage(mHandleHeader, WM_SETFONT,CUInt(mFontHandleHeader),True) 'enlarge the height of header
		'    SelectObject(GridDCHeader,mFontHandleHeader)
		'    'mFSizeHeader=FSizeHeaderSave
		'    'If mFontHandleHeader Then DeleteObject(mFontHandleHeader)
		'    'mFontHandleHeader=CreateFontW(-MulDiv(mFSizeHeader,mFCyPixelsHeader,72),0,mFOrientationHeader*mFSizeHeader,mFOrientationHeader*mFSizeHeader,mFBoldsHeader(Abs_(mFBoldHeader)),mFItalicHeader,mFUnderlineHeader,mFStrikeOutHeader,mFCharSetHeader,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,FF_DONTCARE,*mFNameHeader)
		'    'SelectObject(GridDCHeader,mFontHandleHeader)
		'
		'    ReleaseDC(mHandleHeader, GridDCHeader)
		'    GetClientRect Handle,@mClientRect
		'    GetClientRect mHandleHeader,@mClientRectHeader
		'    mRowHeightHeader=IIf(Value<18,18,Value)
		'    This.Font.Size=(mRowHeightHeader-18)/1.45+8
	End Property
	
	Private Sub GridData.SetFontHeader(tFontColor As Integer=-1,tFontColorBK As Integer=-1,tNameHeader As WString="",_
		tSizeHeader As Integer=-1,tCharSetHeader As Integer=FontCharset.Default, _
		tBoldsHeader As Boolean=False,tItalicHeader As Boolean=False, _
		tUnderlineHeader As Boolean=False,tStrikeoutHeader As Boolean=False)
		
		If tFontColor<>-1 Then mHeaderForeColor=tFontColor
		If tFontColorBK<>-1 Then mHeaderBackColor=tFontColorBK
		If Len(tNameHeader) > 0 Then WLET(mFNameHeader, tNameHeader)
		If tSizeHeader<>-1 Then mFSizeHeader=tSizeHeader
		mFBoldHeader=tBoldsHeader
		mFItalicHeader =tItalicHeader
		mFUnderlineHeader=tUnderlineHeader
		mFStrikeOutHeader=tStrikeoutHeader
		mFCharSetHeader = tCharSetHeader
	End Sub
	
	Private Sub GridData.SetFont(tName As WString="",tSize As Integer=-1,tCharSet As Integer=FontCharset.Default,tBolds As Boolean=False,tItalic As Boolean=False,tUnderline As Boolean=False,tStrikeout As Boolean=False)
		If Len(tName) > 0 Then WLET(mFName, tName)
		If tSize<>-1 Then mFSize=tSize
		mFBold=tBolds
		mFItalic =tItalic
		mFUnderline=tUnderline
		mFStrikeOut=tStrikeout
		mFCharSet = tCharSet
		
	End Sub
	
	Private Property GridData.ShowHoverBar As Boolean
		Return  mShowHoverBar
	End Property
	Private Property GridData.ShowHoverBar(Value As Boolean)
		mShowHoverBar=Value
	End Property
	
	Private Property GridData.ShowSelection As Boolean
		Return  mShowSelection
	End Property
	Private Property GridData.ShowSelection(Value As Boolean)
		mShowSelection=Value
	End Property
	
	Private Property GridData.RowHeight As Integer
		Return  mRowHeight
	End Property
	Private Property GridData.RowHeight(Value As Integer)
		mRowHeight=IIf(Value<18,18,Value)
		'    This.Font.Size=(tRowHeight-18)/1.45+8
		This.ImgListGrid.Height=mRowHeight 'Change Height of body
		This.ImgListGrid.Width=mRowHeight 'Change Height of body
		This.SmallImages  = @ImgListGrid
	End Property
	
	Private Property GridData.SelectedItem(Value As GridDataItem Ptr)
		Value->SelectItem
	End Property
	
	Private Property GridData.SelectedColumn As GridDataColumn Ptr
		Return 0
	End Property
	
	
	Private Property GridData.Sort As SortStyle
		Return FSortStyle
	End Property
	
	Private Property GridData.Sort(Value As SortStyle)
		FSortStyle = Value
	End Property
	Private Sub GridData.Refresh()
		' dim as RECT RectCell
		'PostMessage(Handle, WM_SIZE, 0, 0) 'Force to Refresh. better than GridReDraw because it is not updated sometimes.
	End Sub
	
	Private Sub GridData.SortData(iCol As Integer,tSortStyle As SortStyle)
		If tSortStyle = SortStyle.ssNone Then
			iCol=0
			tSortStyle = SortStyle.ssSortDescending
		End If
		If mSorting Then Exit Sub
		mSorting=True
		Dim As Integer i,j
		Dim tItemCount As Integer
		tItemCount= ListItems.Count'ListItems.Item(j)->Text(iCOl)
		Dim tItem As GridDataItem Ptr
		'print "Sort Start ",time
		If tSortStyle= SortStyle.ssSortDescending Then
			For i = tItemCount -1 To 0  Step -1
				'Skip the blank row marked by ListItems.Item(j)->Text(0))>=BLANKROW
				If Val(ListItems.Item(i)->Text(0))<BLANKROW Then
					For j = 1 To i
						'Print Val(ListItems.Item(j)->Text(0))
						If Columns.Column(iCol)->DataType=DT_Numeric Then
							If Val(ListItems.Item(j)->Text(iCol)) < Val(ListItems.Item(j-1)->Text(iCol)) Then
								'Exchange j - 1, j
								tItem=ListItems.Item(j-1)
								ListItems.Item(j-1)=ListItems.Item(j)
								ListItems.Item(j)=tItem
							End If
						Else
							If LCase(ListItems.Item(j)->Text(iCol)) < LCase(ListItems.Item(j-1)->Text(iCol)) Then
								'Exchange j - 1, j
								tItem=ListItems.Item(j-1)
								ListItems.Item(j-1)=ListItems.Item(j)
								ListItems.Item(j)=tItem
							End If
						End If
					Next
				End If
			Next
		Else
			For i = tItemCount -1 To 0 Step -1
				'Skip the blank row marked by ListItems.Item(j)->Text(0))>=BLANKROW
				If Val(ListItems.Item(i)->Text(0))<BLANKROW Then
					For j = 1 To i
						If Columns.Column(iCol)->DataType=DT_Numeric Then
							If Val(ListItems.Item(j)->Text(iCol)) > Val(ListItems.Item(j-1)->Text(iCol)) Then
								'Exchange j - 1, j
								tItem=ListItems.Item(j-1)
								ListItems.Item(j-1)=ListItems.Item(j)
								ListItems.Item(j)=tItem
							End If
						Else
							If LCase(ListItems.Item(j)->Text(iCOl)) > LCase(ListItems.Item(j-1)->Text(iCOl)) Then
								'Exchange j - 1, j
								tItem=ListItems.Item(j-1)
								ListItems.Item(j-1)=ListItems.Item(j)
								ListItems.Item(j)=tItem
								
							End If
						End If
					Next
				End If
			Next
		End If
		mSorting=False
		'print "Sort End ",time
	End Sub
	
	Private Property GridData.BackColor As Integer
		Return mGridColorBack
	End Property
	Private Property GridData.BackColor(Value As Integer)
		mGridColorBack = Value
	End Property
	
	Private Property GridData.ForeColor As Integer
		Return mGridColorFore
	End Property
	Private Property GridData.ForeColor(Value As Integer)
		mGridColorFore = Value
	End Property
	
	Private Property GridData.SelectedColumn(Value As GridDataColumn Ptr)
	End Property
	
	Private Property GridData.ShowHint As Boolean
		Return FShowHint
	End Property
	
	Private Property GridData.ShowHint(Value As Boolean)
		FShowHint = Value
	End Property
	
	Private Property GridData.AllowEdit As Boolean
		Return mAllowEdit
	End Property
	Private Property GridData.AllowEdit(Value As Boolean)
		mAllowEdit = Value
	End Property
	
	Private Sub GridData.ProcessMessage(ByRef Message As Message)
		'?message.msg, GetMessageName(message.msg)
			Dim As GdkEvent Ptr e = Message.Event
			Select Case Message.Event->type
			Case GDK_MAP
				Init
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	
	Private Operator GridData.Cast As Control Ptr
		Return @This
	End Operator
	
		Private Sub GridData.GridData_RowActivated(tree_view As GtkTreeView Ptr, path As GtkTreePath Ptr, column As GtkTreeViewColumn Ptr, user_data As Any Ptr)
			Dim As GridData Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeModel Ptr model
				Dim As GtkTreeIter iter
				model = gtk_tree_view_get_model(tree_view)
				
				If gtk_tree_model_get_iter(model, @iter, path) Then
					If lv->OnItemActivate Then lv->OnItemActivate(*lv->Designer, *lv, lv->ListItems.FindByIterUser_Data(iter.user_data))
				End If
			End If
		End Sub
		
		Private Sub GridData.GridData_SelectionChanged(selection As GtkTreeSelection Ptr, user_data As Any Ptr)
			Dim As GridData Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeIter iter
				Dim As GtkTreeModel Ptr model
				If gtk_tree_selection_get_selected(selection, @model, @iter) Then
				End If
			End If
		End Sub
		
		Private Sub GridData.GridData_Map(widget As GtkWidget Ptr, user_data As Any Ptr)
			Dim As GridData Ptr lv = user_data
			lv->Init
		End Sub
		
		Private Function GridData.GridData_TestExpandRow(tree_view As GtkTreeView Ptr, iter As GtkTreeIter Ptr, path As GtkTreePath Ptr, user_data As Any Ptr) As Boolean
			Dim As GridData Ptr lv = user_data
			If lv Then
				Dim As GtkTreeModel Ptr model
				model = gtk_tree_view_get_model(tree_view)
				If lv->OnItemExpanding Then lv->OnItemExpanding(*lv->Designer, *lv, lv->ListItems.FindByIterUser_Data(iter->user_data))
			End If
			Return False
		End Function
	
	Private Sub GridData.CollapseAll
			gtk_tree_view_collapse_all(GTK_TREE_VIEW(widget))
	End Sub
	
	Private Sub GridData.ExpandAll
			gtk_tree_view_expand_all(GTK_TREE_VIEW(widget))
	End Sub
	
	Private Constructor GridData
			TreeStore = gtk_tree_store_new(1, G_TYPE_STRING)
			scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
			gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
			'widget = gtk_tree_view_new_with_model(gtk_tree_model(ListStore))
			widget = gtk_tree_view_new()
			gtk_container_add(GTK_CONTAINER(scrolledwidget), widget)
			TreeSelection = gtk_tree_view_get_selection(GTK_TREE_VIEW(widget))
			g_signal_connect(GTK_TREE_VIEW(widget), "map", G_CALLBACK(@GridData_Map), @This)
			g_signal_connect(GTK_TREE_VIEW(widget), "row-activated", G_CALLBACK(@GridData_RowActivated), @This)
			g_signal_connect(GTK_TREE_VIEW(widget), "test-expand-row", G_CALLBACK(@GridData_TestExpandRow), @This)
			g_signal_connect(G_OBJECT(TreeSelection), "changed", G_CALLBACK (@GridData_SelectionChanged), @This)
			gtk_tree_view_set_enable_tree_lines(GTK_TREE_VIEW(widget), True)
			gtk_tree_view_set_grid_lines(GTK_TREE_VIEW(widget), GTK_TREE_VIEW_GRID_LINES_BOTH)
			ColumnTypes = _New(GType[1])
			ColumnTypes[0] = G_TYPE_STRING
			This.RegisterClass "GridData", @This
		'Font
		mFBolds(0) = 400
		mFBolds(1) = 700
		WLet(mFName, This.Font.Name)     '"TAHOMA"
		WLet(mFNameHeader, This.Font.Name)  '"TAHOMA"
		mFCharSet=FontCharset.Default
		mFCharSetHeader=FontCharset.Default
		mFBoldsHeader(0) = 400
		mFBoldsHeader(1) =700
		
		FEnabled = True
		FVisible = True
		ListItems.Parent = @This
		Columns.Parent = @This
		Columns.Clear
		ListItems.Clear
		
		GridEditComboBox.Parent = @This
		GridEditText.Parent = @This
		GridEditDateTimePicker.Parent = @This
		'GridEditLinkLabel.Parent = @This
		'GridEditText.BorderStyle = 0
		GridEditText.Multiline= True
		'GridEditText.WantReturn = True 'one is enough
		GridEditText.BringToFront
		GridEditComboBox.BringToFront
		GridEditDateTimePicker.BringToFront
		
		GridEditComboBox.Visible = False
		GridEditDateTimePicker.Visible = False
		'GridEditLinkLabel.Visible = False
		GridEditText.Visible = False
		With This
			.Child             = @This
			WLet(FClassName, "GridData")
			.Width             = 121
			.Height            = 121
		End With
		Columns.Add "NO.", 0, 35, cfCenter, CT_Header, False, CT_Header, , SortStyle.ssSortAscending
		Columns.Add "Column" & Chr(10) & "One", 0,100,cfCenter, DT_String,False,CT_TextBox
		Columns.Add "Column" & Chr(10) & "Two" , 0,100,cfCenter,DT_String,False,CT_TextBox
		For i As Integer =1 To 50
			ListItems.Add Str(i),0,1
		Next
	End Constructor
	
	Private Destructor GridData
		ListItems.Clear
		Columns.Clear
			If ColumnTypes Then _DeleteSquareBrackets(ColumnTypes)
		WDeAllocate FClassName
		WDeAllocate FClassAncestor
		WDeAllocate mFName
		WDeAllocate mFNameHeader
	End Destructor
End Namespace
