' 11 - ARRAYS
'
' An array holds several values of the same type under one name, reached by
' an index number.

' Five integers, numbered 0 to 4. FreeBASIC arrays start at 0 by default.
Dim As Integer scores(0 To 4)

scores(0) = 85
scores(1) = 92
scores(2) = 78
scores(3) = 95
scores(4) = 60

' LBOUND and UBOUND give the lowest and highest valid index. Using them
' instead of writing 0 and 4 means the loop still works if you resize later.
Print "All scores:"
For i As Integer = LBound(scores) To UBound(scores)
	Print "  scores("; i; ") = "; scores(i)
Next i

' Finding a total and an average.
Dim As Integer total = 0
For i As Integer = LBound(scores) To UBound(scores)
	total = total + scores(i)
Next i
Print
Print "Total:   "; total
Print "Average: "; total / (UBound(scores) - LBound(scores) + 1)

' Finding the largest value: assume the first is biggest, then check the rest.
Dim As Integer highest = scores(LBound(scores))
For i As Integer = LBound(scores) To UBound(scores)
	If scores(i) > highest Then highest = scores(i)
Next i
Print "Highest: "; highest

' You can fill an array as you declare it.
Dim As String days(0 To 2) = {"Mon", "Tue", "Wed"}
Print
Print "Days: "; days(0); " "; days(1); " "; days(2)

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
