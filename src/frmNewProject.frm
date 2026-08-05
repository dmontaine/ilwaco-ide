'#Region "Form"
	#include once "frmNewProject.bi"

	Constructor frmNewProject
		With This
			.Name = "frmNewProject"
			.Text = ML("New Project")
			.Icon.LoadFromResourceID(1)
			.Designer = @This
			.BorderStyle = FormBorderStyle.Sizable
			.OnCreate = @Form_Create_
			.SetBounds 0, 0, 520, 190
			.StartPosition = FormStartPosition.CenterParent
		End With
		' pnlBottom
		With pnlBottom
			.Name = "pnlBottom"
			.Text = ""
			.Align = DockStyle.alBottom
			.AutoSize = True
			.TabIndex = 6
			.SetBounds 10, 130, 500, 34
			.Parent = @This
		End With
		' cmdOK
		With cmdOK
			.Name = "cmdOK"
			.Text = ML("OK")
			.Align = DockStyle.alRight
			.ExtraMargins.Right = 10
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.TabIndex = 7
			.SetBounds 400, 0, 90, 24
			.Default = True
			.Designer = @This
			.OnClick = @cmdOK_Click_
			.Parent = @pnlBottom
		End With
		' cmdCancel
		With cmdCancel
			.Name = "cmdCancel"
			.Text = ML("Cancel")
			.Align = DockStyle.alRight
			.ExtraMargins.Right = 5
			.ExtraMargins.Top = 5
			.ExtraMargins.Bottom = 5
			.TabIndex = 8
			.SetBounds 300, 0, 90, 24
			.Designer = @This
			.OnClick = @cmdCancel_Click_
			.Parent = @pnlBottom
		End With
		' pnlTemplate — row 0
		With pnlTemplate
			.Name = "pnlTemplate"
			.Text = ""
			.Align = DockStyle.alTop
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Top = 12
			.TabIndex = 0
			.SetBounds 0, 0, 500, 34
			.Parent = @This
		End With
		' lblTemplate
		With lblTemplate
			.Name = "lblTemplate"
			.Text = ML("Project type") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 1
			.SetBounds 0, 0, 110, 21
			.Parent = @pnlTemplate
		End With
		' cboTemplate — pick-only dropdown, populated in Form_Create
		With cboTemplate
			.Name = "cboTemplate"
			.Text = ""
			.Style = cbDropDownList
			.Align = DockStyle.alClient
			.ExtraMargins.Top = 2
			.ExtraMargins.Bottom = 2
			.TabIndex = 2
			.SetBounds 110, 0, 380, 26
			.Designer = @This
			.Parent = @pnlTemplate
		End With
		' pnlSaveLocation — row 1
		With pnlSaveLocation
			.Name = "pnlSaveLocation"
			.Text = ""
			.Align = DockStyle.alTop
			.ExtraMargins.Left = 10
			.ExtraMargins.Right = 10
			.ExtraMargins.Top = 8
			.TabIndex = 3
			.SetBounds 0, 34, 500, 34
			.Parent = @This
		End With
		' lblSaveLocation
		With lblSaveLocation
			.Name = "lblSaveLocation"
			.Text = ML("Project name") & ":"
			.Align = DockStyle.alLeft
			.TabIndex = 4
			.SetBounds 0, 0, 110, 21
			.Parent = @pnlSaveLocation
		End With
		' cmdSaveLocation
		With cmdSaveLocation
			.Name = "cmdSaveLocation"
			.Text = "..."
			.Align = DockStyle.alRight
			.TabIndex = 6
			.SetBounds 466, 0, 24, 24
			.Designer = @This
			.OnClick = @cmdSaveLocation_Click_
			.Parent = @pnlSaveLocation
		End With
		' txtSaveLocation
		With txtSaveLocation
			.Name = "txtSaveLocation"
			.Text = ""
			.Align = DockStyle.alClient
			.ExtraMargins.Right = 4
			.ExtraMargins.Top = 2
			.ExtraMargins.Bottom = 2
			.TabIndex = 5
			.SetBounds 110, 0, 352, 24
			.Parent = @pnlSaveLocation
		End With
	End Constructor

'#End Region

Private Sub frmNewProject.AddProjectTemplateItem(ByRef TemplateName As String)
	'' The dropdown holds the template names directly; TemplateNames stays in sync so
	'' cboTemplate.ItemIndex maps back to a name.
	cboTemplate.AddItem ML(TemplateName)
	TemplateNames.Add TemplateName
End Sub

Private Sub frmNewProject.cmdOK_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewProject Ptr, Sender.Designer)).cmdOK_Click(Sender)
End Sub
Private Sub frmNewProject.cmdOK_Click(ByRef Sender As Control)
	SelectedTemplate = ""
	SelectedFolder = ""
	If cboTemplate.ItemIndex < 0 Then
		MsgBox ML("Select template!")
		Me.BringToFront
		Exit Sub
	End If
	If Trim(txtSaveLocation.Text) = "" Then
		MsgBox ML("Enter a project name!")
		Me.BringToFront
		Exit Sub
	End If
	'' Ilwaco's template layout: Templates/Projects/<Name>.vfp is the manifest, and
	'' Templates/Projects/<Name>/ holds its files — the manifest sits BESIDE the folder, not inside
	'' it (Astoria nests it, hence the different copy flow). Some templates ship no folder at all.
	Dim As UString TemplateName = TemplateNames.Item(cboTemplate.ItemIndex)
	Dim As UString TemplatesDir = ExePath & Slash & "Templates" & Slash & "Projects" & Slash
	Dim As UString TemplateFolder = TemplatesDir & TemplateName
	Dim As UString TemplateVfp = TemplatesDir & TemplateName & ".vfp"
	SelectedFolder = GetFullPath(txtSaveLocation.Text)
	If FolderExists(SelectedFolder) Then
		MsgBox ML("Selected folder exists, change the project name!")
		Me.BringToFront
		Exit Sub
	End If
	If Not FolderExists(GetFolderName(SelectedFolder, False)) Then
		MsgBox ML("Parent folder not exists, change the parent folder!")
		Me.BringToFront
		Exit Sub
	End If
	If FolderExists(TemplateFolder) Then
		FolderCopy TemplateFolder, SelectedFolder
	Else
		MkDir SelectedFolder
	End If
	'' Copy the manifest straight to its final name — the project is named after its folder. No
	'' rename step, so nothing here can fail silently the way FB's Name does (see Main.bi).
	SelectedTemplate = SelectedFolder & Slash & GetFileName(SelectedFolder) & ".vfp"
	FileCopy TemplateVfp, SelectedTemplate
	If Not FileExists(SelectedTemplate) Then
		MsgBox ML("Could not create the project") & ":" & Chr(10) & Chr(10) & SelectedTemplate, _
			"Ilwaco IDE", mtError
		SelectedTemplate = ""
		Me.BringToFront
		Exit Sub
	End If
	'' The template manifest's paths are relative to Templates/Projects, so they carry the template
	'' folder as a prefix ("Console Application/Main.bas"). FolderCopy puts those files at the top
	'' of the new project folder, so the prefix has to go or the project points at nothing.
	Dim As String ManifestText, ManifestLine
	Dim As Integer fIn = FreeFile_
	Open SelectedTemplate For Input Encoding "utf-8" As #fIn
	Do Until EOF(fIn)
		Line Input #fIn, ManifestLine
		ManifestText &= Replace(ManifestLine, TemplateName & Slash, "") & Chr(10)
	Loop
	CloseFile_(fIn)
	Dim As Integer fOut = FreeFile_
	Open SelectedTemplate For Output Encoding "utf-8" As #fOut
	Print #fOut, ManifestText;
	CloseFile_(fOut)
	ModalResult = ModalResults.OK
	Me.CloseForm
End Sub

Private Sub frmNewProject.cmdCancel_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewProject Ptr, Sender.Designer)).cmdCancel_Click(Sender)
End Sub
Private Sub frmNewProject.cmdCancel_Click(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	Me.CloseForm
End Sub

Private Sub frmNewProject.cmdSaveLocation_Click_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewProject Ptr, Sender.Designer)).cmdSaveLocation_Click(Sender)
End Sub
Private Sub frmNewProject.cmdSaveLocation_Click(ByRef Sender As Control)
	Dim BrowseD As FolderBrowserDialog
	BrowseD.InitialDir = GetFullPath(GetFolderName(txtSaveLocation.Text))
	If BrowseD.Execute Then
		txtSaveLocation.Text = BrowseD.Directory & Slash & GetFileName(txtSaveLocation.Text)
	End If
End Sub

Private Sub frmNewProject.Form_Create_(ByRef Designer As My.Sys.Object, ByRef Sender As Control)
	(*Cast(frmNewProject Ptr, Sender.Designer)).Form_Create(Sender)
End Sub
Private Sub frmNewProject.Form_Create(ByRef Sender As Control)
	ModalResult = ModalResults.Cancel
	cboTemplate.Clear
	TemplateNames.Clear
	'' An explicit list, in preferred order — NOT everything under Templates/Projects. Ilwaco is a
	'' Linux/GTK IDE, so project types that cannot work here (a Win32 GUI app) must not be offered,
	'' and ones needing an external toolchain (Android's SDK/NDK) do not belong in the everyday
	'' New Project list. Astoria does the same with its own five (Windows Application first).
	Dim As String PreferredTemplates(5)
	PreferredTemplates(0) = "GUI Application"
	PreferredTemplates(1) = "Console Application"
	PreferredTemplates(2) = "GTK Application"
	PreferredTemplates(3) = "Dynamic Library"
	PreferredTemplates(4) = "Static Library"
	PreferredTemplates(5) = "Control Library"
	For i As Integer = 0 To UBound(PreferredTemplates)
		If FileExists(ExePath & Slash & "Templates" & Slash & "Projects" & Slash & PreferredTemplates(i) & ".vfp") Then
			AddProjectTemplateItem(PreferredTemplates(i))
		End If
	Next
	If cboTemplate.ItemCount > 0 Then cboTemplate.ItemIndex = 0
	'' Offer the first free ProjectN so OK is always safe to press.
	Var n = 0
	Dim As String NewName
	Do
		n = n + 1
		NewName = "Project" & Str(n)
	Loop While FolderExists(GetFullPath(*ProjectsPath & Slash & NewName))
	txtSaveLocation.Text = *ProjectsPath & Slash & NewName
End Sub
