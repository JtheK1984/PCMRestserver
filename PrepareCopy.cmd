echo "Kopiere Datei ins Setupverzeichnis 32-Bit"
copy /y /v Win32\Release\PCMRestserver.exe "e:\Inno\Setupfiles\Programme\PCMRestserver"
echo "Kopiere Datei ins Setupverzeichnis 64-Bit"
copy /y /v Win64\Release\PCMRestserver.exe "e:\Inno\Setupfiles\Programme\PCMRestserver_x64"

echo "Kopiere Doku ins Setupverzeichnis"
copy /y /v PCMRestserver.docx "e:\Inno\Setupfiles\Programme\PCMRestserver"
copy /y /v PCMRestserver.pdf "e:\Inno\Setupfiles\Programme\PCMRestserver"
copy /y /v PCMRestserver.htm "e:\Inno\Setupfiles\Programme\PCMRestserver"
