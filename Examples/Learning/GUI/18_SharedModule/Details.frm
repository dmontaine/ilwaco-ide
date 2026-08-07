'#Region "Form"
	' The second window. It includes the same Convert.bi and calls the same
	' functions -- one copy of the logic, two places using it.
	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/CommandButton.bi"
	#include once "vbcompat.bi"
	#include once "Convert.bi"

	Using My.Sys.Forms

	Type DetailsType Extends Form
		Declare Constructor
		Declare Sub SetCelsius(ByVal C As Double)
		Declare Static Sub cmdClose_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblC, lblF, lblK
		Dim As CommandButton cmdClose
	End Type

	Constructor DetailsType
		With This
			.Name = "Details"
			.Text = "All three scales"
			.Designer = @This
			.SetBounds 0, 0, 320, 200
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblC
			.Name = "lblC" : .SetBounds 20, 20, 260, 22
			.Designer = @This : .Parent = @This
		End With
		With lblF
			.Name = "lblF" : .SetBounds 20, 48, 260, 22
			.Designer = @This : .Parent = @This
		End With
		With lblK
			.Name = "lblK" : .SetBounds 20, 76, 260, 22
			.Designer = @This : .Parent = @This
		End With
		With cmdClose
			.Name = "cmdClose" : .Text = "Close"
			.SetBounds 20, 112, 90, 28
			.Designer = @This : .OnClick = @cmdClose_Click : .Parent = @This
		End With
	End Constructor

	' The first window calls this before showing us, which is how data gets
	' from one form to another: a method, not a global variable.
	Sub DetailsType.SetCelsius(ByVal C As Double)
		lblC.Text = "Celsius:    " & Format(C, "0.0")
		lblF.Text = "Fahrenheit: " & Format(CToF(C), "0.0")
		lblK.Text = "Kelvin:     " & Format(CToK(C), "0.0")
	End Sub

	Sub DetailsType.cmdClose_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As DetailsType Ptr frm = Cast(DetailsType Ptr, @Designer)
		frm->CloseForm
	End Sub

	Dim Shared Details As DetailsType
'#End Region
