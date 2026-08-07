' Game.bas -- the rules themselves.
'
' The secret is declared PRIVATE, so nothing outside this file can read it. That
' is deliberate: the window cannot accidentally cheat, and it cannot come to
' depend on how the game is stored. Change the whole thing to a random word
' instead of a number and only this file changes.

#include once "Game.bi"

Private Dim Shared As Integer Secret
Private Dim Shared As Integer Guesses
Private Dim Shared As Boolean Finished

Sub NewGame()
	Randomize Timer
	Secret = Int(Rnd * 100) + 1
	Guesses = 0
	Finished = False
End Sub

Function JudgeGuess(ByVal Guess As Integer) As Integer
	Guesses += 1
	If Guess < Secret Then Return GUESS_LOW
	If Guess > Secret Then Return GUESS_HIGH
	Finished = True
	Return GUESS_RIGHT
End Function

Function GuessCount() As Integer
	Return Guesses
End Function

Function GameOver() As Boolean
	Return Finished
End Function
