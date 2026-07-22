'******************************************************************************
'* ClipboardType
'* This file is part of MyFBFramework
'* Based on:
'*  TClipboard
'*  FreeBasic Windows GUI ToolKit
'*  Copyright (c) 2007-2008 Nastase Eodor
'*  nastase_eodor@yahoo.com
'* Updated and added cross-platform
'* by Xusinboy Bekchanov (2018-2019)
'******************************************************************************
#include once "Clipboard.bi"

'Provides methods to place data on and retrieve data from the system Clipboard.
Dim Shared As My.Sys.ClipboardType Clipboard
'pClipboard = @Clipboard

Namespace My.Sys
	Private Sub ClipboardType.Open
	End Sub
	
	Private Sub ClipboardType.Clear
		#ifdef __USE_GTK__
			gtk_clipboard_clear(FClipboard)
		#else
			EmptyClipboard
		#endif
	End Sub
	
	Private Sub ClipboardType.Close
	End Sub
	
	
	Private Sub ClipboardType.SetAsText(ByRef Value As WString)
		#ifdef __USE_GTK__
			gtk_clipboard_set_text(FClipboard, ToUtf8(Value), -1)
		#else
			Dim pchData As WString Ptr
			Dim hClipboardData As HGLOBAL
			Dim sz As Integer
			This.Open
			This.Clear
			sz = (Len(Value) + 1) * SizeOf(WString)
			hClipboardData = GlobalAlloc(GMEM_MOVEABLE, sz)
			If hClipboardData Then
				pchData = Cast(WString Ptr, GlobalLock(hClipboardData))
				If pchData Then
					memcpy(pchData, @Value, sz)
					GlobalUnlock(hClipboardData)
				Else
					GlobalFree(hClipboardData)
				End If
				SetClipboardData(CF_UNICODETEXT, hClipboardData)
			End If
			This.Close
		#endif
	End Sub
	
	Private Function ClipboardType.GetAsText ByRef As WString
		#ifdef __USE_GTK__
		Dim pGtkTxt As ZString Ptr = gtk_clipboard_wait_for_text(FClipboard)
		If pGtkTxt Then
		WLet(FText, *pGtkTxt)
  	              g_free(pGtkTxt)
   	         Else
    	            WLet(FText, "")
     	       End If
		#else
			Dim hClipboardData As HANDLE
			This.Open
			hClipboardData = GetClipboardData(CF_UNICODETEXT)
			If hClipboardData <> 0 Then
				Dim pText As WString Ptr = CPtr(WString Ptr, GlobalLock(hClipboardData))
				WLet(FText, IIf(pText, *pText, "" ))
				GlobalUnlock(hClipboardData)
			Else
				WLet(FText, "")
			End If
			This.Close
		#endif
		If FText Then Return *FText Else Return ""
	End Function
	
	
	
	Private Property ClipboardType.FormatCount As Integer
			Return 0
	End Property
	
	Private Property ClipboardType.FormatCount(Value As Integer)
	End Property
	
	Private Property ClipboardType.Format ByRef As WString
		Dim s As String = Space(255)
		If FFormat > 0 Then Return *FFormat Else Return ""
	End Property
	
	Private Property ClipboardType.Format(ByRef Value As WString)
		WLet(FFormat, Value)
	End Property
	
	Private Constructor ClipboardType
		#ifdef __USE_GTK__
			FClipboard = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD)
		#endif
	End Constructor
	
	Private Destructor ClipboardType
		If FText Then _Deallocate( FText)
		If FFormat Then _Deallocate(FFormat)
	End Destructor
End Namespace
