' 10 - LOOPS THAT FILL A LIST
'
' Loops are the same in a window as anywhere else. What is new is that you can
' watch the result: one pass of the loop, one row in the list.
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
	#include once "mff/ListView.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdBuild_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblPrompt
		Dim As TextBox txtTable
		Dim As CommandButton cmdBuild
		Dim As ListView lvTable
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
			.Text = "Loops that fill a list"
			.Designer = @This
			.SetBounds 0, 0, 460, 330
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblPrompt
			.Name = "lblPrompt" : .Text = "Times table for:"
			.SetBounds 20, 22, 120, 22
			.Designer = @This : .Parent = @This
		End With
		With txtTable
			.Name = "txtTable" : .Text = "7"
			.SetBounds 145, 20, 60, 24
			.Designer = @This : .Parent = @This
		End With
		With cmdBuild
			.Name = "cmdBuild" : .Text = "Build the table"
			.SetBounds 220, 20, 130, 26
			.Designer = @This : .OnClick = @cmdBuild_Click : .Parent = @This
		End With
		With lvTable
			.Name = "lvTable"
			.SetBounds 20, 56, 400, 220
			.FullRowSelect = True
			.Designer = @This : .Parent = @This
		End With

		lvTable.Columns.Add("Sum"), , 160
		lvTable.Columns.Add("Answer"), , 100
	End Constructor

	Sub MainType.cmdBuild_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		Dim As Integer n = CInt(Val(frm->txtTable.Text))

		' Clear before filling. Forget this and the second click leaves you
		' with two tables end to end -- a very common first bug.
		frm->lvTable.ListItems.Clear

		For i As Integer = 1 To 12
			frm->lvTable.ListItems.Add Str(i) & " x " & Str(n)
			frm->lvTable.ListItems.Item(i - 1)->Text(1) = Str(i * n)
		Next i
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
