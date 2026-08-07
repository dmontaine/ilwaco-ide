' 13 - FUNCTIONS THAT GIVE AN ANSWER BACK
'
' A SUB does something. A FUNCTION does something and hands a value back.
'
' The handler below reads as a sentence because the work is in functions with
' names that say what they produce. Compare the same code with the loops
' written out inline: it would work identically and be much harder to trust.
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

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdCheck_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Function Reversed(ByRef s As String) As String
		Declare Static Function IsPalindrome(ByRef s As String) As Boolean
		Declare Static Function VowelCount(ByRef s As String) As Integer

		Dim As Label lblPrompt, lblReversed, lblVowels, lblVerdict
		Dim As TextBox txtWord
		Dim As CommandButton cmdCheck
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
			.Text = "Functions that give an answer back"
			.Designer = @This
			.SetBounds 0, 0, 480, 200
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblPrompt
			.Name = "lblPrompt" : .Text = "A word or phrase:"
			.SetBounds 20, 22, 130, 22
			.Designer = @This : .Parent = @This
		End With
		With txtWord
			.Name = "txtWord" : .Text = "level"
			.SetBounds 155, 20, 180, 24
			.Designer = @This : .Parent = @This
		End With
		With cmdCheck
			.Name = "cmdCheck" : .Text = "Examine"
			.SetBounds 350, 20, 90, 26
			.Designer = @This : .OnClick = @cmdCheck_Click : .Parent = @This
		End With
		With lblReversed
			.Name = "lblReversed" : .Text = ""
			.SetBounds 20, 62, 420, 22
			.Designer = @This : .Parent = @This
		End With
		With lblVowels
			.Name = "lblVowels" : .Text = ""
			.SetBounds 20, 88, 420, 22
			.Designer = @This : .Parent = @This
		End With
		With lblVerdict
			.Name = "lblVerdict" : .Text = ""
			.SetBounds 20, 118, 420, 22
			.Font.Bold = True
			.Designer = @This : .Parent = @This
		End With
	End Constructor

	Function MainType.Reversed(ByRef s As String) As String
		Dim As String r
		For i As Integer = Len(s) To 1 Step -1
			r &= Mid(s, i, 1)
		Next i
		Return r
	End Function

	Function MainType.VowelCount(ByRef s As String) As Integer
		Dim As Integer n = 0
		Dim As String lower = LCase(s)
		For i As Integer = 1 To Len(lower)
			Select Case Mid(lower, i, 1)
			Case "a", "e", "i", "o", "u" : n += 1
			End Select
		Next i
		Return n
	End Function

	' A function is free to call another one. IsPalindrome does not repeat the
	' reversing code -- it asks Reversed for the answer.
	Function MainType.IsPalindrome(ByRef s As String) As Boolean
		Dim As String clean = LCase(Trim(s))
		Return clean = Reversed(clean)
	End Function

	Sub MainType.cmdCheck_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		Dim As String word = frm->txtWord.Text

		frm->lblReversed.Text = "Backwards: " & Reversed(word)
		frm->lblVowels.Text   = "Vowels:    " & Str(VowelCount(word))

		If IsPalindrome(word) Then
			frm->lblVerdict.Text = "It reads the same both ways."
		Else
			frm->lblVerdict.Text = "It is not a palindrome."
		End If
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
