'' FreeBASIC binding for DevIL-1.8.0
''
'' based on the C header files:
''    ImageLib Utility Toolkit Sources
''    Copyright (C) 2000-2017 by Denton Woods
''    Last modified: 03/07/2009
''
''    Filename: IL/ilut.h
''
''    Description: The main include file for ILUT
''
''   This library is free software; you can redistribute it and/or
''   modify it under the terms of the GNU Lesser General Public
''   License as published by the Free Software Foundation; either
''   version 2.1 of the License, or (at your option) any later version.
''
''   This library is distributed in the hope that it will be useful,
''   but WITHOUT ANY WARRANTY; without even the implied warranty of
''   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
''   Lesser General Public License for more details.
''
''   You should have received a copy of the GNU Lesser General Public
''   License along with this library; if not, write to the Free Software
''   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
''   USA
''
'' translated to FreeBASIC by:
''   FreeBASIC development team

#pragma once

#inclib "ILUT"

#include once "IL/il.bi"
#include once "IL/ilu.bi"

	extern "C"

#define __ilut_h_
#define __ILUT_H__
const ILUT_VERSION_1_8_0 = 1
const ILUT_VERSION = 180
const ILUT_OPENGL_BIT = &h00000001
const ILUT_D3D_BIT = &h00000002
const ILUT_ALL_ATTRIB_BITS = &h000FFFFF
const ILUT_INVALID_ENUM = &h0501
const ILUT_OUT_OF_MEMORY = &h0502
const ILUT_INVALID_VALUE = &h0505
const ILUT_ILLEGAL_OPERATION = &h0506
const ILUT_INVALID_PARAM = &h0509
const ILUT_COULD_NOT_OPEN_FILE = &h050A
const ILUT_STACK_OVERFLOW = &h050E
const ILUT_STACK_UNDERFLOW = &h050F
const ILUT_BAD_DIMENSIONS = &h0511
const ILUT_NOT_SUPPORTED = &h0550
const ILUT_PALETTE_MODE = &h0600
const ILUT_OPENGL_CONV = &h0610
const ILUT_D3D_MIPLEVELS = &h0620
const ILUT_MAXTEX_WIDTH = &h0630
const ILUT_MAXTEX_HEIGHT = &h0631
const ILUT_MAXTEX_DEPTH = &h0632
const ILUT_GL_USE_S3TC = &h0634
const ILUT_D3D_USE_DXTC = &h0634
const ILUT_GL_GEN_S3TC = &h0635
const ILUT_D3D_GEN_DXTC = &h0635
const ILUT_S3TC_FORMAT = &h0705
const ILUT_DXTC_FORMAT = &h0705
const ILUT_D3D_POOL = &h0706
const ILUT_D3D_ALPHA_KEY_COLOR = &h0707
const ILUT_D3D_ALPHA_KEY_COLOUR = &h0707
const ILUT_FORCE_INTEGER_FORMAT = &h0636
const ILUT_GL_AUTODETECT_TEXTURE_TARGET = &h0807
const ILUT_VERSION_NUM = IL_VERSION_NUM
const ILUT_VENDOR = IL_VENDOR
const ILUT_OPENGL = 0
const ILUT_ALLEGRO = 1
const ILUT_WIN32 = 2
const ILUT_DIRECT3D8 = 3
const ILUT_DIRECT3D9 = 4
const ILUT_X11 = 5
const ILUT_DIRECT3D10 = 6


declare function ilutDisable(byval Mode as ILenum) as ILboolean
declare function ilutEnable(byval Mode as ILenum) as ILboolean
declare function ilutGetBoolean(byval Mode as ILenum) as ILboolean
declare sub ilutGetBooleanv(byval Mode as ILenum, byval Param as ILboolean ptr)
declare function ilutGetInteger(byval Mode as ILenum) as ILint
declare sub ilutGetIntegerv(byval Mode as ILenum, byval Param as ILint ptr)
declare function ilutGetString(byval StringName as ILenum) as zstring ptr
declare sub ilutInit()
declare function ilutIsDisabled(byval Mode as ILenum) as ILboolean
declare function ilutIsEnabled(byval Mode as ILenum) as ILboolean
declare sub ilutPopAttrib()
declare sub ilutPushAttrib(byval Bits as ILuint)
declare sub ilutSetInteger(byval Mode as ILenum, byval Param as ILint)
declare function ilutRenderer(byval Renderer as ILenum) as ILboolean


end extern
