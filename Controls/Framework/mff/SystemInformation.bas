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
#include once "SystemInformation.bi"

Namespace My.Sys.Forms
	Private Function SystemInformation.GetSize(iWidth As Integer, iHeight As Integer) As My.Sys.Drawing.Size
			Return Type<My.Sys.Drawing.Size>(0, 0)
	End Function
	
	Private Function SystemInformation.DragSize As My.Sys.Drawing.Size
			Return GetSize(0, 0)
	End Function
	  ' Screen width 
   Function SystemInformation.ScreenWidth As Integer
       Return GetSystemMetrics(SM_CXSCREEN)
   End Function
   ' Screen height 
   Function SystemInformation.ScreenHeight As Integer
       Return GetSystemMetrics(SM_CYSCREEN)
   End Function
   ' Currently pressed mouse buttons 
   Function SystemInformation.MouseButtons As Integer
       Dim As Integer buttons
       If GetAsyncKeyState(VK_LBUTTON) And &H8000 Then buttons Or= 1  ' Left button 
       If GetAsyncKeyState(VK_RBUTTON) And &H8000 Then buttons Or= 2  ' Right button 
       If GetAsyncKeyState(VK_MBUTTON) And &H8000 Then buttons Or= 4  ' Middle button 
       Return buttons
   End Function
   ' Valid double-click area size 
   Function SystemInformation.DoubleClickSize As My.Sys.Drawing.Size
       Dim As My.Sys.Drawing.Size iSize
       iSize.Width = GetSystemMetrics(SM_CXDOUBLECLK)
       iSize.Height = GetSystemMetrics(SM_CYDOUBLECLK)
       Return iSize
   End Function
   ' Working area (excluding taskbar) 
   Function SystemInformation.WorkingArea As My.Sys.Drawing.Rect
       Dim As RECT rc
       SystemParametersInfo(SPI_GETWORKAREA, 0, @rc, 0)
       Return Type<My.Sys.Drawing.Rect>(rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top)
   End Function
   ' Window border size 
   Function SystemInformation.BorderSize As My.Sys.Drawing.Size
       Dim As My.Sys.Drawing.Size iSize
       iSize.Width = GetSystemMetrics(SM_CXBORDER)
       iSize.Height = GetSystemMetrics(SM_CYBORDER)
       Return iSize
   End Function
   ' Maximum draggable window size 
   Function SystemInformation.MaxWindowTrackSize As My.Sys.Drawing.Size
       Dim As My.Sys.Drawing.Size iSize
       iSize.Width = GetSystemMetrics(SM_CXMAXTRACK)
       iSize.Height = GetSystemMetrics(SM_CYMAXTRACK)
       Return iSize
   End Function
   
End Namespace

