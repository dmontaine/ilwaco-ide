' 23 - OPENING AND SAVING A FILE
'
' Never ask a user to type a path. The standard dialogs know where things are,
' complete names, and warn before overwriting.
'
' .Execute returns False when the user cancels, and cancelling is a normal
' thing to do -- so it is checked every time here, before .FileName is touched.
'#Region "Form"
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#cmdline "Main.rc"
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
	#include once "mff/Form.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/Dialogs.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdOpen_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdSave_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblStatus
		Dim As TextBox txtBody
		Dim As CommandButton cmdOpen, cmdSave
		Dim As OpenFileDialog dlgOpen
		Dim As SaveFileDialog dlgSave
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
			.Text = "Opening and saving a file"
			.Designer = @This
			.SetBounds 0, 0, 560, 350
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With cmdOpen
			.Name = "cmdOpen" : .Text = "Open..."
			.SetBounds 20, 18, 100, 28
			.Designer = @This : .OnClick = @cmdOpen_Click : .Parent = @This
		End With
		With cmdSave
			.Name = "cmdSave" : .Text = "Save as..."
			.SetBounds 130, 18, 100, 28
			.Designer = @This : .OnClick = @cmdSave_Click : .Parent = @This
		End With
		With lblStatus
			.Name = "lblStatus" : .Text = "Type something, or open a text file."
			.SetBounds 240, 24, 280, 22
			.Designer = @This : .Parent = @This
		End With
		With txtBody
			.Name = "txtBody"
			.SetBounds 20, 56, 500, 240
			.MultiLine = True
			.ScrollBars = ScrollBarsType.Both
			.Text = "Hello from example 23."
			.Designer = @This : .Parent = @This
		End With

		dlgOpen.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"
		dlgSave.Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*"
		dlgSave.DefaultExt = "txt"
	End Constructor

	Sub MainType.cmdOpen_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)

		If Not frm->dlgOpen.Execute Then
			frm->lblStatus.Text = "Open was cancelled."
			Exit Sub
		End If

		Dim As Integer ff = FreeFile
		If Open(frm->dlgOpen.FileName For Input As #ff) <> 0 Then
			frm->lblStatus.Text = "Could not open that file."
			Exit Sub
		End If

		Dim As String whole, oneLine
		Do Until EOF(ff)
			Line Input #ff, oneLine
			whole &= oneLine & Chr(13, 10)
		Loop
		Close #ff

		frm->txtBody.Text = whole
		frm->lblStatus.Text = "Opened " & frm->dlgOpen.FileName
	End Sub

	Sub MainType.cmdSave_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)

		If Not frm->dlgSave.Execute Then
			frm->lblStatus.Text = "Save was cancelled."
			Exit Sub
		End If

		Dim As Integer ff = FreeFile
		If Open(frm->dlgSave.FileName For Output As #ff) <> 0 Then
			frm->lblStatus.Text = "Could not write there."
			Exit Sub
		End If
		Print #ff, frm->txtBody.Text;
		Close #ff

		frm->lblStatus.Text = "Saved " & frm->dlgSave.FileName
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
