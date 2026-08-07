' Game.bi -- the rules of the game, as seen from outside.
'
' Nothing here mentions a window. Anything that can call a function can play.

#pragma once

Const GUESS_LOW   As Integer = -1
Const GUESS_RIGHT As Integer = 0
Const GUESS_HIGH  As Integer = 1

Declare Sub NewGame()
Declare Function JudgeGuess(ByVal Guess As Integer) As Integer
Declare Function GuessCount() As Integer
Declare Function GameOver() As Boolean

' A .bi normally holds declarations only. This last part is a FreeBASIC
' convention worth knowing: it pulls in the matching .bas so that including
' one file is enough to both SEE the code and LINK it. Without it the calls
' compile and then fail at link time with "undefined reference", which is a
' confusing error the first time you meet it -- the names were spelled right,
' the code simply was not there.
#ifndef __USE_MAKE__
	#include once "Game.bas"
#endif
