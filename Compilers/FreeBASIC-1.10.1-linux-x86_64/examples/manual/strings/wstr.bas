'' examples/manual/strings/wstr.bas
''
'' Example extracted from the FreeBASIC Manual
'' from topic 'WSTR'
''
'' See Also: https://www.freebasic.net/wiki/wikka.php?wakka=KeyPgWstr
'' --------


Dim zs As ZString * 20
Dim ws As WString * 20

zs = "Hello World"
ws = WStr(zs)


Print ws
Print WStr("Unicode 'Hello World'")
