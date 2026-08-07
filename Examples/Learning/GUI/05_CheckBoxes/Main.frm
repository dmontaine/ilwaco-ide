' 05 - CHECK BOXES
'
' A CheckBox is a Boolean with a face on it. Its .Checked property is True or
' False, and each box is independent of the others -- tick as many as you like.
' (Compare 06, where the choices exclude each other.)
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
	#include once "mff/CommandButton.bi"
	#include once "vbcompat.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub Box_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Declare Sub ShowTotal()

		Dim As Label lblPrompt, lblTotal
		Dim As CheckBox chkTea, chkToast, chkEggs
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
			.Text = "Check boxes and true/false"
			.Designer = @This
			.SetBounds 0, 0, 400, 220
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblPrompt
			.Name = "lblPrompt" : .Text = "Breakfast order:"
			.SetBounds 20, 18, 250, 22
			.Designer = @This : .Parent = @This
		End With
		With chkTea
			.Name = "chkTea" : .Text = "Tea (1.50)"
			.SetBounds 30, 48, 200, 22
			.Designer = @This : .OnClick = @Box_Click : .Parent = @This
		End With
		With chkToast
			.Name = "chkToast" : .Text = "Toast (2.00)"
			.SetBounds 30, 76, 200, 22
			.Designer = @This : .OnClick = @Box_Click : .Parent = @This
		End With
		With chkEggs
			.Name = "chkEggs" : .Text = "Eggs (3.25)"
			.SetBounds 30, 104, 200, 22
			.Designer = @This : .OnClick = @Box_Click : .Parent = @This
		End With
		With lblTotal
			.Name = "lblTotal" : .Text = "Total: 0.00"
			.SetBounds 20, 142, 300, 22
			.Font.Bold = True
			.Designer = @This : .Parent = @This
		End With
	End Constructor

	' All three boxes share ONE handler. There is no rule that says a handler
	' belongs to a single control, and sharing one is often clearer than three
	' near-identical copies.
	Sub MainType.Box_Click(ByRef Designer As My.Sys.Object, ByRef Sender As CheckBox)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		frm->ShowTotal()
	End Sub

	Sub MainType.ShowTotal()
		Dim As Double total = 0
		If chkTea.Checked   Then total += 1.50
		If chkToast.Checked Then total += 2.00
		If chkEggs.Checked  Then total += 3.25
		lblTotal.Text = "Total: " & Format(total, "0.00")
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
