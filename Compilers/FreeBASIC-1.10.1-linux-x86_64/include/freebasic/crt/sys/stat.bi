''
''
'' sys\stat -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#ifndef __crt_sys_stat_bi__
#define __crt_sys_stat_bi__

#include once "crt/stddef.bi"
#include once "crt/sys/types.bi"

#error Unsupported platform

extern "C"

declare function fstat (byval as long, byval as _stat ptr) as long
declare function chmod (byval as const zstring ptr, byval as long) as long
declare function stat (byval as const zstring ptr, byval as _stat ptr) as long

end extern

#endif
