' 07 - SELECT CASE
'
' When you are testing the SAME value against many possibilities, SELECT CASE
' reads better than a pile of ELSEIFs.

Dim As Integer day = 3

Select Case day
Case 1
	Print "Monday"
Case 2
	Print "Tuesday"
Case 3
	Print "Wednesday"
Case 4, 5
	Print "Nearly the weekend"      ' one CASE can list several values
Case 6 To 7
	Print "Weekend!"                ' or a range
Case Else
	Print "That is not a day number"
End Select

' It works with strings too.
Dim As String answer = "yes"

Select Case LCase(answer)
Case "yes", "y"
	Print "Confirmed."
Case "no", "n"
	Print "Cancelled."
Case Else
	Print "Please answer yes or no."
End Select

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
