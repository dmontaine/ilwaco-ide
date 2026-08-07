'###############################################################################
'#  Component.bi                                                               #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                    #
'###############################################################################

#include once "Object.bi"
#include once "List.bi"

Namespace My.Sys.ComponentModel
	#define QComponent(__Ptr__) (*Cast(Component Ptr, __Ptr__))
	
	Private Type MarginsType Extends My.Sys.Object
		Declare Function ToString ByRef As WString
		Left         As Integer
		Top          As Integer
		Right        As Integer
		Bottom       As Integer
	End Type
	
	'Provides the base class for the components (Windows, Linux, Android, Web).
	Private Type Component Extends My.Sys.Object
	Protected:
		FClassAncestor      As WString Ptr
		FDesignMode         As Boolean
		FCreated            As Boolean
		FID                 As Integer
		FName               As WString Ptr
		FLeft               As Integer
		FTop                As Integer
		FWidth              As Integer
		FHeight             As Integer
		FMinWidth           As Integer
		FMinHeight          As Integer
		FParent             As Component Ptr
		FComponents         As List
		FTempString         As String
			box 			As GtkWidget Ptr
			fixedwidget		As GtkWidget Ptr
			scrolledwidget	As GtkWidget Ptr
			eventboxwidget  As GtkWidget Ptr
			overlaywidget   As GtkWidget Ptr
			containerwidget As GtkWidget Ptr
		Declare Sub FreeWidget()
		Declare Virtual Sub Move(cLeft As Integer, cTop As Integer, cWidth As Integer, cHeight As Integer)
	Public:
		'Stores any extra data needed for your program (Windows, Linux, Android, Web).
		Tag As Any Ptr
		'Returns/sets the space between controls (Windows, Linux, Android, Web).
		Margins             As MarginsType
		'Returns/sets the extra space between controls (Windows, Linux, Android, Web).
		ExtraMargins        As MarginsType
			'Gets the window handle that the control is bound to (Windows, Linux, Android, Web).
			Declare Property Handle As GtkWidget Ptr
			Declare Property Handle(Value As GtkWidget Ptr)
			Declare Property LayoutHandle As GtkWidget Ptr
			Declare Property LayoutHandle(Value As GtkWidget Ptr)
		#ifndef ReadProperty_Off
			'Reads value from the name of property (Windows, Linux, Android, Web).
			Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
		#endif
		#ifndef WriteProperty_Off
			'Writes value to the name of property (Windows, Linux, Android, Web).
			Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
		#endif
		'Returns a string that represents the current object (Windows, Linux, Android, Web).
		Declare Virtual Function ToString ByRef As WString
		'Returns ancestor class of control (Windows, Linux, Android, Web).
		Declare Function ClassAncestor ByRef As WString
		'Determines if the control is a top-level control (Windows, Linux, Android, Web).
		Declare Function GetTopLevel As Component Ptr
		'Returns/sets the distance between the internal left edge of an object and the left edge of its container (Windows, Linux, Android, Web).
		Declare Property Left As Integer
		Declare Property Left(Value As Integer)
		'Returns/sets the distance between the internal top edge of an object and the top edge of its container (Windows, Linux, Android, Web).
		Declare Property Top As Integer
		Declare Property Top(Value As Integer)
		'Returns/sets the width of an object (Windows, Linux, Android, Web).
		Declare Property Width As Integer
		Declare Property Width(Value As Integer)
		'Returns/sets the height of an object (Windows, Linux, Android, Web).
		Declare Property Height As Integer
		Declare Property Height(Value As Integer)
		'Gets the bounds of the control to the specified location and size (Windows, Linux, Android, Web).
		Declare Sub GetBounds(ByRef ALeft As Integer, ByRef ATop As Integer, ByRef AWidth As Integer, ByRef AHeight As Integer)
		'Sets the bounds of the control to the specified location and size (Windows, Linux, Android, Web).
		Declare Sub SetBounds(ALeft As Integer, ATop As Integer, AWidth As Integer, AHeight As Integer)
		'Gets a value that indicates whether the Component is currently in design mode (Windows, Linux, Android, Web).
		Declare Virtual Property DesignMode As Boolean
		Declare Virtual Property DesignMode(Value As Boolean)
		'Returns the name used in code to identify an object (Windows, Linux, Android, Web).
		Declare Property Name ByRef As WString
		Declare Property Name(ByRef Value As WString)
		'Gets or sets the parent container of the control (Windows, Linux, Android, Web).
		Declare Property Parent As Component Ptr 'ContainerControl
		Declare Property Parent(Value As Component Ptr)
		'Declare Constructor
		Declare Destructor
	End Type
End Namespace

Private Type Message
	Sender   As Any Ptr
		widget As GtkWidget Ptr
		Event As GdkEvent Ptr
		Result   As Boolean
	Handled As Boolean
End Type


Private Enum Keys
		Key_Esc = GDK_KEY_Escape
		Key_Left = GDK_KEY_Left
		Key_Right = GDK_KEY_Right
		Key_Up = GDK_KEY_Up
		Key_Down = GDK_KEY_Down
		Key_Home = GDK_KEY_Home
		Key_End = GDK_KEY_End
		Key_Delete = GDK_KEY_Delete
		Key_Enter = GDK_KEY_Return
		ShiftMask = GDK_SHIFT_MASK
		LockMask = GDK_LOCK_MASK
		CtrlMask = GDK_CONTROL_MASK
		AltMask = GDK_MOD1_MASK
		Key_1 = GDK_KEY_1
		Key_2 = GDK_KEY_2
		Key_3 = GDK_KEY_3
		Key_4 = GDK_KEY_4
		Key_5 = GDK_KEY_5
		Key_6 = GDK_KEY_6
		Key_7 = GDK_KEY_7
		Key_8 = GDK_KEY_8
		Key_9 = GDK_KEY_9
		Key_0 = GDK_KEY_0
		Key_A = GDK_KEY_a
		Key_B = GDK_KEY_b
		Key_C = GDK_KEY_c
		Key_D = GDK_KEY_d
		Key_E = GDK_KEY_e
		Key_F = GDK_KEY_f
		Key_G = GDK_KEY_g
		Key_H = GDK_KEY_h
		Key_I = GDK_KEY_i
		Key_J = GDK_KEY_j
		Key_K = GDK_KEY_k
		Key_L = GDK_KEY_l
		Key_M = GDK_KEY_m
		Key_N = GDK_KEY_n
		Key_O = GDK_KEY_o
		Key_P = GDK_KEY_p
		Key_Q = GDK_KEY_q
		Key_R = GDK_KEY_r
		Key_S = GDK_KEY_s
		Key_T = GDK_KEY_t
		Key_U = GDK_KEY_u
		Key_V = GDK_KEY_v
		Key_W = GDK_KEY_w
		Key_X = GDK_KEY_x
		Key_Y = GDK_KEY_y
		Key_Z = GDK_KEY_z
		F1 = GDK_KEY_F1
		F2 = GDK_KEY_F2
		F3 = GDK_KEY_F3
		F4 = GDK_KEY_F4
		F5 = GDK_KEY_F5
		F6 = GDK_KEY_F6
		F7 = GDK_KEY_F7
		F8 = GDK_KEY_F8
		F9 = GDK_KEY_F9
		F10 = GDK_KEY_F10
		F11 = GDK_KEY_F11
		F12 = GDK_KEY_F12
		F13 = GDK_KEY_F13
		F14 = GDK_KEY_F14
		F15 = GDK_KEY_F15
		F16 = GDK_KEY_F16
		F17 = GDK_KEY_F17
		F18 = GDK_KEY_F18
		F19 = GDK_KEY_F19
		F20 = GDK_KEY_F20
		F21 = GDK_KEY_F21
		F22 = GDK_KEY_F22
		F23 = GDK_KEY_F23
		F24 = GDK_KEY_F24
End Enum

Declare Sub ThreadsEnter

Declare Sub ThreadsLeave

Declare Function ThreadCreate_(ByVal ProcPtr_ As Sub ( ByVal userdata As Any Ptr ), ByVal param As Any Ptr = 0, ByVal stack_size As Integer = 0) As Any Ptr

Declare Sub ComponentGetBounds Alias "ComponentGetBounds" (Ctrl As My.Sys.ComponentModel.Component Ptr, ByRef ALeft As Integer, ByRef ATop As Integer, ByRef AWidth As Integer, ByRef AHeight As Integer)

Declare Sub ComponentSetBounds Alias "ComponentSetBounds"(Ctrl As My.Sys.ComponentModel.Component Ptr, ALeft As Integer, ATop As Integer, AWidth As Integer, AHeight As Integer)

#ifndef __USE_MAKE__
	#include once "Component.bas"
#endif
