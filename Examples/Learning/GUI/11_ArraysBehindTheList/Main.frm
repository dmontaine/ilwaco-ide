' 11 - AN ARRAY BEHIND THE LIST
'
' An important habit: the ListView is not your data, it is a VIEW of your data.
' The scores live in an array; the list shows them. When the array changes, the
' display is rebuilt from it.
'
' Keeping the two apart is what lets you sort, total or save the data without
' picking strings back out of a control.
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
	#include once "mff/CommandButton.bi"
	#include once "mff/ListView.bi"
	#include once "vbcompat.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdAdd_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdSort_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Sub Redraw()

		Dim As Integer Scores(0 To 7)
		Dim As Integer Used
		Dim As CommandButton cmdAdd, cmdSort
		Dim As ListView lvScores
		Dim As Label lblStats
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
			.Text = "An array behind the list"
			.Designer = @This
			.SetBounds 0, 0, 440, 340
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With cmdAdd
			.Name = "cmdAdd" : .Text = "Add a random score"
			.SetBounds 20, 20, 170, 28
			.Designer = @This : .OnClick = @cmdAdd_Click : .Parent = @This
		End With
		With cmdSort
			.Name = "cmdSort" : .Text = "Sort them"
			.SetBounds 200, 20, 120, 28
			.Designer = @This : .OnClick = @cmdSort_Click : .Parent = @This
		End With
		With lvScores
			.Name = "lvScores"
			.SetBounds 20, 60, 300, 190
			.FullRowSelect = True
			.Designer = @This : .Parent = @This
		End With
		With lblStats
			.Name = "lblStats" : .Text = ""
			.SetBounds 20, 258, 380, 22
			.Designer = @This : .Parent = @This
		End With

		lvScores.Columns.Add("#"), , 60
		lvScores.Columns.Add("Score"), , 100
		Randomize Timer
		Used = 0
		Redraw()
	End Constructor

	Sub MainType.cmdAdd_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)

		' UBound is the last valid index. Checking against it is what stops a
		' program writing past the end of its own array.
		If frm->Used > UBound(frm->Scores) Then Exit Sub

		frm->Scores(frm->Used) = Int(Rnd * 100) + 1
		frm->Used += 1
		frm->Redraw()
	End Sub

	Sub MainType.cmdSort_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)

		' Sorting touches only the array. The display follows, because it is
		' rebuilt from the array rather than rearranged by hand.
		For i As Integer = 0 To frm->Used - 2
			For j As Integer = 0 To frm->Used - 2 - i
				If frm->Scores(j) > frm->Scores(j + 1) Then Swap frm->Scores(j), frm->Scores(j + 1)
			Next j
		Next i
		frm->Redraw()
	End Sub

	Sub MainType.Redraw()
		lvScores.ListItems.Clear
		Dim As Integer total = 0
		For i As Integer = 0 To Used - 1
			lvScores.ListItems.Add Str(i + 1)
			lvScores.ListItems.Item(i)->Text(1) = Str(Scores(i))
			total += Scores(i)
		Next i

		If Used = 0 Then
			lblStats.Text = "No scores yet. Room for " & Str(UBound(Scores) + 1) & "."
		Else
			lblStats.Text = Str(Used) & " score(s), total " & Str(total) & _
				", average " & Format(total / Used, "0.0")
		End If
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
