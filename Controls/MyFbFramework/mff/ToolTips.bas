'################################################################################
'#  ToolTips.bi                                                                 #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                     #
'################################################################################

#include once "ToolTips.bi"

Namespace My.Sys.Forms
		Function ToolTips.ActivateLink(label As GtkLabel Ptr, uri As gchar Ptr, user_data As gpointer) As Boolean
			Dim As ToolTips Ptr tt = user_data
			If tt <> 0 Then
				If tt->OnLinkClicked Then tt->OnLinkClicked(*tt->Designer, *tt, *uri)
			End If
			Return True
		End Function
	
	Private Sub ToolTips.Show
		If FText = "" Then FText = " "
			gtk_label_set_markup(GTK_LABEL(lblTooltip), ToUtf8(FText))
			gtk_window_move(GTK_WINDOW(winTooltip), FLeft, FTop)
			gtk_window_resize(GTK_WINDOW(winTooltip), 100, 25)
			gtk_widget_show_all(winTooltip)
	End Sub
	
	Private Sub ToolTips.Hide
			gtk_widget_hide(GTK_WIDGET(winTooltip))
	End Sub
	
	Private Operator ToolTips.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor ToolTips
		With This
			WLet(FClassName, "ToolTips")
			WLet(FClassAncestor, "tooltips_class32")
				winTooltip = gtk_window_new(GTK_WINDOW_POPUP)
				lblTooltip = gtk_label_new(NULL)
					gtk_widget_set_margin_left(lblTooltip, 1)
					gtk_widget_set_margin_top(lblTooltip, 1)
					gtk_widget_set_margin_right(lblTooltip, 1)
					gtk_widget_set_margin_bottom(lblTooltip, 1)
				gtk_container_add(GTK_CONTAINER(winTooltip), lblTooltip)
				g_signal_connect(lblTooltip, "activate-link", G_CALLBACK(@ActivateLink), @This)
			.Width        = 175
			.Height       = 21
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor ToolTips
	End Destructor
End Namespace
