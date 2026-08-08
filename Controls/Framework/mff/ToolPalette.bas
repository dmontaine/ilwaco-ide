'###############################################################################
'#  ToolPalette.bi                                                             #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TToolBar.bi                                                               #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Adapted to ToolPalette and added cross-platform                            #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
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

#include once "ToolPalette.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function ToolPalette.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "autosize": Return @FAutosize
			'Case "caption": Return FText.vptr
			Case "flat": Return @FFlat
			Case "list": Return @FList
			Case "wrapable": Return @FWrapable
			Case "transparency": Return @FTransparent
			Case "disabledimageslist": Return DisabledImagesList
			Case "hotimageslist": Return HotImagesList
			Case "imageslist": Return ImagesList
			Case "divider": Return @FDivider
			Case "bitmapwidth": FBitmapWidth = This.BitmapWidth: Return @FBitmapWidth
			Case "bitmapheight": FBitmapHeight = This.BitmapHeight: Return @FBitmapHeight
			Case "buttonwidth": FButtonWidth = This.ButtonWidth: Return @FButtonWidth
			Case "buttonheight": FButtonHeight = This.ButtonHeight: Return @FButtonHeight
			Case "buttonscount": FButtonsCount = 0: Return @FButtonsCount
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function ToolPalette.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "autosize": This.AutoSize = QBoolean(Value)
				Case "bitmapwidth": This.BitmapWidth = QInteger(Value)
				Case "bitmapheight": This.BitmapHeight = QInteger(Value)
				Case "buttonwidth": This.ButtonWidth = QInteger(Value)
				Case "buttonheight": This.ButtonHeight = QInteger(Value)
				'Case "caption": This.Caption = QWString(Value)
				Case "flat": This.Flat = QBoolean(Value)
				Case "list": This.List = QBoolean(Value)
				Case "disabledimageslist": This.DisabledImagesList = Value
				Case "hotimageslist": This.HotImagesList = Value
				Case "imageslist": This.ImagesList = Value
				Case "divider": This.Divider = QBoolean(Value)
				Case "transparency": This.Transparency = QBoolean(Value)
				Case "wrapable": This.Wrapable = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Constructor ToolGroup
			Widget = gtk_tool_item_group_new("")
		FExpanded = True
		Buttons.Parent = @This
	End Constructor
	
	Private Destructor ToolGroup
		WDeAllocate(FCaption)
		WDeAllocate(FName)
	End Destructor
	
	Private Property ToolGroup.CommandID As Integer
		Return FCommandID
	End Property
	
	Private Property ToolGroup.CommandID(Value As Integer)
		Dim As Integer i
		If Value <> FCommandID Then
			FCommandID = Value
			If Ctrl Then
				With QControl(Ctrl)
				End With
			End If
		End If
	End Property
	
	Private Function ToolGroup.Index As Integer
		If Ctrl Then
			Return Cast(ToolPalette Ptr, Ctrl)->Groups.IndexOf(@This)
		End If
		Return -1
	End Function
	
	Private Property ToolGroup.Caption ByRef As WString
		Return WGet(FCaption)
	End Property
	
	Private Property ToolGroup.Caption(ByRef Value As WString)
		WLet(FCaption, Value)
			gtk_tool_item_group_set_label(GTK_TOOL_ITEM_GROUP(Widget), ToUtf8(Value))
	End Property
	
	Private Property ToolGroup.Name ByRef As WString
		Return WGet(FName)
	End Property
	
	Private Property ToolGroup.Name(ByRef Value As WString)
		WLet(FName, Value)
	End Property
	
	Private Property ToolGroup.Expanded As Boolean
		Return FExpanded
	End Property
	
	Private Property ToolGroup.Expanded(Value As Boolean)
		FExpanded = Value
			gtk_tool_item_group_set_collapsed(GTK_TOOL_ITEM_GROUP(Widget), Not Value)
	End Property
	
	Private Operator ToolGroup.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Property ToolGroupButtons.Count As Integer
		Return FButtons.Count
	End Property
	
	Private Property ToolGroupButtons.Count(Value As Integer)
	End Property
	
	Private Property ToolGroupButtons.Item(Index As Integer) As ToolButton Ptr
		Return Cast(ToolButton Ptr, FButtons.Items[Index])
	End Property
	
	Private Property ToolGroupButtons.Item(ByRef Key As WString) As ToolButton Ptr
		If IndexOf(Key) <> -1 Then Return Cast(ToolButton Ptr, FButtons.Items[IndexOf(Key)])
		Return 0
	End Property
	
	Private Property ToolGroupButtons.Item(Index As Integer, Value As ToolButton Ptr)
		'QToolButton(FButtons.Items[Index]) = Value
	End Property
	
		Private Sub ToolGroupButtons.ToolButtonClicked(gtoolbutton As GtkToolButton Ptr, user_data As Any Ptr)
			Dim As ToolButton Ptr tbut = user_data
			If tbut Then
				If tbut->OnClick Then tbut->OnClick(*tbut->Designer, *tbut)
				If tbut->Ctrl AndAlso *tbut->Ctrl Is ToolBar Then
					Dim As ToolBar Ptr tb = Cast(ToolBar Ptr, tbut->Ctrl)
					If tb->OnButtonClick Then tb->OnButtonClick(*tb->Designer, *tb, *tbut)
				End If
			End If
		End Sub
	
	Private Function ToolGroupButtons.Add(FStyle As ToolButtonStyle = tbsAutosize, FImageIndex As Integer = -1, Index As Integer = -1, FClick As NotifyEvent = NULL, ByRef FKey As WString = "", ByRef FCaption As WString = "", ByRef FHint As WString = "", FShowHint As Boolean = False, FState As ToolButtonState = tstEnabled) As ToolButton Ptr
		Dim As ToolButton Ptr PButton
		PButton = _New( ToolButton)
		PButton->FDynamic = True 
		FButtons.Add PButton
		With *PButton
			.Style          = FStyle
				Select Case FStyle
				Case tbsSeparator
					.Widget = GTK_WIDGET(gtk_separator_tool_item_new())
				Case Else
					Select Case FStyle
					Case tbsButton
						.Widget = GTK_WIDGET(gtk_tool_button_new(NULL, ToUtf8(FCaption)))
					Case tbsAutosize
						.Widget = GTK_WIDGET(gtk_tool_button_new(NULL, ToUtf8(FCaption)))
					Case tbsCheck
						.Widget = GTK_WIDGET(gtk_toggle_tool_button_new())
					Case tbsCheckGroup
						If FButtons.Count > 1 AndAlso GTK_IS_RADIO_TOOL_BUTTON(QToolButton(FButtons.Item(FButtons.Count - 2)).Widget) Then
							.Widget = GTK_WIDGET(gtk_radio_tool_button_new_from_widget(GTK_RADIO_TOOL_BUTTON(QToolButton(FButtons.Item(FButtons.Count - 2)).Widget)))
						Else
							.Widget = GTK_WIDGET(gtk_radio_tool_button_new(NULL))
						End If
					Case tbsGroup
						If FButtons.Count > 1 AndAlso GTK_IS_RADIO_TOOL_BUTTON(QToolButton(FButtons.Item(FButtons.Count - 2)).Widget) Then
							.Widget = GTK_WIDGET(gtk_radio_tool_button_new_from_widget(GTK_RADIO_TOOL_BUTTON(QToolButton(FButtons.Item(FButtons.Count - 2)).Widget)))
						Else
							.Widget = GTK_WIDGET(gtk_radio_tool_button_new(NULL))
						End If
					Case tbsDropDown
						.Widget = GTK_WIDGET(gtk_menu_tool_button_new(NULL, ToUtf8(FCaption)))
						gtk_menu_tool_button_set_menu(GTK_MENU_TOOL_BUTTON(.Widget), .DropDownMenu.Handle)
						gtk_widget_show_all(.Widget)
					Case tbsNoPrefix
						.Widget = GTK_WIDGET(gtk_tool_button_new(NULL, ToUtf8(FCaption)))
					Case tbsShowText
						.Widget = GTK_WIDGET(gtk_tool_button_new(NULL, ToUtf8(FCaption)))
					Case tbsWholeDropdown
						.Widget = GTK_WIDGET(gtk_menu_tool_button_new(NULL, ToUtf8(FCaption)))
						gtk_menu_tool_button_set_menu(GTK_MENU_TOOL_BUTTON(.Widget), .DropDownMenu.Handle)
					Case Else
						.Widget = GTK_WIDGET(gtk_tool_button_new(NULL, ToUtf8(FCaption)))
					End Select
					gtk_tool_item_set_tooltip_text(GTK_TOOL_ITEM(.Widget), ToUtf8(FHint))
					g_signal_connect(.Widget, "clicked", G_CALLBACK(@ToolButtonClicked), PButton)
				End Select
				gtk_widget_show_all(.Widget)
			.State        = FState
			.ImageIndex     = FImageIndex
			.Hint           = FHint
			.ShowHint       = FShowHint
			.Name         = FKey
			.Caption        = FCaption
			.CommandID      = (Cast(ToolGroup Ptr, This.Parent)->Index + 1) * 100 + FButtons.Count
			.OnClick        = FClick
		End With
		PButton->Ctrl = @Cast(ToolGroup Ptr, Parent)->Ctrl
			If Parent Then
				gtk_tool_item_group_insert(GTK_TOOL_ITEM_GROUP(Cast(ToolGroup Ptr, Parent)->Widget), GTK_TOOL_ITEM(PButton->Widget), Index)
			End If
		Return PButton
	End Function
	
	Private Function ToolGroupButtons.Add(FStyle As ToolButtonStyle = tbsAutosize, ByRef ImageKey As WString, Index As Integer = -1, FClick As NotifyEvent = NULL, ByRef FKey As WString = "", ByRef FCaption As WString = "", ByRef FHint As WString = "", FShowHint As Boolean = False, FState As ToolButtonState = tstEnabled) As ToolButton Ptr
		Dim As ToolButton Ptr PButton
			PButton = Add(FStyle, -1, Index, FClick, FKey, FCaption, FHint, FShowHint, FState)
			If PButton Then PButton->ImageKey         = ImageKey
		Return PButton
	End Function
	
	Private Sub ToolGroupButtons.Remove(Index As Integer)
		FButtons.Remove Index
		If Parent AndAlso Cast(ToolGroup Ptr, Parent)->Ctrl Then
		End If
	End Sub
	
	Private Function ToolGroupButtons.IndexOf(ByRef FButton As ToolButton Ptr) As Integer
		Return FButtons.IndexOf(FButton)
	End Function
	
	Private Function ToolGroupButtons.IndexOf(ByRef Key As WString) As Integer
		For i As Integer = 0 To Count - 1
			If QToolButton(FButtons.Items[i]).Name = Key Then Return i
		Next i
		Return -1
	End Function
	
	Private Sub ToolGroupButtons.Clear
		For i As Integer = Count -1 To 0 Step -1
			_Delete( @QToolButton(FButtons.Items[i]))
		Next i
		FButtons.Clear
	End Sub
	
	Private Operator ToolGroupButtons.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ToolGroupButtons
		This.Clear
	End Constructor
	
	Private Destructor ToolGroupButtons
		This.Clear
	End Destructor
	
	Private Property ToolGroups.Count As Integer
		Return FGroups.Count
	End Property
	
	Private Property ToolGroups.Count(Value As Integer)
	End Property
	
	Private Property ToolGroups.Item(Index As Integer) As ToolGroup Ptr
		Return Cast(ToolGroup Ptr, FGroups.Items[Index])
	End Property
	
	Private Property ToolGroups.Item(ByRef Key As WString) As ToolGroup Ptr
		If IndexOf(Key) <> -1 Then Return Cast(ToolGroup Ptr, FGroups.Items[IndexOf(Key)])
		Return 0
	End Property
	
	Private Property ToolGroups.Item(Index As Integer, Value As ToolGroup Ptr)
		'QToolButton(FButtons.Items[Index]) = Value
	End Property
	
	Private Function ToolGroups.Add(ByRef Caption As WString, ByRef Key As WString = "") As ToolGroup Ptr
		Dim As ToolGroup Ptr PGroup
		PGroup = _New( ToolGroup)
		FGroups.Add PGroup
		With *PGroup
			.Name         = Key
			.Caption        = Caption
			.CommandID		= (FGroups.Count) * 100
		End With
		PGroup->Ctrl = Parent
			If Parent AndAlso Parent->Handle Then
				gtk_container_add(GTK_CONTAINER (Parent->Handle), PGroup->Widget)
			End If
		Return PGroup
	End Function
	
	Private Sub ToolGroups.Remove(Index As Integer)
		FGroups.Remove Index
		If Parent Then
		End If
	End Sub
	
	Private Function ToolGroups.IndexOf(ByRef FGroup As ToolGroup Ptr) As Integer
		Return FGroups.IndexOf(FGroup)
	End Function
	
	Private Function ToolGroups.IndexOf(ByRef Key As WString) As Integer
		For i As Integer = 0 To Count - 1
			If QToolGroup(FGroups.Items[i]).Name = Key Then Return i
		Next i
		Return -1
	End Function
	
	Private Sub ToolGroups.Clear
		For i As Integer = Count - 1 To 0 Step -1
			_Delete( @QToolGroup(FGroups.Items[i]))
		Next i
		FGroups.Clear
	End Sub
	
	Private Operator ToolGroups.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor ToolGroups
		This.Clear
	End Constructor
	
	Private Destructor ToolGroups
		This.Clear
	End Destructor
	
	Private Property ToolPalette.ImagesList As ImageList Ptr
		Return FImagesList
	End Property
	
	Private Property ToolPalette.ImagesList(Value As ImageList Ptr)
		FImagesList = Value
	End Property
	
	Private Property ToolPalette.HotImagesList As ImageList Ptr
		Return FHotImagesList
	End Property
	
	Private Property ToolPalette.HotImagesList(Value As ImageList Ptr)
		FHotImagesList = Value
	End Property
	
	Private Property ToolPalette.DisabledImagesList As ImageList Ptr
		Return FDisabledImagesList
	End Property
	
	Private Property ToolPalette.DisabledImagesList(Value As ImageList Ptr)
		FDisabledImagesList = Value
	End Property
	
	Private Sub ToolPalette.GetDropDownMenuItems
		FPopupMenuItems.Clear
		'For j As Integer = 0 To Buttons.Count - 1
		'    For i As Integer = 0 To Buttons.Item(j)->DropDownMenu.Count -1
		'        EnumPopupMenuItems *Buttons.Item(j)->DropDownMenu.Item(i)
		'    Next i
		'Next j
	End Sub
	
	Private Property ToolPalette.AutoSize As Boolean
		Return FAutosize
	End Property
	
	Private Property ToolPalette.AutoSize(Value As Boolean)
		FAutosize = Value
	End Property
	
	Private Property ToolPalette.Style As Integer
		Return FStyle
	End Property
	
	Private Property ToolPalette.Style(Value As Integer)
		FStyle = Value
			Dim As GtkToolbarStyle gStyle
			Select Case FStyle
			Case 0: gStyle = GTK_TOOLBAR_ICONS
			Case 1: gStyle = GTK_TOOLBAR_TEXT
			Case 2: gStyle = GTK_TOOLBAR_BOTH
			Case 3: gStyle = GTK_TOOLBAR_BOTH_HORIZ
			End Select
			gtk_tool_palette_set_style(GTK_TOOL_PALETTE(widget), gStyle)
			'For i As Integer = 0 To Groups.Count - 1
			'	For j As Integer = 0 To Groups.Item(i)->Buttons.Count - 1
			'		With *Groups.Item(i)->Buttons.Item(i)
			'			.ImageKey = .ImageKey
			'		End With
			'	Next j
			'Next i
			If GTK_IS_CONTAINER(widget) Then gtk_widget_queue_resize(widget)
			If GTK_IS_WIDGET(widget) Then gtk_widget_queue_draw(widget)
	End Property
	
	Private Property ToolPalette.Flat As Boolean
		Return FFlat
	End Property
	
	Private Property ToolPalette.Flat(Value As Boolean)
		FFlat = Value
	End Property
	
	Private Property ToolPalette.List As Boolean
		Return FList
	End Property
	
	Private Property ToolPalette.List(Value As Boolean)
		FList = Value
	End Property
	
	
	Private Property ToolPalette.Divider As Boolean
		Return FDivider
	End Property
	
	Private Property ToolPalette.Divider(Value As Boolean)
		FDivider = Value
	End Property
	
	Private Property ToolPalette.Transparency As Boolean
		Return FTransparent
	End Property
	
	Private Property ToolPalette.Transparency(Value As Boolean)
		FTransparent = Value
	End Property
	
	Private Property ToolPalette.BitmapWidth As Integer
		Return FBitmapWidth
	End Property
	
	Private Property ToolPalette.BitmapWidth(Value As Integer)
		FBitmapWidth = Value
	End Property
	
	Private Property ToolPalette.BitmapHeight As Integer
		Return FBitmapHeight
	End Property
	
	Private Property ToolPalette.BitmapHeight(Value As Integer)
		FBitmapHeight = Value
	End Property
	
	Private Property ToolPalette.ButtonWidth As Integer
		Return FButtonWidth
	End Property
	
	Private Property ToolPalette.ButtonWidth(Value As Integer)
		FButtonWidth = Value
	End Property
	
	Private Property ToolPalette.ButtonHeight As Integer
		Return FButtonHeight
	End Property
	
	Private Property ToolPalette.ButtonHeight(Value As Integer)
		FButtonHeight = Value
	End Property
	
	Private Property ToolPalette.Wrapable As Boolean
		Return FWrapable
	End Property
	
	Private Property ToolPalette.Wrapable(Value As Boolean)
		FWrapable = Value
	End Property
	
	Private Sub ToolPalette.WndProc(ByRef Message As Message)
	End Sub
	
	
	Private Sub ToolPalette.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Sub ToolPalette.HandleIsDestroyed(ByRef Sender As Control)
	End Sub
	
	Private Sub ToolPalette.HandleIsAllocated(ByRef Sender As Control)
	End Sub
	
	
	Private Operator ToolPalette.Cast As Control Ptr
		Return @This
	End Operator
	
	Private Constructor ToolPalette
		With This
				widget = gtk_tool_palette_new()
				gtk_tool_palette_set_style(GTK_TOOL_PALETTE(widget), GTK_TOOLBAR_BOTH_HORIZ)
				scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
				gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
				gtk_container_add(GTK_CONTAINER(scrolledwidget), widget)
				.RegisterClass "ToolPalette", @This
			FTransparent    = 1
			FAutosize       = 1
			FBitmapWidth    = 16
			FBitmapHeight   = 16
			FButtonWidth    = 16
			FButtonHeight   = 16
			Groups.Parent  = @This
			FEnabled = True
			.Child             = @This
			WLet(FClassName, "ToolPalette")
			WLet(FClassAncestor, "ToolBarWindow32")
			.Width             = 121
			.Height            = 26
			'.Font              = @Font
			'.Cursor            = @Cursor
		End With
	End Constructor
	
	Private Destructor ToolPalette
		Groups.Clear
	End Destructor
End Namespace
