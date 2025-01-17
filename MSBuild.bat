call "C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"
echo "Build erstellen"
msbuild E:/Projekte/Windows/PCMRestserver/PCMRestserver.dproj /t:Clean;Build;CompressWin32 /p:config=Release /p:platform=Win32
msbuild E:/Projekte/Windows/PCMRestserver/PCMRestserver.dproj /t:Clean;Build;Localize;CompressWin64 /p:config=Release /p:platform=Win64

echo "Kopiere Datei ins Setupverzeichnis 32-Bit"
copy /y /v E:\Projekte\Windows\PCMRestserver\Win32\Release\PCMRestserver.exe "e:\Inno\Setupfiles\Programme\PCMRestserver"

echo "Kopiere Datei ins Setupverzeichnis 64-Bit"
copy /y /v E:\Projekte\Windows\PCMRestserver\Win64\Release\PCMRestserver.exe "e:\Inno\Setupfiles\Programme\PCMRestserver_x64"
copy /y /v E:\Projekte\Windows\PCMRestserver\Win64\Release\PCMRestserver.DE "e:\Inno\Setupfiles\Programme\PCMRestserver_x64"
copy /y /v E:\Projekte\Windows\PCMRestserver\Win64\Release\PCMRestserver.EN "e:\Inno\Setupfiles\Programme\PCMRestserver_x64"

echo "Kopiere Doku ins Setupverzeichnis"
copy /y /v E:\Projekte\Windows\PCMRestserver\PCMRestserver.docx "e:\Inno\Setupfiles\Programme\PCMRestserver"
copy /y /v E:\Projekte\Windows\PCMRestserver\PCMRestserver.pdf "e:\Inno\Setupfiles\Programme\PCMRestserver"
copy /y /v E:\Projekte\Windows\PCMRestserver\PCMRestserver.htm "e:\Inno\Setupfiles\Programme\PCMRestserver"
