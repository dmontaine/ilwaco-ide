' 23 - DATES AND TIMES
'
' FreeBASIC can tell you the current date and time, and do arithmetic on them.
'
' NOW, YEAR, MONTH, DAY, HOUR and FORMAT are not built in -- they live in
' vbcompat.bi, so it has to be included before you can use them. Leaving this
' line out gives "error 42: Variable not declared, Now", which is a confusing
' message for what is really a missing include.
#include once "vbcompat.bi"

Print "Today is:  "; Date
Print "The time:  "; Time
Print

' NOW gives a single value holding both, as a serial number.
Dim As Double rightNow = Now
Print "Now as a number: "; rightNow
Print "Formatted:       "; Format(rightNow, "yyyy-mm-dd hh:mm:ss")
Print

' Pulling out the parts.
Print "Year:  "; Year(rightNow)
Print "Month: "; Month(rightNow)
Print "Day:   "; Day(rightNow)
Print "Hour:  "; Hour(rightNow)

' Because it is a number, you can do arithmetic with it. Adding 1 adds a day.
Print
Print "Tomorrow:      "; Format(rightNow + 1, "yyyy-mm-dd")
Print "This time last week: "; Format(rightNow - 7, "yyyy-mm-dd")

' TIMER counts seconds since midnight, and is the usual way to measure how
' long a piece of code takes.
Dim As Double startTime = Timer
Dim As LongInt total = 0
For i As Integer = 1 To 3000000
	total = total + i
Next i
Dim As Double elapsed = Timer - startTime

Print
Print "Adding 3,000,000 numbers took "; elapsed; " seconds"
Print "The total was "; total

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
