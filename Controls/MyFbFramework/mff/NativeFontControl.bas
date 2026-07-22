''################################################################################
''#  MonthCalendar.bi                                                            #
''#  This file is part of MyFBFramework                                          #
''#  Authors: Xusinboy Bekchanov (2018-2019)                                     #
''################################################################################
'
'
'Namespace My.Sys.Forms
'					
'		
'		
'			Base.ProcessMessage(Message)
'	
'	
'			
'			icex.dwSize = SizeOf(INITCOMMONCONTROLSEX)
'			icex.dwICC =  ICC_NATIVEFNTCTL_CLASS
'			
'			InitCommonControlsEx(@icex)
'			WLet(FClassName, "NativeFontControl")
'			WLet(FClassAncestor, "NativeFontCtl")
'				.RegisterClass "NativeFontControl","NativeFontCtl"
'				.Style        = WS_CHILD Or NFS_EDIT Or NFS_STATIC Or NFS_LISTCOMBO Or NFS_BUTTON Or NFS_ALL
'				.ExStyle      = 0
'				.ChildProc    = @WndProc
'				.OnHandleIsAllocated = @HandleIsAllocated
'			.Width        = 175
'			.Height       = 21
'			.Child        = @This
'	
'			UnregisterClass "NativeFontControl",GetModuleHandle(NULL)
