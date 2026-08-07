' 05 - WORKING WITH STRINGS
'
' A string is a piece of text. FreeBASIC gives you functions to inspect and
' cut them up.

Dim As String first = "Grace"
Dim As String last  = "Hopper"

' & joins strings together (this is called concatenation).
Dim As String full = first & " " & last
Print "Full name: "; full

' LEN counts the characters.
Print "Length:    "; Len(full)

' UCASE and LCASE change case. They return a NEW string; the original is
' unchanged.
Print "Upper:     "; UCase(full)
Print "Lower:     "; LCase(full)

' LEFT, RIGHT and MID take pieces out.
'   Mid(text, start, count) -- start counts from 1, not 0.
Print "First 5:   "; Left(full, 5)
Print "Last 6:    "; Right(full, 6)
Print "Middle:    "; Mid(full, 7, 6)

' INSTR finds one string inside another, returning the position or 0.
Print "Where is 'Hop'? "; InStr(full, "Hop")
Print "Where is 'zzz'? "; InStr(full, "zzz"); " (0 means not found)"

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
