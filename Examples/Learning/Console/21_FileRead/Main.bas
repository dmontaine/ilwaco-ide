' 21 - READING A FILE
'
' The companion to 20_FileWrite. Note that it does NOT simply read the file
' that one wrote: each project builds and runs in its own folder, so 20's
' notes.txt is over in 20_FileWrite. A program that quietly depends on a file
' someone else left lying around is the usual reason for "it works on my
' machine", so this one makes its own if it cannot find one.

Dim As Integer fileNum = FreeFile
Dim As String  fileName = "notes.txt"

' CHECK BEFORE YOU OPEN. A file that is not there is a normal thing to happen,
' not a crash -- OPEN reports it by returning non-zero, and it is up to you to
' look. Ignoring that return is how a program ends up reading nothing at all
' and cheerfully announcing success.
If Open(fileName For Input As #fileNum) <> 0 Then
	Print "No "; fileName; " here yet, so let's write one first."
	Print

	' FreeFile does not RESERVE the number it gives you -- it reports the
	' lowest free one. Ask again for each file rather than reusing a variable.
	Dim As Integer outNum = FreeFile
	Open fileName For Output As #outNum
	Print #outNum, "Shopping list"
	Print #outNum, "-------------"
	Print #outNum, "Bread"
	Print #outNum, "Milk"
	Print #outNum, "Coffee"
	Close #outNum

	fileNum = FreeFile
	Open fileName For Input As #fileNum
End If

Print "Contents of "; fileName; ":"
Print

Dim As String lineText
Dim As Integer lineCount = 0

' EOF stands for End Of File: true once there is nothing left to read.
Do Until EOF(fileNum)
	Line Input #fileNum, lineText
	lineCount = lineCount + 1
	Print "  "; lineCount; ": "; lineText
Loop

Close #fileNum

Print
Print "Read "; lineCount; " lines."

' LINE INPUT reads a whole line including spaces. Plain INPUT # would stop at
' the first comma, which is rarely what you want for ordinary text.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
