' 15 - A SLIDER AND A LIVE VALUE
'
' Some events bring information with them. A TrackBar's OnChange is handed the
' new Position, so the handler does not have to go and ask for it.
'
' Notice there is no button here. The label keeps up with the slider because
' the event fires on every movement -- this is what "event-driven" means when
' there is nothing to click.
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
	#include once "mff/TrackBar.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub trkVolume_Change(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer)
		Declare Sub ShowValue(ByVal v As Integer)

		Dim As Label lblCaption, lblValue, lblBar
		Dim As TrackBar trkVolume
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
			.Text = "A slider and a live value"
			.Designer = @This
			.SetBounds 0, 0, 440, 210
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblCaption
			.Name = "lblCaption" : .Text = "Drag the slider:"
			.SetBounds 20, 18, 200, 22
			.Designer = @This : .Parent = @This
		End With
		With trkVolume
			.Name = "trkVolume"
			.SetBounds 20, 44, 380, 40
			.MinValue = 0
			.MaxValue = 100
			.Designer = @This
			.OnChange = @trkVolume_Change
			.Parent = @This
		End With
		With lblValue
			.Name = "lblValue" : .Text = ""
			.SetBounds 20, 94, 200, 30
			.Font.Size = 14
			.Designer = @This : .Parent = @This
		End With
		With lblBar
			.Name = "lblBar" : .Text = ""
			.SetBounds 20, 130, 380, 24
			.Designer = @This : .Parent = @This
		End With

		trkVolume.Position = 35
		ShowValue(35)
	End Constructor

	Sub MainType.trkVolume_Change(ByRef Designer As My.Sys.Object, ByRef Sender As TrackBar, Position As Integer)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		frm->ShowValue(Position)
	End Sub

	Sub MainType.ShowValue(ByVal v As Integer)
		lblValue.Text = Str(v) & " %"
		' A bar drawn out of characters -- crude, but it makes the number
		' visible as a quantity rather than as digits.
		lblBar.Text = String(v \ 2, "#")
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
