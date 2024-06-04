echo "Kopiere Datei ins Setupverzeichnis"
copy /y /v Win32\Release\PCMRestserver.exe "e:\Inno\Setupfiles\Programme\PCMRestserver"
copy /y /v Win64\Release\PCMRestserver.exe "e:\Inno\Setupfiles\Programme\PCMRestserver_x64"

copy /y /v Win64\Release\PCMRestserver.DE "e:\Inno\Setupfiles\Programme\PCMRestserver_x64"
copy /y /v Win64\Release\PCMRestserver.EN "e:\Inno\Setupfiles\Programme\PCMRestserver_x64"

copy /y /v PCMRestserver.docx "e:\Inno\Setupfiles\Programme\PCMRestserver"
copy /y /v PCMRestserver.pdf "e:\Inno\Setupfiles\Programme\PCMRestserver"
copy /y /v PCMRestserver.htm "e:\Inno\Setupfiles\Programme\PCMRestserver"
