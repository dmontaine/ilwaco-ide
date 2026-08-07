' 17 - FIBONACCI: TWO APPROACHES
'
' Each Fibonacci number is the sum of the two before it:
'   1, 1, 2, 3, 5, 8, 13, 21, ...
'
' The same answer computed two ways, to show that HOW you compute matters.

' WITH A LOOP: keeps the last two numbers and moves forward.
Function FibLoop(n As Integer) As LongInt
	If n <= 2 Then Return 1
	Dim As LongInt previous = 1, current = 1, next_ = 0
	For i As Integer = 3 To n
		next_ = previous + current
		previous = current
		current = next_
	Next i
	Return current
End Function

' WITH RECURSION: reads almost like the definition.
Function FibRec(n As Integer) As LongInt
	If n <= 2 Then Return 1
	Return FibRec(n - 1) + FibRec(n - 2)
End Function

Print "The first 15 Fibonacci numbers:"
For i As Integer = 1 To 15
	Print FibLoop(i);
Next i
Print
Print

Print "Both methods agree:"
For i As Integer = 1 To 10
	Print "  n="; i; "  loop="; FibLoop(i); "  recursive="; FibRec(i)
Next i

' BUT THEY ARE NOT EQUALLY GOOD. FibRec recalculates the same values over and
' over: FibRec(30) makes over a million calls, while FibLoop(30) does 28 sums.
' Elegant is not the same as efficient -- try changing 15 to 35 and watch.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
