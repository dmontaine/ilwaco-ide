' Convert.bas -- the conversions themselves.
'
' Nothing in this file knows a window exists. That is the test of whether code
' belongs in a module: could it be used by a program with no interface at all?

#include once "Convert.bi"
#include once "vbcompat.bi"   ' Format lives here

Function CToF(ByVal C As Double) As Double
	Return C * 9 / 5 + 32
End Function

Function CToK(ByVal C As Double) As Double
	Return C + 273.15
End Function

Function DescribeC(ByVal C As Double) As String
	Return Format(C, "0.0") & " C  =  " & Format(CToF(C), "0.0") & " F"
End Function
