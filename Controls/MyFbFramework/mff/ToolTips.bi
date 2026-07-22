'################################################################################
'#  ToolTips.bi                                                                 #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                     #
'################################################################################

#include once "Control.bi"

Namespace My.Sys.Forms
	#define QToolTips(__Ptr__) (*Cast(ToolTips Ptr, __Ptr__))
	
	'Represents a small rectangular pop-up window that displays a brief description of a control's purpose when the user rests the pointer on the control (Windows, Linux).
	Private Type ToolTips Extends Control
	Private:
			Declare Static Function ActivateLink(Label As GtkLabel Ptr, uri As gchar Ptr, user_data As gpointer) As Boolean
			Dim As GtkWidget Ptr winTooltip
			lblTooltip As GtkWidget Ptr
	Public:
		'Displays the ToolTip to the user (Windows only).
		Declare Virtual Sub Show
		'Conceals the ToolTip from the user (Windows only).
		Declare Virtual Sub Hide
		Declare Operator Cast As Control Ptr
		Declare Constructor
		Declare Destructor
		OnLinkClicked As Sub(ByRef Designer As My.Sys.Object, ByRef Sender As ToolTips, ByRef link As WString)
	End Type
End Namespace

#ifndef __USE_MAKE__
	#include once "ToolTips.bas"
#endif
