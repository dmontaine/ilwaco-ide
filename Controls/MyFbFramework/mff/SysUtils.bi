'################################################################################
'#  SysUtils.bi                                                                 #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   SysUtils.bi                                                                #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#  Modified by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                       #
'################################################################################



	#define __USE_CAIRO__
	#include once "gtk/gtk.bi"
		#include once "glib-object.bi"
#include once "UString.bi"
#include once "Integer.bi"

#ifdef __EXPORT_PROCS__
	#define PublicOrPrivate Public
	#define __EXPORT__ Export
#else
	#define PublicOrPrivate Private
	#define __EXPORT__
#endif

'#macro Each(iter, arr)
'	index As Integer = LBound(arr) To UBound(arr)
'#endmacro

#define Each(iter, col) __index__ As Integer = 0 To col.Count - 1: Dim As Typeof(col.Item(__index__)) iter = col.Item(__index__)

#define Me This

#ifndef _L
		#define _L Print __LINE__, __FILE__, __FUNCTION__:
#endif

Const HELP_SETPOPUP_POS = &Hd

#macro RedefineClassKeyword
	#undef Class
	#define Class Type
	#define __StartOfClassBody__ End Type
	#macro __EndOfClassBody__
		Scope
		#undef Class
		#macro Class
			Scope
			#undef Class
			#define Class Type
		#endmacro
	#endmacro
#endmacro

'#DEFINE __AUTOMATE_CREATE_CHILDS__


Namespace ClassContainer
	Private Type ClassType
	Protected:
		FClassName As WString Ptr
		FClassAncestor As WString Ptr
	Public:
		ClassProc As Any Ptr
		Declare Property ClassName ByRef As WString
		Declare Property ClassName(ByRef Value As WString)
		Declare Property ClassAncestor ByRef As WString
		Declare Property ClassAncestor(ByRef Value As WString)
		Declare Constructor
		Declare Destructor
	End Type
	
	Dim Classes()  As ClassType
	
	Declare Function FindClass(ByRef ClassName As WString) As Integer
	
	Declare Sub StoreClass(ByRef ClassName As WString, ByRef ClassAncestor As WString, ClassProc As Any Ptr)
	
	Declare Function GetClassProc Overload(ByRef ClassName As WString) As Any Ptr
	
End Namespace

Using ClassContainer

#ifdef GetMN
	Declare Function GetMessageName(Message As Integer) As String
#endif

Declare Function ErrDescription(Code As Integer) ByRef As WString

Declare Function GetErrorString(ByVal Code As UInteger, ByVal MaxLen  As UShort = 1024, WithCode As Boolean = False) As UString

#ifndef __USE_MAKE__
	#include once "SysUtils.bas"
#endif
