'###############################################################################
'#  GroupBox.bi                                                                #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TGroupBox.bi                                                              #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "GroupBox.bi"

Namespace My.Sys.Forms
	Property GroupBox.Caption ByRef As WString
		Return Text
	End Property
	
	Property GroupBox.Caption(ByRef Value As WString)
		Text = Value
	End Property
	
	Property GroupBox.Text ByRef As WString
		#ifdef __USE_GTK__
			FText = WStr(gtk_frame_get_label(GTK_FRAME(widget)))
			Return *FText.vptr
		#else
			Return Base.Text
		#endif
	End Property
	
	Property GroupBox.Text(ByRef Value As WString)
		#ifdef __USE_GTK__
			If widget Then gtk_frame_set_label(GTK_FRAME(widget), ToUtf8(Value))
		#else
			Base.Text = Value
		#endif
	End Property
	
	Property GroupBox.ParentColor As Boolean
		Return FParentColor
	End Property
	
	Property GroupBox.ParentColor(Value As Boolean)
		FParentColor = Value
		If FParentColor Then
			This.BackColor = This.Parent->BackColor
			Invalidate
		End If
	End Property
	
	
	Sub GroupBox.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Operator GroupBox.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Constructor GroupBox
		With This
			.Child       = @This
			#ifdef __USE_GTK__
				widget = gtk_frame_new("")
				.RegisterClass "GroupBox", @This
			#else
				.RegisterClass "GroupBox", "Button"
				.ChildProc   = @WndProc
			#endif
			WLet(FClassName, "GroupBox")
			WLet(FClassAncestor, "Button")
			FTabStop           = True
			.Width       = 121
			.Height      = 51
		End With
	End Constructor
	
	Destructor GroupBox
	End Destructor
End Namespace
