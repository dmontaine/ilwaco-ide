' 25 - BINARY SEARCH
'
' To find a value in a SORTED list, you do not have to look at every item.
' Check the middle: if it is too big, the answer is in the left half; too
' small, the right half. Each guess throws away half of what is left.

Dim As Integer sorted_(0 To 14) = {2, 5, 8, 12, 16, 23, 38, 45, 56, 67, 72, 81, 88, 94, 99}

Function BinarySearch(list() As Integer, target As Integer) As Integer
	Dim As Integer low = LBound(list)
	Dim As Integer high = UBound(list)
	Dim As Integer guesses = 0

	While low <= high
		Dim As Integer middle = (low + high) \ 2
		guesses = guesses + 1

		If list(middle) = target Then
			Print "  found after "; guesses; " guess(es)"
			Return middle
		ElseIf list(middle) < target Then
			low = middle + 1        ' too small: discard the left half
		Else
			high = middle - 1       ' too big: discard the right half
		End If
	Wend

	Print "  not found after "; guesses; " guess(es)"
	Return -1                       ' -1 is a common way to say "no result"
End Function

Print "The list:"
For i As Integer = 0 To 14
	Print Using "####"; sorted_(i);
Next i
Print
Print

Print "Searching for 67:"
Dim As Integer found = BinarySearch(sorted_(), 67)
Print "  index = "; found

Print
Print "Searching for 50 (not in the list):"
found = BinarySearch(sorted_(), 50)
Print "  index = "; found

' 15 items need at most 4 guesses. 1000 items need 10. A million need 20.
' THE LIST MUST BE SORTED -- on unsorted data this returns confident nonsense,
' which is worse than being slow.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
