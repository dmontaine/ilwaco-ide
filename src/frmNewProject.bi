'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/ComboBoxEdit.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/Label.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Panel.bi"

	Using My.Sys.Forms

	Type frmNewProject Extends Form
		Declare Static Sub cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdOK_Click(ByRef Sender As Control)
		Declare Static Sub cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdCancel_Click(ByRef Sender As Control)
		Declare Static Sub cmdSaveLocation_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub cmdSaveLocation_Click(ByRef Sender As Control)
		Declare Static Sub Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Form_Create(ByRef Sender As Control)
		Declare Sub AddProjectTemplateItem(ByRef TemplateName As String)
		Declare Constructor

		Dim As ComboBoxEdit cboTemplate
		Dim As CommandButton cmdOK, cmdCancel, cmdSaveLocation
		Dim As Label lblTemplate, lblSaveLocation
		Dim As TextBox txtSaveLocation
		Dim As Panel pnlTemplate, pnlSaveLocation, pnlBottom
		Dim As WStringList TemplateNames
		Dim As UString SelectedTemplate, SelectedFolder
	End Type

	Common Shared pfNewProject As frmNewProject Ptr
'#End Region

	#include once "frmNewProject.frm"
