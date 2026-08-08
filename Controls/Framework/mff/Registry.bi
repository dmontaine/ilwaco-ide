'
' Ilwaco IDE Modifications
' copyright 2026 Donald Montaine
'
' This program is free software; you can redistribute it and/or modify
' it under the terms of the GNU Lesser General Public License as published by
' the Free Software Foundation; either version 3, or (at your option)
' any later version.
'
' This program is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU Lesser General Public License for more details.
'
' You should have received a copy of the GNU Lesser General Public License
' along with this program; if not, write to the Free Software Foundation,
' Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
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
