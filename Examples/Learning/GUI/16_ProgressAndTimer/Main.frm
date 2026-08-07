' 16 - A PROGRESS BAR DRIVEN BY A TIMER
'
' THE MOST IMPORTANT IDEA IN GUI PROGRAMMING IS HERE.
'
' A window stays alive only while it is free to handle messages. A long loop
' inside a handler holds that up: the window stops repainting, stops
' responding, and Windows offers to close it. The bar would not move either --
' it cannot repaint while your loop is running.
'
' So slow work is broken into small pieces and a timer does one piece at a
' time. Between ticks the window is idle and completely responsive, which is
' why you can still press Reset while it counts.
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
	#include once "mff/ProgressBar.bi"
	#include once "mff/TimerComponent.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdStart_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdReset_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub tmrWork_Timer(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)

		Dim As Label lblStatus
		Dim As ProgressBar barWork
		Dim As CommandButton cmdStart, cmdReset
		Dim As TimerComponent tmrWork
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
			.Text = "A progress bar driven by a timer"
			.Designer = @This
			.SetBounds 0, 0, 440, 180
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblStatus
			.Name = "lblStatus" : .Text = "Ready."
			.SetBounds 20, 20, 380, 22
			.Designer = @This : .Parent = @This
		End With
		With barWork
			.Name = "barWork"
			.SetBounds 20, 48, 380, 24
			.MinValue = 0
			.MaxValue = 100
			.Designer = @This : .Parent = @This
		End With
		With cmdStart
			.Name = "cmdStart" : .Text = "Start"
			.SetBounds 20, 88, 100, 30
			.Designer = @This : .OnClick = @cmdStart_Click : .Parent = @This
		End With
		With cmdReset
			.Name = "cmdReset" : .Text = "Reset"
			.SetBounds 130, 88, 100, 30
			.Designer = @This : .OnClick = @cmdReset_Click : .Parent = @This
		End With
		With tmrWork
			.Name = "tmrWork"
			.Interval = 60
			.Designer = @This
			.OnTimer = @tmrWork_Timer
			.Enabled = False      ' nothing happens until Start is pressed
		End With
	End Constructor

	Sub MainType.cmdStart_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		frm->barWork.Position = 0
		frm->lblStatus.Text = "Working..."
		frm->tmrWork.Enabled = True
	End Sub

	Sub MainType.cmdReset_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		frm->tmrWork.Enabled = False
		frm->barWork.Position = 0
		frm->lblStatus.Text = "Reset. Press Start."
	End Sub

	Sub MainType.tmrWork_Timer(ByRef Designer As My.Sys.Object, ByRef Sender As TimerComponent)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)

		' One tick, one small piece of the job.
		frm->barWork.Position = frm->barWork.Position + 2

		If frm->barWork.Position >= frm->barWork.MaxValue Then
			' Turn the timer off when the work is done, or it keeps firing
			' forever for no reason.
			frm->tmrWork.Enabled = False
			frm->lblStatus.Text = "Finished."
		End If
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
