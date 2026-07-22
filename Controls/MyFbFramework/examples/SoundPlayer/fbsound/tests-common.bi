#pragma once

Const TESTS_DATA_PATH = "../data/"

#if Not defined( FBSOUND_USE_DYNAMIC ) And Not defined( FBSOUND_USE_STATIC )
	'#define FBSOUND_USE_DYNAMIC
	'#define FBSOUND_USE_STATIC
#endif

'' set the DLL path before including fbsound_dynamic.bi to override
Const FBSOUND_DLL_PATH  = ""

#define FBSOUND_USE_STATIC
#include once "mff/fbsound/fbsound.bi"
#include once "mff/fbsound/plug.bi"
#include once "mff/fbsound/plug-static.bi"
#include once "mff/fbsound/fbsound.bas"
#include once "mff/fbsound/plug-ds.bas"
#include once "mff/fbsound/plug-mm.bas"
#include once "mff/fbsound/plug-static.bas"
	
