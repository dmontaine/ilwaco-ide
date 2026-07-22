'################################################################################
'#  pipe.bi                                                                     #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov, Liu XiaLin                                     #
'#  Based on: the code posted on the freeBasic forum                            #
'#  See also:                                                                  #
'#   http://www.freebasic-portal.de/code-beispiele/kleine-helferlein/           #
'#    bipipe-bi-fuer-win-linux-299.html                                         #
'#                                                                              #
'################################################################################

	#define __USE_WINAPI__

	#include once "crt/linux/unistd.bi"
	Declare Function ioctl Alias "ioctl" (fd As Integer, request As ULong, ...) As Integer
	#define FIONREAD &h541B
	#define SW_NORMAL 0

Type BiPipe
Private:
		pipeStdin As Long
		pipeStdout As Long
Public:
		Declare Constructor (prgName As String)
	Declare Destructor ()
	Declare Function write (text As String) As Integer
	Declare Function read (timeout As UInteger = 100) As String
End Type

	Constructor BiPipe (prgName As String)
		Dim pipeStdin(0 To 1) As Long
		Dim pipeStdout(0 To 1) As Long
		
		pipe_(@pipeStdin(0))
		pipe_(@pipeStdout(0))
		
		If fork() = 0 Then
			close_(pipeStdin(1))
			close_(pipeStdout(0))
			
			dup2(pipeStdin(0), 0)
			dup2(pipeStdout(1), 1)
			
			execl(StrPtr("/bin/sh"), StrPtr("sh"), StrPtr("-c"), StrPtr(prgName), Cast(UByte Ptr, 0))
			_exit(1)
		End If
		
		This.pipeStdin = pipeStdin(1)
		This.pipeStdout = pipeStdout(0)
		
		close_(pipeStdin(0))
		close_(pipeStdout(1))
	End Constructor
	
	Destructor BiPipe ()
		close_(pipeStdin)
		close_(pipeStdout)
	End Destructor
	
	Function BiPipe.write (text As String) As Integer
		Return write_(pipeStdin, StrPtr(text), Len(text))
	End Function
	
	Function BiPipe.read (timeout As UInteger = 100) As String
		'returns the whole pipe content until the pipe is empty or timeout occurs.
		' timeout default is 100ms to prevent a deadlock
		Dim As Integer iNumberOfBytesRead, iTotalBytesAvail, iBytesLeftThisMessage
		Dim As String buffer, retText
		Dim As Double tout = Timer + Cast(Double,timeout) / 1000
		Do
			ioctl(pipeStdout, FIONREAD, @iTotalBytesAvail)
			If iTotalBytesAvail Then
				buffer = String(iTotalBytesAvail,Chr(0))
				read_(pipeStdout, StrPtr(buffer), Len(buffer))
				retText &= buffer
			ElseIf Len(retText) Then
				Exit Do
			End If
		Loop Until Timer > tout
		Return retText
	End Function

Function bipOpen(PrgName As String, showmode As Short = SW_NORMAL) As BiPipe Ptr
		Return New BiPipe(PrgName)
End Function

Sub bipClose(ByRef handles As BiPipe Ptr)
	Delete handles
	handles = 0
End Sub

Function bipWrite(handles As BiPipe Ptr, text As String) As Integer
	Return handles->write(text)
End Function

Function bipRead(handles As BiPipe Ptr, timeout As UInteger = 100) As String
	Return handles->read(timeout)
End Function

Function bipReadLine(handles As BiPipe Ptr, separator As String = "a" & Chr(13, 10), timeout As UInteger = 100) As String
		#print __FUNCTION__ Function Not implemented
		Return ""
End Function
