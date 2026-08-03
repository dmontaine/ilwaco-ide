'################################################################################
'#  MonthCalendar.bi                                                            #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov (2018-2019)                                     #
'################################################################################

#include once "MonthCalendar.bi"

Namespace My.Sys.Forms
	#ifndef ReadProperty_Off
		Private Function MonthCalendar.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "selecteddate": FSelectedDate = SelectedDate: Return @FSelectedDate
			Case "weeknumbers": Return @FWeekNumbers
			Case "todaycircle": Return @FTodayCircle
			Case "todayselector": Return @FTodaySelector
			Case "trailingdates": Return @FTrailingDates
			Case "shortdaynames": Return @FShortDayNames
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function MonthCalendar.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "selecteddate": SelectedDate = QLong(Value)
				Case "weeknumbers": WeekNumbers = QBoolean(Value)
				Case "todaycircle": TodayCircle = QBoolean(Value)
				Case "todayselector": TodaySelector = QBoolean(Value)
				Case "trailingdates": TrailingDates = QBoolean(Value)
				Case "shortdaynames": ShortDayNames = QBoolean(Value)
				Case "tabindex": TabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	#endif
	
	Private Property MonthCalendar.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property MonthCalendar.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property MonthCalendar.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property MonthCalendar.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
	Private Property MonthCalendar.SelectedDate() As Long
		If This.FHandle Then
				Dim As guint y, m, d
				gtk_calendar_get_date(gtk_calendar(FHandle), @y, @m, @d)
				FSelectedDate = DateSerial(y, m + 1, d)
		End If
		Return FSelectedDate
	End Property
	
	Private Property MonthCalendar.SelectedDate(ByVal Value As Long)
		If This.FHandle Then
				gtk_calendar_select_month(gtk_calendar(FHandle), Month(FSelectedDate) - 1, Year(FSelectedDate))
				gtk_calendar_select_day(gtk_calendar(FHandle), Day(FSelectedDate))
				If FTodayCircle Then
					If Month(FSelectedDate) = Month(Now) AndAlso Year(FSelectedDate) = Year(Now) Then
						gtk_calendar_mark_day(gtk_calendar(FHandle), Day(Now))
					Else
						gtk_calendar_unmark_day(gtk_calendar(FHandle), Day(Now))
					End If
				End If
		End If
		FSelectedDate = Value
	End Property
	
	
	Private Property MonthCalendar.WeekNumbers() As Boolean
		If This.FHandle Then
				FStyle = gtk_calendar_get_display_options(gtk_calendar(FHandle))
				FWeekNumbers = StyleExists(GTK_CALENDAR_SHOW_WEEK_NUMBERS)
		End If
		Return FWeekNumbers
	End Property
	
	Private Property MonthCalendar.WeekNumbers(ByVal Value As Boolean)
		If This.FHandle Then
				FStyle = gtk_calendar_get_display_options(gtk_calendar(FHandle))
				ChangeStyle GTK_CALENDAR_SHOW_WEEK_NUMBERS, Value
				gtk_calendar_set_display_options(gtk_calendar(FHandle), FStyle)
		End If
		FWeekNumbers = Value
	End Property
	
	Private Property MonthCalendar.TodayCircle() As Boolean
		If This.FHandle Then
		End If
		Return FTodayCircle
	End Property
	
	Private Property MonthCalendar.TodayCircle(ByVal Value As Boolean)
		If This.FHandle Then
		End If
		FTodayCircle = Value
	End Property
	
	Private Property MonthCalendar.TodaySelector() As Boolean
		If This.FHandle Then
		End If
		Return FTodaySelector
	End Property
	
	Private Property MonthCalendar.TodaySelector(ByVal Value As Boolean)
		If This.FHandle Then
		End If
		FTodaySelector = Value
	End Property
	
	Private Property MonthCalendar.TrailingDates() As Boolean
		If This.FHandle Then
		End If
		Return FTrailingDates
	End Property
	
	Private Property MonthCalendar.TrailingDates(ByVal Value As Boolean)
		If This.FHandle Then
		End If
		FTrailingDates = Value
	End Property
	
	Private Property MonthCalendar.ShortDayNames() As Boolean
		If This.FHandle Then
				FStyle = gtk_calendar_get_display_options(GTK_CALENDAR(FHandle))
				FShortDayNames = StyleExists(GTK_CALENDAR_SHOW_DAY_NAMES)
		End If
		Return FShortDayNames
	End Property
	
	Private Property MonthCalendar.ShortDayNames(ByVal Value As Boolean)
		If This.FHandle Then
				FStyle = gtk_calendar_get_display_options(GTK_CALENDAR(FHandle))
				ChangeStyle GTK_CALENDAR_SHOW_DAY_NAMES, Value
				gtk_calendar_set_display_options(GTK_CALENDAR(FHandle), FStyle)
		End If
		FShortDayNames = Value
	End Property
	
	
	Private Sub MonthCalendar.ProcessMessage(ByRef Message As Message)
		Base.ProcessMessage(Message)
	End Sub
	
	Private Operator MonthCalendar.Cast As My.Sys.Forms.Control Ptr
		Return Cast(My.Sys.Forms.Control Ptr, @This)
	End Operator
	
		Private Sub MonthCalendar.Calendar_DaySelected(calendar As GtkCalendar Ptr, user_data As Any Ptr)
			Dim As MonthCalendar Ptr cal = user_data
			If cal->OnSelect Then cal->OnSelect(*cal->Designer, *cal)
		End Sub
	
	Private Constructor MonthCalendar
		With This
			WLet(FClassName, "MonthCalendar")
			FTabIndex          = -1
			FTabStop           = True
				widget = gtk_calendar_new ()
				g_signal_connect(widget, "day-selected", G_CALLBACK(@Calendar_DaySelected), @This)
				.RegisterClass "MonthCalendar", @This
			.Width        = 175
			.Height       = 21
			.Child        = @This
		End With
	End Constructor
	
	Private Destructor MonthCalendar
	End Destructor
End Namespace
