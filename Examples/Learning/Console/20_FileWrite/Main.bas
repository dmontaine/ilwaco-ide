' 20 - WRITING A FILE
'
' Files let a program keep information after it stops running.
'
' The pattern is always the same: OPEN, use, CLOSE.

Dim As Integer fileNum = FreeFile      ' ask for an unused file number

' FOR OUTPUT creates the file, or REPLACES it if it already exists.
' FOR APPEND would add to the end of an existing file instead.
Open "notes.txt" For Output As #fileNum

Print #fileNum, "Shopping list"
Print #fileNum, "-------------"
Print #fileNum, "Bread"
Print #fileNum, "Milk"
Print #fileNum, "Coffee"

Close #fileNum

Print "Wrote notes.txt"
Print

' Writing a table of values a loop produced.
fileNum = FreeFile
Open "squares.txt" For Output As #fileNum
For i As Integer = 1 To 10
	Print #fileNum, i; " squared is "; i * i
Next i
Close #fileNum

Print "Wrote squares.txt"
Print
Print "Both files are in the same folder as this program."
Print "Open them in Ilwaco to see what came out, then run 21_FileRead."

' ALWAYS CLOSE what you open. Data can sit in a buffer unwritten until you do,
' and an unclosed file stays locked against other programs.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
