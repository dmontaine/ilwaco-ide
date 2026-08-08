'###############################################################################
'#  LinkLabel.bi                                                               #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov                                                #
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

#include once "LinkLabel.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function LinkLabel.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "tabindex": Return @FTabIndex
			Case "text": Return FText.vptr
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function LinkLabel.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "tabindex": TabIndex = QInteger(Value)
			Case "text": Text = QWString(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property LinkLabel.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property LinkLabel.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property LinkLabel.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property LinkLabel.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property LinkLabel.Text ByRef As WString
		Return Base.Text
	End Property
	
	Private Property LinkLabel.Text(ByRef Value As WString)
		Base.Text = Value
			gtk_label_set_markup_with_mnemonic(GTK_LABEL(widget), ToUtf8(Replace(Value, "&", "_")))
	End Property
	
	
	Private Sub LinkLabel.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage Message
	End Sub
	
		Private Function LinkLabel.ActivateLink(label As GtkLabel Ptr, uri As gchar Ptr, user_data As gpointer) As Boolean
			Dim As LinkLabel Ptr lab = user_data
			Dim As Integer Action = 1
			If lab->OnLinkClicked Then lab->OnLinkClicked(*lab->Designer, *lab, 0, *uri, Action)
			If Action = 1 AndAlso *uri <> "" Then
				'ShellExecute(NULL, "open", uri, NULL, NULL, SW_SHOW)
				Return False
			Else
				Return True
			End If
		End Function
	
	Private Operator LinkLabel.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
	Private Constructor LinkLabel
		With This
			WLet(FClassName, "LinkLabel")
				widget = gtk_label_new("")
				scrolledwidget = gtk_scrolled_window_new(NULL, NULL)
				gtk_scrolled_window_set_policy(gtk_scrolled_window(scrolledwidget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
					gtk_container_add(gtk_container(scrolledwidget), widget)
				g_signal_connect(widget, "activate-link", G_CALLBACK(@ActivateLink), @This)
				.RegisterClass "LinkLabel", @This
			FTabIndex          = -1
			.Width        = 100
			.Height       = 32
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor LinkLabel
	End Destructor
End Namespace
