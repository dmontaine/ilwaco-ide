''
'' "Hello World!" test, in ascii+unc (\u escape sequencies) format
''


const LANG = "Chinese"
	dim helloworld as wstring * 20 => !"\u4f60\u597d\uff0c\u4e16\u754c!"

	print """Hello World!"" in "; LANG; ": "; helloworld
