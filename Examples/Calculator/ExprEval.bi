'################################################################################
'#  ExprEval.bi                                                                 #
'#  A small, self-contained arithmetic expression evaluator for the Calculator  #
'#  example. Pure FreeBASIC -- no external components.                          #
'#                                                                              #
'#  This replaces the example's former dependency on MSScriptControl (a VBScript#
'#  engine reached over COM). That component has no 64-bit build on stock       #
'#  Windows, so a 64-bit program -- which is what Ilwaco builds -- fails with  #
'#  "Class not registered". Evaluating the expression ourselves removes the     #
'#  dependency entirely, so the Calculator just works on any 64-bit Windows.    #
'#                                                                              #
'#  Grammar (standard recursive descent, usual precedence):                     #
'#    expr    = term   { ('+' | '-') term }                                     #
'#    term    = power  { ('*' | '/') power }                                    #
'#    power   = unary  [ '^' power ]              (right associative)            #
'#    unary   = ('+' | '-') unary | primary                                     #
'#    primary = number | '(' expr ')' | func '(' expr ')' | constant            #
'#                                                                              #
'#  Supported functions (case-insensitive): sin cos tan atn sqr/sqrt exp        #
'#  log/ln abs. Constants: pi, e. Angles are in radians; log/ln are natural.    #
'#                                                                              #
'#  Note: the status flag is named `valid`, not `ok` -- MyFbFramework defines a #
'#  global `Ok`, and FreeBASIC identifiers are case-insensitive (a documented   #
'#  collision trap).                                                            #
'################################################################################
#ifndef __EXPREVAL_BI__
#define __EXPREVAL_BI__

Type ExprParser
	Dim As String src        '' the expression being read
	Dim As Integer p         '' 1-based cursor into src (FB Mid is 1-based)
	Dim As Integer n         '' Len(src)
	Dim As Boolean valid     '' cleared on any syntax or math error

	Declare Function Evaluate(ByRef expr As String) As Double
	Declare Sub SkipSpaces()
	Declare Function Cur() As String
	Declare Function ParseExpr() As Double
	Declare Function ParseTerm() As Double
	Declare Function ParsePower() As Double
	Declare Function ParseUnary() As Double
	Declare Function ParsePrimary() As Double
End Type

Sub ExprParser.SkipSpaces()
	While p <= n AndAlso (Mid(src, p, 1) = " " OrElse Mid(src, p, 1) = Chr(9))
		p += 1
	Wend
End Sub

Function ExprParser.Cur() As String
	If p <= n Then Return Mid(src, p, 1)
	Return ""
End Function

Function ExprParser.ParsePrimary() As Double
	SkipSpaces()
	Dim As String c = Cur()

	'' parenthesised sub-expression
	If c = "(" Then
		p += 1
		Dim As Double v = ParseExpr()
		SkipSpaces()
		If Cur() = ")" Then p += 1 Else valid = False
		Return v
	End If

	'' number (integer or decimal)
	If (c >= "0" AndAlso c <= "9") OrElse c = "." Then
		Dim As String num = ""
		Dim As Integer dots = 0
		While p <= n
			Dim As String d = Mid(src, p, 1)
			If d >= "0" AndAlso d <= "9" Then
				num &= d : p += 1
			ElseIf d = "." AndAlso dots = 0 Then
				num &= d : dots += 1 : p += 1
			Else
				Exit While
			End If
		Wend
		Return Val(num)
	End If

	'' identifier: a function call func(...) or a named constant
	If LCase(c) >= "a" AndAlso LCase(c) <= "z" Then
		Dim As String id = ""
		While p <= n
			Dim As String d = LCase(Mid(src, p, 1))
			If d >= "a" AndAlso d <= "z" Then id &= d : p += 1 Else Exit While
		Wend
		SkipSpaces()
		If Cur() = "(" Then
			p += 1
			Dim As Double arg = ParseExpr()
			SkipSpaces()
			If Cur() = ")" Then p += 1 Else valid = False
			Select Case id
				Case "sin"          : Return Sin(arg)
				Case "cos"          : Return Cos(arg)
				Case "tan"          : Return Tan(arg)
				Case "atn", "atan"  : Return Atn(arg)
				Case "sqr", "sqrt"  : If arg < 0 Then valid = False : Return 0
				                      Return Sqr(arg)
				Case "exp"          : Return Exp(arg)
				Case "log", "ln"    : If arg <= 0 Then valid = False : Return 0
				                      Return Log(arg)
				Case "abs"          : Return Abs(arg)
				Case Else           : valid = False : Return 0
			End Select
		Else
			Select Case id
				Case "pi" : Return 3.14159265358979323846
				Case "e"  : Return 2.71828182845904523536
				Case Else : valid = False : Return 0
			End Select
		End If
	End If

	'' anything else is unexpected
	valid = False
	Return 0
End Function

Function ExprParser.ParseUnary() As Double
	SkipSpaces()
	Dim As String c = Cur()
	If c = "-" Then p += 1 : Return -ParseUnary()
	If c = "+" Then p += 1 : Return ParseUnary()
	Return ParsePrimary()
End Function

Function ExprParser.ParsePower() As Double
	Dim As Double lhs = ParseUnary()
	SkipSpaces()
	If Cur() = "^" Then
		p += 1
		Return lhs ^ ParsePower()   '' right associative: 2^2^3 = 2^(2^3)
	End If
	Return lhs
End Function

Function ExprParser.ParseTerm() As Double
	Dim As Double v = ParsePower()
	Do
		SkipSpaces()
		Dim As String c = Cur()
		If c = "*" Then
			p += 1 : v *= ParsePower()
		ElseIf c = "/" Then
			p += 1
			Dim As Double d = ParsePower()
			If d = 0 Then valid = False : Return 0
			v /= d
		Else
			Exit Do
		End If
	Loop
	Return v
End Function

Function ExprParser.ParseExpr() As Double
	Dim As Double v = ParseTerm()
	Do
		SkipSpaces()
		Dim As String c = Cur()
		If c = "+" Then
			p += 1 : v += ParseTerm()
		ElseIf c = "-" Then
			p += 1 : v -= ParseTerm()
		Else
			Exit Do
		End If
	Loop
	Return v
End Function

Function ExprParser.Evaluate(ByRef expr As String) As Double
	src = expr : n = Len(expr) : p = 1 : valid = True
	Dim As Double v = ParseExpr()
	SkipSpaces()
	If p <= n Then valid = False   '' unconsumed trailing characters -> malformed
	Return v
End Function

'' Evaluate an expression to a Double. `valid` is False on any syntax or math error.
Function EvalExpression(ByRef expr As String, ByRef valid As Boolean) As Double
	Dim As ExprParser parser
	Dim As Double v = parser.Evaluate(expr)
	valid = parser.valid
	Return v
End Function

'' Format a result for display: trim floating-point noise to 10 decimal places
'' and drop trailing zeros, so 0.1+0.2 shows "0.3" rather than "0.30000000000000004".
Function FormatEvalResult(ByVal v As Double) As String
	Dim As String r = Str(v)
	Dim As Integer dp = InStr(r, ".")
	If dp = 0 Then Return r
	If Len(r) - dp > 10 Then r = Left(r, dp + 10)
	While Right(r, 1) = "0" : r = Left(r, Len(r) - 1) : Wend
	If Right(r, 1) = "." Then r = Left(r, Len(r) - 1)
	Return r
End Function

'' Convenience: evaluate and return a ready-to-display string, or "Error".
Function EvalToDisplay(ByRef expr As String) As String
	Dim As Boolean valid
	Dim As Double v = EvalExpression(expr, valid)
	If Not valid Then Return "Error"
	Return FormatEvalResult(v)
End Function

#endif
