' 04 - ARITHMETIC
'
' The usual operators, and two that surprise people.

Dim As Integer a = 17
Dim As Integer b = 5

Print "a = "; a; "   b = "; b
Print
Print "a + b  = "; a + b
Print "a - b  = "; a - b
Print "a * b  = "; a * b

' TWO KINDS OF DIVISION, and this catches everyone once.
'   /  gives the true answer, including the fraction
'   \  divides and throws the remainder away
Print "a / b  = "; a / b;  "   (true division)"
Print "a \ b  = "; a \ b;  "   (integer division)"

' MOD gives the remainder -- what is left over after integer division.
Print "a MOD b = "; a Mod b; "   (remainder)"

' ^ raises to a power.
Print "b ^ 2  = "; b ^ 2

' Order of operations follows normal maths: * and / before + and -.
' Use brackets when you want a different order, or just for clarity.
Print
Print "2 + 3 * 4   = "; 2 + 3 * 4
Print "(2 + 3) * 4 = "; (2 + 3) * 4

' ---------------------------------------------------------------------------
' Keeps the window open so you can read the output. Sleep with no argument
' waits for a keypress.
Print
Print "Press any key to close..."
Sleep
