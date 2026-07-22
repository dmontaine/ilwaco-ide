'################################################################################
'#  UserControl.bi                                                              #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov                                                 #
'################################################################################

#include once "UserControl.bi"
'#Include Once "Canvas.bi"

Namespace My.Sys.Forms
	Private Sub UserControl.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator UserControl.Cast As Control Ptr
		Return Cast(Control Ptr, @This)
	End Operator
	
	Private Constructor UserControl
		With This
			#ifdef __USE_GTK__
				widget = gtk_layout_new(NULL, NULL)
				.RegisterClass "UserControl", @This
			#endif
			Canvas.Ctrl    = @This
			.Child       = @This
			WLet(FClassName, "UserControl")
			.Width       = 121
			.Height      = 41
		End With
	End Constructor
	
	Private Destructor UserControl
	End Destructor
End Namespace
