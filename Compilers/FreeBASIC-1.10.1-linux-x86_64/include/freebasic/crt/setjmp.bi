''
''
'' setjmp -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#ifndef __crt_setjmp_bi__
#define __crt_setjmp_bi__

	#ifdef __FB_64BIT__
		'' x86_64 glibc
		type __jmp_buf
			__opaque(0 to 8-1) as longint
		end type
	#else
		'' x86 glibc
		type __jmp_buf
			__opaque(0 to 6-1) as long
		end type
	#endif

	#include once "crt/bits/sigset.bi"

	type jmp_buf
		__jmpbuf		as __jmp_buf
		__mask_was_saved	as long
		__saved_mask		as __sigset_t
	end type

extern "C"

declare function setjmp (byval as jmp_buf ptr) as long

declare sub longjmp (byval as jmp_buf ptr, byval as long)

end extern

#endif
