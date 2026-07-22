'###############################################################################
'#  Dialogs.bi                                                                 #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov                                 #
'#  Based on:                                                                  #
'#   Dialogs.bi                                                                #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov (2018-2019)                                          #
'###############################################################################

#include once "Dialogs.bi"

Private Sub OpenFileOptions.Include(Value As Integer)
	Count += 1
	Options = _Reallocate(Options, Count*SizeOf(Integer))
	Options[Count-1] = Value
End Sub

Private Sub OpenFileOptions.Exclude(Value As Integer)
	Dim As Integer Idx
	For i As Integer = 0 To Count -1
		If Options[i] = Value Then Idx  = 1
	Next i
	If Idx < Count Then
		Count -= 1
		For i As Integer = Idx To Count-1
			Options[i] = Options[i + 1]
		Next i
	End If
	Options = _Reallocate(Options,SizeOf(Integer) * Count)
End Sub

Private Operator OpenFileOptions.Cast As Integer
	Dim As Integer O
	For i As Integer = 0 To Count -1
		O Or= Options[i]
	Next i
	Return O
End Operator

Private Destructor OpenFileOptions
	If Options Then _Deallocate(Options)
End Destructor

#ifndef ReadProperty_Off
	Private Function Dialog.ReadProperty(PropertyName As String) As Any Ptr
		Select Case LCase(PropertyName)
		Case Else: Return Base.ReadProperty(PropertyName)
		End Select
		Return 0
	End Function
#endif

#ifndef WriteProperty_Off
	Private Function Dialog.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		Select Case LCase(PropertyName)
		Case Else: Return Base.WriteProperty(PropertyName, Value)
		End Select
		Return True
	End Function
#endif

#ifndef ReadProperty_Off
	Private Function OpenFileDialog.ReadProperty(PropertyName As String) As Any Ptr
		Select Case LCase(PropertyName)
		Case "caption": Return FCaption
		Case "center": Return @Center
		Case "defaultext": Return FDefaultExt
		Case "filename": Return FFileName
		Case "filetitle": Return FFileTitle
		Case "filter": Return FFilter
		Case "filterindex": Return @FilterIndex
		Case "initialdir": Return FInitialDir
		Case "multiselect": Return @FMultiSelect
		Case Else: Return Base.ReadProperty(PropertyName)
		End Select
		Return 0
	End Function
#endif

#ifndef WriteProperty_Off
	Private Function OpenFileDialog.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		Select Case LCase(PropertyName)
		Case "caption": If Value <> 0 Then This.Caption = QWString(Value)
		Case "center": If Value <> 0 Then This.Center = QBoolean(Value)
		Case "defaultext": If Value <> 0 Then This.DefaultExt = QWString(Value)
		Case "filename": If Value <> 0 Then This.FileName = QWString(Value)
		Case "filetitle": If Value <> 0 Then This.FileTitle = QWString(Value)
		Case "filter": If Value <> 0 Then This.Filter = QWString(Value)
		Case "filterindex": If Value <> 0 Then This.FilterIndex = QInteger(Value)
		Case "initialdir": If Value <> 0 Then This.InitialDir = QWString(Value)
		Case "multiselect": If Value <> 0 Then This.MultiSelect = QBoolean(Value)
		Case Else: Return Base.WriteProperty(PropertyName, Value)
		End Select
		Return True
	End Function
#endif

Private Property OpenFileDialog.MultiSelect As Boolean
	Return FMultiSelect
End Property

Private Property OpenFileDialog.MultiSelect(Value As Boolean)
	FMultiSelect = Value
	If Value Then
		Options.Include ofAllowMultiSelect
	Else
		Options.Exclude ofAllowMultiSelect
	End If
End Property

Private Property OpenFileDialog.InitialDir ByRef As WString
	Static EmptyWString As WString * 1
	If FInitialDir > 0 Then Return *FInitialDir Else Return EmptyWString
End Property

Private Property OpenFileDialog.InitialDir(ByRef Value As WString)
	FInitialDir    = _Reallocate(FInitialDir, (Len(Value) + 1) * SizeOf(WString))
	*FInitialDir = Value
End Property

Private Property OpenFileDialog.Caption ByRef As WString
	Static EmptyWString As WString * 1
	If FCaption > 0 Then Return *FCaption Else Return EmptyWString
End Property

Private Property OpenFileDialog.Caption(ByRef Value As WString)
	FCaption    = _Reallocate(FCaption, (Len(Value) + 1) * SizeOf(WString))
	*FCaption = Value
End Property

Private Property OpenFileDialog.DefaultExt ByRef As WString
	Static EmptyWString As WString * 1
	If FDefaultExt > 0 Then Return *FDefaultExt Else Return EmptyWString
End Property

Private Property OpenFileDialog.DefaultExt(ByRef Value As WString)
	FDefaultExt    = _Reallocate(FDefaultExt, (Len(Value) + 1) * SizeOf(WString))
	*FDefaultExt = Value
End Property

Private Property OpenFileDialog.FileName ByRef As WString
	Static EmptyWString As WString * 1
	If FFileName > 0 Then Return *FFileName Else Return EmptyWString
End Property

Private Property OpenFileDialog.FileName(ByRef Value As WString)
	WLet(FFileName, Value)
End Property

Private Property OpenFileDialog.FileTitle ByRef As WString
	Static EmptyWString As WString * 1
	If FFileTitle > 0 Then Return *FFileTitle Else Return EmptyWString
End Property

Private Property OpenFileDialog.FileTitle(ByRef Value As WString)
	WLet(FFileTitle, Value)
End Property

Private Property OpenFileDialog.Filter ByRef As WString
	Static EmptyWString As WString * 1
	If FFilter > 0 Then Return *FFilter Else Return EmptyWString
End Property

Private Property OpenFileDialog.Filter(ByRef Value As WString)
	FFilter = _Reallocate(FFilter, (Len(Value) + 1) * SizeOf(WString))
	*FFilter = Value
End Property


Private Function OpenFileDialog.Execute As Boolean
	On Error Goto ErrorHandler
	Dim bResult As Boolean
	FileNames.Clear
		Dim As GtkWindow Ptr win
		Dim As GtkFileFilter Ptr filefilter()
		If pApp AndAlso pApp->MainForm Then
			win = GTK_WINDOW(pApp->MainForm->widget)
		End If
		widget =  gtk_file_chooser_dialog_new(ToUtf8(*FCaption), _
		win, _
		GTK_FILE_CHOOSER_ACTION_OPEN, _
		ToUtf8("Cancel"), GTK_RESPONSE_CANCEL, _
		ToUtf8("Open"), GTK_RESPONSE_ACCEPT, _
		NULL)
		Dim As UString res()
		If *FFilter <> "" Then
			Split *FFilter, "|", res()
			ReDim filefilter(UBound(res) + 1)
			Dim j As Integer
			For i As Integer = 1 To UBound(res) Step 2
				If res(i) = "" Then Continue For
				j += 1
				filefilter(j) = gtk_file_filter_new()
				gtk_file_filter_set_name(filefilter(j), ToUtf8(res(i - 1)))
				gtk_file_filter_add_pattern(filefilter(j), res(i))
				gtk_file_chooser_add_filter(GTK_FILE_CHOOSER (widget), filefilter(j))
			Next
			If FilterIndex <= j Then gtk_file_chooser_set_filter(GTK_FILE_CHOOSER (widget), filefilter(FilterIndex))
		End If
		If WGet(FFileName) <> "" Then
			gtk_file_chooser_set_current_name(GTK_FILE_CHOOSER (widget), ToUtf8(*FFileName))
		End If
		If WGet(FInitialDir) = "" Then WLet(FInitialDir, CurDir)
		gtk_file_chooser_set_current_folder(GTK_FILE_CHOOSER (widget), ToUtf8(*FInitialDir))
		'gtk_file_chooser_set_do_overwrite_confirmation (GTK_FILE_CHOOSER (widget), TRUE)
		Dim bTrue As gboolean = 1
		gtk_file_chooser_set_action(GTK_FILE_CHOOSER(widget), GTK_FILE_CHOOSER_ACTION_OPEN)
		If FMultiSelect Then gtk_file_chooser_set_select_multiple(GTK_FILE_CHOOSER (widget), bTrue)
		Dim As Integer result = gtk_dialog_run (GTK_DIALOG (widget))
		bResult = result = GTK_RESPONSE_ACCEPT
		If bResult Then
			FileName = WStr(*gtk_file_chooser_get_filename (GTK_FILE_CHOOSER (widget)))
			Dim As GSList Ptr l = gtk_file_chooser_get_filenames(GTK_FILE_CHOOSER (widget))
			While (l)
				FileNames.Add *Cast(ZString Ptr, l->data)
				g_free(l->data)
				l = l->next
			Wend
			g_slist_free(l)
		End If
			gtk_widget_destroy( GTK_WIDGET(widget) )
	Return bResult
	Exit Function
	ErrorHandler:
	MsgBox ErrDescription(Err) & " (" & Err & ") " & _
	"in line " & Erl() & " " & _
	"in function " & ZGet(Erfn()) & " " & _
	"in module " & ZGet(Ermn())
End Function

Private Constructor OpenFileDialog
		
	WLet(FCaption, "Open ...")
	WLet(FFilter, "")
	WLet(FFileName, "")
	FilterIndex       = 1
	Center            = True
	'Control.Child     = @This
	WLet(FClassName, "OpenFileDialog")
End Constructor

Private Destructor OpenFileDialog
	If FInitialDir Then _Deallocate(FInitialDir)
	If FCaption Then _Deallocate( FCaption)
	If FDefaultExt Then _Deallocate( FDefaultExt)
	If FFileName Then _Deallocate( FFileName)
	If FFileTitle Then _Deallocate( FFileTitle)
	If FFilter Then _Deallocate(FFilter)
End Destructor

#ifndef ReadProperty_Off
	Private Function SaveFileDialog.ReadProperty(PropertyName As String) As Any Ptr
		Select Case LCase(PropertyName)
		Case "caption": Return FCaption
		Case "center": Return @Center
		Case "defaultext": Return FDefaultExt
		Case "filename": Return FFileName
		Case "filter": Return FFilter
		Case "filterindex": Return @FilterIndex
		Case "initialdir": Return FInitialDir
		Case Else: Return Base.ReadProperty(PropertyName)
		End Select
		Return 0
	End Function
#endif

#ifndef WriteProperty_Off
	Private Function SaveFileDialog.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		Select Case LCase(PropertyName)
		Case "caption": If Value <> 0 Then This.Caption = QWString(Value)
		Case "center": If Value <> 0 Then This.Center = QBoolean(Value)
		Case "defaultext": If Value <> 0 Then This.DefaultExt = QWString(Value)
		Case "filename": If Value <> 0 Then This.FileName = QWString(Value)
		Case "filter": If Value <> 0 Then This.Filter = QWString(Value)
		Case "filterindex": If Value <> 0 Then This.FilterIndex = QInteger(Value)
		Case "initialdir": If Value <> 0 Then This.InitialDir = QWString(Value)
		Case Else: Return Base.WriteProperty(PropertyName, Value)
		End Select
		Return True
	End Function
#endif

Private Property SaveFileDialog.InitialDir ByRef As WString
	Static EmptyWString As WString * 1
	If FInitialDir > 0 Then Return *FInitialDir Else Return EmptyWString
End Property

Private Property SaveFileDialog.InitialDir(ByRef Value As WString)
	FInitialDir    = _Reallocate(FInitialDir, (Len(Value) + 1) * SizeOf(WString))
	*FInitialDir = Value
End Property

Private Property SaveFileDialog.Caption ByRef As WString
	Static EmptyWString As WString * 1
	If FCaption > 0 Then Return *FCaption Else Return EmptyWString
End Property

Private Property SaveFileDialog.Caption(ByRef Value As WString)
	FCaption    = _Reallocate(FCaption, (Len(Value) + 1) * SizeOf(WString))
	*FCaption = Value
End Property

Private Property SaveFileDialog.DefaultExt ByRef As WString
	Static EmptyWString As WString * 1
	If FDefaultExt > 0 Then Return *FDefaultExt Else Return EmptyWString
End Property

Private Property SaveFileDialog.DefaultExt(ByRef Value As WString)
	FDefaultExt    = _Reallocate(FDefaultExt, (Len(Value) + 1) * SizeOf(WString))
	*FDefaultExt = Value
End Property

Private Property SaveFileDialog.FileName ByRef As WString
	Static EmptyWString As WString * 1
	If FFileName > 0 Then Return *FFileName Else Return EmptyWString
End Property

Private Property SaveFileDialog.FileName(ByRef Value As WString)
	FFileName    = _Reallocate(FFileName, (Len(Value) + 1) * SizeOf(WString))
	*FFileName = Value
End Property

Private Property SaveFileDialog.Filter ByRef As WString
	Static EmptyWString As WString * 1
	If FFilter > 0 Then Return *FFilter Else Return EmptyWString
End Property

Private Property SaveFileDialog.Filter(ByRef Value As WString)
	FFilter    = _Reallocate(FFilter, (Len(Value) + 1) * SizeOf(WString))
	*FFilter = Value
End Property


Private Function SaveFileDialog.Execute As Boolean
	Dim bResult As Boolean
		Dim As GtkWindow Ptr win
		Dim As GtkFileFilter Ptr filefilter(), curfilefilter
		If pApp->MainForm Then
			win = GTK_WINDOW(pApp->MainForm->widget)
		End If
		widget =  gtk_file_chooser_dialog_new (ToUtf8(*FCaption), _
		win, _
		GTK_FILE_CHOOSER_ACTION_SAVE, _
		ToUtf8("Cancel"), GTK_RESPONSE_CANCEL, _
		ToUtf8("Save"), GTK_RESPONSE_ACCEPT, _
		NULL)
		Dim As UString res()
		If *FFilter <> "" Then
			Split *FFilter, "|", res()
			ReDim filefilter(UBound(res) + 1)
			Dim j As Integer
			For i As Integer = 1 To UBound(res) Step 2
				If res(i) = "" Then Continue For
				j += 1
				filefilter(j) = gtk_file_filter_new()
				gtk_file_filter_set_name(filefilter(j), ToUtf8(res(i - 1)))
				gtk_file_filter_add_pattern(filefilter(j), res(i))
				gtk_file_chooser_add_filter(GTK_FILE_CHOOSER (widget), filefilter(j))
			Next
			If FilterIndex <= j Then gtk_file_chooser_set_filter(GTK_FILE_CHOOSER (widget), filefilter(FilterIndex))
		End If
		If *FFileName <> "" Then
			gtk_file_chooser_set_current_name(GTK_FILE_CHOOSER (widget), ToUtf8(*FFileName))
		End If
		If WGet(FInitialDir) = "" Then WLet(FInitialDir, CurDir)
		gtk_file_chooser_set_current_folder(GTK_FILE_CHOOSER (widget), ToUtf8(*FInitialDir))
		'gtk_file_chooser_set_do_overwrite_confirmation (GTK_FILE_CHOOSER (widget), TRUE)
		'gtk_file_chooser_set_select_multiple(GTK_FILE_CHOOSER (widget), true)
		Dim As Integer result = gtk_dialog_run (GTK_DIALOG (widget))
		bResult = result = GTK_RESPONSE_ACCEPT
		If bResult Then
			Dim As WString Ptr cwsFile, cwsFileExt
			WLet(cwsFile, WStr(*gtk_file_chooser_get_filename (GTK_FILE_CHOOSER (widget))))
			curfilefilter = gtk_file_chooser_get_filter(GTK_FILE_CHOOSER (widget))
			For j As Integer = 0 To UBound(filefilter)
				If curfilefilter = filefilter(j) Then FilterIndex = j: Exit For
			Next
			Var Index = FilterIndex * 2 - 1
			If Index <= UBound(res) Then
				WLet(cwsFileExt, Replace(res(Index), "*", ""))
				If res(Index) = "*.*" Then
					FileName = *cwsFile
				ElseIf Not EndsWith(*cwsFile, *cwsFileExt) Then
					FileName = *cwsFile & *cwsFileExt
				Else
					FileName = *cwsFile
				End If
			Else
				FileName = *cwsFile
			End If
		End If
			gtk_widget_destroy( GTK_WIDGET(widget) )
	Return bResult
End Function

Private Property SaveFileDialog.Color As Integer
	Return Control.BackColor
End Property

Private Property SaveFileDialog.Color(Value As Integer)
	Control.BackColor = Value
End Property

Private Constructor SaveFileDialog
	WLet(FCaption, "Save As")
	WLet(FFilter, "")
	WLet(FFileName, "")
	FilterIndex   = 1
	WLet(FClassName, "SaveFileDialog")
	Center        = True
	'Control.Child = @This
End Constructor

Private Destructor SaveFileDialog
	If FInitialDir <> 0 Then _Deallocate( FInitialDir)
	If FCaption <> 0 Then _Deallocate( FCaption)
	If FDefaultExt <> 0 Then _Deallocate( FDefaultExt)
	If FFileName <> 0 Then _Deallocate( FFileName)
	If FFilter <> 0 Then _Deallocate( FFilter)
End Destructor

#ifndef ReadProperty_Off
	Private Function FontDialog.ReadProperty(PropertyName As String) As Any Ptr
		Select Case LCase(PropertyName)
		Case "font": Return @This.Font
		Case "maxfontsize": Return @MaxFontSize
		Case "minfontsize": Return @MinFontSize
		Case Else: Return Base.ReadProperty(PropertyName)
		End Select
		Return 0
	End Function
#endif

#ifndef WriteProperty_Off
	Private Function FontDialog.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		Select Case LCase(PropertyName)
		Case "font": If Value <> 0 Then This.Font = *Cast(My.Sys.Drawing.Font Ptr, Value)
		Case "maxfontsize": If Value <> 0 Then This.MaxFontSize = QInteger(Value)
		Case "minfontsize": If Value <> 0 Then This.MinFontSize = QInteger(Value)
		Case Else: Return Base.WriteProperty(PropertyName, Value)
		End Select
		Return True
	End Function
#endif

Private Function FontDialog.Execute As Boolean
	Static As Integer FWidth(2) = {400,700}
		Dim As Boolean bResult
			Dim As GtkWindow Ptr win
			If pApp->MainForm Then
				win = GTK_WINDOW(pApp->MainForm->widget)
			End If
			widget =  gtk_font_chooser_dialog_new (ToUtf8("Choose Font"), win)
			gtk_font_chooser_set_font(GTK_FONT_CHOOSER (widget), ToUtf8(Font.Name & " " & WStr(Font.Size)))
		Dim As Integer res = gtk_dialog_run (GTK_DIALOG (widget))
		bResult = res = GTK_RESPONSE_OK
		If bResult Then
				Dim As PangoFontDescription Ptr desc = gtk_font_chooser_get_font_desc (GTK_FONT_CHOOSER (widget))
				Font.Name        = WStr(*pango_font_description_get_family(desc))
				Font.Italic      = pango_font_description_get_style(desc) = PANGO_STYLE_ITALIC
				Font.Underline   = False
				Font.StrikeOut   = False
				Font.Color       = 0
				Font.Size        = gtk_font_chooser_get_font_size(GTK_FONT_CHOOSER (widget)) / PANGO_SCALE
				Font.Bold        = pango_font_description_get_weight(desc) <> PANGO_WEIGHT_THIN
		End If
			gtk_widget_destroy( GTK_WIDGET(widget) )
		Return bResult
End Function

Private Constructor FontDialog
	MaxFontSize = 0
	MinFontSize = 0
	WLet(FClassName, "FontDialog")
End Constructor

Private Destructor FontDialog
End Destructor

#ifndef ReadProperty_Off
	Private Function FolderBrowserDialog.ReadProperty(PropertyName As String) As Any Ptr
		Select Case LCase(PropertyName)
		Case "caption": Return FCaption
		Case "center": Return @Center
		Case "directory": Return FDirectory
		Case "title": Return FTitle
		Case "initialdir": Return FInitialDir
		Case Else: Return Base.ReadProperty(PropertyName)
		End Select
		Return 0
	End Function
#endif

#ifndef WriteProperty_Off
	Private Function FolderBrowserDialog.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		Select Case LCase(PropertyName)
		Case "caption": If Value <> 0 Then This.Caption = QWString(Value)
		Case "center": If Value <> 0 Then This.Center = QBoolean(Value)
		Case "directory": If Value <> 0 Then This.Directory = QWString(Value)
		Case "title": If Value <> 0 Then This.Title = QWString(Value)
		Case "initialdir": If Value <> 0 Then This.InitialDir = QWString(Value)
		Case Else: Return Base.WriteProperty(PropertyName, Value)
		End Select
		Return True
	End Function
#endif

Private Property FolderBrowserDialog.Caption ByRef As WString
	Static EmptyWString As WString * 1
	If FCaption > 0 Then Return *FCaption Else Return EmptyWString
End Property

Private Property FolderBrowserDialog.Caption(ByRef Value As WString)
	FCaption    = _Reallocate(FCaption, (Len(Value) + 1) * SizeOf(WString))
	*FCaption = Value
End Property

Private Property FolderBrowserDialog.Title ByRef As WString
	Static EmptyWString As WString * 1
	If FTitle > 0 Then Return *FTitle Else Return EmptyWString
End Property

Private Property FolderBrowserDialog.Title(ByRef Value As WString)
	FTitle    = _Reallocate(FTitle, (Len(Value) + 1) * SizeOf(WString))
	*FTitle = Value
End Property

Private Property FolderBrowserDialog.InitialDir ByRef As WString
	Static EmptyWString As WString * 1
	If FInitialDir > 0 Then Return *FInitialDir Else Return EmptyWString
End Property

Private Property FolderBrowserDialog.InitialDir(ByRef Value As WString)
	FInitialDir    = _Reallocate(FInitialDir, (Len(Value) + 1) * SizeOf(WString))
	*FInitialDir = Value
End Property

Private Property FolderBrowserDialog.Directory ByRef As WString
	Static EmptyWString As WString * 1
	If FDirectory > 0 Then Return *FDirectory Else Return EmptyWString
End Property

Private Property FolderBrowserDialog.Directory(ByRef Value As WString)
	FDirectory    = _Reallocate(FDirectory, (Len(Value) + 1) * SizeOf(WString))
	*FDirectory = Value
End Property


Private Function FolderBrowserDialog.Execute As Boolean
	Dim As Boolean bResult
		Dim As GtkWindow Ptr win
		If pApp->MainForm Then
			win = GTK_WINDOW(pApp->MainForm->widget)
		End If
		widget =  gtk_file_chooser_dialog_new (ToUtf8("Choose Folder"), _
		win, _
		GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER, _
		ToUtf8("Cancel"), GTK_RESPONSE_CANCEL, _
		ToUtf8("Open"), GTK_RESPONSE_ACCEPT, _
		NULL)
		'gtk_file_chooser_set_current_name(GTK_FILE_CHOOSER (widget), *FFileName)
		'gtk_file_chooser_set_do_overwrite_confirmation (GTK_FILE_CHOOSER (widget), TRUE)
		'gtk_file_chooser_set_select_multiple(GTK_FILE_CHOOSER (widget), true)
		Dim As Integer res = gtk_dialog_run (GTK_DIALOG (widget))
		bResult = res = GTK_RESPONSE_ACCEPT
		If bResult Then
			Directory = WStr(*gtk_file_chooser_get_filename (GTK_FILE_CHOOSER (widget)))
		End If
			gtk_widget_destroy( GTK_WIDGET(widget) )
		Return bResult
End Function

Private Constructor FolderBrowserDialog
	WLet(FClassName, "FolderBrowserDialog")
	'Control.Child = @This
	WLet(FTitle, "Please select a Folder:")
	WLet(FCaption, *FTitle)
End Constructor

Private Destructor FolderBrowserDialog
	If FCaption <> 0 Then _Deallocate( FCaption)
	If FTitle <> 0 Then _Deallocate( FTitle)
	If FInitialDir <> 0 Then _Deallocate( FInitialDir)
	If FDirectory <> 0 Then _Deallocate( FDirectory)
End Destructor

#ifndef ReadProperty_Off
	Private Function ColorDialog.ReadProperty(PropertyName As String) As Any Ptr
		Select Case LCase(PropertyName)
		Case "caption": Return _Caption
		Case "center": Return @Center
		Case "color": Return @Color
		Case "backcolor": Return @BackColor
		Case "parent": Return Parent
		Case "style": Return @Style
		Case Else: Return Base.ReadProperty(PropertyName)
		End Select
		Return 0
	End Function
#endif

#ifndef WriteProperty_Off
	Private Function ColorDialog.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
		Select Case LCase(PropertyName)
		Case "caption": If Value <> 0 Then This.Caption = QWString(Value)
		Case "center": If Value <> 0 Then This.Center = QInteger(Value)
		Case "color": If Value <> 0 Then This.Color = QInteger(Value)
		Case "backcolor": If Value <> 0 Then This.BackColor = QInteger(Value)
		Case "parent": This.Parent = Value
		Case "style": If Value <> 0 Then This.BackColor = QInteger(Value)
		Case Else: Return Base.WriteProperty(PropertyName, Value)
		End Select
		Return True
	End Function
#endif


Private Property ColorDialog.Caption ByRef As WString
	Return *_Caption
End Property

Private Property ColorDialog.Caption(ByRef Value As WString)
	WLet(_Caption, Value)
End Property

Private Function ColorDialog.Execute As Boolean
		Dim As Boolean bResult
		Dim As GtkWindow Ptr win
		If pApp->MainForm Then
			win = GTK_WINDOW(pApp->MainForm->widget)
		End If
			widget = gtk_color_chooser_dialog_new (ToUtf8(*_Caption), win)
		Dim As Integer res = gtk_dialog_run (GTK_DIALOG (widget))
		bResult = res = GTK_RESPONSE_OK
		If bResult Then
			Dim As UString RGBString
				Dim As GdkRGBA RGBAColor
				gtk_color_chooser_get_rgba(GTK_COLOR_CHOOSER (widget), @RGBAColor)
				RGBString = WStr(*gdk_rgba_to_string(@RGBAColor))
			Dim As UString res()
			Split(Mid(RGBString, 5, Len(RGBString) - 5), ",", res())
			If UBound(res) >= 2 Then This.Color = BGR(Val(res(0)), Val(res(1)), Val(res(2)))
		End If
			gtk_widget_destroy( GTK_WIDGET(widget) )
		Return bResult
End Function

Private Operator ColorDialog.Cast As Any Ptr
	Return @This
End Operator

Private Constructor ColorDialog
	WLet(_Caption, "Choose Color...")
	WLet(FClassName, "ColorDialog")
End Constructor

Private Destructor ColorDialog
	_Deallocate(_Caption)
End Destructor
