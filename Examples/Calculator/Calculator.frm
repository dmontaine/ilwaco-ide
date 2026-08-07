'################################################################################
'#  Calculator.frm                                                              #
'#  An example program shipped with Ilwaco IDE (built on MyFbFramework).       #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                     #
'################################################################################
	#if defined(__FB_MAIN__) AndAlso Not defined(__MAIN_FILE__)
		#define __MAIN_FILE__
		#ifdef __FB_WIN32__
			#ifdef __FB_WIN32__
				#cmdline "Calculator.rc"
			#endif
		#endif
		Const _MAIN_FILE_ = __FILE__
	#endif
'#Region "Form"
	#include once "mff/Form.bi"
	#include once "mff/Label.bi"
	#include once "mff/CommandButton.bi"
	#include once "mff/TextBox.bi"
	#include once "mff/Panel.bi"

	Using My.Sys.Forms
	Using My.Sys.Drawing
	
	Type CalculatorType Extends Form
		Declare Sub cmdNum_Click(ByRef Sender As Control)
		Declare Sub cmdExit_Click(ByRef Sender As Control)
		Declare Sub cmdClear_Click(ByRef Sender As Control)
		Declare Constructor
		Declare Function EvalResult(ByRef s As String) As String
		
		Dim As Panel Panel1
		Dim As CommandButton cmdNum(14), cmdClear, cmdExit
		Dim As Label lblExpressions, lblResult
		Dim As TextBox txtResult, txtExpressions
		
		Dim As String fEval
	End Type
	
	Constructor CalculatorType
		#if _MAIN_FILE_ = __FILE__
			With App
				.CurLanguagePath = ExePath & "/"
				.CurLanguage = My.Sys.Language
			End With
		#endif
		' Calculator
		With This
			.Name = "Calculator"
			.Text = ML("Calculator")
			.Designer = @This
			.DoubleBuffered = True
			.Transparent = False 
			.BorderStyle = FormBorderStyle.FixedDialog
			.Icon.LoadFromResourceID(1)
			.StartPosition = FormStartPosition.CenterScreen
			.MaximizeBox = False
			.SetBounds 0, 0, 290, 210
		End With
		
		' Panel1
		With Panel1
			.Name = "Panel1"
			.Text = "Panel1"
			.TabIndex = 1
			.SetBounds 0, 0, 290, 192
			.Designer = @This
			.Parent = @This
		End With
		' cmdNum(0)
		With cmdNum(0)
			.Name = "cmdNum(0)"
			.Text = "0"
			.TabIndex = 2
			.SetBounds 12, 114, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(1)
		With cmdNum(1)
			.Name = "cmdNum(1)"
			.Text = "1"
			.TabIndex = 3
			.ControlIndex = 0
			.SetBounds 12, 12, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(2)
		With cmdNum(2)
			.Name = "cmdNum(2)"
			.Text = "2"
			.TabIndex = 4
			.ControlIndex = 1
			.SetBounds 54, 12, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(3)
		With cmdNum(3)
			.Name = "cmdNum(3)"
			.Text = "3"
			.TabIndex = 5
			.ControlIndex = 2
			.SetBounds 96, 12, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(4)
		With cmdNum(4)
			.Name = "cmdNum(4)"
			.Text = "4"
			.TabIndex = 6
			.ControlIndex = 3
			.SetBounds 12, 46, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(5)
		With cmdNum(5)
			.Name = "cmdNum(5)"
			.Text = "5"
			.TabIndex = 7
			.ControlIndex = 4
			.SetBounds 54, 46, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(6)
		With cmdNum(6)
			.Name = "cmdNum(6)"
			.Text = "6"
			.TabIndex = 8
			.ControlIndex = 5
			.SetBounds 96, 46, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(7)
		With cmdNum(7)
			.Name = "cmdNum(7)"
			.Text = "7"
			.TabIndex = 9
			.ControlIndex = 6
			.SetBounds 12, 80, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(8)
		With cmdNum(8)
			.Name = "cmdNum(8)"
			.Text = "8"
			.TabIndex = 10
			.ControlIndex = 7
			.SetBounds 54, 80, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(9)
		With cmdNum(9)
			.Name = "cmdNum(9)"
			.Text = "9"
			.TabIndex = 11
			.ControlIndex = 8
			.SetBounds 96, 80, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(10)
		With cmdNum(10)
			.Name = "cmdNum(10)"
			.Text = "+"
			.TabIndex = 12
			.Caption = "+"
			.SetBounds 54, 114, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(11)
		With cmdNum(11)
			.Name = "cmdNum(11)"
			.Text = "-"
			.TabIndex = 13
			.ControlIndex = 10
			.SetBounds 96, 114, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(12)
		With cmdNum(12)
			.Name = "cmdNum(12)"
			.Text = "*"
			.TabIndex = 14
			.ControlIndex = 11
			.SetBounds 12, 148, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(13)
		With cmdNum(13)
			.Name = "cmdNum(13)"
			.Text = "/"
			.TabIndex = 15
			.ControlIndex = 12
			.SetBounds 54, 148, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' cmdNum(14)
		With cmdNum(14)
			.Name = "cmdNum(14)"
			.Text = "="
			.TabIndex = 16
			.ControlIndex = 13
			.SetBounds 96, 148, 36, 28
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdNum_Click)
			.Parent = @Panel1
		End With
		' lblExpressions
		With lblExpressions
			.Name = "lblExpressions"
			.Text = ML("Expressions")
			.TabIndex = 17
			.SetBounds 148, 12, 120, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' txtResult
		With txtResult
			.Name = "txtResult"
			.Text = ""
			.TabIndex = 18
			.SetBounds 148, 80, 128, 30
			.Designer = @This
			.Parent = @Panel1
		End With
		' cmdClear
		With cmdClear
			.Name = "cmdClear"
			.Text = ML("Clear")
			.TabIndex = 19
			.SetBounds 148, 116, 128, 26
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdClear_Click)
			.Parent = @Panel1
		End With
		' cmdExit
		With cmdExit
			.Name = "cmdExit"
			.Text = ML("Exit")
			.TabIndex = 20
			.SetBounds 148, 146, 128, 26
			.Designer = @This
			.OnClick = Cast(Sub(ByRef Designer As My.Sys.Object, ByRef Sender As Control), @cmdExit_Click)
			.Parent = @Panel1
		End With
		' lblResult
		With lblResult
			.Name = "lblResult"
			.Text = ML("Result")
			.TabIndex = 21
			.ControlIndex = 15
			.SetBounds 148, 62, 120, 16
			.Designer = @This
			.Parent = @Panel1
		End With
		' txtExpressions
		With txtExpressions
			.Name = "txtExpressions"
			.Text = "5+7*sin(0.5)"
			.TabIndex = 22
			.ControlIndex = 17
			.SetBounds 148, 30, 128, 22
			.Designer = @This
			.Parent = @Panel1
		End With
	End Constructor
	
	Dim Shared Calculator As CalculatorType
	
	#ifndef _NOT_AUTORUN_FORMS_
		Calculator.MainForm = True
		Calculator.Show
		App.Run
	#endif
'#End Region

#include once "ExprEval.bi"   '' self-contained expression evaluator (replaces MSScriptControl)

Private Function CalculatorType.EvalResult(ByRef s As String) As String
	'' Evaluate the typed expression natively -- see ExprEval.bi. Returns "Error" for
	'' malformed input. No COM / MSScriptControl, so it works on any 64-bit Windows.
	Return EvalToDisplay(s)
End Function

Private Sub CalculatorType.cmdNum_Click(ByRef Sender As Control)
	Dim As Integer Index = Val(Mid(Sender.Name, InStrRev(Sender.Name, "(") + 1))
	Dim As String key, tmpStr 
	key = cmdNum(Index).Caption
	If key = "=" Then
		tmpStr = Trim(txtExpressions.Text, " ")
		If Right(tmpStr, 1) = "="  Then tmpStr = Mid(tmpStr, 1, Len(tmpStr) - 1)
		txtResult.Text  = EvalResult(tmpStr)
		txtExpressions.Text  = tmpStr  & "="
	Else
		txtExpressions.Text = txtExpressions.Text  & key
	End If
	
End Sub

Private Sub CalculatorType.cmdExit_Click(ByRef Sender As Control)
	This.CloseForm
End Sub

Private Sub CalculatorType.cmdClear_Click(ByRef Sender As Control)
	txtExpressions.Text = "": txtResult.Text = ""
End Sub


