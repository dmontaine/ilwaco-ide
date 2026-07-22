'###############################################################################
'#  Icon.bi                                                                    #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   TIcon.bi                                                                  #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################
#include once "Icon.bi"

Namespace My.Sys.Drawing
	#ifndef ReadProperty_Off
		Private Function Icon.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			#ifdef __USE_GTK__
			Case "handle": Return Handle
			#elseif 0
			Case "handle": Return @Handle
			#endif
			Case "height": Return @FHeight
			Case "width": Return @FWidth
			Case "resname": Return FResName
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Icon.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value <> 0 Then
				Select Case LCase(PropertyName)
				Case "height": This.Height = QInteger(Value)
				Case "width": This.Width = QInteger(Value)
				Case "resname": This.ResName = QWString(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property Icon.ResName ByRef As WString
		If FResName > 0 Then Return *FResName Else Return ""
	End Property
	
	#ifndef Icon_ResName_Set_Off
		Private Property Icon.ResName(ByRef Value As WString)
			WLet(FResName, Value)
		End Property
	#endif
	
	Private Function Icon.ToString() ByRef As WString
		If FResName > 0 Then Return *FResName Else Return ""
	End Function
	
	#ifndef Icon_Width_Get_Off
		Private Property Icon.Width As Integer
			Return FWidth
		End Property
	#endif
	
	Private Property Icon.Width(Value As Integer)
	End Property
	
	#ifndef Icon_Height_Get_Off
		Private Property Icon.Height As Integer
			Return FWidth
		End Property
	#endif
	
	Private Property Icon.Height(Value As Integer)
	End Property
	
	
	Private Function Icon.LoadFromFile(ByRef File As WString, cx As Integer = 0, cy As Integer = 0) As Boolean
		#ifdef __USE_GTK__
			Dim As GError Ptr gerr
			If File = "" Then Return False
			If cx = 0 AndAlso cy = 0 Then
				Handle = gdk_pixbuf_new_from_file(ToUtf8(File), @gerr)
			Else
				Handle = gdk_pixbuf_new_from_file_at_size(ToUtf8(File), cx, cy, @gerr)
			End If
			If Handle = 0 Then Return False
		#elseif 0
			Dim As ICONINFO ICIF
			Dim As BITMAP BMP
			If Handle Then DestroyIcon(Handle)
			Handle = LoadImage(0, File, IMAGE_ICON, cx, cy, LR_LOADFROMFILE Or LR_LOADTRANSPARENT)
			If Handle = 0 Then Return False
			GetIconInfo(Handle, @ICIF)
			GetObject(ICIF.hbmColor, SizeOf(BMP), @BMP)
			FWidth  = BMP.bmWidth
			FHeight = BMP.bmHeight
			DeleteObject(ICIF.hbmColor)
			DeleteObject(ICIF.hbmMask)
		#endif
		If Changed Then Changed(*Designer, This)
		Return True
	End Function
	
	#ifndef Icon_SaveToFile_Off
		Private Function Icon.SaveToFile(ByRef File As WString) As Boolean
			Return False
		End Function
	#endif
	
	#ifndef Icon_LoadFromResourceName_Off
		Private Function Icon.LoadFromResourceName(ByRef ResourceName As WString, ModuleHandle As Any Ptr = 0, cx As Integer = 0, cy As Integer = 0) As Boolean
			#ifdef __USE_GTK__
				Dim As GError Ptr gerr
				If FileExists(ExePath & "/./Resources/" & ResName & ".ico") Then
					Handle = gdk_pixbuf_new_from_file(ToUtf8(ExePath & "/./Resources/" & ResName & ".ico"), @gerr)
				ElseIf FileExists(ExePath & "/./resources/" & ResName & ".ico") Then
					Handle = gdk_pixbuf_new_from_file(ToUtf8(ExePath & "/./resources/" & ResName & ".ico"), @gerr)
				Else
					Handle = gdk_pixbuf_new_from_resource(ToUtf8(ResName), @gerr)
				End If
				If gerr Then Print gerr->code, *gerr->message
			#elseif 0
				Dim As ICONINFO ICIF
				Dim As BITMAP BMP
				This.ResName = ResourceName
				Dim As Any Ptr ModuleHandle_ = ModuleHandle: If ModuleHandle = 0 Then ModuleHandle_ = GetModuleHandle(NULL)
				If Handle Then DestroyIcon(Handle)
				Handle = LoadImage(ModuleHandle_, ResName, IMAGE_ICON, cx, cy, LR_COPYFROMRESOURCE)
				If Handle = 0 Then Return False
				GetIconInfo(Handle, @ICIF)
				GetObject(ICIF.hbmColor, SizeOf(BMP), @BMP)
				FWidth  = BMP.bmWidth
				FHeight = BMP.bmHeight
				DeleteObject(ICIF.hbmColor)
				DeleteObject(ICIF.hbmMask)
			#endif
			If Changed Then Changed(*Designer, This)
			Return True
		End Function
	#endif
	
	#ifndef Icon_LoadFromResourceID_Off
		Private Function Icon.LoadFromResourceID(ResID As Integer, ModuleHandle As Any Ptr = 0, cx As Integer = 0, cy As Integer = 0) As Boolean
			If Changed Then Changed(*Designer, This)
			Return True
		End Function
	#endif
	
	Private Operator Icon.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Operator Icon.Cast As WString Ptr
		Return This.FResName
	End Operator
	
	Private Operator Icon.Let(ByRef Value As WString)
			LoadFromFile(Value)
		This.ResName = Value
	End Operator
	
	Private Operator Icon.Let(Value As Integer)
		LoadFromResourceID(Value)
		This.ResName = WStr(Value)
	End Operator
	
	Private Operator Icon.Let(Value As Icon)
		Handle = Value.Handle
		If Changed Then Changed(*Designer, This)
	End Operator
	
	#ifndef __USE_JNI__
		#ifdef __USE_GTK__
			Private Operator Icon.Let(Value As GdkPixbuf Ptr)
				If Handle Then g_object_unref(Handle)
		#elseif 0
			Private Operator Icon.Let(Value As HICON)
				If Handle Then DestroyIcon(Handle)
		#else
			Private Operator Icon.Let(Value As Any Ptr)
		#endif
			Handle = Value
			If Changed Then Changed(*Designer, This)
		End Operator
	#endif
	
	Private Constructor Icon
		WLet(FClassName, "Icon")
	End Constructor
	
	Private Destructor Icon
		If FResName Then _Deallocate(FResName)
		#ifdef __USE_GTK__
			If Handle Then g_object_unref(Handle)
		#elseif 0
			If Handle Then DestroyIcon Handle
		#endif
	End Destructor
End Namespace

Sub IconLoadFromFile Alias "IconLoadFromFile"(Ico As My.Sys.Drawing.Icon Ptr, ByRef File As WString, cx As Integer = 0, cy As Integer = 0) __EXPORT__
	Ico->LoadFromFile(File, cx, cy)
End Sub
