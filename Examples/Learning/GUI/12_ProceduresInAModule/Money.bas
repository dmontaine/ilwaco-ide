' Money.bas -- the CODE.
'
' A .bas file holds the working parts. It includes its own .bi so the compiler
' can check that what is written here matches what was promised there -- a
' mismatch is caught at build time rather than at run time.

#include once "Money.bi"
#include once "vbcompat.bi"   ' Format lives here

Function TaxOn(ByVal Amount As Double) As Double
	If Amount <= 0 Then Return 0
	Return Amount * TaxRatePercent / 100
End Function

' Formatting is a good example of code worth naming. Written out at each of
' the three places it is needed, one of them eventually gets it wrong.
Function MoneyText(ByVal Amount As Double) As String
	Return Format(Amount, "0.00")
End Function
