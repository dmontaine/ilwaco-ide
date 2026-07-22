''
'' Regex.bas
'' Regular expressions support for MyFbFramework
''
'' Unicode-only (WString / UString). Three pluggable backends, selected at
'' compile time -- see Regex.bi for the selection rules and link flags.
''
'' All of Match / Matches / Replace / ReplaceFirst / Split / IsMatch are
'' implemented once, in terms of Regex.EngineFindNext(), which is the only
'' function each backend has to provide. EngineFindNext always works in
'' *character* offsets into the caller's WString/UString -- backends that
'' internally operate on UTF-8 (PCRE2, GRegex) convert byte offsets back to
'' char offsets via the framework's ToUtf8()/FromUtf8() helpers so callers
'' never see a UTF-8 byte offset.
''

#include once "Regex.bi"

#ifdef __USE_PCRE2__
	#define PCRE2_CODE_UNIT_WIDTH 8
	#include once "pcre2.bi"
#endif

Namespace My.Sys.Text

	'' -------------------------------------------------------------
	'' Shared UTF-8 <-> WString char-offset helpers.
	'' Used by the PCRE2 and GRegex backends (both operate on UTF-8).
	'' Not used by the Windows/COM backend, which works natively on
	'' UTF-16 WStrings and needs no such conversion.
	'' -------------------------------------------------------------

	'' How many WString characters does the first ByteLen bytes of Utf8Bytes
	'' decode to? Utf8Bytes must be sliced at a UTF-8 character boundary
	'' (true for all offsets PCRE2/GRegex hand back to us).
	Private Function Utf8ByteLenToCharIndex(ByRef Utf8Bytes As String, ByVal ByteLen As Integer) As Integer
		If ByteLen <= 0 Then Return 0
		Dim As String prefix = Left(Utf8Bytes, ByteLen)
		Dim As WString Ptr w = FromUtf8(StrPtr(prefix))
		Dim As Integer n = 0
		If w <> 0 Then
			n = Len(*w)
			Deallocate(w)
		End If
		Return n
	End Function

	'' Inverse: how many UTF-8 bytes does the first CharIndex WString
	'' characters of Text encode to?
	Private Function CharIndexToUtf8ByteOffset(ByRef Text As Const WString, ByVal CharIndex As Integer) As Integer
		If CharIndex <= 0 Then Return 0
		Dim As UString prefix = Left(Text, CharIndex)
		Return Len(ToUtf8(prefix))
	End Function

	'' -------------------------------------------------------------
	'' Backend: PCRE2 (8-bit library, UTF-8 mode) -- used whenever
	'' __USE_PCRE2__ is defined, regardless of platform.
	'' -------------------------------------------------------------

	Type GErrorStruct
		domain As UInteger
		code As Long
		message As ZString Ptr
	End Type

	Const G_REGEX_CASELESS  As Long = 1 Shl 0
	Const G_REGEX_MULTILINE As Long = 1 Shl 1
	Const G_REGEX_DOTALL    As Long = 1 Shl 2
	Const G_REGEX_EXTENDED  As Long = 1 Shl 3

	Extern "C"
		Declare Function g_regex_new Alias "g_regex_new" _
			(ByVal pattern As Const ZString Ptr, ByVal compile_options As Long, ByVal match_options As Long, ByVal error As Any Ptr Ptr) As Any Ptr
		Declare Sub g_regex_unref Alias "g_regex_unref" (ByVal regex As Any Ptr)

		Declare Function g_regex_match_full Alias "g_regex_match_full" _
			(ByVal regex As Any Ptr, ByVal str As Const ZString Ptr, ByVal str_len As Long, ByVal start_position As Long, _
			 ByVal match_options As Long, ByVal match_info As Any Ptr Ptr, ByVal error As Any Ptr Ptr) As Long

		Declare Function g_match_info_get_match_count Alias "g_match_info_get_match_count" (ByVal match_info As Any Ptr) As Long
		Declare Function g_match_info_fetch_pos Alias "g_match_info_fetch_pos" _
			(ByVal match_info As Any Ptr, ByVal match_num As Long, ByRef start_pos As Long, ByRef end_pos As Long) As Long
		Declare Sub g_match_info_free Alias "g_match_info_free" (ByVal match_info As Any Ptr)

		Declare Sub g_error_free Alias "g_error_free" (ByVal error As Any Ptr)
	End Extern

	Private Function OptionsToGRegex(ByVal Options As RegexOptions) As Long
		Dim As Long flags = 0
		If (Options And reIgnoreCase)    Then flags Or= G_REGEX_CASELESS
		If (Options And reMultiline)     Then flags Or= G_REGEX_MULTILINE
		If (Options And reDotMatchesAll) Then flags Or= G_REGEX_DOTALL
		If (Options And reExtended)      Then flags Or= G_REGEX_EXTENDED
		Return flags
	End Function

	Private Sub Regex.FreeCompiled()
		If _Compiled <> NULL Then
			g_regex_unref(_Compiled)
			_Compiled = NULL
		End If
	End Sub

	Private Sub Regex.Compile()
		FreeCompiled()

		Dim As String pat8 = ToUtf8(_Pattern)
		Dim As Long flags = OptionsToGRegex(_Options)
		Dim As Any Ptr err_ = NULL

		_Compiled = g_regex_new(StrPtr(pat8), flags, 0, @err_)

		If _Compiled = NULL Then
			_Valid = False
			If err_ <> NULL Then
				Dim As GErrorStruct Ptr ge = err_
				_LastError = "Regex compile error: " & ZGet(ge->message)
				g_error_free(err_)
			Else
				_LastError = "Regex compile error (unknown)"
			End If
		Else
			_Valid = True
			_LastError = ""
		End If
	End Sub

	Private Function Regex.EngineFindNext(ByRef Text As Const WString, ByVal StartAt As Integer, ByRef OutMatch As RegexMatch) As Boolean
		OutMatch.Success = False
		If _Valid = False OrElse _Compiled = NULL Then Return False

		Dim As String subj8 = ToUtf8(*Cast(WString Ptr, @Text))
		Dim As Long byteStart = CharIndexToUtf8ByteOffset(Text, StartAt)

		Dim As Any Ptr matchInfo = NULL
		Dim As Long ok = g_regex_match_full(_Compiled, StrPtr(subj8), Len(subj8), byteStart, 0, @matchInfo, NULL)

		If ok = 0 Then
			If matchInfo <> NULL Then g_match_info_free(matchInfo)
			Return False
		End If

		Dim As Long groupCount = g_match_info_get_match_count(matchInfo)
		If groupCount < 1 Then groupCount = 1
		ReDim OutMatch.Groups(0 To groupCount - 1)

		For i As Long = 0 To groupCount - 1
			Dim As Long sOff, eOff
			Dim As Long got = g_match_info_fetch_pos(matchInfo, i, sOff, eOff)
			If got = 0 OrElse sOff < 0 Then
				OutMatch.Groups(i).Index  = -1
				OutMatch.Groups(i).Length = -1
				OutMatch.Groups(i).Value  = ""
			Else
				Dim As Integer cStart = Utf8ByteLenToCharIndex(subj8, sOff)
				Dim As Integer cEnd   = Utf8ByteLenToCharIndex(subj8, eOff)
				OutMatch.Groups(i).Index  = cStart
				OutMatch.Groups(i).Length = cEnd - cStart
				OutMatch.Groups(i).Value  = Mid(Text, cStart + 1, cEnd - cStart)
			End If
		Next

		g_match_info_free(matchInfo)

		OutMatch.Success = True
		OutMatch.Value  = OutMatch.Groups(0).Value
		OutMatch.Index  = OutMatch.Groups(0).Index
		OutMatch.Length = OutMatch.Groups(0).Length
		Return True
	End Function


	'' -------------------------------------------------------------
	'' Shared, engine-agnostic implementation. Every function below is
	'' written once, on top of Regex.EngineFindNext(), regardless of
	'' which backend was selected above.
	''
	'' NOTE ON STRING MIXING: WString and UString are different types with
	'' no automatic implicit conversion between them in every context (in
	'' particular, `Return someWString` from a UString-returning Function,
	'' and `uStringVar &= someWString`, do not reliably resolve on all fbc
	'' versions). So every place below that needs to combine a raw WString
	'' parameter (Text/Replacement) with a UString first copies it into a
	'' local `Dim As UString`, which *does* work (it goes through UString's
	'' Let-from-WString assignment), and only ever concatenates/returns
	'' UString-to-UString after that.
	'' -------------------------------------------------------------

	Constructor Regex()
		_Compiled = NULL
		_Valid = False
	End Constructor

	Constructor Regex(ByRef NewPattern As Const WString, ByVal Options As RegexOptions = reNone)
		_Compiled = NULL
		_Valid = False
		SetPattern(NewPattern, Options)
	End Constructor

	Destructor Regex()
		FreeCompiled()
	End Destructor

	Sub Regex.SetPattern(ByRef NewPattern As Const WString, ByVal Options As RegexOptions = reNone)
		_Pattern = NewPattern
		_Options = Options
		Compile()
	End Sub

	Property Regex.Pattern() As UString
		Return _Pattern
	End Property

	Property Regex.Pattern(ByRef Value As Const WString)
		SetPattern(Value, _Options)
	End Property

	Function Regex.IsValid() As Boolean
		Return _Valid
	End Function

	Function Regex.LastError() As UString
		Return _LastError
	End Function

	Function Regex.IsMatch(ByRef Text As Const WString) As Boolean
		Return IsMatch(Text, 0)
	End Function

	Function Regex.IsMatch(ByRef Text As Const WString, ByVal StartAt As Integer) As Boolean
		Dim tmp As RegexMatch
		Return EngineFindNext(Text, StartAt, tmp)
	End Function

	Function Regex.Match(ByRef Text As Const WString) As RegexMatch
		Return Match(Text, 0)
	End Function

	Function Regex.Match(ByRef Text As Const WString, ByVal StartAt As Integer) As RegexMatch
		Dim result As RegexMatch
		EngineFindNext(Text, StartAt, result)
		Return result
	End Function

	Function Regex.Matches(ByRef Text As Const WString) As RegexMatch Ptr
		Erase _LastMatches
		If _Valid = False Then Return NULL

		Dim As Integer pos = 0
		Dim As Integer textLen = Len(Text)
		Dim As Integer count = 0

		Do While pos <= textLen
			Dim m As RegexMatch
			If EngineFindNext(Text, pos, m) = False Then Exit Do

			ReDim Preserve _LastMatches(0 To count)
			_LastMatches(count) = m
			count += 1

			If m.Length <= 0 Then
				pos = m.Index + 1 '' avoid an infinite loop on zero-length matches
			Else
				pos = m.Index + m.Length
			End If
		Loop

		If count = 0 Then Return NULL
		Return @_LastMatches(0)
	End Function

	Function Regex.MatchCount() As Integer
		Return UBound(_LastMatches) + 1
	End Function

	Function Regex.ReplaceFirst(ByRef Text As Const WString, ByRef Replacement As Const WString) As UString
		Dim As UString textU = Text
		If _Valid = False Then Return textU

		Dim m As RegexMatch
		If EngineFindNext(Text, 0, m) = False Then Return textU

		Dim As UString resultU = Left(Text, m.Index) & Replacement & Mid(Text, m.Index + m.Length + 1)
		Return resultU
	End Function

	Function Regex.Replace(ByRef Text As Const WString, ByRef Replacement As Const WString) As UString
		Dim As UString textU = Text
		If _Valid = False Then Return textU

		Dim As UString replacementU = Replacement
		Dim As UString result = ""
		Dim As Integer pos = 0
		Dim As Integer textLen = Len(Text)

		Do While pos <= textLen
			Dim m As RegexMatch
			If EngineFindNext(Text, pos, m) = False Then
				Dim As UString tail = Mid(Text, pos + 1)
				result &= tail
				Exit Do
			End If

			Dim As UString beforeMatch = Mid(Text, pos + 1, m.Index - pos)
			result &= beforeMatch
			result &= replacementU

			If m.Length <= 0 Then
				If m.Index < textLen Then
					Dim As UString oneChar = Mid(Text, m.Index + 1, 1)
					result &= oneChar
				End If
				pos = m.Index + 1
			Else
				pos = m.Index + m.Length
			End If
		Loop

		Return result
	End Function

	Function Regex.Split(ByRef Text As Const WString) As UString Ptr
		Erase _LastSplit

		If _Valid = False Then
			ReDim _LastSplit(0 To 0)
			_LastSplit(0) = Text
			Return @_LastSplit(0)
		End If

		Dim As Integer pos = 0
		Dim As Integer lastEnd = 0
		Dim As Integer count = 0
		Dim As Integer textLen = Len(Text)

		Do While pos <= textLen
			Dim m As RegexMatch
			If EngineFindNext(Text, pos, m) = False Then Exit Do

			ReDim Preserve _LastSplit(0 To count)
			_LastSplit(count) = Mid(Text, lastEnd + 1, m.Index - lastEnd)
			count += 1
			lastEnd = m.Index + m.Length

			If m.Length <= 0 Then
				pos = m.Index + 1
			Else
				pos = m.Index + m.Length
			End If
		Loop

		ReDim Preserve _LastSplit(0 To count)
		_LastSplit(count) = Mid(Text, lastEnd + 1)

		Return @_LastSplit(0)
	End Function

	Function Regex.SplitCount() As Integer
		Return UBound(_LastSplit) + 1
	End Function

End Namespace
