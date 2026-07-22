'###############################################################################
'#  PagePanel.bas                                                              #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov                                                #
'###############################################################################

#include once "PagePanel.bi"
'#Include Once "Canvas.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function PagePanel.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "selectedpanel": Return SelectedPanel
			Case "selectedpanelindex": Return @FSelectedPanelIndex
			Case "tabindex": Return @FTabIndex
			Case "transparent": Return @FTransparent
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function PagePanel.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "designmode": DesignMode = QBoolean(Value)
					If FDesignMode Then 
							gtk_widget_set_can_focus(UpDownButton.widget, False)
							gtk_overlay_add_overlay(GTK_OVERLAY(overlaywidget), NumericUpDownControl.widget)
							gtk_overlay_add_overlay(GTK_OVERLAY(overlaywidget), UpDownButton.widget)
							g_signal_connect(overlaywidget, "get-child-position", G_CALLBACK(@Overlay_get_child_position), @This)
					End If
				Case "selectedpanel": SelectedPanel = Value
				Case "selectedpanelindex": 
					If FDesignMode Then
						NumericUpDownControl.Position = QInteger(Value)
					Else
						SelectedPanelIndex = QInteger(Value)
					End If
				Case "tabindex": TabIndex = QInteger(Value)
				Case "transparent": This.Transparent = QBoolean(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Sub PagePanel.MoveNumericUpDownControl
		NumericUpDownControl.Width = 70
		'NumericUpDownControl.ExtraMargins.Left = (ClientWidth - NumericUpDownControl.Width) / 2
		'NumericUpDownControl.ExtraMargins.Right = NumericUpDownControl.ExtraMargins.Left
		NumericUpDownControl.SetBounds (ClientWidth - NumericUpDownControl.Width) / 2, ClientHeight - NumericUpDownControl.Height, 70, NumericUpDownControl.Height
	End Sub
	
	Private Property PagePanel.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property PagePanel.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property PagePanel.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property PagePanel.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	
		Private Function PagePanel.Overlay_get_child_position(self As GtkOverlay Ptr, widget As GtkWidget Ptr, allocation As GdkRectangle Ptr, user_data As Any Ptr) As Boolean
			Dim As PagePanel Ptr pp = user_data
			If GTK_IS_BUTTON(widget) Then
				pp->UpDownButton.Width = 30
				allocation->x = pp->ScaleX((pp->ClientWidth - pp->NumericUpDownControl.Width) / 2 + pp->NumericUpDownControl.Width - 105)
				allocation->y = pp->ScaleY(pp->ClientHeight - 32)
				allocation->width = pp->ScaleX(35)
				allocation->height = pp->ScaleY(30)
			Else
				pp->NumericUpDownControl.Width = 150
				pp->NumericUpDownControl.Height = 34
				allocation->x = pp->ScaleX((pp->ClientWidth - pp->NumericUpDownControl.Width) / 2)
				allocation->y = pp->ScaleY(pp->ClientHeight - pp->NumericUpDownControl.Height)
				allocation->width = pp->ScaleX(pp->NumericUpDownControl.Width)
				allocation->height = pp->ScaleY(pp->NumericUpDownControl.Height)
			End If
			Return True
		End Function
	
	Private Sub PagePanel.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Property PagePanel.SelectedPanel As Control Ptr
		If FSelectedPanelIndex >= 0 AndAlso FSelectedPanelIndex <= FControlCount - 1 Then Return Controls[FSelectedPanelIndex]
		Return 0
	End Property
	
	Private Property PagePanel.SelectedPanel(Value As Control Ptr)
		If IndexOf(Value) > -1 Then
			SelectedPanelIndex = IndexOf(Value)
		End If
	End Property
	
	Private Property PagePanel.SelectedPanelIndex As Integer
		Return FSelectedPanelIndex
	End Property
	
	Private Property PagePanel.SelectedPanelIndex(Value As Integer)
		If Value >= -1 AndAlso Value <= FControlCount - 1 Then
			FSelectedPanelIndex = Value
				Dim As Boolean bVisible
				If FSelectedPanelIndex = -1 Then
					bVisible = False
				Else
					bVisible = True
					gtk_stack_set_visible_child(GTK_STACK(widget), Controls[FSelectedPanelIndex]->widget)
				End If
				For i As Integer = 0 To FControlCount - 1
					If Controls[i] = @NumericUpDownControl Then Continue For
					Controls[i]->Visible = bVisible
					If FDesignMode Then 
						If scrolledwidget Then
							If bVisible Then
									gtk_widget_show_all(scrolledwidget)
								If Value Then gtk_widget_queue_draw(scrolledwidget)
							Else
								gtk_widget_set_visible(scrolledwidget, bVisible)
							End If
						ElseIf widget Then
							gtk_widget_set_visible(widget, bVisible)
							If Value Then gtk_widget_queue_draw(widget)
						End If
					End If
				Next
		End If
	End Property
	
	Private Property PagePanel.Transparent As Boolean
		Return FTransparent
	End Property
	
	Private Property PagePanel.Transparent(Value As Boolean)
		FTransparent = Value
	End Property
	
	Private Operator PagePanel.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Sub PagePanel.Add(Ctrl As Control Ptr, Index As Integer = -1)
		Base.Add(Ctrl, Index)
		If FDesignMode Then
				NumericUpDownControl.MaxValue = Max(-1, ControlCount - 1)
				NumericUpDownControl.Position = ControlCount - 1
		End If
	End Sub
	
	Private Sub PagePanel.CreateWnd
		Base.CreateWnd
		#ifdef __USE_JNI__
			layoutview = FHandle
		#endif
	End Sub
	
	Private Sub PagePanel.GraphicChange(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Drawing.GraphicType, Image As Any Ptr, ImageType As Integer)
		With Sender
			If .Ctrl->Child Then
				#ifdef __USE_GTK__
				#else
					.Ctrl->Repaint
				#endif
			End If
		End With
	End Sub
	
	Private Sub PagePanel.NumericUpDownControl_Change(ByRef Sender As NumericUpDown)
		If OnSelChanging Then OnSelChanging(*Designer, This, Val(NumericUpDownControl.Text))
		SelectedPanelIndex = Val(NumericUpDownControl.Text)
		'NumericUpDownControl.BringToFront
		If OnSelChange Then OnSelChange(*Designer, This, FSelectedPanelIndex)
	End Sub
	
	Private Sub PagePanel.UpDownButton_Click(ByRef Sender As Control)
		Dim j As Integer = -1
		mnuShowPanel.Clear
		Var mnu = mnuShowPanel.Add(WStr(j) & ": " & Name, "", , Cast(NotifyEvent, @MenuItem_Click))
		mnu->Designer = @This
		For i As Integer = 0 To ControlCount - 1
			If Controls[i] = @NumericUpDownControl Then Continue For
			j = j + 1
			Var mnu = mnuShowPanel.Add(WStr(j) & ": " & Controls[i]->Name, "", , Cast(NotifyEvent, @MenuItem_Click))
			mnu->Designer = @This
		Next
			Dim p As My.Sys.Drawing.Point = Type(UpDownButton.Left, UpDownButton.Top + UpDownButton.Height)
		NumericUpDownControl.ClientToScreen p
		mnuContext.Popup p.X, p.Y
	End Sub
	
	Private Sub PagePanel.MenuItem_Click(ByRef Sender As MenuItem)
		NumericUpDownControl.Position = mnuShowPanel.IndexOf(@Sender) - 1
	End Sub
	
	Private Constructor PagePanel
		With This
			.Child          = @This
			.Canvas.Ctrl    = @This
			.Graphic.Ctrl   = @This
			.Graphic.OnChange = @GraphicChange
			NumericUpDownControl.Name = "PagePanel_NumericUpDownControl"
			'NumericUpDownControl.Align = DockStyle.alBottom
			#ifdef __USE_GTK__
				NumericUpDownControl.Width = 100
			#else
				NumericUpDownControl.Width = 70
			#endif
			NumericUpDownControl.Style = udHorizontal
			NumericUpDownControl.MinValue = -1
			NumericUpDownControl.Position = -1
			NumericUpDownControl.UpDownWidth = 28
			NumericUpDownControl.Designer = @This
			NumericUpDownControl.OnChange = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As NumericUpDown), @NumericUpDownControl_Change)
				UpDownButton.Caption = "V"
				UpDownButton.Designer = @This
				UpDownButton.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @UpDownButton_Click)
			mnuShowPanel.Caption = "Show Panel"
			mnuContext.ParentWindow = @This
			mnuContext.Add @mnuShowPanel
				#ifdef __USE_GTK3__
					widget = gtk_stack_new()
					overlaywidget = gtk_overlay_new()
					gtk_container_add(GTK_CONTAINER(overlaywidget), widget)
				#else
					widget = gtk_layout_new(NULL, NULL)
				#endif
				.RegisterClass "PagePanel", @This
			FTabIndex          = -1
			WLet(FClassName, "PagePanel")
			.Width       = 121
			.Height      = 41
			.ShowCaption = False
			MoveNumericUpDownControl
		End With
	End Constructor
	
	Private Destructor PagePanel
	End Destructor
End Namespace
