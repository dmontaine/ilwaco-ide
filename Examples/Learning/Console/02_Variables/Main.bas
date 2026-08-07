' 02 - VARIABLES
'
' A variable is a named box holding a value. You DIM it (declare it) once,
' saying what TYPE of thing it holds, then assign values with =.

Dim As Integer age          ' whole numbers
Dim As Double  price        ' numbers with a fractional part
Dim As String  personName   ' text

age = 21
price = 4.99
personName = "Ada"

Print "Name:  "; personName
Print "Age:   "; age
Print "Price: "; price

' You can declare and assign in one line.
Dim As Integer year = 2026
Print "Year:  "; year

' TYPES MATTER. An Integer cannot hold a fraction -- assigning one rounds it.
Dim As Integer whole = 7.8
Print "7.8 stored in an Integer becomes: "; whole

' Choosing the wrong type is one of the commonest beginner bugs, and the
' compiler will not always warn you.

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
