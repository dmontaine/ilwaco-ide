' 19 - GROUPING CONTROLS
'
' Containers do two jobs. They tidy a crowded window, and they own the controls
' inside them -- which has consequences you can see:
'
'   A child's position is measured from its CONTAINER, not from the window. The
'   check boxes below are at x = 16 inside their group, wherever the group is.
'
'   Hiding or disabling a container takes its children with it. That is what
'   the buttons demonstrate, and it is far tidier than touching each control.
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
	#include once "mff/CheckBox.bi"
	#include once "mff/GroupBox.bi"
	#include once "mff/Panel.bi"
	#include once "mff/CommandButton.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdToggle_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdEnable_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As GroupBox grpOptions
		Dim As Panel pnlSide
		Dim As CheckBox chkOne, chkTwo, chkThree
		Dim As Label lblSide
		Dim As CommandButton cmdToggle, cmdEnable
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
			.Text = "Grouping controls"
			.Designer = @This
			.SetBounds 0, 0, 470, 250
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With grpOptions
			.Name = "grpOptions" : .Text = "Options"
			.SetBounds 20, 16, 200, 130
			.Designer = @This : .Parent = @This
		End With
		With chkOne
			.Name = "chkOne" : .Text = "First"
			.SetBounds 16, 26, 160, 22
			.Designer = @This : .Parent = @grpOptions
		End With
		With chkTwo
			.Name = "chkTwo" : .Text = "Second"
			.SetBounds 16, 54, 160, 22
			.Designer = @This : .Parent = @grpOptions
		End With
		With chkThree
			.Name = "chkThree" : .Text = "Third"
			.SetBounds 16, 82, 160, 22
			.Designer = @This : .Parent = @grpOptions
		End With
		With pnlSide
			.Name = "pnlSide"
			.SetBounds 240, 16, 190, 130
			.Designer = @This : .Parent = @This
		End With
		With lblSide
			.Name = "lblSide"
			.Text = "A Panel is a plain container with no caption."
			.SetBounds 12, 16, 165, 60
			.Designer = @This : .Parent = @pnlSide
		End With
		With cmdToggle
			.Name = "cmdToggle" : .Text = "Hide the group"
			.SetBounds 20, 162, 140, 30
			.Designer = @This : .OnClick = @cmdToggle_Click : .Parent = @This
		End With
		With cmdEnable
			.Name = "cmdEnable" : .Text = "Disable the group"
			.SetBounds 170, 162, 150, 30
			.Designer = @This : .OnClick = @cmdEnable_Click : .Parent = @This
		End With
	End Constructor

	Sub MainType.cmdToggle_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		' One line hides four controls, because they belong to the group.
		frm->grpOptions.Visible = Not frm->grpOptions.Visible
		If frm->grpOptions.Visible Then
			frm->cmdToggle.Text = "Hide the group"
		Else
			frm->cmdToggle.Text = "Show the group"
		End If
	End Sub

	Sub MainType.cmdEnable_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		frm->grpOptions.Enabled = Not frm->grpOptions.Enabled
		If frm->grpOptions.Enabled Then
			frm->cmdEnable.Text = "Disable the group"
		Else
			frm->cmdEnable.Text = "Enable the group"
		End If
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
