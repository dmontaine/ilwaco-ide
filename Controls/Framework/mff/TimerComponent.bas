'################################################################################
'#  TimerComponent.bi                                                           #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                     #
'################################################################################
'
' Ilwaco IDE Modifications
' copyright 2026 Donald Montaine
'
' This program is free software; you can redistribute it and/or modify
' it under the terms of the GNU Lesser General Public License as published by
' the Free Software Foundation; either version 3, or (at your option)
' any later version.
'
' This program is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU Lesser General Public License for more details.
'
' You should have received a copy of the GNU Lesser General Public License
' along with this program; if not, write to the Free Software Foundation,
' Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

#include once "TimerComponent.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function TimerComponent.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "enabled": Return Cast(Any Ptr, @This.FEnabled)
			Case "interval": Return Cast(Any Ptr, @This.FInterval)
			Case "ontimer": Return Cast(Any Ptr, This.OnTimer)
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function TimerComponent.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "enabled": This.Enabled = QBoolean(Value)
			Case "interval": This.Interval = QInteger(Value)
			Case "ontimer": This.OnTimer = Value
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
		Private Function TimerComponent.TimerProc(ByVal user_data As gpointer) As gboolean
			With TimersList
				Dim As TimerComponent Ptr tmr = user_data
				If tmr <> 0 Then
					If tmr->OnTimer Then tmr->OnTimer(*tmr->Designer, *tmr)
				End If
				Return tmr->Enabled
			End With
		End Function
	
	Private Property TimerComponent.Enabled As Boolean
		Return FEnabled
	End Property
	
	Private Property TimerComponent.Enabled(Value As Boolean)
		FEnabled = Value
		If FInterval <> 0 AndAlso Not FDesignMode Then
				If FEnabled Then
					ID = g_timeout_add(Interval, Cast(GSourceFunc, @TimerProc), Cast(gpointer, @This))
					TimersList.Add ID, @This
				Else
					TimersList.Remove TimersList.IndexOf(ID)
				End If
		End If
	End Property
	
	Private Property TimerComponent.Interval As Integer
		Return FInterval
	End Property
	
	Private Property TimerComponent.Interval(Value As Integer)
		FInterval = Value
		If FEnabled AndAlso Not FDesignMode Then
			TimersList.Remove TimersList.IndexOf(ID)
			ID = 0
			If FInterval > 0 Then
					ID = g_timeout_add(Interval, Cast(GSourceFunc, @TimerProc), Cast(gpointer, @This))
				TimersList.Add ID, @This
			End If
		End If
	End Property
	
	Private Operator TimerComponent.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor TimerComponent
		Interval = 10
		WLet(FClassName, "TimerComponent")
		FEnabled = False
	End Constructor
	
	Private Destructor TimerComponent
		Enabled = False
	End Destructor
End Namespace
