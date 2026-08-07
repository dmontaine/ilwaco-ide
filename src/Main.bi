'#########################################################
'#  Main.bi                                              #
'#  This file is part of Ilwaco IDE                      #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

#include once "mff/WStringList.bi"
#include once "mff/Dictionary.bi"
#include once "mff/Form.bi"
#include once "mff/ComboBoxEdit.bi"
#include once "mff/CommandButton.bi"
#include once "mff/Dialogs.bi"
#include once "mff/TreeView.bi"
#include once "mff/TreeListView.bi"
#include once "mff/ProgressBar.bi"
#include once "mff/TabControl.bi"
#include once "mff/ToolPalette.bi"
#include once "mff/TextBox.bi"
#include once "mff/StatusBar.bi" 'David Change
#include once "mff/IniFile.bi"
#include once "mff/HTTP.bi"

				#define SettingsPath ExePath & "/Settings/ilwaco.ini"
				#define WorkspacePath ExePath & "/Settings/Workspace.ini"

	#define Slash "/"
	#define BackSlash "\"
	#define MAX_PATH 260

'' Prefer rename(2) over FreeBASIC's Name statement for paths held in UString: Name reports failure
'' only through Err and otherwise carries on, so a failed rename is SILENT. rename() gives errno,
'' which is what lets the IDE tell the user why. (Measured on Rename Project, 2026-08-04.)
#include once "crt/errno.bi"
Extern "C"
	Declare Function rename_ Alias "rename" (ByVal oldpath As Const ZString Ptr, ByVal newpath As Const ZString Ptr) As Long
	Declare Function strerror_ Alias "strerror" (ByVal errnum As Long) As ZString Ptr
End Extern

	Type WStringOrStringList As WStringList
	Type WStringOrStringListItem As WStringListItem

Extern "rtlib"
	Declare Function LineInputWstr Alias "fb_FileLineInputWstr"(ByVal filenumber As Long, ByVal dst As WString Ptr, ByVal maxchars As Integer) As Long
End Extern

Using My.Sys.Forms

Namespace VisualFBEditor
	Type Application Extends My.Application
		Declare Virtual Function ReadProperty(ByRef PropertyName As String) As Any Ptr
		Declare Virtual Function WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
	End Type
End Namespace

'#if defined(__FB_WIN32__) AndAlso defined(__USE_GTK__)
'	#define MAX_PATH 260
'#endif

Type HelpOptions
	CurrentPath As WString * MAX_PATH
	CurrentWord As WString * MAX_PATH
End Type
Common Shared As HelpOptions HelpOption

Declare Function MS cdecl(ByRef V As WString, ...) As UString
Declare Function HK(Key As String, Default As String = "", WithSpace As Boolean = False) As String
Declare Function MP(ByRef V As WString) ByRef As WString
Declare Function MLCompilerFun(ByRef V As WString) ByRef As WString
Declare Function MC(ByRef V As WString) ByRef As WString
Declare Sub PopupClick(ByRef Designer As My.Sys.Object, ByRef Sender As My.Sys.Object)
Declare Sub mClick(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
Declare Sub mClickMRU(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
Declare Sub mClickHelp(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
Declare Sub mClickTool(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
Declare Sub mClickWindow(ByRef Designer As My.Sys.Object, Sender As My.Sys.Object)
Declare Sub LoadSettings
Declare Sub LoadLanguageTexts

Common Shared As Form Ptr pfrmMain
Common Shared As ComboBoxEdit Ptr pcboBuildConfiguration
Common Shared As SaveFileDialog Ptr pSaveD
Common Shared As ListView Ptr plvSearch, plvToDo
Common Shared As StatusBar Ptr pstBar 'David Changed
Common Shared As TreeListView Ptr plvProperties, plvEvents
Common Shared As ImageList Ptr pimgList, pimgListTools
Common Shared As ProgressBar Ptr pprProgress
Common Shared As CommandButton Ptr pbtnPropertyValue
Common Shared As TextBox Ptr ptxtPropertyValue
Common Shared As ToolBar Ptr ptbStandard
Common Shared As ToolButton Ptr SelectedTool
Common Shared As TabControl Ptr ptabCode, ptabLeft, ptabBottom, ptabRight
Common Shared As TreeView Ptr ptvExplorer
Common Shared As IniFile Ptr piniSettings, piniTheme
Common Shared As MenuItem Ptr mnuUseDebugger, mnuUseProfiler, miHelps, miXizmat, miWindow
Common Shared As FileEncodings DefaultFileFormat
Common Shared As NewLineTypes DefaultNewLineFormat
Common Shared As Boolean AutoIncrement
Common Shared As Boolean AutoComplete
Common Shared As Boolean AutoSuggestions, ProjectAutoSuggestions
Common Shared As Boolean AutoCreateRC
Common Shared As Boolean AutoCreateBakFiles, gLocalProperties
Common Shared As Boolean AddRelativePathsToRecent
Common Shared As Boolean AllowAgentControl   ' Tools > Options: let the ilwaco-mcp sidecar drive the IDE (MCP)
Common Shared As Boolean UseMakeOnStartWithCompile
Common Shared As Boolean CreateNonStaticEventHandlers, CreateFormTypesWithoutTypeWord
Common Shared As Boolean PlaceStaticEventHandlersAfterTheConstructor, CreateStaticEventHandlersWithAnUnderscoreAtTheBeginning, CreateEventHandlersWithoutStaticEventHandlerIfEventAllowsIt
Common Shared As Boolean DisplayWarningsInDebug, TurnOnEnvironmentVariables
Common Shared As Boolean UseDebugger, ParameterInfoShow, LockControls
Common Shared As Boolean CompileGUI
Common Shared As Boolean mFormFindInFile
Common Shared As Boolean InDebug, FormClosing, Restarting, FastRunning, RunningToCursor
Common Shared As Boolean HighlightCurrentLine, HighlightCurrentWord, HighlightBrackets
Common Shared As Boolean mTabSelChangeByError
Common Shared As Boolean DisplayMenuIcons, ShowMainToolBar, DarkMode, ShowStandardToolBar, ShowEditToolBar, ShowProjectToolBar, ShowFormatToolBar, ShowBuildToolBar, ShowDebugToolBar, ShowRunToolBar
Common Shared As Boolean ShowKeywordsToolTip, ShowTooltipsAtTheTop, ShowHorizontalSeparatorLines, ShowIndentGuides, ShowTipoftheDay
Common Shared As Boolean OpenCommandPromptInMainFileFolder, ShowProjectFolders
Common Shared As Integer ShowTipoftheDayIndex
Common Shared As Integer AutoSaveBeforeCompiling, HistoryCodeDays
Common Shared As Double  HistoryCodeCleanDay
Common Shared As Integer IncludeMFFPath
Common Shared As Integer gSearchItemIndex
Common Shared As Integer InterfaceFontSize
Common Shared As Integer LoadFunctionsCount
Common Shared As String  UseDefine
Common Shared As WString Ptr InterfaceFontName
Common Shared As WString Ptr gSearchSave, EnvironmentVariables
Common Shared As WString Ptr ProjectsPath, LastOpenPath, CommandPromptFolder
Common Shared As WString Ptr DefaultHelp, HelpPath, KeywordsHelpPath, AsmKeywordsHelpPath, DefaultBuildConfiguration
Common Shared As WString Ptr DefaultMakeTool, CurrentMakeTool1, CurrentMakeTool2
Common Shared As WString Ptr DefaultTerminal, CurrentTerminal
Common Shared As WString Ptr MakeToolPath1, MakeToolPath2, TerminalPath, Compiler64Path
' The bundled FreeBASIC compiler is the one and only compiler, hard-coded here
' (resolved relative to the executable, so it travels inside the AppImage bundle).
#define BundledCompilerPath "./Compilers/FreeBASIC-1.10.1-linux-x86_64/bin/fbc"
Common Shared As WString Ptr Compiler64Arguments, Make1Arguments, Make2Arguments, RunArguments, Debug64Arguments
Common Shared As Any Ptr tlock, tlockSave, tlockToDo, tlockSuggestions

Type Library
	Name As UString
	Tips As UString
	Path As UString
	HeadersFolder As UString
	SourcesFolder As UString
	IncludeFolder As UString
	LibX64Folder As UString
	Enabled As Boolean
	Handle As Any Ptr
End Type

Type ToolType
	Name As UString
	Path As UString
	Parameters As UString
	Extensions As UString
	Declare Function GetCommand(ByRef FileName As WString = "", WithoutProgram As Boolean = False) As UString
End Type

'Type FileType
'	FileName As UString
'	DateChanged As Double
'	Includes As WStringList
'	IncludeLines As IntegerList
'	Namespaces As WStringOrStringList
'	Types As WStringOrStringList
'	Enums As WStringOrStringList
'	Procedures As WStringOrStringList
'	Args As WStringOrStringList
'	LineLabels As WStringOrStringList
'	Lines As List
'	InProcess As Boolean
'End Type

Common Shared As List Ptr pTools, pControlLibraries
Common Shared As WStringOrStringList Ptr pComps, pGlobalNamespaces, pGlobalTypes, pGlobalEnums, pGlobalDefines, pGlobalFunctions, pGlobalTypeProcedures, pGlobalArgs
Common Shared As WStringList Ptr pAddIns, pIncludeFiles, pLoadPaths, pIncludePaths, pLibraryPaths
'Common Shared As WStringList Ptr pLocalTypes, pLocalEnums, pLocalProcedures, pLocalFunctions, pLocalFunctionsOthers, pLocalArgs,
Common Shared As Dictionary Ptr pHelps, pMakeTools, pTerminals, pOtherEditors

Enum LoadParam
	OnlyFilePath
	OnlyFilePathOverwrite
	OnlyFilePathOverwriteWithContent
	OnlyIncludeFiles
	FilePathAndIncludeFiles
End Enum

Enum ProjectFolderTypes
	ShowWithFolders
	ShowWithoutFolders
	ShowAsFolder
End Enum

Declare Sub NewProject
Declare Sub OpenProject
Declare Sub OpenRecentProject
Declare Sub AddNew(ByRef Template As WString = "")
Declare Sub AddMRUList(ByRef FileFolderName As WString, ByRef MRUFilesFolders As WStringList)
Declare Sub AddMRUFile(ByRef FileName As WString)
Declare Sub AddMRUProject(ByRef FileName As WString) '
Declare Sub AddMRUFolder(ByRef FolderName As WString)
Declare Sub AddFromTemplates
Declare Sub AddFilesToProject
Declare Sub DeleteEditorFile
Declare Sub CancelFileDeletion
'' 13.71: one queued IntelliSense load. See the serial-loader block in Main.bas for why the loads
'' are queued and run one at a time rather than each on its own thread.
Type SerialLoadItem
	Proc As Sub(ByVal userdata As Any Ptr)
	Param As Any Ptr
	OwnedPath As WString Ptr
End Type
Declare Sub SpawnLoader(ByVal ProcPtr_ As Sub(ByVal userdata As Any Ptr), ByVal Param As Any Ptr, ByVal ParamIsPath As Boolean = False)
Declare Sub DrainLoaderQueue()
Declare Sub ClearLoaderQueue()
Declare Sub UpdateExplorerMenuState
Declare Sub SaveMRU
Declare Sub RestoreStatusText
Declare Sub OpenUrl(ByVal url As String)
Declare Function AddProject(ByRef FileName As WString = "", pFilesList As WStringList Ptr = 0, tn As TreeNode Ptr = 0, bNew As Boolean = False) As TreeNode Ptr
Declare Function SaveProject(ByRef tn As TreeNode Ptr, bWithQuestion As Boolean = False) As Boolean
Declare Function CloseProject(tn As TreeNode Ptr, WithoutMessage As Boolean = False) As Boolean
Declare Function DeleteProject() As Boolean
Declare Function RenameProject() As Boolean
Declare Sub SetMainNode(tn As TreeNode Ptr)
Declare Sub OpenProjectFolder
Declare Sub OpenFiles(ByRef FileName As WString)
Declare Sub OpenProgram()
Declare Sub PrintThis()
Declare Sub PrintPreview()
Declare Sub PageSetup()
Declare Sub ReloadHistoryCode
Declare Sub SetAsMain(IsTab As Boolean)
Declare Sub SetAutoColors
Declare Sub StartProgress()
Declare Sub StopProgress()
Declare Sub ThreadCounter(Id As Any Ptr)
Declare Function EqualPaths(ByRef a As WString, ByRef b As WString) As Boolean
Declare Sub ChangeEnabledDebug(bStart As Boolean, bBreak As Boolean, bEnd As Boolean)
Declare Sub ClearThreadsWindow() ' Defined in ilwaco.bas; forward-declared here since Main.bi pulls in Main.bas before ilwaco.bas defines it
Declare Sub ChangeLockControls(bLockControls As Boolean, ChangeObject As Integer = -1)
Declare Sub ChangeUseDebugger(bUseDebugger As Boolean, ChangeObject As Integer = -1)
Declare Sub UpdateMcpAgentStatusBar()
Declare Sub ReconcileAgentPipe()
Declare Sub ChangeNewLineType(NewLineType As NewLineTypes)
	Common Shared As Long CurrentTimer, CurrentTimerData
	Declare Sub TimerProc()
Declare Function WithoutPointers(ByRef e As String) As String
Declare Function WithoutQuotes(ByRef e As UString) As UString
Declare Sub ChangeFolderType(Value As ProjectFolderTypes)
Declare Function FileCopy_(ByRef Source As WString, ByRef Destination As WString) As Long
Declare Function FolderCopy(FromDir As UString, ToDir As UString) As Integer
Declare Sub Save
Declare Function SaveAllBeforeCompile() As Boolean
Declare Sub SaveWorkspace()
Declare Function LoadWorkspace() As Boolean
Declare Sub CompileProgram(Param As Any Ptr)
Declare Sub CompileWithDebugger(Param As Any Ptr)
Declare Sub CompileAndRun(Param As Any Ptr)
Declare Sub MakeExecute(Param As Any Ptr)
Declare Sub MakeClean(Param As Any Ptr)
Declare Sub SyntaxCheck(Param As Any Ptr)
Declare Sub NextBookmark(iTo As Integer = 1)
Declare Sub ClearAllBookmarks
Declare Sub SaveAll()
Declare Sub FormatProject(UnFormat As Any Ptr)
Declare Sub SetSaveDialogParameters(ByRef FileName As WString)
Declare Function IfNegative(Value As Integer, NonNegative As Integer) As Integer
Declare Function GetChangedCommas(ByRef Value As WString, FromSecond As Boolean = False) As String
Declare Function GetFileName(ByRef FileName As WString, WithExtension As Boolean = True) As UString
Declare Function GetExeFileName(ByRef FileName As WString, ByRef sLine As WString) As UString
Declare Function GetBakFileName(ByRef FileName As WString) As UString
Declare Function GetShortFileName(ByRef FileName As WString, ByRef FilePath As WString) As UString
Declare Function GetFolderName(ByRef FileName As WString, WithSlash As Boolean = True) As UString
Declare Function GetOSPath(ByRef Path As WString) As UString
Declare Function GetFullPathInSystem(ByRef Path As WString) As UString
Declare Function GetFullPath(ByRef Path As WString, ByRef FromFile As WString = "") As UString
Declare Function GetRelative(ByRef FileName As WString, ByRef FromFile As WString) As UString
Declare Function GetRelativePath(ByRef Path As WString, ByRef FromFile As WString = "") As UString
Declare Function GetXY(XorY As Integer) As Integer
Declare Function FolderExists(ByRef FolderName As WString) As Boolean
Declare Function Compile(Parameter As String = "", bAll As Boolean = False) As Integer
Declare Sub LoadFunctions(ByRef Path As WString, LoadParameter As LoadParam = FilePathAndIncludeFiles, ByRef Types As WStringOrStringList, ByRef Enums As WStringOrStringList, ByRef Functions As WStringOrStringList, ByRef Args As WStringOrStringList, ByRef TypeProcedures As WStringOrStringList, ec As Control Ptr = 0, CtlLibrary As Library Ptr = 0, CurFile As Any Ptr = 0, OldFile As Any Ptr = 0)
Declare Sub LoadFunctionsSub(Param As Any Ptr)
Declare Sub LoadOnlyFilePath(Param As Any Ptr)
Declare Sub LoadOnlyFilePathOverwrite(Param As Any Ptr)
Declare Sub LoadOnlyFilePathOverwriteWithContent(Param As Any Ptr)
Declare Sub LoadOnlyIncludeFiles(Param As Any Ptr)
Declare Sub LoadFromTabWindow(Param As Any Ptr)
Declare Sub LoadToolBox(ForLibrary As Library Ptr = 0)
Declare Sub CloseAllTabs(WithoutCurrent As Boolean = False)
Declare Sub UpdateAllTabWindows
Declare Sub RunHelp(Param As Any Ptr)

Common Shared As Integer tabLeftWidth, tabRightWidth, tabBottomHeight
Declare Sub SetLeftClosedStyle(Value As Boolean, WithClose As Boolean = True)
Declare Sub SetRightClosedStyle(Value As Boolean, WithClose As Boolean = True)
Declare Sub SetBottomClosedStyle(Value As Boolean, WithClose As Boolean = True)
Declare Sub pnlToolBox_Resize(ByRef Designer As My.Sys.Object, ByRef Sender As Control, NewWidth As Integer = -1, NewHeight As Integer = -1)

Dim Shared symbols(0 To 15) As UByte
Const plus  As UByte = 43
Const minus As UByte = 45
Const dot   As UByte = 46
Declare Function IsNumeric(ByRef subject As Const WString, base_ As Integer = 10) As Boolean
Declare Function utf16BeByte2wchars( ta() As UByte ) ByRef As WString

#ifndef __USE_MAKE__
	#include once "Main.bas"
#endif