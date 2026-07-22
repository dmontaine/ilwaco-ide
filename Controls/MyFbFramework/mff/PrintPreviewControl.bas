'###############################################################################
'#  PrintPreviewControl.bas                                                           #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov                                                #
'###############################################################################

#include once "PrintPreviewControl.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function PrintPreviewControl.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "currentpage": Return @FCurrentPage
			Case "document": Return Document
			Case "orientation": Return @FOrientation
			Case "pagelength": Return @FPageLength
			Case "pagewidth": Return @FPageWidth
			Case "tabindex": Return @FTabIndex
			Case "zoom": Return @FZoom
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function PrintPreviewControl.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "currentpage": CurrentPage = QInteger(Value)
			Case "document": Document = Value
			Case "orientation": Orientation = *Cast(PrinterOrientation Ptr, Value)
			Case "pagelength": PageLength = QInteger(Value)
			Case "pagewidth": PageWidth = QInteger(Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case "zoom": Zoom = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property PrintPreviewControl.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property PrintPreviewControl.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property PrintPreviewControl.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property PrintPreviewControl.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property PrintPreviewControl.Orientation As PrinterOrientation
		Return FOrientation
	End Property
	
	Private Property PrintPreviewControl.Orientation(Value As PrinterOrientation)
		FOrientation = Value
		Document->PrinterSettings.Orientation = Value
		Document->Repaint
		SetScrollsInfo
		Repaint
	End Property
	
	Private Property PrintPreviewControl.PageLength As Integer
		Return FPageLength
	End Property
	
	Private Property PrintPreviewControl.PageLength(Value As Integer)
		FPageLength = Value
		Document->Repaint
		SetScrollsInfo
		Repaint
	End Property
	
	Private Property PrintPreviewControl.PageWidth As Integer
		Return FPageWidth
	End Property
	
	Private Property PrintPreviewControl.PageWidth(Value As Integer)
		FPageWidth = Value
		Document->Repaint
		SetScrollsInfo
		Repaint
	End Property
	
	Private Property PrintPreviewControl.PageSize As Integer
		Return FPageSize
	End Property
	
	Private Property PrintPreviewControl.PageSize(Value As Integer)
		FPageSize = Value
		Document->PrinterSettings.PageSize = Value
		Document->Repaint
		SetScrollsInfo
		Repaint
	End Property
	
	Private Property PrintPreviewControl.CurrentPage As Integer
		Return FCurrentPage
	End Property
	
	Private Property PrintPreviewControl.CurrentPage(Value As Integer)
		FCurrentPage = Value
		SetScrollsInfo
		Repaint
	End Property
	
	Private Property PrintPreviewControl.Zoom As Integer
		Return FZoom
	End Property
	
	Private Property PrintPreviewControl.Zoom(Value As Integer)
		FZoom = Value
		SetScrollsInfo
		Repaint
	End Property
	
	Private Sub PrintPreviewControl.SetScrollsInfo
	End Sub
	
	
	Private Sub PrintPreviewControl.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator PrintPreviewControl.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor PrintPreviewControl
		#ifdef __USE_GTK__
			widget = gtk_scrolled_window_new(NULL, NULL)
			gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(widget), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC)
			'g_signal_connect(widget, "value-changed", G_CALLBACK(@Range_ValueChanged), @This)
			This.RegisterClass "PrintPreviewControl", @This
		#endif
		FTabIndex       = -1
		Canvas.Ctrl = @This
		DefaultDocument.Name = "DefaultDocument"
		Document = @DefaultDocument
		FOrientation = PrinterOrientation.poPortait
		'Dim As UString DefaultPrinter = Document.PrinterSettings.GetDefaultPrinterDriver
		'If DefaultPrinter > "" Then
		'	This.PrinterName = DefaultPrinter
		'	' Set the default values for the printer
		'	This.Copies = 1
		'	This.Orientation = DMORIENT_PORTRAIT
		'	This.PaperWidth = 8.5
		'	This.PaperHeight = 11
		'End If
		FTabIndex = -1
		FTabStop = True
		With This
			.Child      = @This
			WLet(FClassName, "PrintPreviewControl")
			FHorizontalArrowChangeSize = 10
			FVerticalArrowChangeSize = 10
			FHorizontalMouseWheelChangeSize = 30
			FVerticalMouseWheelChangeSize = 30
			FCurrentPage = 1
			.Width      = 121
			.Height     = 41
		End With
	End Constructor
	
	Private Destructor PrintPreviewControl
	End Destructor
End Namespace
