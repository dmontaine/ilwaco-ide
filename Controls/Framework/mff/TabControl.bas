'###############################################################################
'#  TabControl.bi                                                              #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TTabControl.bi                                                            #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################
'
' Ilwaco IDE Modifications
' copyright 2026 Donald Montaine
'
' This program is free software; you can redistribute it and/or modify
' it under the terms of the GNU Lesser General Public License as published by
' the Free Software Foundation; either version 3, or (at your option)
' any later version.
'
' This program is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU Lesser General Public License for more details.
'
' You should have received a copy of the GNU Lesser General Public License
' along with this program; if not, write to the Free Software Foundation,
' Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

#include once "TabControl.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function TabPage.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "parent": Return FParent
			Case "text": Return FCaption
			Case "caption": Return FCaption
			Case "usevisualstylebackcolor": Return @UseVisualStyleBackColor
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function TabPage.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case "parent": This.Parent = Value
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "parent": If *Cast(My.Sys.Object Ptr, Value) Is TabControl Then This.Parent = Cast(TabControl Ptr, Value)
				Case "text": This.Text = QWString(Value)
				Case "caption": This.Caption = QWString(Value)
				Case "usevisualstylebackcolor": This.UseVisualStyleBackColor = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property TabControl.GroupName ByRef As WString
		If FGroupName > 0 Then Return *FGroupName Else Return ""
	End Property
	
	Private Property TabControl.GroupName(ByRef Value As WString)
		WLet(FGroupName, Value)
			gtk_notebook_set_group_name(GTK_NOTEBOOK(FHandle), ToUtf8(Value))
	End Property
	
	
	Private Sub TabPage.ProcessMessage(ByRef msg As Message)
		Base.ProcessMessage(msg)
	End Sub
	
	Private Property TabPage.Index As Integer
		If This.Parent AndAlso *Base.Parent Is TabControl Then
			Return Cast(TabControl Ptr, This.Parent)->IndexOfTab(@This)
		End If
		Return -1
	End Property
	
	Private Sub TabPage.Update()
		If This.Parent AndAlso *Base.Parent Is TabControl Then
		End If
	End Sub
	
	Private Sub TabPage.SelectTab()
		If This.Parent AndAlso *Base.Parent Is TabControl Then
			Cast(TabControl Ptr, This.Parent)->SelectedTabIndex = Index
		End If
	End Sub
	
	Private Function TabPage.IsSelected() As Boolean
		If This.Parent AndAlso *Base.Parent Is TabControl Then
			Return Cast(TabControl Ptr, This.Parent)->SelectedTabIndex = Index
		End If
		Return False
	End Function
	
	Private Property TabPage.Caption ByRef As WString
		Return This.Text
	End Property
	
	Private Property TabPage.Caption(ByRef Value As WString)
		This.Text = Value
	End Property
	
	Private Property TabPage.Text ByRef As WString
		Return *FCaption
	End Property
	
	Private Property TabPage.Text(ByRef Value As WString)
		WLet(FCaption, Value)
			If GTK_IS_LABEL(_Label) Then
				gtk_label_set_text(GTK_LABEL(_Label), ToUtf8(Value))
			End If
	End Property
	
	#ifndef Parent_Off
		Private Property TabPage.Parent As TabControl Ptr
			Return Cast(TabControl Ptr, FParent)
		End Property
		
		Private Property TabPage.Parent(Value As TabControl Ptr)
			If FParent AndAlso Value AndAlso FParent <> Value Then
				Dim As Boolean bDynamic = FDynamic
				FDynamic = False
				Cast(TabControl Ptr, FParent)->DeleteTab(@This)
				FDynamic = bDynamic
			End If
			FParent = Value
			If Value Then Value->AddTab(@This)
		End Property
	#endif
	
	Private Property TabPage.Object As Any Ptr
		Return FObject
	End Property
	
	Private Property TabPage.Object(Value As Any Ptr)
		FObject = Value
		Update
	End Property
	
	Private Property TabPage.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property TabPage.ImageIndex(Value As Integer)
		FImageIndex = Value
		Update
	End Property
	
	Private Property TabPage.ImageKey ByRef As WString
		If FImageKey > 0 Then Return *FImageKey Else Return ""
	End Property
	
	Private Property TabPage.ImageKey(ByRef Value As WString)
		WLet(FImageKey, Value)
			gtk_image_set_from_icon_name(GTK_IMAGE(_Icon), ToUtf8(Value), GTK_ICON_SIZE_MENU)
	End Property
	
	Property TabPage.Visible As Boolean
		Return Base.Visible
	End Property
	
	Property TabPage.Visible(Value As Boolean)
		If FVisible <> Value Then
			FVisible = Value
			If Value Then
			Else
			End If
		End If
		Base.Visible = Value
	End Property
	
	Private Operator TabPage.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Operator TabPage.Let(ByRef Value As WString)
		Caption = Value
	End Operator
	
	Private Operator TabPage.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor TabPage
		FObject    = 0
		FImageIndex        = 0
		'Anchor.Left = asAnchor
		'Anchor.Top = asAnchor
		'Anchor.Right = asAnchor
		'Anchor.Bottom = asAnchor
		Caption = " "
		Text    = " "
		WLet(FClassName, "TabPage")
		WLet(FClassAncestor, "Panel")
		Child = @This
			This.RegisterClass "TabPage", @This
	End Constructor
	
	Private Destructor TabPage
		'If FParent <> 0 Then Parent->DeleteTab(Parent->IndexOf(@This))
		If FCaption Then _Deallocate(FCaption)
		If FImageKey Then _Deallocate(FImageKey)
	End Destructor
	
	#ifndef ReadProperty_Off
		Private Function TabControl.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "tabindex": Return @FTabIndex
			Case "selectedtabindex": Return @FSelectedTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function TabControl.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "tabindex": TabIndex = QInteger(Value)
				Case "selectedtabindex": This.SelectedTabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property TabControl.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property TabControl.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property TabControl.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property TabControl.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property TabPage.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property TabPage.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property TabPage.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property TabPage.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property TabControl.SelectedTabIndex As Integer
			Return gtk_notebook_get_current_page(GTK_NOTEBOOK(widget))
	End Property
	
	Private Property TabControl.SelectedTabIndex(Value As Integer)
		FSelectedTabIndex = Value
			gtk_notebook_set_current_page(GTK_NOTEBOOK(widget), Value)
	End Property
	
	Private Sub TabControl.SetMargins()
		Select Case FTabPosition
		Case 0: Base.SetMargins 4 + ItemWidth(0), 2, 4, 3
		Case 1: Base.SetMargins 2, 2, 4 + ItemWidth(0), 3
		Case 2: Base.SetMargins 2, 4 + ItemHeight(0), 4, 3
		Case 3: Base.SetMargins 2, 2, 2, 4 + ItemHeight(0)
		End Select
	End Sub
	
	Private Property TabControl.TabPosition As My.Sys.Forms.TabPosition
		Return FTabPosition
	End Property
	
	Private Property TabControl.TabPosition(Value As My.Sys.Forms.TabPosition)
		FTabPosition = Value
			gtk_notebook_set_tab_pos(GTK_NOTEBOOK(widget), FTabPosition)
			For i As Integer = 0 To TabCount - 1
				Select Case FTabPosition
				Case 0, 1
					gtk_label_set_text(GTK_LABEL(Tabs[i]->_Label), ToUtf8(" " & Tabs[i]->Caption & " "))
					gtk_label_set_angle(GTK_LABEL(Tabs[i]->_Label), 90)
				Case 2, 3
					gtk_label_set_text(GTK_LABEL(Tabs[i]->_Label), ToUtf8(Tabs[i]->Caption))
					gtk_label_set_angle(GTK_LABEL(Tabs[i]->_Label), 0)
				End Select
			Next
		SetMargins
	End Property
	
	Private Property TabControl.TabStyle As My.Sys.Forms.TabStyle
		Return FTabStyle
	End Property
	
	Private Property TabControl.TabStyle(Value As My.Sys.Forms.TabStyle)
		FTabStyle = Value
	End Property
	
	Private Property TabControl.FlatButtons As Boolean
		Return FFlatButtons
	End Property
	
	Private Property TabControl.FlatButtons(Value As Boolean)
		FFlatButtons = Value
		'RecreateWnd
	End Property
	
	Private Property TabControl.Multiline As Boolean
		Return FMultiline
	End Property
	
	Private Property TabControl.Multiline(Value As Boolean)
		FMultiline = Value
		RecreateWnd
	End Property
	
	Private Property TabControl.Reorderable As Boolean
		Return FReorderable
	End Property
	
	Private Property TabControl.Reorderable(Value As Boolean)
		FReorderable = Value
			For i As Integer = 0 To TabCount - 1
				gtk_notebook_set_tab_reorderable(GTK_NOTEBOOK(widget), Tabs[i]->widget, Value)
			Next
	End Property
	
	Private Property TabControl.Detachable As Boolean
		Return FDetachable
	End Property
	
	Private Property TabControl.Detachable(Value As Boolean)
		FDetachable = Value
			For i As Integer = 0 To TabCount - 1
				gtk_notebook_set_tab_detachable(GTK_NOTEBOOK(widget), Tabs[i]->widget, Value)
			Next
	End Property
	
	Private Property TabControl.TabCount As Integer
		Return FTabCount
	End Property
	
	Private Property TabControl.TabCount(Value As Integer)
	End Property
	
	Private Property TabControl.Tab(Index As Integer) As TabPage Ptr
		Return Tabs[Index]
	End Property
	
	Private Property TabControl.Tab(Index As Integer, Value As TabPage Ptr)
	End Property
	
	Private Property TabControl.SelectedTab As TabPage Ptr
		Var Idx = SelectedTabIndex
		If Idx >= 0 AndAlso Idx <= TabCount - 1 Then
			Return Tabs[Idx]
		Else
			Return 0
		End If
	End Property
	
	Private Property TabControl.SelectedTab(Value As TabPage Ptr)
		SelectedTabIndex = IndexOfTab(Value)
	End Property
	
	Private Function TabControl.ItemHeight(Index As Integer) As Integer
		If Index >= 0 And Index < TabCount Then
					Return gtk_widget_get_allocated_height(gtk_notebook_get_tab_label(GTK_NOTEBOOK(widget), Tabs[Index]->widget))
		End If
		Return 0
	End Function
	
	Private Function TabControl.ItemWidth(Index As Integer) As Integer
		If Index >= 0 And Index < TabCount Then
					Return gtk_widget_get_allocated_width(gtk_notebook_get_tab_label(GTK_NOTEBOOK(widget), Tabs[Index]->widget))
		End If
		Return 0
	End Function
	
	Private Function TabControl.ItemLeft(Index As Integer) As Integer
		If Index >= 0 And Index < TabCount Then
		End If
		Return 0
	End Function
	
	Private Function TabControl.ItemTop(Index As Integer) As Integer
		If Index >= 0 And Index < TabCount Then
		End If
		Return 0
	End Function
	
	
	Private Sub TabControl.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Function TabControl.AddTab(ByRef Caption As WString, aObject As Any Ptr = 0, ImageIndex As Integer = -1) As TabPage Ptr
		FTabCount += 1
		Dim tp As TabPage Ptr = _New( TabPage)
		tp->FDynamic = True
		tp->Caption = Caption
		tp->Object = aObject
		tp->ImageIndex = ImageIndex
		Tabs = _Reallocate(Tabs, SizeOf(TabPage Ptr) * FTabCount)
		Tabs[FTabCount - 1] = tp
			If widget Then
					tp->_Box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 1)
				tp->_Icon = gtk_image_new_from_icon_name(ToUtf8(tp->ImageKey), GTK_ICON_SIZE_MENU)
				gtk_container_add (GTK_CONTAINER (tp->_Box), tp->_Icon)
				tp->_Label = gtk_label_new(ToUtf8(tp->Caption))
				gtk_container_add (GTK_CONTAINER (tp->_Box), tp->_Label)
				'gtk_box_pack_end (GTK_BOX (tp->_box), tp->_label, TRUE, TRUE, 0)
				gtk_widget_show_all(tp->_Box)
				gtk_notebook_append_page(GTK_NOTEBOOK(widget), tp->widget, tp->_Box)
				gtk_notebook_set_tab_reorderable(GTK_NOTEBOOK(widget), tp->widget, FReorderable)
				gtk_notebook_set_tab_detachable(GTK_NOTEBOOK(widget), tp->widget, FDetachable)
				'gtk_notebook_append_page(gtk_notebook(widget), tp->widget, gtk_label_new(ToUTF8(Caption)))
			End If
		This.Add(tp)
		tp->Visible = FTabCount = 1
		If OnTabAdded Then OnTabAdded(*Designer, This, Tabs[FTabCount - 1], FTabCount - 1)
		Return Tabs[FTabCount - 1]
	End Function
	
	Private Function TabControl.AddTab(ByRef Caption As WString, aObject As Any Ptr = 0, ByRef ImageKey As WString) As TabPage Ptr
		Dim tb As TabPage Ptr
		If Images Then
			tb = AddTab(Caption, aObject, Images->IndexOf(ImageKey))
		Else
			tb = AddTab(Caption, aObject, -1)
		End If
		If tb Then tb->ImageKey = ImageKey
		Return tb
	End Function
	
	Private Sub TabControl.AddTab(ByRef tp As TabPage Ptr)
		FTabCount += 1
		'tp->TabPageControl = @This
		Tabs = _Reallocate(Tabs, SizeOf(TabPage Ptr) * FTabCount)
		Tabs[FTabCount - 1] = tp
		If tp->Parent <> 0 AndAlso tp->Parent <> @This Then
			Dim As Boolean bDynamic = tp->FDynamic
			tp->FDynamic = False
			Cast(TabControl Ptr, tp->Parent)->DeleteTab(tp)
			tp->FDynamic = bDynamic
		End If
			If widget Then
					tp->_Box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 1)
				tp->_Icon = gtk_image_new_from_icon_name(ToUtf8(tp->ImageKey), GTK_ICON_SIZE_MENU)
				gtk_container_add (GTK_CONTAINER (tp->_Box), tp->_Icon)
				tp->_Label = gtk_label_new(ToUtf8(tp->Caption))
				gtk_container_add (GTK_CONTAINER (tp->_Box), tp->_Label)
				'gtk_box_pack_end (GTK_BOX (tp->_box), tp->_label, TRUE, TRUE, 0)
				gtk_widget_show_all(tp->_Box)
				gtk_notebook_append_page(GTK_NOTEBOOK(widget), tp->widget, tp->_Box)
				gtk_notebook_set_tab_reorderable(GTK_NOTEBOOK(widget), tp->widget, FReorderable)
				gtk_notebook_set_tab_detachable(GTK_NOTEBOOK(widget), tp->widget, FDetachable)
				'RequestAlign
			End If
			tp->Visible = FTabCount = 1
			If widget Then
				gtk_widget_show_all(widget)
			End If
		This.Add(Tabs[FTabCount - 1])
		If OnTabAdded Then OnTabAdded(*Designer, This, Tabs[FTabCount - 1], FTabCount - 1)
		Tabs[FTabCount - 1]->SendToBack
	End Sub
	
	Private Sub TabControl.ReorderTab(ByVal tp As TabPage Ptr, Index As Integer, bNoActivate As Boolean = False)
		Dim As Integer i
		Dim As TabPage Ptr It
		If Index >= 0 And Index <= FTabCount -1 Then
			If Index < tp->Index Then
				For i = tp->Index - 1 To Index Step -1
					It = Tabs[i]
					Tabs[i + 1] = It
					If i = Index Then
						Tabs[Index] = tp
						SetTabPageIndex(tp, Index)
					End If
					Tabs[i + 1]->Update
					SetTabPageIndex(It, i + 1)
				Next i
				Tabs[Index]->Update
			Else
				For i = tp->Index + 1 To Index
					It = Tabs[i]
					Tabs[i - 1] = It
					Tabs[i - 1]->Update
					SetTabPageIndex(It, i - 1)
				Next i
				Tabs[Index] = tp
				Tabs[Index]->Update
				SetTabPageIndex(tp, Index)
			End If
			If Not bNoActivate Then SelectedTabIndex = Index
			If OnTabReordered Then OnTabReordered(*Designer, This, tp, Index)
		End If
	End Sub
	
	Private Sub TabControl.SetTabPageIndex(tp As TabPage Ptr, Index As Integer)
	End Sub
	
	Private Sub TabControl.DeleteTab(Index As Integer)
		Dim As Integer i
		Dim As TabPage Ptr It, Prev
		If Index >= 0 And Index <= FTabCount - 1 Then
			Prev = Tabs[Index]
			'' A non-dynamic TabPage outlives its removal from the notebook, so remember whether
			'' it survives -- its _Label/_Box must be cleared below (see gtk_notebook_remove_page).
			Dim As Boolean bPageSurvives = Not Prev->FDynamic
			Prev->Parent = 0
			This.Remove(Tabs[Index])
			If Prev->FDynamic Then _Delete(Prev)
			For i = Index + 1 To FTabCount - 1
				It = Tabs[i]
				Tabs[i - 1] = It
				SetTabPageIndex(It, i - 1)
			Next i
			FTabCount -= 1
			If FTabCount = 0 Then
				_Deallocate(Tabs)
				Tabs = 0
			Else
				Tabs = _Reallocate(Tabs, FTabCount * SizeOf(TabPage Ptr))
			End If
				gtk_notebook_remove_page(GTK_NOTEBOOK(widget), Index)
			'' The notebook owned the tab's box and label; removing the page drops the last
			'' reference and GTK finalises them. A surviving (non-dynamic) TabPage must not keep
			'' pointing at those freed widgets: TabPage.Text does
			''     If GTK_IS_LABEL(_Label) Then gtk_label_set_text(...)
			'' and GTK_IS_LABEL reads the instance's class pointer, so it cannot detect a FREED
			'' widget -- it dereferences it first. Measured: Close Project -> ClearAnalysisPanels
			'' -> tpProblems->Caption = ... faulted in TabPage.Text with _Label holding
			'' 0x0000006600000061, i.e. the label's heap reused for the UTF-32 text "af".
			If bPageSurvives Then Prev->_Label = 0: Prev->_Box = 0
			If Index > 0 Then
				SelectedTabIndex = Index - 1
			ElseIf Index < TabCount - 1 Then
				SelectedTabIndex = Index + 1
			End If
			If FTabCount = 0 Then SetMargins
			If OnTabRemoved Then OnTabRemoved(*Designer, This, Prev, Index)
		End If
	End Sub
	
	Private Sub TabControl.DeleteTab(Value As TabPage Ptr)
		DeleteTab IndexOfTab(Value)
	End Sub

	' Remove a tab from the control *without destroying its TabPage* so it can be re-added later.
	' DeleteTab only frees the page when FDynamic is set, so clear it across the removal. On GTK
	' gtk_notebook_remove_page (inside DeleteTab) drops the notebook's reference to the page widget,
	' which would finalize it; take an extra ref first (the same idiom Control.BringToFront uses when
	' reparenting) so the widget survives and AddTab can re-append it.
	Private Sub TabControl.DetachTab(Value As TabPage Ptr)
		If Value = 0 Then Exit Sub
		Dim As Integer idx = IndexOfTab(Value)
		If idx < 0 Then Exit Sub
		If Value->widget Then g_object_ref(G_OBJECT(Value->widget))
		Dim As Boolean bDynamic = Value->FDynamic
		Value->FDynamic = False
		DeleteTab idx
		Value->FDynamic = bDynamic
	End Sub

	Private Function TabControl.InsertTab(Index As Integer, ByRef Caption As WString, AObject As Any Ptr = 0) As TabPage Ptr
		Dim As Integer i
		Dim As TabPage Ptr It, tp
		Dim As Integer iIndex = Index
		If iIndex < 0 Then
			iIndex = 0
		ElseIf iIndex > FTabCount Then
			iIndex = FTabCount
		End If
		'If Index >= 0 And Index <= FTabCount -1 Then
			FTabCount += 1
			Tabs = _Reallocate(Tabs,FTabCount*SizeOf(TabPage Ptr))
			For i = iIndex To FTabCount - 2
				It = Tabs[i]
				Tabs[i + 1] = It
				SetTabPageIndex(It, i + 1)
			Next i
			tp = _New( TabPage)
			Tabs[iIndex] = tp
			tp->FDynamic = True
			tp->Caption = Caption
			tp->Object = AObject
			'tp->TabPageControl = @This
				If widget Then
						tp->_Box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 1)
					tp->_Icon = gtk_image_new_from_icon_name(ToUtf8(tp->ImageKey), GTK_ICON_SIZE_MENU)
					gtk_container_add (GTK_CONTAINER (tp->_Box), tp->_Icon)
					tp->_Label = gtk_label_new(ToUtf8(tp->Caption))
					gtk_container_add (GTK_CONTAINER (tp->_Box), tp->_Label)
					'gtk_box_pack_end (GTK_BOX (tp->_box), tp->_label, TRUE, TRUE, 0)
					gtk_widget_show_all(tp->_Box)
					gtk_notebook_insert_page(GTK_NOTEBOOK(widget), tp->widget, tp->_Box, iIndex)
					gtk_notebook_set_tab_reorderable(GTK_NOTEBOOK(widget), tp->widget, FReorderable)
					gtk_notebook_set_tab_detachable(GTK_NOTEBOOK(widget), tp->widget, FDetachable)
					'gtk_notebook_append_page(gtk_notebook(widget), tp->widget, gtk_label_new(ToUTF8(Caption)))
				End If
			SetMargins
			This.Add(tp)
			tp->Visible = FTabCount = 1
			If OnTabAdded Then OnTabAdded(*Designer, This, tp, iIndex)
			Return Tabs[iIndex]
		'End If
		'Return 0
	End Function
	
	Private Sub TabControl.InsertTab(Index As Integer, ByRef tp As TabPage Ptr)
		FTabCount += 1
		'tp->TabPageControl = @This
		Tabs = _Reallocate(Tabs, SizeOf(TabPage Ptr) * FTabCount)
		Tabs[FTabCount - 1] = tp
			If widget Then
					tp->_Box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 1)
				tp->_Icon = gtk_image_new_from_icon_name(ToUtf8(tp->ImageKey), GTK_ICON_SIZE_MENU)
				gtk_container_add (GTK_CONTAINER (tp->_Box), tp->_Icon)
				tp->_Label = gtk_label_new(ToUtf8(tp->Caption))
				gtk_container_add (GTK_CONTAINER (tp->_Box), tp->_Label)
				'gtk_box_pack_end (GTK_BOX (tp->_box), tp->_label, TRUE, TRUE, 0)
				gtk_widget_show_all(tp->_Box)
				gtk_notebook_insert_page(GTK_NOTEBOOK(widget), tp->widget, tp->_Box, Index)
				gtk_notebook_set_tab_reorderable(GTK_NOTEBOOK(widget), tp->widget, FReorderable)
				gtk_notebook_set_tab_detachable(GTK_NOTEBOOK(widget), tp->widget, FDetachable)
				'RequestAlign
			End If
			tp->Visible = FTabCount = 1
			If widget Then
				gtk_widget_show_all(widget)
			End If
		This.Add(Tabs[Index])
		If OnTabAdded Then OnTabAdded(*Designer, This, Tabs[Index], Index)
	End Sub
	
	Private Operator TabControl.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Function TabControl.IndexOfTab(Value As TabPage Ptr) As Integer
		Dim As Integer i
		For i = 0 To TabCount - 1
			If Tabs[i] = Value Then Return i
		Next i
		Return -1
	End Function
	
		Private Sub TabControl.TabControl_SwitchPage(notebook As GtkNotebook Ptr, page As GtkWidget Ptr, page_num As UInteger, user_data As Any Ptr)
			Dim As TabControl Ptr tc = user_data
			If tc AndAlso tc->Tabs[page_num] Then
				tc->Tabs[page_num]->RequestAlign
				If tc->OnSelChange Then tc->OnSelChange(*tc->Designer, *tc, page_num)
			End If
		End Sub
		
		Private Sub TabControl.TabControl_PageAdded(notebook As GtkNotebook Ptr, page As GtkWidget Ptr, page_num As UInteger, user_data As Any Ptr)
			Dim As TabControl Ptr tc = user_data
			Dim As TabPage Ptr tp = Cast(Any Ptr, g_object_get_data(G_OBJECT(page), "MFFControl"))
			If tc->IndexOfTab(tp) = -1 Then
				tc->FTabCount += 1
				tc->Tabs = _Reallocate(tc->Tabs, tc->FTabCount * SizeOf(TabPage Ptr))
				Dim As TabPage Ptr It
				For i As Integer = page_num To tc->FTabCount - 2
					It = tc->Tabs[i]
					tc->Tabs[i + 1] = It
				Next i
				If tc->OnTabAdded Then tc->OnTabAdded(*tc->Designer, *tc, tp, page_num)
			End If
		End Sub
		
		Private Sub TabControl.TabControl_PageRemoved(notebook As GtkNotebook Ptr, page As GtkWidget Ptr, page_num As UInteger, user_data As Any Ptr)
			Dim As TabControl Ptr tc = user_data
			Dim As TabPage Ptr tp = Cast(Any Ptr, g_object_get_data(G_OBJECT(page), "MFFControl"))
			If tc->IndexOfTab(tp) > 0 Then
				Dim As TabPage Ptr It
				For i As Integer = page_num + 1 To tc->FTabCount - 1
					It = tc->Tabs[i]
					tc->Tabs[i - 1] = It
				Next i
				tc->FTabCount -= 1
				If tc->FTabCount = 0 Then
					_Deallocate(tc->Tabs)
					tc->Tabs = 0
				Else
					tc->Tabs = _Reallocate(tc->Tabs, tc->FTabCount * SizeOf(TabPage Ptr))
				End If
				If tc->OnTabRemoved Then tc->OnTabRemoved(*tc->Designer, *tc, tp, page_num)
			End If
		End Sub
		
		Private Sub TabControl.TabControl_PageReordered(notebook As GtkNotebook Ptr, page As GtkWidget Ptr, page_num As UInteger, user_data As Any Ptr)
			Dim As TabControl Ptr tc = user_data
			Dim As TabPage Ptr tp = Cast(Any Ptr, g_object_get_data(G_OBJECT(page), "MFFControl"))
			tc->ReorderTab tp, page_num
		End Sub
	
	Private Constructor TabControl
		SetMargins
		With This
				widget = gtk_notebook_new()
				gtk_notebook_set_scrollable(GTK_NOTEBOOK(widget), True)
				g_signal_connect(GTK_NOTEBOOK(widget), "switch-page", G_CALLBACK(@TabControl_SwitchPage), @This)
				g_signal_connect(GTK_NOTEBOOK(widget), "page-added", G_CALLBACK(@TabControl_PageAdded), @This)
				g_signal_connect(GTK_NOTEBOOK(widget), "page-removed", G_CALLBACK(@TabControl_PageRemoved), @This)
				g_signal_connect(GTK_NOTEBOOK(widget), "page-reordered", G_CALLBACK(@TabControl_PageReordered), @This)
				.RegisterClass "TabControl", @This
			WLet(FClassName, "TabControl")
			.Child       = @This
			FTabIndex          = -1
			FTabStop           = True
			FTabPosition = 2
			.Width       = 121
			.Height      = 121
		End With
	End Constructor
	
	Private Destructor TabControl
		For i As Integer = 0 To FTabCount - 1
			Tabs[i]->Parent = 0
			If Tabs[i]->FDynamic Then _Delete(Tabs[i])
		Next
		If Tabs <> 0 Then _Deallocate(Tabs)
		If FGroupName Then _Deallocate(FGroupName)
		'UnregisterClass "TabControl", GetModuleHandle(NULL)
	End Destructor
	
End Namespace
