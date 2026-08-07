' 08 - FOR LOOPS
'
' A FOR loop repeats a block a known number of times, counting as it goes.

Print "Counting up:"
For i As Integer = 1 To 5
	Print "  i = "; i
Next i

' STEP changes the size of each jump.
Print
Print "Even numbers:"
For i As Integer = 2 To 10 Step 2
	Print "  "; i;
Next i
Print

' A negative STEP counts down.
Print
Print "Countdown:"
For i As Integer = 5 To 1 Step -1
	Print "  "; i;
Next i
Print
Print "  Lift off!"

' The counter variable is declared in the loop itself, so it only exists
' inside it. That is a good habit: it cannot be changed by accident later.

' Summing with a loop is one of the most common patterns in programming.
Dim As Integer total = 0
For i As Integer = 1 To 100
	total = total + i
Next i
Print
Print "1 + 2 + ... + 100 = "; total

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
