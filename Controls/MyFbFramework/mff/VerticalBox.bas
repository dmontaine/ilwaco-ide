'###############################################################################
'#  VerticalBox.bi                                                           #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov                                                #
'###############################################################################

#include once "VerticalBox.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function VerticalBox.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "spacing": Return @FVerticalSpacing
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function VerticalBox.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "spacing": Spacing = QInteger(Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property VerticalBox.Spacing As Integer
		Return FVerticalSpacing
	End Property
	
	Private Property VerticalBox.Spacing(Value As Integer)
		FVerticalSpacing = Value
		#ifdef __USE_GTK__
			gtk_box_set_spacing(GTK_BOX(widget), FVerticalSpacing)
		#else
			RequestAlign
		#endif
	End Property
	
	Private Property VerticalBox.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property VerticalBox.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property VerticalBox.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property VerticalBox.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property VerticalBox.Text ByRef As WString
		Return WGet(FText)
	End Property
	
	Private Property VerticalBox.Text(ByRef Value As WString)
		Base.Text = Value
	End Property
		
	Private Sub VerticalBox.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Property VerticalBox.Visible As Boolean
		Return Base.Visible
	End Property
	
	Property VerticalBox.Visible(Value As Boolean)
		Base.Visible = Value
	End Property
	
	Private Operator VerticalBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor VerticalBox
		With This
			#ifdef __USE_GTK__
					widget = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0)
				.RegisterClass "VerticalBox", @This
			#endif
			FAutoSize = True
			Canvas.Ctrl    = @This
			.Child       = @This
			FTabIndex          = -1
			WLet(FClassName, "VerticalBox")
			.Width       = 121
			.Height      = 41
		End With
	End Constructor
	
	Private Destructor VerticalBox
	End Destructor
End Namespace
