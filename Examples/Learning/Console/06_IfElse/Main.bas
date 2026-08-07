' 06 - MAKING DECISIONS
'
' IF runs a block of code only when a condition is true.

Dim As Integer score = 72

If score >= 90 Then
	Print "Grade: A"
ElseIf score >= 80 Then
	Print "Grade: B"
ElseIf score >= 70 Then
	Print "Grade: C"
Else
	Print "Grade: F"
End If

' The comparison operators:
'   =   equal to            <>  not equal to
'   <   less than           >   greater than
'   <=  less or equal       >=  greater or equal
Print
Print "score = 72"
Print "score > 50  is "; score > 50
Print "score = 100 is "; score = 100

' NOTE: FreeBASIC prints True as -1 and False as 0 when the value is a plain
' number. That is normal and worth knowing before it confuses you.

' Conditions can be combined with AND, OR and NOT.
Dim As Integer age = 20
Dim As Integer ticket = 1
If age >= 18 AndAlso ticket = 1 Then
	Print "Admitted."
End If

' ANDALSO / ORELSE stop as soon as the answer is known, which is usually what
' you want. AND / OR always test both sides.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
