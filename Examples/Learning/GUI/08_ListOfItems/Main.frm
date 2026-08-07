' 08 - A LIST YOU CAN ADD TO
'
' A ListView shows rows, optionally in columns. This one is a to-do list: type
' something, add it, select a row and remove it.
'
' The order matters when setting one up: add the COLUMNS first, then the rows.
' Rows added before there is a column to hold them have nowhere to go.
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
	#include once "mff/ListView.bi"

	Using My.Sys.Forms

	Type MainType Extends Form
		Declare Constructor
		Declare Static Sub cmdAdd_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub cmdRemove_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Declare Static Sub lvItems_SelChanged(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Declare Sub ShowCount()

		Dim As Integer SelIndex

		Dim As TextBox txtItem
		Dim As CommandButton cmdAdd, cmdRemove
		Dim As ListView lvItems
		Dim As Label lblCount
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
			.Text = "A list you can add to"
			.Designer = @This
			.SetBounds 0, 0, 500, 320
			.StartPosition = FormStartPosition.CenterScreen
		End With
		With txtItem
			.Name = "txtItem" : .Text = ""
			.SetBounds 20, 20, 220, 24
			.Designer = @This : .Parent = @This
		End With
		With cmdAdd
			.Name = "cmdAdd" : .Text = "Add"
			.SetBounds 250, 19, 80, 26
			.Designer = @This : .OnClick = @cmdAdd_Click : .Parent = @This
		End With
		With cmdRemove
			.Name = "cmdRemove" : .Text = "Remove selected"
			.SetBounds 338, 19, 130, 26
			.Designer = @This : .OnClick = @cmdRemove_Click : .Parent = @This
		End With
		With lvItems
			.Name = "lvItems"
			.SetBounds 20, 56, 448, 180
			.FullRowSelect = True
			.Designer = @This
			.OnSelectedItemChanged = @lvItems_SelChanged
			.Parent = @This
		End With
		With lblCount
			.Name = "lblCount" : .Text = ""
			.SetBounds 20, 244, 300, 22
			.Designer = @This : .Parent = @This
		End With

		lvItems.Columns.Add("Task"), , 300
		lvItems.ListItems.Add "Read the comments in this file"
		lvItems.ListItems.Add "Add something of your own"
		SelIndex = -1
		ShowCount()
	End Constructor

	Sub MainType.cmdAdd_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		Dim As String what = Trim(frm->txtItem.Text)
		If Len(what) = 0 Then Exit Sub

		frm->lvItems.ListItems.Add what
		frm->txtItem.Text = ""       ' clear the box, ready for the next one
		frm->ShowCount()
	End Sub

	Sub MainType.cmdRemove_Click(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		Dim As Integer which = frm->SelIndex
		If which < 0 Then Exit Sub   ' nothing selected: do nothing, quietly

		frm->lvItems.ListItems.Remove which
		frm->SelIndex = -1           ' that row is gone -- forget it
		frm->ShowCount()
	End Sub

	' There is no "which row is selected?" property to read. The list TELLS you,
	' through this event, and remembering the answer is your job. Reaching for a
	' property that does not exist is a common first stumble with list controls.
	Sub MainType.lvItems_SelChanged(ByRef Designer As My.Sys.Object, ByRef Sender As ListView, ByVal ItemIndex As Integer)
		Dim As MainType Ptr frm = Cast(MainType Ptr, @Designer)
		frm->SelIndex = ItemIndex
	End Sub

	Sub MainType.ShowCount()
		lblCount.Text = Str(lvItems.ListItems.Count) & " item(s) in the list."
	End Sub

	Dim Shared Main As MainType

	#if _MAIN_FILE_ = __FILE__
		Main.MainForm = True
		Main.Show
		App.Run
	#endif
'#End Region
