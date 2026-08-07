' 02 - LABELS AND TEXT
'
' A Label displays text the user cannot edit. Its appearance is a set of
' properties you can change at any time -- including while the program runs,
' which is what the buttons here do.
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
	#include once "mff/Graphics.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdBig_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdColour_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdReset_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblPlain, lblBold, lblSubject
		Dim As CommandButton cmdBig, cmdColour, cmdReset
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
			.Text = "Labels and text"
			.Designer = @This
			.SetBounds 0, 0, 460, 220
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblPlain
			.Name = "lblPlain"
			.Text = "An ordinary label."
			.SetBounds 20, 20, 400, 22
			.Designer = @This : .Parent = @This
		End With
		With lblBold
			.Name = "lblBold"
			.Text = "Bold, because Font.Bold is True."
			.SetBounds 20, 48, 400, 22
			.Font.Bold = True
			.Designer = @This : .Parent = @This
		End With
		With lblSubject
			.Name = "lblSubject"
			.Text = "Change me with the buttons below."
			.SetBounds 20, 84, 400, 30
			.Designer = @This : .Parent = @This
		End With
		With cmdBig
			.Name = "cmdBig" : .Text = "Bigger"
			.SetBounds 20, 130, 100, 30
			.Designer = @This : .OnClick = @cmdBig_Click : .Parent = @This
		End With
		With cmdColour
			.Name = "cmdColour" : .Text = "Red"
			.SetBounds 130, 130, 100, 30
			.Designer = @This : .OnClick = @cmdColour_Click : .Parent = @This
		End With
		With cmdReset
			.Name = "cmdReset" : .Text = "Reset"
			.SetBounds 240, 130, 100, 30
			.Designer = @This : .OnClick = @cmdReset_Click : .Parent = @This
		End With
	End Constructor

	Sub MainType.cmdBig_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		frm->lblSubject.Font.Size = frm->lblSubject.Font.Size + 2
	End Sub

	Sub MainType.cmdColour_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		' clRed and friends come from mff/Graphics.bi. They are already in the
		' byte order Windows wants, which is why you should use them rather
		' than writing a colour out by hand.
		frm->lblSubject.ForeColor = clRed
	End Sub

	Sub MainType.cmdReset_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		With frm->lblSubject
			.Font.Size = 9
			.ForeColor = clBlack
			.Text = "Change me with the buttons below."
		End With
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
