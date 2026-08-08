'###############################################################################
'#  Control.bas                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TControl.bi                                                               #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.1                                                             #
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

#include once "Control.bi"

Namespace My.Sys.Forms
	#ifndef Control_Off
		Private Function SizeConstraints.ToString ByRef As WString
			WLet(FTemp, This.Left & "; " & This.Top & "; " & This.Width & "; " & This.Height)
			Return *FTemp
		End Function
		
		Private Function AnchorType.ToString ByRef As WString
			WLet(FTemp, This.Left & "; " & This.Top & "; " & This.Right & "; " & This.Bottom)
			Return *FTemp
		End Function
		
		#ifndef ReadProperty_Off
			Private Function Control.ReadProperty(ByRef PropertyName As String) As Any Ptr
				FTempString = LCase(PropertyName)
				Select Case FTempString
				Case "align": Return @FAlign
				Case "allowdrop": Return @FAllowDrop
				Case "allowdropfiles": Return @FAllowDropFiles
				Case "anchor": Return @Anchor
				Case "anchor.left": Return @Anchor.Left
				Case "anchor.right": Return @Anchor.Right
				Case "anchor.top": Return @Anchor.Top
				Case "anchor.bottom": Return @Anchor.Bottom
				Case "borderstyle": Return @FBorderStyle
				Case "backcolor": Return @FBackColor
				Case "canvas": Return @Canvas
				Case "constraints": Return @Constraints
				Case "constraints.left": Return @Constraints.Left
				Case "constraints.top": Return @Constraints.Top
				Case "constraints.width": Return @Constraints.Width
				Case "constraints.height": Return @Constraints.Height
				Case "contextmenu": Return ContextMenu
				Case "controlindex": FControlIndex = ControlIndex: Return @FControlIndex
				Case "controlcount": Return @FControlCount
				Case "cursor": Return @This.Cursor
				Case "doublebuffered": Return @DoubleBuffered
				Case "grouped": Return @FGrouped
				Case "helpcontext": Return @HelpContext
				Case "location": WLet(FTemp, WStr(FLeft) & ", " & WStr(FTop)): Return FTemp
				Case "location.x": Return @FLeft
				Case "location.y": Return @FTop
				Case "size": WLet(FTemp, WStr(FWidth) & ", " & WStr(FHeight)): Return FTemp
				Case "size.width": Return @FWidth
				Case "size.height": Return @FHeight
					Case "parentwidget": Return FParentWidget
				Case "enabled": Return @FEnabled
				Case "forecolor": Return @FForeColor
				Case "font": Return @This.Font
				Case "id": Return @FID
				Case "ischild": Return @FIsChild
				Case "parent": Return FParent
				Case "showhint": Return @FShowHint
				Case "showcaption": Return @FShowCaption
				Case "hint": Return FHint
				Case "hovertime": Return @FHoverTime
				Case "subclass": Return @SubClass
				Case "tabstop": Return @FTabStop
				Case "text": Return FText.vptr
				Case "visible": Return @FVisible
				Case Else: Return Base.ReadProperty(PropertyName)
				End Select
				Return 0
			End Function
		#endif
		
		#ifndef WriteProperty_Off
			Private Function Control.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
				If Value = 0 Then
					Select Case LCase(PropertyName)
					Case "parent": This.Parent = Value
					Case Else: Return Base.WriteProperty(PropertyName, Value)
					End Select
				Else
					Select Case LCase(PropertyName)
					Case "align": This.Align = *Cast(DockStyle Ptr, Value)
					Case "allowdrop": This.AllowDrop = QBoolean(Value)
					Case "allowdropfiles": This.AllowDropFiles = QBoolean(Value)
					Case "anchor.left": This.Anchor.Left = QInteger(Value)
					Case "anchor.right": This.Anchor.Right = QInteger(Value)
					Case "anchor.top": This.Anchor.Top = QInteger(Value)
					Case "anchor.bottom": This.Anchor.Bottom = QInteger(Value)
					Case "cursor": This.Cursor = QWString(Value)
					Case "doublebuffered": This.DoubleBuffered = QBoolean(Value)
					Case "borderstyle": This.BorderStyle = *Cast(BorderStyles Ptr, Value)
					Case "backcolor": This.BackColor = QInteger(Value)
					Case "constraints.left": This.Constraints.Left = QInteger(Value)
					Case "constraints.top": This.Constraints.Top = QInteger(Value)
					Case "constraints.width": This.Constraints.Width = QInteger(Value)
					Case "constraints.height": This.Constraints.Height = QInteger(Value)
					Case "controlindex": This.ControlIndex = QInteger(Value)
					Case "contextmenu": This.ContextMenu = Cast(PopupMenu Ptr, Value)
					Case "enabled": This.Enabled = QBoolean(Value)
					Case "grouped": This.Grouped = QBoolean(Value)
					Case "helpcontext": This.HelpContext = QInteger(Value)
					Case "hovertime": This.HoverTime = QInteger(Value)
					Case "font": This.Font = *Cast(My.Sys.Drawing.Font Ptr, Value)
					Case "id": This.ID = QInteger(Value)
					Case "ischild": This.IsChild = QInteger(Value)
					Case "forecolor": This.ForeColor = QInteger(Value)
					Case "location.x": This.Left = QInteger(Value)
					Case "location.y": This.Top = QInteger(Value)
					Case "size.width": This.Width = QInteger(Value)
					Case "size.height": This.Height = QInteger(Value)
					Case "parent": This.Parent = Value
						Case "parentwidget": This.ParentWidget = Value
					Case "tabstop": ChangeTabStop QBoolean(Value)
					Case "text": This.Text = QWString(Value)
					Case "visible": This.Visible = QBoolean(Value)
					Case "showhint": This.ShowHint = QBoolean(Value)
					Case "showcaption": This.ShowCaption = QBoolean(Value)
					Case "hint": This.Hint = QWString(Value)
					Case "subclass": This.SubClass = QBoolean(Value)
					Case Else: Return Base.WriteProperty(PropertyName, Value)
					End Select
				End If
				Return True
			End Function
		#endif
		
		'Sub Requests(Cpnt As Component Ptr)
		'	If Cpnt AndAlso *Cpnt Is Control Then
		'		Dim Ctrl As Control Ptr = Cast(Control Ptr, Cpnt)
		'		If Ctrl->Controls Then
		'			Ctrl->RequestAlign
		'			For i As Integer = 0 To Ctrl->ControlCount - 1
		'				Requests Ctrl->Controls[i]
		'			Next i
		'			Ctrl->RequestAlign
		'		End If
		'		If Ctrl->OnReSize Then Ctrl->OnReSize(*Ctrl)
		'	End If
		'End Sub
		
		'    Property Control.Location As LocationType
		'        Return FLocation
		'    End Property
		'
		'    Property Control.Location(Value As LocationType)
		'        FLocation = Value
		'        FLeft = Value.X
		'        FTop = Value.Y
		'        If FHandle Then Move
		'    End Property
		Private Property Control.Current As My.Sys.Drawing.Point
			Return FCurrent
		End Property
		
		Private Property Control.Current(Value As My.Sys.Drawing.Point)
			FCurrent = Value
		End Property
		
		Private Property Control.Location As My.Sys.Drawing.Point
			Return Type(This.Left, This.Top)
		End Property
		
		Private Property Control.Location(Value As My.Sys.Drawing.Point)
			This.SetBounds Value.X, Value.Y, This.Width, This.Height
		End Property
		
		Private Property Control.HoverTime As Integer
			Return FHoverTime
		End Property
		
		Private Property Control.HoverTime(Value As Integer)
			FHoverTime = Value
		End Property
		
		Private Property Control.Size As My.Sys.Drawing.Size
			Return Type(This.Width, This.Height)
		End Property
		
		Private Property Control.Size(Value As My.Sys.Drawing.Size)
			This.SetBounds This.Left, This.Top, Value.Width, Value.Height
		End Property
		
		Private Property Control.AllowDrop As Boolean
			Return FAllowDrop
		End Property
		
		Private Property Control.AllowDrop(Value As Boolean)
			FAllowDrop = Value
				If Value Then
					If GTK_IS_ENTRY(widget) OrElse GTK_IS_TEXT_VIEW(widget) Then
							gtk_drag_dest_set(widget, GTK_DEST_DEFAULT_HIGHLIGHT, gtk_target_entry_new("text/uri-list", 4, 0), 1, GDK_ACTION_COPY)
						'gtk_drag_dest_add_text_targets(widget)
					Else
						Dim As GtkTargetEntry target_table(0)
						target_table(0).target = Cast(gchar Ptr, @"text/uri-list")
						target_table(0).flags = 4
						target_table(0).info  = 0
						gtk_drag_dest_set(widget, GTK_DEST_DEFAULT_ALL, @target_table(0), 1, GDK_ACTION_COPY)
						gtk_drag_dest_add_text_targets(widget)
					End If
					g_signal_connect(widget, "drag-data-received", G_CALLBACK(@DragDataReceived), @This)
				Else
					gtk_drag_dest_unset(widget)
				End If
		End Property
		
		Private Property Control.AllowDropFiles As Boolean
			Return FAllowDropFiles
		End Property
		
		Private Property Control.AllowDropFiles(Value As Boolean)
			FAllowDropFiles = Value
				If Value Then
					If GTK_IS_ENTRY(widget) OrElse GTK_IS_TEXT_VIEW(widget) Then
							gtk_drag_dest_set(widget, GTK_DEST_DEFAULT_HIGHLIGHT, gtk_target_entry_new("text/uri-list", 4, 0), 1, GDK_ACTION_COPY)
						'gtk_drag_dest_add_text_targets(widget)
					Else
						Dim As GtkTargetEntry target_table(0)
						target_table(0).target = Cast(gchar Ptr, @"text/uri-list")
						target_table(0).flags = 4
						target_table(0).info  = 0
						gtk_drag_dest_set(widget, GTK_DEST_DEFAULT_ALL, @target_table(0), 1, GDK_ACTION_COPY)
						gtk_drag_dest_add_text_targets(widget)
					End If
					g_signal_connect(widget, "drag-data-received", G_CALLBACK(@DragDataReceived), @This)
				Else
					gtk_drag_dest_unset(widget)
				End If
		End Property
		
		#ifndef ControlCount_Off
			Private Function Control.ControlCount As Integer
				Return FControlCount
			End Function
		#endif
		
		#ifndef Focused_Off
			Private Function Control.Focused As Boolean
					Return widget AndAlso gtk_widget_is_focus(widget)
			End Function
		#endif
		
		#ifndef Control_GetTextLength_Off
			Private Function Control.GetTextLength() As Integer
					Return Len(This.Text)
			End Function
		#endif
		
		#ifndef GetForm_Off
			Private Function Control.GetForm As Control Ptr
				If FParent = 0 OrElse WGet(FClassName) = "Form" OrElse WGet(FClassName) = "UserControl" Then
					Return @This
				Else
					Return QControl(FParent).GetForm()
				End If
			End Function
		#endif
		
		#ifndef Control_TopLevelControl_Off
			Private Function Control.TopLevelControl As Control Ptr
				If FParent = 0 Then
					Return @This
				Else
					Return QControl(FParent).TopLevelControl()
				End If
			End Function
		#endif
		
		#ifndef BorderStyle_Off
			Private Property Control.BorderStyle As BorderStyles
				Return FBorderStyle
			End Property
			
			Private Property Control.BorderStyle(Value As BorderStyles)
				FBorderStyle = Value
					If scrolledwidget Then
						If Value Then
							gtk_scrolled_window_set_shadow_type(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_SHADOW_OUT)
						Else
							gtk_scrolled_window_set_shadow_type(GTK_SCROLLED_WINDOW(scrolledwidget), GTK_SHADOW_NONE)
						End If
					End If
			End Property
		#endif
		
		#ifndef Style_Off
			Private Property Control.Style As Integer
				Return FStyle
			End Property
			
			Private Property Control.Style(Value As Integer)
				FStyle = Value
			End Property
		#endif
		
		#ifndef ExStyle_Off
			Private Property Control.ExStyle As Integer
				Return FExStyle
			End Property
			
			Private Property Control.ExStyle(Value As Integer)
				FExStyle = Value
				'If FHandle Then RecreateWnd
			End Property
		#endif
		
		#ifndef IsChild_Off
			Private Property Control.IsChild As Boolean
					FIsChild = gtk_widget_get_parent(IIf(containerwidget, containerwidget, IIf(scrolledwidget, scrolledwidget, IIf(eventboxwidget, eventboxwidget, widget)))) <> 0
				Return FIsChild
			End Property
			
			Private Property Control.IsChild(Value As Boolean)
				FIsChild = Value
					If FIsChild <> Value Then
						If Value Then
							If Parent AndAlso Parent->layoutwidget Then
								gtk_layout_put(GTK_LAYOUT(Parent->layoutwidget), IIf(containerwidget, containerwidget, IIf(scrolledwidget, scrolledwidget, IIf(layoutwidget, layoutwidget, IIf(eventboxwidget, eventboxwidget, widget)))), FLeft, FTop)
							End If
						Else
							Dim As GtkWidget Ptr CtrlWidget = IIf(containerwidget, containerwidget, IIf(scrolledwidget, scrolledwidget, IIf(overlaywidget, overlaywidget, IIf(layoutwidget AndAlso gtk_widget_get_parent(layoutwidget) <> widget, layoutwidget, IIf(eventboxwidget, eventboxwidget, widget)))))
							g_object_ref(G_OBJECT(CtrlWidget))
							gtk_widget_unparent(CtrlWidget)
						End If
					End If
			End Property
		#endif
		
		#ifndef ID_Off
			Private Property Control.ID As Integer
				Return FID
			End Property
			
			Private Property Control.ID(Value As Integer)
				FID = Value
			End Property
		#endif
		
		Private Property Control.ControlIndex As Integer
			If This.FParent Then
				Return Cast(Control Ptr, This.FParent)->IndexOf(@This)
			Else
				Return -1
			End If
		End Property
		
		Private Property Control.ControlIndex(Value As Integer)
			If This.FParent Then
				With *Cast(Control Ptr, This.FParent)
					.ChangeControlIndex @This, Value
					.RequestAlign
				End With
			End If
		End Property
		
		#ifndef Text_Off
			Private Property Control.Text ByRef As WString
				If FText.vptr = 0 Then Return "" Else Return *FText.vptr
			End Property
			
			Private Property Control.Text(ByRef Value As WString)
				FText = Value
					If widget Then
						If GTK_IS_WINDOW(widget) Then
							If Value = "" Then
								gtk_window_set_title(GTK_WINDOW(widget), !"\0")
							Else
								gtk_window_set_title(GTK_WINDOW(widget), ToUtf8(Value))
							End If
						End If
					End If
			End Property
		#endif
		
		#ifndef Hint_Off
			Private Property Control.Hint ByRef As WString
				If FHint = 0 Then Return "" Else Return *FHint
			End Property
			
			Private Property Control.Hint(ByRef Value As WString)
				WLet(FHint, Value)
				If FHint = 0 Then Return
					If FShowHint Then
						If widget Then gtk_widget_set_tooltip_text(widget, ToUtf8(Value))
					End If
			End Property
		#endif
		
		#ifndef Align_Off
			Private Property Control.Align As DockStyle
				Return FAlign
			End Property
			
			Private Property Control.Align(Value As DockStyle)
				FAlign = Value
				'                #IfDef __USE_GTK__
				'					If widget Then
				'						Select Case FAlign
				'						Case 0 'None
				'							gtk_widget_set_halign(widget, GTK_ALIGN_BASELINE)
				'							gtk_widget_set_valign(widget, GTK_ALIGN_BASELINE)
				'						Case 1 'Left
				'							gtk_widget_set_halign(widget, GTK_ALIGN_START)
				'							gtk_widget_set_valign(widget, GTK_ALIGN_FILL)
				'						Case 2 'Right
				'							gtk_widget_set_halign(widget, GTK_ALIGN_END)
				'							gtk_widget_set_valign(widget, GTK_ALIGN_FILL)
				'						Case 3 'Top
				'							gtk_widget_set_halign(widget, GTK_ALIGN_FILL)
				'							gtk_widget_set_valign(widget, GTK_ALIGN_START)
				'						Case 4 'Bottom
				'							gtk_widget_set_halign(widget, GTK_ALIGN_FILL)
				'							gtk_widget_set_valign(widget, GTK_ALIGN_END)
				'						Case 5 'Client
				'							gtk_widget_set_halign(widget, GTK_ALIGN_FILL)
				'							gtk_widget_set_valign(widget, GTK_ALIGN_FILL)
				'						End Select
				'					End If
				'                #EndIf
				If FParent <> 0 Then QControl(FParent).RequestAlign
			End Property
		#endif
		
		#ifndef ClientWidth_Off
			Private Function Control.ClientWidth As Integer
					Dim As GtkRequisition minimum, requisition
					If layoutwidget Then
							FClientWidth = gtk_widget_get_allocated_width(layoutwidget)
						FClientWidth = UnScaleX(FClientWidth)
						'ElseIf fixedwidget Then
						'	FClientWidth = gtk_widget_get_allocated_width(fixedwidget)
						
						'	Dim As guint width_, height_
						'gtk_widget_get_preferred_size(scrolledwidget, @minimum, @requisition)
						'	gtk_layout_get_size(GTK_LAYOUT(layoutwidget), @width_, @height_)
						'	FClientWidth = width_
						'If scrolledwidget Then
						'gtk_widget_get_preferred_size(scrolledwidget, @minimum, @requisition)
						'FClientWidth = gtk_widget_get_allocated_width(scrolledwidget)
						'FClientWidth = minimum.width
						'ElseIf fixedwidget Then
						'	FClientWidth = gtk_widget_get_allocated_width(fixedwidget)
					ElseIf widget Then
						'gtk_widget_get_preferred_size(widget, @minimum, @requisition)
						'FClientWidth = gtk_widget_get_allocated_width(widget)
						FClientWidth = This.Width
						'FClientWidth = minimum.width
					End If
				Return FClientWidth
			End Function
		#endif
		
		#ifndef ClientHeight_Off
			Private Function Control.ClientHeight As Integer
					Dim As GtkRequisition minimum, requisition
					If layoutwidget Then
							FClientHeight = gtk_widget_get_allocated_height(layoutwidget)
						FClientHeight = UnScaleY(FClientHeight)
						'ElseIf fixedwidget Then
						'	FClientHeight = gtk_widget_get_allocated_height(fixedwidget)
						'	Dim As guint width_, height_
						'gtk_widget_get_preferred_size(scrolledwidget, @minimum, @requisition)
						'	gtk_layout_get_size(GTK_LAYOUT(layoutwidget), @width_, @height_)
						'	FClientHeight = height_
						'If scrolledwidget Then
						'gtk_widget_get_preferred_size(scrolledwidget, @minimum, @requisition)
						'	FClientHeight = gtk_widget_get_allocated_height(scrolledwidget) - 10
						'ElseIf fixedwidget Then
						'	FClientHeight = gtk_widget_get_allocated_height(fixedwidget)
					ElseIf widget Then
						'gtk_widget_get_preferred_size(widget, @minimum, @requisition)
						'FClientHeight = gtk_widget_get_allocated_height(widget) - 10
						FClientHeight = This.Height
					End If
				Return FClientHeight
			End Function
		#endif
		
		#ifndef ShowCaption_Off
			Private Property Control.ShowCaption As Boolean
				Return FShowCaption
			End Property
			
			Private Property Control.ShowCaption(Value As Boolean)
				FShowCaption = Value
					
			End Property
		#endif
		
		#ifndef ShowHint_Off
			Private Property Control.ShowHint As Boolean
				Return FShowHint
			End Property
			
			Private Property Control.ShowHint(Value As Boolean)
				FShowHint = Value
					If widget Then gtk_widget_set_has_tooltip(widget, Value)
					If WGet(FHint) <> "" Then
						If Value Then
							gtk_widget_set_tooltip_text(widget, ToUtf8(*FHint))
						Else
							gtk_widget_set_tooltip_text(widget, "")
						End If
					End If
			End Property
		#endif
		
		#ifndef Color_Off
			Private Property Control.BackColor As Integer
				Return FBackColor
			End Property
			
			Private Property Control.BackColor(Value As Integer)
				FBackColor = Value
				FBackColorRed = GetRed(Value) / 255.0
				FBackColorGreen = GetGreen(Value) / 255.0
				FBackColorBlue = GetBlue(Value) / 255.0
				Brush.Color = FBackColor
				Canvas.BackColor = FBackColor
				Invalidate
			End Property
			
			Private Property Control.ForeColor As Integer
				Return FForeColor
			End Property
			
			Private Property Control.ForeColor(Value As Integer)
				FForeColor = Value
				FForeColorRed = GetRed(Value) / 255.0
				FForeColorGreen = GetGreen(Value) / 255.0
				FForeColorBlue = GetBlue(Value) / 255.0
				Font.Color = FForeColor
				Canvas.Font.Color = FForeColor
				Invalidate
			End Property
		#endif
		
		#ifndef Control_Parent_Off
			#ifndef Control_Parent_Get_Off
				Private Property Control.Parent As Control Ptr
					Return Cast(Control Ptr, FParent)
				End Property
			#endif
			
			#ifndef Control_Parent_Set_Off
				Private Property Control.Parent(Value As Control Ptr)
					If FParent <> Value Then
						FParent = Value
						If Value Then Value->Add(@This)
					End If
				End Property
			#endif
		#endif
		
		#ifndef Control_StyleExists_Off
			Private Function Control.StyleExists(iStyle As Integer) As Boolean
				Return (Style And iStyle) = iStyle
			End Function
		#endif
		
		#ifndef Control_ExStyleExists_Off
			Private Function Control.ExStyleExists(iStyle As Integer) As Boolean
				Return (ExStyle And iStyle) = iStyle
			End Function
		#endif
		
		#ifndef Control_ChangeStyle_Off
			Private Sub Control.ChangeStyle(iStyle As Integer, Value As Boolean)
				If Value Then
					If ((Style And iStyle) <> iStyle) Then Style = Style Or iStyle
				ElseIf ((Style And iStyle) = iStyle) Then
					Style = Style And Not iStyle
				End If
			End Sub
		#endif
		
		Private Sub Control.ChangeExStyle(iStyle As Integer, Value As Boolean)
			If Value Then
				If ((ExStyle And iStyle) <> iStyle) Then ExStyle = ExStyle Or iStyle
			ElseIf ((ExStyle And iStyle) = iStyle) Then
				ExStyle = ExStyle And Not iStyle
			End If
		End Sub
		
		#ifndef Control_ChangeControlIndex_Off
			Private Sub Control.ChangeControlIndex(Ctrl As Control Ptr, Index As Integer)
				Dim OldIndex As Integer = This.IndexOf(Ctrl)
				If OldIndex > -1 AndAlso OldIndex <> Index AndAlso Index <= FControlCount - 1 Then
					If Index < OldIndex Then
						For i As Integer = OldIndex - 1 To Index Step -1
							Controls[i + 1] = Controls[i]
						Next i
						Controls[Index] = Ctrl
					Else
						For i As Integer = OldIndex + 1 To Index
							Controls[i - 1] = Controls[i]
						Next i
						Controls[Index] = Ctrl
					End If
				End If
			End Sub
		#endif
		
		Private Sub Control.ChangeTabIndex(Value As Integer)
			FTabIndex = Value
			Dim As Control Ptr ParentCtrl = GetForm
			Dim As Control Ptr Ctrl
			If ParentCtrl Then
				With *ParentCtrl
					.GetControls
					.FTabIndexList.Clear
					Dim As Integer Idx
					For i As Integer = 0 To .FControls.Count - 1
						Ctrl = .FControls.Item(i)
						If Ctrl <> @This AndAlso Ctrl->FTabIndex <> -2 Then .FTabIndexList.Add Ctrl->FTabIndex, Ctrl
					Next
					If FTabIndex = -1 OrElse FTabIndex > .FTabIndexList.Count Then FTabIndex = .FTabIndexList.Count
					.FTabIndexList.Sort
					If FTabIndex <> -2 Then .FTabIndexList.Insert FTabIndex, FTabIndex, @This
					For i As Integer = 0 To .FTabIndexList.Count - 1
						Ctrl = .FTabIndexList.Object(i)
						Ctrl->FTabIndex = i
					Next
				End With
			End If
		End Sub
		
			Private Property Control.ParentWidget As GtkWidget Ptr
				Return FParentWidget
			End Property
			
			Private Property Control.ParentWidget(Value As GtkWidget Ptr)
				FParentWidget = Value
				If GTK_IS_WIDGET(widget) Then
					If GTK_IS_LAYOUT(Value) Then
						gtk_layout_put(GTK_LAYOUT(Value), widget, FLeft, FTop)
					ElseIf GTK_IS_FIXED(Value) Then
						gtk_fixed_put(GTK_FIXED(Value), widget, FLeft, FTop)
					ElseIf GTK_IS_CONTAINER(Value) Then
						gtk_container_add(GTK_CONTAINER(Value), widget)
					End If
				End If
			End Property
		
		#ifndef Control_ChangeTabStop_Off
			Private Sub Control.ChangeTabStop(Value As Boolean)
				FTabStop = Value
			End Sub
		#endif
		
		Private Property Control.Grouped As Boolean
			Return FGrouped
		End Property
		
		Private Property Control.Grouped(Value As Boolean)
			FGrouped = Value
		End Property
		
		Private Property Control.Enabled As Boolean
			Return FEnabled
		End Property
		
		Private Property Control.Enabled(Value As Boolean)
			FEnabled = Value
				If widget Then gtk_widget_set_sensitive(widget, FEnabled)
		End Property
		
		Private Property Control.Visible() As Boolean
			Return FVisible
		End Property
		
		Private Property Control.Visible(Value As Boolean)
			FVisible = Value
			If (Not FDesignMode) OrElse Value Then
					'If Not gtk_widget_is_toplevel(widget) Then gtk_widget_set_child_visible(widget, Value)
					If containerwidget Then
						If Value Then
								gtk_widget_show_all(containerwidget)
							'gtk_widget_set_no_show_all(widget, Not Value)
							If Value Then gtk_widget_queue_draw(containerwidget)
						Else
							gtk_widget_set_visible(containerwidget, Value)
						End If
					ElseIf scrolledwidget Then
						If Value Then
								gtk_widget_show_all(scrolledwidget)
							'gtk_widget_set_no_show_all(widget, Not Value)
							If Value Then gtk_widget_queue_draw(scrolledwidget)
						Else
							gtk_widget_set_visible(scrolledwidget, Value)
						End If
					ElseIf widget Then
						gtk_widget_set_visible(widget, Value)
						'gtk_widget_set_no_show_all(widget, Not Value)
						If Value Then gtk_widget_queue_draw(widget)
					End If
			End If
		End Property
		
		Private Sub Control.Show
			Visible = True
		End Sub
		
		Private Sub Control.Hide '...'
			Visible = False
		End Sub
		
		
		Private Sub Control.CreateWnd
			If FParent Then
				xdpi = FParent->xdpi
				ydpi = FParent->ydpi
				Font.xdpi = FParent->xdpi
				Font.ydpi = FParent->ydpi
				Canvas.xdpi = FParent->xdpi
				Canvas.ydpi = FParent->ydpi
			End If
			Dim As Long nLeft   = ScaleX(FLeft)
			Dim As Long nTop    = ScaleY(FTop)
			Dim As Long nWidth  = ScaleX(FWidth)
			Dim As Long nHeight = ScaleY(FHeight)
		End Sub
		
		#ifndef Control_RecreateWnd_Off
			Private Sub Control.RecreateWnd
				Dim As Integer i
			End Sub
		#endif
		
		Private Sub Control.FreeWnd
				FreeWidget()
				'For i As Integer = 0 To ControlCount - 1
				'	Controls[i]->FreeWnd
				'Next
		End Sub
		
		Private Property Control.ContextMenu As PopupMenu Ptr
			Return FContextMenu
		End Property
		
		Private Property Control.ContextMenu(Value As PopupMenu Ptr)
			FContextMenu = Value
			If FContextMenu Then FContextMenu->ParentWindow = @This
		End Property
		
			Private Function Control.hover_cb(ByVal user_data As gpointer) As gboolean
				_Delete(Cast(Boolean Ptr, user_data))
				If hover_timer_id Then
					If user_data = MouseHoverMessage.pBoolean Then
						Dim As Control Ptr Ctrl = MouseHoverMessage.Sender
						If Ctrl->OnMouseHover Then Ctrl->OnMouseHover(*Ctrl->Designer, *Ctrl, Ctrl->DownButton, MouseHoverMessage.X, MouseHoverMessage.Y, MouseHoverMessage.State)
					End If
				End If
				Return False
			End Function
		
		Private Sub Control.ProcessMessage(ByRef Message As Message)
			Static bShift As Boolean, bCtrl As Boolean, bAlt As Boolean
			If OnMessage Then OnMessage(*Designer, This, Message)
				Dim As GdkEvent Ptr e = Message.Event
				Select Case Message.Event->type
				Case GDK_NOTHING
				Case GDK_BUTTON_PRESS
					'Message.Result = True
					DownButton = e->button.button - 1
						If gtk_widget_get_window(widget) = e->motion.window OrElse (layoutwidget AndAlso gtk_layout_get_bin_window(GTK_LAYOUT(layoutwidget)) = e->motion.window) Then
							If OnMouseDown Then OnMouseDown(*Designer, This, e->button.button - 1, e->button.x, e->button.y, e->button.state)
						End If
				Case GDK_BUTTON_RELEASE
					'Message.Result = True
					DownButton = -1
					If GTK_IS_BUTTON(widget) = 0 Then
						If OnClick Then OnClick(*Designer, This)
					End If
						If gtk_widget_get_window(widget) = e->motion.window OrElse (layoutwidget AndAlso gtk_layout_get_bin_window(GTK_LAYOUT(layoutwidget)) = e->motion.window) Then
							If OnMouseUp Then OnMouseUp(*Designer, This, e->button.button - 1, e->button.x, e->button.y, e->button.state)
						End If
					If e->button.button = 3 AndAlso ContextMenu Then
						Message.Result = True
						If ContextMenu->Widget Then
							ContextMenu->Popup(e->button.x, e->button.y, @Message)
						End If
					End If
					Case GDK_2BUTTON_PRESS, GDK_DOUBLE_BUTTON_PRESS
					If OnDblClick Then OnDblClick(*Designer, This)
					Message.Result = True
					Case GDK_3BUTTON_PRESS, GDK_TRIPLE_BUTTON_PRESS
				Case GDK_MOTION_NOTIFY
					'Message.Result = True
						If gtk_widget_get_window(widget) = e->motion.window OrElse (layoutwidget AndAlso gtk_layout_get_bin_window(GTK_LAYOUT(layoutwidget)) = e->motion.window) Then
						If OnMouseMove Then OnMouseMove(*Designer, This, DownButton, e->motion.x, e->motion.y, e->motion.state)
						hover_timer_id = 0
						If OnMouseHover Then
							Dim As Boolean Ptr pBoolean = _New(Boolean)
							MouseHoverMessage = Type(@This, e->motion.x, e->motion.y, e->motion.state, pBoolean, widget)
							hover_timer_id = g_timeout_add(IIf(FHoverTime = 0, 400, FHoverTime), Cast(GSourceFunc, @hover_cb), pBoolean)
							Message.Result = True
						End If
					End If
				Case GDK_KEY_PRESS
					'Message.Result = True
					If OnKeyDown Then OnKeyDown(*Designer, This, e->key.keyval, e->key.state)
					If CInt(OnKeyPress) AndAlso CInt(Not Message.Result) Then OnKeyPress(*Designer, This, Asc(*e->key.string))
				Case GDK_KEY_RELEASE
					'Message.Result = True
					If OnKeyUp Then OnKeyUp(*Designer, This, e->key.keyval, e->key.state)
				Case GDK_ENTER_NOTIFY
					If OnMouseEnter Then OnMouseEnter(*Designer, This)
				Case GDK_LEAVE_NOTIFY
					If OnMouseLeave Then OnMouseLeave(*Designer, This)
				Case GDK_CONFIGURE
					'					If Constraints.Left <> 0 OrElse Constraints.Top <> 0 OrElse Constraints.Width <> 0 OrElse Constraints.Height <> 0 Then
					'						g_signal_handlers_block_by_func(G_OBJECT(Message.widget), G_CALLBACK(@EventProc), @This)
					'						SetBounds(IIf(Constraints.Left, Constraints.Left, e->configure.x), IIf(Constraints.Top, Constraints.Top, e->configure.y), IIf(Constraints.Width, Constraints.Width, e->configure.Width), IIf(Constraints.Height, Constraints.Height, e->configure.Height))
					'						g_signal_handlers_unblock_by_func(G_OBJECT (Message.widget), G_CALLBACK(@EventProc), @This)
					'						g_signal_stop_emission_by_name(G_OBJECT(Message.widget), "event")
					'						Message.Result = True
					'					End If
					'					If gtk_is_window(widget) Then
					'						If Constraints.Left <> 0 Then gtk_window_move(gtk_window(widget), Constraints.Left, e->configure.y): Message.Result = True: Return
					'						If Constraints.Top <> 0 Then gtk_window_move(gtk_window(widget), e->configure.x, Constraints.Top): Message.Result = True: Return
					'						If Constraints.Width <> 0 Then gtk_window_resize(gtk_window(widget), Constraints.Width, e->configure.height): Message.Result = True: Return
					'						If Constraints.Height <> 0 Then gtk_window_resize(gtk_window(widget), e->configure.width, Constraints.Height): Message.Result = True: Return
					'					End If
					If OnMove Then OnMove(*Designer, This)
					'If OnResize Then OnResize(This)
					'RequestAlign
					'Requests @This
					'Message.Result = True
				Case GDK_DRAG_ENTER
				Case GDK_DRAG_LEAVE
					'Case GDK_DRAG_MOTION
					'Case GDK_DRAG_STATUS
				Case GDK_DROP_START
				Case GDK_DROP_FINISHED
					Case GDK_TOUCH_BEGIN, GDK_TOUCH_UPDATE, GDK_TOUCH_END, GDK_TOUCH_CANCEL
						Dim pe As PointerEventArgs
						pe.id = Cast(Integer, Message.Event->touch.sequence)
						pe.x = Message.Event->touch.x
						pe.y = Message.Event->touch.y
						pe.buttons = 1
						pe.primary = 1
						pe.modifiers = Message.Event->touch.state
						pe.pointerType = ptTouch
						Select Case Message.Event->type
						Case GDK_TOUCH_BEGIN
							pe.phase = PointerPhase.ppBegin
							If OnPointerDown Then OnPointerDown(*Designer, This, pe)
						Case GDK_TOUCH_UPDATE
							pe.phase = PointerPhase.ppMove
							If OnPointerUpdate Then OnPointerUpdate(*Designer, This, pe)
						Case GDK_TOUCH_END, GDK_TOUCH_CANCEL
							pe.phase = PointerPhase.ppEnd
							If OnPointerUp Then OnPointerUp(*Designer, This, pe)
						End Select
				Case GDK_MAP
					If Not FCreated Then
						If OnCreate Then OnCreate(*Designer, This)
						FCreated = True
							If OnGesture Then
								GestureDrag = gtk_gesture_drag_new(widget)
								g_signal_connect(GestureDrag, "begin", G_CALLBACK(@GestureBegin), @This)
								g_signal_connect(GestureDrag, "update", G_CALLBACK(@GestureUpdate), @This)
								g_signal_connect(GestureDrag, "end", G_CALLBACK(@GestureEnd), @This)
								GestureLongPress = gtk_gesture_long_press_new(widget)
								g_signal_connect(GestureLongPress, "begin", G_CALLBACK(@GestureBegin), @This)
								g_signal_connect(GestureLongPress, "update", G_CALLBACK(@GestureUpdate), @This)
								g_signal_connect(GestureLongPress, "end", G_CALLBACK(@GestureEnd), @This)
								GestureMultiPress = gtk_gesture_multi_press_new(widget)
								g_signal_connect(GestureMultiPress, "begin", G_CALLBACK(@GestureBegin), @This)
								g_signal_connect(GestureMultiPress, "update", G_CALLBACK(@GestureUpdate), @This)
								g_signal_connect(GestureMultiPress, "end", G_CALLBACK(@GestureEnd), @This)
								GesturePanHorizontal = gtk_gesture_pan_new(widget, GTK_ORIENTATION_HORIZONTAL)
								g_signal_connect(GesturePanHorizontal, "begin", G_CALLBACK(@GestureBegin), @This)
								g_signal_connect(GesturePanHorizontal, "update", G_CALLBACK(@GestureUpdate), @This)
								g_signal_connect(GesturePanHorizontal, "end", G_CALLBACK(@GestureEnd), @This)
								GesturePanVertical = gtk_gesture_pan_new(widget, GTK_ORIENTATION_VERTICAL)
								g_signal_connect(GesturePanVertical, "begin", G_CALLBACK(@GestureBegin), @This)
								g_signal_connect(GesturePanVertical, "update", G_CALLBACK(@GestureUpdate), @This)
								g_signal_connect(GesturePanVertical, "end", G_CALLBACK(@GestureEnd), @This)
								GestureRotate = gtk_gesture_rotate_new(widget)
								g_signal_connect(GestureRotate, "begin", G_CALLBACK(@GestureBegin), @This)
								g_signal_connect(GestureRotate, "update", G_CALLBACK(@GestureUpdate), @This)
								g_signal_connect(GestureRotate, "end", G_CALLBACK(@GestureEnd), @This)
								GestureSwipe = gtk_gesture_swipe_new(widget)
								g_signal_connect(GestureSwipe, "begin", G_CALLBACK(@GestureBegin), @This)
								g_signal_connect(GestureSwipe, "update", G_CALLBACK(@GestureUpdate), @This)
								g_signal_connect(GestureSwipe, "end", G_CALLBACK(@GestureEnd), @This)
								GestureZoom = gtk_gesture_zoom_new(widget)
								g_signal_connect(GestureZoom, "begin", G_CALLBACK(@GestureBegin), @This)
								g_signal_connect(GestureZoom, "update", G_CALLBACK(@GestureUpdate), @This)
								g_signal_connect(GestureZoom, "end", G_CALLBACK(@GestureEnd), @This)
							End If
					End If
					If OnShow Then OnShow(*Designer, This)
				Case GDK_UNMAP
					If OnHide Then OnHide(*Designer, This)
				Case GDK_VISIBILITY_NOTIFY
				Case GDK_PROPERTY_NOTIFY
				Case GDK_SELECTION_CLEAR
				Case GDK_SELECTION_REQUEST
				Case GDK_SELECTION_NOTIFY
				Case GDK_PROXIMITY_IN
				Case GDK_PROXIMITY_OUT
				Case GDK_CLIENT_EVENT
				Case GDK_DAMAGE
				Case GDK_GRAB_BROKEN
				Case GDK_OWNER_CHANGE
				Case GDK_SETTING
				Case GDK_WINDOW_STATE
					'Requests @This
					'RequestAlign
				Case GDK_SCROLL
						If OnMouseWheel Then OnMouseWheel(*Designer, This, e->scroll.delta_x, e->scroll.x, e->scroll.y, e->scroll.state)
				Case GDK_FOCUS_CHANGE
					If Cast(GdkEventFocus Ptr, e)->in Then
						If OnGotFocus Then OnGotFocus(*Designer, This)
						If Not FDesignMode Then
							Dim frm As Control Ptr = GetForm
							If frm Then
								frm->FActiveControl = @This
								If frm->OnActiveControlChanged Then frm->OnActiveControlChanged(*frm)
							End If
						End If
					Else
						If OnLostFocus Then OnLostFocus(*Designer, This)
					End If
				Case GDK_DELETE
				Case GDK_DESTROY
					If OnDestroy Then OnDestroy(*Designer, This)
					widget = 0
				Case GDK_EXPOSE
					If OnPaint Then OnPaint(*Designer, This, Canvas)
				Case GDK_EVENT_LAST
				End Select
		End Sub
		
		Private Sub Control.ProcessMessageAfter(ByRef Message As Message)
				Dim As GdkEvent Ptr e = Message.Event
				Select Case Message.Event->type
				Case GDK_CONFIGURE
					
				Case GDK_WINDOW_STATE
					
				End Select
				Message.Result = True
		End Sub
		
		Private Function Control.EnumPopupMenuItems(ByRef Item As MenuItem) As Boolean
			FPopupMenuItems.Add Item
			For i As Integer = 0 To Item.Count -1
				EnumPopupMenuItems *Item.Item(i)
			Next i
			Return True
		End Function
		
		Private Sub Control.GetPopupMenuItems
			FPopupMenuItems.Clear
			If ContextMenu Then
				For i As Integer = 0 To ContextMenu->Count - 1
					EnumPopupMenuItems *ContextMenu->Item(i)
				Next i
			End If
			If FLastNotifyIcon AndAlso FLastNotifyIcon->ContextMenu Then
				For i As Integer = 0 To FLastNotifyIcon->ContextMenu->Count - 1
					EnumPopupMenuItems *FLastNotifyIcon->ContextMenu->Item(i)
				Next i
			End If
		End Sub
		
		Private Function Control.EnumControls(Item As Control Ptr) As Boolean
			FControls.Add Item
			For i As Integer = 0 To Item->ControlCount - 1
				EnumControls Item->Controls[i]
			Next i
			Return True
		End Function
		
		Private Sub Control.GetControls
			FControls.Clear
			For i As Integer = 0 To ControlCount - 1
				EnumControls Controls[i]
			Next i
		End Sub
		
			Private Function Control.EventProc(widget As GtkWidget Ptr, Event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
				Dim Message As Message
				Dim As Control Ptr Ctrl = user_data
				Message = Type(Ctrl, widget, Event, False)
				If Ctrl Then
					'If Ctrl->DesignMode Then Return True
					Message.Sender = Ctrl
					Ctrl->ProcessMessage(Message)
				End If
				Return Message.Result
			End Function
			
			Private Function Control.EventAfterProc(widget As GtkWidget Ptr, Event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
				Dim Message As Message
				Dim As Control Ptr Ctrl = user_data
				Message = Type(Ctrl, widget, Event, False)
				If Ctrl Then
					'If Ctrl->DesignMode Then Return True
					Message.Sender = Ctrl
					Ctrl->ProcessMessageAfter(Message)
				End If
				Return Message.Result
			End Function
		
		Private Function Control.SelectNextControl(Prev As Boolean = False) As Control Ptr
				
			Return 0
		End Function
		
		Private Sub Control.Move(cLeft As Integer, cTop As Integer, cWidth As Integer, cHeight As Integer)
			Base.Move IIf(FDesignMode AndAlso (Designer = @This), 0, IIf(Constraints.Left, Constraints.Left, cLeft)), IIf(FDesignMode AndAlso (Designer = @This), 0, IIf(Constraints.Top, Constraints.Top, cTop)), IIf(Constraints.Width, Constraints.Width, cWidth), IIf(Constraints.Height, Constraints.Height, cHeight)
		End Sub
		
			Private Sub Control.Control_SizeAllocate(widget As GtkWidget Ptr, allocation As GdkRectangle Ptr, user_data As Any Ptr)
				Dim As Control Ptr Ctrl = Cast(Any Ptr, user_data)
				If GTK_IS_LAYOUT(widget) OrElse GTK_IS_SCROLLED_WINDOW(widget) OrElse GTK_IS_BOX(widget) Then
					Dim As Integer AllocatedWidth = allocation->width, AllocatedHeight = allocation->height
					'					#ifdef __USE_GTK3__
					'						Dim As Integer AllocatedWidth = gtk_widget_get_allocated_width(widget), AllocatedHeight = gtk_widget_get_allocated_height(widget)
					'					#else
					'						Dim As Integer AllocatedWidth = widget->allocation.width, AllocatedHeight = widget->allocation.height
					'					#endif
					''					If Ctrl->BackColor <> -1 Then
					''						Dim As Integer iColor = Ctrl->BackColor
					''						cairo_rectangle(cr, 0.0, 0.0, AllocatedWidth, AllocatedHeight)
					''						cairo_set_source_rgb(cr, Abs(GetRed(iColor) / 255.0), Abs(GetGreen(iColor) / 255.0), Abs(GetBlue(iColor) / 255.0))
					''						cairo_fill(cr)
					''					End If
					If AllocatedWidth <> Ctrl->AllocatedWidth Or AllocatedHeight <> Ctrl->AllocatedHeight Then
						Ctrl->AllocatedWidth = AllocatedWidth
						Ctrl->AllocatedHeight = AllocatedHeight
						Ctrl->RequestAlign Ctrl->UnScaleX(AllocatedWidth), Ctrl->UnScaleY(AllocatedHeight), True
						If Ctrl->OnResize Then Ctrl->OnResize(*Ctrl->Designer, *Ctrl, Ctrl->UnScaleX(AllocatedWidth), Ctrl->UnScaleY(AllocatedHeight))
					End If
				End If
			End Sub
			
			Private Function Control.Control_Draw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As Any Ptr) As Boolean
				Dim As Control Ptr Ctrl = Cast(Any Ptr, data1)
					If Ctrl <> 0 AndAlso (GTK_IS_LAYOUT(widget) OrElse GTK_IS_BOX(widget) OrElse GTK_IS_EVENT_BOX(widget)) Then
					Ctrl->Canvas.HandleSetted = True
					Ctrl->Canvas.Handle = cr
					'					Dim allocation As GtkAllocation
					'					gtk_widget_get_allocation(widget, @allocation)
						Dim As Integer AllocatedWidth = gtk_widget_get_allocated_width(widget), AllocatedHeight = gtk_widget_get_allocated_height(widget)
					'Dim As Integer AllocatedWidth = allocation.width, AllocatedHeight = allocation.height
					If Ctrl->BackColor <> -1 Then
						Dim As Integer iColor = Ctrl->BackColor
						cairo_rectangle(cr, 0.0, 0.0, AllocatedWidth, AllocatedHeight)
						cairo_set_source_rgb(cr, Ctrl->FBackColorRed, Ctrl->FBackColorGreen, Ctrl->FBackColorBlue)
						cairo_fill(cr)
					End If
					If Ctrl->OnPaint Then Ctrl->OnPaint(*Ctrl->Designer, *Ctrl, Ctrl->Canvas)
					'					#ifdef __USE_GTK3__
					'						Control_SizeAllocate(widget, @allocation, data1)
					'					#endif
					If AllocatedWidth <> Ctrl->AllocatedWidth Or AllocatedHeight <> Ctrl->AllocatedHeight Then
						Ctrl->AllocatedWidth = AllocatedWidth
						Ctrl->AllocatedHeight = AllocatedHeight
						Ctrl->RequestAlign Ctrl->UnScaleX(AllocatedWidth), Ctrl->UnScaleY(AllocatedHeight), True
						If Ctrl->OnResize Then Ctrl->OnResize(*Ctrl->Designer, *Ctrl, Ctrl->UnScaleX(AllocatedWidth), Ctrl->UnScaleY(AllocatedHeight))
					End If
					Ctrl->Canvas.Handle = 0
					Ctrl->Canvas.HandleSetted = False
				End If
				Return False
			End Function
			
			Private Function Control.Control_ExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As Any Ptr) As Boolean
				Return False
			End Function
			
			Private Function Control.Control_Scroll(self As GtkScrolledWindow Ptr, scroll As GtkScrollType Ptr, horizontal As Boolean, user_data As Any Ptr) As Boolean
				Dim As Control Ptr Ctrl = user_data
				If Ctrl->OnScroll Then Ctrl->OnScroll(*Ctrl->Designer, *Ctrl)
				Return False
			End Function
			
				Private Sub Control.Gesture(self As GtkGesture Ptr, sequence As GdkEventSequence Ptr, phase As GesturePhase, user_data As Any Ptr)
					Dim As Control Ptr Ctrl = user_data
					Dim As GestureEventArgs e
					e.phase = phase
					If GTK_IS_GESTURE_DRAG(self) Then
						e.gestureType = GestureType.gtPan
						Dim As gdouble dx, dy
						gtk_gesture_drag_get_offset(GTK_GESTURE_DRAG(self), @dx, @dy)
						e.dx = dx
						e.dy = dy
					ElseIf GTK_IS_GESTURE_LONG_PRESS(self) Then
						e.gestureType = GestureType.gtLongPress
					ElseIf GTK_IS_GESTURE_MULTI_PRESS(self) Then
						e.gestureType = GestureType.gtTwoFingerTap
					ElseIf GTK_IS_GESTURE_PAN(self) Then
						e.gestureType = GestureType.gtDirectionalPan
						Select Case gtk_gesture_pan_get_orientation(GTK_GESTURE_PAN(self))
						Case GTK_ORIENTATION_HORIZONTAL: e.orientation = Orientation.orHorizontal
						Case GTK_ORIENTATION_VERTICAL: e.orientation = Orientation.orHorizontal
						End Select
					ElseIf GTK_IS_GESTURE_ROTATE(self) Then
						e.gestureType = GestureType.gtRotate
						e.scale = gtk_gesture_rotate_get_angle_delta(GTK_GESTURE_ROTATE(self))
					ElseIf GTK_IS_GESTURE_SWIPE(self) Then
						e.gestureType = GestureType.gtSwipe
					ElseIf GTK_IS_GESTURE_ZOOM(self) Then
						e.gestureType = GestureType.gtZoom
						e.scale = gtk_gesture_zoom_get_scale_delta(GTK_GESTURE_ZOOM(self))
					End If
					Dim As gdouble x, y
					gtk_gesture_get_point(self, sequence, @x, @y)
					e.x = x
					e.y = y
					If Ctrl->OnGesture Then Ctrl->OnGesture(*Ctrl->Designer, *Ctrl, e)
					If e.handled Then
						gtk_gesture_set_state(self, GTK_EVENT_SEQUENCE_CLAIMED)
					End If
				End Sub
				
				Private Sub Control.GestureBegin(self As GtkGesture Ptr, sequence As GdkEventSequence Ptr, user_data As Any Ptr)
					Gesture(self, sequence, GesturePhase.gpBegin, user_data)
				End Sub
				
				Private Sub Control.GestureUpdate(self As GtkGesture Ptr, sequence As GdkEventSequence Ptr, user_data As Any Ptr)
					Gesture(self, sequence, GesturePhase.gpUpdate, user_data)
				End Sub
				
				Private Sub Control.GestureEnd(self As GtkGesture Ptr, sequence As GdkEventSequence Ptr, user_data As Any Ptr)
					Gesture(self, sequence, GesturePhase.gpEnd, user_data)
				End Sub
			
			Private Sub Control.DragDataReceived(self As GtkWidget Ptr, context As GdkDragContext Ptr, x As gint, y As gint, selection_data As GtkSelectionData Ptr, info As guint, Time As guint, user_data As Any Ptr)
				Dim As Control Ptr Ctrl = user_data
				If info = 0 Then
					If Ctrl->OnDropFile Then
						Dim As UString res(Any)
						Dim As UString datatext = *Cast(gchar Ptr, gtk_selection_data_get_data(selection_data)) '*g_locale_from_utf8(gtk_selection_data_get_text(selection_data), -1, 0, 0, 0)
						'If StartsWith(datatext, "file://") Then
						datatext = Mid(datatext, 8)
						Split(datatext, Chr(13) & Chr(10), res())
						For i As Integer = 0 To UBound(res)
							If StartsWith(res(i), "file://") Then res(i) = Mid(res(i), 8)
							If Trim(res(i)) <> "" Then
								Ctrl->OnDropFile(*Ctrl->Designer, *Ctrl, res(i))
							End If
						Next
						'End If
					End If
					gtk_drag_finish(context, True, False, Time)
				Else
					gtk_drag_finish(context, False, False, Time)
				End If
			End Sub
			
			Private Function Control.ConfigureEventProc(widget As GtkWidget Ptr, e As GdkEvent Ptr, user_data As Any Ptr) As Boolean
				Dim As Control Ptr Ctrl = user_data
				If Ctrl Then
					If Ctrl->Constraints.Left <> 0 OrElse Ctrl->Constraints.Top <> 0 OrElse Ctrl->Constraints.Width <> 0 OrElse Ctrl->Constraints.Height <> 0 Then
						If GTK_IS_WINDOW(widget) Then
							'g_signal_handlers_block_by_func(G_OBJECT(widget), G_CALLBACK(@ConfigureEventProc), user_data)
							If Ctrl->Constraints.Left <> 0 OrElse Ctrl->Constraints.Top <> 0 Then
								Dim As GdkRectangle rect
								gdk_window_get_frame_extents(gtk_widget_get_window(widget), @rect)
								If Ctrl->Constraints.Left <> 0 AndAlso Ctrl->Constraints.Left <> rect.x OrElse Ctrl->Constraints.Top <> 0 AndAlso Ctrl->Constraints.Top <> rect.y Then
									gtk_window_move(GTK_WINDOW(widget), _
									IIf(Ctrl->Constraints.Left, Ctrl->Constraints.Left, rect.x), _
									IIf(Ctrl->Constraints.Top, Ctrl->Constraints.Top, rect.y))
								End If
							End If
							'							If Ctrl->Constraints.Left <> 0 OrElse Ctrl->Constraints.Top <> 0 Then
							'								If Ctrl->Constraints.Left <> 0 AndAlso Ctrl->Constraints.Left <> e->configure.x OrElse Ctrl->Constraints.Top <> 0 AndAlso Ctrl->Constraints.Top <> e->configure.y - 37 Then
							'									gtk_window_move(gtk_window(widget), _
							'										IIf(Ctrl->Constraints.Left, Ctrl->Constraints.Left, e->configure.x), _
							'										IIf(Ctrl->Constraints.Top, Ctrl->Constraints.Top, e->configure.y - 37))
							'								End If
							'							End If
							'g_signal_handlers_unblock_by_func(G_OBJECT (widget), G_CALLBACK(@ConfigureEventProc), user_data)
							'g_signal_stop_emission_by_name(G_OBJECT(widget), "configure-event")
							Return True
						End If
					End If
				End If
				Return False
			End Function
			
			Private Function Control.RegisterClass(ByRef wClassName As WString, Obj As Any Ptr, WndProcAddr As Any Ptr = 0) As Boolean
				Dim As Boolean Result
				Dim Proc As Function(widget As GtkWidget Ptr, Event As GdkEvent Ptr, user_data As Any Ptr) As Boolean = WndProcAddr
				g_object_set_data(G_OBJECT(widget), "MFFControl", Cast(gpointer, @This))
				If layoutwidget Then
						gtk_widget_set_events(layoutwidget, _
						GDK_EXPOSURE_MASK Or _
						GDK_SCROLL_MASK Or _
						GDK_STRUCTURE_MASK Or _
						GDK_KEY_PRESS_MASK Or _
						GDK_KEY_RELEASE_MASK Or _
						GDK_FOCUS_CHANGE_MASK Or _
						GDK_LEAVE_NOTIFY_MASK Or _
						GDK_BUTTON_PRESS_MASK Or _
						GDK_BUTTON_RELEASE_MASK Or _
						GDK_POINTER_MOTION_MASK Or _
						GDK_POINTER_MOTION_HINT_MASK)
						'Result = g_signal_connect(layoutwidget, "event", G_CALLBACK(IIf(WndProcAddr = 0, @EventProc, Proc)), Obj)
						'Result = g_signal_connect(layoutwidget, "event-after", G_CALLBACK(IIf(WndProcAddr = 0, @EventAfterProc, Proc)), Obj)
							g_signal_connect(layoutwidget, "draw", G_CALLBACK(@Control_Draw), Obj)
							'g_signal_connect(layoutwidget, "size-allocate", G_CALLBACK(@Control_SizeAllocate), Obj)
				End If
				If widget Then
					Font.Parent = @This
						gtk_widget_set_events(IIf(eventboxwidget, eventboxwidget, widget), _
						GDK_EXPOSURE_MASK Or _
						GDK_SCROLL_MASK Or _
						GDK_STRUCTURE_MASK Or _
						GDK_KEY_PRESS_MASK Or _
						GDK_KEY_RELEASE_MASK Or _
						GDK_FOCUS_CHANGE_MASK Or _
						GDK_LEAVE_NOTIFY_MASK Or _
						GDK_BUTTON_PRESS_MASK Or _
						GDK_BUTTON_RELEASE_MASK Or _
						GDK_POINTER_MOTION_MASK Or _
						GDK_POINTER_MOTION_HINT_MASK)
						Result = g_signal_connect(widget, "event", G_CALLBACK(IIf(WndProcAddr = 0, @EventProc, Proc)), Obj)
						Result = g_signal_connect(widget, "event-after", G_CALLBACK(IIf(WndProcAddr = 0, @EventAfterProc, Proc)), Obj)
						Result = g_signal_connect(G_OBJECT(widget), "configure-event", G_CALLBACK(@ConfigureEventProc), @This)
							g_signal_connect(widget, "draw", G_CALLBACK(@Control_Draw), Obj)
					If GTK_IS_SCROLLED_WINDOW(widget) Then
						g_signal_connect(widget, "size-allocate", G_CALLBACK(@Control_SizeAllocate), Obj)
					End If
					'g_signal_connect(widget, "destroy", G_CALLBACK(Control_Destroy), @widget)
				End If
					If eventboxwidget Then
						Font.Parent = @This
						gtk_widget_set_events(IIf(eventboxwidget, eventboxwidget, widget), _
						GDK_EXPOSURE_MASK Or _
						GDK_SCROLL_MASK Or _
						GDK_STRUCTURE_MASK Or _
						GDK_KEY_PRESS_MASK Or _
						GDK_KEY_RELEASE_MASK Or _
						GDK_FOCUS_CHANGE_MASK Or _
						GDK_LEAVE_NOTIFY_MASK Or _
						GDK_BUTTON_PRESS_MASK Or _
						GDK_BUTTON_RELEASE_MASK Or _
						GDK_POINTER_MOTION_MASK Or _
						GDK_POINTER_MOTION_HINT_MASK)
						Result = g_signal_connect(eventboxwidget, "event", G_CALLBACK(IIf(WndProcAddr = 0, @EventProc, Proc)), Obj)
						Result = g_signal_connect(eventboxwidget, "event-after", G_CALLBACK(IIf(WndProcAddr = 0, @EventAfterProc, Proc)), Obj)
							g_signal_connect(eventboxwidget, "draw", G_CALLBACK(@Control_Draw), Obj)
					End If
				If scrolledwidget Then
					Result = g_signal_connect(scrolledwidget, "scroll-child", G_CALLBACK(@Control_Scroll), @This)
				End If
				Return Result
			End Function
		
		Private Sub Control.SetMargins(mLeft As Integer, mTop As Integer, mRight As Integer, mBottom As Integer)
			Margins.Left   = mLeft
			Margins.Top    = mTop
			Margins.Right  = mRight
			Margins.Bottom = mBottom
			RequestAlign
		End Sub
		
		Sub Control.GetMax(ByRef MaxWidth As Integer, ByRef MaxHeight As Integer)
			MaxWidth = 0
			MaxHeight = 0
			For i As Integer = 0 To ControlCount - 1
				With *Controls[i]
					If .FVisible Then
							If MaxWidth < .Left + .Width + .ExtraMargins.Right Then MaxWidth = .Left + .Width + .ExtraMargins.Right
							If MaxHeight < .Top + .Height + .ExtraMargins.Bottom Then MaxHeight = .Top + .Height + .ExtraMargins.Bottom
					End If
				End With
			Next
			MaxWidth += Margins.Right
			MaxHeight += Margins.Bottom
		End Sub
		
		Private Sub Control.RequestAlign(iClientWidth As Integer = -1, iClientHeight As Integer = -1, bInDraw As Boolean = False, bWithoutControl As Control Ptr = 0)
				If GTK_IS_NOTEBOOK(widget) Then
					For i As Integer = 0 To ControlCount - 1
						'Controls[i]->Width = FWidth 'gtk_widget_get_allocated_width(widget) - 30
						'Controls[i]->Height = FHeight 'gtk_widget_get_allocated_height(widget) - 25
						Controls[i]->RequestAlign
					Next i
					Exit Sub
				End If
				If bInDraw = False Then
					AllocatedWidth = 0
					AllocatedHeight = 0
					Exit Sub
				End If
			Dim As Control Ptr Ptr ListLeft, ListRight, ListTop, ListBottom, ListClient
			Dim As Integer i,LeftCount = 0, RightCount = 0, TopCount = 0, BottomCount = 0, ClientCount = 0
			Dim As Integer tTop, bTop, lLeft, rLeft
			Dim As Integer aLeft, aTop, aWidth, aHeight
			If iClientWidth = -1 Then iClientWidth = ClientWidth
			If iClientHeight = -1 Then iClientHeight = ClientHeight
			'If ClassName = "ScrollControl" Then iClientWidth = Width: iClientHeight = Height
			If iClientWidth <= 0 OrElse iClientHeight <= 0 Then Exit Sub
			lLeft = Margins.Left
			rLeft = iClientWidth - Margins.Right
			tTop  = Margins.Top
			bTop  = iClientHeight - Margins.Bottom
			If ControlCount <> 0 Then
					If rLeft <= 1 And bTop <= 1 Then
						Exit Sub
					End If
					If layoutwidget Then
						'gtk_layout_set_size(gtk_layout(layoutwidget), rLeft, bTop)
						'gtk_widget_set_size_request(layoutwidget, Max(0, rLeft), Max(0, tTop))
					ElseIf fixedwidget Then
						'gtk_widget_set_size_request(fixedwidget, Max(0, rLeft), Max(0, tTop))
					End If
					'If FMenu AndAlso FMenu->widget Then
					'	tTop = gtk_widget_get_allocated_height(FMenu->widget)
					'	gtk_widget_set_size_request(FMenu->widget, Max(0, rLeft), Max(0, tTop))
					'End If
					'If fixedwidget Then
					'	gtk_widget_set_size_request(fixedwidget, Max(0, rLeft), Max(0, bTop))
					'End If
				'This.UpdateLock
				'#ifdef __USE_GTK__
				'	Dim bNotPainted As Boolean
				'	For i = 0 To ControlCount - 1
				'		If Controls[i]->FAutoSize Then
				'			If Controls[i]->AllocatedWidth = 0 AndAlso Controls[i]->AllocatedHeight = 0 Then
				'				Controls[i]->Repaint
				'				bNotPainted = True
				'			End If
				'		End If
				'	Next
				'	If bNotPainted Then
				'		AllocatedWidth = 0
				'		AllocatedHeight = 0
				'		Repaint
				'		'If FAutoSize AndAlso This.Parent Then
				'			This.Parent->AllocatedWidth = 0
				'			This.Parent->AllocatedHeight = 0
				'		'	This.Parent->Repaint
				'		'End If
				'		Exit Sub
				'	End If
				'#endif
				For i = 0 To ControlCount - 1
					'If Controls[i]->Handle = 0 Then Continue For
					Select Case Controls[i]->Align
					Case 1'alLeft
						LeftCount += 1
						ListLeft = _Reallocate(ListLeft,SizeOf(Control Ptr)*LeftCount)
						ListLeft[LeftCount - 1] = Controls[i]
					Case 2'alRight
						RightCount += 1
						ListRight = _Reallocate(ListRight,SizeOf(Control Ptr)*RightCount)
						ListRight[RightCount - 1] = Controls[i]
					Case 3'alTop
						TopCount += 1
						ListTop = _Reallocate(ListTop, SizeOf(Control Ptr)*TopCount)
						ListTop[TopCount - 1] = Controls[i]
					Case 4'alBottom
						BottomCount += 1
						ListBottom = _Reallocate(ListBottom,SizeOf(Control Ptr)*BottomCount)
						ListBottom[BottomCount - 1] = Controls[i]
					Case 5'alClient
						ClientCount += 1
						ListClient = _Reallocate(ListClient,SizeOf(Control Ptr)*ClientCount)
						ListClient[ClientCount - 1] = Controls[i]
					Case Else
						If ClassName = "VerticalBox" Then
							TopCount += 1
							ListTop = _Reallocate(ListTop, SizeOf(Control Ptr)*TopCount)
							ListTop[TopCount - 1] = Controls[i]
						ElseIf ClassName = "HorizontalBox" Then
							LeftCount += 1
							ListLeft = _Reallocate(ListLeft,SizeOf(Control Ptr)*LeftCount)
							ListLeft[LeftCount - 1] = Controls[i]
						ElseIf ClassName = "PagePanel" AndAlso Controls[i]->Name <> "PagePanel_NumericUpDownControl" Then
							ClientCount += 1
							ListClient = _Reallocate(ListClient,SizeOf(Control Ptr)*ClientCount)
							ListClient[ClientCount - 1] = Controls[i]
						End If
					End Select
					With *Controls[i]
						If Cast(Integer, .Anchor.Left) + Cast(Integer, .Anchor.Right) + Cast(Integer, .Anchor.Top) + Cast(Integer, .Anchor.Bottom) <> 0 Then
								If CInt(.FVisible) Then
								aLeft = .FLeft: aTop = .FTop: aWidth = .FWidth: aHeight = .FHeight
								This.FWidth = This.Width: This.FHeight = This.Height
								If .Anchor.Left <> asNone Then
									If .Anchor.Left = asAnchorProportional Then aLeft = This.FWidth / .FAnchoredParentWidth * .FAnchoredLeft
									If .Anchor.Right <> asNone Then aWidth = This.FWidth - aLeft - IIf(.Anchor.Right = asAnchor, .FAnchoredRight, This.FWidth / .FAnchoredParentWidth * .FAnchoredRight)
								ElseIf .Anchor.Right <> asNone Then
									aLeft = This.FWidth - .FWidth - IIf(.Anchor.Right = asAnchor, .FAnchoredRight, This.FWidth / .FAnchoredParentWidth * .FAnchoredRight)
								End If
								If .Anchor.Top <> asNone Then
									If .Anchor.Top = asAnchorProportional Then aTop = This.FHeight / .FAnchoredParentHeight * .FAnchoredTop
									If .Anchor.Bottom <> asNone Then aHeight = This.FHeight - aTop - IIf(.Anchor.Bottom = asAnchor, .FAnchoredBottom, This.FHeight / .FAnchoredParentHeight * .FAnchoredBottom)
								ElseIf .Anchor.Bottom <> asNone Then
									aTop = This.FHeight - .FHeight - IIf(.Anchor.Bottom = asAnchor, .FAnchoredBottom, This.FHeight / .FAnchoredParentHeight * .FAnchoredBottom)
								End If
								If bWithoutControl <> Controls[i] Then .SetBounds(aLeft, aTop, aWidth, aHeight)
							End If
						End If
					End With
					'Select Case Controls[i]->Align
					'Case 0 'None
					'	gtk_widget_set_halign(Controls[i]->widget, GTK_ALIGN_BASELINE)
					'	gtk_widget_set_valign(Controls[i]->widget, GTK_ALIGN_BASELINE)
					'Case 1 'Left
					'	gtk_widget_set_halign(Controls[i]->widget, GTK_ALIGN_START)
					'	gtk_widget_set_valign(Controls[i]->widget, GTK_ALIGN_FILL)
					'Case 2 'Right
					'	gtk_widget_set_halign(Controls[i]->widget, GTK_ALIGN_END)
					'	gtk_widget_set_valign(Controls[i]->widget, GTK_ALIGN_FILL)
					'Case 3 'Top
					'	gtk_widget_set_halign(Controls[i]->widget, GTK_ALIGN_FILL)
					'	gtk_widget_set_valign(Controls[i]->widget, GTK_ALIGN_START)
					'Case 4 'Bottom
					'	gtk_widget_set_halign(Controls[i]->widget, GTK_ALIGN_FILL)
					'	gtk_widget_set_valign(Controls[i]->widget, GTK_ALIGN_END)
					'Case 5 'Client
					'	gtk_widget_set_halign(Controls[i]->widget, GTK_ALIGN_FILL)
					'	gtk_widget_set_valign(Controls[i]->widget, GTK_ALIGN_FILL)
					'End Select
				Next i
				'#IfDef __USE_GTK__
				'#Else
				'?ClassName, rLeft, bTop
				For i = 0 To TopCount -1
					With *ListTop[i]
						If .FVisible Then
								tTop += .ExtraMargins.Top + IIf(bWithoutControl = ListTop[i], .FHeight, .Height) + .ExtraMargins.Bottom + IIf(i = 0, 0, FVerticalSpacing)
								If GTK_IS_BOX(.widget) Then
									.RequestAlign rLeft - lLeft - .ExtraMargins.Left - .ExtraMargins.Right, .Height, True, bWithoutControl
								End If
							If bWithoutControl <> ListTop[i] Then .SetBounds(lLeft + .ExtraMargins.Left, tTop - .Height - .ExtraMargins.Bottom, rLeft - lLeft - .ExtraMargins.Left - .ExtraMargins.Right, .Height)
						End If
					End With
				Next i
				'bTop = ClientHeight
				For i = 0 To BottomCount -1
					With *ListBottom[i]
						If .FVisible Then
							bTop -= .ExtraMargins.Top + .Height + .ExtraMargins.Bottom - IIf(i = 0, 0, FVerticalSpacing)
								If GTK_IS_BOX(.widget) Then
									.RequestAlign rLeft - lLeft - .ExtraMargins.Left - .ExtraMargins.Right, .Height, True, bWithoutControl
								End If
							If bWithoutControl <> ListBottom[i] Then .SetBounds(lLeft + .ExtraMargins.Left, bTop + .ExtraMargins.Top, rLeft - lLeft - .ExtraMargins.Left - .ExtraMargins.Right, .Height)
						End If
					End With
				Next i
				'lLeft = 0
				For i = 0 To LeftCount -1
					With *ListLeft[i]
						If .FVisible Then
							lLeft += .ExtraMargins.Left + .Width + .ExtraMargins.Right + IIf(i = 0, 0, FHorizontalSpacing)
								If GTK_IS_BOX(.widget) Then
									.RequestAlign .Width, bTop - tTop - .ExtraMargins.Top - .ExtraMargins.Bottom, True, bWithoutControl
								End If
							If bWithoutControl <> ListLeft[i] Then .SetBounds(lLeft - .Width - .ExtraMargins.Right, tTop + .ExtraMargins.Top, .Width, bTop - tTop - .ExtraMargins.Top - .ExtraMargins.Bottom)
						End If
					End With
				Next i
				'rLeft = ClientWidth
				For i = 0 To RightCount -1
					With *ListRight[i]
						If .FVisible Then
							rLeft -= .ExtraMargins.Left + .Width + .ExtraMargins.Right - IIf(i = 0, 0, FHorizontalSpacing)
								If GTK_IS_BOX(.widget) Then
									.RequestAlign .Width, bTop - tTop - .ExtraMargins.Top - .ExtraMargins.Bottom, True, bWithoutControl
								End If
							If bWithoutControl <> ListRight[i] Then .SetBounds(rLeft + .ExtraMargins.Left, tTop + .ExtraMargins.Top, .Width, bTop - tTop - .ExtraMargins.Top - .ExtraMargins.Bottom)
						End If
					End With
				Next i
				For i = 0 To ClientCount - 1
					With *ListClient[i]
							If GTK_IS_BOX(.widget) Then
								.RequestAlign rLeft - lLeft - .ExtraMargins.Left - .ExtraMargins.Right, bTop - tTop - .ExtraMargins.Top - .ExtraMargins.Bottom, True, bWithoutControl
							End If
						'If .FVisible Then
						If bWithoutControl <> ListClient[i] Then .SetBounds(lLeft + .ExtraMargins.Left, tTop + .ExtraMargins.Top, rLeft - lLeft - .ExtraMargins.Left - .ExtraMargins.Right, bTop - tTop - .ExtraMargins.Top - .ExtraMargins.Bottom)
						'End If
					End With
				Next i
			End If
			If FAutoSize AndAlso ControlCount <> 0 Then
				Dim As Integer MaxWidth, MaxHeight
				
				GetMax MaxWidth, MaxHeight
				
					If GTK_IS_BOX(widget) Then
						If Height > MaxHeight + Height - iClientHeight Then
							If MaxHeight + Height - iClientHeight <> 0 Then
								Height = MaxHeight + Height - iClientHeight
									If Parent Then Parent->RequestAlign
							End If
						End If
					ElseIf GTK_IS_WINDOW(widget) Then
						If Height <> MaxHeight + Height - iClientHeight OrElse Width <> MaxWidth + Width - iClientWidth  Then
							If MaxHeight + Height - iClientHeight <> 0 AndAlso MaxWidth + Width - iClientWidth <> 0 Then
								Move FLeft, FTop, MaxWidth + Width - iClientWidth, MaxHeight + Height - iClientHeight
									If Parent Then Parent->RequestAlign
							End If
						End If
					Else
						If Height <> MaxHeight + Height - iClientHeight Then
							If MaxHeight + Height - iClientHeight <> 0 Then
								Height = MaxHeight + Height - iClientHeight
									If Parent Then Parent->RequestAlign
							End If
						End If
					End If
			End If
				If FClient Then
					gtk_layout_move(GTK_LAYOUT(layoutwidget), FClient, lLeft, tTop)
					gtk_widget_set_size_request(FClient, Max(0, rLeft - lLeft), Max(0, bTop - tTop))
				End If
			'#EndIf
			If ListLeft   Then _Deallocate( ListLeft)
			If ListRight  Then _Deallocate( ListRight)
			If ListTop    Then _Deallocate( ListTop)
			If ListBottom Then _Deallocate( ListBottom)
			If ListClient Then _Deallocate( ListClient)
			'This.UpdateUnLock
		End Sub
		
		Private Sub Control.ClientToScreen(ByRef P As My.Sys.Drawing.Point)
		End Sub
		
		Private Sub Control.ScreenToClient(ByRef P As My.Sys.Drawing.Point)
		End Sub
		
		Private Sub Control.Invalidate(ByVal iRect As Any Ptr = 0, ByVal bErase As Boolean = True)
		End Sub
		
		Private Sub Control.Repaint
				If GTK_IS_WIDGET(widget) Then gtk_widget_queue_draw(widget)
		End Sub
		
		Private Sub Control.Update
				If GTK_IS_WIDGET(widget) Then gtk_widget_queue_draw(widget)
		End Sub
		
		Private Sub Control.UpdateLock
		End Sub
		
		Private Sub Control.UpdateUnLock
		End Sub
		
		Private Sub Control.SetFocus
				If widget Then gtk_widget_grab_focus(widget)
		End Sub
		
		Private Sub Control.BringToFront
				If This.Parent AndAlso This.Parent->layoutwidget Then
					Dim As Integer iLeft = This.Left, iTop = This.Top
					Dim As GtkWidget Ptr CtrlWidget = widget
					Select Case gtk_widget_get_parent(CtrlWidget)
					Case containerwidget, scrolledwidget, overlaywidget, layoutwidget, eventboxwidget
						CtrlWidget = gtk_widget_get_parent(CtrlWidget)
					End Select
					g_object_ref(CtrlWidget)
					gtk_container_remove(GTK_CONTAINER(This.Parent->layoutwidget), CtrlWidget)
					gtk_layout_put(GTK_LAYOUT(This.Parent->layoutwidget), CtrlWidget, iLeft, iTop)
				End If
		End Sub
		
		Private Sub Control.SendToBack
				If This.Parent AndAlso This.Parent->layoutwidget Then
					Dim As Integer iLeft, iTop
					Dim As GtkWidget Ptr CtrlWidget
					For i As Integer = 0 To This.Parent->ControlCount - 1
						If widget <> This.Parent->Controls[i]->widget Then
							CtrlWidget = This.Parent->Controls[i]->widget
							Select Case gtk_widget_get_parent(CtrlWidget)
							Case This.Parent->Controls[i]->containerwidget, This.Parent->Controls[i]->scrolledwidget, This.Parent->Controls[i]->overlaywidget, This.Parent->Controls[i]->layoutwidget AndAlso gtk_widget_get_parent(This.Parent->Controls[i]->layoutwidget) <> This.Parent->Controls[i]->widget, This.Parent->Controls[i]->eventboxwidget
								CtrlWidget = gtk_widget_get_parent(CtrlWidget)
							End Select
							iLeft = This.Parent->Controls[i]->Left
							iTop = This.Parent->Controls[i]->Top
							g_object_ref(CtrlWidget)
							gtk_container_remove(GTK_CONTAINER(This.Parent->layoutwidget), CtrlWidget)
							gtk_layout_put(GTK_LAYOUT(This.Parent->layoutwidget), CtrlWidget, iLeft, iTop)
						End If
					Next
				End If
		End Sub
		
		
		Private Sub Control.Add(Ctrl As Control Ptr, Index As Integer = -1)
			'On Error Goto ErrorHandler
			If Ctrl Then
				Dim As Control Ptr FSaveParent = Ctrl->Parent
				Ctrl->FParent = @This
				FControlCount += 1
				Controls = _Reallocate(Controls, SizeOf(Control Ptr)*FControlCount)
				If Index = -1 Then
					Controls[FControlCount - 1] = Ctrl
				Else
					For i As Integer = Index To FControlCount - 2
						Controls[i + 1] = Controls[i]
					Next
					Controls[Index] = Ctrl
				End If
					Dim As Integer FrameTop
					Dim As Boolean bAdded
					'If Not FDesignMode Then
					If widget AndAlso GTK_IS_FRAME(widget) Then FrameTop = 20
					'End If
					Dim As GtkWidget Ptr Ctrlwidget = IIf(Ctrl->containerwidget, Ctrl->containerwidget, IIf(Ctrl->scrolledwidget, Ctrl->scrolledwidget, IIf(Ctrl->overlaywidget, Ctrl->overlaywidget, IIf(Ctrl->layoutwidget AndAlso gtk_widget_get_parent(Ctrl->layoutwidget) <> Ctrl->widget, Ctrl->layoutwidget, IIf(Ctrl->eventboxwidget, Ctrl->eventboxwidget, Ctrl->widget)))))
					If GTK_IS_WIDGET(Ctrlwidget) AndAlso Not GTK_IS_WINDOW(Ctrlwidget) Then
						If layoutwidget Then
							If gtk_widget_get_parent(Ctrlwidget) <> 0 Then gtk_widget_unparent(Ctrlwidget)
							gtk_layout_put(GTK_LAYOUT(layoutwidget), Ctrlwidget, ScaleX(Ctrl->FLeft), ScaleY(Ctrl->FTop - FrameTop))
							bAdded = True
						ElseIf fixedwidget Then
							If gtk_widget_get_parent(Ctrlwidget) <> 0 Then gtk_widget_unparent(Ctrlwidget)
							gtk_fixed_put(GTK_FIXED(fixedwidget), Ctrlwidget, ScaleX(Ctrl->FLeft), ScaleY(Ctrl->FTop - FrameTop))
							bAdded = True
							ElseIf GTK_IS_STACK(widget) Then
								If gtk_widget_get_parent(Ctrlwidget) <> 0 Then gtk_widget_unparent(Ctrlwidget)
									gtk_widget_set_margin_left(Ctrlwidget, ScaleX(Margins.Left + Ctrl->ExtraMargins.Left))
									gtk_widget_set_margin_top(Ctrlwidget, ScaleY(Margins.Top + Ctrl->ExtraMargins.Top))
									gtk_widget_set_margin_right(Ctrlwidget, ScaleX(Margins.Right + Ctrl->ExtraMargins.Right))
									gtk_widget_set_margin_bottom(Ctrlwidget, ScaleY(Margins.Bottom + Ctrl->ExtraMargins.Bottom))
								gtk_container_add(GTK_CONTAINER(widget), Ctrlwidget)
						ElseIf GTK_IS_TEXT_VIEW(widget) Then
							If gtk_widget_get_parent(Ctrlwidget) <> 0 Then gtk_widget_unparent(Ctrlwidget)
							gtk_text_view_add_child_in_window(GTK_TEXT_VIEW(widget), Ctrlwidget, GTK_TEXT_WINDOW_WIDGET, ScaleX(Ctrl->FLeft), ScaleY(Ctrl->FTop - FrameTop))
							bAdded = True
						ElseIf GTK_IS_BOX(widget) Then
							If gtk_widget_get_parent(Ctrlwidget) <> 0 Then gtk_widget_unparent(Ctrlwidget)
								gtk_widget_set_margin_left(Ctrlwidget, ScaleX(Margins.Left + Ctrl->ExtraMargins.Left))
								gtk_widget_set_margin_top(Ctrlwidget, ScaleY(Margins.Top + Ctrl->ExtraMargins.Top))
								gtk_widget_set_margin_right(Ctrlwidget, ScaleX(Margins.Right + Ctrl->ExtraMargins.Right))
								gtk_widget_set_margin_bottom(Ctrlwidget, ScaleY(Margins.Bottom + Ctrl->ExtraMargins.Bottom))
							If Ctrl->Align = DockStyle.alRight OrElse Ctrl->Align = DockStyle.alBottom Then
									gtk_box_pack_end(GTK_BOX(widget), Ctrlwidget, False, False, 0)
							ElseIf Ctrl->Align = DockStyle.alClient Then
									gtk_box_pack_start(GTK_BOX(widget), Ctrlwidget, True, True, 0)
							Else
									gtk_box_pack_start(GTK_BOX(widget), Ctrlwidget, False, False, 0)
							End If
							bAdded = True
						End If
					End If
					If Ctrl->eventboxwidget Then g_object_set_data(G_OBJECT(Ctrl->eventboxwidget), "@@@Control2", Ctrl)
					If Ctrl->scrolledwidget Then g_object_set_data(G_OBJECT(Ctrl->scrolledwidget), "@@@Control2", Ctrl)
					If Ctrl->overlaywidget Then g_object_set_data(G_OBJECT(Ctrl->overlaywidget), "@@@Control2", Ctrl)
					If Ctrl->widget Then g_object_set_data(G_OBJECT(Ctrl->widget), "@@@Control2", Ctrl)
					If Ctrl->layoutwidget Then g_object_set_data(G_OBJECT(Ctrl->layoutwidget), "@@@Control2", Ctrl)
					If Ctrl->containerwidget Then g_object_set_data(G_OBJECT(Ctrl->containerwidget), "@@@Control2", Ctrl)
					If CInt(bAdded) AndAlso CInt(CInt(Ctrl->FVisible) OrElse CInt(GTK_IS_NOTEBOOK(gtk_widget_get_parent(Ctrl->widget)))) Then
						If Ctrl->eventboxwidget Then gtk_widget_show(Ctrl->eventboxwidget)
						If Ctrl->scrolledwidget Then gtk_widget_show(Ctrl->scrolledwidget)
						If Ctrl->overlaywidget Then gtk_widget_show(Ctrl->overlaywidget)
						If Ctrl->widget Then gtk_widget_show(Ctrl->widget)
						If Ctrl->layoutwidget Then gtk_widget_show(Ctrl->layoutwidget)
						If Ctrl->containerwidget Then gtk_widget_show(Ctrl->containerwidget)
					End If
					Ctrl->FAnchoredParentWidth = This.FWidth
					Ctrl->FAnchoredParentHeight = This.FHeight
					Ctrl->FAnchoredLeft = Ctrl->FLeft
					Ctrl->FAnchoredTop = Ctrl->FTop
					Ctrl->FAnchoredRight = Ctrl->FAnchoredParentWidth - Ctrl->FWidth - Ctrl->FLeft
					Ctrl->FAnchoredBottom = Ctrl->FAnchoredParentHeight - Ctrl->FHeight - Ctrl->FTop
				If Ctrl->FTabIndex = -1 Then Ctrl->ChangeTabIndex - 1
				RequestAlign
				If FSaveParent Then
					If FSaveParent <> @This Then
						FSaveParent->Remove Ctrl
						FSaveParent->RequestAlign
					End If
				End If
			End If
			'Exit Sub
			'ErrorHandler:
			'Print ErrDescription(Err) & " (" & Err & ") " & _
			'"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
			'"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
			'"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
		End Sub
		
		Private Sub Control.AddRange cdecl(CountArgs As Integer, ...)
			'Dim value As Any Ptr
			Dim args As Cva_List
			'value = va_first()
			Cva_Start(args, CountArgs)
			For i As Integer = 1 To CountArgs
				'Add(va_arg(value, Control Ptr))
				Add(Cva_Arg(args, Control Ptr))
				'value = va_next(value, Long)
			Next
			Cva_End(args)
		End Sub
		
		Private Sub Control.Remove(Ctrl As Control Ptr)
			Dim As Any Ptr P
			Dim As Integer i,x,Index
			If Ctrl->FTabIndex <> -2 Then Ctrl->ChangeTabIndex -1
			Index = IndexOf(Ctrl)
			If Index >= 0 And Index <= FControlCount -1 Then
				For i = Index + 1 To FControlCount -1
					P = Controls[i]
					Controls[i -1] = P
				Next i
				FControlCount -= 1
				If FControlCount = 0 Then
					_Deallocate(Controls)
					Controls = 0
				Else
					Controls = _Reallocate(Controls,FControlCount*SizeOf(Control Ptr))
				End If
				'DeAllocate P
			End If
		End Sub
		
		Private Function Control.IndexOf(Ctrl As Control Ptr) As Integer
			Dim As Integer i
			For i = 0 To ControlCount -1
				If Controls[i] = Ctrl Then Return i
			Next i
			Return -1
		End Function
		
		#ifndef Control_IndexOf_String_Off
			Private Function Control.IndexOf(CtrlName As String) As Integer
				Dim As Integer i
				For i = 0 To ControlCount -1
					If Controls[i]->Name = CtrlName Then Return i
				Next i
				Return -1
			End Function
		#endif
		
		Private Function Control.ControlByName(CtrlName As String) As Control Ptr
			Dim i As Integer = IndexOf(CtrlName)
			If i <> -1 Then
				Return Controls[i]
			Else
				Return 0
			End If
		End Function
		
		Private Operator Control.Cast As Any Ptr
			Return @This
		End Operator
		
		Private Operator Control.Let(ByRef Value As Control Ptr)
			If Value Then
				This = *Cast(Control Ptr,Value)
			End If
		End Operator
		
		Private Function Control.DoDragDrop(ByRef DataObject As DataObject, AllowedEffects As DragDropEffects) As DragDropEffects
			Return 0
		End Function
		
		Private Constructor Control
			WLet(FClassName, "Control")
			WLet(FClassAncestor, "")
			Text = ""
			FLeft = 0
			FTop = 0
			FWidth = 0
			FHeight = 0
			FBackColor = -1
			FDefaultBackColor = FBackColor
			FDefaultForeColor = FForeColor
			FTabIndex = -2
			FShowHint = True
			FShowCaption = True
			FVisible = True
			FEnabled = True
			Cursor.Ctrl = @This
		End Constructor
		
		Private Destructor Control
				If layoutwidget <> 0 AndAlso GTK_IS_WIDGET(layoutwidget) Then
						g_signal_handlers_disconnect_by_func(layoutwidget, G_CALLBACK(@Control_Draw), @This)
				End If
				If widget <> 0 AndAlso GTK_IS_WIDGET(widget) Then
					g_signal_handlers_disconnect_by_func(IIf(eventboxwidget, eventboxwidget, widget), G_CALLBACK(@EventProc), @This)
					g_signal_handlers_disconnect_by_func(IIf(eventboxwidget, eventboxwidget, widget), G_CALLBACK(@EventAfterProc), @This)
					g_signal_handlers_disconnect_by_func(G_OBJECT(widget), G_CALLBACK(@ConfigureEventProc), @This)
				End If
				If scrolledwidget <> 0 AndAlso GTK_IS_WIDGET(scrolledwidget) Then
					g_signal_handlers_disconnect_by_func(scrolledwidget, G_CALLBACK(@Control_Scroll), @This)
				End If
			'' A shared context menu outlives the controls that point at it. The ContextMenu
			'' setter writes FContextMenu->ParentWindow = @This, so when one menu is shared
			'' across N controls the LAST one to bind wins -- and nothing ever cleared it.
			'' Destroying that control left the menu holding a dangling Component Ptr, and the
			'' next MenuItem.Enabled assignment dereferenced it; a null check on ParentWindow
			'' cannot help, because reaching ->Handle derefs the dead object first.
			''
			'' Ilwaco points every tab's editor at the one shared mnuCode, so this is the same
			'' shape Astoria measured on its 78-tab close (13.68): 78 binds, 78 frees, and the
			'' faulting read is the last bound address.
			''
			'' Only cleared when it still points at THIS control: a menu already re-bound to a
			'' living control must keep that binding.
			If FContextMenu AndAlso _
				Cast(Any Ptr, FContextMenu->ParentWindow) = Cast(Any Ptr, @This) Then
				FContextMenu->ParentWindow = 0
			End If
			FreeWnd
			'If FText Then Deallocate FText
			If FProgID Then _Deallocate(FProgID)
			If FHint Then _Deallocate(FHint)
			'			Dim As Integer i
			'			For i = 0 To ControlCount -1
			'			    If Controls[i] Then Controls[i]->Free
			'			Next i
			If Controls Then _Deallocate( Controls)
			FControlCount = 0
			FPopupMenuItems.Clear
		End Destructor
	#endif
End Namespace


#ifdef __EXPORT_PROCS__
	Function Q_Control Alias "QControl" (Ctrl As Any Ptr) As My.Sys.Forms.Control Ptr __EXPORT__
		Return Cast(My.Sys.Forms.Control Ptr, Ctrl)
	End Function
	
	Sub RemoveControl Alias "RemoveControl"(Parent As My.Sys.Forms.Control Ptr, Ctrl As My.Sys.Forms.Control Ptr) Export
		Parent->Remove Ctrl
	End Sub
	
	Function ControlByIndex Alias "ControlByIndex"(Parent As My.Sys.Forms.Control Ptr, Index As Integer) As My.Sys.Forms.Control Ptr Export
		Return Parent->Controls[Index]
	End Function
	
	Function ControlByName Alias "ControlByName"(Parent As My.Sys.Forms.Control Ptr, CtrlName As String) As My.Sys.Forms.Control Ptr Export
		Return Parent->ControlByName(CtrlName)
	End Function
	
	Function IsControl Alias "IsControl"(Cpnt As My.Sys.ComponentModel.Component Ptr) As Boolean Export
		Return *Cpnt Is My.Sys.Forms.Control
	End Function
	
	Sub ControlSetFocus Alias "ControlSetFocus"(Ctrl As My.Sys.Forms.Control Ptr) Export
		Ctrl->SetFocus()
	End Sub
	
	Sub ControlFreeWnd Alias "ControlFreeWnd"(Ctrl As My.Sys.Forms.Control Ptr) Export
		Ctrl->FreeWnd()
	End Sub
	
	Sub ControlRepaint Alias "ControlRepaint" (Ctrl As My.Sys.Forms.Control Ptr) Export
		Ctrl->Repaint()
	End Sub
#endif