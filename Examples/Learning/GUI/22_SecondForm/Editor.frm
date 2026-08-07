'#Region "Form"
	' A dialog. The only thing that makes it one is how it is used: shown with
	' ShowModal, and setting ModalResult is what closes it.
	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/CommandButton.bi"

	Using My.Sys.Forms

	Type EditorType Extends Form
		Declare Constructor
		Declare Static Sub cmdOk_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblPrompt
		Dim As TextBox txtValue
		Dim As CommandButton cmdOk, cmdCancel
	End Type

	Constructor EditorType
		With This
			.Name = "Editor"
			.Text = "Edit nickname"
			.Designer = @This
			.SetBounds 0, 0, 320, 160
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblPrompt
			.Name = "lblPrompt" : .Text = "Nickname:"
			.SetBounds 16, 18, 100, 22
			.Designer = @This : .Parent = @This
		End With
		With txtValue
			.Name = "txtValue"
			.SetBounds 16, 44, 270, 24
			.Designer = @This : .Parent = @This
		End With
		With cmdOk
			.Name = "cmdOk" : .Text = "OK"
			.SetBounds 110, 84, 84, 28
			.Designer = @This : .OnClick = @cmdOk_Click : .Parent = @This
		End With
		With cmdCancel
			.Name = "cmdCancel" : .Text = "Cancel"
			.SetBounds 202, 84, 84, 28
			.Designer = @This : .OnClick = @cmdCancel_Click : .Parent = @This
		End With
	End Constructor

	' Setting ModalResult ends ShowModal and tells the caller which way.
	Sub EditorType.cmdOk_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As EditorType Ptr frm = Cast(EditorType Ptr, @Designer)
		frm->ModalResult = ModalResults.OK
	End Sub

	Sub EditorType.cmdCancel_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As EditorType Ptr frm = Cast(EditorType Ptr, @Designer)
		frm->ModalResult = ModalResults.Cancel
	End Sub

	Dim Shared Editor As EditorType
'#End Region
