'################################################################################
'#  Form.bi                                                                     #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   TForm.bi                                                                   #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#   Version 1.0.0                                                              #
'#  Updated and added cross-platform                                            #
'#  by Xusinboy Bekchanov (2018-2019), Liu XiaLin (2020)                        #
'################################################################################

#include once "Form.bi"
#include once "Application.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function Form.ReadProperty(ByRef PropertyName As String) As Any Ptr
			FTempString = LCase(PropertyName)
			Select Case FTempString
			Case "activecontrol": Return FActiveControl
			Case "borderstyle": Return @FBorderStyle
			Case "cancelbutton": Return FCancelButton
			Case "caption": Return This.FText.vptr
			Case "defaultbutton": Return FDefaultButton
			Case "icon": Return @Icon
			Case "controlbox": Return @FControlBox
			Case "keypreview": Return @FKeyPreview
			Case "minimizebox": Return @FMinimizeBox
			Case "maximizebox": Return @FMaximizeBox
			Case "formstyle": Return @FFormStyle
			Case "menu": Return This.Menu
			Case "mainform": Return @FMainForm
			Case "modalresult": Return @ModalResult
			Case "opacity": Return @FOpacity
			Case "owner": Return FOwner
			Case "showintaskbar": Return @FShowInTaskbar
			Case "transparent": Return @FTransparent
			Case "transparentcolor": Return @FTransparentColor
			Case "windowstate": Return @FWindowState
			Case "startposition": Return @FStartPosition
			Case "graphic": Return Cast(Any Ptr, @This.Graphic)
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Form.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case "activecontrol": This.ActiveControl = 0
				Case "menu": This.Menu = 0
				Case "cancelbutton": This.CancelButton = 0
				Case "defaultbutton": This.DefaultButton = 0
				Case "owner": This.Owner = 0
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "activecontrol": This.ActiveControl = Cast(Control Ptr, Value)
				Case "borderstyle": This.BorderStyle = *Cast(FormBorderStyle Ptr, Value)
				Case "cancelbutton": This.CancelButton = Cast(Control Ptr, Value)
				Case "caption": This.Caption = QWString(Value)
				Case "defaultbutton": This.DefaultButton = Cast(Control Ptr, Value)
				Case "formstyle": This.FormStyle = *Cast(FormStyles Ptr, Value)
				Case "controlbox": This.ControlBox = QBoolean(Value)
				Case "keypreview": This.KeyPreview = QBoolean(Value)
				Case "minimizebox": This.MinimizeBox = QBoolean(Value)
				Case "maximizebox": This.MaximizeBox = QBoolean(Value)
				Case "icon": This.Icon = QWString(Value)
				Case "mainform": This.MainForm = QBoolean(Value)
				Case "menu": This.Menu = Cast(MainMenu Ptr, Value)
				Case "modalresult": This.ModalResult = QInteger(Value)
				Case "opacity": This.Opacity = QInteger(Value)
				Case "owner": This.Owner = Cast(Form Ptr, Value)
					Case "parentwidget": This.ParentWidget = Value
				Case "showintaskbar": This.ShowInTaskbar = QBoolean(Value)
				Case "text": This.Text = QWString(Value)
				Case "transparent": This.Transparent = QBoolean(Value)
				Case "transparentcolor": This.TransparentColor = QInteger(Value)
				Case "windowstate": This.WindowState = *Cast(WindowStates Ptr, Value)
				Case "startposition": This.StartPosition = *Cast(FormStartPosition Ptr, Value)
				Case "visible": This.Visible = QBoolean(Value)
				Case "graphic": This.Graphic = QWString(Value)
				Case "xdpi": This.xdpi = QSingle(Value)
				Case "ydpi": This.ydpi = QSingle(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property Form.ActiveControl As Control Ptr
		Return FActiveControl
	End Property
	
	Private Property Form.ActiveControl(Value As Control Ptr)
		FActiveControl = Value
		If FActiveControl Then FActiveControl->SetFocus
		If OnActiveControlChange Then OnActiveControlChange(*Designer, This)
	End Property
	
	Private Property Form.Owner As Form Ptr
		Return Cast(Form Ptr, FOwner)
	End Property
	
	Private Property Form.Owner(Value As Form Ptr)
		If Value <> FOwner Then
			FOwner = Value
		End If
	End Property
	
	Private Property Form.KeyPreview As Boolean
		Return FKeyPreview
	End Property
	
	Private Property Form.KeyPreview(Value As Boolean)
		FKeyPreview = Value
	End Property
	
		Private Property Form.ParentWidget As GtkWidget Ptr
			Return FParentWidget
		End Property
		
		Private Property Form.ParentWidget(Value As GtkWidget Ptr)
			If Not GTK_IS_BOX(widget) Then
				g_object_ref(box)
				gtk_container_remove(GTK_CONTAINER(WindowWidget), box)
				widget = box
				gtk_widget_set_size_request(widget, FWidth, FHeight)
					HeaderBarWidget = gtk_header_bar_new()
					gtk_widget_set_sensitive(HeaderBarWidget, False)
					gtk_header_bar_set_has_subtitle(GTK_HEADER_BAR(HeaderBarWidget), False)
					'gtk_widget_set_size_request(widget, FW, 1)
					gtk_header_bar_set_title(GTK_HEADER_BAR(HeaderBarWidget), ToUtf8(FText))
					'gtk_header_bar_set_show_close_button(gtk_header_bar(HeaderBarWidget), True)
					gtk_box_pack_start(GTK_BOX(widget), HeaderBarWidget, False, False, 0)
				Base.ParentWidget = Value
				BorderStyle = BorderStyle
			End If
		End Property
	
	Private Property Form.DefaultButton As Control Ptr
		Return FDefaultButton
	End Property
	
	Private Property Form.DefaultButton(Value As Control Ptr)
		FDefaultButton = Value
			If Value <> 0 Then
				gtk_widget_set_can_default(Value->widget, True)
				If GTK_IS_WINDOW(widget) Then
					gtk_window_set_default(GTK_WINDOW(widget), Value->widget)
				End If
				'gtk_widget_grab_default(Value->Widget)
			Else
				If GTK_IS_WINDOW(widget) Then
					gtk_window_set_default(GTK_WINDOW(widget), NULL)
				End If
			End If
		If FDefaultButton AndAlso UCase((*FDefaultButton).ClassName) = "COMMANDBUTTON" Then
			
		End If
	End Property
	
	Private Property Form.CancelButton As Control Ptr
		Return FCancelButton
	End Property
	
	Private Property Form.CancelButton(Value As Control Ptr)
		FCancelButton = Value
	End Property
	
	Private Property Form.MainForm As Boolean
		Return FMainForm
	End Property
	
	Private Property Form.MainForm(Value As Boolean)
		If Value <> FMainForm Then
			FMainForm = Value
			If pApp <> 0 Then
				If pApp->MainForm <> 0 Then Cast(Form Ptr, pApp->MainForm)->MainForm = False
					If GTK_IS_BOX(widget) Then Exit Property
				If FMainForm Then
					pApp->MainForm = @This
					App.MainForm = @This
				Else
					pApp->MainForm = 0
					App.MainForm = 0
				End If
			End If
		End If
	End Property
	
	Private Property Form.Menu As MainMenu Ptr
		Return FMenu
	End Property
	
	Private Property Form.Menu(Value As MainMenu Ptr)
		FMenu = Value
		If FMenu Then FMenu->ParentWindow = @This
	End Property
	
	Private Property Form.StartPosition As FormStartPosition
		Return FStartPosition
	End Property
	
	Private Property Form.StartPosition(Value As FormStartPosition)
		FStartPosition = Value
		If Not FDesignMode Then
				If GTK_IS_WINDOW(widget) Then
					Select Case FStartPosition
					Case 0: gtk_window_set_position(GTK_WINDOW(widget), GTK_WIN_POS_NONE) ' Manual
					Case 1, 4 ' CenterScreen, CenterParent
						If FStartPosition = 4 AndAlso FParent Then ' CenterParent
							gtk_window_set_position(GTK_WINDOW(widget), GTK_WIN_POS_CENTER_ON_PARENT)
							With *Cast(Control Ptr, FParent)
								gtk_window_move(GTK_WINDOW(widget), ScaleX(.Left + (.Width - This.FWidth) \ 2), ScaleY(.Top + (.Height - This.FHeight) \ 2))
							End With
						Else ' CenterScreen
							gtk_window_set_position(GTK_WINDOW(widget), GTK_WIN_POS_CENTER)
								gtk_window_move(GTK_WINDOW(widget), (gdk_screen_width() - ScaleX(This.FWidth)) \ 2, (gdk_screen_height() - ScaleY(This.FHeight)) \ 2)
						End If
					Case 2: gtk_window_set_position(GTK_WINDOW(widget), GTK_WIN_POS_MOUSE) ' DefaultLocation
					Case 3: 'gtk_window_set_default_size(gtk_window(widget), -1, -1) ' DefaultBounds
						gtk_window_resize(GTK_WINDOW(widget), 1000, 600)
					End Select
				End If
		End If
	End Property
	
	Private Property Form.Opacity As Integer
		Return FOpacity
	End Property
	
	Private Property Form.Opacity(Value As Integer)
		FOpacity = Value
				gtk_widget_set_opacity(widget, Value / 255.0)
	End Property
	
	Private Property Form.Transparent As Boolean
		Return FTransparent
	End Property
	
	Private Property Form.Transparent(Value As Boolean)
		FTransparent = Value
	End Property
	
	Private Property Form.TransparentColor As Integer
		Return FTransparentColor
	End Property
	
	Private Property Form.TransparentColor(Value As Integer)
		FTransparentColor = Value
	End Property
	
	Private Property Form.ControlBox As Boolean
		Return FControlBox
	End Property
	
	Private Property Form.ControlBox(Value As Boolean)
		FControlBox = Value
	End Property
	
	Private Property Form.MinimizeBox As Boolean
		Return FMinimizeBox
	End Property
	
	Private Property Form.MinimizeBox(Value As Boolean)
		FMinimizeBox = Value
	End Property
	
	Private Property Form.MaximizeBox As Boolean
		Return FMaximizeBox
	End Property
	
	Private Property Form.MaximizeBox(Value As Boolean)
		FMaximizeBox = Value
	End Property
	
	Private Property Form.BorderStyle As FormBorderStyle
		Return FBorderStyle
	End Property
	
	Private Property Form.BorderStyle(Value As FormBorderStyle)
		FBorderStyle = Value
			Select Case Value
			Case FormBorderStyle.None, FormBorderStyle.FixedToolWindow, FormBorderStyle.Fixed3D, FormBorderStyle.FixedSingle, FormBorderStyle.FixedDialog
				Dim As GdkGeometry hints
				hints.base_width = FWidth
				hints.base_height = FHeight
				hints.min_width = FWidth
				hints.min_height = FHeight
				hints.max_width = FWidth
				hints.max_height = FHeight
				hints.width_inc = 1
				hints.height_inc = 1
				If GTK_IS_WINDOW(widget) Then
						gtk_window_set_geometry_hints(GTK_WINDOW(widget), NULL, @hints, GDK_HINT_RESIZE_INC Or GDK_HINT_MIN_SIZE Or GDK_HINT_BASE_SIZE)
				End If
			Case FormBorderStyle.SizableToolWindow, FormBorderStyle.Sizable
				
			End Select
			Select Case Value
			Case FormBorderStyle.None
				If GTK_IS_WINDOW(widget) Then
					gtk_window_set_decorated(GTK_WINDOW(widget), False)
					gtk_window_set_type_hint(GTK_WINDOW(widget), GDK_WINDOW_TYPE_HINT_SPLASHSCREEN)
					'#ifndef __USE_GTK3__
					'	gtk_window_set_resizable(GTK_WINDOW(widget), False)
					'#endif
				Else
					gtk_widget_set_visible(HeaderBarWidget, False)
				End If
			Case FormBorderStyle.SizableToolWindow
				If GTK_IS_WINDOW(widget) Then
					gtk_window_set_decorated(GTK_WINDOW(widget), True)
					gtk_window_set_type_hint(GTK_WINDOW(widget), GDK_WINDOW_TYPE_HINT_DOCK)
					gtk_window_set_resizable(GTK_WINDOW(widget), True)
				Else
					gtk_widget_set_visible(HeaderBarWidget, True)
				End If
			Case FormBorderStyle.FixedToolWindow
				If GTK_IS_WINDOW(widget) Then
					gtk_window_set_decorated(GTK_WINDOW(widget), True)
					gtk_window_set_type_hint(GTK_WINDOW(widget), GDK_WINDOW_TYPE_HINT_DOCK)
					'#ifndef __USE_GTK3__
					'	gtk_window_set_resizable(GTK_WINDOW(widget), False)
					'#endif
				Else
					gtk_widget_set_visible(HeaderBarWidget, True)
				End If
			Case FormBorderStyle.Sizable
				If GTK_IS_WINDOW(widget) Then
					gtk_window_set_decorated(GTK_WINDOW(widget), True)
					gtk_window_set_type_hint(GTK_WINDOW(widget), GDK_WINDOW_TYPE_HINT_NORMAL)
					gtk_window_set_resizable(GTK_WINDOW(widget), True)
				Else
					gtk_widget_set_visible(HeaderBarWidget, True)
				End If
			Case FormBorderStyle.Fixed3D
				If GTK_IS_WINDOW(widget) Then
					gtk_window_set_decorated(GTK_WINDOW(widget), True)
					gtk_window_set_type_hint(GTK_WINDOW(widget), GDK_WINDOW_TYPE_HINT_DIALOG)
					'#ifndef __USE_GTK3__
					'	gtk_window_set_resizable(GTK_WINDOW(widget), False)
					'#endif
				Else
					gtk_widget_set_visible(HeaderBarWidget, True)
				End If
			Case FormBorderStyle.FixedSingle
				If GTK_IS_WINDOW(widget) Then
					gtk_window_set_decorated(GTK_WINDOW(widget), True)
					gtk_window_set_type_hint(GTK_WINDOW(widget), GDK_WINDOW_TYPE_HINT_DIALOG)
					'#ifndef __USE_GTK3__
					'	gtk_window_set_resizable(GTK_WINDOW(widget), False)
					'#endif
				Else
					gtk_widget_set_visible(HeaderBarWidget, True)
				End If
			Case FormBorderStyle.FixedDialog
				If GTK_IS_WINDOW(widget) Then
					gtk_window_set_decorated(GTK_WINDOW(widget), True)
					gtk_window_set_type_hint(GTK_WINDOW(widget), GDK_WINDOW_TYPE_HINT_DIALOG)
					'#ifndef __USE_GTK3__
					'	gtk_window_set_resizable(GTK_WINDOW(widget), False)
					'#endif
				Else
					gtk_widget_set_visible(HeaderBarWidget, True)
				End If
			End Select
	End Property
	
	Private Property Form.FormStyle As FormStyles
		Return FFormStyle
	End Property
	
		Private Function Form.Client_Draw(widget As GtkWidget Ptr, cr As cairo_t Ptr, data1 As Any Ptr) As Boolean
			If GTK_IS_LAYOUT(widget) Then
					Dim As Integer AllocatedWidth = gtk_widget_get_allocated_width(widget), AllocatedHeight = gtk_widget_get_allocated_height(widget)
				cairo_rectangle(cr, 0.0, 0.0, AllocatedWidth, AllocatedHeight)
				cairo_set_source_rgb(cr, 171 / 255.0, 171 / 255.0, 171 / 255.0)
				cairo_fill(cr)
			End If
			Return False
		End Function
		
		Private Function Form.Client_ExposeEvent(widget As GtkWidget Ptr, Event As GdkEventExpose Ptr, data1 As Any Ptr) As Boolean
			Return False
		End Function
	
	Private Property Form.FormStyle(Value As FormStyles)
		If Value = FFormStyle Then Exit Property
		FFormStyle = Value
		Select Case FFormStyle
		Case 0 'fsNormal
				If GTK_IS_WINDOW(widget) Then
					gtk_window_set_keep_above (GTK_WINDOW(widget), False)
				End If
		Case 1 'fsMDIForm
				FClient = gtk_layout_new(NULL, NULL)
					g_signal_connect(FClient, "draw", G_CALLBACK(@Client_Draw), @This)
				If GTK_IS_WIDGET(layoutwidget) Then gtk_container_add(GTK_CONTAINER(layoutwidget), FClient)
		Case 2 'fsMDIChild
		Case 3 'fsStayOnTop
				If GTK_IS_WINDOW(widget) Then
					gtk_window_set_keep_above (GTK_WINDOW(widget), True)
				End If
		End Select
	End Property
	
	Private Property Form.Parent As Control Ptr
		Return Cast(Control Ptr, @FParent)
	End Property
	
	Private Property Form.Parent(value As Control Ptr)
			If FormStyle = fsMDIChild OrElse FParentWidget = 0 Then
				Base.FParent = value
			Else
				Base.Parent = value
			End If
		If *value Is Form Then
			If Cast(Form Ptr, value)->FFormStyle = fsMDIForm Then
					ParentWidget = Cast(Form Ptr, value)->FClient
			End If
		End If
	End Property
	
	Private Property Form.ShowInTaskbar As Boolean
		Return FShowInTaskbar
	End Property
	
	Private Property Form.ShowInTaskbar(Value As Boolean)
		If FShowInTaskbar <> Value Then
			FShowInTaskbar = Value
		End If
	End Property
	
	Property Form.WindowState As WindowStates
			If GTK_IS_WINDOW(widget) Then
					If gdk_window_get_state(gtk_widget_get_window(widget)) And GDK_WINDOW_STATE_MAXIMIZED = GDK_WINDOW_STATE_MAXIMIZED Then
					FWindowState = WindowStates.wsMaximized
					ElseIf gdk_window_get_state(gtk_widget_get_window(widget)) And GDK_WINDOW_STATE_ICONIFIED = GDK_WINDOW_STATE_ICONIFIED Then
						FWindowState = WindowStates.wsMinimized
				Else
					FWindowState = WindowStates.wsNormal
				End If
			End If
		Return FWindowState
	End Property
	
	Private Property Form.WindowState(Value As WindowStates)
		FWindowState = Value
			If GTK_IS_WINDOW(widget) Then
				gtk_window_deiconify(GTK_WINDOW(widget))
				gtk_window_unmaximize(GTK_WINDOW(widget))
				Select Case FWindowState
				Case WindowStates.wsMinimized:  gtk_window_iconify(GTK_WINDOW(widget))
				Case WindowStates.wsMaximized:  gtk_window_maximize(GTK_WINDOW(widget))
				Case WindowStates.wsNormal:
				Case WindowStates.wsHide:       gtk_widget_hide(widget)
				End Select
			End If
	End Property
	
	Private Property Form.Caption ByRef As WString
		Return Text
	End Property
	
	Private Property Form.Caption(ByRef Value As WString)
		Text = Value
	End Property
	
	Private Property Form.Text ByRef As WString
		Return Base.Text
	End Property
	
	Private Property Form.Text(ByRef Value As WString)
		Base.Text = Value
			If GTK_IS_WINDOW(widget) Then
				If Value = "" Then
					gtk_window_set_title(GTK_WINDOW(widget), !"\0")
				Else
					gtk_window_set_title(GTK_WINDOW(widget), ToUtf8(Value))
				End If
			ElseIf HeaderBarWidget Then
					If Value = "" Then
						gtk_header_bar_set_title(GTK_HEADER_BAR(HeaderBarWidget), !"\0")
					Else
						gtk_header_bar_set_title(GTK_HEADER_BAR(HeaderBarWidget), ToUtf8(Value))
					End If
			End If
	End Property
	
	Private Property Form.Enabled As Boolean
		Return Base.Enabled
	End Property
	
	Private Property Form.Enabled(Value As Boolean)
		Base.Enabled = Value
	End Property
	
	Private Sub Form.ActiveControlChanged(ByRef Sender As Control)
		If Sender.Child Then
			With QForm(Sender.Child)
				If .OnActiveControlChange Then .OnActiveControlChange(*QForm(Sender.Child).Designer, QForm(Sender.Child))
			End With
		End If
	End Sub
	
	
	
		Private Function Form.deactivate_cb(ByVal user_data As gpointer) As gboolean
			pApp->FDeactivated = False
			If pApp->FActivated Then
				pApp->FActivated = False
			Else
				Dim As Form Ptr frm = user_data
				If frm->OnDeActivateApp Then frm->OnDeActivateApp(*frm->Designer, *frm)
			End If
			Return False
		End Function
	
	
	Private Sub Form.ProcessMessage(ByRef msg As Message)
		Dim As Integer Action = 1
			Select Case msg.Event->type
			Case GDK_DELETE
				If OnClose Then OnClose(*Designer, This, Action)
				Select Case Action
				Case 0
					msg.Result = -1
				Case 1
					If MainForm Then
							gtk_main_quit()
							'End 0
					Else
						'#ifdef __USE_GTK3__
						
						'#else
						If GTK_IS_WINDOW(widget) Then
							If gtk_window_get_modal (GTK_WINDOW(widget)) Then
								gtk_main_quit()
							End If
						End If
						gtk_widget_hide(widget)
						FCreated = False
						msg.Result = -1
						'#endif
					End If
				Case 2
					msg.Result = -1
				End Select
			Case GDK_FOCUS_CHANGE
				If Cast(GdkEventFocus Ptr, msg.Event)->in Then
					If OnActivateApp OrElse OnDeActivateApp Then
						If pApp Then
							pApp->FActivated = True
							If OnActivateApp AndAlso CInt(pApp->FDeactivated = False) Then OnActivateApp(*Designer, This)
						End If
					End If
					pApp->ActiveForm = @This
					If OnActivate Then OnActivate(*Designer, This)
				Else
					If OnDeActivate Then OnDeActivate(*Designer, This)
					If OnActivateApp OrElse OnDeActivateApp Then
						If pApp Then
							pApp->FDeactivated = True
							g_timeout_add(500, Cast(GSourceFunc, @deactivate_cb), @This)
						End If
					End If
				End If
			Case GDK_WINDOW_STATE
				
			Case Else
				
			End Select
		Base.ProcessMessage(msg)
	End Sub
	
	'David Change
	Private Sub Form.BringToFront
	End Sub
	
	Private Sub Form.SendToBack
	End Sub
	
	Private Property Form.Visible() As Boolean
		Return FVisible
	End Property
	
	Private Property Form.Visible(Value As Boolean)
		FVisible = Value
		If Value Then
			Show
		Else
			Hide
		End If
	End Property
	
	Private Sub Form.ShowItems(Ctrl As Control Ptr)
			If CInt(Ctrl->FVisible) OrElse CInt(GTK_IS_NOTEBOOK(gtk_widget_get_parent(Ctrl->widget))) Then
				If Ctrl->box Then gtk_widget_show(Ctrl->box)
				If Ctrl->scrolledwidget Then gtk_widget_show(Ctrl->scrolledwidget)
				If Ctrl->eventboxwidget Then gtk_widget_show(Ctrl->eventboxwidget)
				If Ctrl->layoutwidget Then gtk_widget_show(Ctrl->layoutwidget)
				If Ctrl->containerwidget Then gtk_widget_show(Ctrl->containerwidget)
					If Ctrl->widget Then If Not *Ctrl Is ContainerControl Then gtk_widget_show_all(Ctrl->widget) Else gtk_widget_show(Ctrl->widget)
			End If
			For i As Integer = 0 To Ctrl->ControlCount - 1
				ShowItems Ctrl->Controls[i]
			Next
	End Sub
	
	Private Sub Form.HideItems(Ctrl As Control Ptr)
			If Not (CInt(Ctrl->FVisible) OrElse CInt(GTK_IS_NOTEBOOK(gtk_widget_get_parent(Ctrl->widget)))) Then
				If Ctrl->box Then gtk_widget_hide(Ctrl->box)
				If Ctrl->scrolledwidget Then gtk_widget_hide(Ctrl->scrolledwidget)
				If Ctrl->eventboxwidget Then gtk_widget_hide(Ctrl->eventboxwidget)
				If Ctrl->layoutwidget Then gtk_widget_hide(Ctrl->layoutwidget)
				If Ctrl->containerwidget Then gtk_widget_hide(Ctrl->containerwidget)
				If Ctrl->widget Then gtk_widget_hide(Ctrl->widget)
			End If
			For i As Integer = 0 To Ctrl->ControlCount - 1
				HideItems Ctrl->Controls[i]
			Next
	End Sub
	
	Private Sub Form.Show
			RequestAlign
			If widget Then
				If Not FCreated Then
					If OnCreate Then OnCreate(*Designer, This)
					FCreated = True
				End If
				If Not FFormCreated Then
					FFormCreated = True
					If FStartPosition <> 0 Then StartPosition = Cast(FormStartPosition, FStartPosition)
					If Icon.ResName <> "" Then
						If GTK_IS_WINDOW(widget) Then
							Dim As GList Ptr list1 = NULL
							Dim As GError Ptr gerr
							Dim As GdkPixbuf Ptr gtkicon
							If Icon.ResName <> "" Then
								gtkicon = gdk_pixbuf_new_from_file_at_size(ToUtf8(Icon.ResName), 16, 16, @gerr)
								If gtkicon <> 0 Then list1 = g_list_append(list1, gtkicon)
								g_error_free(gerr)
								gerr = 0
								gtkicon = gdk_pixbuf_new_from_file_at_size(ToUtf8(Icon.ResName), 48, 48, @gerr)
								If gtkicon <> 0 Then list1 = g_list_append(list1, gtkicon)
								g_error_free(gerr)
								gerr = 0
								gtk_window_set_icon_list(GTK_WINDOW(widget), list1)
							End If
						End If
					End If
					If GTK_IS_WINDOW(widget) Then
						'Select Case FBorderStyle
						'Case FormBorderStyle.None, FormBorderStyle.FixedToolWindow, FormBorderStyle.Fixed3D, FormBorderStyle.FixedSingle, FormBorderStyle.FixedDialog
						'	Dim As GdkGeometry hints
						'	hints.base_width = FWidth
						'	hints.base_height = FHeight
						'	hints.min_width = FWidth
						'	hints.min_height = FHeight
						'	hints.max_width = FWidth
						'	hints.max_height = FHeight
						'	hints.width_inc = 1
						'	hints.height_inc = 1
						'	#ifndef __USE_GTK4__
						'	gtk_window_set_geometry_hints(GTK_WINDOW(widget), NULL, @hints, GDK_HINT_RESIZE_INC Or GDK_HINT_MIN_SIZE Or GDK_HINT_MAX_SIZE Or GDK_HINT_BASE_SIZE)
						'   #endif
						'Case FormBorderStyle.SizableToolWindow, FormBorderStyle.Sizable
						'
						'End Select
						If Constraints.Width <> 0 OrElse Constraints.Height <> 0 Then
							Dim As GdkGeometry hints
							If Constraints.Width <> 0 Then
								hints.base_width = Constraints.Width
								hints.min_width = Constraints.Width
								hints.max_width = Constraints.Width
								hints.width_inc = 1
							Else
								hints.base_width = FWidth
								hints.min_width = 0
									hints.max_width = gdk_screen_get_width(gtk_widget_get_screen(widget))
								hints.width_inc = 1
							End If
							If Constraints.Height <> 0 Then
								hints.base_height = Constraints.Height
								hints.min_height = Constraints.Height
								hints.max_height = Constraints.Height
								hints.height_inc = 1
							Else
								hints.base_height = FHeight
								hints.min_height = 0
									hints.max_height = gdk_screen_get_height(gtk_widget_get_screen(widget))
								hints.height_inc = 1
							End If
								gtk_window_set_geometry_hints(GTK_WINDOW(widget), NULL, @hints, GDK_HINT_RESIZE_INC Or GDK_HINT_MIN_SIZE Or GDK_HINT_MAX_SIZE Or GDK_HINT_BASE_SIZE)
						End If
						Select Case FBorderStyle
						Case FormBorderStyle.None
							'#ifndef __USE_GTK3__
							'	gtk_window_set_resizable(GTK_WINDOW(widget), False)
							'#endif
						Case FormBorderStyle.SizableToolWindow
							gtk_window_set_resizable(GTK_WINDOW(widget), True)
						Case FormBorderStyle.FixedToolWindow
							'#ifndef __USE_GTK3__
							'	gtk_window_set_resizable(GTK_WINDOW(widget), False)
							'#endif
						Case FormBorderStyle.Sizable
							gtk_window_set_resizable(GTK_WINDOW(widget), True)
						Case FormBorderStyle.Fixed3D
							'#ifndef __USE_GTK3__
							'	gtk_window_set_resizable(GTK_WINDOW(widget), False)
							'#endif
						Case FormBorderStyle.FixedSingle
							'#ifndef __USE_GTK3__
							'	gtk_window_set_resizable(GTK_WINDOW(widget), False)
							'#endif
						Case FormBorderStyle.FixedDialog
							'#ifndef __USE_GTK3__
							'	gtk_window_set_resizable(GTK_WINDOW(widget), False)
							'#endif
						End Select
					End If
				Else
					StartPosition = Manual
				End If
				'If Menu Then gtk_widget_show_all(Menu->widget)
				'				gtk_widget_show(ImageWidget)
				'				If box Then gtk_widget_show(box)
				'				If layoutwidget Then gtk_widget_show(layoutwidget)
				'				gtk_widget_show(widget)
					gtk_widget_show_all(widget)
					'ShowItems @This
					FVisible = True
					HideItems @This
				'Requests @This
			End If
		If OnShow Then OnShow(*Designer, This)
	End Sub
	
	Private Sub Form.Show(ByRef OwnerForm As Form)
		This.FParent = @OwnerForm
			If GTK_IS_WINDOW(widget) AndAlso GTK_IS_WINDOW(OwnerForm.widget) Then
				gtk_window_set_transient_for(GTK_WINDOW(widget), GTK_WINDOW(OwnerForm.widget))
			End If
		This.Show
	End Sub
	
	#ifndef Form_ShowModal_Off
		Private Function Form.ShowModal(ByRef OwnerForm As Form) As Integer
			This.FParent = @OwnerForm
			CenterToParent
			Return This.ShowModal()
		End Function
		
		Private Function Form.ShowModal() As Integer
				If pApp AndAlso pApp->ActiveForm <> 0 Then gtk_window_set_transient_for(GTK_WINDOW(widget), GTK_WINDOW(pApp->ActiveForm->widget))
				gtk_window_set_modal(GTK_WINDOW(widget), True)
				This.Show
				'If OnShow Then OnShow(This)
				gtk_main()
				gtk_window_set_modal(GTK_WINDOW(widget), False)
			Function = ModalResult
		End Function
	#endif
	
	Private Sub Form.Hide
			If widget Then
					If gtk_widget_is_visible(widget) Then
					If OnHide Then OnHide(*Designer, This)
					If GTK_IS_WINDOW(widget) Then
						If gtk_window_get_modal (GTK_WINDOW(widget)) Then
							gtk_main_quit()
						End If
					End If
					gtk_widget_hide(widget)
				End If
			End If
	End Sub
	
	Private Sub Form.Maximize
			If GTK_IS_WINDOW(widget) Then
				gtk_window_maximize(GTK_WINDOW(widget))
			End If
	End Sub
	
	Private Sub Form.Minimize
			If GTK_IS_WINDOW(widget) Then
				gtk_window_iconify(GTK_WINDOW(widget))
			End If
	End Sub
	
	Private Sub Form.CloseForm
			'#ifdef __USE_GTK3__
			'	gtk_window_close(Gtk_Window(widget))
			'#else
			Dim As Integer Action = 1
			If OnClose Then OnClose(*Designer, This, Action)
			Select Case Action
			Case 0
			Case 1
				If MainForm Then
					If GTK_IS_WIDGET(widget) Then
							gtk_widget_destroy(widget)
					End If
					gtk_main_quit()
				Else
					If GTK_IS_WINDOW(widget) Then
						If gtk_window_get_modal (GTK_WINDOW(widget)) Then
							gtk_main_quit()
						End If
					End If
					gtk_widget_hide(widget)
				End If
			Case 2
			End Select
			'#endif
	End Sub
	
	Private Sub Form.CenterToParent()
		If FParent Then
			With *Cast(Control Ptr, FParent)
					If GTK_IS_WINDOW(widget) Then
						gtk_window_set_position(GTK_WINDOW(widget), GTK_WIN_POS_CENTER)
						gtk_window_move(GTK_WINDOW(widget), ScaleX(.Left + (.Width - This.FWidth) \ 2), ScaleY(.Top + (.Height - This.FHeight) \ 2))
					End If
			End With
		End If
	End Sub
	
	Private Sub Form.CenterToScreen(ByVal ScrLeft As Integer = 0, ByVal ScrTop As Integer = 0, ByVal ScrWidth As Integer = 0, ByVal ScrHeight As Integer = 0)
			If GTK_IS_WINDOW(widget) Then
					gtk_window_move(GTK_WINDOW(widget), (gdk_screen_width() - ScaleX(This.FWidth)) \ 2, (gdk_screen_height() - ScaleY(This.FHeight)) \ 2)
			End If
			'gtk_window_set_position(gtk_window(widget), GTK_WIN_POS_CENTER) '_ALWAYS
	End Sub
	
	Private Function Form.EnumMenuItems(Item As MenuItem) As Boolean
		FMenuItems.Add Item
		For i As Integer = 0 To Item.Count -1
			EnumMenuItems *Item.Item(i)
		Next i
		Return True
	End Function
	
	Private Sub Form.GetMenuItems
		FMenuItems.Clear
		If This.Menu Then
			For i As Integer = 0 To This.Menu->Count -1
				EnumMenuItems *This.Menu->Item(i)
			Next i
		End If
	End Sub
	
	Private Sub Form.GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
		With Sender
			If .Ctrl->Child Then
					If GTK_IS_IMAGE(QForm(.Ctrl->Child).ImageWidget) Then
						Select Case ImageType
						Case 0
							gtk_image_set_from_pixbuf(GTK_IMAGE(QForm(.Ctrl->Child).ImageWidget), .Bitmap.Handle)
						Case 1
							gtk_image_set_from_pixbuf(GTK_IMAGE(QForm(.Ctrl->Child).ImageWidget), .Icon.Handle)
						End Select
					End If
			End If
		End With
	End Sub
	
	Private Operator Form.Cast As Control Ptr
		Return @This
	End Operator
	
	Private Sub Form.IconChanged(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.Icon)
		With *Cast(Form Ptr, Sender.Graphic)
		End With
	End Sub
	
	Private Constructor Form
			ImageWidget = gtk_image_new()
			WindowWidget = gtk_window_new(GTK_WINDOW_TOPLEVEL)
			widget = WindowWidget
			'gtk_window_set_policy(GTK_WINDOW(widget), true, false, false)
			This.RegisterClass "Form", @This
			If GTK_IS_WIDGET(layoutwidget) Then gtk_layout_put(GTK_LAYOUT(layoutwidget), ImageWidget, 0, 0)
		Text = "Form"
		FBorderStyle   = 3
		FWindowState   = 1
		FControlBox = True
		FMinimizeBox = True
		FMaximizeBox = True
		FShowInTaskbar = True
		FOpacity = 255
		FTransparentColor = -1
		Canvas.Ctrl    = @This
		Graphic.Ctrl = @This
		Graphic.OnChange = @GraphicChange
		Icon.Graphic = @This
		Icon.Changed = @IconChanged
		With This
			.Child             = @This
			WLet(FClassName, "Form")
			.OnActiveControlChanged = @ActiveControlChanged
				.Width             = 350
				.Height            = 300
				WLet(FClassAncestor, "GtkWindow")
			.StartPosition = DefaultLocation
		End With
		If pApp->MainForm = 0 Then
			pApp->MainForm = @This
			FMainForm = True
			
		End If
		#ifdef __AUTOMATE_CREATE_FORM__
			CreateWnd
		#endif
	End Constructor
	
	Private Destructor Form
		'		If OnFree Then OnFree(This)
		'		#ifndef __USE_GTK__
		'			If FHandle Then FreeWnd
		'		#endif
		This.Menu = 0
		FMenuItems.Clear
		'UnregisterClass ClassName, GetModuleHandle(NULL)
	End Destructor
End Namespace
