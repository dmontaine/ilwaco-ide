#pragma once

Dim Shared As Boolean g_darkModeSupported
Dim Shared As Boolean g_darkModeEnabled

#define nullptr 0
Declare Sub SetDarkMode(useDarkMode As Boolean, fixDarkScrollbar As Boolean)

#ifndef __USE_MAKE__
	#include once "DarkMode.bas"
#endif
