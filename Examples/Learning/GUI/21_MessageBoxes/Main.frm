' 21 - ASKING AND TELLING
'
' MsgBox puts a message in front of the user and waits. Its return value tells
' you which button they pressed, so it can ask as well as tell.
'
' Use it sparingly. A dialog stops everything and demands attention; for
' ordinary progress a label or a status bar is kinder. Save the interruption
' for something that genuinely cannot continue without an answer.
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
	#include once "mff/CommandButton.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdInfo_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdWarn_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdAsk_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblOutcome
		Dim As CommandButton cmdInfo, cmdWarn, cmdAsk
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
			.Text = "Asking and telling"
			.Designer = @This
			.SetBounds 0, 0, 470, 170
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With cmdInfo
			.Name = "cmdInfo" : .Text = "Tell me something"
			.SetBounds 20, 20, 160, 30
			.Designer = @This : .OnClick = @cmdInfo_Click : .Parent = @This
		End With
		With cmdWarn
			.Name = "cmdWarn" : .Text = "Warn me"
			.SetBounds 190, 20, 120, 30
			.Designer = @This : .OnClick = @cmdWarn_Click : .Parent = @This
		End With
		With cmdAsk
			.Name = "cmdAsk" : .Text = "Ask me"
			.SetBounds 320, 20, 110, 30
			.Designer = @This : .OnClick = @cmdAsk_Click : .Parent = @This
		End With
		With lblOutcome
			.Name = "lblOutcome"
			.Text = "The answer to the last question appears here."
			.SetBounds 20, 66, 410, 44
			.Designer = @This : .Parent = @This
		End With
	End Constructor

	Sub MainType.cmdInfo_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		MsgBox "Everything is fine.", "Information", MessageType.mtInfo
	End Sub

	Sub MainType.cmdWarn_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		MsgBox "This is what a warning looks like.", "Careful", MessageType.mtWarning
	End Sub

	Sub MainType.cmdAsk_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)

		' The RESULT is the point. Ask a question and then ignore the answer
		' and you have merely annoyed the user.
		Dim As MessageResult answer = MsgBox("Is this a question?", "Well?", _
			MessageType.mtQuestion, ButtonsTypes.btYesNo)

		If answer = MessageResult.mrYes Then
			frm->lblOutcome.Text = "You said Yes."
		Else
			frm->lblOutcome.Text = "You said No."
		End If
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
