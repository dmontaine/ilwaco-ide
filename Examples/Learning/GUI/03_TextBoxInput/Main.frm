' 03 - READING WHAT THE USER TYPES
'
' The console version of this used INPUT, which stops the program until the
' user answers. A window never stops: the text sits in the TextBox, and you
' read it whenever you need it -- here, when the button is clicked.
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
		Declare Static Sub cmdGreet_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblPrompt, lblResult
		Dim As TextBox txtName
		Dim As CommandButton cmdGreet
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
			.Text = "Reading what the user types"
			.Designer = @This
			.SetBounds 0, 0, 440, 200
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblPrompt
			.Name = "lblPrompt" : .Text = "What is your name?"
			.SetBounds 20, 20, 200, 22
			.Designer = @This : .Parent = @This
		End With
		With txtName
			.Name = "txtName" : .Text = ""
			.SetBounds 20, 46, 240, 24
			.Designer = @This : .Parent = @This
		End With
		With cmdGreet
			.Name = "cmdGreet" : .Text = "Greet me"
			.SetBounds 275, 46, 110, 26
			.Designer = @This : .OnClick = @cmdGreet_Click : .Parent = @This
		End With
		With lblResult
			.Name = "lblResult" : .Text = ""
			.SetBounds 20, 90, 400, 44
			.Designer = @This : .Parent = @This
		End With
	End Constructor

	Sub MainType.cmdGreet_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		Dim As String typed = frm->txtName.Text

		' Always consider the empty case. A user who clicks before typing is
		' not doing anything wrong, and a program that greets "" looks broken.
		If Len(Trim(typed)) = 0 Then
			frm->lblResult.Text = "Type your name first, then click the button."
		Else
			frm->lblResult.Text = "Hello, " & typed & "!"
		End If
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
