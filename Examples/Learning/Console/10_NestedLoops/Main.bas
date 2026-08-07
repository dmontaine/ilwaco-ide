' 10 - NESTED LOOPS
'
' Putting one loop inside another lets you work through rows and columns.
' The inner loop runs completely for EACH pass of the outer loop.

Print "Times tables, 1 to 5:"
Print

For row As Integer = 1 To 5
	For col As Integer = 1 To 5
		' Print with a trailing semicolon stays on the same line.
		Print Using "####"; row * col;
	Next col
	Print          ' end the row
Next row

' A triangle of stars -- the inner loop's limit depends on the outer counter.
Print
For i As Integer = 1 To 5
	For j As Integer = 1 To i
		Print "*";
	Next j
	Print
Next i

' Nested loops multiply: 5 rows x 5 columns is 25 passes of the inner body.
' Three levels deep on a large range gets slow very quickly.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
