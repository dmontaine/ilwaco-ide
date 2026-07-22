#pragma once

Const TESTS_DATA_PATH = "../../Resources/"

#if Not defined( FBSOUND_USE_DYNAMIC ) And Not defined( FBSOUND_USE_STATIC )
'#define FBSOUND_USE_DYNAMIC
#define FBSOUND_USE_STATIC
#endif

'' set the DLL path before including fbsound_dynamic.bi to override
#if 0
		Const FBSOUND_DLL_PATH  = ""
#else
	Const FBSOUND_DLL_PATH  = ""
#endif

#if 0
#include "inc/fbsound/fbsound_dynamic.bi"
#endif

#if 0
'
'#ifdef __FB_WIN32__
' #ifndef __FB_64BIT__
'  #libpath "./lib/win32/"
' #else
'  #libpath "./lib/win64/"
' #endif 
'#else
' #ifdef  __FB_LINUX__
'   #ifndef __FB_64BIT__
'    #libpath "./lib/lin32/"
'   #else
'    #libpath "./lib/lin64/"
'   #endif
' #else
'   #error 666: Build target must be Windows or Linux !
' #endif
'#endif

#include "inc/fbsound/fbsound.bi"

#endif
