' 03 - READING INPUT
'
' INPUT stops the program, waits for the user to type something and press
' Enter, then stores it in a variable.

Dim As String userName
Dim As Integer userAge

' The text before the semicolon is the prompt.
Input "What is your name? "; userName
Input "How old are you?  "; userAge

Print
Print "Hello, "; userName; "!"
Print "Next year you will be "; userAge + 1

' CAREFUL: if the user types letters when you asked for a number, FreeBASIC
' stores 0 rather than complaining. Real programs must check their input --
' see 25_BinarySearch for a validation example.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
