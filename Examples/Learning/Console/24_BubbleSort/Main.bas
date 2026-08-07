' 24 - BUBBLE SORT
'
' Sorting is one of the first real algorithms most people meet. Bubble sort is
' the simplest: repeatedly walk the list, swapping any two neighbours that are
' in the wrong order, until a full pass makes no swaps.

Dim As Integer numbers(0 To 9) = {42, 7, 19, 88, 3, 56, 12, 74, 25, 61}

Sub ShowArray(list() As Integer, label As String)
	Print label;
	For i As Integer = LBound(list) To UBound(list)
		Print Using "####"; list(i);
	Next i
	Print
End Sub

ShowArray(numbers(), "Before: ")

Dim As Integer passes = 0
Dim As Boolean swapped

Do
	swapped = False
	passes = passes + 1

	' Each pass pushes the largest remaining value to the end -- which is why
	' the upper limit shrinks by one each time.
	For i As Integer = 0 To UBound(numbers) - passes
		If numbers(i) > numbers(i + 1) Then
			' SWAP exchanges two values. Without it you would need a
			' temporary variable to avoid losing one of them.
			Swap numbers(i), numbers(i + 1)
			swapped = True
		End If
	Next i
Loop While swapped

ShowArray(numbers(), "After:  ")
Print
Print "Sorted in "; passes; " passes."

' Bubble sort is easy to understand and slow: doubling the list roughly
' quadruples the work. Real programs use better algorithms -- but every one of
' them is judged against how you would do it by hand, which is this.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
