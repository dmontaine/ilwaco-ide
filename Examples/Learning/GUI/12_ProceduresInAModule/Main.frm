' 12 - PROCEDURES IN A MODULE
'
' This project has THREE files, and that is the whole lesson:
'
'   Money.bi    what exists  -- the declarations
'   Money.bas   how it works -- the code
'   Main.frm    the window, which uses it
'
' Why bother? Because MoneyText and TaxOn have nothing to do with windows.
' They are about money. Code that would still make sense in a program with no
' window at all belongs in its own file, where it can be read, tested and
' reused without dragging the user interface along with it.
'
' The .bi is included wherever the code is needed; the .bas is listed in the
' project so it gets compiled. Open the project's file list and you will see
' all three.
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
	#include once "Money.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdWork_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)

		Dim As Label lblPrompt, lblNet, lblTax, lblGross
		Dim As TextBox txtAmount
		Dim As CommandButton cmdWork
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
			.Text = "Procedures in a module"
			.Designer = @This
			.SetBounds 0, 0, 440, 200
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblPrompt
			.Name = "lblPrompt" : .Text = "Amount before tax:"
			.SetBounds 20, 22, 140, 22
			.Designer = @This : .Parent = @This
		End With
		With txtAmount
			.Name = "txtAmount" : .Text = "49.99"
			.SetBounds 165, 20, 90, 24
			.Designer = @This : .Parent = @This
		End With
		With cmdWork
			.Name = "cmdWork" : .Text = "Work it out"
			.SetBounds 270, 20, 110, 26
			.Designer = @This : .OnClick = @cmdWork_Click : .Parent = @This
		End With
		With lblNet
			.Name = "lblNet" : .Text = ""
			.SetBounds 20, 66, 380, 22
			.Designer = @This : .Parent = @This
		End With
		With lblTax
			.Name = "lblTax" : .Text = ""
			.SetBounds 20, 92, 380, 22
			.Designer = @This : .Parent = @This
		End With
		With lblGross
			.Name = "lblGross" : .Text = ""
			.SetBounds 20, 118, 380, 22
			.Font.Bold = True
			.Designer = @This : .Parent = @This
		End With
	End Constructor

	Sub MainType.cmdWork_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		Dim As Double net = Val(frm->txtAmount.Text)

		' Every one of these lives in Money.bas. This handler does no
		' arithmetic of its own -- it collects input, calls, and displays.
		Dim As Double tax = TaxOn(net)

		frm->lblNet.Text   = "Net:   " & MoneyText(net)
		frm->lblTax.Text   = "Tax:   " & MoneyText(tax) & "  (at " & Str(TaxRatePercent) & "%)"
		frm->lblGross.Text = "Total: " & MoneyText(net + tax)
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
