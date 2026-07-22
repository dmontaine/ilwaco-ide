'#########################################################
'#  Designer.bas                                        #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#           Nastase Eodor(nastasa.eodor@gmail.com)      #
'#########################################################

#include once "Designer.bi"
#include once "EditControl.bi"

#ifdef __USE_GTK__
	#define CtrlHandle GtkWindow Ptr
#else
	#define CtrlHandle HWND
#endif

Namespace My.Sys.Forms
	#ifdef __USE_GTK__
		Function Designer.GetControl(ControlHandle As GtkWidget Ptr) As Any Ptr
			Return Cast(Any Ptr, g_object_get_data(G_OBJECT(ControlHandle), "@@@Control2"))
			'Return SelectedControl
		End Function
	#else
		Function Designer.GetControl(ControlHandle As HWND) As Any Ptr
			Return Cast(Any Ptr, GetProp(ControlHandle, "MFFControl"))
		End Function
	#endif
	
	Function Designer.GetParentControl(iControl As Any Ptr, ByVal toRoot As Boolean = True) As Any Ptr
		If iControl = 0 Then Return iControl
		Dim As Any Ptr iParentControl, iParentControlSave
		Dim As SymbolsType Ptr st = Symbols(iControl)
		If st AndAlso st->ReadPropertyFunc  Then
			iParentControl = st->ReadPropertyFunc(iControl, "Parent")
			Dim As Integer ii
			If toRoot Then
				Do Until iParentControl = 0
					iParentControlSave = iControl
					iControl = iParentControl
					iParentControl = st->ReadPropertyFunc(iControl, "Parent")
					ii +=1
					If ii > 10 Then Exit Do
				Loop
				iParentControl = iParentControlSave
			End If
		End If
		Return iParentControl
	End Function
	
	Sub Designer.ProcessMessage(ByRef message As Message)
		
		'message.Result = -1
		
	End Sub
	
	'Sub Designer.HandleIsAllocated(BYREF Sender As Control)
	'    With QDesigner(@Sender)
	'        .CreateDots(GetParent(Sender.Handle))
	'        .Dialog = Sender.Handle
	'            'dim as RECT R
	'            'GetClientRect(Sender.Handle, @R)
	'            'if .FShowGrid then
	'              '.DrawGrid(GetDC(Sender.Handle), R)
	'            'else
	'              'FillRect(GetDC(Sender.Handle), @R, cast(HBRUSH, 16))
	'            'end if
	'    End With
	'End Sub
	
	Sub Designer.ChangeFirstMenuItem()
		If SelectedControl = DesignControl Then
			mnuDesigner.Item("LockControls")->Visible = True
			mnuDesigner.Item("Copy")->Visible = False
			mnuDesigner.Item("Cut")->Visible = False
			mnuDesigner.Item("Delete")->Visible = False
			mnuDesigner.Item("DuplicateSeparator")->Visible = False
			mnuDesigner.Item("Duplicate")->Visible = False
			mnuDesigner.Item("OrderSeparator")->Visible = False
			mnuDesigner.Item("BringToFront")->Visible = False
			mnuDesigner.Item("SendToBack")->Visible = False
			mnuDesigner.Item(0)->Caption = ML("Default event")
			mnuDesigner.Item(0)->Image = "Code"
		Else
			mnuDesigner.Item("LockControls")->Visible = False
			mnuDesigner.Item("Copy")->Visible = True
			mnuDesigner.Item("Cut")->Visible = True
			mnuDesigner.Item("Delete")->Visible = True
			mnuDesigner.Item("DuplicateSeparator")->Visible = True
			mnuDesigner.Item("Duplicate")->Visible = True
			mnuDesigner.Item("OrderSeparator")->Visible = True
			mnuDesigner.Item("BringToFront")->Visible = True
			mnuDesigner.Item("SendToBack")->Visible = True
			Dim As SymbolsType Ptr st = Symbols(SelectedControl)
			If st AndAlso st->ReadPropertyFunc Then
				Select Case QWString(st->ReadPropertyFunc(SelectedControl, "ClassName"))
				Case "MainMenu", "PopupMenu"
					mnuDesigner.Item(0)->Caption = ML("Menu Editor")
					mnuDesigner.Item(0)->Image = ""
				Case "ToolBar"
					mnuDesigner.Item(0)->Caption = ML("ToolBar Editor")
					mnuDesigner.Item(0)->Image = ""
				Case "StatusBar"
					mnuDesigner.Item(0)->Caption = ML("StatusBar Editor")
					mnuDesigner.Item(0)->Image = ""
				Case "ImageList"
					mnuDesigner.Item(0)->Caption = ML("ImageList Editor")
					mnuDesigner.Item(0)->Image = ""
				Case Else
					mnuDesigner.Item(0)->Caption = ML("Default event")
					mnuDesigner.Item(0)->Image = "Code"
				End Select
			End If
		End If
	End Sub
	
	Sub Designer.CheckTopMenuVisible(ChangeHeight As Boolean = True, bMoveDots As Boolean = True)
	End Sub
	
	
	
	Sub Designer.DrawBox(R As My.Sys.Drawing.Rect)
	End Sub
	
	Sub Designer.DrawBoxs(R() As My.Sys.Drawing.Rect)
		'''for future implementation of multiselect suport
		For i As Integer = 0 To UBound(R)
			DrawBox(R(i))
		Next
	End Sub
	
	Function Designer.GetClassAcceptControls(AClassName As String) As Boolean
		'''for future implementation of classbag struct
		Return False
	End Function
	
	Sub Designer.Clear
		HideDots
	End Sub
	
	Sub Designer.SelectNextControl(Direction As Integer = 0)
		If Components.Count > 0 Then
			SelectedControls.Clear
			If Direction < 0 Then
				Var iIndex = Components.IndexOf(SelectedControl)
				If iIndex < 1 Then
					MoveDots Components.Item(Components.Count - 1)
				Else
					MoveDots Components.Item(iIndex - 1)
				End If
			Else
				Var iIndex = Components.IndexOf(SelectedControl)
				If iIndex = Components.Count - 1 Then
					MoveDots Components.Item(0)
				Else
					MoveDots Components.Item(iIndex + 1)
				End If
			End If
		End If
	End Sub
	
	Function Designer.ClassExists() As Boolean
		'FClass = SelectedClass
		Return SelectedClass <> "" 'and (GetClassInfoEx(0, FClass, @wcls) or GetClassInfoEx(instance, FClass, @wcls))
	End Function
	
	'function Designer.GetClassName(hDlg as HWND) as string
	'dim as Wstring Ptr s
	'WReallocate s, 256
	'*s = space(255)
	'dim as integer L = .GetClassName(hDlg, s, Len(*s))
	'return trim(Left(*s, L))
	'end function
	'
	'#IfDef __USE_GTK__
	Function Designer.ControlAt(Parent As Any Ptr, X As Integer, Y As Integer, CtrlPressed As Any Ptr = 0) As Any Ptr
		'#Else
		'	function Designer.ControlAt(Parent as HWND,X as integer,Y as integer) as HWND
		'#EndIf
		#ifdef __USE_GTK__
			If Parent = 0 Then Return Parent
			If CtrlPressed Then Return CtrlPressed
			Dim As Integer ALeft, ATop, AWidth, AHeight
			Dim As Any Ptr Ctrl
			For i As Integer = Objects.Count - 1 To 0 Step -1
				Ctrl = Objects.Item(i)
				If Ctrl Then
					Dim As SymbolsType Ptr st = Symbols(Ctrl)
					If st AndAlso st->ComponentGetBoundsSub AndAlso st->Q_ComponentFunc Then
						st->ComponentGetBoundsSub(st->Q_ComponentFunc(Ctrl), ALeft, ATop, AWidth, AHeight)
						If (X > ALeft And X < ALeft + AWidth) And (Y > ATop And Y < ATop + AHeight) Then
							'ControlAt(Ctrl, X - ALeft, Y - ATop)
							Return Ctrl
						End If
					End If
				End If
			Next i
			Return Parent
		#else
			Dim As SymbolsType Ptr st = Symbols(Parent)
			If st AndAlso st->ReadPropertyFunc Then
				Dim ParentHwndPtr As HWND Ptr = Cast(HWND Ptr, st->ReadPropertyFunc(Parent, "Handle"))
				If ParentHwndPtr = 0 Then Return Parent
				Dim ParentHwnd As HWND = *Cast(HWND Ptr, st->ReadPropertyFunc(Parent, "Handle"))
				Dim Result As HWND = ChildWindowFromPointEx(ParentHwnd, Type<..Point>(ScaleX(X), ScaleY(Y)), CWP_SKIPINVISIBLE)
				If IsWindowVisible(Result) = 0 Then Return Parent
				If GetControl(Result) = Parent Then Return Parent
				If Result = 0 OrElse Result = ParentHwnd OrElse GetControl(Result) = 0 Then
					Return Parent
				Else
					Dim As ..Rect R
					GetWindowRect Result, @R
					MapWindowPoints 0, ParentHwnd, Cast(..Point Ptr, @R), 2
					Return ControlAt(GetControl(Result), X - UnScaleX(R.Left), Y - UnScaleY(R.Top))
				End If
			End If
			'		dim as RECT R
			'		GetChilds(Parent)
			'		for i as integer = 0 to FChilds.Count -1
			'			if IsWindowVisible(FChilds.Child[i]) then
			'			   GetWindowRect(FChilds.Child[i], @R)
			'			   MapWindowPoints(0, Parent, cast(POINT ptr, @R) ,2)
			'			   if (X > R.Left and X < R.Right) and (Y > R.Top and Y < R.Bottom) then
			'				  return FChilds.Child[i]
			'			   end If
			'			end if
			'		next i
		#endif
		'    return Parent
	End Function
	
	#ifdef __USE_GTK__
		Function Dot_Draw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As Any Ptr) As Boolean
			Dim As Designer Ptr Des = data1
			If Des->SelectedControl AndAlso Des->SelectedControl = g_object_get_data(G_OBJECT(widget), "@@@Control2") AndAlso CInt(Not Des->LockControls) Then
				cairo_set_source_rgb(cr, 0.0, 0.0, 1.0)
			Else
				cairo_set_source_rgb(cr, 1.0, 1.0, 1.0)
			End If
			.cairo_rectangle(cr, 0, 0, Des->DotSize, Des->DotSize)
			cairo_fill_preserve(cr)
			If Des->SelectedControl AndAlso Des->SelectedControl = g_object_get_data(G_OBJECT(widget), "@@@Control2") AndAlso CInt(Not Des->LockControls) Then
				cairo_set_source_rgb(cr, 1.0, 1.0, 1.0)
			Else
				cairo_set_source_rgb(cr, 0.0, 0.0, 1.0)
			End If
			cairo_stroke(cr)
			Return False
		End Function
		
		Function Dot_ExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As Any Ptr) As Boolean
			Dim As cairo_t Ptr cr = gdk_cairo_create(Event->window)
			Dot_Draw(widget, cr, data1)
			cairo_destroy(cr)
			Return False
		End Function
	#endif
	
	Sub Designer.CreateDots(ParentCtrl As Control Ptr)
		#ifdef __USE_GTK__
			Dim As GdkDisplay Ptr pdisplay
			Dim As GdkCursor Ptr gcurs
		#endif
		For i As Integer = 0 To 7
			#ifdef __USE_GTK__
				FDots(0, i) = gtk_layout_new(NULL, NULL)
				'g_object_ref(FDots(i))
				If GTK_IS_WIDGET(FDots(0, i)) Then gtk_layout_put(GTK_LAYOUT(ParentCtrl->layoutwidget), FDots(0, i), 0, 0)
				gtk_widget_set_size_request(FDots(0, i), FDotSize, FDotSize)
				#ifdef __USE_GTK3__
					g_signal_connect(FDots(0, i), "draw", G_CALLBACK(@Dot_Draw), @This)
				#else
					g_signal_connect(FDots(0, i), "expose-event", G_CALLBACK(@Dot_ExposeEvent), @This)
				#endif
				gtk_widget_realize(FDots(0, i))
				pdisplay = gtk_widget_get_display(FDots(0, i))
				Select Case i
				Case 0, 4 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeNWSE)
				Case 1, 5 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeNS)
				Case 2, 6 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeNESW)
				Case 3, 7 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeWE)
				End Select
				gdk_window_set_cursor(gtk_widget_get_window(FDots(0, i)), gcurs)
			#else
				If ParentCtrl > 0 AndAlso ParentCtrl->Handle > 0 Then FDots(0, i) = CreateWindowEx(0, "DOT", "", WS_CHILD Or WS_CLIPSIBLINGS Or WS_CLIPCHILDREN, 0, 0, ScaleX(FDotSize), ScaleY(FDotSize), ParentCtrl->Handle, 0, Instance, 0)
				If IsWindow(FDots(0, i)) Then
					SetWindowLongPtr(FDots(0, i), GWLP_USERDATA, CInt(@This))
				End If
			#endif
		Next i
	End Sub
	
	Sub Designer.DestroyDots
		For j As Integer = UBound(FDots) To 0 Step -1
			For i As Integer = 7 To 0 Step -1
				#ifdef __USE_GTK__
						If GTK_IS_WIDGET(FDots(j, i)) Then gtk_widget_destroy(FDots(j, i))
				#else
					DestroyWindow(FDots(j, i))
				#endif
			Next i
		Next j
	End Sub
	
	Sub Designer.HideDots
		For j As Integer = 0 To UBound(FDots)
			For i As Integer = 0 To 7
				#ifdef __USE_GTK__
					If GTK_IS_WIDGET(FDots(j, i)) Then gtk_widget_set_visible(FDots(j, i), False)
				#else
					ShowWindow(FDots(j, i), SW_HIDE)
				#endif
			Next i
		Next j
	End Sub
	
	#ifdef __USE_GTK__
		Sub ScreenToClient(widget As GtkWidget Ptr, P As Point Ptr)
			Dim As gint x, y
			gdk_window_get_origin(gtk_widget_get_window(widget), @x, @y)
			P->X = P->X - x
			P->Y = P->Y - y
		End Sub
	#endif
	
	#ifdef __USE_GTK__
		Sub GetPosToClient(widget As GtkWidget Ptr, Client As GtkWidget Ptr, x As Integer Ptr, y As Integer Ptr, x1 As Integer = -1, y1 As Integer = -1, ParentWidget As GtkWidget Ptr = 0)
			If widget = 0 Or widget = Client Then Return
			Dim allocation As GtkAllocation
			gtk_widget_get_allocation(widget, @allocation)
			*x = *x + allocation.x
			*y = *y + allocation.y
			If GTK_IS_FRAME(gtk_widget_get_parent(widget)) Then
				gtk_widget_get_allocation(gtk_widget_get_parent(widget), @allocation)
				*x = *x - allocation.x
				*y = *y - allocation.y
			End If
			If ParentWidget = gtk_widget_get_parent(widget) Then
				If x1 <> -1 Then *x = x1
				If y1 <> -1 Then *y = y1
			End If
			GetPosToClient gtk_widget_get_parent(widget), Client, x, y, x1, y1, ParentWidget
		End Sub
		
		Sub Designer.MoveDots(Control As Any Ptr, bSetFocus As Boolean = True, Left1 As Integer = -1, Top1 As Integer = -1, Width1 As Integer = -1, Height1 As Integer = -1)
	#else
		Sub Designer.MoveDots(Control As Any Ptr, bSetFocus As Boolean = True)
			Dim As ..Rect R
	#endif
		Dim As My.Sys.Drawing.Point P
		Dim As Integer iWidth, iHeight
		#ifdef __USE_GTK__
			Dim As GtkWidget Ptr ControlHandle, ControlHandle2
		#else
			Dim As HWND ControlHandle
		#endif
		ControlHandle = GetControlHandle(Control)
		Dim As Integer CountOfControls
		#ifdef __USE_GTK__
			If GTK_IS_WIDGET(ControlHandle) Then
		#else
			If IsWindow(ControlHandle) Then
		#endif
			SelectedControl = Control
			FSelControl = ControlHandle
			If SelectedControls.Count = 0 Then SelectedControls.Add SelectedControl
			#ifdef __USE_GTK__
				CountOfControls = 0
			#else
				CountOfControls = SelectedControls.Count
			#endif
			'if Control <> FDialog then
			Dim As Integer DotsCount = UBound(FDots)
			For j As Integer = DotsCount To CountOfControls Step -1
				For i As Integer = 7 To 0 Step -1
					#ifdef __USE_GTK__
						If FDots(j, i) > 0 AndAlso GTK_IS_WIDGET(FDots(j, i)) Then
							#ifdef __USE_GTK3__
								gtk_widget_destroy(FDots(j, i))
							#else
								gtk_container_remove(GTK_CONTAINER(FDialogParent), FDots(j, i))
							#endif
						End If
					#else
						If FDots(j, i) > 0 Then DestroyWindow(FDots(j, i))
					#endif
				Next
			Next
			ReDim Preserve FDots(SelectedControls.Count - 1, 7) As CtrlHandle
			#ifdef __USE_GTK__
				Dim As Integer x, y ', x1, y1
				'			gtk_widget_set_has_window(Control, True)
				'			gtk_widget_set_has_window(FDialogParent, True)
				'  	      	gtk_widget_realize(Control)
				'  	      	gtk_widget_realize(FDialogParent)
				'  	      	gdk_window_get_origin(gtk_widget_get_window(Control), @x, @y)
				'  	      	gdk_window_get_origin(gtk_widget_get_window(FDialogParent), @x1, @y1)
				For j As Integer = 0 To SelectedControls.Count - 1
					ControlHandle2 = GetControlHandle(SelectedControls.Items[j])
					gtk_widget_realize(ControlHandle2)
					#ifdef __USE_GTK3__
						iWidth = gtk_widget_get_allocated_width(ControlHandle2)
						iHeight = gtk_widget_get_allocated_height(ControlHandle2)
					#else
						iWidth = ControlHandle2->allocation.width
						iHeight = ControlHandle2->allocation.height
					#endif
					x = 0
					y = 0
					Dim As gint NewX, NewY
					If ControlHandle2 = ControlHandle Then
						If Width1 <> -1 Then iWidth = Width1
						If Height1 <> -1 Then iHeight = Height1
						'If ReadPropertyFunc(SelectedControls.Items[j], "Parent") Then
							'GetPosToClient ControlHandle2, FDialogParent, @x, @y, Left1, Top1, ReadPropertyFunc(ReadPropertyFunc(SelectedControls.Items[j], "Parent"), "layoutwidget")
							gtk_widget_translate_coordinates(ControlHandle2, FDialogParent, x, y, @NewX, @NewY)
						'Else
						'	'GetPosToClient ControlHandle2, FDialogParent, @x, @y, Left1, Top1, 0
						'	gtk_widget_translate_coordinates(ControlHandle2, FDialogParent, x, y, @NewX, @NewY)
						'End If
					Else
						gtk_widget_translate_coordinates(ControlHandle2, FDialogParent, x, y, @NewX, @NewY)
						'GetPosToClient ControlHandle2, FDialogParent, @x, @y
					End If
					P.X     = NewX
					P.Y     = NewY
					Dim As GdkDisplay Ptr pdisplay
					Dim As GdkCursor Ptr gcurs
					'For i As Integer = 0 To 7
					'	If GTK_IS_WIDGET(FDots(j, i)) Then
					'		#ifdef __USE_GTK3__
					'			gtk_widget_destroy(FDots(j, i))
					'			'gtk_container_remove(gtk_container(layout), FDots(j, i))
					'		#else
					'			gtk_container_remove(GTK_CONTAINER(FDialogParent), FDots(j, i))
					'		#endif
					'	End If
					'Next i
					For i As Integer = 0 To 7
						FDots(j, i) = gtk_layout_new(NULL, NULL)
						gtk_widget_set_size_request(FDots(j, i), FDotSize, FDotSize)
						gtk_widget_set_events(FDots(j, i), _
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
						g_signal_connect(FDots(j, i), "event", G_CALLBACK(@DotWndProc), @This)
						#ifdef __USE_GTK3__
							g_signal_connect(FDots(j, i), "draw", G_CALLBACK(@Dot_Draw), @This)
						#else
							g_signal_connect(FDots(j, i), "expose-event", G_CALLBACK(@Dot_ExposeEvent), @This)
						#endif
						Dim As Integer iLeft, iTop
						Select Case i
						Case 0: iLeft = P.X - FDotSize: iTop = P.Y - FDotSize
						Case 1: iLeft = P.X + iWidth / 2 - 3: iTop = P.Y - FDotSize
						Case 2: iLeft = P.X + iWidth: iTop = P.Y - FDotSize
						Case 3: iLeft = P.X + iWidth: iTop = P.Y + iHeight / 2 - 3
						Case 4: iLeft = P.X + iWidth: iTop = P.Y + iHeight
						Case 5: iLeft = P.X + iWidth / 2 - 3: iTop = P.Y + iHeight
						Case 6: iLeft = P.X - FDotSize: iTop = P.Y + iHeight
						Case 7: iLeft = P.X - FDotSize: iTop = P.Y + iHeight / 2 - 3
						End Select
						#ifdef __USE_GTK3__
							If GTK_IS_WIDGET(FDots(j, i)) Then 'gtk_layout_put(gtk_layout(layout), FDots(j, i), iLeft, iTop) Then
								g_object_set_data(G_OBJECT(FDots(j, i)), "@@@Left", Cast(gpointer, iLeft))
								g_object_set_data(G_OBJECT(FDots(j, i)), "@@@Top", Cast(gpointer, iTop))
								gtk_overlay_add_overlay(GTK_OVERLAY(overlay), FDots(j, i))
								'								If iLeft < 0 OrElse iTop < 0 OrElse iLeft > Parent->Width OrElse iTop > Parent->Height Then
								'								Else
								'									gtk_widget_set_margin_start(FDots(j, i), iLeft)
								'									gtk_widget_set_margin_top(FDots(j, i), iTop)
								'									gtk_widget_set_margin_end(FDots(j, i), Parent->Width - iLeft - FDotSize)
								'									gtk_widget_set_margin_bottom(FDots(j, i), Parent->Height - iTop - FDotSize)
								'								End If
							End If
						#else
							If GTK_IS_WIDGET(FDots(j, i)) Then gtk_layout_put(GTK_LAYOUT(FDialogParent), FDots(j, i), iLeft, iTop)
						#endif
						gtk_widget_realize(FDots(j, i))
						pdisplay = gtk_widget_get_display(FDots(j, i))
						Select Case i
						Case 0, 4 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeNWSE)
						Case 1, 5 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeNS)
						Case 2, 6 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeNESW)
						Case 3, 7 : gcurs = gdk_cursor_new_from_name(pdisplay, crSizeWE)
						End Select
						gdk_window_set_cursor(gtk_widget_get_window(FDots(j, i)), gcurs)
						g_object_set_data(G_OBJECT(FDots(j, i)), "@@@Control", ControlHandle2)
						g_object_set_data(G_OBJECT(FDots(j, i)), "@@@Control2", SelectedControls.Items[j])
						'SetParent(FDots(i), GetParent(Control))
						'SetProp(FDots(i),"@@@Control", Control)
						'BringWindowToTop FDots(i)
						'gdk_window_raise(gtk_widget_get_window(FDots(i)))
						#ifdef __USE_GTK3__
							If iLeft < 0 OrElse iTop < 0 OrElse iLeft > Parent->Width OrElse iTop > Parent->Height Then
								gtk_widget_hide(FDots(j, i))
							Else
								gtk_widget_show(FDots(j, i))
							End If
						#else
							gtk_widget_show(FDots(j, i))
						#endif
					Next i
				Next j
			#else
				For j As Integer = SelectedControls.Count - 1 To DotsCount + 1 Step - 1 'For Compile with FBC 1.10
					For i As Integer = 0 To 7
						FDots(j, i) = CreateWindowEx(0, "DOT", "", WS_CHILD Or WS_CLIPSIBLINGS Or WS_CLIPCHILDREN, 0, 0, ScaleX(FDotSize), ScaleY(FDotSize), GetParent(FDialog), 0, Instance, 0)
						SetWindowLongPtr(FDots(j, i), GWLP_USERDATA, CInt(@This))
					Next
				Next
				For j As Integer = 0 To SelectedControls.Count - 1
					GetWindowRect(GetControlHandle(SelectedControls.Items[j]), @R)
					iWidth  = R.Right  - R.Left
					iHeight = R.Bottom - R.Top
					P.X     = R.Left
					P.Y     = R.Top
					ScreenToClient(GetParent(FDialog), Cast(..Point Ptr, @P))
					MoveWindow FDots(j, 0), P.X - ScaleX(FDotSize), P.Y - ScaleY(FDotSize), ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 1), P.X + iWidth / 2 - 3, P.Y - ScaleY(FDotSize), ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 2), P.X + iWidth, P.Y - ScaleY(FDotSize), ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 3), P.X + iWidth, P.Y + iHeight / 2 - 3, ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 4), P.X + iWidth, P.Y + iHeight, ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 5), P.X + iWidth / 2 - 3, P.Y + iHeight, ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 6), P.X - ScaleX(FDotSize), P.Y + iHeight, ScaleX(FDotSize), ScaleY(FDotSize), True
					MoveWindow FDots(j, 7), P.X - ScaleX(FDotSize), P.Y + iHeight / 2 - 3, ScaleX(FDotSize), ScaleY(FDotSize), True
					For i As Integer = 0 To 7
						'SetParent(FDots(i), GetParent(Control))
						SetProp(FDots(j, i),"@@@Control", GetControlHandle(SelectedControls.Items[j]))
						SetProp(FDots(j, i),"@@@Control2", SelectedControls.Items[j])
						BringWindowToTop FDots(j, i)
						ShowWindow(FDots(j, i), SW_SHOW)
					Next i
				Next j
				FHDC = GetDC(GetParent(ControlHandle))
				'SetROP2(hdc, R2_NOTXORPEN)
				RedrawWindow(FDialog, NULL, NULL, RDW_INVALIDATE)
				'DrawFocusRect(Fhdc, @type<RECT>(R.Left, R.Top, R.Right, R.Bottom + 10))
				ReleaseDC(ControlHandle, FHDC)
			#endif
			If bSetFocus Then
				#ifdef __USE_GTK__
					gtk_widget_grab_focus(layoutwidget)
				#else
					'SetFocus(Dialog)
				#endif
				'else
				'   HideDots
				'end If
				If OnChangeSelection Then OnChangeSelection(This, SelectedControl, UnScaleX(P.X), UnScaleY(P.Y), UnScaleX(iWidth), UnScaleY(iHeight))
			End If
		Else
			HideDots
		End If
	End Sub
	
	Sub Designer.MoveControl(Control As Any Ptr, iLeft As Integer, iTop As Integer, iWidth As Integer, iHeight As Integer)
		Dim As SymbolsType Ptr st = Symbols(Control)
		If st AndAlso st->ComponentSetBoundsSub AndAlso st->Q_ComponentFunc Then
			st->ComponentSetBoundsSub(st->Q_ComponentFunc(Control), iLeft, iTop, iWidth, iHeight)
		End If
	End Sub
	
	Sub Designer.GetControlBounds(Control As Any Ptr, ByRef iLeft As Integer, ByRef iTop As Integer, ByRef iWidth As Integer, ByRef iHeight As Integer)
		Dim As SymbolsType Ptr st = Symbols(Control)
		If st AndAlso st->ComponentGetBoundsSub AndAlso st->Q_ComponentFunc Then
			st->ComponentGetBoundsSub(st->Q_ComponentFunc(Control), iLeft, iTop, iWidth, iHeight)
		End If
	End Sub
	
	Sub Designer.SetControlBounds(Control As Any Ptr, ByRef iLeft As Integer, ByRef iTop As Integer, ByRef iWidth As Integer, ByRef iHeight As Integer)
		Dim As SymbolsType Ptr st = Symbols(Control)
		If st AndAlso st->ComponentSetBoundsSub AndAlso st->Q_ComponentFunc Then
			st->ComponentSetBoundsSub(st->Q_ComponentFunc(Control), iLeft, iTop, iWidth, iHeight)
		End If
	End Sub
	
	#ifdef __USE_GTK__
		Function Designer.IsDot(hDlg As GtkWidget Ptr) As Integer
			Dim As String s
			'if UCase(s) = "DOT" then
			For j As Integer = 0 To SelectedControls.Count - 1
				For i As Integer = 0 To 7
					If FDots(j, i) = hDlg Then Return i
				Next i
			Next j
			Return -1
		End Function
	#else
		Function Designer.IsDot(hDlg As HWND) As Integer
			Dim As String s
			If GetWindowLongPtr(hDlg, GWLP_USERDATA) = CInt(@This) Then
				'if UCase(s) = "DOT" then
				For j As Integer = 0 To SelectedControls.Count - 1
					For i As Integer = 0 To 7
						If FDots(j, i) = hDlg Then Return i
					Next i
				Next j
			End If
			Return -1
		End Function
	#endif
	
	Sub Designer.DblClick(X As Integer, Y As Integer, Shift As Integer, Ctrl As Any Ptr = 0)
		'#IfDef __USE_GTK__
		SelectedControl = ControlAt(DesignControl, X, Y, Ctrl)
		If OnDblClickControl Then OnDblClickControl(This, SelectedControl)
		'#Else
		'    FSelControl = ControlAt(FDialog, X, Y)
		'	If OnDblClickControl Then OnDblClickControl(This, GetControl(FSelControl))
		'#EndIf
	End Sub
	
	#ifdef __USE_GTK__
		Function Designer.GetControlHandle(Control As Any Ptr) As GtkWidget Ptr
			Dim As SymbolsType Ptr st = Symbols(Control)
			If st = 0 OrElse st->ReadPropertyFunc = 0 Then Return 0
			Return st->ReadPropertyFunc(Control, "Widget")
	#else
		Function Designer.GetControlHandle(Control As Any Ptr) As HWND
			If Control = 0 Then Return 0
			Dim As SymbolsType Ptr st = Symbols(Control)
			If st = 0 OrElse st->ReadPropertyFunc = 0 Then Return 0
			Var tHandle = st->ReadPropertyFunc(Control, "Handle")
			If tHandle = 0 Then Return 0
			Return *Cast(HWND Ptr, tHandle)
	#endif
	End Function
	
	Sub Designer.MouseDown(X As Integer, Y As Integer, Shift As Integer, Ctrl As Any Ptr = 0)
		#ifdef __USE_GTK__
			Dim As Boolean bCtrl = Shift And GDK_CONTROL_MASK
			Dim As Boolean bShift = Shift And GDK_SHIFT_MASK
		#else
			Dim As Boolean bCtrl = GetKeyState(VK_CONTROL) And 8000
			Dim As Boolean bShift = GetKeyState(VK_SHIFT) And 8000
		#endif
		pfrmMain->ActiveControl = GetControl(FDialogParent)
		FDown   = True
		FStepX = GridSize
		FStepY = GridSize
		FBeginX = IIf(SnapToGridOption, (X\FStepX)*FStepX,X)
		FBeginY = IIf(SnapToGridOption, (Y\FStepY)*FStepY,Y)
		FEndX   = FBeginX
		FEndY   = FBeginY
		FNewX   = FBeginX
		FNewY   = FBeginY
		HideDots
		Dim As Any Ptr SelCtrl = ControlAt(DesignControl, X, Y, Ctrl)
		FDotIndex   = IsDot(FOverControl)
		If FDotIndex = -1 Then
			If bCtrl Or bShift Then
				If SelectedControls.Contains(SelCtrl) Then
					If SelectedControls.Count > 1 Then SelectedControls.Remove SelectedControls.IndexOf(SelCtrl)
					SelectedControl = SelectedControls.Items[0]
				ElseIf SelectedControls.Count = 0 OrElse (Symbols(SelectedControls.Items[0]) AndAlso Symbols(SelectedControls.Items[0])->ReadPropertyFunc AndAlso Symbols(SelCtrl) AndAlso Symbols(SelCtrl)->ReadPropertyFunc AndAlso Symbols(SelectedControls.Items[0])->ReadPropertyFunc(SelectedControls.Items[0], "Parent") = Symbols(SelCtrl)->ReadPropertyFunc(SelCtrl, "Parent")) Then
					SelectedControls.Add SelCtrl
					SelectedControl = SelCtrl
				End If
			ElseIf Not SelectedControls.Contains(SelCtrl) Then
				SelectedControls.Clear
				SelectedControls.Add SelCtrl
				SelectedControl = SelCtrl
			Else
				SelectedControl = SelCtrl
			End If
		End If
		FSelControl = GetControlHandle(SelectedControl)
		If FDotIndex <> -1 Then
			FCanInsert  = False
			FCanMove    = False
			FCanSize    = Not FLockControls
			#ifdef __USE_GTK__
					If G_IS_OBJECT(FDots(0, FDotIndex)) Then
						FSelControl = g_object_get_data(G_OBJECT(FDots(0, FDotIndex)), "@@@Control")
						SelectedControl = g_object_get_data(G_OBJECT(FDots(0, FDotIndex)), "@@@Control2")
					End If
			#else
				'If Not IsWindow(FSelControl) Then
				FSelControl = GetProp(FDots(0, FDotIndex),"@@@Control")
				SelectedControl = GetControl(FSelControl)
				'End If
			#endif
			'BringWindowToTop(FSelControl)
			Dim As Integer iCount = SelectedControls.Count - 1
			ReDim As Integer FLeft(iCount), FTop(iCount), FWidth(iCount), FHeight(iCount)
			ReDim As Integer FLeftNew(iCount), FTopNew(iCount), FWidthNew(iCount), FHeightNew(iCount)
			For j As Integer = 0 To iCount
				#ifdef __USE_GTK__
					GetControlBounds(SelectedControls.Items[j], FLeft(j), FTop(j), FWidth(j), FHeight(j))
				#else
					GetWindowRect(GetControlHandle(SelectedControls.Items[j]), @R)
					P.X         = R.Left
					P.Y         = R.Top
					FWidth(j)   = UnScaleX(R.Right - R.Left)
					FHeight(j)  = UnScaleY(R.Bottom - R.Top)
					ScreenToClient(GetParent(FSelControl), @P)
					FLeft(j)    = UnScaleX(P.X)
					FTop(j)     = UnScaleY(P.Y)
				#endif
			Next
		Else
			If FSelControl <> FDialog Then
				'BringWindowToTop(FSelControl)
				If ClassExists Then
					FCanInsert = True
					FCanMove   = False
					FCanSize   = False
					#ifdef __USE_GTK__
						gdk_window_set_cursor(gtk_widget_get_window(layoutwidget), gdk_cursor_new_from_name(gtk_widget_get_display(layoutwidget), crCross))
					#else
						SetCursor(crCross)
					#endif
				Else
					FCanInsert = False
					FCanMove   = Not FLockControls
					FCanSize   = False
					' Ctrl+drag (mouse drag-and-drop copy/paste): duplicate the currently
					' selected control(s) and drag the new copy instead of moving the originals,
					' mirroring the classic VB/Delphi-style designer behavior.
					If bCtrl AndAlso FCanMove AndAlso SelectedControl <> DesignControl Then
						CopyControl
						PasteControl
						FSelControl = GetControlHandle(SelectedControl)
					End If
					#ifdef __USE_GTK__
						gdk_window_set_cursor(gtk_widget_get_window(layoutwidget), gdk_cursor_new_from_name(gtk_widget_get_display(layoutwidget), crSize))
					#else
						SetCursor(crSize) :SetCapture(FDialog)
					#endif
					If OnChangeSelection Then OnChangeSelection(This, SelectedControl)
					Dim As Integer iCount = SelectedControls.Count - 1
					ReDim As Integer FLeft(iCount), FTop(iCount), FWidth(iCount), FHeight(iCount)
					ReDim As Integer FLeftNew(iCount), FTopNew(iCount), FWidthNew(iCount), FHeightNew(iCount)
					For j As Integer = 0 To iCount
						#ifdef __USE_GTK__
							GetControlBounds(SelectedControls.Items[j], FLeft(j), FTop(j), FWidth(j), FHeight(j))
						#else
							GetWindowRect(GetControlHandle(SelectedControls.Items[j]), @R)
							P.X         = R.Left
							P.Y         = R.Top
							FWidth(j)   = UnScaleX(R.Right - R.Left)
							FHeight(j)  = UnScaleY(R.Bottom - R.Top)
							ScreenToClient(GetParent(FSelControl), @P)
							FLeft(j)    = UnScaleX(P.X)
							FTop(j)     = UnScaleY(P.Y)
						#endif
					Next
				End If
			Else
				HideDots
				FCanInsert = IIf(ClassExists, True, False)
				FCanMove   = 0
				FCanSize   = False
				If FCanInsert Then
					#ifdef __USE_GTK__
						gdk_window_set_cursor(gtk_widget_get_window(layoutwidget), gdk_cursor_new_from_name(gtk_widget_get_display(layoutwidget), crCross))
					#else
						SetCursor(crCross)
					#endif
				Else
					If OnChangeSelection Then OnChangeSelection(This, SelectedControl)
				End If
				If Not FCanInsert AndAlso Not FCanMove AndAlso (CBool(FSelControl = FDialog) OrElse Not FLockControls) Then
				End If
			End If
		End If
	End Sub
	
	Sub Designer.MouseMove(X As Integer, Y As Integer, Shift As Integer)
		FStepX = GridSize
		FStepY = GridSize
		FNewX = IIf(SnapToGridOption, (X \ FStepX) * FStepX, X)
		FNewY = IIf(SnapToGridOption, (Y \ FStepY) * FStepY, Y)
		'dim hdc As HDC = GetDC(FHandle)
		If FDown Then
			If FCanInsert Then
				#ifdef __USE_GTK__
					If GTK_IS_WIDGET(layoutwidget) Then gtk_widget_queue_draw(layoutwidget)
				#else
					SetCursor(crCross)
				#endif
				DrawBox(Type<My.Sys.Drawing.Rect>(FBeginX, FBeginY, FNewX, FNewY))
				DrawBox(Type<My.Sys.Drawing.Rect>(FBeginX, FBeginY, FEndX, FEndY))
			End If
			If FCanSize Then
				For j As Integer = 0 To SelectedControls.Count - 1
					FLeftNew(j) = FLeft(j)
					FTopNew(j) = FTop(j)
					FWidthNew(j) = FWidth(j)
					FHeightNew(j) = FHeight(j)
					#ifdef __USE_GTK__
						Select Case FDotIndex
						Case 0: FLeftNew(j) = FLeft(j) + (FNewX - FBeginX): FTopNew(j) = FTop(j) + (FNewY - FBeginY): FWidthNew(j) = FWidth(j) - (FNewX - FBeginX): FHeightNew(j) = FHeight(j) - (FNewY - FBeginY)
						Case 1: FTopNew(j) = FTop(j) + (FNewY - FBeginY): FHeightNew(j) = FHeight(j) - (FNewY - FBeginY)
						Case 2: FTopNew(j) = FTop(j) + (FNewY - FBeginY): FWidthNew(j) = FWidth(j) + (FNewX - FBeginX): FHeightNew(j) = FHeight(j) - (FNewY - FBeginY)
						Case 3: FWidthNew(j) = FWidth(j) + (FNewX - FBeginX)
						Case 4: FWidthNew(j) = FWidth(j) + (FNewX - FBeginX): FHeightNew(j) = FHeight(j) + (FNewY - FBeginY)
						Case 5: FHeightNew(j) = FHeight(j) + (FNewY - FBeginY)
						Case 6: FLeftNew(j) = FLeft(j) + (FNewX - FBeginX): FWidthNew(j) = FWidth(j) - (FNewX - FBeginX): FHeightNew(j) = FHeight(j) + (FNewY - FBeginY)
						Case 7: FLeftNew(j) = FLeft(j) - (FBeginX - FNewX): FWidthNew(j) = FWidth(j) + (FBeginX - FNewX)
						End Select
						SetControlBounds(SelectedControls.Items[j], FLeftNew(j), FTopNew(j), FWidthNew(j), FHeightNew(j))
					#else
						Select Case FDotIndex
						Case 0: FLeftNew(j) = FLeft(j) + (FNewX - FBeginX): FTopNew(j) = FTop(j) + (FNewY - FBeginY): FWidthNew(j) = FWidth(j) - (FNewX - FBeginX): FHeightNew(j) = FHeight(j) - (FNewY - FBeginY)
						Case 1: FTopNew(j) = FTop(j) + (FNewY - FBeginY): FHeightNew(j) = FHeight(j) - (FNewY - FBeginY)
						Case 2: FTopNew(j) = FTop(j) + (FNewY - FBeginY): FWidthNew(j) = FWidth(j) + (FNewX - FBeginX): FHeightNew(j) = FHeight(j) - (FNewY - FBeginY)
						Case 3: FWidthNew(j) = FWidth(j) + (FNewX - FBeginX)
						Case 4: FWidthNew(j) = FWidth(j) + (FNewX - FBeginX): FHeightNew(j) = FHeight(j) + (FNewY - FBeginY)
						Case 5: FHeightNew(j) = FHeight(j) + (FNewY - FBeginY)
						Case 6: FLeftNew(j) = FLeft(j) + (FNewX - FBeginX): FWidthNew(j) = FWidth(j) - (FNewX - FBeginX): FHeightNew(j) = FHeight(j) + (FNewY - FBeginY)
						Case 7: FLeftNew(j) = FLeft(j) - (FBeginX - FNewX): FWidthNew(j) = FWidth(j) + (FBeginX - FNewX)
						End Select
						'ComponentSetBoundsSub(Q_ComponentFunc(SelectedControl), FLeftNew, FTopNew, FWidthNew, FHeightNew)
						MoveWindow(GetControlHandle(SelectedControls.Items[j]), ScaleX(FLeftNew(j)), ScaleY(FTopNew(j)), ScaleX(FWidthNew(j)), ScaleY(FHeightNew(j)), True)
					#endif
				Next
			End If
			If FCanMove Then
				If FBeginX <> FEndX Or FBeginY <> FEndY Then
					For j As Integer = 0 To SelectedControls.Count - 1
						#ifdef __USE_GTK__
							SetControlBounds(SelectedControls.Items[j], FLeft(j) + (FNewX - FBeginX), FTop(j) + (FNewY - FBeginY), FWidth(j), FHeight(j))
						#else
							MoveWindow(GetControlHandle(SelectedControls.Items[j]), ScaleX(FLeft(j) + (FNewX - FBeginX)), ScaleY(FTop(j) + (FNewY - FBeginY)), ScaleX(FWidth(j)), ScaleY(FHeight(j)), True)
						#endif
					Next j
				End If
			End If
			If Not FCanInsert AndAlso Not FCanMove AndAlso Not FCanSize AndAlso (CBool(FSelControl = FDialog) OrElse Not FLockControls) Then
				#ifdef __USE_GTK__
					If GTK_IS_WIDGET(layoutwidget) Then gtk_widget_queue_draw(layoutwidget)
				#else
					FHDC = GetDC(FDialog)
					'SetROP2(hdc, R2_NOTXORPEN)
					DrawFocusRect(FHDC, @Type<..Rect>(ScaleX(Min(FBeginX, FOldX)), ScaleY(Min(FBeginY, FOldY)), ScaleX(Max(FBeginX, FOldX)), ScaleY(Max(FBeginY, FOldY))))
					DrawFocusRect(FHDC, @Type<..Rect>(ScaleX(Min(FBeginX, FNewX)), ScaleX(Min(FBeginY, FNewY)), ScaleX(Max(FBeginX, FNewX)), ScaleY(Max(FBeginY, FNewY))))
				#endif
				FOldX = FNewX
				FOldY = FNewY
			End If
		Else
			#ifdef __USE_GTK__
				
			#else
				P = Type(ScaleX(X), ScaleY(Y))
				ClientToScreen(FDialog, @P)
				ScreenToClient(GetParent(FDialog), @P)
				FOverControl = ChildWindowFromPoint(GetParent(FDialog), P)
				If OnMouseMove Then OnMouseMove(This, X, Y, GetControl(FOverControl))
				Dim As Integer Id = IsDot(FOverControl)
				If Id <> -1 Then
					If FLockControls Then
						SetCursor(crArrow)
					Else
						Select Case Id
						Case 0 : SetCursor(crSizeNWSE)
						Case 1 : SetCursor(crSizeNS)
						Case 2 : SetCursor(crSizeNESW)
						Case 3 : SetCursor(crSizeWE)
						Case 4 : SetCursor(crSizeNWSE)
						Case 5 : SetCursor(crSizeNS)
						Case 6 : SetCursor(crSizeNESW)
						Case 7 : SetCursor(crSizeWE)
						End Select
					End If
				Else
					If GetAncestor(FOverControl,GA_ROOTOWNER) <> FDialog Then
						ReleaseCapture
					End If
					SetCursor(crArrow)
					ClipCursor(0)
				End If
			#endif
		End If
		FEndX = FNewX
		FEndY = FNewY
	End Sub
	
	Function Designer.GetContainerControl(Ctrl As Any Ptr) As Any Ptr
		Dim As SymbolsType Ptr st = Symbols(Ctrl)
		If st = 0 Then Return 0
		If st->ControlIsContainerFunc <> 0 Then
			If Ctrl Then
				If st->ControlIsContainerFunc(Ctrl) Then
					Return Ctrl
				ElseIf st->ReadPropertyFunc <> 0 AndAlso st->ReadPropertyFunc(Ctrl, "Parent") Then
					Return GetContainerControl(st->ReadPropertyFunc(Ctrl, "Parent"))
				End If
			End If
		End If
		Return Ctrl
	End Function
	
	Sub Designer.MouseUp(X As Integer, Y As Integer, Shift As Integer)
		Dim As Rect R
		If FDown Then
			'    	if (FBeginX > FEndX and FBeginY > FEndY) then
			'            swap FBeginX, FNewX
			'            swap FBeginY, FNewY
			'        end if
			'        if (FBeginX > FEndX and FBeginY < FEndY) then
			'            swap FBeginX, FNewX
			'        end if
			'        if (FBeginX < FEndX and FBeginY > FEndY) then
			'            swap FBeginY, FNewY
			'        end if
			FDown = False
			If Not FCanMove AndAlso Not FCanInsert AndAlso Not FCanSize Then
				If FBeginX > FNewX Then Swap FBeginX, FNewX
				If FBeginY > FNewY Then Swap FBeginY, FNewY
				SelectedControls.Clear
				#ifdef __USE_GTK__
					If GTK_IS_WIDGET(layoutwidget) Then gtk_widget_queue_draw(layoutwidget)
					Dim As Integer ALeft, ATop, AWidth, AHeight
					Dim As Any Ptr Ctrl
					SelectedControl = DesignControl
					FSelControl = FDialog
					For i As Integer = Objects.Count - 1 To 0 Step -1
						Ctrl = Objects.Item(i)
						Dim As SymbolsType Ptr st = Symbols(Ctrl)
						If Ctrl AndAlso st AndAlso st->ReadPropertyFunc <> 0 Then
							GetControlBounds(Ctrl, ALeft, ATop, AWidth, AHeight)
							If Not (ALeft + AWidth < FBeginX OrElse ALeft > FNewX OrElse ATop > FNewY OrElse ATop + AHeight < FBeginY) Then
								If SelectedControls.Count = 0 OrElse (Symbols(SelectedControls.Items[0]) AndAlso Symbols(SelectedControls.Items[0])->ReadPropertyFunc <> 0 AndAlso Symbols(SelectedControls.Items[0])->ReadPropertyFunc(SelectedControls.Items[0], "Parent") = st->ReadPropertyFunc(Ctrl, "Parent")) Then
									SelectedControls.Add Ctrl
								End If
							End If
						End If
					Next i
				#else
					If CBool(FSelControl = FDialog) OrElse Not FLockControls Then
						FHDC = GetDC(FDialog)
						DrawFocusRect(FHDC, @Type<Rect>(ScaleX(FBeginX), ScaleY(FBeginY), ScaleX(FNewX), ScaleY(FNewY)))
						ReleaseDC(FDialog, FHDC)
					End If
					SelectedControl = DesignControl
					FSelControl = FDialog
					Dim As Rect R, R1
					Dim As Any Ptr Ctrl
					For i As Integer = Objects.Count - 1 To 0 Step -1
						Ctrl = Objects.Item(i)
						Dim As SymbolsType Ptr st = Symbols(Ctrl)
						If Ctrl AndAlso st AndAlso st->ReadPropertyFunc <> 0 AndAlso st->ReadPropertyFunc(Ctrl, "Handle") AndAlso IsWindowVisible(*Cast(HWND Ptr, st->ReadPropertyFunc(Ctrl, "Handle"))) Then
							GetWindowRect(*Cast(HWND Ptr, st->ReadPropertyFunc(Ctrl, "Handle")), @R)
							MapWindowPoints(0, FDialog, Cast(Point Ptr, @R) , 2)
							R1 = Type<Rect>(UnScaleX(R.Left), UnScaleY(R.Top), UnScaleX(R.Right), UnScaleY(R.Bottom))
							If Not (R1.Right < FBeginX OrElse R1.Left > FNewX OrElse R1.Top > FNewY OrElse R1.Bottom < FBeginY) Then
								If SelectedControls.Count = 0 OrElse (Symbols(SelectedControls.Items[0]) AndAlso Symbols(SelectedControls.Items[0])->ReadPropertyFunc <> 0 AndAlso Symbols(SelectedControls.Items[0])->ReadPropertyFunc(SelectedControls.Items[0], "Parent") = st->ReadPropertyFunc(Ctrl, "Parent")) Then
									SelectedControls.Add Ctrl
								End If
							End If
						End If
					Next i
				#endif
				If SelectedControls.Count > 0 Then
					SelectedControl = SelectedControls.Items[0]
					FSelControl = GetControlHandle(SelectedControl)
				End If
				MoveDots(SelectedControl)
			End If
			If FCanInsert Then
				If FBeginX > FNewX Then Swap FBeginX, FNewX
				If FBeginY > FNewY Then Swap FBeginY, FNewY
				DrawBox(Type<My.Sys.Drawing.Rect>(FBeginX, FBeginY, FNewX, FNewY))
				#ifdef __USE_GTK__
					If GTK_IS_WIDGET(layoutwidget) Then gtk_widget_queue_draw(layoutwidget)
				#endif
				'if GetClassAcceptControls(GetClassName(FSelControl)) Then
				'R.Left   = FBeginX
				'R.Top    = FBeginY
				'R.Right  = FNewX
				'R.Bottom = FNewY
				'MapWindowPoints(FDialog, FSelControl, cast(POINT ptr, @R), 2)
				'if OnInsertingControl then
				'OnInsertingControl(this, FClass, FStyleEx, FStyle, FID)
				'end if
				'CreateControl(FClass, "", "", FSelControl, R.Left, R.Top, R.Right -R.Left, R.Bottom -R.Top)
				'else
				FClass = SelectedClass
				If OnInsertingControl Then
					FName = SelectedClass
					OnInsertingControl(This, SelectedClass, FName)
				End If
				SelectedControl = GetContainerControl(SelectedControl)
				Dim As ..Rect R
				If SelectedControl <> DesignControl Then
					#ifdef __USE_GTK__
						gtk_widget_translate_coordinates(FSelControl, layoutwidget, 0, 0, Cast(gint Ptr, @R.Left), Cast(gint Ptr, @R.Top))
					#else
						GetWindowRect FSelControl, @R
						MapWindowPoints 0, FDialog, Cast(..Point Ptr, @R), 2
					#endif
				End If
				Dim ctr As Any Ptr
				'#IfDef __USE_GTK__
				ctr = SelectedControl
				'#Else
				'	ctr = Cast(Any Ptr, GetWindowLongPtr(FSelControl, GWLP_USERDATA))
				'#EndIf
				If SelectedType = 3 Or SelectedType = 4 Then
					Dim cpnt As Any Ptr = CreateComponent(SelectedClass, FName, ctr, FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top))
					If OnInsertComponent Then OnInsertComponent(This, FClass, cpnt, 0, 0, FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top))
					If FSelControl Then
						SelectedControls.Clear
					End If
					#ifdef __USE_GTK__
						MoveDots(cpnt, , FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top), 16, 16)
					#else
						MoveDots(cpnt)
						'LockWindowUpdate(0)
					#endif
				Else
					CreateControl(SelectedClass, FName, FName, ctr, FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top), FNewX - FBeginX, FNewY - FBeginY)
					If FSelControl Then
						SelectedControls.Clear
						#ifdef __USE_GTK__
							Dim bTrue As Boolean = True
							If Symbols(SelectedControl) Then Symbols(SelectedControl)->WritePropertyFunc(SelectedControl, "Visible", @bTrue)
						#else
							LockWindowUpdate(FSelControl)
							BringWindowToTop(FSelControl)
						#endif
						If OnInsertControl Then OnInsertControl(This, FClass, SelectedControl, 0, 0, FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top), FNewX - FBeginX, FNewY - FBeginY)
						#ifdef __USE_GTK__
							MoveDots(SelectedControl, , FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top), FNewX - FBeginX, FNewY - FBeginY)
						#else
							MoveDots(SelectedControl)
							LockWindowUpdate(0)
						#endif
					Else
						Dim cpnt As Any Ptr = CreateComponent(FClass, FName, ctr, FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top))
						If cpnt Then
							If OnInsertComponent Then OnInsertComponent(This, FClass, cpnt, 0, 0, FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top))
							If FSelControl Then
								SelectedControls.Clear
							End If
							#ifdef __USE_GTK__
								MoveDots(cpnt, , FBeginX - UnScaleX(R.Left), FBeginY - UnScaleY(R.Top), 16, 16)
							#else
								MoveDots(cpnt)
								'LockWindowUpdate(0)
							#endif
						Else
							SelectedControl = DesignControl
							MoveDots(SelectedControl)
						End If
					End If
				End If
				FCanInsert = False
			End If
			If FCanSize Then
				FCanSize = False
				If FBeginX <> FNewX OrElse FBeginY <> FNewY Then
					For j As Integer = 0 To SelectedControls.Count - 1
						If OnModified Then OnModified(This, SelectedControls.Items[j], , , , FLeftNew(j), FTopNew(j), FWidthNew(j), FHeightNew(j))
					Next j
				End If
				MoveDots(SelectedControl)
			End If
			If FCanMove Then
				FCanMove = False
				If FBeginX <> FEndX OrElse FBeginY <> FEndY Then
					For j As Integer = 0 To SelectedControls.Count - 1
						If OnModified Then OnModified(This, SelectedControls.Items[j], , , , FLeft(j) + (FEndX - FBeginX), FTop(j) + (FEndY - FBeginY), FWidth(j), FHeight(j))
					Next
				End If
				MoveDots(SelectedControl)
			End If
			FBeginX = FEndX
			FBeginY = FEndY
			FNewX   = FBeginX
			FNewY   = FBeginY
			#ifdef __USE_GTK__
				gdk_window_set_cursor(gtk_widget_get_window(layoutwidget), gdk_cursor_new_from_name(gtk_widget_get_display(layoutwidget), crArrow))
			#else
				ClipCursor(0)
				ReleaseCapture
			#endif
		Else
			#ifdef __USE_GTK__
				gdk_window_set_cursor(gtk_widget_get_window(layoutwidget), gdk_cursor_new_from_name(gtk_widget_get_display(layoutwidget), crArrow))
			#else
				ClipCursor(0)
			#endif
		End If
	End Sub
	
	Sub Designer.SelectAllControls()
		If DesignControl Then
			SelectedControls.Clear
			Dim As Any Ptr Ctrl
			Dim As SymbolsType Ptr st = Symbols(DesignControl)
			If st AndAlso st->ReadPropertyFunc AndAlso st->ControlByIndexFunc Then
				For i As Integer = 0 To iGet(st->ReadPropertyFunc(DesignControl, "ControlCount")) - 1
					Ctrl = st->ControlByIndexFunc(DesignControl, i)
					SelectedControls.Add Ctrl
				Next
			End If
			If Ctrl = 0 Then SelectedControl = DesignControl Else SelectedControl = Ctrl
			MoveDots SelectedControl
		End If
	End Sub
	
	Sub Designer.DeleteControls(Ctrl As Any Ptr, EventOnly As Boolean = False)
		Dim As SymbolsType Ptr st = Symbols(Ctrl)
		If Controls.Contains(Ctrl) Then
			If st AndAlso st->ReadPropertyFunc AndAlso st->ControlByIndexFunc Then
				For i As Integer = 0 To iGet(st->ReadPropertyFunc(Ctrl, "ControlCount")) - 1
					DeleteControls st->ControlByIndexFunc(Ctrl, i), EventOnly
				Next
			End If
		End If
		If OnDeleteControl Then OnDeleteControl(This, Ctrl)
		If EventOnly Then
			If st AndAlso CInt(st->IsControlFunc) AndAlso CInt(st->IsControlFunc(Ctrl)) Then
				If st->ControlFreeWndSub Then st->ControlFreeWndSub(Ctrl)
			ElseIf st AndAlso st->ReadPropertyFunc Then
				#ifdef __USE_GTK__
					Dim As GtkWidget Ptr widget = st->ReadPropertyFunc(Ctrl, "widget")
					If widget <> 0 Then gtk_widget_destroy(widget)
				#else
					Dim As HWND Ptr phWnd = st->ReadPropertyFunc(Ctrl, "Handle")
					If phWnd <> 0 AndAlso *phWnd <> 0 Then DestroyWindow *phWnd
				#endif
			End If
		Else
			If Controls.Contains(Ctrl) Then
				If st AndAlso st->ReadPropertyFunc Then
					Dim As Any Ptr AParent = st->ReadPropertyFunc(Ctrl, "Parent")
					If st->RemoveControlSub AndAlso AParent Then st->RemoveControlSub(AParent, Ctrl)
					If st->WritePropertyFunc Then
						If st->ReadPropertyFunc(DesignControl, "CancelButton") = Ctrl Then
							st->WritePropertyFunc(DesignControl, "CancelButton", 0)
							If OnModified Then OnModified(This, DesignControl, "CancelButton")
						End If
						If st->ReadPropertyFunc(DesignControl, "DefaultButton") = Ctrl Then
							st->WritePropertyFunc(DesignControl, "DefaultButton", 0)
							If OnModified Then OnModified(This, DesignControl, "DefaultButton")
						End If
					End If
				End If
				Controls.Remove Controls.IndexOf(Ctrl)
			End If
			If Objects.Contains(Ctrl) Then
				If st AndAlso st->ReadPropertyFunc AndAlso st->WritePropertyFunc Then
					If st->ReadPropertyFunc(DesignControl, "Menu") = Ctrl Then
						st->WritePropertyFunc(DesignControl, "Menu", 0)
						If OnModified Then OnModified(This, DesignControl, "Menu")
					End If
					For i As Integer = Objects.Count - 1 To 0 Step -1
						If Objects.Item(i) > 0 AndAlso st->ReadPropertyFunc(Objects.Item(i), "Parent") = Ctrl Then
							DeleteControls Objects.Item(i), EventOnly
						End If
						If Objects.Item(i) > 0 AndAlso st->ReadPropertyFunc(Objects.Item(i), "ParentMenu") = Ctrl Then
							DeleteControls Objects.Item(i), EventOnly
						End If
					Next
				End If
				Objects.Remove Objects.IndexOf(Ctrl)
			End If
			If st AndAlso st->DeleteComponentFunc Then
				'If ReadPropertyFunc(Ctrl, "Tag") <> 0 Then Delete_(Cast(Dictionary Ptr, ReadPropertyFunc(Ctrl, "Tag")))
				st->DeleteComponentFunc(Ctrl)
			End If
		End If
		'if OnModified then OnModified(this, Ctrl, , , , -1, -1, -1, -1)
	End Sub
	
	Sub Designer.DeleteControl()
		If SelectedControl Then
			If SelectedControl <> DesignControl Then
				For i As Integer = 0 To SelectedControls.Count - 1
					DeleteControls SelectedControls.Item(i)
				Next
				FSelControl = FDialog
				SelectedControls.Clear
				SelectedControl = DesignControl
				SelectedControls.Add SelectedControl
				MoveDots SelectedControl
			End If
		End If
	End Sub
	
	Sub Designer.DeleteMenuItems(pMenu As Any Ptr, mi As Any Ptr)
		Dim As SymbolsType Ptr st = Symbols(mi)
		If st AndAlso st->ReadPropertyFunc AndAlso st->MenuItemByIndexFunc Then
			For i As Integer = iGet(st->ReadPropertyFunc(mi, "Count")) - 1 To 0 Step -1
				DeleteMenuItems pMenu, st->MenuItemByIndexFunc(mi, i)
			Next
		End If
		If OnDeleteControl Then OnDeleteControl(This, mi)
		If st Then
			Dim As Any Ptr AParent = st->ReadPropertyFunc(mi, "ParentMenuItem")
			If AParent Then
				Dim As SymbolsType Ptr st = Symbols(AParent)
				If st AndAlso st->MenuItemRemoveSub Then st->MenuItemRemoveSub(AParent, mi)
			Else
				Dim As SymbolsType Ptr st = Symbols(pMenu)
				If st AndAlso st->MenuRemoveSub Then st->MenuRemoveSub(pMenu, mi)
			End If
			If st->ObjectDeleteFunc Then
				st->ObjectDeleteFunc(mi)
			End If
		End If
	End Sub
	
	'sub Designer.DeleteControl(hDlg as HWND)
	'	if IsWindow(hDlg) then
	'		if hDlg <> FDialog then
	'		   if OnDeleteControl then OnDeleteControl(this, GetControl(hDlg))
	'		   DestroyWindow(hDlg)
	'		   if OnModified then OnModified(this, GetControl(hDlg))
	'		   FSelControl = FDialog
	'		   MoveDots SelectedControl
	'	   end if
	'	end if
	'end sub
	Dim Shared CopyList As PointerList
	Sub Designer.CopyControl()
		CopyList.Clear
		#ifdef __USE_GTK__
			If GTK_IS_WIDGET(FSelControl) Then
		#else
			If IsWindow(FSelControl) Then
		#endif
			If FSelControl <> FDialog Then
				For j As Integer = 0 To SelectedControls.Count - 1
					Dim As SymbolsType Ptr st = Symbols(SelectedControls.Items[j])
					CopyList.Add SelectedControls.Items[j], st
				Next
			End If
		End If
	End Sub
	
	Sub Designer.CutControl()
		#ifdef __USE_GTK__
			If GTK_IS_WIDGET(FSelControl) Then
		#else
			If IsWindow(FSelControl) Then
		#endif
			If FSelControl <> FDialog Then
				CopyControl
				For j As Integer = 0 To SelectedControls.Count - 1
					DeleteControls SelectedControls.Items[j], True
				Next
				'if OnModified then OnModified(this, GetControl(FSelControl))
				FSelControl = FDialog
				SelectedControl = DesignControl
				MoveDots SelectedControl
			End If
		End If
	End Sub
	
	Sub Designer.AddPasteControls(Ctrl As Any Ptr, st As SymbolsType Ptr, ByVal ParentCtrl As Any Ptr, bStart As Boolean)
		Dim As Integer iStepX, iStepY
		If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
		If bStart Then
			iStepX = GridSize
			iStepY = GridSize
			If Ctrl = ParentCtrl Then ParentCtrl = st->ReadPropertyFunc(Ctrl, "Parent")
		End If
		If OnInsertingControl Then
			FName = WGet(st->ReadPropertyFunc(Ctrl, "Name"))
			OnInsertingControl(This, WGet(st->ReadPropertyFunc(Ctrl, "ClassName")), FName)
		End If
		Dim As Integer FLeft, FTop, FWidth, FHeight
		If st->ComponentGetBoundsSub AndAlso st->Q_ComponentFunc Then st->ComponentGetBoundsSub(st->Q_ComponentFunc(Ctrl), FLeft, FTop, FWidth, FHeight)
		Dim As Any Ptr NewCtrl
		If st->IsControlFunc <> 0 AndAlso st->IsControlFunc(Ctrl) Then
			NewCtrl = This.CreateControl(WGet(st->ReadPropertyFunc(Ctrl, "ClassName")), FName, WGet(st->ReadPropertyFunc(Ctrl, "Text")), ParentCtrl, FLeft + iStepX, FTop + iStepY, FWidth, FHeight)
		Else
			NewCtrl = This.CreateComponent(WGet(st->ReadPropertyFunc(Ctrl, "ClassName")), FName, ParentCtrl, FLeft + iStepX, FTop + iStepY)
		End If
		If FSelControl Then
			Dim As String AClassName = WGet(st->ReadPropertyFunc(Ctrl, "ClassName"))
			Dim As SymbolsType Ptr st = Symbols(AClassName)
			CtrlSymbols.Add Ctrl, st
			If OnInsertControl Then OnInsertControl(This, WGet(st->ReadPropertyFunc(Ctrl, "ClassName")), NewCtrl, Ctrl, 0, FLeft + iStepX, FTop + iStepY, FWidth, FHeight)
			If bStart Then SelectedControls.Add NewCtrl
		End If
		If Controls.Contains(Ctrl) Then
			If st->ControlByIndexFunc Then
				For i As Integer = 0 To iGet(st->ReadPropertyFunc(Ctrl, "ControlCount")) - 1
					AddPasteControls st->ControlByIndexFunc(Ctrl, i), st, NewCtrl, False
				Next
			End If
		End If
	End Sub
	
	Sub Designer.PasteControl()
			If GTK_IS_WIDGET(FSelControl) Then
			Dim ParentCtrl As Any Ptr = GetControl(FSelControl)
			Dim As SymbolsType Ptr st = Symbols(ParentCtrl)
			If st AndAlso st->ControlIsContainerFunc <> 0 AndAlso st->ReadPropertyFunc <> 0 Then
				If Not st->ControlIsContainerFunc(ParentCtrl) Then ParentCtrl = st->ReadPropertyFunc(ParentCtrl, "Parent")
			End If
			#ifdef __USE_GTK__
				Dim As PointerList Ptr Value = @CopyList
			#else
				If Clipboard.HasFormat(fformat) Then
					If ( OpenClipboard(NULL) ) Then
						'извлекаем данные из буфера 'Extract data from buffer
						Dim As HANDLE hData = GetClipboardData(fformat)
						Dim As UInteger Ptr buffer = Cast(UInteger Ptr, GlobalLock( hData ))
						GlobalUnlock( hData )
						CloseClipboard()
						Dim As PointerList Ptr Value = Cast(Any Ptr, *buffer)
			#endif
					'If ReadPropertyFunc <> 0 AndAlso ComponentGetBoundsSub <> 0 Then
					SelectedControls.Clear
					For j As Integer = 0 To Value->Count - 1
						If FSelControl Then AddPasteControls Value->Item(j), Value->Object(j), ParentCtrl, True
						MoveDots(SelectedControl)
					Next
			'if OnModified then OnModified(this, GetControl(hDlg))
			'FSelControl = FDialog
		End If
	End Sub
	
	Sub Designer.DuplicateControl()
		CopyControl
		PasteControl
	End Sub
	
	
	#ifdef __USE_GTK__
		Sub Designer.HookControl(Control As GtkWidget Ptr)
	#else
		Sub Designer.HookControl(Control As HWND)
	#endif
		#ifdef __USE_GTK__
			If GTK_IS_WIDGET(Control) Then
				g_signal_connect(Control, "event", G_CALLBACK(@HookChildProc), @This)
				If GTK_IS_BIN(Control) AndAlso gtk_bin_get_child(GTK_BIN(Control)) <> 0 Then
					g_signal_connect(gtk_bin_get_child(GTK_BIN(Control)), "event", G_CALLBACK(@HookChildProc), @This)
				End If
				#ifdef __USE_GTK3__
					g_signal_connect_after(Control, "draw", G_CALLBACK(@HookChildDraw), @This)
				#endif
			End If
		#else
			If IsWindow(Control) Then
				SetProp(Control, "@@@Designer", @This)
				If GetWindowLongPtr(Control, GWLP_WNDPROC) <> @HookChildProc Then
					SetProp(Control, "@@@Proc", Cast(WNDPROC, SetWindowLongPtr(Control, GWLP_WNDPROC, CInt(@HookChildProc))))
				End If
			End If
			GetChilds(Control)
			For i As Integer = 0 To FChilds.Count - 1
				SetProp(FChilds.Child[i], "@@@Designer", @This)
				'SetWindowLongPtr(FChilds.Child[i], GWLP_USERDATA, CInt(GetControl(Control)))
				If GetProp(FChilds.Child[i], "MFFControl") = 0 Then SetProp(FChilds.Child[i], "MFFControl", GetControl(Control))
				If GetWindowLongPtr(FChilds.Child[i], GWLP_WNDPROC) <> @HookChildProc Then
					SetProp(FChilds.Child[i], "@@@Proc", Cast(WNDPROC, SetWindowLongPtr(FChilds.Child[i], GWLP_WNDPROC, CInt(@HookChildProc))))
				End If
			Next
		#endif
	End Sub
	
	Function Designer.CreateControl(AClassName As String, ByRef AName As WString, ByRef AText As WString, AParent As Any Ptr, x As Integer, y As Integer, cx As Integer, cy As Integer, bNotHook As Boolean = False) As Any Ptr
		On Error Goto ErrorHandler
		Dim As SymbolsType Ptr st = Symbols(AClassName)
		Ctrl = 0
		FSelControl = 0
		#ifdef __USE_GTK__
			Dim As GtkWidget Ptr EventBox
		#else
			Dim As HWND ParentHandle
		#endif
		If st Then
			If st->CreateControlFunc <> 0 Then
				ChDir GetFolderName(st->Path)
				Ctrl = st->CreateControlFunc(AClassName, _
				AName, _
				AText, _
				x, _
				y, _
				IIf(cx, cx, 50), _
				IIf(cy, cy, 50), _
				AParent)
				If Ctrl Then
					Objects.Add Ctrl
					CtrlSymbols.Add Ctrl, st
					Components.Add Ctrl
					Controls.Add Ctrl
					SelectedControl = Ctrl
					If st->ReadPropertyFunc Then
						#ifdef __USE_GTK__
							'g_signal_connect(layoutwidget, "event", G_CALLBACK(@HookChildProc), Ctrl)
							Dim As GtkWidget Ptr hHandle = st->ReadPropertyFunc(Ctrl, "Widget")
							EventBox = st->ReadPropertyFunc(Ctrl, "EventBoxWidget")
							If hHandle <> 0 Then FSelControl = hHandle
						#else
							Dim As HWND Ptr hHandle = st->ReadPropertyFunc(Ctrl, "Handle")
							If AParent <> 0 Then ParentHandle = *Cast(HWND Ptr, st->ReadPropertyFunc(AParent, "Handle"))
							If hHandle <> 0 Then FSelControl = *hHandle
						#endif
					End If
					If st->WritePropertyFunc Then
						Dim As Boolean bTrue = True
						st->WritePropertyFunc(Ctrl, "DesignMode", @bTrue)
						st->WritePropertyFunc(Ctrl, "ControlDesigner", @This)
						#ifdef __USE_GTK__
							
						#else
							
						#endif
					End If
				Else
					
				End If
			End If
		End If
		SelectedClass = ""
		#ifdef __USE_GTK__
			If GTK_IS_WIDGET(FSelControl) Then
				If Not bNotHook Then
					If EventBox Then
						HookControl(EventBox)
					Else
						HookControl(FSelControl)
					End If
					'AName = iif(AName="", AName = AClassName & ...)
					'SetProp(Control, "Name", ...)
					'possibly using in propertylist inspector
				End If
			End If
		#else
			If IsWindow(FSelControl) Then
				If Not bNotHook Then
					If GetParent(FSelControl) <> ParentHandle Then
						HookControl(GetParent(FSelControl))
					Else
						HookControl(FSelControl)
					End If
					'AName = iif(AName="", AName = AClassName & ...)
					'SetProp(Control, "Name", ...)
					'possibly using in propertylist inspector
					Select Case GetClassNameOf(FSelControl)
					Case "ToolBar", "ToolPalette"
						RedrawWindow FSelControl, 0, 0, RDW_INVALIDATE
						UpdateWindow FSelControl
					End Select
				End If
			End If
		#endif
		'DyLibFree(MFF)
		Return Ctrl
		Exit Function
		ErrorHandler:
		MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
	"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
	"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
	End Function
	
	#ifdef __USE_GTK__
		Function DrawComponentBorder(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As Any Ptr) As Boolean
			#ifdef __USE_GTK3__
				Dim As Integer AllocatedWidth = gtk_widget_get_allocated_width(widget), AllocatedHeight = gtk_widget_get_allocated_height(widget)
			#else
				Dim As Integer AllocatedWidth = widget->allocation.width, AllocatedHeight = widget->allocation.height
			#endif
			.cairo_rectangle(cr, 0.0, 0.0, AllocatedWidth, AllocatedHeight)
			cairo_set_source_rgb(cr, 173 / 255.0, 173 / 255.0, 173 / 255.0)
			cairo_stroke(cr)
			Return False
		End Function
		
		Function ComponentExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As Any Ptr) As Boolean
			Dim As cairo_t Ptr cr = gdk_cairo_create(Event->window)
			DrawComponentBorder(widget, cr, data1)
			cairo_destroy(cr)
			Return False
		End Function
	#endif
	
	Function Designer.Symbols(Ctrl As Any Ptr) As SymbolsType Ptr
		If Ctrl = 0 Then Return 0
		If Ctrl = OldCtrl Then Return OldCtrlSymbols
		Var Idx = 0
		If CtrlSymbols.Contains(Ctrl, Idx) Then
			OldCtrlSymbols = CtrlSymbols.Object(Idx)
			OldCtrl = Ctrl
			Return OldCtrlSymbols
		End If
		OldCtrlSymbols = 0
		OldCtrl = Ctrl
		Return 0
	End Function
	
	Function Designer.SymbolsReadProperty(Ctrl As Any Ptr) As SymbolsType Ptr
		Dim As SymbolsType Ptr st = Symbols(Ctrl)
		If st AndAlso st->ReadPropertyFunc Then Return st Else Return 0
	End Function
	
	Function Designer.SymbolsWriteProperty(Ctrl As Any Ptr) As SymbolsType Ptr
		Dim As SymbolsType Ptr st = Symbols(Ctrl)
		If st AndAlso st->WritePropertyFunc Then Return st Else Return 0
	End Function
	
	Function Designer.Symbols(AClassName As String) As SymbolsType Ptr
		If OldClassName = AClassName Then Return OldSymbols
		Var Idx = 0
		If Comps.Contains(AClassName, , , , Idx) Then
			Dim As TypeElement Ptr te = Comps.Object(Idx)
			If te <> 0 AndAlso te->Tag <> 0 Then
				If OldLibrary = te->Tag Then Return OldSymbols
				If FLibs.Contains(te->Tag, Idx) Then
					OldClassName = AClassName
					OldLibrary = te->Tag
					OldSymbols = FSymbols.Item(Idx)
					Return OldSymbols
				Else
					Dim As Library Ptr CtlLib = te->Tag
					Var st = _New(SymbolsType)
					st->Handle = DyLibLoad(GetFullPath(CtlLib->Path))
					st->Path = GetFullPath(CtlLib->Path)
					st->CreateControlFunc = DyLibSymbol(st->Handle, "CreateControl")
					st->CreateComponentFunc = DyLibSymbol(st->Handle, "CreateComponent")
					st->ReadPropertyFunc = DyLibSymbol(st->Handle, "ReadProperty")
					st->WritePropertyFunc = DyLibSymbol(st->Handle, "WriteProperty")
					st->DeleteComponentFunc = DyLibSymbol(st->Handle, "DeleteComponent")
					st->DeleteAllObjectsFunc = DyLibSymbol(st->Handle, "DeleteAllObjects")
					st->RemoveControlSub = DyLibSymbol(st->Handle, "RemoveControl")
					st->ControlByIndexFunc = DyLibSymbol(st->Handle, "ControlByIndex")
					st->Q_ComponentFunc = DyLibSymbol(st->Handle, "Q_Component")
					st->ComponentGetBoundsSub = DyLibSymbol(st->Handle, "ComponentGetBounds")
					st->ComponentSetBoundsSub = DyLibSymbol(st->Handle, "ComponentSetBounds")
					st->ControlIsContainerFunc = DyLibSymbol(st->Handle, "ControlIsContainer")
					st->IsControlFunc = DyLibSymbol(st->Handle, "IsControl")
					st->IsComponentFunc = DyLibSymbol(st->Handle, "IsComponent")
					st->ControlSetFocusSub = DyLibSymbol(st->Handle, "ControlSetFocus")
					st->ControlFreeWndSub = DyLibSymbol(st->Handle, "ControlFreeWnd")
					st->ControlRepaintSub = DyLibSymbol(st->Handle, "ControlRepaint")
					st->ToStringFunc = DyLibSymbol(st->Handle, "ToString")
					st->CreateObjectFunc = DyLibSymbol(st->Handle, "CreateObject")
					st->ObjectDeleteFunc = DyLibSymbol(st->Handle, "ObjectDelete")
					st->MenuByIndexFunc = DyLibSymbol(st->Handle, "MenuByIndex")
					st->MenuItemByIndexFunc = DyLibSymbol(st->Handle, "MenuItemByIndex")
					st->MenuFindByCommandFunc = DyLibSymbol(st->Handle, "MenuFindByCommand")
					st->MenuRemoveSub = DyLibSymbol(st->Handle, "MenuRemove")
					st->MenuItemRemoveSub = DyLibSymbol(st->Handle, "MenuItemRemove")
					st->ToolBarButtonByIndexFunc = DyLibSymbol(st->Handle, "ToolBarButtonByIndex")
					st->ToolBarRemoveButtonSub = DyLibSymbol(st->Handle, "ToolBarRemoveButton")
					st->StatusBarPanelByIndexFunc = DyLibSymbol(st->Handle, "StatusBarPanelByIndex")
					st->StatusBarRemovePanelSub = DyLibSymbol(st->Handle, "StatusBarRemovePanel")
					st->GraphicTypeLoadFromFileFunc = DyLibSymbol(st->Handle, "GraphicTypeLoadFromFile")
					st->BitmapTypeLoadFromFileFunc = DyLibSymbol(st->Handle, "BitmapTypeLoadFromFile")
					st->IconLoadFromFileFunc = DyLibSymbol(st->Handle, "IconLoadFromFile")
					st->CursorLoadFromFileFunc = DyLibSymbol(st->Handle, "CursorLoadFromFile")
					st->ImageListAddFromFileSub = DyLibSymbol(st->Handle, "ImageListAddFromFile")
					st->ImageListIndexOfFunc = DyLibSymbol(st->Handle, "ImageListIndexOf")
					st->ImageListClearSub = DyLibSymbol(st->Handle, "ImageListClear")
					FSymbols.Add st
					FLibs.Add CtlLib
					OldClassName = AClassName
					OldLibrary = CtlLib
					OldSymbols = st
					Return st
				End If
			End If
		End If
		OldClassName = AClassName
		OldLibrary = 0
		OldSymbols = 0
		Return 0
	End Function
	
	Function Designer.CreateComponent(AClassName As String, AName As String, AParent As Any Ptr, x As Integer, y As Integer, bNotHook As Boolean = False) As Any Ptr
		Dim As SymbolsType Ptr st = Symbols(AClassName)
		Dim As Any Ptr Cpnt
		If st Then
			If st->CreateComponentFunc <> 0 Then
				ChDir GetFolderName(st->Path)
				Cpnt = st->CreateComponentFunc(AClassName, AName, x, y, AParent)
				If Cpnt Then
					Objects.Add Cpnt
					Components.Add Cpnt
					CtrlSymbols.Add Cpnt, st
					SelectedControl = Cpnt
					If st->WritePropertyFunc Then
						Dim As Boolean bTrue = True
						st->WritePropertyFunc(Cpnt, "DesignMode", @bTrue)
						Dim As BitmapType pBitmap
						#ifdef __USE_GTK__
							pBitmap.LoadFromFile(*MFFPath & "/resources/" & AClassName &".png")
							Dim As GtkWidget Ptr Result
							Dim As Integer FWidth = 16, FHeight = 16
							Dim As SymbolsType Ptr stParentCtrl = Symbols(AParent)
							If AParent <> 0 AndAlso stParentCtrl <> 0 Then Result = stParentCtrl->ReadPropertyFunc(AParent, "layoutwidget")
							FSelControl = gtk_image_new()
							st->WritePropertyFunc(Cpnt, "widget", FSelControl)
							gtk_image_set_from_pixbuf(GTK_IMAGE(FSelControl), pBitmap.Handle)
							gtk_widget_set_size_request(FSelControl, 16, 16)
							#ifdef __USE_GTK3__
								g_signal_connect(FSelControl, "draw", G_CALLBACK(@DrawComponentBorder), @This)
							#else
								g_signal_connect(FSelControl, "expose-event", G_CALLBACK(@ComponentExposeEvent), @This)
							#endif
							'							ComponentSetBoundsSub()
							'							WritePropertyFunc(Cpnt, "Left", @x)
							'							WritePropertyFunc(Cpnt, "Top", @y)
							'							WritePropertyFunc(Cpnt, "Width", @FWidth)
							'							WritePropertyFunc(Cpnt, "Height", @FHeight)
							'If GTK_IS_WIDGET(FSelControl) Then
							'	If AParent = 0 OrElse Result = 0 Then
							'		If st->ReadPropertyFunc Then gtk_layout_put(GTK_LAYOUT(st->ReadPropertyFunc(DesignControl, "layoutwidget")), FSelControl, x, y)
							'	Else
							'		gtk_layout_put(GTK_LAYOUT(Result), FSelControl, x, y)
							'	End If
							'End If
							gtk_widget_show_all(FSelControl)
						#else
							If st->ReadPropertyFunc Then
								pBitmap.LoadFromResourceName(AClassName, st->Handle)
								Dim As HWND Ptr Result
								If AParent <> 0 Then Result = Cast(HWND Ptr, st->ReadPropertyFunc(AParent, "Handle"))
								If AParent = 0 OrElse Result = 0 OrElse *Result = 0 Then
									FSelControl = CreateWindowExW(0, "Button", @"", WS_CHILD Or BS_BITMAP, ScaleX(x), ScaleY(y), ScaleX(16), ScaleY(16), *Cast(HWND Ptr, st->ReadPropertyFunc(DesignControl, "Handle")), Cast(HMENU, 1000), Instance, Cpnt)
								Else
									FSelControl = CreateWindowExW(0, "Button", @"", WS_CHILD Or BS_BITMAP, ScaleX(x), ScaleY(y), ScaleX(16), ScaleY(16), *Result, Cast(HMENU, 1000), Instance, Cpnt)
								End If
								st->WritePropertyFunc(Cpnt, "Handle", @FSelControl)
								SetWindowLongPtr(FSelControl, GWLP_USERDATA, CInt(Cpnt))
								SetProp(FSelControl, "MFFControl", Cpnt)
								SendMessage(FSelControl, BM_SETIMAGE, 0, Cast(LPARAM, pBitmap.Handle))
								ShowWindow(FSelControl, SW_SHOWNORMAL)
							End If
						#endif
					End If
				End If
			End If
		End If
		#ifdef __USE_GTK__
			If GTK_IS_WIDGET(FSelControl) Then
				If Not bNotHook Then
					HookControl(FSelControl)
					'AName = iif(AName="", AName = AClassName & ...)
					'SetProp(Control, "Name", ...)
					'possibly using in propertylist inspector
				End If
			End If
		#else
			If IsWindow(FSelControl) Then
				If Not bNotHook Then
					HookControl(FSelControl)
					'AName = iif(AName="", AName = AClassName & ...)
					'SetProp(Control, "Name", ...)
					'possibly using in propertylist inspector
				End If
			End If
		#endif
		SelectedClass = ""
		Return Cpnt
	End Function
	
	Function Designer.CreateObject(AClassName As String) As Any Ptr
		Dim As SymbolsType Ptr st = Symbols(AClassName)
		Dim As Any Ptr Obj
		If st Then
			If st->CreateObjectFunc <> 0 Then
				ChDir GetFolderName(st->Path)
				Obj = st->CreateObjectFunc(AClassName)
				If Obj Then
					Objects.Add Obj
					CtrlSymbols.Add Obj, st
				End If
			End If
		End If
		Return Obj
	End Function
	
	Sub Designer.UpdateGrid
	End Sub
	
	Sub Designer.DrawTopMenu()
	End Sub
	
	Sub Designer.DrawToolBar(Handle As Any Ptr)
	End Sub
	
	Sub Designer.DrawThis()
		FStepX = GridSize
		FStepY = GridSize
		#ifdef __USE_GTK__
			Dim As GtkWidget Ptr CtrlParent = gtk_widget_get_parent(layoutwidget)
			If GTK_IS_BOX(CtrlParent) = 0 Then CtrlParent = layoutwidget
			Dim As Integer iWidth, iHeight
			#ifdef __USE_GTK3__
				Dim As Integer iWidthOverlay, iHeightOverlay
				iWidth = gtk_widget_get_allocated_width(CtrlParent): iHeight = gtk_widget_get_allocated_height(CtrlParent)
				iWidthOverlay = gtk_widget_get_allocated_width(overlay): iHeightOverlay = gtk_widget_get_allocated_height(overlay)
				If iWidthOverlay <> iWidth + 2 * FDotSize OrElse iHeightOverlay <> iHeight + 2 * FDotSize Then
					gtk_widget_set_size_request(overlay, iWidth + 2 * FDotSize, iHeight + 2 * FDotSize)
				End If
			#endif
			If ShowAlignmentGrid Then
				#ifdef __USE_GTK3__
					iWidth = gtk_widget_get_allocated_width(layoutwidget): iHeight = gtk_widget_get_allocated_height(layoutwidget)
				#else
					iWidth = layoutwidget->allocation.width: iHeight = layoutwidget->allocation.height
				#endif
				cairo_set_source_rgb(cr, 0, 0, 0)
				For i As Integer = 0 To iWidth Step FStepX
					For j As Integer = 0 To iHeight Step FStepY
						.cairo_rectangle(cr, i, j, 1, 1)
						cairo_fill(cr)
					Next j
				Next i
			End If
			Dim As Integer FLeft, FTop, FWidth, FHeight
			Dim As Const Double dashed = 0.85
			cairo_set_source_rgb(cr, 0, 0, 0)
			cairo_set_line_width (cr, 0.1)
			cairo_set_dash(cr, @dashed, 0.5, 1.5)
			For j As Integer = 0 To SelectedControls.Count - 1
				Dim As SymbolsType Ptr st = Symbols(SelectedControls.Items[j])
				If st AndAlso st->ReadPropertyFunc(SelectedControls.Items[j], "Parent") = DesignControl Then
					GetControlBounds(SelectedControls.Items[j], FLeft, FTop, FWidth, FHeight)
					'GetPosToClient ReadPropertyFunc(SelectedControls.Items[j], "widget"), layoutwidget, @FLeft, @FTop
					.cairo_rectangle(cr, ScaleX(FLeft - 2), ScaleY(FTop - 2), ScaleX(FWidth + 4), ScaleY(FHeight + 4))
					cairo_stroke(cr)
				End If
			Next j
		#else
			Dim As HDC mDc
			Dim As HBITMAP mBMP, pBMP
			Dim As ..Rect R, BrushRect = Type(0, 0, ScaleX(FStepX), ScaleY(FStepY))
			Dim As PAINTSTRUCT Ps
			Dim As Boolean WithGraphic
			Dim As Integer BackColor
			Dim As SymbolsType Ptr st = Symbols(DesignControl)
			If st AndAlso st->ReadPropertyFunc Then BackColor = QInteger(st->ReadPropertyFunc(DesignControl, "BackColor"))
			Dim As HBRUSH Brush = CreateSolidBrush(BackColor)
			FHDC = BeginPaint(FDialog,@Ps)
			GetClientRect(FDialog, @R)
			If BitmapHandle <> 0 Then
				FillRect(FHDC, @R, Brush) 'Cast(HBRUSH, 16))
				With Parent->Canvas
					.HandleSetted = True
					.Handle = FHDC
					.Draw 0, 0, BitmapHandle
					.HandleSetted = False
					WithGraphic = True
				End With
			End If
			If ShowAlignmentGrid Then
				If WithGraphic Then
					For i As Integer = R.Left To R.Right Step ScaleX(FStepX)
						For j As Integer = R.Top To R.Bottom Step ScaleY(FStepX)
							SetPixel(FHDC, i, j, 0)
						Next
					Next
				Else
					If FGridBrush Then
						DeleteObject(FGridBrush)
					End If
					mDc   = CreateCompatibleDC(FHDC)
					mBMP  = CreateCompatibleBitmap(FHDC, ScaleX(FStepX), ScaleY(FStepY))
					pBMP  = SelectObject(mDc, mBMP)
					FillRect(mDc, @BrushRect, Brush) 'Cast(HBRUSH, 16))
					SetPixel(mDc, 0, 0, 0)
					'for lines use MoveTo and LineTo or Rectangle function or whatever...
					FGridBrush = CreatePatternBrush(mBMP)
					FillRect(FHDC, @R, FGridBrush)
				End If
			ElseIf Not WithGraphic Then
				FillRect(FHDC, @R, Brush) 'Cast(HBRUSH, 16))
			End If
			DeleteObject(Brush)
			For j As Integer = 0 To SelectedControls.Count - 1
				GetWindowRect(GetControlHandle(SelectedControls.Items[j]), @R)
				MapWindowPoints 0, FDialog, Cast(..Point Ptr, @R), 2
				DrawFocusRect(FHDC, @Type<..Rect>(R.Left - 2, R.Top - 2, R.Right + 2, R.Bottom + 2))
			Next j
			If ShowAlignmentGrid Then
				SelectObject(mDc, pBMP)
				DeleteObject(mBMP)
				DeleteDC(mDc)
			End If
			EndPaint FDialog,@Ps
		#endif
	End Sub
	
	#ifdef __USE_GTK__
		Function Designer.HookChildDraw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As Any Ptr) As Boolean
			#ifdef __USE_GTK__
				Static As My.Sys.Forms.Designer Ptr Des
				Des = data1
				If Des Then
					With *Des
						If .SelectedControl = .DesignControl Then Exit Function
						If g_object_get_data(G_OBJECT(widget), "drawed") <> Des Then
							If .FSelControl = widget Then
								.MoveDots .SelectedControl, False
							End If
							g_object_set_data(G_OBJECT(widget), "drawed", Des)
						End If
					End With
				End If
				Return False
			#endif
		End Function
		
		Function Designer.HookChildProc(widget As GtkWidget Ptr, Event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
	#else
		Function Designer.HookChildProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
	#endif
		If FormClosing Then Return False
		Static As My.Sys.Forms.Designer Ptr Des
		#ifdef __USE_GTK__
			Des = user_data
		#else
			Des = GetProp(hDlg, "@@@Designer")
		#endif
		If Des Then
			With *Des
				#ifdef __USE_GTK__
					Static LeavesCount As Integer
					Select Case Event->type
					Case GDK_ENTER_NOTIFY
						If GTK_IS_EVENT_BOX(widget) Then
							LeavesCount += 1
							If LeavesCount = 2 Then
								.MouseDown(0, 0, 0, g_object_get_data(G_OBJECT(widget), "@@@Control2"))
								.MouseUp(0, 0, 0)
							End If
						End If
					Case GDK_LEAVE_NOTIFY
						LeavesCount = 0
				#else
					Select Case uMsg
					Case WM_NCHITTEST
						Dim As SymbolsType Ptr st = .Symbols(.SelectedControl)
						If st AndAlso st->IsControlFunc AndAlso CInt(Not st->IsControlFunc(.SelectedControl)) Then
							Return HTTRANSPARENT
						End If
					Case WM_GETDLGCODE: 'Return DLGC_WANTCHARS Or DLGC_WANTALLKEYS Or DLGC_WANTARROWS Or DLGC_WANTTAB
				#endif
					#ifdef __USE_GTK__
					Case GDK_EXPOSE
						Return False
						'					Case GDK_VISIBILITY_NOTIFY
						'						If Event->visibility.state = GDK_VISIBILITY_UNOBSCURED OrElse Event->visibility.state = GDK_VISIBILITY_PARTIAL Then
						'							If .FSelControl = widget Then
						'								.MoveDots .SelectedControl
						'							End If
						'						End If
					#else
					Case WM_PAINT, WM_ERASEBKGND
						Select Case GetClassNameOf(hDlg)
						Case "ToolBar", "ToolPalette"
							.DrawToolBar hDlg
							Return 1
						End Select
					#endif
					#ifdef __USE_GTK__
					Case GDK_2BUTTON_PRESS ', GDK_DOUBLE_BUTTON_PRESS
						Dim As Integer x, y
						GetPosToClient widget, .layoutwidget, @x, @y
						.DblClick(.UnScaleX(Event->motion.x + x), .UnScaleY(Event->motion.y + y), Event->motion.state, g_object_get_data(G_OBJECT(widget), "@@@Control2"))
						Return True
					#else
					Case WM_LBUTTONDBLCLK
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.DblClick(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF )
						'Return 0
					#endif
					#ifdef __USE_GTK__
					Case GDK_BUTTON_PRESS
					#else
					Case WM_LBUTTONDOWN
					#endif
					#ifdef __USE_GTK__
						Dim As Integer x, y
						GetPosToClient widget, .layoutwidget, @x, @y
						.MouseDown(.UnScaleX(Event->button.x + x), .UnScaleY(Event->button.y + y), Event->button.state, g_object_get_data(G_OBJECT(widget), "@@@Control2"))
						If GTK_IS_NOTEBOOK(widget) AndAlso Event->button.y < 20 Then
							Return False
						Else
							Return True
						End If
					#else
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.MouseDown(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF, GetProp(hDlg, "MFFControl"))
						'Return 0
					#endif
					#ifdef __USE_GTK__
					Case GDK_BUTTON_RELEASE
					#else
					Case WM_LBUTTONUP
					#endif
					#ifdef __USE_GTK__
						Dim As Integer x, y
						GetPosToClient widget, .layoutwidget, @x, @y
						.MouseUp(.UnScaleX(Event->button.x + x), .UnScaleY(Event->button.y + y), Event->button.state)
						If Event->button.button = 3 Then
							.ChangeFirstMenuItem
							mnuDesigner.Popup(.UnScaleX(Event->button.x), .UnScaleY(Event->button.y), @Type<Message>(Des, widget, Event, False))
						End If
						If GTK_IS_NOTEBOOK(widget) AndAlso .UnScaleY(Event->button.y) < 20 Then
							Return False
						Else
							Return True
						End If
					#else
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.MouseUp(GetXY(.UnScaleX(P.X)), GetXY(.UnScaleY(P.Y)), wParam And &HFFFF )
						'Return 0
					#endif
					#ifdef __USE_GTK__
					Case GDK_MOTION_NOTIFY
					#else
					Case WM_MOUSEMOVE
					#endif
					#ifdef __USE_GTK__
						Dim As Integer x, y
						GetPosToClient widget, .layoutwidget, @x, @y
						.FOverControl = widget
						.MouseMove(.UnScaleX(Event->button.x + x), .UnScaleY(Event->button.y + y), Event->button.state)
						Return True
					#else
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.MouseMove(GetXY(.UnScaleX(P.X)), GetXY(.UnScaleY(P.Y)), wParam And &HFFFF )
						'Return 0
					#endif
					#ifdef __USE_GTK__
					Case GDK_KEY_PRESS
					#else
					Case WM_KEYDOWN
					#endif
					#ifdef __USE_GTK__
						.KeyDown(Event->key.keyval, Event->key.state, g_object_get_data(G_OBJECT(widget), "@@@Control2"))
					#else
						.KeyDown(wParam, 0)
					#endif
				End Select
			End With
		End If
		#ifdef __USE_GTK__
			Return True
		#else
			Return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
		#endif
		'#Else
		'Dim As Any Ptr Ctrl = Cast(Any Ptr, GetWindowLongPtr(hDlg, GWLP_USERDATA))
		'If Ctrl <> 0 AndAlso Des <> 0 AndAlso Des->ReadPropertyFunc <> 0 AndAlso QWString(Des->ReadPropertyFunc(Ctrl, "ClassAncestor")) = "" Then
		'Select Case uMsg
		
		'case WM_MOUSEFIRST to WM_MOUSELAST
		'	return true
		'case WM_NCHITTEST
		'	return HTTRANSPARENT
		'case WM_KEYFIRST to WM_KEYLAST
		'	return 0
		'end select
		'End If
		'return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
		'#EndIf
	End Function
	
	Public Sub Designer.AlignLefts
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiLeft = iLeft
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.AlignCenters
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiLeft = iLeft + iWidth / 2 - iiWidth / 2
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.AlignRights
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiLeft = iLeft + iWidth - iiWidth
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.AlignTops
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiTop = iTop
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.AlignMiddles
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiTop = iTop + iHeight / 2 - iiHeight / 2
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.AlignBottoms
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiTop = iTop + iHeight - iiHeight
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.AlignToGrid
		If Components.Count > 0 Then
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiLeft = Int(iiLeft / GridSize) * GridSize
				iiTop = Int(iiTop / GridSize) * GridSize
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.MakeSameSizeWidth
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiWidth = iWidth
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.MakeSameSizeHeight
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiHeight = iHeight
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.MakeSameSizeBoth
		If Components.Count > 0 Then
			Dim As Integer iLeft, iTop, iWidth, iHeight
			GetControlBounds(SelectedControl, iLeft, iTop, iWidth, iHeight)
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiWidth = iWidth
				iiHeight = iHeight
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.SizeToGrid
		If Components.Count > 0 Then
			For i As Integer = 0 To SelectedControls.Count - 1
				Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
				GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				iiLeft = Int(iiLeft / GridSize) * GridSize
				iiTop = Int(iiTop / GridSize) * GridSize
				iiWidth = Int(iiWidth / GridSize) * GridSize
				iiHeight = Int(iiHeight / GridSize) * GridSize
				SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
				If OnModified Then OnModified(This, SelectedControls.Items[i], , , , iiLeft, iiTop, iiWidth, iiHeight)
			Next
			MoveDots SelectedControl
		End If
	End Sub
	
	Public Sub Designer.HorizontalSpacingMakeEqual
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 3 Then Exit Sub
		Dim As Integer iMin, iMax, iLefts, iWidths, iAverage, iIndex
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
			iWidths += iiWidth
		Next
		iListOfLefts.Sort
		iMin = iListOfLefts.Item(0)
		iMax = iListOfLefts.Item(iCount - 1)
		iIndex = iListOfWidths.IndexOfObject(iListOfLefts.Object(iCount - 1))
		iWidths -= iListOfWidths.Item(iIndex)
		iAverage = (iMax - iMin - iWidths) / (iCount - 1)
		iIndex = iListOfWidths.IndexOfObject(iListOfLefts.Object(0))
		iLefts = iMin + iListOfWidths.Item(iIndex)
		For i As Integer = 1 To iCount - 2
			Ctrl = iListOfLefts.Object(i)
			iIndex = iListOfTops.IndexOfObject(Ctrl)
			iLefts += iAverage
			iiLeft = iLefts
			iiTop = iListOfTops.Item(iIndex)
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
			iLefts += iiWidth
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.HorizontalSpacingIncrease
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 2 Then Exit Sub
		Dim As Integer iIndex
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
		Next
		iListOfLefts.Sort
		For i As Integer = 1 To iCount - 1
			Ctrl = iListOfLefts.Object(i)
			iIndex = iListOfTops.IndexOfObject(Ctrl)
			iiLeft = iListOfLefts.Item(i) + GridSize * i
			iiTop = iListOfTops.Item(iIndex)
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.HorizontalSpacingDecrease
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 2 Then Exit Sub
		Dim As Integer iIndex
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
		Next
		iListOfLefts.Sort
		For i As Integer = 1 To iCount - 1
			Ctrl = iListOfLefts.Object(i)
			iIndex = iListOfTops.IndexOfObject(Ctrl)
			iiLeft = iListOfLefts.Item(i) - GridSize * i
			iiTop = iListOfTops.Item(iIndex)
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.HorizontalSpacingRemove
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 2 Then Exit Sub
		Dim As Integer iIndex, iLefts
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
		Next
		iListOfLefts.Sort
		iIndex = iListOfWidths.IndexOfObject(iListOfLefts.Object(0))
		iLefts = iListOfLefts.Item(0) + iListOfWidths.Item(iIndex)
		For i As Integer = 1 To iCount - 1
			Ctrl = iListOfLefts.Object(i)
			iIndex = iListOfTops.IndexOfObject(Ctrl)
			iiLeft = iLefts
			iiTop = iListOfTops.Item(iIndex)
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
			iLefts += iiWidth
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.VerticalSpacingMakeEqual
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 3 Then Exit Sub
		Dim As Integer iMin, iMax, iTops, iHeights, iAverage, iIndex
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
			iHeights += iiHeight
		Next
		iListOfTops.Sort
		iMin = iListOfTops.Item(0)
		iMax = iListOfTops.Item(iCount - 1)
		iIndex = iListOfHeights.IndexOfObject(iListOfTops.Object(iCount - 1))
		iHeights -= iListOfHeights.Item(iIndex)
		iAverage = (iMax - iMin - iHeights) / (iCount - 1)
		iIndex = iListOfHeights.IndexOfObject(iListOfTops.Object(0))
		iTops = iMin + iListOfHeights.Item(iIndex)
		For i As Integer = 1 To iCount - 2
			Ctrl = iListOfTops.Object(i)
			iIndex = iListOfLefts.IndexOfObject(Ctrl)
			iTops += iAverage
			iiLeft = iListOfLefts.Item(iIndex)
			iiTop = iTops
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
			iTops += iiHeight
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.VerticalSpacingIncrease
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 2 Then Exit Sub
		Dim As Integer iIndex
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
		Next
		iListOfTops.Sort
		For i As Integer = 1 To iCount - 1
			Ctrl = iListOfTops.Object(i)
			iIndex = iListOfLefts.IndexOfObject(Ctrl)
			iiLeft = iListOfLefts.Item(iIndex)
			iiTop = iListOfTops.Item(i) + GridSize * i
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.VerticalSpacingDecrease
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 2 Then Exit Sub
		Dim As Integer iIndex
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
		Next
		iListOfTops.Sort
		For i As Integer = 1 To iCount - 1
			Ctrl = iListOfTops.Object(i)
			iIndex = iListOfLefts.IndexOfObject(Ctrl)
			iiLeft = iListOfLefts.Item(iIndex)
			iiTop = iListOfTops.Item(i) - GridSize * i
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.VerticalSpacingRemove
		If Components.Count = 0 Then Exit Sub
		Dim As Integer iCount = SelectedControls.Count
		If iCount < 2 Then Exit Sub
		Dim As Integer iIndex, iTops
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		Dim As IntegerList iListOfLefts, iListOfTops, iListOfWidths, iListOfHeights
		Dim As Any Ptr Ctrl
		For i As Integer = 0 To iCount - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iListOfLefts.Add iiLeft, SelectedControls.Items[i]
			iListOfTops.Add iiTop, SelectedControls.Items[i]
			iListOfWidths.Add iiWidth, SelectedControls.Items[i]
			iListOfHeights.Add iiHeight, SelectedControls.Items[i]
		Next
		iListOfTops.Sort
		iIndex = iListOfHeights.IndexOfObject(iListOfTops.Object(0))
		iTops = iListOfTops.Item(0) + iListOfHeights.Item(iIndex)
		For i As Integer = 1 To iCount - 1
			Ctrl = iListOfTops.Object(i)
			iIndex = iListOfLefts.IndexOfObject(Ctrl)
			iiLeft = iListOfLefts.Item(iIndex)
			iiTop = iTops
			iiWidth = iListOfWidths.Item(iIndex)
			iiHeight = iListOfHeights.Item(iIndex)
			SetControlBounds(Ctrl, iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
			iTops += iiHeight
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.CenterInParentHorizontally
		Dim As SymbolsType Ptr st = Symbols(SelectedControl)
		If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
		Dim As Any Ptr ParentCtrl = st->ReadPropertyFunc(SelectedControl, "Parent")
		If ParentCtrl = 0 Then Exit Sub
		Dim As Integer iLeft, iTop, iWidth, iHeight
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		GetControlBounds(ParentCtrl, iLeft, iTop, iWidth, iHeight)
		For i As Integer = 0 To SelectedControls.Count - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iiLeft = (iWidth - iiWidth) / 2
			SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Sub Designer.CenterInParentVertically
		Dim As SymbolsType Ptr st = Symbols(SelectedControl)
		If st = 0 OrElse st->ReadPropertyFunc = 0 Then Exit Sub
		Dim As Any Ptr ParentCtrl = st->ReadPropertyFunc(SelectedControl, "Parent")
		If ParentCtrl = 0 Then Exit Sub
		Dim As Integer iLeft, iTop, iWidth, iHeight
		Dim As Integer iiLeft, iiTop, iiWidth, iiHeight
		GetControlBounds(ParentCtrl, iLeft, iTop, iWidth, iHeight)
		For i As Integer = 0 To SelectedControls.Count - 1
			GetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			iiTop = (iHeight - iiHeight) / 2
			SetControlBounds(SelectedControls.Items[i], iiLeft, iiTop, iiWidth, iiHeight)
			If OnModified Then OnModified(This, Ctrl, , , , iiLeft, iiTop, iiWidth, iiHeight)
		Next
		MoveDots SelectedControl
	End Sub
	
	Public Property Designer.LockControls As Boolean
		Return FLockControls
	End Property
	
	Public Property Designer.LockControls(Value As Boolean)
		FLockControls = Value
	End Property
	
	Sub Designer.BringToFront(Ctrl As Any Ptr = 0)
		Dim As SymbolsType Ptr st = Symbols(SelectedControl)
		#ifdef __USE_GTK__
			If st <> 0 AndAlso CInt(st->ReadPropertyFunc <> 0) AndAlso CInt(st->ReadPropertyFunc(SelectedControl, "Parent")) AndAlso CInt(st->ReadPropertyFunc(st->ReadPropertyFunc(SelectedControl, "Parent"), "layoutwidget")) Then
				Dim As Integer iLeft = QInteger(st->ReadPropertyFunc(SelectedControl, "Left")), iTop = QInteger(st->ReadPropertyFunc(SelectedControl, "Top"))
				Dim As GtkWidget Ptr CtrlWidget = st->ReadPropertyFunc(SelectedControl, "widget")
				Dim As Any Ptr ParentCtrl = st->ReadPropertyFunc(SelectedControl, "Parent")
				Dim As SymbolsType Ptr stParent = Symbols(ParentCtrl)
				If stParent->ReadPropertyFunc Then
					Dim As GtkWidget Ptr LayoutWidget = stParent->ReadPropertyFunc(ParentCtrl, "layoutwidget")
					If GTK_IS_SCROLLED_WINDOW(gtk_widget_get_parent(CtrlWidget)) OrElse GTK_IS_EVENT_BOX(gtk_widget_get_parent(CtrlWidget)) Then
						CtrlWidget = gtk_widget_get_parent(CtrlWidget)
					End If
					g_object_ref(CtrlWidget)
					gtk_container_remove(GTK_CONTAINER(LayoutWidget), CtrlWidget)
					gtk_layout_put(GTK_LAYOUT(LayoutWidget), CtrlWidget, iLeft, iTop)
				End If
			End If
		#else
			If Ctrl = 0 Then
				SetWindowPos FSelControl, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
			ElseIf Symbols(Ctrl) AndAlso Symbols(Ctrl)->ReadPropertyFunc Then
				SetWindowPos *Cast(HWND Ptr, Symbols(Ctrl)->ReadPropertyFunc(Ctrl, "Handle")), HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
			End If
		#endif
		If Ctrl = 0 AndAlso st AndAlso st->ReadPropertyFunc AndAlso st->WritePropertyFunc AndAlso st->ReadPropertyFunc(SelectedControl, "Parent") Then
			Dim As Any Ptr ParentCtrl = st->ReadPropertyFunc(SelectedControl, "Parent"), CtrlAfter
			Dim As SymbolsType Ptr stParent = Symbols(ParentCtrl)
			If stParent->ReadPropertyFunc AndAlso stParent->ControlByIndexFunc Then
				Dim As Integer ControlCount = QInteger(stParent->ReadPropertyFunc(ParentCtrl, "ControlCount"))
				If ControlCount > 1 Then
					Dim As Integer newIndex = ControlCount - 1
					CtrlAfter = stParent->ControlByIndexFunc(ParentCtrl, newIndex)
					If SelectedControl <> CtrlAfter Then
						st->WritePropertyFunc(SelectedControl, "ControlIndex", @newIndex)
						If OnModified Then OnModified(This, SelectedControl, , , CtrlAfter)
					End If
				End If
			End If
		End If
	End Sub
	
	Sub Designer.SendToBack(Ctrl As Any Ptr = 0)
		Dim As SymbolsType Ptr st = Symbols(SelectedControl)
		#ifdef __USE_GTK__
			If st AndAlso st->ReadPropertyFunc AndAlso st->ReadPropertyFunc(SelectedControl, "Parent") Then
				Dim As Integer iLeft, iTop
				Dim As Any Ptr ParentCtrl = st->ReadPropertyFunc(SelectedControl, "Parent"), Ctrl
				Dim As SymbolsType Ptr stParent = Symbols(ParentCtrl)
				Dim As GtkWidget Ptr CtrlWidget, CurrentWidget = st->ReadPropertyFunc(SelectedControl, "widget")
				If stParent AndAlso stParent->ReadPropertyFunc AndAlso stParent->ControlByIndexFunc Then
					Dim As GtkWidget Ptr LayoutWidget = stParent->ReadPropertyFunc(ParentCtrl, "layoutwidget")
					For i As Integer = 0 To QInteger(stParent->ReadPropertyFunc(ParentCtrl, "ControlCount")) - 1
						Ctrl = stParent->ControlByIndexFunc(ParentCtrl, i)
						Dim As SymbolsType Ptr st = Symbols(Ctrl)
						If st AndAlso st->ReadPropertyFunc Then
							CtrlWidget = st->ReadPropertyFunc(Ctrl, "widget")
							If CurrentWidget <> CtrlWidget Then
								If GTK_IS_SCROLLED_WINDOW(gtk_widget_get_parent(CtrlWidget)) OrElse GTK_IS_EVENT_BOX(gtk_widget_get_parent(CtrlWidget)) Then
									CtrlWidget = gtk_widget_get_parent(CtrlWidget)
								End If
								iLeft = QInteger(st->ReadPropertyFunc(Ctrl, "Left"))
								iTop = QInteger(st->ReadPropertyFunc(Ctrl, "Top"))
								g_object_ref(CtrlWidget)
								gtk_container_remove(GTK_CONTAINER(LayoutWidget), CtrlWidget)
								gtk_layout_put(GTK_LAYOUT(LayoutWidget), CtrlWidget, iLeft, iTop)
							End If
						End If
					Next
				End If
			End If
		#else
			If Ctrl = 0 Then
				SetWindowPos FSelControl, HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
			ElseIf Symbols(Ctrl) AndAlso Symbols(Ctrl)->ReadPropertyFunc Then
				SetWindowPos *Cast(HWND Ptr, Symbols(Ctrl)->ReadPropertyFunc(Ctrl, "Handle")), HWND_BOTTOM, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE
			End If
		#endif
		If st AndAlso st->ReadPropertyFunc AndAlso st->WritePropertyFunc AndAlso st->ReadPropertyFunc(SelectedControl, "Parent") Then
			Dim As Any Ptr ParentCtrl = st->ReadPropertyFunc(SelectedControl, "Parent"), Ctrl
			Dim As SymbolsType Ptr stParent = Symbols(ParentCtrl)
			If stParent AndAlso stParent->ReadPropertyFunc AndAlso stParent->ControlByIndexFunc AndAlso QInteger(stParent->ReadPropertyFunc(ParentCtrl, "ControlCount")) > 1 Then
				Dim As Integer NewIndex = 0
				Ctrl = stParent->ControlByIndexFunc(ParentCtrl, NewIndex)
				If SelectedControl <> Ctrl Then
					st->WritePropertyFunc(SelectedControl, "ControlIndex", @NewIndex)
					If OnModified Then OnModified(This, SelectedControl, , Ctrl)
				End If
			End If
		End If
	End Sub
	
	Function Designer.EnumPopupMenuItems(ByRef Item As MenuItem) As Boolean
		FPopupMenuItems.Add Item
		For i As Integer = 0 To Item.Count -1
			EnumPopupMenuItems *Item.Item(i)
		Next i
		Return True
	End Function
	
	Sub Designer.GetPopupMenuItems
		FPopupMenuItems.Clear
		If Parent AndAlso Parent->ContextMenu Then
			For i As Integer = 0 To Parent->ContextMenu->Count -1
				EnumPopupMenuItems *Parent->ContextMenu->Item(i)
			Next i
		End If
	End Sub
	
	#ifdef __USE_GTK__
		Function Designer.HookDialogProc(widget As GtkWidget Ptr, Event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
	#else
		Function Designer.HookDialogProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
	#endif
		Static As Boolean bCtrl, bShift
		Static As Any Ptr Ctrl
		Static As My.Sys.Forms.Designer Ptr Des
		#ifdef __USE_GTK__
			bShift = Event->key.state And GDK_SHIFT_MASK
			bCtrl = Event->key.state And GDK_CONTROL_MASK
			Des = user_data
			'If ReadPropertyFunc Then Des = ReadPropertyFunc(Ctrl, "ControlDesigner")
		#else
			bShift = GetKeyState(VK_SHIFT) And 8000
			bCtrl = GetKeyState(VK_CONTROL) And 8000
			Des = GetProp(hDlg, "@@@Designer")
		#endif
		If Des Then
			With *Des
				#ifdef __USE_GTK__
					Select Case Event->type
				#else
					Select Case uMsg
				#endif
					#ifdef __USE_GTK__
					Case GDK_2BUTTON_PRESS ', GDK_DOUBLE_BUTTON_PRESS
						.DblClick(.UnScaleX(Event->motion.x), .UnScaleY(Event->motion.y), Event->motion.state)
						Return True
					#else
					Case WM_LBUTTONDBLCLK
						.DblClick(.UnScaleX(LoWord(lParam)), .UnScaleY(HiWord(lParam)), wParam And &HFFFF)
						'Return 0
					#endif
					#ifdef __USE_GTK__
					Case GDK_BUTTON_PRESS
						.MouseDown(.UnScaleX(Event->button.x), .UnScaleY(Event->button.y), Event->button.state)
						Return True
					#else
					Case WM_LBUTTONDOWN
						.MouseDown(.UnScaleX(LoWord(lParam)), .UnScaleY(HiWord(lParam)), wParam And &HFFFF )
						Return 0
					#endif
					#ifdef __USE_GTK__
					Case GDK_BUTTON_RELEASE
						.MouseUp(.UnScaleX(Event->button.x), .UnScaleY(Event->button.y), Event->button.state)
						If Event->button.button = 3 Then
							.ChangeFirstMenuItem
							mnuDesigner.Popup(Event->button.x, Event->button.y, @Type<Message>(Des, widget, Event, False))
						End If
						Return True
					#else
					Case WM_LBUTTONUP
						.MouseUp(.UnScaleX(LoWord(lParam)), .UnScaleY(HiWord(lParam)), wParam And &HFFFF )
						Return 0
					#endif
					#ifdef __USE_GTK__
					Case GDK_MOTION_NOTIFY
						.FOverControl = widget
						.MouseMove(.UnScaleX(Event->button.x), .UnScaleY(Event->button.y), Event->button.state)
						Return True
					#else
					Case WM_MOUSEMOVE
						.MouseMove(.UnScaleX(LoWord(lParam)), .UnScaleY(HiWord(lParam)), wParam And &HFFFF )
						'Return 0
					#endif
					#ifdef __USE_GTK__
					Case GDK_KEY_PRESS
						.KeyDown(Event->key.keyval, Event->key.state)
						Return True
						'Select Case event->Key.keyval
					#else
					Case WM_KEYDOWN
						.KeyDown(wParam, 0)
						'Select Case wParam
					#endif
					'					Case Keys.Key_Delete
					'						If Des->FSelControl <> Des->FDialog Then Des->DeleteControl(Des->SelectedControl)
					'					Case Keys.Key_Left, Keys.Key_Right, Keys.Key_Up, Keys.Key_Down
					'						Dim As Integer FLeft, FTop, FWidth, FHeight
					'						Dim As Integer FStepX = Des->FStepX
					'						Dim As Integer FStepY = Des->FStepY
					'						If bCtrl Then FStepX = 1: FStepY = 1
					'						#IfDef __USE_GTK__
					'						#Else
					'							Dim As POINT P
					'							Dim As RECT R
					'							GetWindowRect(Des->FSelControl, @R)
					'							P.X     = R.Left
					'							P.Y     = R.Top
					'							FWidth  = R.Right - R.Left
					'							FHeight = R.Bottom - R.Top
					'							ScreenToClient(GetParent(Des->FSelControl), @P)
					'							FLeft   = P.X
					'							FTop    = P.Y
					'							If bShift Then
					'								Select Case wParam
					'								Case Keys.Key_Left: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth - FStepX, FHeight, True)
					'								Case Keys.Key_Right: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth + FStepX, FHeight, True)
					'								Case Keys.Key_Up: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth, FHeight - FStepY, True)
					'								Case Keys.Key_Down: MoveWindow(Des->FSelControl, FLeft, FTop, FWidth, FHeight + FStepY, True)
					'								End Select
					'							ElseIf Des->FSelControl <> Des->Dialog Then
					'								Select Case wParam
					'								Case Keys.Key_Left: MoveWindow(Des->FSelControl, FLeft - FStepX, FTop, FWidth, FHeight, True)
					'								Case Keys.Key_Right: MoveWindow(Des->FSelControl, FLeft + FStepX, FTop, FWidth, FHeight, True)
					'								Case Keys.Key_Up: MoveWindow(Des->FSelControl, FLeft, FTop - FStepY, FWidth, FHeight, True)
					'								Case Keys.Key_Down: MoveWindow(Des->FSelControl, FLeft, FTop + FStepY, FWidth, FHeight, True)
					'								End Select
					'							End If
					'							Des->MoveDots(Des->FSelControl)
					'							If Des->OnModified Then Des->OnModified(*Des, GetControl(Des->FSelControl))
					'						#EndIf
					'					End Select
				End Select
			End With
		End If
		#ifdef __USE_GTK__
			Return False
		#else
			Return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
		#endif
	End Function
	
	
	#ifdef __USE_GTK__
		Function Designer.HookDialogParentProc(widget As GtkWidget Ptr, Event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
	#else
		Function Designer.HookDialogParentProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
	#endif
		Static As My.Sys.Forms.Designer Ptr Des
		#ifdef __USE_GTK__
			Des = user_data
		#else
			Des = GetProp(hDlg, "@@@Designer")
		#endif
		If Des Then
			With *Des
				#ifdef __USE_GTK__
					Select Case Event->type
				#else
					Select Case uMsg
					Case WM_NCHITTEST
					Case WM_GETDLGCODE: 'Return DLGC_WANTCHARS Or DLGC_WANTALLKEYS Or DLGC_WANTARROWS Or DLGC_WANTTAB
				#endif
					#ifdef __USE_GTK__
					Case GDK_2BUTTON_PRESS ', GDK_DOUBLE_BUTTON_PRESS
						.DblClick(.UnScaleX(Event->motion.x), .UnScaleY(Event->motion.y), Event->motion.state)
						Return True
					#else
					Case WM_LBUTTONDBLCLK
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.DblClick(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF)
						'Return 0
					#endif
					#ifdef __USE_GTK__
					Case GDK_BUTTON_PRESS
					#else
					Case WM_LBUTTONDOWN
					#endif
					#ifdef __USE_GTK__
						Dim As Integer x, y
						GetPosToClient(.layoutwidget, widget, @x, @y)
						.MouseDown(.UnScaleX(Event->button.x - x), .UnScaleY(Event->button.y - y), Event->button.state)
						Return True
					#else
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.MouseDown(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF )
						Return 0
					#endif
					#ifdef __USE_GTK__
					Case GDK_BUTTON_RELEASE
					#else
					Case WM_LBUTTONUP
					#endif
					#ifdef __USE_GTK__
						Dim As Integer x, y
						GetPosToClient(.layoutwidget, widget, @x, @y)
						.MouseUp(.UnScaleX(Event->button.x - x), .UnScaleY(Event->button.y - y), Event->button.state)
						Return True
					#else
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.MouseUp(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF )
						Return 0
					#endif
					#ifdef __USE_GTK__
					Case GDK_MOTION_NOTIFY
						'.FOverControl = Widget
					#else
					Case WM_MOUSEMOVE
					#endif
					#ifdef __USE_GTK__
						Dim As Integer x, y
						GetPosToClient(.layoutwidget, widget, @x, @y)
						.MouseMove(.UnScaleX(Event->motion.x - x), .UnScaleY(Event->motion.y - y), Event->motion.state)
						Return True
					#else
						P = Type<..Point>(LoWord(lParam), HiWord(lParam))
						ClientToScreen(hDlg, @P)
						ScreenToClient(.FDialog, @P)
						.MouseMove(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF )
						Return 0
					#endif
					#ifdef __USE_GTK__
					Case GDK_KEY_PRESS
					#else
					Case WM_KEYDOWN
					#endif
					#ifdef __USE_GTK__
						.KeyDown(Event->key.keyval, Event->key.state)
					#else
						.KeyDown(wParam, 0)
					#endif
				End Select
			End With
		End If
		#ifdef __USE_GTK__
			Return False
		#else
			Return CallWindowProc(GetProp(hDlg, "@@@Proc"), hDlg, uMsg, wParam, lParam)
		#endif
	End Function
	
	Sub Designer.Hook
		#ifdef __USE_GTK__
			If GTK_IS_WIDGET(FDialog) Then
		#else
			If IsWindow(FDialog) Then
		#endif
			#ifdef __USE_GTK__
				g_signal_connect(layoutwidget, "event", G_CALLBACK(@HookDialogProc), @This)
			#else
				SetProp(FDialog, "@@@Designer", @This)
				If GetWindowLongPtr(FDialog, GWLP_WNDPROC) <> @HookDialogProc Then
					SetProp(FDialog, "@@@Proc", Cast(Any Ptr, SetWindowLongPtr(FDialog, GWLP_WNDPROC, CInt(@HookDialogProc))))
				End If
			#endif
			HookParent
			'GetChilds
			'for i as integer = 0 to FChilds.Count-1
			'	HookControl(FChilds.Child[i])
			'next
		End If
	End Sub
	
	Sub Designer.UnHook
	End Sub
	
	Sub Designer.HookParent
		#ifdef __USE_GTK__
			If GTK_IS_WIDGET(FDialogParent) Then
				g_signal_connect(FDialogParent, "event", G_CALLBACK(@HookDialogParentProc), @This)
				'				#ifdef __USE_GTK3__
				'					gtk_widget_set_events(layout, _
				'					GDK_EXPOSURE_MASK Or _
				'					GDK_SCROLL_MASK Or _
				'					GDK_STRUCTURE_MASK Or _
				'					GDK_KEY_PRESS_MASK Or _
				'					GDK_KEY_RELEASE_MASK Or _
				'					GDK_FOCUS_CHANGE_MASK Or _
				'					GDK_LEAVE_NOTIFY_MASK Or _
				'					GDK_BUTTON_PRESS_MASK Or _
				'					GDK_BUTTON_RELEASE_MASK Or _
				'					GDK_POINTER_MOTION_MASK Or _
				'					GDK_POINTER_MOTION_HINT_MASK)
				'					g_signal_connect(layout, "event", G_CALLBACK(@HookDialogParentProc), @This)
				'				#endif
			End If
		#else
			If IsWindow(FDialog) Then
				SetProp(GetParent(FDialog), "@@@Designer", @This)
				If GetWindowLongPtr(GetParent(FDialog), GWLP_WNDPROC) <> @HookDialogParentProc Then
					SetProp(GetParent(FDialog), "@@@Proc", Cast(Any Ptr, SetWindowLongPtr(GetParent(FDialog), GWLP_WNDPROC, CInt(@HookDialogParentProc))))
				End If
				SetProp(TopMenu->Handle, "@@@Designer", @This)
				If GetWindowLongPtr(TopMenu->Handle, GWLP_WNDPROC) <> @HookTopMenuProc Then
					SetProp(TopMenu->Handle, "@@@Proc", Cast(Any Ptr, SetWindowLongPtr(TopMenu->Handle, GWLP_WNDPROC, CInt(@HookTopMenuProc))))
				End If
			End If
		#endif
	End Sub
	
	Sub Designer.UnHookParent
	End Sub
	
	Sub Designer.KeyDown(KeyCode As Integer, Shift As Integer, Ctrl As Any Ptr = 0)
		Static bShift As Boolean
		Static bCtrl As Boolean
		#ifdef __USE_GTK__
			bShift = Shift And GDK_SHIFT_MASK
			bCtrl = Shift And GDK_CONTROL_MASK
		#else
			bShift = GetKeyState(VK_SHIFT) And 8000
			bCtrl = GetKeyState(VK_CONTROL) And 8000
		#endif
		Select Case KeyCode
		Case Keys.Key_Delete: DeleteControl()
		Case Keys.Key_Enter: If OnDblClickControl Then OnDblClickControl(This, SelectedControl)
		Case Keys.Key_Left, Keys.Key_Right, Keys.Key_Up, Keys.Key_Down
			FStepX = GridSize
			FStepY = GridSize
			Dim As Integer FStepX1 = FStepX
			Dim As Integer FStepY1 = FStepY
			Dim As Integer FLeft, FTop, FWidth, FHeight
			If bCtrl Then FStepX1 = 1: FStepY1 = 1
			#ifdef __USE_GTK__
				If SelectedControl <> 0 Then
					For j As Integer = 0 To SelectedControls.Count - 1
						Dim As SymbolsType Ptr st = Symbols(SelectedControls.Items[j])
						GetControlBounds(SelectedControls.Items[j], FLeft, FTop, FWidth, FHeight)
						If bShift Then
							Select Case KeyCode
							Case Keys.Key_Left: FWidth = FWidth - FStepX1
							Case Keys.Key_Right: FWidth = FWidth + FStepX1
							Case Keys.Key_Up: FHeight = FHeight - FStepY1
							Case Keys.Key_Down: FHeight = FHeight + FStepY1
							End Select
						ElseIf SelectedControl <> DesignControl Then
							Select Case KeyCode
							Case Keys.Key_Left: FLeft = FLeft - FStepX1
							Case Keys.Key_Right: FLeft = FLeft + FStepX1
							Case Keys.Key_Up: FTop = FTop - FStepY1
							Case Keys.Key_Down: FTop = FTop + FStepY1
							End Select
						End If
						If st Then st->ComponentSetBoundsSub(SelectedControls.Items[j], FLeft, FTop, FWidth, FHeight)
						Dim As Integer FrameTop
						Dim As Any Ptr ParentCtrl
						If st AndAlso st->ReadPropertyFunc Then ParentCtrl = st->ReadPropertyFunc(SelectedControls.Items[j], "Parent")
						Dim As SymbolsType Ptr stParentCtrl = Symbols(ParentCtrl)
						If CInt(ParentCtrl) AndAlso stParentCtrl AndAlso stParentCtrl->ReadPropertyFunc AndAlso CInt(QWString(stParentCtrl->ReadPropertyFunc(ParentCtrl, "ClassName")) = "GroupBox") Then FrameTop = 20
						pApp->DoEvents
						MoveDots(SelectedControls.Items[j], , FLeft, FTop - FrameTop, FWidth, FHeight)
						If OnModified Then OnModified(This, SelectedControls.Items[j], , , , FLeft, FTop, FWidth, FHeight)
					Next
				End If
			#else
				Dim As ..Point P
				Dim As ..Rect R
				Dim As HWND ControlHandle
				For j As Integer = 0 To SelectedControls.Count - 1
					ControlHandle = GetControlHandle(SelectedControls.Items[j])
					GetWindowRect(ControlHandle, @R)
					P.X     = R.Left
					P.Y     = R.Top
					FWidth  = UnScaleX(R.Right - R.Left)
					FHeight = UnScaleY(R.Bottom - R.Top)
					ScreenToClient(GetParent(ControlHandle), @P)
					FLeft   = UnScaleX(P.X)
					FTop    = UnScaleY(P.Y)
					If bShift Then
						Select Case KeyCode
						Case Keys.Key_Left: FWidth = FWidth - FStepX1
						Case Keys.Key_Right: FWidth = FWidth + FStepX1
						Case Keys.Key_Up: FHeight = FHeight - FStepY1
						Case Keys.Key_Down: FHeight = FHeight + FStepY1
						End Select
					ElseIf ControlHandle <> Dialog Then
						Select Case KeyCode
						Case Keys.Key_Left: FLeft = FLeft - FStepX1
						Case Keys.Key_Right: FLeft = FLeft + FStepX1
						Case Keys.Key_Up: FTop = FTop - FStepY1
						Case Keys.Key_Down: FTop = FTop + FStepY1
						End Select
					End If
					MoveWindow(ControlHandle, ScaleX(FLeft), ScaleY(FTop), ScaleX(FWidth), ScaleY(FHeight), True)
					If OnModified Then OnModified(This, SelectedControls.Items[j], , , , FLeft, FTop, FWidth, FHeight)
				Next
				MoveDots(SelectedControl)
			#endif
		End Select
	End Sub
	
	#ifdef __USE_GTK__
		Function Designer.DotWndProc(widget As GtkWidget Ptr, Event As GdkEvent Ptr, user_data As Any Ptr) As Boolean
	#else
		Function Designer.DotWndProc(hDlg As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As LRESULT
	#endif
		Dim As My.Sys.Forms.Designer Ptr Des
		#ifdef __USE_GTK__
			Des = user_data
		#else
			Des = Cast(My.Sys.Forms.Designer Ptr, GetWindowLongPtr(hDlg, GWLP_USERDATA))
		#endif
		If Des Then
			With *Des
				#ifdef __USE_GTK__
					Select Case Event->type
				#else
					Select Case uMsg
					Case WM_PAINT
						Dim As PAINTSTRUCT Ps
						Dim As HDC FHDc = BeginPaint(hDlg, @Ps)
						Dim As HPEN Pen = CreatePen(PS_SOLID, 0, IIf(GetProp(hDlg, "@@@Control2") = .SelectedControl AndAlso Not .FLockControls, GetSysColor(COLOR_HIGHLIGHTTEXT), GetSysColor(COLOR_HIGHLIGHT)))
						Dim As HPEN PrevPen = SelectObject(FHDc, Pen)
						Dim As HBRUSH Brush = CreateSolidBrush(IIf(GetProp(hDlg, "@@@Control2") = .SelectedControl AndAlso Not .FLockControls, GetSysColor(COLOR_HIGHLIGHT), GetSysColor(COLOR_HIGHLIGHTTEXT)))
						Dim As HBRUSH PrevBrush = SelectObject(FHDc, Brush)
						Rectangle(FHDc, Ps.rcPaint.Left, Ps.rcPaint.Top, Ps.rcPaint.Right, Ps.rcPaint.Bottom)
						SelectObject(FHDc, PrevBrush)
						SelectObject(FHDc, PrevPen)
						EndPaint(hDlg, @Ps)
						DeleteObject(Pen)
						DeleteObject(Brush)
						Return 0
						'or use WM_ERASEBKGND message
				#endif
					#ifdef __USE_GTK__
					Case GDK_MOTION_NOTIFY
						.FOverControl = widget
					#else
					Case WM_MOUSEMOVE
						'.MouseMove(loWord(lParam), hiWord(lParam),wParam and &HFFFF )
						Select Case .IsDot(hDlg)
						Case 0 : SetCursor(crSizeNWSE)
						Case 1 : SetCursor(crSizeNS)
						Case 2 : SetCursor(crSizeNESW)
						Case 3 : SetCursor(crSizeWE)
						Case 4 : SetCursor(crSizeNWSE)
						Case 5 : SetCursor(crSizeNS)
						Case 6 : SetCursor(crSizeNESW)
						Case 7 : SetCursor(crSizeWE)
						End Select
						.FOverControl = hDlg
					#endif
					#ifdef __USE_GTK__
					Case GDK_BUTTON_PRESS
					#else
					Case WM_LBUTTONDOWN
					#endif
					#ifdef __USE_GTK__
						#ifdef __USE_GTK3__
							Dim As gint x1, y1
							gtk_widget_translate_coordinates(widget, .layoutwidget, Event->button.x, Event->button.y, @x1, @y1)
							.MouseDown(x1, y1, Event->button.state, g_object_get_data(G_OBJECT(widget), "@@@Control2"))
						#else
							Dim As Integer x, y, x1, y1
							GetPosToClient(widget, .FDialogParent, @x, @y)
							GetPosToClient(.layoutwidget, .FDialogParent, @x1, @y1)
							.MouseDown(Event->button.x + x - x1, Event->button.y + y - y1, Event->button.state, g_object_get_data(G_OBJECT(widget), "@@@Control2"))
						#endif
						Return True
					#else
						Dim P As ..Point
						P.X = LoWord(lParam)
						P.Y = HiWord(lParam)
						ScreenToClient .FDialog, @P
						.MouseDown(.UnScaleX(P.X), .UnScaleY(P.Y), wParam And &HFFFF )
						Return 0
					#endif
					#ifdef __USE_GTK__
					Case GDK_BUTTON_RELEASE
					#else
					Case WM_LBUTTONUP
					#endif
					#ifdef __USE_GTK__
						#ifdef __USE_GTK3__
							Dim As gint x1, y1
							gtk_widget_translate_coordinates(widget, .layoutwidget, Event->button.x, Event->button.y, @x1, @y1)
							.MouseUp(x1, y1, Event->button.state)
						#else
							Dim As Integer x, y, x1, y1
							GetPosToClient(widget, .FDialogParent, @x, @y)
							GetPosToClient(.layoutwidget, .FDialogParent, @x1, @y1)
							.MouseUp(Event->button.x + x - x1, Event->button.y + y - y1, Event->button.state)
						#endif
						Return True
					#else
						.MouseUp(.UnScaleX(LoWord(lParam)), .UnScaleY(HiWord(lParam)), wParam And &HFFFF )
						Return 0
						
					Case WM_NCHITTEST
						Return HTTRANSPARENT
					Case WM_KEYUP
					#endif
					#ifdef __USE_GTK__
					Case GDK_KEY_PRESS
					#else
					Case WM_KEYDOWN
					#endif
					#ifdef __USE_GTK__
						.KeyDown(Event->key.keyval, Event->key.state)
					#else
						.KeyDown(wParam, wParam And &HFFFF)
					#endif
				End Select
			End With
		End If
	End Function
	
	Sub Designer.RegisterDotClass(ByRef clsName As WString)
	End Sub
	
	#ifdef __USE_GTK__
		Property Designer.Dialog As GtkWidget Ptr
			Return FDialog
		End Property
	#else
		Property Designer.Dialog As HWND
			Return FDialog
		End Property
	#endif
	
	Sub Designer.PaintControl()
		If FDown AndAlso ((FCanInsert) OrElse (FCanMove = False AndAlso FCanSize = False)) Then
			#ifdef __USE_GTK__
				cairo_set_source_rgb(cr, 0.0, 0.0, 0.0)
				.cairo_rectangle(cr, FBeginX, FBeginY, FNewX - FBeginX, FNewY - FBeginY)
				cairo_stroke(cr)
			#endif
		End If
		'cairo_fill(cr)
	End Sub
	
	#ifdef __USE_GTK__
		Function Dialog_Draw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As Any Ptr) As Boolean
			Dim As Designer Ptr Des = data1
			Des->cr = cr
			Des->DrawThis
			Des->PaintControl
			Return False
		End Function
		
		Function Dialog_ExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As Any Ptr) As Boolean
			Dim As cairo_t Ptr cr = gdk_cairo_create(Event->window)
			Dialog_Draw(widget, cr, data1)
			cairo_destroy(cr)
			Return False
		End Function
		
		Property Designer.Dialog(value As GtkWidget Ptr)
			If value <> FDialog Then
				UnHook
				FDialog = value
				If value <> 0 Then
					gtk_widget_set_can_focus(layoutwidget, True)
					'CreateDots(gtk_widget_get_parent(FDialog))
					If layoutwidget Then
						#ifdef __USE_GTK3__
							g_signal_connect(layoutwidget, "draw", G_CALLBACK(@Dialog_Draw), @This)
						#else
							g_signal_connect(layoutwidget, "expose-event", G_CALLBACK(@Dialog_ExposeEvent), @This)
						#endif
						'				Dim As GdkDisplay Ptr display = gdk_display_get_default ()
						'				Dim As GdkDeviceManager Ptr device_manager = gdk_display_get_device_manager (display)
						'				Dim As GdkDevice Ptr device = gdk_device_manager_get_client_pointer (device_manager)
						'				gtk_widget_set_device_enabled(layoutwidget, device, false)
						If FActive Then Hook
						'InvalidateRect(FDialog, 0, true)
					End If
				End If
			End If
		End Property
	#else
		Property Designer.Dialog(value As HWND)
			If value <> FDialog Then
				UnHook
				FDialog = value
				If value <> 0 Then
					'CreateDots(GetParent(FDialog))
					If FActive Then Hook
					InvalidateRect(FDialog, 0, True)
				End If
			End If
		End Property
		
		Property Designer.TopMenuHeight As Integer
			Return FTopMenuHeight
		End Property
		
		Property Designer.TopMenuHeight(Value As Integer)
			FTopMenuHeight = Value
		End Property
	#endif
	
	Property Designer.Active As Boolean
		Return FActive
	End Property
	
	Property Designer.Active(value As Boolean)
		If value <> FActive Then
			FActive = value
			If value Then
				Hook
			Else
				UnHook
				HideDots
			End If
		End If
	End Property
	
	Property Designer.ChildCount As Integer
		Return FChilds.Count
	End Property
	
	Property Designer.ChildCount(value As Integer)
	End Property
	
	
	
	Property Designer.StepX As Integer
		Return FStepX
	End Property
	
	Property Designer.StepX(value As Integer)
		If value <> FStepX Then
			FStepX = value
			UpdateGrid
		End If
	End Property
	
	Property Designer.StepY As Integer
		Return FStepY
	End Property
	
	Property Designer.StepY(value As Integer)
		If value <> FStepY Then
			FStepY = value
			UpdateGrid
		End If
	End Property
	
	Property Designer.DotColor As Integer
		Return FDotColor
	End Property
	
	Property Designer.DotColor(value As Integer)
		If value <> FDotColor Then
			FDotColor = value
		End If
	End Property
	
	Property Designer.DotSize As Integer
		Return FDotSize
	End Property
	
	Property Designer.DotSize(value As Integer)
		FDotSize = value
	End Property
	
	Property Designer.SnapToGrid As Boolean
		Return FSnapToGrid
	End Property
	
	Property Designer.SnapToGrid(value As Boolean)
		FSnapToGrid = value
	End Property
	
	Property Designer.ShowGrid As Boolean
		Return FShowGrid
	End Property
	
	Property Designer.ShowGrid(value As Boolean)
		FShowGrid = value
	End Property
	
	Property Designer.ClassName As String
		Return FClass
	End Property
	
	Property Designer.ClassName(value As String)
		FClass = value
	End Property
	
	Operator Designer.cast As Any Ptr
		Return @This
	End Operator
	
	Constructor Designer(ParentControl As Control Ptr)
		FStepX      = 10
		FStepY      = 10
		FShowGrid   = True
		FActive     = True
		FSnapToGrid = 1
		FDotSize 	= 7
		FDotColor 	= clBlack
		FSelDotColor = clBlue
		Parent = ParentControl
		xdpi = Parent->xdpi
		ydpi = Parent->ydpi
		#ifdef __USE_GTK__
			FDialogParent = ParentControl->Handle
		#else
			FDialogParent = ParentControl->Handle
			FDotBrush   = CreateSolidBrush(FDotColor)
			FSelDotBrush   = CreateSolidBrush(FSelDotColor)
		#endif
		'FIsChild = True
		RegisterDotClass "DOT"
		WLet(FClassName, "Designer")
		'OnHandleIsAllocated = @HandleIsAllocated
		'ChangeStyle WS_CHILD, True
		'FDesignMode = True
		'Base.Child             = Cast(Control Ptr, @This)
		CreateDots(ParentControl)
		
		'mnuDesigner.ImagesList = @imgList '<m>
		ParentControl->ContextMenu = @mnuDesigner
		'		#ifdef __USE_GTK__
		'
		'		#else
		'			FPopupMenu  = CreatePopupMenu
		'			AppendMenu(FPopupMenu, MF_STRING, 10, @"Delete")
		'			AppendMenu(FPopupMenu, MF_SEPARATOR, -1, @"-")
		'			AppendMenu(FPopupMenu, MF_STRING, 12, @"Copy")
		'			AppendMenu(FPopupMenu, MF_STRING, 13, @"Cut")
		'			AppendMenu(FPopupMenu, MF_STRING, 14, @"Paste")
		'			AppendMenu(FPopupMenu, MF_SEPARATOR, -1, @"-")
		'			AppendMenu(FPopupMenu, MF_STRING, 16, @"Bring to Front")
		'			AppendMenu(FPopupMenu, MF_STRING, 17, @"Send to Back")
		'			AppendMenu(FPopupMenu, MF_SEPARATOR, -1, @"-")
		'			AppendMenu(FPopupMenu, MF_STRING, 19, @"Properties")
		'		#endif
	End Constructor
	
	Destructor Designer
		UnHook
		DestroyDots
		'If DeleteAllObjectsFunc <> 0 Then DeleteAllObjectsFunc()
		For i As Integer = 0 To FSymbols.Count - 1
			Dim As SymbolsType Ptr st = FSymbols.Item(i)
			If st Then
				If st->Handle Then DyLibFree(st->Handle)
				_Delete(st)
			End If
		Next
		FSymbols.Clear
		FLibs.Clear
		If pApp = 0 Then pApp = @VisualFBEditorApp
		WDeAllocate(FClassName)
		WDeAllocate(FTemp)
	End Destructor
End Namespace

mnuDesigner.Add(ML("Default event"), "Code", "Default", @PopupClick)
mnuDesigner.Add("-")
mnuDesigner.Add(ML("Lock Controls"), "LockControls", "LockControls", @PopupClick)
mnuDesigner.Add(ML("Copy") & !"\t Ctrl+C", "Copy", "Copy", @PopupClick)
mnuDesigner.Add(ML("Cut") & !"\t Ctrl+X", "Cut", "Cut", @PopupClick)
mnuDesigner.Add(ML("Paste") & !"\t Ctrl+V", "Paste", "Paste", @PopupClick)
mnuDesigner.Add(ML("Delete"), "", "Delete", @PopupClick)
mnuDesigner.Add("-", "", "DuplicateSeparator")
mnuDesigner.Add(ML("Duplicate") & !"\t Ctrl+D", "", "Duplicate", @mClick)
mnuDesigner.Add("-", "", "OrderSeparator")
mnuDesigner.Add(ML("Bring to Front"), "BringToFront", "BringToFront", @PopupClick)
mnuDesigner.Add(ML("Send to Back"), "SendToBack", "SendToBack", @PopupClick)
mnuDesigner.Add("-")
mnuDesigner.Add(ML("Properties"), "Property", "Properties", @PopupClick)
