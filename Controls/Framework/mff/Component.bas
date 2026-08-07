'###############################################################################
'#  Component.bi                                                               #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                    #
'###############################################################################

#include once "Component.bi"

Namespace My.Sys.ComponentModel
	Private Function MarginsType.ToString ByRef As WString
		WLet(FTemp, This.Left & "; " & This.Top & "; " & This.Right & "; " & This.Bottom)
		If FTemp <> 0 Then Return *FTemp Else Return ""
	End Function
	
	#ifndef ReadProperty_Off
		Private Function Component.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "designmode": Return @FDesignMode
			Case "classancestor": Return FClassAncestor
			Case "tag": Return Tag
				Case "handle": Return widget
				Case "widget": Return widget
				Case "layoutwidget": Return layoutwidget
				Case "overlaywidget": Return overlaywidget
				Case "eventboxwidget": Return eventboxwidget
			Case "left": FLeft = This.Left: Return @FLeft
			Case "top": FTop = This.Top: Return @FTop
			Case "width": FWidth = This.Width: Return @FWidth
			Case "height": FHeight = This.Height: Return @FHeight
			Case "parent": Return FParent
			Case "margins": Return @Margins
			Case "margins.left": Return @Margins.Left
			Case "margins.right": Return @Margins.Right
			Case "margins.top": Return @Margins.Top
			Case "margins.bottom": Return @Margins.Bottom
			Case "extramargins": Return @ExtraMargins
			Case "extramargins.left": Return @ExtraMargins.Left
			Case "extramargins.right": Return @ExtraMargins.Right
			Case "extramargins.top": Return @ExtraMargins.Top
			Case "extramargins.bottom": Return @ExtraMargins.Bottom
			Case "name": Return FName
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Component.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value <> 0 Then
				Select Case LCase(PropertyName)
				Case "tag": This.Tag = Value
				Case "name": This.Name = QWString(Value)
				Case "designmode": This.DesignMode = QBoolean(Value)
					Case "handle": This.Handle = Value
					Case "widget": This.widget = Value
					Case "layoutwidget": This.layoutwidget = Value
					Case "overlaywidget": This.overlaywidget = Value
					Case "eventboxwidget": This.eventboxwidget = Value
				Case "left": This.Left = QInteger(Value)
				Case "top": This.Top = QInteger(Value)
				Case "width": This.Width = QInteger(Value)
				Case "height": This.Height = QInteger(Value)
				Case "parent": This.Parent = Value
				Case "margins.left": This.Margins.Left = QInteger(Value)
				Case "margins.right": This.Margins.Right = QInteger(Value)
				Case "margins.top": This.Margins.Top = QInteger(Value)
				Case "margins.bottom": This.Margins.Bottom = QInteger(Value)
				Case "extramargins.left": This.ExtraMargins.Left = QInteger(Value)
				Case "extramargins.right": This.ExtraMargins.Right = QInteger(Value)
				Case "extramargins.top": This.ExtraMargins.Top = QInteger(Value)
				Case "extramargins.bottom": This.ExtraMargins.Bottom = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	#ifndef Component_GetTopLevel_Off
		Private Function Component.GetTopLevel As Component Ptr
			If FParent = 0 Then
				Return @This
			Else
				Return FParent->GetTopLevel()
			End If
		End Function
	#endif
	
	#ifndef Parent_Off
		Private Property Component.Parent As Component Ptr
			Return FParent
		End Property
		
		Private Property Component.Parent(Value As Component Ptr)
			If FParent <> Value Then
				FParent = Value
				Value->FComponents.Add @This
					If FDesignMode AndAlso widget <> 0 AndAlso GTK_IS_WIDGET(widget) AndAlso Value <> 0 AndAlso Value->layoutwidget <> 0 Then
						If gtk_widget_get_parent(widget) <> Value->layoutwidget Then
							If gtk_widget_get_parent(widget) <> 0 Then gtk_widget_unparent(widget)
							gtk_layout_put(GTK_LAYOUT(Value->layoutwidget), widget, ScaleX(FLeft), ScaleY(FTop))
						Else
							gtk_layout_move(GTK_LAYOUT(Value->layoutwidget), widget, ScaleX(FLeft), ScaleY(FTop))
						End If
					End If
			End If
		End Property
	#endif
	
	Private Function Component.ClassAncestor ByRef As WString
		If FClassAncestor Then Return *FClassAncestor Else Return ""
	End Function
	
	Private Property Component.DesignMode As Boolean
		Return FDesignMode
	End Property
	
	Private Property Component.DesignMode(Value As Boolean)
		FDesignMode = Value
	End Property
	
	Private Property Component.Name ByRef As WString
		If FName> 0 Then Return *FName Else Return ""
	End Property
	
	Private Property Component.Name(ByRef Value As WString)
		WLet(FName, Value)
			If GTK_IS_WIDGET(widget) Then gtk_widget_set_name(widget, Value)
	End Property
	
	#ifndef Handle_Off
			Private Property Component.Handle As GtkWidget Ptr
				Return widget
			End Property
			
			Private Property Component.Handle(Value As GtkWidget Ptr)
				widget = Value
			End Property
			
			Private Property Component.LayoutHandle As GtkWidget Ptr
				Return layoutwidget
			End Property
			
			Private Property Component.LayoutHandle(Value As GtkWidget Ptr)
				layoutwidget = Value
			End Property
	#endif
	
	#ifndef Move_Off
		Private Sub Component.Move(cLeft As Integer, cTop As Integer, cWidth As Integer, cHeight As Integer)
			'#ifdef __USE_GTK__
			'	Dim As Integer iLeft = FLeft, iTop = FTop, iWidth = FWidth, iHeight = FHeight
			'#else
				Dim As Integer iLeft = cLeft, iTop = cTop, iWidth = cWidth, iHeight = cHeight
			'#endif
			If FParent Then
				Dim As Component Ptr cParent = FParent
				If cParent Then
						'If Not FDesignMode Then
							If cParent->widget AndAlso GTK_IS_FRAME(cParent->widget) Then
								iTop -= 20
							End If
						'End If
'					iLeft = iLeft + cParent->Margins.Left
'					iTop = iTop + cParent->Margins.Top
					'iWidth = iWidth - cParent->Margins.Left - cParent->Margins.Right
					'iHeight = iHeight - cParent->Margins.Top - cParent->Margins.Bottom
					'iWidth = Min(iWidth, Max(0, cParent->Width - iLeft - cParent->Margins.Right))
					'iHeight = Min(iHeight, Max(0, cParent->Height - iTop - cParent->Margins.Bottom))
				End If
			End If
'				Dim allocation As GtkAllocation
'				allocation.x = iLeft
'				allocation.y = iTop
'				allocation.width = iWidth
'				allocation.height = iHeight
				'gtk_widget_set_allocation(widget, @allocation)
				If iWidth <= 1 Or iHeight <= 1 Then
					Exit Sub
				End If
				If widget Then
					iLeft = ScaleX(iLeft)
					iTop = ScaleY(iTop)
					iWidth = ScaleX(iWidth)
					iHeight = ScaleY(iHeight)
					If GTK_IS_WIDGET(widget) AndAlso gtk_widget_is_toplevel(widget) Then
						gtk_window_move(GTK_WINDOW(widget), iLeft, iTop)
						gtk_window_resize(GTK_WINDOW(widget), Max(0, iWidth), Max(0, iHeight - 20))
						'gtk_window_resize(GTK_WINDOW(widget), Max(1, iWidth), Max(1, iHeight))
						'RequestAlign iWidth, iHeight
					Else
						'gdk_window_move(gtk_widget_get_window (widget), iLeft, iTop)
						'gdk_window_resize(gtk_widget_get_window (widget), Max(1, iWidth), Max(1, iHeight))
						'If Parent AndAlso Parent->fixedwidget Then gtk_fixed_move(gtk_fixed(Parent->fixedwidget), widget, iLeft, iTop)
						Dim As GtkWidget Ptr CtrlWidget = IIf(containerwidget, containerwidget, IIf(scrolledwidget, scrolledwidget, IIf(overlaywidget, overlaywidget, IIf(layoutwidget AndAlso gtk_widget_get_parent(layoutwidget) <> widget, layoutwidget, IIf(eventboxwidget, eventboxwidget, widget)))))
						If Parent Then
							If Parent->layoutwidget AndAlso GTK_IS_LAYOUT(gtk_widget_get_parent(CtrlWidget)) Then
								'gtk_widget_size_allocate(IIF(scrolledwidget, scrolledwidget, widget), @allocation)
								gtk_layout_move(GTK_LAYOUT(Parent->layoutwidget), CtrlWidget, iLeft, iTop)
							ElseIf Parent->fixedwidget Then
								gtk_fixed_move(GTK_FIXED(Parent->fixedwidget), CtrlWidget, iLeft, iTop)
							ElseIf GTK_IS_TEXT_VIEW(Parent->widget) Then
								gtk_text_view_move_child(GTK_TEXT_VIEW(Parent->widget), CtrlWidget, iLeft, iTop)
							End If
						End If
						'gtk_widget_set_size_allocation(widget, @allocation)
						'gtk_widget_set_size_request(widget, Max(0, iWidth), Max(0, iHeight))
						gtk_widget_set_size_request(CtrlWidget, Max(0, iWidth), Max(0, iHeight))
						'gtk_widget_set_size_request(widget, Max(0, iWidth), Max(0, iHeight))
						'gtk_widget_size_allocate(IIF(scrolledwidget, scrolledwidget, widget), @allocation)
						'gtk_widget_queue_draw(widget)
						'?ClassName, FWidth, gtk_widget_get_allocated_width(widget)
						'FHeight = gtk_widget_get_allocated_height(widget)
						'RequestAlign iWidth, iHeight
						'Requests @This
					End If
				EndIf
		End Sub
	#endif
	
	Private Sub Component.GetBounds(ByRef ALeft As Integer, ByRef ATop As Integer, ByRef AWidth As Integer, ByRef AHeight As Integer)
		ALeft = This.Left
		ATop = This.Top
		AWidth = This.Width
		AHeight = This.Height
	End Sub
	
	Private Sub Component.SetBounds(ALeft As Integer, ATop As Integer, AWidth As Integer, AHeight As Integer)
		FLeft   = ALeft
		FTop    = ATop
		FWidth  = AWidth
		FHeight = AHeight
		FWidth = Max(FMinWidth, FWidth)
		FHeight = Max(FMinHeight, FHeight)
		Move FLeft, FTop, FWidth, FHeight
	End Sub
	
	#ifndef Left_Off
		Private Property Component.Left As Integer
			If Not (FDesignMode AndAlso (Designer = @This)) Then
					If GTK_IS_WINDOW(widget) Then
						Dim As gint iLeft, iTop
						gtk_window_get_position(GTK_WINDOW(widget), @iLeft, @iTop)
						FLeft = UnScaleX(iLeft)
						FTop = UnScaleY(iTop)
					Else
						Dim As GtkWidget Ptr CtrlWidget = IIf(containerwidget, containerwidget, IIf(scrolledwidget, scrolledwidget, IIf(overlaywidget, overlaywidget, IIf(layoutwidget AndAlso gtk_widget_get_parent(layoutwidget) <> widget, layoutwidget, IIf(eventboxwidget, eventboxwidget, widget)))))
						If CtrlWidget AndAlso gtk_widget_get_mapped(CtrlWidget) Then
							Dim allocation As GtkAllocation
							gtk_widget_get_allocation(CtrlWidget, @allocation)
							FLeft = UnScaleX(allocation.x)
							'If FParent Then FLeft -= FParent->Margins.Left
						End If
					End If
			End If
			Return FLeft
		End Property
		
		#ifndef Component_Left_Set_Off
			Private Property Component.Left(Value As Integer)
				FLeft = Value
				Move FLeft, Top, This.Width, Height
			End Property
		#endif
	#endif
	
	#ifndef Top_Off
		Private Property Component.Top As Integer
			If Not (FDesignMode AndAlso (Designer = @This)) Then
					Dim ControlChanged As Boolean
					If GTK_IS_WINDOW(widget) Then
						Dim As gint iLeft, iTop
						gtk_window_get_position(GTK_WINDOW(widget), @iLeft, @iTop)
						FLeft =  UnScaleX(iLeft)
						FTop =  UnScaleY(iTop)
					Else
						Dim As GtkWidget Ptr CtrlWidget = IIf(containerwidget, containerwidget, IIf(scrolledwidget, scrolledwidget, IIf(overlaywidget, overlaywidget, IIf(layoutwidget AndAlso gtk_widget_get_parent(layoutwidget) <> widget, layoutwidget, IIf(eventboxwidget, eventboxwidget, widget)))))
						If CtrlWidget AndAlso gtk_widget_get_mapped(CtrlWidget) Then
							Dim allocation As GtkAllocation
							gtk_widget_get_allocation(CtrlWidget, @allocation)
							FTop = UnScaleY(allocation.y)
							'If FParent Then FTop -= FParent->Margins.Top
							ControlChanged = True
						End If
					End If
					If CInt(ControlChanged) AndAlso CInt(Parent) AndAlso CInt(Parent->ClassName = "GroupBox") Then
						FTop + = 20
					End If
			End If
			Return FTop
		End Property
		
		#ifndef Component_Top_Set_Off
			Private Property Component.Top(Value As Integer)
				FTop = Value
				Move This.Left, FTop, This.Width, Height
			End Property
		#endif
	#endif
	
	#ifndef Width_Off
		Private Property Component.Width As Integer
				If GTK_IS_WIDGET(widget) AndAlso gtk_widget_get_realized(widget) Then
					If GTK_IS_WINDOW(widget) Then
						Dim As gint iWidth, iHeight
						gtk_window_get_size(GTK_WINDOW(widget), @iWidth, @iHeight)
						FWidth = UnScaleX(iWidth)
					Else
						Dim As GtkWidget Ptr CtrlWidget = IIf(containerwidget, containerwidget, IIf(scrolledwidget, scrolledwidget, IIf(layoutwidget AndAlso gtk_widget_get_parent(layoutwidget) <> widget, layoutwidget, widget)))
						If layoutwidget AndAlso gtk_widget_is_toplevel(widget) Then
								FWidth = gtk_widget_get_allocated_width(widget)
							FWidth = UnScaleX(FWidth)
						ElseIf CtrlWidget Then
								If gtk_widget_get_allocated_width(CtrlWidget) > 1 Then FWidth = gtk_widget_get_allocated_width(CtrlWidget)
							FWidth = UnScaleX(FWidth)
							'Dim As GtkAllocation alloc
							'gtk_widget_get_allocation (widget, @alloc)
							'FWidth = alloc.width
							'If gtk_widget_get_allocated_width(widget) > 1 Then FWidth = gtk_widget_get_allocated_width(widget)
							'FWidth = Max(gtk_widget_get_allocated_width(widget), FWidth)
						End If
					End If
				End If
			Return FWidth
		End Property
		
		Private Property Component.Width(Value As Integer)
			FWidth = Max(FMinWidth, Value)
			Move This.Left, This.Top, FWidth, Height
		End Property
	#endif
	
	#ifndef Height_Off
		Private Property Component.Height As Integer
				If GTK_IS_WIDGET(widget) AndAlso gtk_widget_get_realized(widget) Then
					If GTK_IS_WINDOW(widget) Then
						Dim As gint iWidth, iHeight
						gtk_window_get_size(GTK_WINDOW(widget), @iWidth, @iHeight)
						FHeight = UnScaleY(iHeight + 20)
					Else
						Dim As GtkWidget Ptr CtrlWidget = IIf(containerwidget, containerwidget, IIf(scrolledwidget, scrolledwidget, IIf(layoutwidget AndAlso gtk_widget_get_parent(layoutwidget) <> widget, layoutwidget, widget)))
						If layoutwidget AndAlso gtk_widget_is_toplevel(widget) Then
								FHeight = gtk_widget_get_allocated_height(widget)
							FHeight = UnScaleY(FHeight)
						ElseIf CtrlWidget Then
								If gtk_widget_get_allocated_height(CtrlWidget) > 1 Then FHeight = gtk_widget_get_allocated_height(CtrlWidget)
							FHeight = UnScaleY(FHeight)
						End If
					End If
				End If
			Return FHeight
		End Property
		
		Private Property Component.Height(Value As Integer)
			FHeight = Max(FMinHeight, Value)
			Move This.Left, This.Top, This.Width, FHeight
		End Property
	#endif
	
	Private Function Component.ToString ByRef As WString
		Return This.Name
	End Function
	
	Private Sub Component.FreeWidget()
			If widget <> 0 AndAlso GTK_IS_WIDGET(widget) Then
				Dim As GtkWidget Ptr TempWidget = widget
				widget = 0
						gtk_widget_destroy(TempWidget)
				
				If TempWidget = overlaywidget Then overlaywidget = 0
				If TempWidget = scrolledwidget Then scrolledwidget = 0
				If TempWidget = eventboxwidget Then eventboxwidget = 0
				If TempWidget = fixedwidget Then fixedwidget = 0
				If TempWidget = layoutwidget Then layoutwidget = 0
				If TempWidget = box Then box = 0
				If TempWidget = containerwidget Then containerwidget = 0
				widget = 0
			End If
			If overlaywidget <> 0 AndAlso GTK_IS_WIDGET(overlaywidget) Then
					gtk_widget_destroy(overlaywidget)
				overlaywidget = 0
			End If
			If scrolledwidget <> 0 AndAlso GTK_IS_WIDGET(scrolledwidget) Then
					gtk_widget_destroy(scrolledwidget)
				scrolledwidget = 0
			End If
			If eventboxwidget <> 0 AndAlso GTK_IS_WIDGET(eventboxwidget) Then
					gtk_widget_destroy(eventboxwidget)
				eventboxwidget = 0
			End If
			If fixedwidget <> 0 AndAlso GTK_IS_WIDGET(fixedwidget) Then
					gtk_widget_destroy(fixedwidget)
				fixedwidget = 0
			End If
			If layoutwidget <> 0 AndAlso GTK_IS_WIDGET(layoutwidget) Then
					gtk_widget_destroy(layoutwidget)
				layoutwidget = 0
			End If
			If box <> 0 AndAlso GTK_IS_WIDGET(box) Then
					gtk_widget_destroy(box)
				box = 0
			End If
			If containerwidget <> 0 AndAlso GTK_IS_WIDGET(containerwidget) Then
					gtk_widget_destroy(containerwidget)
				containerwidget = 0
			End If
	End Sub
	
	Destructor Component
		If FName Then _Deallocate(FName)
		If FClassAncestor Then _Deallocate(FClassAncestor)
			FreeWidget()
	End Destructor
End Namespace

Function ThreadCreate_(ByVal ProcPtr_ As Sub ( ByVal userdata As Any Ptr ), ByVal param As Any Ptr = 0, ByVal stack_size As Integer = 0) As Any Ptr
		Return ThreadCreate(ProcPtr_, param, stack_size)
End Function

Private Sub ThreadsEnter
		gdk_threads_enter()
End Sub

Private Sub ThreadsLeave
			gdk_threads_leave()
End Sub

#ifdef __EXPORT_PROCS__
	Function Q_Component Alias "Q_Component"(Cpnt As Any Ptr) As My.Sys.ComponentModel.Component Ptr __EXPORT__
		Return Cast(My.Sys.ComponentModel.Component Ptr, Cpnt)
	End Function
	
	Sub ComponentGetBounds Alias "ComponentGetBounds" (Cpnt As My.Sys.ComponentModel.Component Ptr, ByRef ALeft As Integer, ByRef ATop As Integer, ByRef AWidth As Integer, ByRef AHeight As Integer) __EXPORT__
		Cpnt->GetBounds(ALeft, ATop, AWidth, AHeight)
	End Sub
	
	Sub ComponentSetBounds Alias "ComponentSetBounds"(Cpnt As My.Sys.ComponentModel.Component Ptr, ALeft As Integer, ATop As Integer, AWidth As Integer, AHeight As Integer) __EXPORT__
		Cpnt->SetBounds(ALeft, ATop, AWidth, AHeight)
	End Sub
	
	Function IsComponent Alias "IsComponent"(Obj As My.Sys.Object Ptr) As Boolean Export
		If Obj > 0  Then Return *Obj Is My.Sys.ComponentModel.Component Else Return  False
	End Function
#endif
