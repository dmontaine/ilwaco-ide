' 16 - RECURSION
'
' A recursive function calls itself with a smaller version of the problem,
' until it reaches a case simple enough to answer directly.

' Factorial: 5! = 5 x 4 x 3 x 2 x 1 = 120
Function Factorial(n As Integer) As LongInt
	' THE BASE CASE. Without one, the function calls itself forever and the
	' program crashes when it runs out of stack. Always write this first.
	If n <= 1 Then Return 1

	' THE RECURSIVE CASE: a smaller problem of the same shape.
	Return n * Factorial(n - 1)
End Function

For i As Integer = 1 To 10
	Print "  "; i; "! = "; Factorial(i)
Next i

' Counting down, to show the calls unwinding.
Sub Countdown(n As Integer)
	If n < 0 Then Return
	Print "  "; n
	Countdown(n - 1)
End Sub

Print
Print "Countdown from 5:"
Countdown(5)

' Recursion is elegant where the problem is naturally nested -- folder trees,
' parsing, sorting. For simple counting, a loop is usually clearer and faster.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
