' 17 - A CLOCK THAT TICKS
'
' The smallest useful timer program. Every second the handler runs and the
' label changes.
'
' A timer is not a loop with a wait in it. Between ticks your program is doing
' nothing at all, and the window is fully usable -- which is exactly why you
' can still start and stop it while it runs.
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
	#include once "mff/TimerComponent.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub tmrClock_Timer(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
		Declare Static Sub cmdToggle_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblTime, lblTicks
		Dim As CommandButton cmdToggle
		Dim As TimerComponent tmrClock
		Dim As Integer Ticks
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
			.Text = "A clock that ticks"
			.Designer = @This
			.SetBounds 0, 0, 380, 200
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblTime
			.Name = "lblTime" : .Text = "--:--:--"
			.SetBounds 20, 20, 320, 46
			.Font.Size = 26
			.Designer = @This : .Parent = @This
		End With
		With lblTicks
			.Name = "lblTicks" : .Text = "0 ticks so far"
			.SetBounds 20, 74, 320, 22
			.Designer = @This : .Parent = @This
		End With
		With cmdToggle
			.Name = "cmdToggle" : .Text = "Stop"
			.SetBounds 20, 106, 100, 30
			.Designer = @This : .OnClick = @cmdToggle_Click : .Parent = @This
		End With
		With tmrClock
			.Name = "tmrClock"
			.Interval = 1000        ' milliseconds, so this is once a second
			.Designer = @This
			.OnTimer = @tmrClock_Timer
			.Enabled = True
		End With

		Ticks = 0
	End Constructor

	Sub MainType.tmrClock_Timer(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		frm->Ticks += 1
		frm->lblTime.Text = Time
		frm->lblTicks.Text = Str(frm->Ticks) & " ticks so far"
	End Sub

	Sub MainType.cmdToggle_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)

		frm->tmrClock.Enabled = Not frm->tmrClock.Enabled
		If frm->tmrClock.Enabled Then
			frm->cmdToggle.Text = "Stop"
		Else
			frm->cmdToggle.Text = "Start"
		End If
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
