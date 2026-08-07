' 14 - FUNCTIONS
'
' A FUNCTION is like a SUB, but it hands a value back to whoever called it.
' You must say what type that value is.

Function Square(n As Integer) As Integer
	Return n * n
End Function

Function Larger(a As Integer, b As Integer) As Integer
	If a > b Then
		Return a
	Else
		Return b
	End If
End Function

Function Celsius(fahrenheit As Double) As Double
	Return (fahrenheit - 32.0) * 5.0 / 9.0
End Function

' A function returning a string.
Function Initials(first As String, last As String) As String
	Return Left(first, 1) & "." & Left(last, 1) & "."
End Function

Print "Square(7)        = "; Square(7)
Print "Larger(12, 30)   = "; Larger(12, 30)
Print "Celsius(212)     = "; Celsius(212.0)
Print "Initials         = "; Initials("Ada", "Lovelace")

' Because a function produces a value, you can use it anywhere a value fits --
' including inside another call.
Print "Square(Square(3)) = "; Square(Square(3))

Dim As Integer total = Square(2) + Square(3)
Print "Square(2)+Square(3) = "; total

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
