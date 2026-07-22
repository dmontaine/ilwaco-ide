'################################################################################
'#  Printer.bas                                                                 #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Aloberoger, Xusinboy Bekchanov                                     #
'#  Based on:                                                                   #
'#   TPrinter.bas                                                               #
'#   GUITK-S Windows GUI FB Wrapper Library                                     #
'#   Copyright (c) Aloberoger                                                   #
'################################################################################

#include once "Printer.bi"
#include once "WStringList.bi"

Namespace My.Sys.ComponentModel
	#ifndef ReadProperty_Off
		Private Function Printer.ReadProperty(PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "Name": Return @m_Name
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	#endif
	
	#ifndef WriteProperty_Off
		Private Function Printer.WriteProperty(PropertyName As String, Value As Any Ptr) As Boolean
			Select Case LCase(PropertyName)
			Case "Name": Name = QString(Value)
			Case Else: Return Base.WriteProperty(PropertyName, Value)
			End Select
			Return True
		End Function
	#endif
	
	Private Function PaperSizeCollection.Add(Index As Integer = -1) As PaperSize Ptr
		Dim As PaperSize Ptr NewPaperSize = _New(PaperSize)
		If Index > -1 Then
			FItems.Insert Index, NewPaperSize
		Else
			FItems.Add NewPaperSize
		End If
		Return NewPaperSize
	End Function
	
	Private Sub PaperSizeCollection.Clear
		For i As Integer = Count - 1 To 0 Step -1
			_Delete(Cast(PaperSize Ptr, FItems.Items[i]))
		Next i
		FItems.Clear
	End Sub
	
	Private Property PaperSizeCollection.Count As Integer
		Return FItems.Count
	End Property
	
	Private Function PaperSizeCollection.Contains(PaperSizeItem As PaperSize Ptr) As Boolean
		Return IndexOf(PaperSizeItem) <> -1
	End Function
	
	Private Function PaperSizeCollection.IndexOf(PaperSizeItem As PaperSize Ptr) As Integer
		Return FItems.IndexOf(PaperSizeItem)
	End Function
	
	Private Function PaperSizeCollection.Insert(Index As Integer, PageItem As PaperSize Ptr) As PaperSize Ptr
		FItems.Insert(Index, PageItem)
		Return PageItem
	End Function
	
	Private Property PaperSizeCollection.Item(Index As Integer) As PaperSize Ptr
		Return Cast(PaperSize Ptr, FItems.Item(Index))
	End Property
	
	Private Property PaperSizeCollection.Item(Index As Integer, Value As PaperSize Ptr)
		FItems.Item(Index) = Value
	End Property
	
	Private Sub PaperSizeCollection.Remove(Index As Integer)
		_Delete(Item(Index))
		FItems.Remove Index
	End Sub
	
	Private Constructor PaperSizeCollection
		This.Clear
	End Constructor
	
	Private Destructor PaperSizeCollection
		This.Clear
	End Destructor
	
	Private Function  Printer.Parse(source As String, index As Integer, delimiter As String = ",") As String
		Dim As Long i,s,c,l
		s=1
		l=Len(delimiter)
		Do
			If c=index-1 Then
				Function=Mid(source,s,InStr(s,source,delimiter)-s)
				Exit Function
			End If
			i=InStr(s,source,delimiter)
			If i>0 Then
				c+=1
				s=i+l
			End If
		Loop Until i=0
	End Function
	
	
	Private Function Printer.Parse (source As String, delimiter As String = "|", index As Integer) As String
		Dim As Long i,s,c,l
		s=1
		l=Len(delimiter)
		Do
			If c=index-1 Then
				Function=Mid(source,s,InStr(s,source,delimiter)-s)
				Exit Function
			End If
			i=InStr(s,source,delimiter)
			If i>0 Then
				c+=1
				s=i+l
			End If
		Loop Until i=0
	End Function
	
	Private Function Printer.StrReverse (S As String) As String
		Dim As Integer j=Len(S)
		Dim rstr As String=Space(j)
		While (j<>0)
			j=j-1
			rstr[j] = S[Len(S)-j-1]
		Wend
		Return rstr
	End Function
	
	Private Sub Printer.reportError(  ByVal n As Long)
		Dim s As String
		If n = 1 Then
			s = "Document printing error"
		ElseIf n = 2 Then
			s = "Page printing error"
		Else
			s = "Unspecified printer error"
		End If
	End Sub
	
	' ========================================================================================
	' Sets the printer orientation.
	' DMORIENT_PORTRAIT = Portrait
	' DMORIENT_LANDSCAPE = Landscape
	' ========================================================================================
	Private Function Printer.SetPrinterOrientation (ByRef PrinterName As WString, ByVal nOrientation As Long) As Long
		Function  = True
		
	End Function
	' ========================================================================================
	' Sets the printer orientation.
	' DMORIENT_PORTRAIT = Portrait
	' DMORIENT_LANDSCAPE = Landscape
	' ========================================================================================
	Private Function Printer.SetPrinterOrientation2 (ByRef PrinterName As WString, ByVal nOrientation As Long) As Long
		Return True
	End Function
	
	Private Function Printer.GetPrinterNeededSize(ByRef PrinterName As WString) As Long
			Return 0
	End Function
	
	' ========================================================================================
	' Returns the printer orientation.
	' The return value can be one of the following:
	' - DMORIENT_PORTRAIT = Portrait
	' - DMORIENT_LANDSCAPE = Landscape
	' ========================================================================================
	Private Function Printer.GetPrinterOrientation (ByRef PrinterName As WString) As Long
			Function = 0
	End Function
	
	
	Private Property Printer.Name(vData As String)
		m_Name= vData
		GetPrinterPaperSizes(m_Name)
	End Property
	
	Private Property Printer.Name As String
		Return m_Name
	End Property
	
	
	Private Property Printer.PortName(vData As String)
	End Property
	
	Private Property Printer.PortName As String
		m_PortName=GetPrinterPort (printerName)
		Return m_PortName
	End Property
	
	
	Private Property Printer.Page(vData As Integer)
		m_Page=vData
	End Property
	
	Private Property Printer.Page As Integer
		Return m_Page
	End Property
	
	
	Private Property Printer.PageSize(vData As Integer)
		m_PageSize = vData
		SetPrinterPaperSize printerName, vData
	End Property
	
	Private Property Printer.PageSize As Integer
		Return m_PageSize
	End Property
	
	Private Property Printer.Copies(vData As Integer)
		m_Copies=vData
		SetPrinterCopies ( printerName ,vData)
	End Property
	
	Private Property Printer.Copies As Integer
		Return m_Copies
	End Property
	
	Private Property Printer.Quality(vData As PrinterQuality)
		m_Quality=vData
		SetPrinterQuality (printerName, vData)
	End Property
	
	Private Property Printer.Quality As PrinterQuality
		m_Quality=GetPrinterQualityMode (printerName)
		Return m_Quality
	End Property
	
	Private Property Printer.FromPage(vData As Integer)
		m_FromPage=vData
	End Property
	
	Private Property Printer.FromPage As Integer
		Return m_FromPage
	End Property
	
	
	Private Property Printer.ToPage(vData As Integer)
		m_ToPage=vData
	End Property
	
	Private Property Printer.ToPage As Integer
		Return m_ToPage
	End Property
	
	
	
	
	Private Property Printer.Scale () As Long
		Return GetPrinterScale ( printerName )
	End Property
	
	Private Property Printer.ScaleFactorX () As Long
		Return GetPrinterScalingFactorX ( printerName )
	End Property
	
	Private Property Printer.ScaleFactorY () As Long
		Return GetPrinterScalingFactorY ( printerName)
	End Property
	
	Private Property Printer.ColorMode (ByVal nMode As Long)
		SetPrinterColorMode (printerName ,nMode)
		m_ColorMode=nMode
	End Property
	
	Private Property Printer.ColorMode () As Long
		Return  m_ColorMode
	End Property
	
	Private Property Printer.DriveVersion () As Long
		Return GetPrinterDriverVersion ( printerName )
	End Property
	
	Private Property  Printer.PrintableWidth() As Long
		Dim As Long nResult, pixHorzRes, mmHorzSize
		Return nResult
	End Property
	
	
	Private Property  Printer.PrintableHeight() As Long
		Dim As Long nResult, pixVertRes, mmVertSize
		Return nResult
	End Property
	
	Private Property  Printer.MaxCopies () As Long
		Return GetPrinterMaxCopies (printerName)
	End Property
	
	Private Property  Printer.MaxPaperHeight () As Long
		Return GetPrinterMaxPaperHeight (printerName )
	End Property
	
	Private Property  Printer.MaxPaperWidth () As Long
		Return GetPrinterMaxPaperWidth (printerName )
	End Property
	
	
	Private Property Printer.PageWidth As  Integer
			Return 0
	End Property
	
	Private Property Printer.PageLength() As Integer
			Return 0
	End Property
	
	Private Property Printer.MarginLeft As  Integer
		Return leftMargin
	End Property
	
	Private Property Printer.MarginLeft(value As  Integer)
		leftMargin =value
	End Property
	
	Private Property Printer.MarginTop As  Integer
		Return topMargin
	End Property
	
	Private Property Printer.MarginTop(value As  Integer)
		topMargin =value
	End Property
	
	
	Private Property Printer.MarginRight As  Integer
		Return rightMargin
	End Property
	
	Private Property Printer.MarginRight(value As  Integer)
		rightMargin =value
	End Property
	
	
	Private Property Printer.Marginbottom As  Integer
		Return bottomMargin
	End Property
	
	Private Property Printer.Marginbottom(value As  Integer)
		bottomMargin =value
	End Property
	
	
	Private Function Printer.DefaultPrinter() As String    'determine default printer and device context handle
		Return printerName
	End Function
	
	Private Function Printer.ChoosePrinter() As String  'choose printer and determine device context handle
		Dim n As Long
		Return printerName
		
	End Function
	
	/'
	FUNCTION printer.getTextWidth(txt AS STRING) AS Integer
	'get the text width in inches
	Dim cSize AS SIZEL
	IF m_hdc  = 0 THEN printerName=This.defaultprinter
	GetTextExtentPoint32 m_hdc , BYVAL STRPTR(txt), LEN(txt), @cSize
	Function = cSize.cx
	END FUNCTION
	
	Function printer.truncate(s AS STRING, BYVAL wi AS Integer) AS STRING
	'truncate the text to a specified width, in inches
	'if wi > 0, truncate the back end, else truncate the front end
	Dim nFit AS LONG, cSize AS SIZEL, ss AS STRING
	IF m_hdc  = 0 THEN printerName=This.defaultprinter
	'wi = GetDeviceCaps(m_hdc ,  LOGPIXELSX) * wi 'width in pixels (logical units)
	IF wi > 0 THEN
	ss = s
	GetTextExtentExPoint m_hdc , StrPtr(ss), LEN(ss), wi, Cast(LPINT,nFit), NULL, @cSize
	Return LEFT(ss, nFit)
	ELSEIF wi < 0 THEN
	wi = ABS(wi): ss = STRREVERSE$(s)
	GetTextExtentExPoint m_hdc , StrPtr(ss), LEN(ss), wi, Cast(LPINT,nFit),NULL, @cSize
	Function =STRREVERSE$(LEFT(ss, nFit))
	END IF
	END Function
	'/
	
	
	
	
	
	Private Sub printer.getCharSize(ByRef wi As Integer, ByRef ht As Integer) 'character width and height in inches 'average character width if proportional font
	End Sub
	
	Private Function printer.getLines(  ByVal y As Integer) As Long 'determine number of remaining lines from y to bottom margin
			Return 0
	End Function
	
	Private Property Printer.DuplexMode() As PrinterDuplexMode
		Return m_Duplex
	End Property
	
	Private Property Printer.DuplexMode(n As PrinterDuplexMode)   'n = 1 Simplex  'n = 2 Horizontal  'n = 3 Vertical
	End Property
	
	Private Sub Printer.orientPrint(n As Long) 'n = 1 Portrait 'n = 2 Landscape
	End Sub
	
	Private Property Printer.Orientation(value As PrinterOrientation)
		SetPrinterOrientation2(printerName, value) ' orientPrint(value)
	End Property
	
	Private Property Printer.Orientation() As PrinterOrientation
		Return GetPrinterOrientation(printerName)
	End Property
	
	
	
	
	
	
	Private Sub Printer.UpdateMargeins()
		'x, y are measured from the left and top edges of the paper
		'if x or y are omitted then last valuew, xLast, yLast are used
		Dim As Long xc, yc, xm, leftNoPrn, rightNoPrn, topNoPrn, bottomNoPrn
		Dim As Long paperWi, paperHt, xMax, yMax, xppi, yppi
	End Sub
	
	Private Property Printer.Title( value As String)
		FTitle=value
	End Property
	
	Private Property Printer.Title() As String
		Return FTitle
	End Property
	
	Private Sub Printer.StartDoc()
	End Sub
	
	Private Sub Printer.StartPage
	End Sub
	
	Private Sub Printer.EndDPage
	End Sub
	
	Private Sub Printer.NewPage
	End Sub
	
	Private Sub Printer.EndDoc
	End Sub
	
	
	'------------------------------------------------------------------------------
	' Calculate the text resolution based on the default font for the Device
	' Context. Works with both window and printer DC's. Requires %MM_TEXT mode.
	'
	Private Sub Printer.CalcPageSize(ByRef Rows As Long, ByRef Columns As Long)
	End Sub
	
	Private Function Printer.PrinterPaperNames (ByRef PrinterName As WString) As String
		Dim Names As String
		Function = Names
	End Function
	
	
	
	' ========================================================================================
	' Returns a list of each supported paper sizes, in tenths of a millimeter.
	' Each entry if formated as "<width> x <height>" and separated by a carriage return and a
	' line feed characters.
	' ========================================================================================
	Private Function Printer.GetPrinterPaperSizesAsString(ByRef PrinterName As WString) As String
		Dim i As Long, r As Long, Sizes As String
		Function = Sizes
	End Function
	
	Sub Printer.GetPrinterPaperSizes(ByRef PrinterName As WString)
		Dim paperCount As Integer
		Dim paperIDs As Integer Ptr
		Dim paperNames As WString Ptr
		Dim paperWidth As Integer
		Dim paperHeight As Integer
		Dim i As Integer
		
	End Sub
	
	Private Function Printer.GetPrinterPort (ByRef PrinterName As WString) As String ' Returns the port name for a given printer name.
		Dim i As Long, Level As Long, cbNeeded As Long, cbReturned As Long
			Return ""
	End Function
	
	
	
	' ========================================================================================
	' Returns the printer print quality mode.
	' The return value can be one of the following:
	' - DMRES_DRAFT  = Draft
	' - DMRES_LOW    = Low
	' - DMRES_MEDIUM = Medium
	' - DMRES_HIGH   = High
	' ========================================================================================
	Private Function Printer.GetPrinterQualityMode (ByRef PrinterName As WString) As PrinterQuality
			Return 0
	End Function
	' ========================================================================================
	
	' ========================================================================================
	' Specifies the factor by which the printed output is to be scaled. The apparent page size
	' is scaled from the physical page size by a factor of dmScale /100. For example, a
	' letter-sized page with a dmScale value of 50 would contain as much data as a page of
	' 17- by 22-inches because the output text and graphics would be half their original
	' height and width.
	' ========================================================================================
	Private Function Printer.GetPrinterScale (ByRef PrinterName As WString) As Long
			Return 0
	End Function
	
	Private Function Printer.GetPrinterScalingFactorX (ByRef PrinterName As WString) As Long  ' Scaling factor for the x-axis of the printer.
		Dim nResult As Long
		Function = nResult
	End Function
	
	
	
	Private Function printer.GetPrinterScalingFactorY (ByRef PrinterName As WString) As Long ' Scaling factor for the y-axis of the printer.
		Dim nResult As Long
		Function = nResult
	End Function
	
	
	' ========================================================================================
	' Switches between color and monochrome on color printers.
	' The following are the possible values:
	'   DMCOLOR_COLOR
	'   DMCOLOR_MONOCHROME
	' ========================================================================================
	Private Function printer.SetPrinterColorMode (ByRef PrinterName As WString, ByVal nMode As Long) As Long
		Function  = True
		
	End Function
	
	' ========================================================================================
	' Selects the number of copies printed if the device supports multiple-page copies.
	' ========================================================================================
	Private Function printer.SetPrinterCopies (ByRef PrinterName As WString, ByVal nCopies As Long) As Long
		Function  = True
		
	End Function
	
	' ========================================================================================
	' Sets the printer duplex mode
	' DMDUP_SIMPLEX = Single sided printing
	' DMDUP_VERTICAL = Page flipped on the vertical edge
	' DMDUP_HORIZONTAL = Page flipped on the horizontal edge
	' ========================================================================================
	Private Function printer.SetPrinterDuplexMode (ByRef PrinterName As WString, ByVal nDuplexMode As Long) As Long
		Function  = True
		
	End Function
	
	
	
	Private Function Printer.SetPrinterPaperSize (ByRef PrinterName As WString, ByVal nSize As Long) As Long ' Sets the printer paper size.
		Function  = True
		
	End Function
	
	Private Function Printer.SetPrinterQuality (ByRef PrinterName As WString, ByVal nMode As PrinterQuality) As Long ' Specifies the printer resolution.
		Function  = True
		
	End Function
	
	
	Private Function Printer.GetPrinterDriverVersion (ByRef PrinterName As WString) As Long  ' Returns the version number of the printer driver.
			Function = 0
	End Function
	
	Private Function Printer.GetPrinterDuplex (ByRef PrinterName As WString) As Long  ' If the printer supports duplex printing, the return value is 1; otherwise, the return value is zero.
			Function = 0
	End Function
	
	
	Private Function Printer.GetPrinterFromPort (ByRef sPortName As WString) As String ' Returns the printer name for a given port name.
		Dim i As Long, Level As Long, cbNeeded As Long, cbReturned As Long, Names As String
		Function = Names
	End Function
	
	
	Private Function Printer.GetPrinterHorizontalResolution (ByRef PrinterName As WString) As Long ' Width, in pixels, of the printable area of the page.
		Dim nResult As Long
		Function = nResult
	End Function
	
	
	Private Function Printer.GetPrinterVerticalResolution (ByRef PrinterName As WString) As Long ' Width, in pixels, of the printable area of the page.
		Dim nResult As Long
		Function = nResult
	End Function
	
	' ========================================================================================
	' Returns the maximum number of copies the device can print.
	' there was a general function failure.
	' ========================================================================================
	
	
	Private Function Printer.GetPrinterMaxCopies (ByRef PrinterName As WString) As Long
			Function = 0
	End Function
	
	Private Function Printer.GetPrinterMaxPaperHeight (ByRef PrinterName As WString) As Long  ' Returns the maximum paper width in tenths of a millimeter.
			Function = 0
	End Function
	
	Private Function Printer.GetPrinterMaxPaperWidth (ByRef PrinterName As WString) As Long ' Returns the maximum paper width in tenths of a millimeter.
			Function = 0
	End Function
	
	
	
	
	' ========================================================================================
	' Returns a list with port names of the available printers, print servers, domains, or print providers.
	' Names are separated with a carriage return and a line feed characters.
	' ========================================================================================
	Private Function Printer.EnumPrinterPorts () As String
		Dim i As Long, Level As Long, cbNeeded As Long, cbReturned As Long, Names As String
		Function = Names
	End Function
	
	' ========================================================================================
	' Returns a list with the available printers, print servers, domains, or print providers.
	' Names are separated with a carriage return and a line feed characters.
	' ========================================================================================
	Private Function Printer.EnumPrinters_ () As String
		Dim i As Long, Level As Long, cbNeeded As Long, cbReturned As Long, Names As String
		Function = Names
	End Function
	
	' ========================================================================================
	' Retrieves the name of the default printer.
	' ========================================================================================
	/'
	FUNCTION  printer.defaultprinter () AS String
	Dim buffer AS ZSTRING * MAX_PATH
	GetProfileString "WINDOWS", "DEVICE", "", buffer, SIZEOF(buffer)
	FUNCTION = PARSE (buffer, 1)
	END FUNCTION
	'/
	
	Private Function Printer.GetDefaultPrinterDevice () As String  ' Retrieves the name of the default printer device.
			Function = ""
	End Function
	
	
	Private Function Printer.GetDefaultPrinterDriver () As String  ' Retrieves the name of the default printer driver.
			Function = ""
	End Function
	
	
	Private Function Printer.GetDefaultPrinterPort () As String  ' Retrieves the name of the default printer port.
			Function = ""
	End Function
	
	Private Sub Printer.ShowPrinterProperties()
	End Sub
	
	
	Private Constructor Printer
		Canvas.Ctrl = @This
		WLet(FClassName, "Printer")
	End Constructor
End Namespace
