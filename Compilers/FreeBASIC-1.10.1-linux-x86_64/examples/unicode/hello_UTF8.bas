''
'' "Hello World!" test, in UTF-8 format
''


const LANG = "Chinese"
	dim helloworld as wstring * 20 => "你好，世界!"

	print """Hello World!"" in "; LANG; ": "; helloworld
