' 22 - A SECOND WINDOW
'
' Most programs have more than one window. This one opens a dialog, lets the
' user edit a value, and reads it back afterwards.
'
' ShowModal does not return until the dialog closes, and its result says how
' it closed. Check that before believing the value -- a user who pressed
' Cancel has told you to leave things alone, and a program that saves anyway
' is a program people stop trusting.
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
	#include once "Editor.frm"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdEdit_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Function CurrentValue() As String

		Dim As Label lblCurrent, lblHow
		Dim As CommandButton cmdEdit
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
			.Text = "A second window"
			.Designer = @This
			.SetBounds 0, 0, 430, 170
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblCurrent
			.Name = "lblCurrent" : .Text = "Nickname: (none set)"
			.SetBounds 20, 20, 380, 22
			.Font.Bold = True
			.Designer = @This : .Parent = @This
		End With
		With lblHow
			.Name = "lblHow" : .Text = ""
			.SetBounds 20, 48, 380, 22
			.Designer = @This : .Parent = @This
		End With
		With cmdEdit
			.Name = "cmdEdit" : .Text = "Edit it..."
			.SetBounds 20, 82, 110, 30
			.Designer = @This : .OnClick = @cmdEdit_Click : .Parent = @This
		End With
	End Constructor

	Sub MainType.cmdEdit_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)

		Editor.txtValue.Text = frm->CurrentValue()

		' Blocks here until the dialog closes.
		If Editor.ShowModal(*frm) = ModalResults.OK Then
			frm->lblCurrent.Text = "Nickname: " & Editor.txtValue.Text
			frm->lblHow.Text = "Saved, because OK was pressed."
		Else
			frm->lblHow.Text = "Cancelled -- nothing was changed."
		End If
	End Sub

	Function MainType.CurrentValue() As String
		Dim As String shown = lblCurrent.Text
		If InStr(shown, "(none set)") > 0 Then Return ""
		Return Mid(shown, Len("Nickname: ") + 1)
	End Function

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
