' 14 - A SMALL CALCULATOR
'
' Four operations sharing one handler, told apart by the button's .Name.
'
' The interesting line is the division check. Dividing by zero is not a bug in
' your arithmetic -- it is a value the user is allowed to type, and the program
' has to have an answer for it that is not a crash.
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
		Declare Static Sub Op_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblA, lblB, lblResult
		Dim As TextBox txtA, txtB
		Dim As CommandButton cmdAdd, cmdSub, cmdMul, cmdDiv
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
			.Text = "A small calculator"
			.Designer = @This
			.SetBounds 0, 0, 400, 210
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblA
			.Name = "lblA" : .Text = "A:"
			.SetBounds 20, 24, 24, 22
			.Designer = @This : .Parent = @This
		End With
		With txtA
			.Name = "txtA" : .Text = "10"
			.SetBounds 44, 22, 90, 24
			.Designer = @This : .Parent = @This
		End With
		With lblB
			.Name = "lblB" : .Text = "B:"
			.SetBounds 150, 24, 24, 22
			.Designer = @This : .Parent = @This
		End With
		With txtB
			.Name = "txtB" : .Text = "4"
			.SetBounds 174, 22, 90, 24
			.Designer = @This : .Parent = @This
		End With
		With cmdAdd
			.Name = "cmdAdd" : .Text = "+"
			.SetBounds 20, 62, 56, 32
			.Designer = @This : .OnClick = @Op_Click : .Parent = @This
		End With
		With cmdSub
			.Name = "cmdSub" : .Text = "-"
			.SetBounds 84, 62, 56, 32
			.Designer = @This : .OnClick = @Op_Click : .Parent = @This
		End With
		With cmdMul
			.Name = "cmdMul" : .Text = "x"
			.SetBounds 148, 62, 56, 32
			.Designer = @This : .OnClick = @Op_Click : .Parent = @This
		End With
		With cmdDiv
			.Name = "cmdDiv" : .Text = "/"
			.SetBounds 212, 62, 56, 32
			.Designer = @This : .OnClick = @Op_Click : .Parent = @This
		End With
		With lblResult
			.Name = "lblResult" : .Text = "= ?"
			.SetBounds 20, 108, 300, 34
			.Font.Size = 16
			.Designer = @This : .Parent = @This
		End With
	End Constructor

	Sub MainType.Op_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		Dim As Double a = Val(frm->txtA.Text)
		Dim As Double b = Val(frm->txtB.Text)
		Dim As Double answer

		frm->lblResult.ForeColor = clBlack

		' Sender is the button that was pressed, so one handler can serve them
		' all. Compare four near-identical handlers -- this is less to get wrong.
		Select Case Sender.Name
		Case "cmdAdd" : answer = a + b
		Case "cmdSub" : answer = a - b
		Case "cmdMul" : answer = a * b
		Case "cmdDiv"
			If b = 0 Then
				frm->lblResult.Text = "Cannot divide by zero"
				frm->lblResult.ForeColor = clRed
				Exit Sub
			End If
			answer = a / b
		End Select

		frm->lblResult.Text = "= " & Str(answer)
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
