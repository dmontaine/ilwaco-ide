' 22 - RANDOM NUMBERS
'
' RND gives a random number from 0 up to (but not including) 1.

' WITHOUT Randomize, a program produces the SAME "random" numbers every run.
' That is useful when testing; it is not what you want in a game.
Randomize Timer          ' Timer changes constantly, so each run differs

Print "Five raw random numbers:"
For i As Integer = 1 To 5
	Print "  "; Rnd
Next i

' To get a whole number in a range, scale it and use Int.
'   Int(Rnd * n) + low   gives low .. low + n - 1
Print
Print "Five dice rolls:"
For i As Integer = 1 To 5
	Dim As Integer roll = Int(Rnd * 6) + 1
	Print "  "; roll
Next i

' Counting outcomes: with enough rolls each face should appear about 1/6 of
' the time. This is how you check a random generator behaves.
Dim As Integer counts(1 To 6)
For i As Integer = 1 To 6000
	Dim As Integer roll = Int(Rnd * 6) + 1
	counts(roll) = counts(roll) + 1
Next i

Print
Print "6000 rolls:"
For face As Integer = 1 To 6
	Print "  face "; face; " came up "; counts(face); " times"
Next face

' Picking a random item from a list.
Dim As String colours(0 To 3) = {"red", "green", "blue", "yellow"}
Print
Print "A random colour: "; colours(Int(Rnd * 4))

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
