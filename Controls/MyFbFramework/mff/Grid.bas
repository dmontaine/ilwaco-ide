'################################################################################
'#  Grid.bas                                                                    #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov,  Liu XiaLin                                    #
'################################################################################

#include once "Grid.bi"

Namespace My.Sys.Forms
	Private Function GridRow.Index As Integer
		If Parent Then
			Dim As Integer tIndex = Cast(Grid Ptr, Parent)->Rows.IndexOf(@This)
			If tIndex = -1 Then Print "Out of bound of Rows " & Cast(Grid Ptr, Parent)->Rows.Count
			Return tIndex
		Else
			Return -1
		End If
	End Function
	
	Private Sub GridCell.SelectItem
		With *Cast(Grid Ptr, Parent)
			.SelectedColumn = Column
			.SelectedRow = Row
		End With
	End Sub
	
	Private Sub GridRow.SelectItem
			If Parent Then
				If gtk_tree_view_get_selection(GTK_TREE_VIEW(Parent->Handle)) Then
					gtk_tree_selection_select_iter(gtk_tree_view_get_selection(GTK_TREE_VIEW(Parent->Handle)), @TreeIter)
				End If
			End If
	End Sub
	
	#ifndef GridRow_Item_Off
		Private Function GridRow.Item(ColumnIndex As Integer) As GridCell Ptr
			Dim ic As Integer = FCells.Count
			Dim cc As Integer = Cast(Grid Ptr, Parent)->Columns.Count
			If ic < cc Then
				For i As Integer = ic To cc -1
					Dim As GridCell Ptr Cell : Cell = _New(GridCell)
					Cell->Column = Cast(Grid Ptr, Parent)->Columns.Column(i)
					Cell->Row = Cast(Grid Ptr, Parent)->Rows.Item(Index)
					Cell->Parent = Parent
					FCells.Add "", Cell
				Next
			End If
			If ColumnIndex < FCells.Count AndAlso ColumnIndex >= 0 Then
				Dim As GridCell Ptr Cell = FCells.Object(ColumnIndex)
				If Cell = 0 Then
					Cell = _New(GridCell)
					FCells.Object(ColumnIndex) = Cell
					Cell->Column = Cast(Grid Ptr, Parent)->Columns.Column(ColumnIndex)
					Cell->Row = Cast(Grid Ptr, Parent)->Rows.Item(Index)
					Cell->Parent = Parent
				End If
				Return Cell
			Else
				Return 0
			End If
		End Function
	#endif
	
	Private Property GridCell.Text ByRef As WString
		If Row > 0 Then Return Row->Text(Column->Index) Else Return ""
	End Property
	
	Private Property GridCell.Text(ByRef Value As WString)
		If Row > 0 Then Row->Text(Column->Index) = Value
	End Property
	
	Private Property GridCell.Editable As Boolean
		Return FEditable
	End Property
	
	Private Property GridCell.Editable(Value As Boolean)
		FEditable = Value
	End Property
	
	Private Property GridCell.BackColor As Integer
		Return FBackColor
	End Property
	
	Private Property GridCell.BackColor(Value As Integer)
		FBackColor = Value
	End Property
	
	Private Property GridCell.ForeColor As Integer
		Return FForeColor
	End Property
	
	Private Property GridCell.ForeColor(Value As Integer)
		FForeColor = Value
	End Property
	
	Private Sub GridRow.ColumnEvents(ColumnIndex As Integer, ColumnDelete As Boolean = False)
		If ColumnDelete AndAlso FCells.Count > 0 AndAlso FCells.Count > ColumnIndex AndAlso ColumnIndex >= 0 Then
			FCells.Remove ColumnIndex
		Else
			Dim As GridCell Ptr Cell : Cell = _New(GridCell)
			Cell->Column = Cast(Grid Ptr, Parent)->Columns.Column(ColumnIndex)
			Cell->Row = @This
			Cell->Parent = Parent
			FCells.Insert(ColumnIndex, "", Cell)
		End If
	End Sub
	
	Private Property GridRow.Text(ColumnIndex As Integer) ByRef As WString
		If FCells.Count > ColumnIndex AndAlso ColumnIndex >= 0 Then
			Return FCells.Item(ColumnIndex)
		Else
			Return WStr("")
		End If
	End Property
	
		Private Function GridGetModel(widget As GtkWidget Ptr) As GtkTreeModel Ptr
			If GTK_IS_WIDGET(widget) Then
				Return gtk_tree_view_get_model(GTK_TREE_VIEW(widget))
			End If
		End Function
	
	Private Property GridRow.Text(ColumnIndex As Integer, ByRef Value As WString)
		WLet(FText, Value)
		If Parent <= 0 Then Return
		Dim ic As Integer = FCells.Count
		Dim cc As Integer = Cast(Grid Ptr, Parent)->Columns.Count
		If ic < cc Then
			For i As Integer = ic To cc - 1
				Dim As GridCell Ptr Cell : Cell = _New(GridCell)
				Cell->Column = Cast(Grid Ptr, Parent)->Columns.Column(i)
				Cell->Row = @This
				Cell->Parent = Parent
				FCells.Add "", Cell
			Next
		End If
		If ColumnIndex < FCells.Count AndAlso ColumnIndex >= 0 Then FCells.Item(ColumnIndex) = Value
			If Parent AndAlso Parent->Handle AndAlso GridGetModel(Parent->Handle) Then
				gtk_list_store_set(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @TreeIter, ColumnIndex + 3, ToUtf8(Value), -1)
			End If
	End Property
	
	Private Property GridRow.Editable As Boolean
		Return FEditable
	End Property
	
	Private Property GridRow.Editable(Value As Boolean)
		FEditable = Value
	End Property
	
	Private Property GridRow.BackColor As Integer
		Return FBackColor
	End Property
	
	Private Property GridRow.BackColor(Value As Integer)
		FBackColor = Value
	End Property
	
	Private Property GridRow.ForeColor As Integer
		Return FForeColor
	End Property
	
	Private Property GridRow.ForeColor(Value As Integer)
		FForeColor = Value
	End Property
	
	Private Property GridRow.State As Integer
		Return FState
	End Property
	
	Private Property GridRow.State(Value As Integer)
		FState = Value
	End Property
	
	Private Property GridRow.Hint ByRef As WString
		Return WGet(FHint)
	End Property
	
	Private Property GridRow.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	
	Private Property GridRow.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	#ifndef GridRow_ImageIndex_Set_Off
		Private Property GridRow.ImageIndex(Value As Integer)
			If Value <> FImageIndex Then
				FImageIndex = Value
			End If
		End Property
	#endif
	
	Private Property GridRow.Indent As Integer
		Return FIndent
	End Property
	
	#ifndef GridRow_Indent_Set_Off
		Private Property GridRow.Indent(Value As Integer)
			FIndent = Value
		End Property
	#endif
	
	Private Property GridRow.SelectedImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property GridRow.SelectedImageIndex(Value As Integer)
		If Value <> FSelectedImageIndex Then
			FSelectedImageIndex = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MAKELONG(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property GridRow.ImageKey ByRef As WString
		Return WGet(FImageKey)
	End Property
	
	#ifndef GridRow_ImageKey_Set_Off
		Private Property GridRow.ImageKey(ByRef Value As WString)
			If FImageKey = 0 OrElse Value <> *FImageKey Then
				WLet(FImageKey, Value)
					If Parent AndAlso Parent->Handle Then
						Dim As GError Ptr gerr
						If Value <> "" Then
							gtk_list_store_set(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @TreeIter, 1, gtk_icon_theme_load_icon(gtk_icon_theme_get_default(), ToUtf8(Value), 16, GTK_ICON_LOOKUP_USE_BUILTIN, @gerr), -1)
							gtk_list_store_set(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @TreeIter, 2, ToUtf8(Value), -1)
						End If
					End If
			End If
		End Property
	#endif
	
	Private Property GridRow.SelectedImageKey ByRef As WString
		If FImageKey > 0 Then Return *FImageKey Else Return ""
	End Property
	
	Private Property GridRow.SelectedImageKey(ByRef Value As WString)
		If FSelectedImageKey = 0 OrElse Value <> *FSelectedImageKey Then
			WLet(FSelectedImageKey, Value)
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_CHANGEBITMAP, FCommandID, MAKELONG(FImageIndex, 0))
				End With
			End If
		End If
	End Property
	
	Private Property GridRow.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property GridRow.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_HIDEBUTTON, FCommandID, MAKELONG(Not FVisible, 0))
				End With
			End If
		End If
	End Property
	
	Private Operator GridRow.[](ColumnIndex As Integer) ByRef As GridCell
		Return *Item(ColumnIndex)
	End Operator
	
	Private Operator GridRow.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor GridRow
		FVisible            = 1
		Text(0)             = ""
		Hint                = ""
		FImageIndex         = -1
		FSelectedImageIndex = -1
		FSmallImageIndex    = -1
	End Constructor
	
	Private Destructor GridRow
		For i As Integer = 0 To FCells.Count - 1
			If FCells.Object(i) <> 0 Then _Delete(Cast(GridCell Ptr, FCells.Object(i)))
		Next
		FCells.Clear
		If FHint Then _Deallocate( FHint)
		If FText Then _Deallocate( FText)
	End Destructor
	
	Private Sub GridColumn.SelectItem
	End Sub
	
	Private Property GridColumn.Text ByRef As WString
		If FText > 0 Then Return *FText Else Return ""
	End Property
	
	Private Property GridColumn.Text(ByRef Value As WString)
		WLet(FText, Value)
	End Property
	
	Private Property GridColumn.Width As Integer
			If This.Column Then FWidth = gtk_tree_view_column_get_width(This.Column)
		Return FWidth
	End Property
	
	#ifndef GridColumn_Width_Set_Off
		Private Property GridColumn.Width(Value As Integer)
			FWidth = Value
			Update
		End Property
	#endif
	
	#ifndef GridColumn_Update_Off
		Private Sub GridColumn.Update()
					If This.Column Then gtk_tree_view_column_set_fixed_width(This.Column, Max(-1, FWidth))
		End Sub
	#endif
	
	Private Property GridColumn.Format As ColumnFormat
		Return FFormat
	End Property
	
	#ifndef GridColumn_Format_Set_Off
		Private Property GridColumn.Format(Value As ColumnFormat)
			FFormat = Value
		End Property
	#endif
	
	Private Property GridColumn.Editable As Boolean
		Return FEditable
	End Property
	
	Private Property GridColumn.Editable(Value As Boolean)
		FEditable = Value
	End Property
	
	Private Property GridColumn.BackColor As Integer
		Return FBackColor
	End Property
	
	Private Property GridColumn.BackColor(Value As Integer)
		FBackColor = Value
	End Property
	
	Private Property GridColumn.ForeColor As Integer
		Return FForeColor
	End Property
	
	Private Property GridColumn.ForeColor(Value As Integer)
		FForeColor = Value
	End Property
	
	Private Property GridColumn.Hint ByRef As WString
		Return WGet(FHint)
	End Property
	
	Private Property GridColumn.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	Private Property GridColumn.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	#ifndef GridColumn_ImageIndex_Set_Off
		Private Property GridColumn.ImageIndex(Value As Integer)
			If Value <> FImageIndex Then
				FImageIndex = Value
				If Parent Then
					With QControl(Parent)
						'.Perform(TB_CHANGEBITMAP, FCommandID, MakeLong(FImageIndex, 0))
					End With
				End If
			End If
		End Property
	#endif
	
	Private Property GridColumn.Visible As Boolean
		Return FVisible
	End Property
	
	Private Property GridColumn.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Parent Then
				With QControl(Parent)
					'.Perform(TB_HIDEBUTTON, FCommandID, MakeLong(NOT FVisible, 0))
				End With
			End If
		End If
	End Property
	
	Private Operator GridColumn.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor GridColumn
		FVisible     = 1
		Text         = ""
		Hint         = ""
		FEditable    = False
		FImageIndex = -1
	End Constructor
	
	Private Destructor GridColumn
		If FHint Then _Deallocate( FHint)
		If FText Then _Deallocate( FText)
	End Destructor
	
	Private Property GridRows.Count As Integer
		Return FItems.Count
	End Property
	
	Private Property GridRows.Count(Value As Integer)
		If Parent Then
			With *Cast(Grid Ptr, Parent)
				If Value >= .Rows.Count Then
					For i As Integer = .Rows.Count To Value - 1
						.Rows.Add
					Next
				Else
					For i As Integer = .Rows.Count - 1 To Value Step -1
						.Rows.Remove i
					Next
				End If
			End With
			If Parent->Handle Then
			End If
		End If
	End Property
	
	Private Property GridRows.Item(Index As Integer) As GridRow Ptr
		If Index >= 0 AndAlso Index < FItems.Count Then
			Return FItems.Items[Index]
		End If
		Return 0
	End Property
	
	Private Property GridRows.Item(Index As Integer, Value As GridRow Ptr)
		If Index >= 0 AndAlso Index < FItems.Count Then
			FItems.Items[Index] = Value
		End If
	End Property
	
		Private Function GridRows.FindByIterUser_Data(User_Data As Any Ptr) As GridRow Ptr
			For i As Integer = 0 To Count - 1
				If Item(i)->TreeIter.user_data = User_Data Then Return Item(i)
			Next i
			Return 0
		End Function
	
	Sub GridRows.Sort(ColumnIndex As Integer = 0, Direction As SortStyle = SortStyle.ssSortAscending, MatchCase As Boolean = False, iLeft As Integer = 0, iRight As Integer = 0)
		If Cast(Grid Ptr, Parent)->OwnerData Then Exit Sub
		Dim bStarted As Boolean
		Cast(Grid Ptr, Parent)->SortIndex = ColumnIndex
		Cast(Grid Ptr, Parent)->SortOrder = Direction
		If iLeft = 0 AndAlso iRight = 0 Then
		End If
		If FItems.Count <= 1 Then Return
		If iRight = 0 Then iRight = FItems.Count - 1
		If iLeft < 0 Then iLeft = 0
		If (iRight <> 0 AndAlso (iLeft >= iRight)) Then Return
		Dim As Integer i = iLeft, j = iRight
		'QuickSort
		Dim As WString Ptr iKey = @(Item(i)->Text(ColumnIndex))
		If Direction = SortStyle.ssSortAscending Then
			If MatchCase Then
				While (i < FItems.Count And j >= 0 And i <= j)
					While (*iKey < Item(j)->Text(ColumnIndex) AndAlso i < j)
						j -= 1
					Wend
					If i <= j Then FItems.Exchange i, j: i += 1
					While (*iKey >= Item(i)->Text(ColumnIndex) AndAlso i < j)
						i += 1
					Wend
					If i <= j Then FItems.Exchange i, j:  j -= 1
				Wend
			Else
				While (i < FItems.Count And j >= 0 And i <= j)
					While (LCase(*iKey) < LCase(Item(j)->Text(ColumnIndex)) AndAlso i < j)
						j -= 1
					Wend
					If i <= j Then FItems.Exchange i, j: i += 1
					While (LCase(*iKey) >= LCase(Item(i)->Text(ColumnIndex)) AndAlso i < j)
						i += 1
					Wend
					If i <= j Then FItems.Exchange i, j: j -= 1
				Wend
			End If
		Else
			If MatchCase Then
				While (i < FItems.Count And j >= 0 And i <= j)
					While (*iKey > Item(j)->Text(ColumnIndex) AndAlso i < j)
						j -= 1
					Wend
					If i <= j Then FItems.Exchange i, j: i += 1
					While (*iKey <= Item(i)->Text(ColumnIndex) AndAlso i < j)
						i += 1
					Wend
					If i <= j Then FItems.Exchange i, j:  j -= 1
				Wend
			Else
				While (i < FItems.Count And j >= 0 And i <= j)
					While (LCase(*iKey) > LCase(Item(j)->Text(ColumnIndex)) AndAlso i < j)
						j -= 1
					Wend
					If i <= j Then FItems.Exchange i, j: i += 1
					While (LCase(*iKey) <= LCase(Item(i)->Text(ColumnIndex)) AndAlso i < j)
						i += 1
					Wend
					If i <= j Then FItems.Exchange i, j: j -= 1
				Wend
			End If
		End If
		If j > iLeft Then This.Sort(ColumnIndex, Direction, MatchCase, iLeft, j)
		If i < iRight Then This.Sort(ColumnIndex, Direction, MatchCase, i, iRight)
		If bStarted Then
			Parent->Repaint
		End If
	End Sub
	
	#ifndef GridRows_Add_Integer_Off
		Private Function GridRows.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0, Index As Integer = -1, RowEditable As Boolean = False, ColorBK As Integer = -1, ColorText As Integer = -1, ByRef DelimiterChr As String = "", ByVal IsLastItem As Boolean = True) As GridRow Ptr
			If Parent <= 0 Then Return 0
			Dim As Integer i = Index, FixCols = 1
			If Parent <> 0 Then FixCols = IIf(Cast(Grid Ptr, Parent)->FixCols, 1, 0)
			PItem = _New(GridRow)
			PItem->Parent = Parent
			If Index = -1  Then
				FItems.Add PItem
				If FCaption = "" Then Return PItem  'For fast add at the beginning while set RowsCount
				i = FItems.Count - 1
			Else
				FItems.Insert i, PItem
			End If
			With *PItem
				.ImageIndex     = FImageIndex
					Dim As GtkWidget Ptr ParentTemp = Parent->Handle
					Parent->Handle = 0
				'Only compare the string of the first row
				If DelimiterChr = "" Then
					If InStr(FCaption, Chr(9)) Then
						DelimiterChr =  Chr(9)
					Else
						DelimiterChr = IIf(InStr(FCaption, "|"), "|", IIf(InStr(FCaption, ","), ",", ";"))
					End If
				End If
				'If FixCols > 0 Then .Text(0)    = Str(FItems.Count) Else .Text(0)    = "**" & Str(FItems.Count)
				If InStr(FCaption, DelimiterChr) > 0 Then
					Dim As Integer ii = 1, tLen = Len(DelimiterChr), ls = Len(FCaption), p = 1, n = FixCols
					Do While ii <= ls
						If Mid(FCaption, ii, tLen) = DelimiterChr Then
							n = n + 1
							.Text(n - 1) = Mid(FCaption, p, ii - p)
							.Item(n - 1)->BackColor = IIf(ColorBK = -1, Cast(Grid Ptr, Parent)->Columns.Column(n - 1)->BackColor, ColorBK)
							.Item(n - 1)->ForeColor = IIf(ColorText = -1, Cast(Grid Ptr, Parent)->Columns.Column(n - 1)->ForeColor, ColorText)
							p = ii + tLen
							ii = p
							Continue Do
						End If
						ii = ii + 1
					Loop
					n = n + 1
					.Text(n - 1) = Mid(FCaption, p, ii - p)
					'.Item(n - 1)->Editable  = IIf(RowEditableMode = -1, Cast(Grid Ptr, Parent)->Columns.Column(n - 1)->Editable, IIf(RowEditableMode = 0, False, True))
					.Item(n - 1)->BackColor = IIf(ColorBK = -1, Cast(Grid Ptr, Parent)->Columns.Column(n - 1)->BackColor, ColorBK)
					.Item(n - 1)->ForeColor = IIf(ColorText = -1, Cast(Grid Ptr, Parent)->Columns.Column(n - 1)->ForeColor, ColorText)
				Else
					.Text(FixCols)    = FCaption
				End If
					Parent->Handle = ParentTemp
				' For entir row： if the value is -1 or false then flowing the Column property
				.Editable       = RowEditable
				.BackColor      = ColorBK
				.ForeColor      = ColorText
				.State          = State
				.Indent         = Indent
			End With
				Cast(Grid Ptr, Parent)->Clear
				If Index <> -1 Then 'iSortStyle <> SortStyle.ssNone OrElse
					gtk_list_store_insert(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter, i)
				Else
					gtk_list_store_append(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter)
				End If
				gtk_list_store_set (GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter, 3, ToUtf8(PItem->Text(0)), -1)
				If InStr(FCaption, DelimiterChr) > 0 Then
					For j As Integer = 1 To Cast(Grid Ptr, Parent)->Columns.Count - 1
						gtk_list_store_set (GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter, j + 1, ToUtf8(PItem->Text(j)), -1)
					Next j
				End If
			Return PItem
		End Function
	#endif
	
	Private Function GridRows.Add(ByRef FCaption As WString = "", ByRef FImageKey As WString, State As Integer = 0, Indent As Integer = 0, Index As Integer = -1, RowEditable As Boolean = False, ColorBK As Integer = -1, ColorText As Integer = -1, ByRef DelimiterChr As String = "", ByVal IsLastItem As Boolean = True) As GridRow Ptr
		If Parent AndAlso Cast(Grid Ptr, Parent)->Images Then
			PItem = Add(FCaption, Cast(Grid Ptr, Parent)->Images->IndexOf(FImageKey), State, Indent, Index, RowEditable, ColorBK, ColorText, DelimiterChr, IsLastItem)
		Else
			PItem = Add(FCaption, -1, State, Indent, Index, RowEditable, ColorBK, ColorText, DelimiterChr, IsLastItem)
		End If
		If PItem Then PItem->ImageKey = FImageKey
		Return PItem
	End Function
	
	Private Function GridRows.Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, State As Integer = 0, Indent As Integer = 0, InsertBefore As Boolean = True, RowEditable As Boolean = False, ColorBK As Integer = -1, ColorText As Integer = -1, DuplicateIndex As Integer = -1, ByRef DelimiterChr As String = "", ByVal IsLastItem As Boolean = True) As GridRow Ptr
		If Not InsertBefore Then Index += 1
		If Index > FItems.Count - 1 Then Return Add(FCaption, FImageIndex, State, Indent, Index, RowEditable, ColorBK, ColorText, DelimiterChr, IsLastItem)
		Dim As GridRow Ptr PItem, tGridRow, tGridRowD
		PItem = _New(GridRow)
		FItems.Insert Index, PItem
		Dim As Integer FixCols = 1
		If Parent <> 0 Then FixCols = IIf(Cast(Grid Ptr, Parent)->FixCols, 1, 0)
		With *PItem
			.Parent         = Parent
			.ImageIndex     = FImageIndex
				Dim As GtkWidget Ptr ParentTemp = Parent->Handle
				Parent->Handle = 0
			.Text(FixCols)        = FCaption
			If DuplicateIndex >= 0 Then tGridRowD = Cast(Grid Ptr, Parent)->Rows.Item(DuplicateIndex)
			.Editable = IIf(DuplicateIndex >= 0, tGridRowD->Editable, RowEditable)
			.BackColor = IIf(DuplicateIndex >= 0, tGridRowD->BackColor, ColorBK)
			.ForeColor = IIf(DuplicateIndex >= 0, tGridRowD->ForeColor, ColorText)
			.State          = State
			.Indent         = Indent
				Parent->Handle = ParentTemp
		End With
			Cast(Grid Ptr, Parent)->Clear
			If Index <> -1 Then 'iSortStyle <> SortStyle.ssNone OrElse
				gtk_list_store_insert(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter, Index)
			Else
				gtk_list_store_append(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter)
			End If
			gtk_list_store_set (GTK_LIST_STORE(GridGetModel(Parent->Handle)), @PItem->TreeIter, 3, ToUtf8(IIf(FCaption = "", !"\0", FCaption)), -1)
		If Parent > 0 AndAlso Index > 0 Then
			Dim As GridCell Ptr tGridCell, tGridCellD
			For j As Integer = 0 To Cast(Grid Ptr, Parent)->Columns.Count - 1
				tGridRow = Cast(Grid Ptr, Parent)->Rows.Item(Index)
				tGridCell = tGridRow->Item(j)
				If DuplicateIndex >= 0 Then tGridCellD = tGridRow->Item(DuplicateIndex)
				tGridCell->Editable = IIf(DuplicateIndex >= 0, tGridCellD->Editable, RowEditable)
				tGridCell->BackColor = IIf(DuplicateIndex >= 0, tGridCellD->BackColor, ColorBK)
				tGridCell->ForeColor = IIf(DuplicateIndex >= 0, tGridCellD->ForeColor, ColorText)
			Next
		End If
		Return PItem
	End Function
	
	Private Sub GridRows.Remove(Index As Integer)
		If FItems.Count < 1 OrElse Index < 0 OrElse Index > FItems.Count - 1 Then Exit Sub
			If Parent AndAlso Parent->Handle Then
				gtk_list_store_remove(GTK_LIST_STORE(GridGetModel(Parent->Handle)), @This.Item(Index)->TreeIter)
			End If
		FItems.Remove Index
	End Sub
	
	Private Function GridRows.IndexOf(ByRef FItem As GridRow Ptr) As Integer
		Return FItems.IndexOf(FItem)
	End Function
	
	Private Sub GridRows.Clear
			If Parent AndAlso GTK_LIST_STORE(GridGetModel(Parent->Handle)) Then gtk_list_store_clear(GTK_LIST_STORE(GridGetModel(Parent->Handle)))
		For i As Integer = Count -1 To 0 Step -1
			_Delete( @QGridRow(FItems.Items[i]))
		Next i
		FItems.Clear
	End Sub
	
	Private Operator GridRows.[](Index As Integer) ByRef As GridRow
		Return *Item(Index)
	End Operator
	
	Private Operator GridRows.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor GridRows
		This.Clear
		
	End Constructor
	
	Private Destructor GridRows
		This.Clear
	End Destructor
	
	Private Property GridColumns.Count As Integer
		Return FColumns.Count
	End Property
	
	Private Property GridColumns.Count(Value As Integer)
	End Property
	
	Private Property GridColumns.Column(Index As Integer) As GridColumn Ptr
		Return FColumns.Items[Index]
	End Property
	
	Private Property GridColumns.Column(Index As Integer, Value As GridColumn Ptr)
		FColumns.Items[Index] = Value
	End Property
	
		Private Sub GridColumns.Cell_Edited(renderer As GtkCellRendererText Ptr, path As gchar Ptr, new_text As gchar Ptr, user_data As Any Ptr)
			Dim As GridColumn Ptr PColumn = user_data
			If PColumn = 0 Then Exit Sub
			Dim As Grid Ptr lv = Cast(Grid Ptr, PColumn->Parent)
			If lv = 0 Then Exit Sub
			If lv->OnCellEdited Then lv->OnCellEdited(*lv->Designer, *lv, Val(*path), PColumn->Index, *new_text)
		End Sub
		
		Private Sub GridColumns.Check(cell As GtkCellRendererToggle Ptr, path As gchar Ptr, user_data As Any Ptr)
			Dim As Grid Ptr lv = user_data
			Dim As GtkListStore Ptr model = GTK_LIST_STORE(GridGetModel(lv->Handle))
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
	
	Private Function GridColumns.Add(ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = 100, Format As ColumnFormat = cfLeft, ColEditable As Boolean = False, ColBackColor As Integer = -1, ColForeColor As Integer = -1) As GridColumn Ptr
		Dim As GridColumn Ptr PColumn
		Dim As Integer Index
		PColumn = _New(GridColumn)
		FColumns.Add PColumn
		Index = FColumns.Count - 1
		With *PColumn
			.ImageIndex     = FImageIndex
			.Text           = FCaption
			.Index          = Index
			.Width          = iWidth
			.Format         = Format
			.Editable       = ColEditable
			.BackColor      = ColBackColor
			.ForeColor      = ColForeColor
			If Parent > 0 Then
				Dim As GridRow Ptr tGridRow
				Dim As GridCell Ptr tGridCell
				For j As Integer = 0 To Cast(Grid Ptr, Parent)->Rows.Count - 1
					tGridRow = Cast(Grid Ptr, Parent)->Rows.Item(j)
					tGridRow->ColumnEvents(Index)
					tGridRow->State = 0
					tGridCell = tGridRow->Item(Index)
					tGridCell->Editable = ColEditable
					tGridCell->BackColor = ColBackColor
					tGridCell->ForeColor = ColForeColor
				Next
			End If
		End With
		
			If Parent Then
				PColumn->Column = gtk_tree_view_column_new()
				gtk_tree_view_column_set_reorderable(PColumn->Column, Cast(Grid Ptr, Parent)->AllowColumnReorder)
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
			End If
		If Parent Then
			PColumn->Parent = Parent
			If Parent->Handle Then
					
			End If
		End If
		Return PColumn
	End Function
	
	Private Sub GridColumns.Insert(Index As Integer, ByRef FCaption As WString = "", FImageIndex As Integer = -1, iWidth As Integer = -1, Format As ColumnFormat = cfLeft, InsertBefore As Boolean = True, ColEditable As Boolean = False, ColBackColor As Integer = -1, ColForeColor As Integer = -1, DuplicateIndex As Integer = -1)
		If Not InsertBefore Then
			Index += 1
		ElseIf Index = 0 Then
			Exit Sub
		End If
		If Index > FColumns.Count - 1 Then Add(FCaption, FImageIndex, iWidth, Format, ColEditable, ColBackColor, ColForeColor) : Exit Sub
		Dim As GridColumn Ptr PColumn, tColumn
	End Sub
	
	Private Sub GridColumns.Remove(Index As Integer)
		FColumns.Remove Index
	End Sub
	
	Private Function GridColumns.IndexOf(ByRef FColumn As GridColumn Ptr) As Integer
		Return FColumns.IndexOf(FColumn)
	End Function
	
	Private Sub GridColumns.Clear
		For i As Integer = Count -1 To 0 Step -1
			_Delete( @QGridColumn(FColumns.Items[i]))
			FColumns.Remove i
		Next i
		FColumns.Clear
	End Sub
	
	Private Operator GridColumns.[](Index As Integer) ByRef As GridColumn
		Return *Column(Index)
	End Operator
	
	Private Operator GridColumns.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor GridColumns
		This.Clear
	End Constructor
	
	Private Destructor GridColumns
		This.Clear
	End Destructor
	
	#ifndef ReadProperty_Off
		Private Function Grid.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "allowcolumnreorder": Return @FAllowColumnReorder
			Case "columnheaderhidden": Return @FColumnHeaderHidden
			Case "fullrowselect": Return @FFullRowSelect
			Case "ownerdata": Return @FOwnerData
			Case "colorselected" : Return @FGridColorSelected
			Case "ColorEditBack" : Return @FGridColorEditBack
			Case "coloreditfore" : Return @FGridColorEditFore
			Case "colorline" : Return @FGridColorLine
			Case "hovertime": Return @FHoverTime
			Case "gridlines": Return @FGridLines
			Case "images": Return Images
			Case "stateimages": Return StateImages
			Case "smallimages": Return SmallImages
			Case "singleclickactivate": Return @FSingleClickActivate
			Case "sortindex": Return @FSortIndex
			Case "tabindex": Return @FTabIndex
			Case "hoverselection": Return @FHoverSelection
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Grid.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "allowcolumnreorder": AllowColumnReorder = QBoolean(Value)
				Case "columnheaderhidden": ColumnHeaderHidden = QBoolean(Value)
				Case "fullrowselect": FullRowSelect = QBoolean(Value)
				Case "ownerdata": OwnerData = QBoolean(Value)
				Case "colorselected" : FGridColorSelected = QInteger(Value)
				Case "coloreditback" : FGridColorEditBack = QInteger(Value)
				Case "coloreditfore" : FGridColorEditFore = QInteger(Value)
				Case "colorline" : FGridColorLine = QInteger(Value)
				Case "hovertime": HoverTime = QInteger(Value)
				Case "gridlines": GridLines = QBoolean(Value)
				Case "images": Images = Cast(ImageList Ptr, Value)
				Case "stateimages": StateImages = Cast(ImageList Ptr, Value)
				Case "smallimages": SmallImages = Cast(ImageList Ptr, Value)
				Case "singleclickactivate": SingleClickActivate = QBoolean(Value)
				Case "sortindex": FSortIndex = QInteger(Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case "hoverselection": HoverSelection = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property Grid.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property Grid.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property Grid.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property Grid.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Sub Grid.Clear()
		If LBound(DataArrayPtr) <= UBound(DataArrayPtr) Then
			Dim As Integer LboundData = LBound(DataArrayPtr, 2)
			Dim As Integer UboundData = UBound(DataArrayPtr, 2)
			For i As Integer = LBound(DataArrayPtr, 1) To UBound(DataArrayPtr, 1)
				For j As Integer = LboundData To UboundData
					Deallocate DataArrayPtr(i, j)
				Next
			Next
		End If
		Erase DataArrayPtr
			If gtk_tree_view_get_model(GTK_TREE_VIEW(widget)) = NULL Then
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
				gtk_tree_view_set_model(GTK_TREE_VIEW(widget), GTK_TREE_MODEL(ListStore))
				gtk_tree_view_set_enable_tree_lines(GTK_TREE_VIEW(widget), True)
			End If
	End Sub
	
	Private Property Grid.ColumnHeaderHidden As Boolean
		Return FColumnHeaderHidden
	End Property
	
	Private Property Grid.ColumnHeaderHidden(Value As Boolean)
		FColumnHeaderHidden = Value
			gtk_tree_view_set_headers_visible(GTK_TREE_VIEW(widget), Not Value)
	End Property
	
	Private Function Grid.Cells(RowIndex As Integer, ColumnIndex As Integer) As GridCell Ptr
		Return Rows.Item(RowIndex)->Item(ColumnIndex)
	End Function
	
	#ifndef Grid_ChangeLVExStyle_Off
		Private Sub Grid.ChangeLVExStyle(iStyle As Integer, Value As Boolean)
		End Sub
	#endif
	
	Private Property Grid.SingleClickActivate As Boolean
		Return FSingleClickActivate
	End Property
	
	Private Property Grid.SingleClickActivate(Value As Boolean)
		If FSingleClickActivate = Value Then Return
		FSingleClickActivate = Value
				gtk_tree_view_set_activate_on_single_click(GTK_TREE_VIEW(widget), Value)
	End Property
	
	Private Property Grid.HoverSelection As Boolean
		Return FHoverSelection
	End Property
	
	Private Property Grid.HoverSelection(Value As Boolean)
		If FHoverSelection = Value Then Return
		FHoverSelection = Value
			gtk_tree_view_set_hover_selection(GTK_TREE_VIEW(widget), Value)
	End Property
	
	Private Property Grid.HoverTime As Integer
		Return FHoverTime
	End Property
	
	Private Property Grid.HoverTime(Value As Integer)
		FHoverTime = Value
	End Property
	
	Private Property Grid.AllowEdit As Boolean
		Return FAllowEdit
	End Property
	
	Private Property Grid.AllowEdit(Value As Boolean)
		FAllowEdit = Value
	End Property
	
	Private Property Grid.FixCols As Integer
		Return FFixCols
	End Property
	
	Private Property Grid.FixCols(Value As Integer)
		FFixCols = IIf(Value > 0, 1, 0)
	End Property
	
	Private Property Grid.AllowColumnReorder As Boolean
		Return FAllowColumnReorder
	End Property
	
	Private Property Grid.AllowColumnReorder(Value As Boolean)
		If FAllowColumnReorder = Value Then Return
		FAllowColumnReorder = Value
			For i As Integer = 0 To Columns.Count - 1
				gtk_tree_view_column_set_reorderable(Columns.Column(i)->Column, Value)
			Next
	End Property
	
	Private Property Grid.GridLines As Boolean
		Return FGridLines
	End Property
	
	Private Property Grid.GridLines(Value As Boolean)
		If FGridLines = Value Then Return
		FGridLines = Value
			gtk_tree_view_set_grid_lines(GTK_TREE_VIEW(widget), IIf(Value, GTK_TREE_VIEW_GRID_LINES_BOTH, GTK_TREE_VIEW_GRID_LINES_NONE))
	End Property
	
	Private Property Grid.FullRowSelect As Boolean
		Return FFullRowSelect
	End Property
	
	Private Property Grid.FullRowSelect(Value As Boolean)
		If FFullRowSelect = Value Then Return
		FFullRowSelect = Value
	End Property
	
	Private Property Grid.OwnerData As Boolean
		Return FOwnerData
	End Property
	
	Private Property Grid.OwnerData(Value As Boolean)
		FOwnerData = Value
	End Property
	
	Private Property Grid.ColorSelected As Integer
		Return FGridColorSelected
	End Property
	
	Private Property Grid.ColorSelected(Value As Integer)
		FGridColorSelected = Value
	End Property
	
	
	Private Property Grid.ColorEditBack(Value As Integer)
		FGridColorEditBack = Value
	End Property
	
	Private Property Grid.ColorEditBack As Integer
		Return FGridColorEditBack
	End Property
	
	Private Property Grid.ColorEditFore(Value As Integer)
		FGridColorEditFore = Value
	End Property
	
	Private Property Grid.ColorEditFore As Integer
		Return FGridColorEditFore
	End Property
	
	Private Property Grid.ColorLine(Value As Integer)
		FGridColorEditFore = Value
	End Property
	
	Private Property Grid.ColorLine As Integer
		Return FGridColorLine
	End Property
	
	Private Property Grid.SelectedRowIndex As Integer
			Dim As GtkTreeIter iter
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
		Return -1
	End Property
	
	Private Property Grid.SelectedRowIndex(Value As Integer)
			If TreeSelection Then
				If Value = -1 Then
					gtk_tree_selection_unselect_all(TreeSelection)
				ElseIf Value > -1 AndAlso Value < Rows.Count Then
					Dim As GtkTreeIter iter
					gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(ListStore), @iter, Trim(Str(Value)))
					gtk_tree_selection_select_iter(TreeSelection, @iter)
					gtk_tree_view_scroll_to_cell(GTK_TREE_VIEW(widget), gtk_tree_model_get_path(GTK_TREE_MODEL(ListStore), @iter), NULL, False, 0, 0)
				End If
			End If
	End Property
	
	Private Property Grid.SelectedRow As GridRow Ptr
			Dim As GtkTreeIter iter
			If gtk_tree_selection_get_selected(TreeSelection, NULL, @iter) Then
				Return Rows.FindByIterUser_Data(iter.user_data)
			End If
		Return 0
	End Property
	
	#ifndef Grid_SelectedRow_Off
		Private Property Grid.SelectedRow(Value As GridRow Ptr)
			Value->SelectItem
		End Property
	#endif
	
	Private Property Grid.SelectedColumn As GridColumn Ptr
		Return Columns.Column(FCol)
	End Property
	
	#ifndef Grid_SelectedColumn_Off
		Private Property Grid.SelectedColumn(Value As GridColumn Ptr)
			FCol = Value->Index
		End Property
	#endif
	
	Private Property Grid.SelectedColumnIndex As Integer
		Return FCol
	End Property
	
	Private Property Grid.SelectedColumnIndex(Value As Integer)
		FCol = Value
	End Property
	
	Private Property Grid.SortIndex As Integer
		Return FSortIndex
	End Property
	
	Private Property Grid.SortIndex(Value As Integer)
		FSortIndex = Value+ FFixCols
		'#ifndef __USE_GTK__
		'	Select Case FSortStyle
		'	Case SortStyle.ssNone
		'		ChangeStyle LVS_SORTASCENDING, False
		'		ChangeStyle LVS_SORTDESCENDING, False
		'	Case SortStyle.ssSortAscending
		'		ChangeStyle LVS_SORTDESCENDING, False
		'		ChangeStyle LVS_SORTASCENDING, True
		'	Case SortStyle.ssSortDescending
		'		ChangeStyle LVS_SORTASCENDING, False
		'		ChangeStyle LVS_SORTDESCENDING, True
		'	End Select
		'#endif
	End Property
	
	Private Property Grid.SortOrder As SortStyle
		Return FSortOrder
	End Property
	
	Private Property Grid.SortOrder(Value As SortStyle)
		FSortOrder = Value
		'#ifndef __USE_GTK__
		'	Select Case FSortStyle
		'	Case SortStyle.ssNone
		'		ChangeStyle LVS_SORTASCENDING, False
		'		ChangeStyle LVS_SORTDESCENDING, False
		'	Case SortStyle.ssSortAscending
		'		ChangeStyle LVS_SORTDESCENDING, False
		'		ChangeStyle LVS_SORTASCENDING, True
		'	Case SortStyle.ssSortDescending
		'		ChangeStyle LVS_SORTASCENDING, False
		'		ChangeStyle LVS_SORTDESCENDING, True
		'	End Select
		'#endif
	End Property
	Private Property Grid.ShowHint As Boolean
		Return FShowHint
	End Property
	
	Private Property Grid.ShowHint(Value As Boolean)
		FShowHint = Value
	End Property
	
	
	Private Sub Grid.ProcessMessage(ByRef Message As Message)
			Dim As GdkEvent Ptr e = Message.Event
			Select Case Message.Event->type
			Case GDK_MAP
				Clear
			Case GDK_BUTTON_RELEASE
				If SelectedRowIndex <> -1 Then
					If OnRowClick Then OnRowClick(*Designer, This, SelectedRowIndex)
				End If
				Case GDK_2BUTTON_PRESS, GDK_DOUBLE_BUTTON_PRESS
				If SelectedRowIndex <> -1 Then
					If OnRowDblClick Then OnRowDblClick(*Designer, This, SelectedRowIndex)
				End If
			Case GDK_KEY_PRESS
				If SelectedRowIndex <> -1 Then
					If OnRowKeyDown Then OnRowKeyDown(*Designer, This, SelectedRowIndex, Message.Event->key.keyval, Message.Event->key.state)
				End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
	
	
		Private Sub Grid.Grid_RowActivated(tree_view As GtkTreeView Ptr, path As GtkTreePath Ptr, column As GtkTreeViewColumn Ptr, user_data As Any Ptr)
			Dim As Grid Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeModel Ptr model
				Dim As GtkTreeIter iter
				model = gtk_tree_view_get_model(tree_view)
				If gtk_tree_model_get_iter(model, @iter, path) Then
					If lv->OnRowActivate Then lv->OnRowActivate(*lv->Designer, *lv, Val(*gtk_tree_model_get_string_from_iter(model, @iter)))
				End If
			End If
		End Sub
		
		Private Sub Grid.Grid_SelectionChanged(selection As GtkTreeSelection Ptr, user_data As Any Ptr)
			Dim As Grid Ptr lv = Cast(Any Ptr, user_data)
			If lv Then
				Dim As GtkTreeIter iter
				Dim As GtkTreeModel Ptr model
				If gtk_tree_selection_get_selected(selection, @model, @iter) Then
					Dim As Integer SelectedIndex = Val(*gtk_tree_model_get_string_from_iter(model, @iter))
					If lv->PrevIndex <> SelectedIndex AndAlso lv->PrevIndex <> -1 Then
						Dim bCancel As Boolean
						If lv->OnSelectedRowChanging Then lv->OnSelectedRowChanging(*lv->Designer, *lv, lv->PrevIndex, bCancel)
						If bCancel Then
							lv->SelectedRowIndex = lv->PrevIndex
							Exit Sub
						End If
					End If
					If lv->OnSelectedRowChanged Then lv->OnSelectedRowChanged(*lv->Designer, *lv, SelectedIndex)
					lv->PrevIndex = SelectedIndex
				End If
			End If
		End Sub
		
		Private Sub Grid.Grid_Map(widget As GtkWidget Ptr, user_data As Any Ptr)
			Dim As Grid Ptr lv = user_data
			lv->Clear
		End Sub
		
		Private Function Grid.Grid_Scroll(self As GtkAdjustment Ptr, user_data As Any Ptr) As Boolean
			Dim As Grid Ptr lv = user_data
			If lv->OnEndScroll Then lv->OnEndScroll(*lv->Designer, *lv)
			Return True
		End Function
	
	Private Operator Grid.[](RowIndex As Integer) ByRef As GridRow
		Return *Rows.Item(RowIndex)
	End Operator
	
	Private Operator Grid.Cast As Control Ptr
		Return @This
	End Operator
	
	Private Sub Grid.EnsureVisible(Index As Integer)
			If GTK_IS_ICON_VIEW(widget) Then
				gtk_icon_view_select_path(GTK_ICON_VIEW(widget), gtk_tree_path_new_from_string(Trim(Str(Index))))
			Else
				If TreeSelection Then
					If Index > -1 AndAlso Index < Rows.Count Then
						Dim As GtkTreeIter iter
						gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(ListStore), @iter, Trim(Str(Index)))
						gtk_tree_view_scroll_to_cell(GTK_TREE_VIEW(widget), gtk_tree_model_get_path(GTK_TREE_MODEL(ListStore), @iter), NULL, False, 0, 0)
					End If
				End If
			End If
	End Sub
	
	Private Function Grid.SaveToFile(ByRef FileName As WString, ByRef DelimiterChr As String = Chr(9)) As Boolean
		Dim As Integer Fn
		Fn = FreeFile_
		If Open(FileName For Output Encoding "utf-8" As #Fn) = 0 Then
			Dim As WString Ptr tmpStr
			WLet(tmpStr, Columns.Column(FFixCols)->Text)
			For iCol As Integer = FFixCols + 1 To Columns.Count - 1
				WAdd tmpStr, DelimiterChr & Columns.Column(iCol)->Text
			Next
			Print #Fn, *tmpStr
			For iRow As Integer = 0 To Rows.Count - 1
				WLet(tmpStr, Rows.Item(iRow)->Text(FFixCols))
				For iCol As Integer = FFixCols + 1 To Columns.Count - 1
					WAdd tmpStr, DelimiterChr & Rows.Item(iRow)->Text(iCol)
				Next
				Print #Fn, *tmpStr
			Next
			_Deallocate(tmpStr)
		Else
			Debug.Print Date & " " & Time & Chr(9) & __FUNCTION__ & Chr(9) & ML("Open file failure!") & " " & FileName, True
			CloseFile_(Fn)
			Return False
		End If
		CloseFile_(Fn)
		Return True
	End Function
	'
	Private Function Grid.LoadFromFile(ByRef FileName As WString, ByRef DelimiterChr As String = "", ByVal HasTitle As Boolean = True, ByVal ReadToArrary As Boolean = True) As Integer
		Dim As Integer Fn, iRowsCount, Result, ArrayUbound, items = 100
		Fn = FreeFile_
		Result = Open(FileName For Input Encoding "utf-8" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-16" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input Encoding "utf-32" As #Fn)
		If Result <> 0 Then Result = Open(FileName For Input As #Fn)
		If Result = 0 Then
			Dim As WString * 2048 tmpStr
			Dim As WString Ptr ColTitle(Any)
			Dim As Integer iPos
			If ReadToArrary AndAlso LBound(DataArrayPtr) <= UBound(DataArrayPtr) Then
				Dim As Integer LboundData = LBound(DataArrayPtr, 2)
				Dim As Integer UboundData = UBound(DataArrayPtr, 2)
				For i As Integer = LBound(DataArrayPtr, 1) To UBound(DataArrayPtr, 1)
					For j As Integer = LboundData To UboundData
						Deallocate DataArrayPtr(i, j)
					Next
				Next
				ReDim DataArrayPtr(0, 0)
			End If
			Line Input #Fn, tmpStr
			If DelimiterChr = "" Then
				If InStr(tmpStr, Chr(9)) Then
					DelimiterChr =  Chr(9)
				Else
					DelimiterChr = IIf(InStr(tmpStr, "|"), "|", IIf(InStr(tmpStr, ","), ",", ";"))
				End If
			End If
			If HasTitle Then
				Columns.Clear
				Rows.Clear
				Split(tmpStr, DelimiterChr, ColTitle())
				ArrayUbound = UBound(ColTitle) + FFixCols
				If FFixCols > 0 Then Columns.Add "NO.", , 30 , cfRight
				For i As Integer = 0 To UBound(ColTitle)
					Columns.Add *ColTitle(i)
					Deallocate ColTitle(i) : ColTitle(i) = 0
				Next
				Erase ColTitle
				If ReadToArrary Then ReDim DataArrayPtr(0 To items, 0 To ArrayUbound)
			Else
				iRowsCount += 1
				If ReadToArrary Then
					Split(tmpStr, DelimiterChr, ColTitle())
					ArrayUbound = UBound(ColTitle) + FFixCols
					ReDim DataArrayPtr(0 To items, 0 To ArrayUbound)
					For i As Integer = 0 To ArrayUbound
						DataArrayPtr(iRowsCount - 1, i) = ColTitle(i)
					Next
					Erase ColTitle
				Else
					Rows.Add tmpStr, , , , , , , ,  DelimiterChr, False
				End If
			End If
			Dim As Long ii = 1, n = 0, tLen = Len(DelimiterChr), ls, p = 1
			
			While Not EOF(Fn)
				Line Input #Fn, tmpStr
				ii = 1: n = 0: ls = Len(tmpStr): p = 1
				iRowsCount += 1
				If ReadToArrary Then
					If (iRowsCount >= items ) Then
						items += 100
						ReDim Preserve DataArrayPtr(0 To items, 0 To ArrayUbound)
					End If
					Do While ii <= ls
						If Mid(tmpStr, ii, tLen) = DelimiterChr Then
							If n > ArrayUbound Then Exit Do
							n = n + 1
							WLet(DataArrayPtr(iRowsCount - 1, n - 1), Mid(tmpStr, p, ii - p))
							p = ii + tLen
							ii = p
							Continue Do
						End If
						ii = ii + 1
					Loop
					n = n + 1
					'Debug.Print " iRowsCount=" & iRowsCount & " n=" & n
					WLet(DataArrayPtr(iRowsCount - 1, n - 1), Mid(tmpStr, p, ii - p))
				Else
					Rows.Add tmpStr, , , , , , , , DelimiterChr, False
				End If
			Wend
			Rows.Count = iRowsCount   'This is the same as is LastItem parameter of ListItems.Add function
			If ReadToArrary Then ReDim Preserve DataArrayPtr(0 To iRowsCount - 1, 0 To ArrayUbound)
		Else
			Debug.Print Date & " " & Time & " " & Chr(9) & __FUNCTION__ & " " & Chr(9) & ML("Open file failure!") & " " & FileName, True
			CloseFile_(Fn)
			Return 0
		End If
		CloseFile_(Fn)
		Return iRowsCount
	End Function
	Private Constructor Grid
			ListStore = gtk_list_store_new(3, G_TYPE_BOOLEAN, GDK_TYPE_PIXBUF, G_TYPE_STRING)
			scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
			gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
			'widget = gtk_tree_view_new_with_model(gtk_tree_model(ListStore))
			widget = gtk_tree_view_new()
			gtk_container_add(GTK_CONTAINER(scrolledwidget), widget)
			TreeSelection = gtk_tree_view_get_selection(GTK_TREE_VIEW(widget))
				g_signal_connect(gtk_scrollable_get_hadjustment(GTK_SCROLLABLE(widget)), "value-changed", G_CALLBACK(@Grid_Scroll), @This)
				g_signal_connect(gtk_scrollable_get_vadjustment(GTK_SCROLLABLE(widget)), "value-changed", G_CALLBACK(@Grid_Scroll), @This)
			g_signal_connect(GTK_TREE_VIEW(widget), "map", G_CALLBACK(@Grid_Map), @This)
			g_signal_connect(GTK_TREE_VIEW(widget), "row-activated", G_CALLBACK(@Grid_RowActivated), @This)
			g_signal_connect(G_OBJECT(TreeSelection), "changed", G_CALLBACK (@Grid_SelectionChanged), @This)
			gtk_tree_view_set_enable_tree_lines(GTK_TREE_VIEW(widget), True)
			gtk_tree_view_set_grid_lines(GTK_TREE_VIEW(widget), GTK_TREE_VIEW_GRID_LINES_BOTH)
			ColumnTypes = _New( GType[3])
			ColumnTypes[0] = G_TYPE_BOOLEAN
			ColumnTypes[1] = GDK_TYPE_PIXBUF
			ColumnTypes[2] = G_TYPE_STRING
			This.RegisterClass "Grid", @This
		BorderStyle = BorderStyles.bsClient
		FOwnerData = False
		Rows.Parent = @This
		Columns.Parent = @This
		DoubleBuffered = True
		FEnabled = True
		FGridLines = True
		FFullRowSelect = True
		FVisible = True
		FTabIndex          = -1
		FTabStop           = True
		With GridEditText
			.Parent = @This
			.Multiline= False
			.BackColor = FGridColorEditBack
			.ForeColor = FGridColorEditFore
			.BringToFront
		End With
		With This
			.Child             = @This
			WLet(FClassName, "Grid")
			.Width             = 121
			.Height            = 121
		End With
	End Constructor
	
	Private Destructor Grid
		Rows.Clear
		Columns.Clear
			If ColumnTypes Then _DeleteSquareBrackets( ColumnTypes)
	End Destructor
End Namespace