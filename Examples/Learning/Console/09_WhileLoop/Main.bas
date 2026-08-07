' 09 - WHILE AND DO LOOPS
'
' Use these when you do not know in advance how many times to repeat.

' WHILE tests BEFORE each pass, so the body may never run at all.
Dim As Integer count = 1
While count <= 5
	Print "count = "; count
	count = count + 1
Wend

' DO ... LOOP UNTIL tests AFTER each pass, so the body always runs at least
' once. Notice the difference -- it matters more often than you would think.
Print
Dim As Integer n = 20
Do
	Print "n = "; n
	n = n - 5
Loop Until n <= 0

' A loop that halves a number until it reaches 1.
Print
Dim As Integer value = 64
Dim As Integer steps = 0
Do While value > 1
	value = value \ 2
	steps = steps + 1
Loop
Print "64 halved "; steps; " times reaches 1"

' THE CLASSIC BUG: forgetting to change the variable the condition tests, so
' the loop never ends. If your program hangs, look here first.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
