' 24 - DRAWING YOUR OWN GRAPHICS
'
' Windows does not remember what you drew. Cover the window and uncover it and
' the picture is gone -- unless you can draw it again, which is what OnPaint is
' for: it runs whenever the window needs its contents back.
'
' So the rule is: keep the DATA (here, how many bars and what size), and draw
' from it inside OnPaint. Never treat the screen as your storage. Beginners
' draw once from a button handler, and their picture vanishes the first time
' another window passes over it.
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
		Declare Static Sub Form_Paint(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Cv As My.Sys.Drawing.Canvas)
		Declare Static Sub cmdMore_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdFewer_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Integer BarCount
		Dim As CommandButton cmdMore, cmdFewer
		Dim As Label lblHint
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
			.Text = "Drawing your own graphics"
			.Designer = @This
			.SetBounds 0, 0, 580, 340
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With cmdMore
			.Name = "cmdMore" : .Text = "More bars"
			.SetBounds 20, 18, 110, 28
			.Designer = @This : .OnClick = @cmdMore_Click : .Parent = @This
		End With
		With cmdFewer
			.Name = "cmdFewer" : .Text = "Fewer bars"
			.SetBounds 140, 18, 110, 28
			.Designer = @This : .OnClick = @cmdFewer_Click : .Parent = @This
		End With
		With lblHint
			.Name = "lblHint"
			.Text = "Cover this window with another and back again -- it redraws."
			.SetBounds 260, 24, 300, 34
			.Designer = @This : .Parent = @This
		End With

		BarCount = 5
		This.OnPaint = @Form_Paint
	End Constructor

	Sub MainType.Form_Paint(ByRef Designer As My.Sys.Object, ByRef Sender As Control, ByRef Cv As My.Sys.Drawing.Canvas)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)

		' Drawn fresh from BarCount every time. That is the whole technique.
		For i As Integer = 0 To frm->BarCount - 1
			Dim As Integer x = 30 + i * 46
			Dim As Integer height = 30 + (i * 27) Mod 150

			' "BF" means Box, Filled -- the same idiom as FreeBASIC's own LINE
			' statement. The colour is passed in rather than set beforehand.
			Cv.Line x, 250 - height, x + 34, 250, clSteelBlue, "BF"

			Cv.TextOut x + 6, 256, Str(height)
		Next i

		Cv.TextOut 30, 76, "Bars: " & Str(frm->BarCount)
	End Sub

	Sub MainType.cmdMore_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		If frm->BarCount < 9 Then frm->BarCount += 1
		' Change the data, then ASK for a repaint. Do not draw here -- this
		' makes Windows send a paint message, and OnPaint does the drawing.
		frm->Repaint
	End Sub

	Sub MainType.cmdFewer_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		If frm->BarCount > 1 Then frm->BarCount -= 1
		frm->Repaint
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
