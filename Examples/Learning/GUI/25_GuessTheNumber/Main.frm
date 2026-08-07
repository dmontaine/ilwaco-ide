' 25 - GUESS THE NUMBER
'
' Everything so far, in one program: input, validation, decisions, state that
' survives between clicks, and a module.
'
' The split is the lesson. Game.bas knows the rules -- what the secret is, what
' a guess is worth, when it is over. Main.frm knows the window. Neither knows
' anything about the other's job, so you could put this game behind a console,
' a web page or a phone screen without touching Game.bas at all.
'
' That separation has a name -- keeping the logic out of the interface -- and
' it is the single habit that most reliably keeps a growing program readable.
'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Main.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Graphics.bi"
	#include once "Game.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdGuess_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdNew_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub StartRound()

		Dim As Label lblPrompt, lblVerdict, lblScore
		Dim As TextBox txtGuess
		Dim As CommandButton cmdGuess, cmdNew
	End Type

	Constructor MainType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/Languages/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		With This
			.Name = "Main"
			.Text = "Guess the number"
			.Designer = @This
			.SetBounds 0, 0, 460, 200
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblPrompt
			.Name = "lblPrompt"
			.Text = "I am thinking of a number between 1 and 100."
			.SetBounds 20, 18, 400, 22
			.Designer = @This : .Parent = @This
		End With
		With txtGuess
			.Name = "txtGuess" : .Text = "50"
			.SetBounds 20, 48, 80, 24
			.Designer = @This : .Parent = @This
		End With
		With cmdGuess
			.Name = "cmdGuess" : .Text = "Guess"
			.SetBounds 110, 47, 90, 26
			.Designer = @This : .OnClick = @cmdGuess_Click : .Parent = @This
		End With
		With cmdNew
			.Name = "cmdNew" : .Text = "New game"
			.SetBounds 210, 47, 100, 26
			.Designer = @This : .OnClick = @cmdNew_Click : .Parent = @This
		End With
		With lblVerdict
			.Name = "lblVerdict" : .Text = ""
			.SetBounds 20, 88, 400, 30
			.Font.Size = 13
			.Designer = @This : .Parent = @This
		End With
		With lblScore
			.Name = "lblScore" : .Text = ""
			.SetBounds 20, 124, 400, 22
			.Designer = @This : .Parent = @This
		End With

		StartRound()
	End Constructor

	Sub MainType.StartRound()
		NewGame()                       ' the module picks a fresh secret
		lblVerdict.Text = "Make your first guess."
		lblVerdict.ForeColor = clBlack
		lblScore.Text = "Guesses: 0"
		txtGuess.Text = "50"
	End Sub

	Sub MainType.cmdNew_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		frm->StartRound()
	End Sub

	Sub MainType.cmdGuess_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)

		If GameOver() Then
			frm->lblVerdict.Text = "That round is over -- press New game."
			Exit Sub
		End If

		Dim As Integer guess = CInt(Val(frm->txtGuess.Text))
		If guess < 1 OrElse guess > 100 Then
			frm->lblVerdict.Text = "Between 1 and 100, please."
			frm->lblVerdict.ForeColor = clRed
			Exit Sub
		End If

		' The window asks the module what the guess was worth. It does not
		' know the secret, and does not need to.
		Dim As Integer verdict = JudgeGuess(guess)
		frm->lblVerdict.ForeColor = clBlack

		Select Case verdict
		Case GUESS_LOW  : frm->lblVerdict.Text = Str(guess) & " is too low."
		Case GUESS_HIGH : frm->lblVerdict.Text = Str(guess) & " is too high."
		Case Else
			frm->lblVerdict.Text = "Correct! It was " & Str(guess) & "."
		End Select

		frm->lblScore.Text = "Guesses: " & Str(GuessCount())
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
