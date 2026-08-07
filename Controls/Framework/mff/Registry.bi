#include once "SysUtils.bi"
#include once "vbcompat.bi"

Namespace My.Sys.Registry
	' Possible registry data types
	Private Enum InTypes
		ValNull = 0
		ValString = 1
		ValXString = 2
		ValBinary = 3
		ValDWord = 4
		ValLink = 6
		ValMultiString = 7
		ValResList = 8
	End Enum
	
End Namespace

#ifndef __USE_MAKE__
	#include once "Registry.bas"
#endif
