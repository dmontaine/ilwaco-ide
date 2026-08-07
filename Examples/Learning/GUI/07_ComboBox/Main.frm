' 07 - A DROP-DOWN LIST
'
' A ComboBox offers a list without using the room a list would. Two things are
' worth knowing:
'
'   .ItemIndex is the position of the choice, counting from 0, and -1 when
'   nothing is chosen. That -1 is the case beginners forget.
'
'   The items are filled in AFTER the controls exist, at the end of the
'   constructor -- not inside the With block that creates the control.
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
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CommandButton.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdPick_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblPrompt, lblResult
		Dim As ComboBoxEdit cboCity
		Dim As CommandButton cmdPick
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
			.Text = "A drop-down list"
			.Designer = @This
			.SetBounds 0, 0, 460, 180
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblPrompt
			.Name = "lblPrompt" : .Text = "Pick a city:"
			.SetBounds 20, 22, 100, 22
			.Designer = @This : .Parent = @This
		End With
		With cboCity
			.Name = "cboCity"
			.SetBounds 120, 20, 180, 24
			.Designer = @This : .Parent = @This
		End With
		With cmdPick
			.Name = "cmdPick" : .Text = "Use it"
			.SetBounds 315, 20, 90, 26
			.Designer = @This : .OnClick = @cmdPick_Click : .Parent = @This
		End With
		With lblResult
			.Name = "lblResult" : .Text = "Nothing picked yet."
			.SetBounds 20, 64, 400, 44
			.Designer = @This : .Parent = @This
		End With

		cboCity.AddItem "Lisbon"
		cboCity.AddItem "Reykjavik"
		cboCity.AddItem "Valparaiso"
		cboCity.AddItem "Ulaanbaatar"
	End Constructor

	Sub MainType.cmdPick_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		Dim As Integer chosen = frm->cboCity.ItemIndex

		If chosen = -1 Then
			frm->lblResult.Text = "Nothing is selected. ItemIndex is -1."
		Else
			frm->lblResult.Text = "Item " & Str(chosen) & " of " & _
				Str(frm->cboCity.Items.Count) & ": " & frm->cboCity.Text
		End If
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
