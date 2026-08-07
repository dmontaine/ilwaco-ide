'###############################################################################
'#  StatusBar.bi                                                               #
'#  This file is part of MyFBFramework                                         #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                     #
'#  Based on:                                                                  #
'#   TStatusBar.bi                                                             #
'#   FreeBasic Windows GUI ToolKit                                             #
'#   Copyright (c) 2007-2008 Nastase Eodor                                     #
'#   Version 1.0.0                                                             #
'#  Updated and added cross-platform                                           #
'#  by Xusinboy Bekchanov(2018-2019)  Liu XiaLin                               #
'###############################################################################

#include once "StatusBar.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function StatusPanel.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "alignment": Return @FAlignment
			Case "bevel": Return @FBevel
			Case "caption": Return FCaption
			Case "icon": Return @Icon
			Case "index": Return @Index
			Case "name": Return FName
			Case "panelindex": FPanelIndex = PanelIndex: Return @FPanelIndex
			Case "parent": Return StatusBarControl
			Case "realwidth": FRealWidth = RealWidth: Return @FRealWidth
			Case "width": Return @FWidth
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function StatusPanel.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "alignment": This.Alignment = QInteger(Value)
			Case "bevel": This.Bevel = *Cast(BevelStyle Ptr, Value)
			Case "caption": This.Caption = QWString(Value)
			Case "icon": This.Icon = QWString(Value)
			Case "name": This.Name = QWString(Value)
			Case "panelindex": This.PanelIndex = QInteger(Value)
			Case "parent": This.Parent = Value
			Case "width": This.Width = QInteger(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Property StatusPanel.Caption ByRef As WString
		If FCaption > 0 Then Return *FCaption Else Return ""
	End Property
	
	Private Property StatusPanel.Caption(ByRef Value As WString)
		FCaption = _Reallocate(FCaption, (Len(Value) + 1) * SizeOf(WString))
		*FCaption = Value
		If This.StatusBarControl Then Cast(StatusBar Ptr, This.StatusBarControl)->UpdatePanels
	End Property
	
	Private Property StatusPanel.Name ByRef As WString
		If FName > 0 Then Return *FName Else Return ""
	End Property
	
	Private Property StatusPanel.Name(ByRef Value As WString)
		WLet(FName, Value)
	End Property
	
	Private Property StatusPanel.PanelIndex As Integer
		If StatusBarControl Then
			Return Cast(StatusBar Ptr, StatusBarControl)->IndexOf(@This)
		Else
			Return -1
		End If
	End Property
	
	Private Sub StatusBar.ChangePanelIndex(ByRef stPanel As StatusPanel Ptr, Index As Integer)
		Dim OldIndex As Integer = This.IndexOf(stPanel)
		If OldIndex > -1 AndAlso OldIndex <> Index AndAlso Index <= Count - 1 Then
			If Index < OldIndex Then
				For i As Integer = OldIndex - 1 To Index Step -1
					Panels[i + 1] = Panels[i]
				Next i
				Panels[Index] = stPanel
			Else
				For i As Integer = OldIndex + 1 To Index
					Panels[i - 1] = Panels[i]
				Next i
				Panels[Index] = stPanel
			End If
		End If
	End Sub
	
	Private Property StatusPanel.PanelIndex(Value As Integer)
		If StatusBarControl Then
			Cast(StatusBar Ptr, StatusBarControl)->ChangePanelIndex @This, Value
		End If
	End Property
	
	Private Property StatusPanel.Parent As Control Ptr
		Return StatusBarControl
	End Property
	
	Private Property StatusPanel.Parent(Value As Control Ptr)
		If StatusBarControl <> 0 AndAlso StatusBarControl <> Value Then
			Dim As Integer Index = Cast(StatusBar Ptr, StatusBarControl)->IndexOf(@This)
			If Index > -1 Then Cast(StatusBar Ptr, StatusBarControl)->Remove Index
		End If
		StatusBarControl = Value
		Cast(StatusBar Ptr, StatusBarControl)->Add @This
	End Property

	Private Property StatusPanel.Width As Integer
		Return FWidth
	End Property
	
	Private Property StatusPanel.Width(Value As Integer)
		FWidth = Value
		If This.StatusBarControl Then Cast(StatusBar Ptr, This.StatusBarControl)->UpdatePanels
	End Property
	
	Private Property StatusPanel.RealWidth As Integer
		Return FRealWidth
	End Property
		
	Private Property StatusPanel.Bevel As BevelStyle
		Return FBevel
	End Property
	
	Private Property StatusPanel.Bevel(Value As BevelStyle)
		FBevel = Value
		If This.StatusBarControl Then Cast(StatusBar Ptr, This.StatusBarControl)->UpdatePanels
	End Property
	
	Private Property StatusPanel.Alignment As Integer
		Return FAlignment
	End Property
	
	Private Property StatusPanel.Alignment(Value As Integer)
		FAlignment = Value
		If This.StatusBarControl Then Cast(StatusBar Ptr, This.StatusBarControl)->UpdatePanels
	End Property
	
	Private Operator StatusPanel.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Operator StatusPanel.Let(ByRef Value As WString)
		Caption = Value
	End Operator
	
	Private Sub StatusPanel.IconChanged(ByRef Designer As My.Sys.Object,  ByRef Sender As My.Sys.Drawing.Icon)
		With *Cast(StatusPanel Ptr, Sender.Graphic)
		End With
	End Sub

	Private Constructor StatusPanel
		WLet(FClassName, "StatusPanel")
		Caption     = ""
		FWidth      = 50
		FAlignment  = 0
		FBevel      = 0
		Icon.Graphic = @This
		Icon.Changed = @IconChanged
	End Constructor
	
	Private Destructor StatusPanel
		If FCaption Then _Deallocate(FCaption)
		If FName Then _Deallocate(FName)
	End Destructor
	
	#ifndef ReadProperty_Off
		Private Function StatusBar.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "count": Return @Count
			Case "simplepanel": Return @FSimplePanel
			Case "simpletext": Return FSimpleText
			Case "sizegrip": Return @FSizeGrip
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function StatusBar.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "backcolor": This.BackColor = QInteger(Value)
			Case "simplepanel": This.SimplePanel = QBoolean(Value)
			Case "simpletext": This.SimpleText = QWString(Value)
			Case "sizegrip": This.SizeGrip = QBoolean(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Function StatusBar.Add(ByRef wText As WString, ByVal iWidth As Integer = 50, ByVal iAlignment As Integer = 0) As StatusPanel Ptr
		Count += 1
		Panels = _Reallocate(Panels, SizeOf(StatusPanel Ptr) * Count)
		Panels[Count - 1]            = _New( StatusPanel)
		Panels[Count - 1]->FDynamic  = True
		Panels[Count - 1]->Index     = Count - 1
		Panels[Count - 1]->Width     = iWidth
		Panels[Count - 1]->Caption   = wText
		Panels[Count - 1]->Alignment = iAlignment
		Panels[Count - 1]->Bevel     = BevelStyle.pbLowered
		Panels[Count - 1]->StatusBarControl = @This
		UpdatePanels
		Return Panels[Count - 1]
	End Function
	
	Private Sub StatusBar.Add(stPanel As StatusPanel Ptr)
		Count += 1
		Panels = _Reallocate(Panels, SizeOf(StatusPanel Ptr) * Count)
		Panels[Count - 1] = stPanel
		UpdatePanels
	End Sub
	
	Private Sub StatusBar.Remove(Index As Integer)
		Dim As StatusPanel Ptr Ptr Temp
		Dim As Integer i, x = 0
		If Index >= 0 And Index <= Count - 1 Then
				gtk_statusbar_remove(GTK_STATUSBAR(widget), context_id, Panels[i]->message_id)
			Temp = _CAllocate((Count - 1) * SizeOf(StatusPanel Ptr))
			x = 0
			For i = 0 To Count -1
				If i <> Index Then
					x += 1
					Temp[x -1] = Panels[i]
				End If
			Next i
			Count -= 1
			Panels = _CAllocate(Count*SizeOf(StatusPanel Ptr))
			For i = 0 To Count -1
				Panels[i] = Temp[i]
			Next i
			_Deallocate( Temp)
		End If
		UpdatePanels
	End Sub
	
	Private Sub StatusBar.Clear
		For i As Integer = Count -1 To 0 Step -1
			Remove i
		Next i
		Count = 0
			gtk_statusbar_remove_all(GTK_STATUSBAR(widget), context_id)
	End Sub
	
	Private Function StatusBar.IndexOf(ByRef stPanel As StatusPanel Ptr) As Integer
		For i As Integer = 0 To Count - 1
			If Panels[i] = stPanel Then Return i
		Next
		Return -1
	End Function
	
	Private Sub StatusBar.UpdatePanels
		Dim As Long i, FWidth()
		Dim As WString Ptr s
		Dim As WString Ptr ss
		If Count > 0 Then
			ReDim FWidth(Count - 1)
			For i = 0 To Count - 1
				If i = 0 Then
					FWidth(i) = ScaleX(Panels[i]->Width)
				Else
					FWidth(i) = ScaleX(Panels[i]->Width) + FWidth(i - 1)
				End If
			Next i
			FWidth(Count - 1) = -1
			For i = 0 To Count - 1
				If Panels[i]->Alignment = 0 Then
					WLet(s, Panels[i]->Caption)
				ElseIf Panels[i]->Alignment = 1 Then
					WLet(s, Chr(9)+Panels[i]->Caption)
				ElseIf Panels[i]->Alignment = 2 Then
					WLet(s, Chr(9) & Chr(9) & Panels[i]->Caption)
				Else
					WLet(s, Panels[i]->Caption)
				End If
				WAdd(ss, IIf(i = 0, "", !"\t") & Panels[i]->Caption)
			Next i
		End If
			If *ss = "" Then
				gtk_statusbar_push(GTK_STATUSBAR(widget), context_id, !"\0")
			Else
				gtk_statusbar_push(GTK_STATUSBAR(widget), context_id, ToUtf8(*ss))
			End If
		Invalidate
		WDeAllocate(s)
		WDeAllocate(ss)
	End Sub
	
	Private Property StatusBar.Panel(Index As Integer) As StatusPanel Ptr
		If Index >= 0 And Index <= Count -1 Then
			Return *Panels[Index]
		End If
	End Property
	
	Private Property StatusBar.Panel(Index As Integer, Value As StatusPanel Ptr)
		If Index >= 0 And Index <= Count -1 Then
			Panels[Index] = Value
		End If
	End Property
	
	Private Property StatusBar.BackColor As Integer
		Return Base.BackColor
	End Property
	
	Private Property StatusBar.BackColor(Value As Integer)
		Base.BackColor = Value
	End Property
	
	Private Property StatusBar.SizeGrip As Boolean
		Return FSizeGrip
	End Property
	
	Private Property StatusBar.SizeGrip(Value As Boolean)
		If Value <> FSizeGrip Then
			FSizeGrip = Value
			RecreateWnd
		End If
	End Property
	
	Private Property StatusBar.SimplePanel As Boolean
		Return FSimplePanel
	End Property
	
	Private Property StatusBar.SimplePanel(Value As Boolean)
		If Value <> FSimplePanel Then
			FSimplePanel = Value
		End If
	End Property
	
	Private Property StatusBar.SimpleText ByRef As WString
		If FSimpleText > 0 Then Return *FSimpleText Else Return ""
	End Property
	
	Private Property StatusBar.SimpleText(ByRef Value As WString)
		If SimplePanel Then
			FSimpleText = _Reallocate(FSimpleText, (Len(Value) + 1) * SizeOf(WString))
			*FSimpleText = Value
			Text = *FSimpleText
		End If
	End Property
	
	
	Private Operator StatusBar.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
	Private Constructor StatusBar
		With This
				widget = gtk_statusbar_new
				'gtk_statusbar_set_has_resize_grip(gtk_statusbar(widget), true)
				.RegisterClass "StatusBar", @This
				WLet(FSimpleText, "StatusBar")
				context_id = gtk_statusbar_get_context_id(GTK_STATUSBAR(widget), *FSimpleText)
				gtk_widget_show_all(widget)
				'Var cont2 = gtk_statusbar_get_context_id(gtk_statusbar(widget), "statusbar 2")
				'gtk_statusbar_push(gtk_statusbar(widget), cont2, *FSimpleText)
				
			FSizeGrip = True
			WLet(FClassName, "StatusBar")
			WLet(FClassAncestor, "msctls_StatusBar32")
			'#ifdef __USE_GTK3__
			'	.Height       = 35
			'#else
			'	.Height       = 21
			'#endif
			.Height = ScaleY(Font.Size / 72 * 96 + 6)
			.Width        = 175
			' Dock to the bottom of the parent, which is what a status bar is.
			' Win32 gets this free -- msctls_statusbar32 positions itself -- but
			' gtk_statusbar_new is an ordinary widget, so without this it lands
			' at the top-left like any other control.
			.Align        = DockStyle.alBottom
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor StatusBar
		For i As Integer = Count - 1 To 0 Step -1
			If Panels[i]->FDynamic Then _Delete(Panels[i])
		Next
		_Deallocate(Panels) 'CAllocate_(0)
		If FSimpleText <> 0 Then _Deallocate( FSimpleText)
	End Destructor
End Namespace

#ifdef __EXPORT_PROCS__
	Sub StatusBarRemovePanel Alias "StatusBarRemovePanel" (sb As My.Sys.Forms.StatusBar Ptr, Index As Integer) Export
		sb->Remove Index
	End Sub

	Function StatusBarPanelByIndex Alias "StatusBarPanelByIndex" (sb As My.Sys.Forms.StatusBar Ptr, Index As Integer) As My.Sys.Forms.StatusPanel Ptr Export
		Return sb->Panel(Index)
	End Function
#endif
