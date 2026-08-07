' 04 - NUMBERS FROM A TEXT BOX
'
' A TextBox always holds TEXT, even when it looks like a number. VAL converts
' it -- and VAL of something that is not a number is 0, which is a perfectly
' good number and therefore a silent wrong answer.
'
' So check first. Validating input is not politeness; it is the difference
' between a program that reports a problem and one that quietly computes
' nonsense.
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

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdAdd_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Function LooksNumeric(ByRef s As String) As Boolean

		Dim As Label lblA, lblB, lblResult
		Dim As TextBox txtA, txtB
		Dim As CommandButton cmdAdd
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
			.Text = "Numbers from a text box"
			.Designer = @This
			.SetBounds 0, 0, 460, 240
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With lblA
			.Name = "lblA" : .Text = "First number:"
			.SetBounds 20, 22, 130, 22
			.Designer = @This : .Parent = @This
		End With
		With txtA
			.Name = "txtA" : .Text = "12"
			.SetBounds 160, 20, 100, 24
			.Designer = @This : .Parent = @This
		End With
		With lblB
			.Name = "lblB" : .Text = "Second number:"
			.SetBounds 20, 58, 130, 22
			.Designer = @This : .Parent = @This
		End With
		With txtB
			.Name = "txtB" : .Text = "30"
			.SetBounds 160, 56, 100, 24
			.Designer = @This : .Parent = @This
		End With
		With cmdAdd
			.Name = "cmdAdd" : .Text = "Add them up"
			.SetBounds 160, 94, 120, 30
			.Designer = @This : .OnClick = @cmdAdd_Click : .Parent = @This
		End With
		With lblResult
			.Name = "lblResult" : .Text = ""
			.SetBounds 20, 136, 400, 48
			.Designer = @This : .Parent = @This
		End With
	End Constructor

	' A helper does not have to be a handler. This one just answers a question,
	' and keeping it separate stops the click handler from getting tangled.
	Function MainType.LooksNumeric(ByRef s As String) As Boolean
		Dim As String t = Trim(s)
		If Len(t) = 0 Then Return False
		For i As Integer = 1 To Len(t)
			Dim As String c = Mid(t, i, 1)
			If c = "-" AndAlso i = 1 Then Continue For
			If c = "." Then Continue For
			If c < "0" OrElse c > "9" Then Return False
		Next i
		Return True
	End Function

	Sub MainType.cmdAdd_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		Dim As String sa = frm->txtA.Text, sb = frm->txtB.Text

		If Not LooksNumeric(sa) OrElse Not LooksNumeric(sb) Then
			frm->lblResult.Text = "Both boxes need to contain a number." & _
				Chr(13, 10) & "VAL would turn anything else into 0 without telling you."
			Exit Sub
		End If

		Dim As Double total = Val(sa) + Val(sb)
		frm->lblResult.Text = sa & " + " & sb & " = " & Str(total)
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
