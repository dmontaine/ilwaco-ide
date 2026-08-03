'###############################################################################
'#  ComboBoxEx.bi                                                              #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                    #
'#  Version 1.0.0                                                              #
'###############################################################################

#include once "ComboBoxEx.bi"

Namespace My.Sys.Forms
	Private Function ComboBoxItem.Index As Integer
		If Parent Then
			Return Cast(ComboBoxEx Ptr, Parent)->Items.IndexOf(@This)
		Else
			Return -1
		End If
	End Function
	
	Private Property ComboBoxItem.Text ByRef As WString
		'        If Parent AndAlso Parent->Handle Then
		'            WReallocate FText, 255
		'            Dim cbei As COMBOBOXEXITEM
		'            cbei.mask = CBEIF_TEXT
		'            cbei.iItem = Index
		'                cbei.pszText    = FText
		'                cbei.cchTextMax = 255
		'              Parent->Perform CBEM_GETITEM, 0, CInt(@cbei)
		'          End If
		Return WGet(FText)
	End Property
	
	Private Property ComboBoxItem.Text(ByRef Value As WString)
		WLet(FText, Value)
			If Parent AndAlso Parent->Handle Then
				gtk_list_store_set (Cast(ComboBoxEx Ptr, Parent)->ListStore, @TreeIter, 1, ToUtf8(Value), -1)
			End If
	End Property
	
	Private Property ComboBoxItem.Object As Any Ptr
		Return FObject
	End Property
	
	Private Property ComboBoxItem.Object(Value As Any Ptr)
		FObject = Value
	End Property
	
	Private Property ComboBoxItem.Hint ByRef As WString
		Return WGet(FHint)
	End Property
	
	Private Property ComboBoxItem.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	
	Private Property ComboBoxItem.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property ComboBoxItem.ImageIndex(Value As Integer)
		If Value <> FImageIndex Then
			FImageIndex = Value
		End If
	End Property
	
	Private Property ComboBoxItem.ImageKey ByRef As WString
		Return WGet(FImageKey)
	End Property
	
	Private Property ComboBoxItem.ImageKey(ByRef Value As WString)
		WLet(FImageKey, Value)
			If Parent AndAlso Parent->Handle Then
				gtk_list_store_set (Cast(ComboBoxEx Ptr, Parent)->ListStore, @TreeIter, 0, ToUtf8(Value), -1)
			End If
	End Property
	
	Private Property ComboBoxItem.SelectedImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property ComboBoxItem.SelectedImageIndex(Value As Integer)
		If Value <> FSelectedImageIndex Then
			FSelectedImageIndex = Value
		End If
	End Property
	
	Private Property ComboBoxItem.OverlayIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property ComboBoxItem.OverlayIndex(Value As Integer)
		If Value <> FOverlayIndex Then
			FOverlayIndex = Value
		End If
	End Property
	
	Private Property ComboBoxItem.Indent As Integer
		Return FIndent
	End Property
	
	Private Property ComboBoxItem.Indent(Value As Integer)
		If Value <> FIndent Then
			FIndent = Value
		End If
	End Property
	
	Private Operator ComboBoxItem.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ComboBoxItem
		WLet(FHint, "")
		WLet(FText, "")
		FImageIndex = -1
		FSelectedImageIndex = -1
		FOverlayIndex = -1
	End Constructor
	
	Private Destructor ComboBoxItem
		If FHint Then _Deallocate( FHint)
		If FText Then _Deallocate( FText)
		If FImageKey Then _Deallocate( FImageKey)
	End Destructor
	
	Private Property ComboBoxExItems.Count As Integer
		Return FItems.Count
	End Property
	
	Private Property ComboBoxExItems.Count(Value As Integer)
	End Property
	
	Private Property ComboBoxExItems.Item(Index As Integer) As ComboBoxItem Ptr
		If Index > -1 AndAlso Index < FItems.Count Then Return QComboBoxItem(FItems.Items[Index]) Else Return 0
	End Property
	
	Private Property ComboBoxExItems.Item(Index As Integer, Value As ComboBoxItem Ptr)
		'QToolButton(FItems.Items[Index]) = Value
	End Property
	
	Private Function ComboBoxExItems.Add(ByRef FText As WString = "", Obj As Any Ptr = 0, FImageIndex As Integer = -1, FSelectedImageIndex As Integer = -1, FOverlayIndex As Integer = -1, FIndent As Integer = 0, Index As Integer = -1) As ComboBoxItem Ptr
		PItem = _New( ComboBoxItem)
		Dim i As Integer
		If Cast(ComboBoxEx Ptr, Parent)->Sort Then
			For i = 0 To FItems.Count - 1
				If Item(i)->Text > FText Then Exit For
			Next
			FItems.Insert i, PItem
		Else
			If Index = -1 Then
				FItems.Add PItem
			Else
				FItems.Insert Index, PItem
			End If
		End If
		With *PItem
			.ImageIndex         = FImageIndex
			.SelectedImageIndex = FSelectedImageIndex
			.OverlayIndex       = FOverlayIndex
			.Indent     		= FIndent
			.Text        		= FText
			.Object        		= Obj
		End With
			If Cast(ComboBoxEx Ptr, Parent)->Sort Then
				gtk_list_store_insert(Cast(ComboBoxEx Ptr, Parent)->ListStore, @PItem->TreeIter, i)
			Else
					gtk_list_store_insert(Cast(ComboBoxEx Ptr, Parent)->ListStore, @PItem->TreeIter, Index)
			End If
			gtk_list_store_set (Cast(ComboBoxEx Ptr, Parent)->ListStore, @PItem->TreeIter, 1, ToUtf8(FText), -1)
			'gtk_widget_show_all(Parent->widget)
		If Parent Then
			PItem->Parent = Parent
		End If
		Return PItem
	End Function
	
	Private Function ComboBoxExItems.Add(ByRef FText As WString = "", Obj As Any Ptr = 0, ByRef ImageKey As WString, ByRef SelectedImageKey As WString = "", ByRef OverlayKey As WString = "", Indent As Integer = 0, Index As Integer = -1) As ComboBoxItem Ptr
		Dim Value As ComboBoxItem Ptr
		If Parent AndAlso Cast(ComboBoxEx Ptr, Parent)->ImagesList Then
			With *Cast(ComboBoxEx Ptr, Parent)->ImagesList
				Value = Add(FText, Obj, .IndexOf(ImageKey), .IndexOf(SelectedImageKey), .IndexOf(OverlayKey), Indent, Index)
				Value->ImageKey = ImageKey
			End With
		Else
			Value = Add(FText, Obj, -1, -1, -1, Indent, Index)
		End If
		Return Value
	End Function
	
	Private Sub ComboBoxExItems.Remove(Index As Integer)
		If Index = -1 Then Exit Sub
		If Parent Then
				gtk_list_store_remove(Cast(ComboBoxEx Ptr, Parent)->ListStore, @This.Item(Index)->TreeIter)
		End If
		_Delete( Cast(ComboBoxItem Ptr, FItems.Items[Index]))
		FItems.Remove Index
	End Sub
	
	Private Function ComboBoxExItems.IndexOf(ByRef FItem As ComboBoxItem Ptr) As Integer
		Return FItems.IndexOf(FItem)
	End Function
	
	Private Function ComboBoxExItems.IndexOf(ByRef Text As WString) As Integer
		For i As Integer = 0 To FItems.Count - 1
			If (*Cast(ComboBoxItem Ptr, FItems.Items[i])).Text = Text Then Return i
		Next i
		Return -1
	End Function
	
	Function ComboBoxExItems.IndexOfData(pData As Any Ptr) As Integer
		For i As Integer = 0 To FItems.Count - 1
			If (*Cast(ComboBoxItem Ptr, FItems.Items[i])).Object = pData Then Return i
		Next i
		Return -1
	End Function
	
	Private Function ComboBoxExItems.Contains(ByRef Text As WString) As Boolean
		Return IndexOf(Text) <> -1
	End Function
	
	Private Sub ComboBoxExItems.Clear
			If Parent Then gtk_list_store_clear(Cast(ComboBoxEx Ptr, Parent)->ListStore)
		For i As Integer = Count -1 To 0 Step -1
			_Delete( Cast(ComboBoxItem Ptr, FItems.Items[i]))
		Next i
		FItems.Clear
	End Sub
	
	Private Operator ComboBoxExItems.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ComboBoxExItems
		This.Clear
	End Constructor
	
	Private Destructor ComboBoxExItems
		This.Clear
	End Destructor
	
	#ifndef ReadProperty_Off
		Private Function ComboBoxEx.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "imageslist": Return ImagesList
			Case "integralheight": Return @FIntegralHeight
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function ComboBoxEx.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "designmode": DesignMode = QBoolean(Value): If FDesignMode Then This.Items.Add *FName: This.ItemIndex = 0
			Case "imageslist": ImagesList = Value
			Case "integralheight": IntegralHeight = QBoolean(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Sub ComboBoxEx.AddItem(ByRef FItem As WString)
		Var ComboItem = Items.Add(FItem)
		FNewIndex = ComboItem->Index
	End Sub
	
	Private Sub ComboBoxEx.RemoveItem(Index As Integer)
		Items.Remove(Index)
	End Sub
	
	Private Sub ComboBoxEx.InsertItem(Index As Integer, ByRef FItem As WString)
		Items.Add FItem, , , , , , Index
		FNewIndex = Index
	End Sub
	
	Private Function ComboBoxEx.IndexOf(ByRef FItem As WString) As Integer
		Return Items.IndexOf(FItem)
	End Function
	
	Private Function ComboBoxEx.Contains(ByRef FItem As WString) As Boolean
		Return IndexOf(FItem) <> -1
	End Function
	
	Private Function ComboBoxEx.IndexOfData(pData As Any Ptr) As Integer
		Return Items.IndexOfData(pData)
	End Function
	
	Private Property ComboBoxEx.IntegralHeight As Boolean
		Return FIntegralHeight
	End Property
	
	Private Property ComboBoxEx.IntegralHeight(Value As Boolean)
		FIntegralHeight = Value
	End Property
	
	Private Property ComboBoxEx.Item(Index As Integer) ByRef As WString
		If Items.Item(Index) Then
			Return Items.Item(Index)->Text
		Else
			Return ""
		End If
	End Property
	
	Private Property ComboBoxEx.Item(Index As Integer, ByRef FItem As WString)
		If Items.Item(Index) Then
			Items.Item(Index)->Text = FItem
		End If
	End Property
	
	Private Property ComboBoxEx.ItemData(Index As Integer) As Any Ptr
		If Items.Item(Index) Then
			Return Items.Item(Index)->Object
		Else
			Return 0
		End If
	End Property
	
	Private Property ComboBoxEx.ItemData(Index As Integer, Value As Any Ptr)
		If Items.Item(Index) Then
			Items.Item(Index)->Object = Value
		End If
	End Property
	
	Private Property ComboBoxEx.ItemCount As Integer
		Return Items.Count
	End Property
	
	Private Property ComboBoxEx.ItemCount(Value As Integer)
	End Property
	
	Private Property ComboBoxEx.Text ByRef As WString
		If This.FStyle >= cbDropDownList Then
			Var iItem = This.Items.Item(This.ItemIndex)
			If iItem = 0 Then
				FText = ""
			Else
				FText = iItem->Text
			End If
		Else
				'#ifdef __USE_GTK__
					FText = WStr(*gtk_combo_box_text_get_active_text(GTK_COMBO_BOX_TEXT(widget)))
'				#else
'					Base.Text
'				#endif
		End If
		Return *FText.vptr
	End Property
	
	Private Property ComboBoxEx.Text(ByRef Value As WString)
		Base.Text = Value
			If widget Then gtk_combo_box_set_active (GTK_COMBO_BOX(widget), This.IndexOf(Value))
	End Property
	
	Private Sub ComboBoxEx.UpdateListHeight
		If This.Style <> cbSimple Then
		End If
	End Sub
	
	Private Sub ComboBoxEx.Clear
		Items.Clear
	End Sub
	
	
	
	
	Private Sub ComboBoxEx.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Property ComboBoxEx.Style As ComboBoxEditStyle
		Return Base.FStyle
	End Property
	
	Private Property ComboBoxEx.Style(Value As ComboBoxEditStyle)
		If Value <> Base.FStyle Then
			Base.FStyle = Value
				Base.Style = Value
		End If
	End Property
	
	Private Operator ComboBoxEx.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor ComboBoxEx
			ListStore = gtk_list_store_new(2, G_TYPE_STRING, G_TYPE_STRING)
			widget = gtk_combo_box_new_with_model(GTK_TREE_MODEL(ListStore))
			g_signal_connect(widget, "changed", G_CALLBACK(@ComboBoxEdit.ComboBoxEdit_Changed), @This)
			Dim As GtkCellRenderer Ptr renderer
			/' icon cell '/
			renderer = gtk_cell_renderer_pixbuf_new()
			gtk_cell_layout_pack_start( GTK_CELL_LAYOUT(widget), renderer, False)
			gtk_cell_layout_set_attributes( GTK_CELL_LAYOUT(widget), renderer, ToUtf8("icon-name"), 0, NULL)
			/' text cell '/
			renderer = gtk_cell_renderer_text_new()
			gtk_cell_layout_pack_start( GTK_CELL_LAYOUT(widget), renderer, True)
			gtk_cell_layout_set_attributes( GTK_CELL_LAYOUT(widget), renderer, ToUtf8("text"), 1, NULL)
			eventboxwidget = gtk_event_box_new()
			gtk_container_add(GTK_CONTAINER(eventboxwidget), widget)
			Base.Base.RegisterClass "ComboBoxEx", @This
		Items.Parent       = @This
		FIntegralHeight    = False
		FTabStop           = True
		'ItemHeight         = 13
		FDropDownCount     = 8
		With This
			.Child       = @This
			WLet(FClassName, "ComboBoxEx")
			WLet(FClassAncestor, "ComboBoxEx32")
			.Width       = 121
			.Height      = 121
		End With
	End Constructor
	
	Private Destructor ComboBoxEx
		Items.Clear
	End Destructor
End Namespace