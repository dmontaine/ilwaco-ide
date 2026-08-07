' 01 - HELLO, WINDOW
'
' The GUI counterpart of "Hello, World". A window, a piece of text, and a
' button that changes it.
'
' Every program in this folder has the same three parts, and once you can see
' them the rest is detail:
'
'   1. The TYPE lists what is on the form -- the controls, and the handlers.
'   2. The CONSTRUCTOR builds it: position and size each control, then set
'      .Parent so it actually appears in the window.
'   3. The HANDLERS run when the user does something.
'
' Nothing draws the window itself. App.Run at the bottom starts the message
' loop, which waits for the user and calls your handlers. That is the whole
' idea of event-driven programming: you do not ask "what did they do?", you
' describe what should happen when they do it.
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
		Declare Static Sub cmdHello_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblMessage
		Dim As CommandButton cmdHello
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
			.Text = "Hello, Window"
			.Designer = @This
			.SetBounds 0, 0, 360, 200
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblMessage
			.Name = "lblMessage"
			.Text = "Click the button."
			.SetBounds 20, 20, 300, 24
			.Designer = @This
			.Parent = @This
		End With
		With cmdHello
			.Name = "cmdHello"
			.Text = "Say hello"
			.SetBounds 20, 60, 120, 30
			' .Designer MUST be set before .OnClick. The control passes its
			' Designer to the handler, so wiring an event without one crashes
			' the moment the button is pressed.
			.Designer = @This
			.OnClick = @cmdHello_Click
			.Parent = @This
		End With
	End Constructor

	Sub MainType.cmdHello_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		' Designer is the form the control belongs to. Casting it back gives
		' access to everything else on that form.
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		frm->lblMessage.Text = "Hello!"
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
