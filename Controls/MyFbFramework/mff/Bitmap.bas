'################################################################################
'#  BitmapType.bi                                                               #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   TBitmap.bi                                                                 #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#   Version 1.0.0                                                              #
'#  Updated and added cross-platform                                            #
'#  by Xusinboy Bekchanov (2018-2019), Liu XiaLin (2020)                        #
'################################################################################

#include once "Bitmap.bi"

Namespace My.Sys.Drawing
	#ifndef ReadProperty_Off
		Private Function BitmapType.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
				Case "handle": Return Handle
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function BitmapType.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	#ifndef BitmapType_Width_Get_Off
		Private Property BitmapType.Width As Integer
			Return FWidth
		End Property
	#endif
	
	Private Property BitmapType.Width(Value As Integer)
		FWidth = Value
		If Changed Then Changed(*Designer, This)
	End Property
	
	#ifndef BitmapType_Height_Get_Off
		Private Property BitmapType.Height As Integer
			Return FHeight
		End Property
	#endif
	
	Private Property BitmapType.Height(Value As Integer)
		FHeight = Value
		If Changed Then Changed(*Designer, This)
	End Property
	
	Private Property BitmapType.Transparency As Boolean
		Return FTransparent
	End Property
	
	Private Property BitmapType.Transparency(Value As Boolean)
		FTransparent = Value
	End Property
	
	Private Function BitmapType.LoadFromFile(ByRef File As WString, cxDesired As Integer = 0, cyDesired As Integer = 0, iMaskColor As Integer = 0) As Boolean
		Free
			Dim As GError Ptr gerr
			If File = "" Then Return False
			If cxDesired = 0 AndAlso cyDesired = 0 Then
				Handle = gdk_pixbuf_new_from_file(ToUtf8(File), @gerr)
			Else
				Handle = gdk_pixbuf_new_from_file_at_size(ToUtf8(File), cxDesired, cyDesired, @gerr)
			End If
			If Handle = 0 Then Return False
			FWidth  = gdk_pixbuf_get_width(Handle)
			FHeight = gdk_pixbuf_get_height(Handle)
		If Changed Then Changed(*Designer, This)
		Return True
	End Function
	
	#ifndef BitmapType_SaveToFile_Off
		Private Function BitmapType.SaveToFile(ByRef File As WString) As Boolean
			Return True
		End Function
	#endif
	
	
	
	#ifndef BitmapType_LoadFromResourceName_Off
		Private Function BitmapType.LoadFromResourceName(ResName As String, ModuleHandle As Any Ptr = 0, cxDesired As Integer = 0, cyDesired As Integer = 0, iMaskColor As Integer = 0) As Boolean
			Free
				Dim As GError Ptr gerr
				If FileExists(ExePath & "/./Resources/" & ResName & ".png") Then
					Handle = gdk_pixbuf_new_from_file(ToUtf8(ExePath & "/./Resources/" & ResName & ".png"), @gerr)
				ElseIf FileExists(ExePath & "/./resources/" & ResName & ".png") Then
					Handle = gdk_pixbuf_new_from_file(ToUtf8(ExePath & "/./resources/" & ResName & ".png"), @gerr)
				ElseIf FileExists(ExePath & "/./Resources/" & ResName & ".ico") Then
					Handle = gdk_pixbuf_new_from_file(ToUtf8(ExePath & "/./Resources/" & ResName & ".ico"), @gerr)
				ElseIf FileExists(ExePath & "/./resources/" & ResName & ".ico") Then
					Handle = gdk_pixbuf_new_from_file(ToUtf8(ExePath & "/./resources/" & ResName & ".ico"), @gerr)
				ElseIf ResName <> "" Then
					Handle = gdk_pixbuf_new_from_resource(ToUtf8(ResName), @gerr)
				End If
				If gerr Then Print gerr->code, *gerr->message
			If Changed Then Changed(*Designer, This)
			Return Handle <> 0
		End Function
	#endif
	
	Private Function BitmapType.LoadFromResourceID(ResID As Integer, ModuleHandle As Any Ptr = 0, cxDesired As Integer = 0, cyDesired As Integer = 0) As Boolean
		Free
			Return False
		If Changed Then Changed(*Designer, This)
		Return True
	End Function
	
	Private Sub BitmapType.Create
		If Changed Then Changed(*Designer, This)
	End Sub
	
	Private Sub BitmapType.Clear
		If Changed Then Changed(*Designer, This)
	End Sub
	
	Private Sub BitmapType.Free
		'If Changed Then Changed(This)
	End Sub
	
	Private Operator BitmapType.Cast As Any Ptr
		Return @This
	End Operator
	
	#ifndef BitmapType_Let_WString_Off
		Private Operator BitmapType.Let(ByRef Value As WString)
			Free
			WLet(FResName, Value)
				If StartsWith(Value, "/") Then
					LoadFromFile(Value)
				Else
					LoadFromResourceName(Value)
				End If
		End Operator
	#endif
	
		
	
	Private Function BitmapType.ToString() ByRef As WString
		If FResName > 0 Then Return *FResName Else Return ""
	End Function
	
	Private Constructor BitmapType
		WLet(FClassName, "BitmapType")
		FWidth       = 16
		FHeight      = 16
		FTransparent = False
		'Create
	End Constructor
	
	Private Destructor BitmapType
		If FResName Then _Deallocate(FResName)
		Free
			If Handle Then g_object_unref(Handle)
	End Destructor
End Namespace

#ifdef __EXPORT_PROCS__
	Function BitmapTypeLoadFromResourceName Alias "BitmapTypeLoadFromResourceName"(Bitm As My.Sys.Drawing.BitmapType Ptr, ResName As String, ModuleHandle As Any Ptr = 0) As Boolean  __EXPORT__
			Return Bitm->LoadFromResourceName(ResName)
	End Function
	
	Function BitmapTypeLoadFromFile Alias "BitmapTypeLoadFromFile"(Bitm As My.Sys.Drawing.BitmapType Ptr, ByRef File As WString, cxDesired As Integer = 0, cyDesired As Integer = 0) As Boolean __EXPORT__
		Return Bitm->LoadFromFile(File, cxDesired, cyDesired)
	End Function
#endif
