' 13 - PROCEDURES (SUBS)
'
' A SUB is a named block of code you can run whenever you like. It groups
' work under a name, so the main program reads as a list of steps.

' A sub that takes no information.
Sub PrintBanner()
	Print "=============================="
End Sub

' A sub that takes PARAMETERS -- values passed in when you call it.
Sub Greet(personName As String)
	Print "Hello, "; personName; "!"
End Sub

Sub PrintRepeated(text As String, times As Integer)
	For i As Integer = 1 To times
		Print text;
	Next i
	Print
End Sub

' The main program.
PrintBanner()
Greet("Alan")
Greet("Grace")
PrintBanner()

PrintRepeated("-=", 10)

' WHY BOTHER? Three reasons, and they get more important as programs grow:
'   1. You write the code once and use it many times.
'   2. A good name explains what the code does, so the main program is readable.
'   3. When it is wrong, there is exactly one place to fix it.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
