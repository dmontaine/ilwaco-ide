'################################################################################
'#  Brush.bi                                                                    #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Nastase Eodor, Xusinboy Bekchanov, Liu XiaLin                      #
'#  Based on:                                                                   #
'#   TBrush.bi                                                                  #
'#   FreeBasic Windows GUI ToolKit                                              #
'#   Copyright (c) 2007-2008 Nastase Eodor                                      #
'#   Version 1.0.0                                                              #
'#  Modified by Xusinboy Bekchanov (2018-2019), Liu XiaLin (2020)               #
'################################################################################

#include once "Brush.bi"


Namespace My.Sys.Drawing
	#ifndef ReadProperty_Off
		Private Function Brush.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "color": Return @FColor
			Case "style": Return @FStyle
			Case "hatchstyle": Return @FHatchStyle
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Brush.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "color": This.Color = QInteger(Value)
			Case "style": This.Style = *Cast(BrushStyles Ptr, Value)
			Case "hatchstyle": This.HatchStyle = *Cast(HatchStyles Ptr, Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	#ifndef Brush_Color_Get_Off
		Private Property Brush.Color As Integer
			Return FColor
		End Property
	#endif
	
	Private Property Brush.Color(Value As Integer)
		FColor = Value
		Create
	End Property
	
	Private Property Brush.Style As BrushStyles
		Return FStyle
	End Property
	
	Private Property Brush.Style(Value As BrushStyles)
		FStyle = Value
		Create
	End Property
	
	Private Property Brush.HatchStyle As HatchStyles
		Return FHatchStyle
	End Property
	
	Private Property Brush.HatchStyle(Value As HatchStyles)
		FHatchStyle = Value
		Create
	End Property
	
	Private Sub Brush.Create
	End Sub
	
	
	Private Operator Brush.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor Brush
		FColor = &HFFFFFF
		FStyle = bsSolid
		'Create
		WLet(FClassName, "Brush")
	End Constructor
	
	Private Destructor Brush
	End Destructor
End Namespace
