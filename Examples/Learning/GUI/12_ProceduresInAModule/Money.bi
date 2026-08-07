' Money.bi -- the DECLARATIONS.
'
' A .bi file says what exists. Anything that wants to call these includes this
' file; it does not need to see how they are written.

#pragma once

Const TaxRatePercent As Integer = 20

Declare Function TaxOn(ByVal Amount As Double) As Double
Declare Function MoneyText(ByVal Amount As Double) As String

' A .bi normally holds declarations only. This last part is a FreeBASIC
' convention worth knowing: it pulls in the matching .bas so that including
' one file is enough to both SEE the code and LINK it. Without it the calls
' compile and then fail at link time with "undefined reference", which is a
' confusing error the first time you meet it -- the names were spelled right,
' the code simply was not there.
#ifndef __USE_MAKE__
	#include once "Money.bas"
#endif
