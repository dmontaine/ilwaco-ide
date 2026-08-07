' 09 - MAKING DECISIONS
'
' Exactly the IF/ELSEIF and SELECT CASE from the console examples, except the
' result changes the window instead of printing a line. The logic is the same
' logic; only the output differs.
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

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdGrade_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblPrompt, lblGrade, lblComment
		Dim As TextBox txtScore
		Dim As CommandButton cmdGrade
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
			.Text = "Making decisions"
			.Designer = @This
			.SetBounds 0, 0, 460, 220
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblPrompt
			.Name = "lblPrompt" : .Text = "Score out of 100:"
			.SetBounds 20, 22, 130, 22
			.Designer = @This : .Parent = @This
		End With
		With txtScore
			.Name = "txtScore" : .Text = "72"
			.SetBounds 155, 20, 70, 24
			.Designer = @This : .Parent = @This
		End With
		With cmdGrade
			.Name = "cmdGrade" : .Text = "Grade it"
			.SetBounds 240, 20, 100, 26
			.Designer = @This : .OnClick = @cmdGrade_Click : .Parent = @This
		End With
		With lblGrade
			.Name = "lblGrade" : .Text = ""
			.SetBounds 20, 64, 200, 40
			.Font.Size = 20 : .Font.Bold = True
			.Designer = @This : .Parent = @This
		End With
		With lblComment
			.Name = "lblComment" : .Text = ""
			.SetBounds 20, 112, 400, 40
			.Designer = @This : .Parent = @This
		End With
	End Constructor

	Sub MainType.cmdGrade_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		Dim As Integer score = CInt(Val(frm->txtScore.Text))

		' Guard the impossible values before deciding anything else.
		If score < 0 OrElse score > 100 Then
			frm->lblGrade.Text = "?"
			frm->lblGrade.ForeColor = clRed
			frm->lblComment.Text = "A score has to be between 0 and 100."
			Exit Sub
		End If

		' A chain of ELSEIF stops at the first branch that is true, so the
		' order of the tests IS the logic. Reverse them and everything is an A.
		Dim As String grade
		If score >= 90 Then
			grade = "A"
		ElseIf score >= 80 Then
			grade = "B"
		ElseIf score >= 70 Then
			grade = "C"
		ElseIf score >= 60 Then
			grade = "D"
		Else
			grade = "F"
		End If

		frm->lblGrade.Text = grade
		frm->lblGrade.ForeColor = clBlack

		' SELECT CASE reads better than IF when every branch tests the same
		' thing for a different value.
		Select Case grade
		Case "A" : frm->lblComment.Text = "Outstanding."
		Case "B" : frm->lblComment.Text = "Good work."
		Case "C" : frm->lblComment.Text = "A solid pass."
		Case "D" : frm->lblComment.Text = "Scraped through."
		Case Else : frm->lblComment.Text = "Worth another go."
		End Select
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
