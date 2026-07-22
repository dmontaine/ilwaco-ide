'###############################################################################
'#  CheckedListBox.bi                                                          #
'#  This file is part of MyFBFramework                                         #
'#  Based on:                                                                  #
'#   TListBox.bi                                                               #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Modified by Xusinboy Bekchanov (2018-2019)                                 #
'###############################################################################

#include once "CheckedListBox.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function CheckedListBox.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function CheckedListBox.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Sub CheckedListBox.AddItem(ByRef FItem As WString, Obj As Any Ptr = 0)
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
			gtk_list_store_set(ListStore, @iter, 1, ToUtf8(FItem), -1)
	End Sub
	
	Private Sub CheckedListBox.InsertItem(FIndex As Integer, ByRef FItem As WString, Obj As Any Ptr = 0)
		If FSort Then
			AddItem FItem, Obj
			Exit Sub
		End If
		Items.Insert(FIndex, FItem, Obj)
		FNewIndex = FIndex
			Dim As GtkTreeIter iter
			gtk_list_store_insert(ListStore, @iter, FIndex)
			gtk_list_store_set (ListStore, @iter, 1, ToUtf8(FItem), -1)
	End Sub
	
	Private Property CheckedListBox.Checked(Index As Integer) As Boolean
			Dim As GtkTreeIter iter
			Dim As Boolean bChecked
			gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(ListStore), @iter, Trim(Str(Index)))
			gtk_tree_model_get(GTK_TREE_MODEL(ListStore), @iter, 0, @bChecked, -1)
			Return bChecked
	End Property
	
	Private Property CheckedListBox.Checked(Index As Integer, Value As Boolean)
			Dim As GtkTreeIter iter
			gtk_tree_model_get_iter_from_string(GTK_TREE_MODEL(ListStore), @iter, Trim(Str(Index)))
			gtk_list_store_set(ListStore, @iter, 0, Value, -1)
	End Property
	
	Private Property CheckedListBox.RadioCheck As Boolean
		Return FRadioCheck
	End Property
	
	Private Property CheckedListBox.RadioCheck(Value As Boolean)
		FRadioCheck = Value
			gtk_cell_renderer_toggle_set_radio(GTK_CELL_RENDERER_TOGGLE(rendertoggle), Value)
	End Property
	
	
	
	
	Private Sub CheckedListBox.SaveToFile(ByRef FileName As WString)
		Dim As Integer F, i
		Dim As WString Ptr s
		F = FreeFile_
		Open FileName For Output Encoding "utf-8" As #F
		For i = 0 To ItemCount - 1
				Print #F, Items.Item(i)
		Next i
		CloseFile_(F)
	End Sub
	
	Private Sub CheckedListBox.LoadFromFile(ByRef FileName As WString)
		Dim As Integer F, i
		Dim As WString * 1024 s
		F = FreeFile_
		This.Clear
		Open FileName For Input Encoding "utf-8" As #F
		While Not EOF(F)
			Line Input #F, s
				AddItem s
		Wend
		CloseFile_(F)
	End Sub
	
		Private Sub CheckedListBox.Check(cell As GtkCellRendererToggle Ptr, path As gchar Ptr, model As GtkListStore Ptr)
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
	
	Private Constructor CheckedListBox
			Dim As GtkTreeViewColumn Ptr col = gtk_tree_view_column_new()
			rendertoggle = gtk_cell_renderer_toggle_new()
			Dim As GtkCellRenderer Ptr rendertext = gtk_cell_renderer_text_new()
			scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
			gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
			gtk_scrolled_window_set_shadow_type(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_SHADOW_OUT)
			ListStore = gtk_list_store_new(2, G_TYPE_BOOLEAN, G_TYPE_STRING)
			widget = gtk_tree_view_new_with_model(GTK_TREE_MODEL(ListStore))
			gtk_container_add(GTK_CONTAINER(scrolledwidget), widget)
			TreeSelection = gtk_tree_view_get_selection(GTK_TREE_VIEW(widget))
			
			gtk_tree_view_column_pack_start(col, rendertoggle, False)
			gtk_tree_view_column_add_attribute(col, rendertoggle, ToUtf8("active"), 0)
			g_signal_connect(rendertoggle, "toggled", G_CALLBACK(@Check), ListStore)
			
			gtk_tree_view_column_pack_start(col, rendertext, True)
			gtk_tree_view_column_add_attribute(col, rendertext, ToUtf8("text"), 1)
			gtk_tree_view_append_column(GTK_TREE_VIEW(widget), col)
			
			gtk_tree_view_set_headers_visible(GTK_TREE_VIEW(widget), False)
			
			'			g_signal_connect(gtk_tree_view(widget), "button-release-event", G_CALLBACK(@TreeView_ButtonRelease), @This)
			'			g_signal_connect(widget, "row-activated", G_CALLBACK(@TreeView_RowActivated), @This)
			'			g_signal_connect(widget, "query-tooltip", G_CALLBACK(@TreeView_QueryTooltip), @This)
			'			g_signal_connect(G_OBJECT(TreeSelection), "changed", G_CALLBACK (@TreeView_SelectionChanged), @This)
		FCtl3D             = False
		Base.FBorderStyle       = 1
		FTabIndex          = -1
		FTabStop           = True
		'Items.Parent       = @This
		With This
			WLet(FClassName, "CheckedListBox")
			WLet(FClassAncestor, "ListBox")
			.Child       = @This
			.Width       = 121
			.Height      = 17
		End With
	End Constructor
	
	Private Destructor CheckedListBox
	End Destructor
End Namespace
