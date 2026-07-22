#pragma once

Const TESTS_DATA_PATH = "../../Resources/"

#if Not defined( FBSOUND_USE_DYNAMIC ) And Not defined( FBSOUND_USE_STATIC )
'#define FBSOUND_USE_DYNAMIC
#define FBSOUND_USE_STATIC
#endif

'' set the DLL path before including fbsound_dynamic.bi to override
Const FBSOUND_DLL_PATH  = ""

