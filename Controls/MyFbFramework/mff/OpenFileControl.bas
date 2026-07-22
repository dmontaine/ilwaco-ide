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

#include once "OpenFileControl.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function OpenFileControl.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "defaultext": Return FDefaultExt
			Case "filename": WLet(FFileName, FileName): Return FFileName
			Case "filetitle": WLet(FFileTitle, FileTitle): Return FFileTitle
			Case "filter": Return FFilter
			Case "initialdir": WLet(FInitialDir, InitialDir): Return FInitialDir
			Case "multiselect": Return @FMultiSelect
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function OpenFileControl.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "defaultext": DefaultExt = QWString(Value)
			Case "filename": FileName = QWString(Value)
			Case "filetitle": FileTitle = QWString(Value)
			Case "filter": Filter = QWString(Value)
			Case "initialdir": InitialDir = QWString(Value)
			Case "multiselect": MultiSelect = QBoolean(Value)
			Case "tabindex": TabIndex = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property OpenFileControl.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property OpenFileControl.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property OpenFileControl.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property OpenFileControl.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property OpenFileControl.MultiSelect As Boolean
		Return FMultiSelect
	End Property
	
	Private Property OpenFileControl.MultiSelect(Value As Boolean)
		FMultiSelect = Value
		If Value Then
			Options.Include ofAllowMultiSelect
		Else
			Options.Exclude ofAllowMultiSelect
		End If
		#ifdef __USE_GTK__
			gtk_file_chooser_set_select_multiple(GTK_FILE_CHOOSER (widget), FMultiSelect)
		#endif
	End Property
	
	Private Property OpenFileControl.InitialDir ByRef As WString
		If FHandle Then
			#ifdef __USE_GTK__
				WLet(FInitialDir, WStr(*gtk_file_chooser_get_current_folder(GTK_FILE_CHOOSER (widget))))
			#else
				Dim As Integer iSize = 1024
				Dim As WString * 1024 Path
				If SendMessage(FHandle, CDM_GETFOLDERPATH, iSize, Cast(WPARAM, @Path)) > 0 Then
					WLet(FInitialDir, Path)
				End If
			#endif
		End If
		If FInitialDir > 0 Then Return *FInitialDir Else Return ""
	End Property
	
	Private Property OpenFileControl.InitialDir(ByRef Value As WString)
		FInitialDir    = _Reallocate(FInitialDir, (Len(Value) + 1) * SizeOf(WString))
		*FInitialDir = Value
		#ifdef __USE_GTK__
			If WGet(FInitialDir) = "" Then WLet(FInitialDir, CurDir)
			gtk_file_chooser_set_current_folder(GTK_FILE_CHOOSER (widget), ToUtf8(*FInitialDir))
		#endif
	End Property
	
	Private Property OpenFileControl.DefaultExt ByRef As WString
		If FDefaultExt > 0 Then Return *FDefaultExt Else Return ""
	End Property
	
	Private Property OpenFileControl.DefaultExt(ByRef Value As WString)
		FDefaultExt    = _Reallocate(FDefaultExt, (Len(Value) + 1) * SizeOf(WString))
		*FDefaultExt = Value
	End Property
	
	Private Property OpenFileControl.FileName ByRef As WString
		If FHandle Then
			#ifdef __USE_GTK__
				WLet(FFileName, WStr(*gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(widget))))
				If InStr(*FFileName, ".") = 0 Then
					If *FDefaultExt <> "" Then WAdd FFileName, "." & *FDefaultExt
				End If
			#else
				Dim As Integer iSize = 1024
				Dim As WString * 1024 Path
				If SendMessage(FHandle, CDM_GETFILEPATH, iSize, Cast(WPARAM, @Path)) > 0 Then
					WLet(FFileName, Path)
				End If
			#endif
		End If
		If FFileName > 0 Then Return *FFileName Else Return ""
	End Property
	
	Private Property OpenFileControl.FileName(ByRef Value As WString)
		WLet(FFileName, Value)
		#ifdef __USE_GTK__
			If WGet(FFileName) = "" Then
				gtk_file_chooser_set_current_name(GTK_FILE_CHOOSER (widget), !"\0")
			Else
				gtk_file_chooser_set_current_name(GTK_FILE_CHOOSER (widget), ToUtf8(*FFileName))
			End If
		#endif
	End Property
	
	Private Property OpenFileControl.FileTitle ByRef As WString
		If FHandle Then
			FileName
			#ifdef __USE_GTK__
				Dim As Integer Pos1 = InStrRev(*FFileName, "/")
				If Pos1 > 0 Then
					WLet(FFileTitle, Mid(*FFileName, Pos1 + 1))
				Else
					WLet(FFileTitle, *FFileName)
				End If
			#else
				Dim As Integer iSize = 1024
				Dim As WString * 1024 Path
				If SendMessage(FHandle, CDM_GETSPEC, iSize, Cast(WPARAM, @Path)) > 0 Then
					WLet(FFileTitle, Path)
				End If
			#endif
		End If
		If FFileTitle > 0 Then Return *FFileTitle Else Return ""
	End Property
	
	Private Property OpenFileControl.FileTitle(ByRef Value As WString)
		WLet(FFileTitle, Value)
		FileName = InitialDir & "/" & *FFileTitle
	End Property
	
	Private Property OpenFileControl.Filter ByRef As WString
		If FFilter > 0 Then Return *FFilter Else Return ""
	End Property
	
	Private Property OpenFileControl.Filter(ByRef Value As WString)
		FFilter    = _Reallocate(FFilter, (Len(Value) + 1) * SizeOf(WString))
		*FFilter = Value
		#ifdef __USE_GTK__
			Dim As UString res()
			If *FFilter <> "" Then
				Split *FFilter, "|", res()
				ReDim filefilter(UBound(res) + 1)
				FFilterCount = 0
				For i As Integer = 1 To UBound(res) Step 2
					If res(i) = "" Then Continue For
					FFilterCount += 1
					filefilter(FFilterCount) = gtk_file_filter_new()
					gtk_file_filter_set_name(filefilter(FFilterCount), ToUtf8(res(i - 1)))
					gtk_file_filter_add_pattern(filefilter(FFilterCount), res(i))
					gtk_file_chooser_add_filter(GTK_FILE_CHOOSER (widget), filefilter(FFilterCount))
				Next
				If FFilterIndex <= FFilterCount Then gtk_file_chooser_set_filter(GTK_FILE_CHOOSER (widget), filefilter(FFilterIndex))
			End If
		#endif
	End Property
	
	Private Property OpenFileControl.FilterIndex As Integer
		#ifdef __USE_GTK__
			Dim As GtkFileFilter Ptr choosedfilefilter = gtk_file_chooser_get_filter(GTK_FILE_CHOOSER(widget))
			For i As Integer = 0 To UBound(filefilter)
				If choosedfilefilter = filefilter(i) Then
					FFilterIndex = i
					Exit For
				End If
			Next i
		#endif
		Return FFilterIndex
	End Property
	
	Private Property OpenFileControl.FilterIndex(Value As Integer)
		FFilterIndex    = Value
		#ifdef __USE_GTK__
			If FFilterIndex <= FFilterCount Then gtk_file_chooser_set_filter(GTK_FILE_CHOOSER (widget), filefilter(FFilterIndex))
		#endif
	End Property
	
	
	Private Sub OpenFileControl.CreateWnd(Param As Any Ptr)
	End Sub
	
	Private Sub OpenFileControl.CreateWnd
	End Sub
	
	#ifdef __USE_GTK__
		Private Sub OpenFileControl.FileChooser_CurrentFolderChanged(chooser As GtkFileChooser Ptr, user_data As Any Ptr)
			Dim As OpenFileControl Ptr ofc = user_data
			If ofc->OnFolderChange Then ofc->OnFolderChange(*ofc->Designer, *ofc)
		End Sub
		
		Private Sub OpenFileControl.FileChooser_FileActivated(chooser As GtkFileChooser Ptr, user_data As Any Ptr)
			Dim As OpenFileControl Ptr ofc = user_data
			If ofc->OnFileActivate Then ofc->OnFileActivate(*ofc->Designer, *ofc)
		End Sub
		
		Private Sub OpenFileControl.FileChooser_SelectionChanged(chooser As GtkFileChooser Ptr, user_data As Any Ptr)
			Dim As OpenFileControl Ptr ofc = user_data
			If ofc->OnSelectionChange Then ofc->OnSelectionChange(*ofc->Designer, *ofc)
		End Sub
	#endif
	
	Private Constructor OpenFileControl
		#ifdef __USE_GTK__
			widget =  gtk_file_chooser_widget_new (GTK_FILE_CHOOSER_ACTION_OPEN)
			g_signal_connect(widget, "current-folder-changed", G_CALLBACK(@FileChooser_CurrentFolderChanged), @This)
			g_signal_connect(widget, "file-activated", G_CALLBACK(@FileChooser_FileActivated), @This)
			g_signal_connect(widget, "selection-changed", G_CALLBACK(@FileChooser_SelectionChanged), @This)
		#else
			Options.Include OFN_PATHMUSTEXIST
			Options.Include OFN_FILEMUSTEXIST
			Options.Include OFN_HIDEREADONLY
			Options.Include OFN_ENABLESIZING
			Options.Include OFN_EXPLORER
			Options.Include OFN_ENABLEHOOK
			'OFN_NONETWORKBUTTON
			'OFN_LONGNAMES
			'OFN_NODEREFERENCELINKS
			'OFN_OVERWRITEPROMPT
			'OFN_CREATEPROMPT
			'OFN_DONTADDTORECENT
		#endif
		Child = @This
		FTabIndex          = -1
		FTabStop           = True
		WLet(FClassName, "OpenFileControl")
		WLet(FFilter, "")
		FilterIndex       = 1
		'Control.Child     = @This
	End Constructor
	
	Private Destructor OpenFileControl
		If FInitialDir Then _Deallocate(FInitialDir)
		If FDefaultExt Then _Deallocate(FDefaultExt)
		If FFileName Then _Deallocate(FFileName)
		If FFileTitle Then _Deallocate(FFileTitle)
		If FFilter Then _Deallocate(FFilter)
			g_signal_handlers_disconnect_by_func(widget, G_CALLBACK(@FileChooser_CurrentFolderChanged), @This)
			g_signal_handlers_disconnect_by_func(widget, G_CALLBACK(@FileChooser_FileActivated), @This)
			g_signal_handlers_disconnect_by_func(widget, G_CALLBACK(@FileChooser_SelectionChanged), @This)
			widget = 0
	End Destructor
End Namespace
