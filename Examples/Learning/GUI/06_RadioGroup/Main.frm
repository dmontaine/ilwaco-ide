' 06 - RADIO BUTTONS
'
' Radio buttons are for choices that exclude each other: picking one clears
' the others automatically. You never write that clearing code yourself.
'
' What decides which buttons belong together is their PARENT. All three here
' share a GroupBox, so they form one group. Put a fourth radio button on the
' form itself and it would be in a different group entirely -- which is the
' usual explanation when radio buttons "will not stop selecting each other".
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
	#include once "mff/RadioButton.bi"
	#include once "mff/GroupBox.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub Size_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)

		Dim As GroupBox grpSize
		Dim As RadioButton optSmall, optMedium, optLarge
		Dim As Label lblChoice
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
			.Text = "Radio buttons: one of several"
			.Designer = @This
			.SetBounds 0, 0, 460, 200
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With grpSize
			.Name = "grpSize" : .Text = "Cup size"
			.SetBounds 20, 16, 200, 120
			.Designer = @This : .Parent = @This
		End With
		With optSmall
			.Name = "optSmall" : .Text = "Small"
			.SetBounds 16, 26, 160, 22
			.Designer = @This : .OnClick = @Size_Click : .Parent = @grpSize
		End With
		With optMedium
			.Name = "optMedium" : .Text = "Medium"
			.SetBounds 16, 54, 160, 22
			.Designer = @This : .OnClick = @Size_Click : .Parent = @grpSize
		End With
		With optLarge
			.Name = "optLarge" : .Text = "Large"
			.SetBounds 16, 82, 160, 22
			.Designer = @This : .OnClick = @Size_Click : .Parent = @grpSize
		End With
		With lblChoice
			.Name = "lblChoice" : .Text = "Nothing chosen yet."
			.SetBounds 240, 60, 190, 40
			.Designer = @This : .Parent = @This
		End With

		' Setting .Checked in code also FIRES the handler -- which is why the
		' label already shows a choice when the window opens.
		optMedium.Checked = True
	End Constructor

	Sub MainType.Size_Click(ByRef Designer As My.Sys.Object, ByRef Sender As RadioButton)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		If Sender.Checked Then frm->lblChoice.Text = "You chose: " & Sender.Text
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
