' 12 - TWO-DIMENSIONAL ARRAYS
'
' A 2D array is a grid. The first index is usually the row, the second the
' column -- but that is a convention you choose, not a rule.

Dim As Integer grid(0 To 2, 0 To 3)     ' 3 rows, 4 columns

' Fill it with row x column.
For r As Integer = 0 To 2
	For c As Integer = 0 To 3
		grid(r, c) = (r + 1) * (c + 1)
	Next c
Next r

Print "The grid:"
For r As Integer = 0 To 2
	For c As Integer = 0 To 3
		Print Using "#####"; grid(r, c);
	Next c
	Print
Next r

' Totalling one row.
Dim As Integer rowTotal = 0
For c As Integer = 0 To 3
	rowTotal = rowTotal + grid(1, c)
Next c
Print
Print "Total of row 1: "; rowTotal

' Totalling one column -- note which index moves.
Dim As Integer colTotal = 0
For r As Integer = 0 To 2
	colTotal = colTotal + grid(r, 2)
Next r
Print "Total of column 2: "; colTotal

' A noughts-and-crosses board is just a 2D array of strings.
Dim As String board(0 To 2, 0 To 2)
For r As Integer = 0 To 2
	For c As Integer = 0 To 2
		board(r, c) = "."
	Next c
Next r
board(1, 1) = "X"
Print
For r As Integer = 0 To 2
	Print "  "; board(r, 0); board(r, 1); board(r, 2)
Next r

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
