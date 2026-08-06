'#########################################################
'#  ilwaco.bas                                           #
'#  This file is part of Ilwaco IDE                      #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################
'#ifndef __FB_WIN32__
'	#cmdline "-gen gas64"
'#endif
'#define __USE_GTK__
#ifndef __USE_MAKE__
	'#define __USE_GTK3__
	#define _NOT_AUTORUN_FORMS_
#endif

			#cmdline "-x ../ilwaco"

#define APP_TITLE "Ilwaco IDE"
#define VER_MAJOR "1"
#define VER_MINOR "3"
#define VER_PATCH "8"
#define VER_BUILD "0"
Const VERSION    = VER_MAJOR + "." + VER_MINOR + "." + VER_PATCH
Const BUILD_DATE = __DATE__
Const SIGN       = APP_TITLE + " " + VERSION

On Error Goto AA

#define MEMCHECK 0
#define FILENUMCHECK 1
#define _L DebugPrint_ __LINE__ & ": " & __FILE__ & ": " & __FUNCTION__:

Declare Sub DebugPrint_(ByRef MSG As WString)

#include once "Main.bi"
#include once "Debug.bi"
#include once "Designer.bi"
#include once "frmAddProcedure.frm"
#include once "frmAddType.frm"
#include once "frmOptions.bi"
#include once "frmGoto.bi"
#include once "frmFind.bi"
#include once "frmFindInFiles.bi"
#include once "frmProjectProperties.bi"
#include once "frmImageManager.bi"
#include once "frmParameters.bi"
#include once "frmAddIns.bi"
#include once "frmTools.bi"
#include once "frmAbout.bi"
#include once "TabWindow.bi"

Sub DebugPrint_(ByRef msg As WString)
	Debug.Print msg, True, False, False, False
End Sub

Sub StartDebuggingWithCompile(Param As Any Ptr)
	'	ThreadsEnter
	'	ChangeEnabledDebug False, True, True
	'	ThreadsLeave
	If Compile("RunWithDebug") Then Else ThreadsEnter: ChangeEnabledDebug True, False, False: ThreadsLeave
End Sub

Sub StartDebugging(Param As Any Ptr)
	ThreadsEnter
	ChangeEnabledDebug False, True, True
	ThreadsLeave
	RunProgramWithDebug(0)
End Sub

Sub RunCmd(Param As Any Ptr)
	Dim As UString MainFile = GetMainFile()
	Dim As UString cmd
	Dim As WString Ptr Workdir, CmdL
	If Trim(MainFile) = "" OrElse Trim(MainFile) = ML("Untitled") Then MainFile = GetFullPath(*ProjectsPath & "\1", pApp->FileName)
	If OpenCommandPromptInMainFileFolder Then
		WLet(Workdir, GetFolderName(MainFile))
	Else
		WLet(Workdir, *CommandPromptFolder)
	End If
		cmd = WGet(TerminalPath) & " --working-directory=""" & *Workdir & """"
		Shell(cmd)
	If Workdir Then _Deallocate( Workdir)
End Sub

Sub FindInFiles
	ThreadCounter(ThreadCreate_(@FindSub))
End Sub
Sub ReplaceInFiles
	ThreadCounter(ThreadCreate_(@ReplaceSub))
End Sub

Sub mClickMRU(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
	Select Case Sender.ToString
	Case "ClearFiles"
		miRecentFiles->Clear
		miRecentFiles->Enabled = False
		MRUFiles.Clear
	Case "ClearFolders"
		miRecentFolders->Clear
		miRecentFolders->Enabled = False
		MRUFolders.Clear
	Case "ClearSessions"
		miRecentSessions->Clear
		miRecentSessions->Enabled = False
		MRUSessions.Clear
	Case Else
		OpenFiles GetFullPath(Sender.ToString)
	End Select
End Sub

Sub mClickHelp(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	HelpOption.CurrentPath = Cast(MenuItem Ptr, @Sender)->ImageKey
	HelpOption.CurrentWord = ""
	ThreadCounter(ThreadCreate_(@RunHelp, @HelpOption))
End Sub

Sub mClickTool(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	Dim As MenuItem Ptr mi = Cast(MenuItem Ptr, @Sender)
	If mi = 0 Then Exit Sub
	Dim As UserToolType Ptr tt = mi->Tag
	If tt <> 0 Then tt->Execute
End Sub

Sub mClickWindow(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
	Dim As MenuItem Ptr mi = Cast(MenuItem Ptr, @Sender)
	If mi = 0 Then Exit Sub
	Dim As TabWindow Ptr tb = mi->Tag
	If tb <> 0 Then tb->SelectTab
End Sub

Sub SelectNextControl
	Select Case frmMain.ActiveControl
	Case @txtExplorer: tvExplorer.SetFocus
	Case @tvExplorer: txtExplorer.SetFocus
	Case @txtForm: tbToolBox.SetFocus
	Case @tbToolBox: txtForm.SetFocus
	Case @txtProperties: lvProperties.SetFocus
	Case @lvProperties: txtProperties.SetFocus
	Case @txtEvents: lvEvents.SetFocus
	Case @lvEvents: txtEvents.SetFocus
	End Select
End Sub

Sub ClearThreadsWindow
	lvThreads.Nodes.Clear
	tpThreads->Caption = ML("Threads")
End Sub

Sub mClick(ByRef Designer_ As My.Sys.Object, Sender As My.Sys.Object)
	Select Case Sender.ToString
	Case "NewProject":                          NewProject
	Case "OpenProject":                         OpenProject
	Case "RecentProject":                       OpenRecentProject
	Case "RenameProject":                       RenameProject
	Case "DeleteProject":                       DeleteProject
	Case "OpenFolder":                          OpenFolder
	Case "OpenSession":                         OpenSession
	Case "SaveProject":                         SaveProject ptvExplorer->SelectedNode
	Case "SaveProjectAs":                       SaveProject ptvExplorer->SelectedNode, True
	Case "SaveSession":                         SaveSession
	Case "CloseProject":                        CloseProject GetParentNode(ptvExplorer->SelectedNode)
	Case "New":                                 Dim As TabWindow Ptr tb = AddTab(ExePath & "/Templates/Files/Module.bas", False) : If tb <> 0 Then tb->FileName = ML("Untitled") : tb->Caption = tb->FileName + "*"
	Case "Open":                                OpenProgram
	Case "Save":                                Save
	Case "Print":                               PrintThis
	Case "PrintPreview":                        PrintPreview
	Case "PageSetup":                           PageSetup
	Case "CommandPrompt":                       ThreadCounter(ThreadCreate_(@RunCmd))
	Case "AddFromTemplates":                    AddFromTemplates
	Case "AddFilesToProject":                   AddFilesToProject
	Case "Rename":                              RenameFile
	Case "RemoveFileFromProject":               RemoveFileFromProject
	Case "OpenProjectFolder":                   OpenProjectFolder
	Case "ProjectProperties":                   pfProjectProperties->ShowModal *pfrmMain : pfProjectProperties->CenterToParent
	Case "SetAsMain":                           SetAsMain @Sender = miTabSetAsMain
	Case "ClearStartUp":                        SetMainNode 0
	Case "ReloadHistoryCode":                   ReloadHistoryCode
	Case "ProblemsCopy":                        If lvProblems.ListItems.Count < 1 Then Return Else Clipboard.SetAsText lvProblems.SelectedItem->Text(0)
	Case "ProblemsCopyAll":
		Dim As WString Ptr tmpStrPtr
		If lvProblems.ListItems.Count < 1 Then Return
		For j As Integer = 0 To lvProblems.ListItems.Count - 1
			WAdd(tmpStrPtr, !"\r\n" & lvProblems.ListItems.Item(j)->Text(0))
		Next
		Clipboard.SetAsText *tmpStrPtr
		_Deallocate(tmpStrPtr)
	Case "DarkMode":
		DarkMode = Not DarkMode
		App.DarkMode = DarkMode
		If (*CurrentTheme = "Default Theme" AndAlso DarkMode) OrElse (*CurrentTheme = "Dark (Visual Studio)" AndAlso Not DarkMode) Then
			WLet(CurrentTheme, IIf(DarkMode, "Dark (Visual Studio)", "Default Theme"))
			LoadTheme
			UpdateAllTabWindows
		End If
	Case "ProjectExplorer":                     If Not pnlLeft.Visible Then SetLeftClosedStyle False
	                                            tpProject->SelectTab: txtExplorer.SetFocus
	Case "PropertiesWindow":                    If Not pnlRight.Visible Then SetRightClosedStyle False
	                                            tpProperties->SelectTab: txtProperties.SetFocus
	Case "EventsWindow":                        If Not pnlRight.Visible Then SetRightClosedStyle False
	                                            tpEvents->SelectTab: txtEvents.SetFocus
	Case "Toolbox":                             If Not pnlLeft.Visible Then SetLeftClosedStyle False
	                                            tpToolbox->SelectTab: txtForm.SetFocus
	Case "OutputWindow":                        If Not pnlBottom.Visible Then ShowBottom : tpOutput->SelectTab
	Case "ProblemsWindow":                      If Not pnlBottom.Visible Then ShowBottom : tpProblems->SelectTab
	Case "SuggestionsWindow":                   If Not pnlBottom.Visible Then ShowBottom : tpSuggestions->SelectTab
	Case "FindWindow":                          If Not pnlBottom.Visible Then ShowBottom : tpFind->SelectTab
	Case "ToDoWindow":                          If Not pnlBottom.Visible Then ShowBottom : tpToDo->SelectTab
	Case "ChangeLogWindow":                     If Not pnlBottom.Visible Then ShowBottom : tpChangeLog->SelectTab
	Case "ImmediateWindow":                     If Not pnlBottom.Visible Then ShowBottom : tpImmediate->SelectTab
	Case "LocalsWindow":                        If Not pnlBottom.Visible Then ShowBottom : tpLocals->SelectTab
	Case "GlobalsWindow":                       If Not pnlBottom.Visible Then ShowBottom : tpGlobals->SelectTab
		'Case "ProceduresWindow":                    tpProcedures->SelectTab
	Case "ThreadsWindow":                       If Not pnlBottom.Visible Then ShowBottom : tpThreads->SelectTab
	Case "WatchWindow":                         If Not pnlBottom.Visible Then ShowBottom : tpWatches->SelectTab
	Case "ImageManager":                        pfImageManager->Show *pfrmMain : pfImageManager->CenterToParent
	Case "Toolbars":                            'ShowMainToolbar = Not ShowMainToolbar: ReBar1.Visible = ShowMainToolbar: pfrmMain->RequestAlign
	Case "Standard":                            ShowStandardToolBar = Not ShowStandardToolBar: MainReBar.Bands.Item(0)->Visible = ShowStandardToolBar: mnuStandardToolBar->Checked = ShowStandardToolBar: pfrmMain->RequestAlign
	Case "Edit":                                ShowEditToolBar = Not ShowEditToolBar: MainReBar.Bands.Item(1)->Visible = ShowEditToolBar: mnuEditToolBar->Checked = ShowEditToolBar: pfrmMain->RequestAlign
	Case "Project":                             ShowProjectToolBar = Not ShowProjectToolBar: MainReBar.Bands.Item(2)->Visible = ShowProjectToolBar: mnuProjectToolBar->Checked = ShowProjectToolBar: pfrmMain->RequestAlign
	Case "FormFormat":                          ShowFormatToolBar = Not ShowFormatToolBar: MainReBar.Bands.Item(6)->Visible = ShowFormatToolBar: mnuFormatToolBar->Checked = ShowFormatToolBar: pfrmMain->RequestAlign
	Case "Build":                               ShowBuildToolBar = Not ShowBuildToolBar: MainReBar.Bands.Item(3)->Visible = ShowBuildToolBar: mnuBuildToolBar->Checked = ShowBuildToolBar: pfrmMain->RequestAlign
	Case "Debug":                               ShowDebugToolBar = Not ShowDebugToolBar: MainReBar.Bands.Item(4)->Visible = ShowDebugToolBar: mnuDebugToolBar->Checked = ShowDebugToolBar: pfrmMain->RequestAlign
	Case "Run":                                 ShowRunToolBar = Not ShowRunToolBar: MainReBar.Bands.Item(5)->Visible = ShowRunToolBar: mnuRunToolBar->Checked = ShowRunToolBar: pfrmMain->RequestAlign
	Case "TBUseDebugger":                       ChangeUseDebugger tbtUseDebugger->Checked, 0
	Case "UseDebugger":                         ChangeUseDebugger CBool(gtk_check_menu_item_get_active(GTK_CHECK_MENU_ITEM(mnuUseDebugger->Widget))), 1  ' read GTK's real (post-click) state, not MFF's stale FChecked
	Case "UseProfiler":                         mnuUseProfiler->Checked = Not mnuUseProfiler->Checked
	Case "ShowWithFolders":                     ChangeFolderType ProjectFolderTypes.ShowWithFolders
	Case "ShowWithoutFolders":                  ChangeFolderType ProjectFolderTypes.ShowWithoutFolders
	Case "ShowAsFolder":                        ChangeFolderType ProjectFolderTypes.ShowAsFolder
	Case "SyntaxCheck":                         If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@SyntaxCheck))
	Case "CompileAll":                          If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileAll))
	Case "Compile":                             If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileProgram))
	Case "Make":                                If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@MakeExecute))
	Case "MakeClean":                           If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@MakeClean))
	Case "BuildBundle":                         If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileBundle))
	Case "BuildAPK":                            If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileAPK))
	Case "Suggestions":                         Suggestions
	Case "CreateKeyStore":                      CreateKeyStore
	Case "GenerateSignedBundle":                GenerateSignedBundleAPK("bundle")
	Case "GenerateSignedAPK":                   GenerateSignedBundleAPK("apk")
	Case "FormatProject":                       ThreadCounter(ThreadCreate_(@FormatProject)) 'FormatProject 0
	Case "UnformatProject":                     ThreadCounter(ThreadCreate_(@FormatProject, Cast(Any Ptr, 1))) 'FormatProject Cast(Any Ptr, 1)
	Case "Parameters":                          pfParameters->ShowModal *pfrmMain : pfParameters->CenterToParent
	Case "LocateProcedure":                     proc_loc
	Case "EnableDisable":                       proc_enable
	Case "StartWithCompile"
		ClearThreadsWindow
		If SaveAllBeforeCompile Then
			ChangeEnabledDebug False, True, True
			'SaveAll '
			If InDebug Then
				'#ifndef __USE_GTK__
				ChangeEnabledDebug False, True, True
					fastrun()
				'runtype = RTRUN
				'thread_resume()
				'#endif
				'runtype = RTAUTO
				'#ifdef __FB_WIN32__
				'	set_cc()
				'#else
				'	If ccstate = KCC_NONE Then
				'		msgdata = 1 ''CC everywhere
				'		exec_order(KPT_CCALL)
				'	End If
				'#endif
				'thread_set()
			ElseIf UseDebugger Then
				runtype = RTFRUN
				'runtype = RTRUN
				'runtype = RTAUTO
				'#ifdef __FB_WIN32__
				'	set_cc()
				'#else
				'	If ccstate = KCC_NONE Then
				'		msgdata = 1 ''CC everywhere
				'		exec_order(KPT_CCALL)
				'	End If
				'#endif
				'thread_set()
				SetTimer(0, GTIMER001, 1, Cast(Any Ptr, @DEBUG_EVENT))
				CurrentTimer = SetTimer(0, 0, 1, @TIMERPROC)
				ThreadCounter(ThreadCreate_(@StartDebuggingWithCompile))
			Else
				ThreadCounter(ThreadCreate_(@CompileAndRun))
			End If
		End If
	Case "Start"
		ClearThreadsWindow
		If InDebug Then
			'#ifndef __USE_GTK__
			ChangeEnabledDebug False, True, True
			'runtype = RTRUN
			'thread_resume()
			'#endif
		ElseIf UseDebugger Then
			'#ifndef __USE_GTK__
			runtype = RTFRUN
			'runtype = RTRUN
			SetTimer(0, GTIMER001, 1, Cast(Any Ptr, @DEBUG_EVENT))
			CurrentTimer = SetTimer(0, 0, 1, @TIMERPROC)
			'#endif
			ThreadCounter(ThreadCreate_(@StartDebugging))
		Else
			ThreadCounter(ThreadCreate_(@RunProgram))
		End If
	Case "Break":
			ChangeEnabledDebug True, False, True
	Case "End":
		'#ifdef __USE_GTK__
		'	ChangeEnabledDebug True, False, False
		'#else
		'kill_process("Terminate immediatly no saved data, other option Release")
		For i As Integer = 1 To linenb 'restore old instructions
			WriteProcessMemory(dbghand, Cast(LPVOID, rline(i).ad), @rline(i).sv, 1, 0)
		Next
		runtype = RTFREE
		'but_enable()
		thread_resume()
		DeleteDebugCursor
		ChangeEnabledDebug True, False, False
		'#endif
		ClearDebugPanels
	Case "Restart"
		ClearThreadsWindow
		'#ifndef __USE_GTK__
		If prun AndAlso kill_process(ML("Trying to launch but debuggee still running")) = False Then
			Exit Sub
		End If
		runtype = RTFRUN
		'runtype = RTRUN
		SetTimer(0, GTIMER001, 1, Cast(Any Ptr, @DEBUG_EVENT))
		CurrentTimer = SetTimer(0, 0, 1, @TIMERPROC)
		Restarting = True
		ThreadCounter(ThreadCreate_(@StartDebugging))
		'#endif
	Case "StepInto":
		ClearThreadsWindow
		ptabBottom->TabIndex = 6 'David Changed
		If InDebug Then
			ChangeEnabledDebug False, True, True
			'runtype = RTSTEP
			'stopcode=0
			''bcktrk_close
			'SetFocus(windmain)
			'thread_resume
				If ccstate=KCC_NONE Then
					msgdata=1 ''CC everywhere
					exec_order(KPT_CCALL)
				End If
			dbg_prt2 "=============== STEP =================================="
			stopcode=0
			runtype=RTSTEP
			thread_set()
			'thread_resume()
		Else
			runtype = RTSTEP
			SetTimer(0, GTIMER001, 1, Cast(Any Ptr, @DEBUG_EVENT))
			CurrentTimer = SetTimer(0, 0, 1, @TIMERPROC)
			ThreadCounter(ThreadCreate_(@StartDebugging))
		End If
	Case "StepOver":
		ClearThreadsWindow
		If InDebug Then
			ChangeEnabledDebug False, True, True
		Else
			ThreadCounter(ThreadCreate_(@StartDebugging))
		End If
	Case "SaveAs", "Close", "SyntaxCheck", "Compile", "CompileAndRun", "Run", "RunToCursor", "SplitHorizontally", "SplitVertically", _
		"Start", "Stop", "StepOut", "FindNext", "FindPrev", "Goto", "SetNextStatement", "SplitLines", "CombineLines", "SortLines", "DeleteBlankLines", "FormatWithBasisWord", "ConvertFromHexStrUnicode", "ConvertToHexStrUnicode", "ConvertToUppercaseFirstLetter", "ConvertToLowercase", "ConvertToUppercase", "SplitUp", "SplitDown", "SplitLeft", "SplitRight", _
		"AddWatch", "ShowVar", "NextBookmark", "PreviousBookmark", "ClearAllBookmarks", "Code", "Form", "CodeAndForm", "GotoCodeForm", "AddProcedure", "AddType"
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		Select Case Sender.ToString
		Case "Save":                        tb->Save
		Case "SaveAs":                      tb->SaveAs:  frmMain.Caption = tb->FileName & " - " & App.Title
		Case "Close":                       CloseTab(tb)
		Case "SplitLines":                  tb->SplitLines
		Case "CombineLines":                tb->CombineLines
		Case "SortLines":                   tb->SortLines
		Case "DeleteBlankLines":            tb->DeleteBlankLines
		Case "FormatWithBasisWord" :        tb->FormatWithBasisWord
		Case "ConvertToLowercase":          tb->ConvertToLowercase
		Case "ConvertToUppercase":          tb->ConvertToUppercase
		Case "ConvertToHexStrUnicode":          tb->ConvertToHexStrUnicode
		Case "ConvertFromHexStrUnicode":          tb->ConvertFromHexStrUnicode
		Case "ConvertToUppercaseFirstLetter": tb->ConvertToUppercaseFirstLetter
		Case "SplitHorizontally":           tb->txtCode.SplittedHorizontally = Not mnuSplitHorizontally->Checked
		Case "SplitVertically":             tb->txtCode.SplittedVertically = Not mnuSplitVertically->Checked
		Case "SplitUp", "SplitDown", "SplitLeft", "SplitRight":
			Var ptabCode = Cast(TabControl Ptr, mnuTabs.ParentWindow)
			Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
			Var tp = Cast(TabPanel Ptr, tb->Parent->Parent)
			Var ptabPanelNew = _New(TabPanel)
			Var bUpDown = False
			Select Case Sender.ToString
			Case "SplitUp"
				ptabPanelNew->Align = DockStyle.alTop
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alTop
				bUpDown = True
			Case "SplitDown"
				ptabPanelNew->Align = DockStyle.alBottom
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alBottom
				bUpDown = True
			Case "SplitLeft"
				ptabPanelNew->Align = DockStyle.alLeft
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alLeft
			Case "SplitRight"
				ptabPanelNew->Align = DockStyle.alRight
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alRight
			End Select
			Var ptabPanel = Cast(TabPanel Ptr, tb->Parent->Parent)
			Var Idx = tp->IndexOf(tb->Parent)
			tp->Add ptabPanelNew, Idx
			tp->Add @ptabPanelNew->splGroup, Idx + 1
			Var SplitterCount = 0 'Fix(tp->ControlCount / 2)
			For i As Integer = 1 To tp->ControlCount - 2 Step 2
				If bUpDown Then
					If tp->Controls[i]->Align = DockStyle.alTop OrElse tp->Controls[i]->Align = DockStyle.alBottom Then SplitterCount += 1
				Else
					If tp->Controls[i]->Align = DockStyle.alLeft OrElse tp->Controls[i]->Align = DockStyle.alRight Then SplitterCount += 1
				End If
			Next
			For i As Integer = 0 To tp->ControlCount - 2 Step 2
				If bUpDown Then
					tp->Controls[i]->Height = (tp->Height - ptabPanelNew->splGroup.Height * SplitterCount) / (SplitterCount + 1)
				Else
					tp->Controls[i]->Width = (tp->Width - ptabPanelNew->splGroup.Width * SplitterCount) / (SplitterCount + 1)
				End If
			Next
				g_object_ref(tb->Handle)
				g_object_ref(tb->btnClose.Handle)
				gtk_container_remove(GTK_CONTAINER(tb->_Box), tb->btnClose.Handle)
			'ptabPanel->tabCode.DeleteTab tb
			tb->Parent = @ptabPanelNew->tabCode
				tb->txtCode.cr = 0
				gtk_box_pack_end(GTK_BOX(tb->_Box), tb->btnClose.Handle, False, False, 0)
			ptabCode = @ptabPanelNew->tabCode
			TabPanels.Add ptabPanelNew
		Case "SetNextStatement":
			ClearThreadsWindow
		Case "ShowVar":
			'#ifndef __USE_GTK__
			var_tip(1)
			'#endif
		Case "StepOut":
			ClearThreadsWindow
		Case "RunToCursor":
			ClearThreadsWindow
			If InDebug Then
				ChangeEnabledDebug False, True, True
			Else
				RunningToCursor = True
				runtype = RTFRUN
				'#ifndef __USE_GTK__
				CurrentTimer = SetTimer(0, 0, 1, @TIMERPROC)
				'#endif
				ThreadCounter(ThreadCreate_(@StartDebugging))
			End If
		Case "AddWatch":
			'#ifndef __USE_GTK__
			var_tip(2)
			'#endif
		Case "FindNext":                    pfFind->Find(True)
		Case "FindPrev":                    pfFind->Find(False)
		Case "Goto":                        pfGoto->Show *pfrmMain : pfGoto->CenterToParent
		Case "NextBookmark":                NextBookmark 1
		Case "PreviousBookmark":            NextBookmark -1
		Case "ClearAllBookmarks":           ClearAllBookmarks
		Case "Code":                        tb->tbrTop.Buttons.Item("Code")->Checked = True: tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item("Code")
		Case "Form":                        tb->tbrTop.Buttons.Item("Form")->Checked = True: tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item("Form")
		Case "CodeAndForm":                 tb->tbrTop.Buttons.Item("CodeAndForm")->Checked = True: tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item("CodeAndForm")
		Case "GotoCodeForm":
			If tb->txtCode.Focused Then
				If tb->tbrTop.Buttons.Item("Code")->Checked Then tb->tbrTop.Buttons.Item(tb->LastButton)->Checked = True: tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item(tb->LastButton)
				If tb->Des Then DesignerChangeSelection(*tb->Des, tb->Des->SelectedControl)
			Else
				If tb->tbrTop.Buttons.Item("Form")->Checked Then tb->tbrTop.Buttons.Item("Code")->Checked = True: tbrTop_ButtonClick *tb->tbrTop.Designer, tb->tbrTop, *tb->tbrTop.Buttons.Item("Code")
				Dim As Integer iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
				tb->txtCode.GetSelection iSelStartLine, iSelEndLine, iSelStartChar, iSelEndChar
				tb->txtCode.SetFocus
				OnLineChangeEdit *tb->txtCode.Designer, tb->txtCode, iSelEndLine, iSelEndLine
			End If
		Case "AddProcedure":                frmAddProcedure.ShowModal frmMain
		Case "AddType":                     frmAddType.ShowModal frmMain
		End Select
	Case "SaveAll":                         SaveAll
	Case "CloseAll":                        CloseAllTabs
	Case "CloseSession":                    CloseSession
	Case "CloseAllWithoutCurrent":          CloseAllTabs(True)
	Case "Exit":                            pfrmMain->CloseForm
	Case "Find":                            pfFind->mFormFind = True: pfFind->Show *pfrmMain
	Case "FindInFiles":                     mFormFindInFile = True:  pfFindFile->Show *pfrmMain : pfFindFile->CenterToParent
	Case "ReplaceInFiles":                  mFormFindInFile = False:  pfFindFile->Show *pfrmMain : pfFindFile->CenterToParent
	Case "Replace":                         pfFind->mFormFind = False: pfFind->Show *pfrmMain
	Case "PinLeft":
		' splLeft.Visible tracks open/closed: open -> collapse to the pin strip, closed -> re-open.
		If splLeft.Visible Then SetLeftClosedStyle True, True Else SetLeftClosedStyle False, True
	Case "PinRight":
		' splRight.Visible tracks open/closed: open -> collapse to the rail, closed -> re-open.
		If splRight.Visible Then SetRightClosedStyle True, True Else SetRightClosedStyle False, True
	Case "PinBottom":
		' splBottom.Visible tracks open/closed: open -> collapse to the rail, closed -> re-open.
		If splBottom.Visible Then SetBottomClosedStyle True, True Else SetBottomClosedStyle False, True
	Case "EraseOutputWindow":               txtOutput.Text = ""
	Case "EraseImmediateWindow":            txtImmediate.Text = ""
	Case "AddForm":                         AddFromTemplate ExePath + "/Templates/Files/Form.frm"
	Case "AddModule":                       AddFromTemplate ExePath + "/Templates/Files/Module.bas"
	Case "AddIncludeFile":                  AddFromTemplate ExePath + "/Templates/Files/Include File.bi"
	Case "AddUserControl":                  AddFromTemplate ExePath + "/Templates/Files/User Control.bas"
	Case "AddResource":                     AddFromTemplate ExePath + "/Templates/Files/Resource.rc"
	Case "AddManifest":                     AddFromTemplate ExePath + "/Templates/Files/Manifest.xml"
	Case "VariableDump":                var_dump(tviewvar)
	Case "PointedDataDump":             var_dump(tviewvar, 1)
	Case "MemoryDumpWatch":             var_dump(tviewwch)
	Case "Undo", "Redo", "CutCurrentLine", "Cut", "Copy", "Paste", "SelectAll", "Duplicate", "SingleComment", "BlockComment", "UnComment", _
		"Indent", "Outdent", "Format", "Unformat", "AddSpaces", _
		"Breakpoint", "ToggleBookmark", "CollapseAll", "UnCollapseAll", "CollapseAllProcedures", "UnCollapseAllProcedures", _
		"CollapseCurrent", "UnCollapseCurrent", "CompleteWord", "ParameterInfo", "Define", _
		"AlignLefts", "AlignCenters", "AlignRights", "AlignTops", "AlignMiddles", "AlignBottoms", "AlignToGrid", "MakeSameSizeWidth", "MakeSameSizeHeight", "MakeSameSizeBoth", "SizeToGrid", _
		"HorizontalSpacingMakeEqual", "HorizontalSpacingIncrease", "HorizontalSpacingDecrease", "HorizontalSpacingRemove", "VerticalSpacingMakeEqual", "VerticalSpacingIncrease", "VerticalSpacingDecrease", _
		"VerticalSpacingRemove", "CenterInParentHorizontally", "CenterInParentVertically", "SendToBack", "BringToFront", "LockControls", "TBLockControls"
		If Sender.ToString = "LockControls" OrElse Sender.ToString = "TBLockControls" Then
			Select Case Sender.ToString
			Case "TBLockControls": ChangeLockControls tbtLockControls->Checked, 0
			Case "LockControls": ChangeLockControls Not miLockControls->Checked, 1
			End Select
			If ptabCode <> 0 Then
				Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
				If tb <> 0 Then
					Dim des As Designer Ptr = tb->Des
					If des <> 0 Then
						des->LockControls = miLockControls->Checked
						des->Parent->Repaint
					End If
				End If
			End If
		End If
		Dim As Form Ptr ActiveForm = Cast(Form Ptr, pApp->ActiveForm)
		If ActiveForm = 0 Then Exit Sub
		If ActiveForm->ActiveControl = 0 Then
			Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
			If tb <> 0 AndAlso tb->cboClass.ItemIndex > 0 Then
				Dim des As Designer Ptr = tb->Des
				If des = 0 Then Exit Sub
				Select Case Sender.ToString
				Case "Cut":                         des->CutControl
				Case "Copy":                        des->CopyControl
				Case "Paste":                       des->PasteControl
				Case "Delete":                      des->DeleteControl
				Case "Duplicate":                   des->DuplicateControl
				Case "SelectAll":                   des->SelectAllControls
				Case "Indent":                      des->SelectNextControl
				Case "Outdent":                     des->SelectNextControl - 1
				Case "AlignLefts":                  des->AlignLefts
				Case "AlignCenters":                des->AlignCenters
				Case "AlignRights":                 des->AlignRights
				Case "AlignTops":                   des->AlignTops
				Case "AlignMiddles":                des->AlignMiddles
				Case "AlignBottoms":                des->AlignBottoms
				Case "AlignToGrid":                 des->AlignToGrid
				Case "MakeSameSizeWidth":           des->MakeSameSizeWidth
				Case "MakeSameSizeHeight":          des->MakeSameSizeHeight
				Case "MakeSameSizeBoth":            des->MakeSameSizeBoth
				Case "SizeToGrid":                  des->SizeToGrid
				Case "HorizontalSpacingMakeEqual":  des->HorizontalSpacingMakeEqual
				Case "HorizontalSpacingIncrease":   des->HorizontalSpacingIncrease
				Case "HorizontalSpacingDecrease":   des->HorizontalSpacingDecrease
				Case "HorizontalSpacingRemove":     des->HorizontalSpacingRemove
				Case "VerticalSpacingMakeEqual":    des->VerticalSpacingMakeEqual
				Case "VerticalSpacingIncrease":     des->VerticalSpacingIncrease
				Case "VerticalSpacingDecrease":     des->VerticalSpacingDecrease
				Case "VerticalSpacingRemove":       des->VerticalSpacingRemove
				Case "CenterInParentHorizontally":  des->CenterInParentHorizontally
				Case "CenterInParentVertically":    des->CenterInParentVertically
				Case "SendToBack":                  des->SendToBack
				Case "BringToFront":                des->BringToFront
				End Select
			End If
			Exit Sub
		End If
		Select Case Sender.ToString
		Case "Indent", "Outdent":           SelectNextControl
		End Select
		If ActiveForm->ActiveControl->ClassName <> "EditControl" AndAlso ActiveForm->ActiveControl->ClassName <> "TextBox" AndAlso ActiveForm->ActiveControl->ClassName <> "RichTextBox" AndAlso ActiveForm->ActiveControl->ClassName <> "Panel" AndAlso ActiveForm->ActiveControl->ClassName <> "ComboBoxEdit" AndAlso ActiveForm->ActiveControl->ClassName <> "ComboBoxEx" Then Exit Sub
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If ActiveForm->ActiveControl->ClassName = "TextBox" OrElse ActiveForm->ActiveControl->ClassName = "RichTextBox" Then
			Dim txt As TextBox Ptr = Cast(TextBox Ptr, pfrmMain->ActiveControl)
			Select Case Sender.ToString
			Case "Undo":                            txt->Undo
			Case "Cut":                             txt->CutToClipboard
			Case "Copy":                            txt->CopyToClipboard
			Case "Paste":                           txt->PasteFromClipboard
			Case "SelectAll":                       txt->SelectAll
			End Select
		ElseIf ActiveForm->ActiveControl->ClassName = "ComboBoxEdit" OrElse ActiveForm->ActiveControl->ClassName = "ComboBoxEx" Then
			Dim cbo As ComboBoxEdit Ptr = Cast(ComboBoxEdit Ptr, ActiveForm->ActiveControl)
			Select Case Sender.ToString
			Case "Undo":                            cbo->Undo
			Case "Cut":                             cbo->CutToClipboard
			Case "Copy":                            cbo->CopyToClipboard
			Case "Paste":                           cbo->PasteFromClipboard
			Case "SelectAll":                       cbo->SelectAll
			End Select
		ElseIf tb <> 0 Then
			If tb->cboClass.ItemIndex > 0 Then
				Dim des As Designer Ptr = tb->Des
				If des = 0 Then Exit Sub
				Select Case Sender.ToString
				Case "Cut":                         des->CutControl
				Case "Copy":                        des->CopyControl
				Case "Paste":                       des->PasteControl
				Case "Delete":                      des->DeleteControl
				Case "Duplicate":                   des->DuplicateControl
				Case "SelectAll":                   des->SelectAllControls
				Case "Indent":                      des->SelectNextControl
				Case "Outdent":                     des->SelectNextControl - 1
				Case "AlignLefts":                  des->AlignLefts
				Case "AlignCenters":                des->AlignCenters
				Case "AlignRights":                 des->AlignRights
				Case "AlignTops":                   des->AlignTops
				Case "AlignMiddles":                des->AlignMiddles
				Case "AlignBottoms":                des->AlignBottoms
				Case "AlignToGrid":                 des->AlignToGrid
				Case "MakeSameSizeWidth":           des->MakeSameSizeWidth
				Case "MakeSameSizeHeight":          des->MakeSameSizeHeight
				Case "MakeSameSizeBoth":            des->MakeSameSizeBoth
				Case "SizeToGrid":                  des->SizeToGrid
				Case "HorizontalSpacingMakeEqual":  des->HorizontalSpacingMakeEqual
				Case "HorizontalSpacingIncrease":   des->HorizontalSpacingIncrease
				Case "HorizontalSpacingDecrease":   des->HorizontalSpacingDecrease
				Case "HorizontalSpacingRemove":     des->HorizontalSpacingRemove
				Case "VerticalSpacingMakeEqual":    des->VerticalSpacingMakeEqual
				Case "VerticalSpacingIncrease":     des->VerticalSpacingIncrease
				Case "VerticalSpacingDecrease":     des->VerticalSpacingDecrease
				Case "VerticalSpacingRemove":       des->VerticalSpacingRemove
				Case "CenterInParentHorizontally":  des->CenterInParentHorizontally
				Case "CenterInParentVertically":    des->CenterInParentVertically
				Case "SendToBack":                  des->SendToBack
				Case "BringToFront":                des->BringToFront
				End Select
			ElseIf ActiveForm->ActiveControl->ClassName = "EditControl" OrElse ActiveForm->ActiveControl->ClassName = "Panel" Then
				Dim ec As EditControl Ptr = @tb->txtCode
				Select Case Sender.ToString
				Case "Redo":                        ec->Redo
				Case "Undo":                        ec->Undo
				Case "CutCurrentLine":              ec->CutCurrentLineToClipboard
				Case "Cut":                         ec->CutToClipboard
				Case "Copy":                        ec->CopyToClipboard
				Case "Paste":                       ec->PasteFromClipboard
				Case "Duplicate":                   ec->DuplicateLine
				Case "SelectAll":                   ec->SelectAll
				Case "SingleComment":               ec->CommentSingle
				Case "BlockComment":                ec->CommentBlock
				Case "UnComment":                   ec->UnComment
				Case "Indent":                      ec->Indent
				Case "Outdent":                     ec->Outdent
				Case "Format":                      ec->FormatCode
				Case "Unformat":                    ec->UnformatCode
				Case "AddSpaces":                   tb->AddSpaces
				Case "Breakpoint":
					ec->Breakpoint
				Case "CollapseAll":                 ec->CollapseAll
				Case "UnCollapseAll":               ec->UnCollapseAll
				Case "CollapseAllProcedures":       ec->CollapseAllProcedures
				Case "UnCollapseAllProcedures":     ec->UnCollapseAllProcedures
				Case "CollapseCurrent":             ec->CollapseCurrent
				Case "UnCollapseCurrent":           ec->UnCollapseCurrent
				Case "CompleteWord":                CompleteWord
				Case "ParameterInfo":               ParameterInfo 0
				Case "ToggleBookmark":              ec->Bookmark
				Case "Define":                      tb->Define
				End Select
			End If
		End If
	Case "Options":                         pfOptions->Show *pfrmMain : pfOptions->CenterToParent
	Case "AddIns":                          pfAddIns->Show *pfrmMain : pfAddIns->CenterToParent
	Case "Tools":                           pfTools->Show *pfrmMain : pfTools->CenterToParent
	Case "Content":                         ThreadCounter(ThreadCreate_(@RunHelp))
	Case "FreeBasicForums":                 OpenUrl "https://www.freebasic.net/forum/index.php"
	Case "FreeBasicWiKi":                   OpenUrl "https://www.freebasic.net/wiki/wikka.php?wakka=PageIndex"
	Case "About":                           pfAbout->Show *pfrmMain : pfAbout->CenterToParent
	Case "TipoftheDay":                     pfTipOfDay->ShowModal *pfrmMain : pfTipOfDay->CenterToParent
	End Select
End Sub

'' Agent MCP command server implementation -- included here, last, so its handlers see
'' every IDE symbol (project model, tabs, output pane). The declarations came in early via
'' AgentPipe.bi (Main.bas), which is what frmMain_Show/frmMain_Close call.
#include once "AgentPipe.bas"

pApp->MainForm = @frmMain
pApp->Run

End
AA:
MsgBox ErrDescription(Err) & " (" & Err & ") " & _
"in line " & Erl() & " (Handler line: " & __LINE__ & ") " & _
"in function " & ZGet(Erfn()) & " (Handler function: " & __FUNCTION__ & ") " & _
"in module " & ZGet(Ermn()) & " (Handler file: " & __FILE__ & ") "
