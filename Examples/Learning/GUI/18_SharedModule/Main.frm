' 18 - ONE MODULE, TWO FORMS
'
' 12 showed how to make a module. This shows WHY.
'
' There are two windows here, and both need to say the same thing about a
' temperature. The conversion lives in Convert.bas, so there is exactly one
' copy of it. Two copies would agree today and disagree the day one of them
' is fixed -- and the wrong one is always the one you are not looking at.
'
' Files:
'   Convert.bi / Convert.bas   the conversion, belonging to neither window
'   Main.frm                   this window
'   Details.frm                a second window, opened by the button
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
	#include once "Convert.bi"
	#include once "Details.frm"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdShow_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdDetails_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblPrompt, lblResult
		Dim As TextBox txtCelsius
		Dim As CommandButton cmdShow, cmdDetails
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
			.Text = "One module, two forms"
			.Designer = @This
			.SetBounds 0, 0, 460, 190
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblPrompt
			.Name = "lblPrompt" : .Text = "Celsius:"
			.SetBounds 20, 22, 70, 22
			.Designer = @This : .Parent = @This
		End With
		With txtCelsius
			.Name = "txtCelsius" : .Text = "21"
			.SetBounds 90, 20, 80, 24
			.Designer = @This : .Parent = @This
		End With
		With cmdShow
			.Name = "cmdShow" : .Text = "Convert"
			.SetBounds 185, 20, 100, 26
			.Designer = @This : .OnClick = @cmdShow_Click : .Parent = @This
		End With
		With lblResult
			.Name = "lblResult" : .Text = ""
			.SetBounds 20, 60, 400, 22
			.Designer = @This : .Parent = @This
		End With
		With cmdDetails
			.Name = "cmdDetails" : .Text = "Open the second window"
			.SetBounds 20, 96, 200, 30
			.Designer = @This : .OnClick = @cmdDetails_Click : .Parent = @This
		End With
	End Constructor

	Sub MainType.cmdShow_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		Dim As Double c = Val(frm->txtCelsius.Text)
		' DescribeC comes from the module -- and the other window calls the
		' very same function.
		frm->lblResult.Text = DescribeC(c)
	End Sub

	Sub MainType.cmdDetails_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		Details.SetCelsius(Val(frm->txtCelsius.Text))
		Details.ShowModal(*frm)
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
