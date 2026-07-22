''
''
'' string -- header translated with help of SWIG FB wrapper
''
'' NOTICE: This file is part of the FreeBASIC Compiler package and can't
''         be included in other distributions without authorization.
''
''
#ifndef __crt_string_bi__
#define __crt_string_bi__

#include once "crt/stddef.bi"
#include once "crt/mem.bi"

extern "c"

#undef strcat
declare function strcat (byval as zstring ptr, byval as const zstring ptr) as zstring ptr
#undef strchr
declare function strchr (byval as const zstring ptr, byval as long) as zstring ptr
#undef strcmp
declare function strcmp (byval as const zstring ptr, byval as const zstring ptr) as long
declare function strcoll (byval as const zstring ptr, byval as const zstring ptr) as long
#undef strcpy
declare function strcpy (byval as zstring ptr, byval as const zstring ptr) as zstring ptr
#undef strcspn
declare function strcspn (byval as const zstring ptr, byval as const zstring ptr) as size_t
declare function strerror (byval as long) as zstring ptr
declare function strlen (byval as const zstring ptr) as size_t
#undef strncat
declare function strncat (byval as zstring ptr, byval as const zstring ptr, byval as size_t) as zstring ptr
#undef strncmp
declare function strncmp (byval as const zstring ptr, byval as const zstring ptr, byval as size_t) as long
#undef strncpy
declare function strncpy (byval as zstring ptr, byval as const zstring ptr, byval as size_t) as zstring ptr
#undef strpbrk
declare function strpbrk (byval as const zstring ptr, byval as const zstring ptr) as zstring ptr
#undef strrchr
declare function strrchr (byval as const zstring ptr, byval as long) as zstring ptr
#undef strspn
declare function strspn (byval as const zstring ptr, byval as const zstring ptr) as size_t
#undef strstr
declare function strstr (byval as const zstring ptr, byval as const zstring ptr) as zstring ptr
declare function strtok (byval as zstring ptr, byval as const zstring ptr) as zstring ptr
declare function strxfrm (byval as zstring ptr, byval as const zstring ptr, byval as size_t) as size_t
declare function wcscat (byval as wchar_t ptr, byval as const wchar_t ptr) as wchar_t ptr
declare function wcschr (byval as const wchar_t ptr, byval as wchar_t) as wchar_t ptr
declare function wcscmp (byval as const wchar_t ptr, byval as const wchar_t ptr) as long
declare function wcscoll (byval as const wchar_t ptr, byval as const wchar_t ptr) as long
declare function wcscpy (byval as wchar_t ptr, byval as const wchar_t ptr) as wchar_t ptr
declare function wcscspn (byval as const wchar_t ptr, byval as const wchar_t ptr) as size_t
declare function wcslen (byval as const wchar_t ptr) as size_t
declare function wcsncat (byval as wchar_t ptr, byval as const wchar_t ptr, byval as size_t) as wchar_t ptr
declare function wcsncmp (byval as const wchar_t ptr, byval as const wchar_t ptr, byval as size_t) as long
declare function wcsncpy (byval as wchar_t ptr, byval as const wchar_t ptr, byval as size_t) as wchar_t ptr
declare function wcspbrk (byval as const wchar_t ptr, byval as const wchar_t ptr) as wchar_t ptr
declare function wcsrchr (byval as const wchar_t ptr, byval as wchar_t) as wchar_t ptr
declare function wcsspn (byval as const wchar_t ptr, byval as const wchar_t ptr) as size_t
declare function wcsstr (byval as const wchar_t ptr, byval as const wchar_t ptr) as wchar_t ptr
declare function wcstok (byval as wchar_t ptr, byval as const wchar_t ptr) as wchar_t ptr
declare function wcsxfrm (byval as wchar_t ptr, byval as const wchar_t ptr, byval as size_t) as size_t


end extern

#endif
