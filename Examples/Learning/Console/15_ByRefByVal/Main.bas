' 15 - BYVAL AND BYREF
'
' When you pass a variable to a procedure, FreeBASIC can pass either a COPY of
' it or the variable ITSELF. The difference decides whether the procedure can
' change your original.

' BYVAL gets a copy. Changing it inside affects nothing outside.
Sub TryToChange(ByVal n As Integer)
	n = 999
End Sub

' BYREF gets the variable itself. Changing it DOES affect the caller.
Sub ReallyChange(ByRef n As Integer)
	n = 999
End Sub

Dim As Integer value = 1

TryToChange(value)
Print "After TryToChange(value):  "; value; "   (unchanged -- it got a copy)"

ReallyChange(value)
Print "After ReallyChange(value): "; value; "   (changed -- it got the variable)"

' The classic use of BYREF: a procedure that must return more than one thing.
Sub MinAndMax(ByVal a As Integer, ByVal b As Integer, _
              ByRef smallest As Integer, ByRef largest As Integer)
	If a < b Then
		smallest = a : largest = b
	Else
		smallest = b : largest = a
	End If
End Sub

Dim As Integer lo, hi
MinAndMax(42, 17, lo, hi)
Print
Print "MinAndMax(42, 17) gives lo="; lo; " hi="; hi

' Use BYVAL unless you mean to change the caller's variable. A procedure that
' modifies its arguments unexpectedly is a hard bug to find.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
