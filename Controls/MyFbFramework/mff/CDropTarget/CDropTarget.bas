''
'' IDropTarget example for text objects, translated from a C++ code written by J Brown 2004 (www.catch22.net)
''

#include once "CDropTarget.bi"
#include once "../CDataObject/CDataObject.bi"
#include once "../Control.bi"

Namespace My.Sys.Forms
	Function DataObject.GetDataPresent(DataType As DataFormats) As Boolean
			Return False
	End Function
	
	Function DataObject.GetData(DataType As DataFormats) As Any Ptr
		Return 0
	End Function
	
	Private Sub DataObject.SetData(DataType As DataFormats, pData As Any Ptr, Bytes As Integer = 0)
	End Sub
	
	Private Sub DataObject.GetFileDropList(filePaths() As UString)
	End Sub
	
	Private Sub DataObject.SetFileDropList(filePaths() As UString)
	End Sub
	
End Namespace
