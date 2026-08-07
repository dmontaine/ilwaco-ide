' 19 - USER-DEFINED TYPES
'
' A TYPE groups several values into one thing you can pass around as a unit.
' Other languages call this a record or a struct.

Type Student
	As String  name
	As Integer age
	As Double  average
End Type

' Declare one and fill in its FIELDS with a dot.
Dim As Student pupil
pupil.name = "Kim"
pupil.age = 17
pupil.average = 82.5

Print "Name:    "; pupil.name
Print "Age:     "; pupil.age
Print "Average: "; pupil.average

' The real gain: an ARRAY of them. One name holds a whole class, and each
' entry keeps its fields together.
Dim As Student class_(0 To 2)

class_(0).name = "Ana"  : class_(0).age = 16 : class_(0).average = 91.0
class_(1).name = "Ben"  : class_(1).age = 17 : class_(1).average = 74.5
class_(2).name = "Cara" : class_(2).age = 16 : class_(2).average = 88.0

Print
Print "The class:"
For i As Integer = 0 To 2
	Print "  "; class_(i).name; " (age "; class_(i).age; ") average "; class_(i).average
Next i

' Find the best average -- the same pattern as 11_Arrays, but on a field.
Dim As Integer best = 0
For i As Integer = 1 To 2
	If class_(i).average > class_(best).average Then best = i
Next i
Print
Print "Top of the class: "; class_(best).name

' A TYPE can be passed to a procedure like any other value. Pass it BYREF to
' avoid copying the whole thing.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
