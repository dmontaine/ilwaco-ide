'###############################################################################
'#  HorizontalBox.bi                                                           #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov                                                #
'###############################################################################

#include once "HorizontalBox.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function HorizontalBox.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "spacing": Return @FHorizontalSpacing
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function HorizontalBox.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
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
	
	Private Property HorizontalBox.Spacing As Integer
		Return FHorizontalSpacing
	End Property
	
	Private Property HorizontalBox.Spacing(Value As Integer)
		FHorizontalSpacing = Value
			gtk_box_set_spacing(GTK_BOX(widget), FHorizontalSpacing)
	End Property
	
	Private Property HorizontalBox.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property HorizontalBox.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property HorizontalBox.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property HorizontalBox.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property HorizontalBox.Text ByRef As WString
		Return WGet(FText)
	End Property
	
	Private Property HorizontalBox.Text(ByRef Value As WString)
		Base.Text = Value
	End Property
		
	Private Sub HorizontalBox.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Property HorizontalBox.Visible As Boolean
		Return Base.Visible
	End Property
	
	Property HorizontalBox.Visible(Value As Boolean)
		Base.Visible = Value
	End Property
	
	Private Operator HorizontalBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor HorizontalBox
		With This
					widget = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0)
				.RegisterClass "HorizontalBox", @This
			FAutoSize = True
			Canvas.Ctrl    = @This
			.Child       = @This
			FTabIndex          = -1
			WLet(FClassName, "HorizontalBox")
			.Width       = 121
			.Height      = 41
		End With
	End Constructor
	
	Private Destructor HorizontalBox
	End Destructor
End Namespace
