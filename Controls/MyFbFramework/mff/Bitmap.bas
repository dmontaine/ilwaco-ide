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
				#ifdef __USE_GTK__
				Case "handle": Return Handle
				#elseif 0
				Case "handle": Return @Handle
				#endif
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
		#ifdef __USE_GTK__
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
		#elseif 0
			Handle = File
		#elseif 0
			Dim As Integer Pos1 = InStrRev(File, ".")
			Select Case LCase(Mid(File, Pos1 + 1))
			Case "bmp"
				Dim As BITMAP BMP
				Dim As HDC MemDC
				If Handle Then DeleteObject Handle
				Handle = LoadImageW(0, File, IMAGE_BITMAP, cxDesired, cyDesired, LR_LOADFROMFILE Or LR_LOADMAP3DCOLORS Or FLoadFlag(abs_(FTransparent)))
				If Handle = 0 Then Return False
				GetObject(Handle,SizeOf(BMP),@BMP)
				FWidth  = BMP.bmWidth
				FHeight = BMP.bmHeight
			Case Else
				'Dim pImage As GpImage Ptr
				If Handle Then DeleteObject Handle: Handle = 0
				' // Initialize Gdiplus
				Dim token As ULONG_PTR, StartupInput As GdiplusStartupInput
				StartupInput.GdiplusVersion = 1
				GdiplusStartup(@token, @StartupInput, NULL)
				If token = NULL Then If Changed Then Changed(*Designer, This) End If: Return False
				' // Load the image from file
				If pImage Then GdipDisposeImage pImage: pImage = 0
				GdipLoadImageFromFile(File, @pImage)
				If pImage = NULL Then If Changed Then Changed(*Designer, This) End If: Return False
				' // Get the image width and height
				GdipGetImageWidth(pImage, @FWidth)
				GdipGetImageHeight(pImage, @FHeight)
				' // Create bitmap from image
				GdipCreateHBITMAPFromBitmap(Cast(GpBitmap Ptr, pImage), @Handle, iMaskColor)
				' // Free the image Save the Ptr and send the ptr to canvas later
				'If pImage Then GdipDisposeImage pImage
				' // Shutdown Gdiplus
				GdiplusShutdown token
			End Select
		#endif
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
			#ifdef __USE_GTK__
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
			#elseif 0
				Handle = "Resources/" & ResName & ".png"
			#elseif 0
				Dim As Any Ptr ModuleHandle_ = ModuleHandle: If ModuleHandle = 0 Then ModuleHandle_ = GetModuleHandle(NULL)
				Dim As BITMAP BMP
				If ModuleHandle = 0 AndAlso FileExists(ExePath & "./Resources/" & ResName & ".png") Then
					LoadFromFile(ExePath & "./Resources/" & ResName & ".png", cxDesired, cyDesired, iMaskColor)
				ElseIf ModuleHandle = 0 AndAlso FileExists(ExePath & "./Resources/" & ResName & ".ico") Then
					LoadFromFile(ExePath & "./Resources/" & ResName & ".ico", cxDesired, cyDesired, iMaskColor)
				ElseIf FindResource(ModuleHandle_, ResName, RT_BITMAP) Then
					Handle = LoadImageW(ModuleHandle_, ResName, IMAGE_BITMAP, cxDesired, cyDesired, LR_COPYFROMRESOURCE Or FLoadFlag(abs_(FTransparent)))
				ElseIf FindResource(ModuleHandle_, ResName, RT_GROUP_ICON) Then
					Dim As HICON IcoHandle
					IcoHandle = LoadImageW(ModuleHandle_, ResName, IMAGE_ICON, cxDesired, cyDesired, LR_COPYFROMRESOURCE)
					If IcoHandle = 0 Then Return False
					LoadFromHICON(IcoHandle)
				ElseIf FindResource(ModuleHandle_, ResName, RT_GROUP_CURSOR) Then
					Dim As HICON IcoHandle
					IcoHandle = LoadImageW(ModuleHandle_, ResName, IMAGE_CURSOR, cxDesired, cyDesired, LR_COPYFROMRESOURCE)
					LoadFromHICON(IcoHandle)
				Else
					Dim As HRSRC hPicture = FindResourceW(ModuleHandle_, ResName, "PNG")
					If hPicture = 0 Then hPicture = FindResourceW(ModuleHandle_, ResName, RT_GROUP_ICON)
					If hPicture = 0 Then hPicture = FindResourceW(ModuleHandle_, ResName, RT_RCDATA)
					
					Dim As HRSRC hPictureData
					Dim As Unsigned Long dwSize = SizeofResource(ModuleHandle_, hPicture)
					Dim As HGLOBAL hGlobal = NULL
					If hPicture = 0 Then Return False
					hPictureData = LockResource(LoadResource(ModuleHandle_, hPicture))
					If hPictureData = 0 Then Return False
					hGlobal = GlobalAlloc(GMEM_MOVEABLE, dwSize)
					If hGlobal = 0 Then Return False
					' Lock the memory
					Dim As LPVOID pData = GlobalLock(hGlobal)
					If pData = 0 Then
						GlobalFree(hGlobal)
						Return False
					End If
					' Initialize Gdiplus
					Dim token As ULONG_PTR, StartupInput As GdiplusStartupInput
					StartupInput.GdiplusVersion = 1
					GdiplusStartup(@token, @StartupInput, NULL)
					' Copy the image from the binary string file to global memory
					CopyMemory(pData, hPictureData, dwSize)
					Dim As IStream Ptr pngstream = NULL
					If SUCCEEDED(CreateStreamOnHGlobal(hGlobal, False, @pngstream)) Then
						If pngstream Then
							'Dim As gdiplus.Color clr
							'Dim pImage As GpImage Ptr ', hImage As HICON . Save it for GDIPlus
							' Create a bitmap from the data contained in the stream
							If pImage Then GdipDisposeImage pImage: pImage = 0
							GdipCreateBitmapFromStream(pngstream, Cast(GpBitmap Ptr Ptr, @pImage))
							' Create icon from image
							GdipCreateHBITMAPFromBitmap(Cast(GpBitmap Ptr, pImage), @Handle, iMaskColor)
							' Free the image. Save it for GDIPlus
							'If pImage Then GdipDisposeImage pImage
							pngstream->lpVtbl->Release(pngstream)
						End If
					End If
					' Unlock the memory
					GlobalUnlock pData
					' Free the memory
					GlobalFree hGlobal
					' Shutdown Gdiplus
					GdiplusShutdown token
				End If
				GetObject(Handle,SizeOf(BMP),@BMP)
				FWidth  = BMP.bmWidth
				FHeight = BMP.bmHeight
			#endif
			If Changed Then Changed(*Designer, This)
			Return Handle <> 0
		End Function
	#endif
	
	Private Function BitmapType.LoadFromResourceID(ResID As Integer, ModuleHandle As Any Ptr = 0, cxDesired As Integer = 0, cyDesired As Integer = 0) As Boolean
		Free
		#ifdef __USE_GTK__
			Return False
		#elseif 0
			Dim As BITMAP BMP
			Dim As Any Ptr ModuleHandle_ = ModuleHandle: If ModuleHandle = 0 Then ModuleHandle_ = GetModuleHandle(NULL)
			Handle = LoadImageW(ModuleHandle_, MAKEINTRESOURCE(ResID), IMAGE_BITMAP, cxDesired, cyDesired, LR_COPYFROMRESOURCE Or FLoadFlag(abs_(FTransparent)))
			If Handle = 0 Then Return False
			GetObject(Handle,SizeOf(BMP),@BMP)
			FWidth  = BMP.bmWidth
			FHeight = BMP.bmHeight
		#endif
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
			#ifdef __USE_GTK__
				If StartsWith(Value, "/") Then
					LoadFromFile(Value)
				Else
					LoadFromResourceName(Value)
				End If
			#elseif 0
				If StartsWith(Value, "/") OrElse InStr(Value, ".") > 0 Then
					LoadFromFile(Value)
				Else
					LoadFromResourceName(Value)
				End If
			#else
				If (Not LoadFromResourceName(Value)) AndAlso (Not LoadFromResourceID(Val(Value))) Then
					LoadFromFile(Value)
				End If
			#endif
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
		#ifdef __USE_GTK__
			Return Bitm->LoadFromResourceName(ResName)
		#else
			Return Bitm->LoadFromResourceName(ResName, Cast(HINSTANCE, ModuleHandle))
		#endif
	End Function
	
	Function BitmapTypeLoadFromFile Alias "BitmapTypeLoadFromFile"(Bitm As My.Sys.Drawing.BitmapType Ptr, ByRef File As WString, cxDesired As Integer = 0, cyDesired As Integer = 0) As Boolean __EXPORT__
		Return Bitm->LoadFromFile(File, cxDesired, cyDesired)
	End Function
#endif
