' 20 - A MENU AND A STATUS BAR
'
' Menus are not controls you place. You build them: Add returns a pointer to
' the item you just made, and you add the next level to that.
'
' A menu item's handler takes a MenuItem, not a Control -- each kind of thing
' hands its own type to its handler, and using the wrong one compiles silently
' and then misbehaves. Copy the signature from the header if unsure.
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
	#include once "mff/Menus.bi"
	#include once "mff/StatusBar.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub Menu_Click(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem)

		Dim As MainMenu mnuBar
		Dim As Label lblBody
		Dim As StatusBar stbInfo
		Dim As StatusPanel Ptr pnlStatus
		Dim As Integer Chosen
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
			.Text = "A menu and a status bar"
			.Designer = @This
			.SetBounds 0, 0, 460, 240
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblBody
			.Name = "lblBody"
			.Text = "Use the File and Help menus above."
			.SetBounds 20, 20, 400, 60
			.Designer = @This : .Parent = @This
		End With
		With stbInfo
			.Name = "stbInfo"
			.Designer = @This : .Parent = @This
		End With

		' Build the menu. Add returns the item, so the second level is added
		' to what the first call handed back.
		Dim As MenuItem Ptr miFile = mnuBar.Add("&File", "", "File")
		Dim As MenuItem Ptr miNew  = miFile->Add("&New", "", "New")
		Dim As MenuItem Ptr miOpen = miFile->Add("&Open", "", "Open")
		miFile->Add("-", "", "sep1")            ' a lone hyphen is a separator
		Dim As MenuItem Ptr miExit = miFile->Add("E&xit", "", "Exit")

		Dim As MenuItem Ptr miHelp  = mnuBar.Add("&Help", "", "Help")
		Dim As MenuItem Ptr miAbout = miHelp->Add("&About", "", "About")

		miNew->OnClick   = @Menu_Click
		miOpen->OnClick  = @Menu_Click
		miExit->OnClick  = @Menu_Click
		miAbout->OnClick = @Menu_Click

		This.Menu = @mnuBar
		' Add hands back a pointer to the panel it made. Keep it -- that is how
		' you change the text later. (StatusBar.Panels is a raw pointer array,
		' not a collection you can index with .Item.)
		pnlStatus = stbInfo.Add("Ready", 300)
		Chosen = 0
	End Constructor

	Sub MainType.Menu_Click(ByRef Designer As My.Sys.Object, ByRef Sender As MenuItem)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)

		' A MenuItem calls its text .Caption, not .Text. Controls and menu items
		' are different kinds of thing and do not share every property name.
		If Sender.Name = "Exit" Then
			frm->CloseForm
			Exit Sub
		End If

		frm->Chosen += 1
		frm->lblBody.Text = "You chose: " & Sender.Caption
		' The status bar is where a program says what just happened without
		' interrupting anyone with a dialog.
		frm->pnlStatus->Caption = Str(frm->Chosen) & " menu command(s) used"
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
