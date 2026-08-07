' 18 - CONSTANTS AND ENUMS
'
' A CONST is a value that never changes. Naming one explains what a number
' means and stops it being mistyped in one place out of twenty.

Const PI = 3.14159265
Const MAX_STUDENTS = 30
Const APP_NAME = "Class Register"

Print APP_NAME
Print "Room capacity: "; MAX_STUDENTS
Print

Dim As Double radius = 5.0
Print "Circle of radius "; radius
Print "  circumference = "; 2 * PI * radius
Print "  area          = "; PI * radius ^ 2

' Trying to assign to a constant is a compile error, which is the point:
' the compiler catches the mistake instead of your users.

' An ENUM names a set of related values, so you write Wednesday instead of 3.
Enum Weekday
	Monday = 1
	Tuesday
	Wednesday
	Thursday
	Friday
End Enum

' Values continue from the last one given, so Tuesday is 2, Wednesday 3...
Dim As Weekday today = Wednesday
Print
Print "today (as a number) = "; today

If today = Wednesday Then Print "Midweek."

' Compare the two versions of the same test:
'     If today = 3 Then ...            what is 3?
'     If today = Wednesday Then ...    obvious

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
