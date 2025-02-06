# Projekt: 
  PCMRestserver.exe

# Kurzbeschreibung
  RestServer API

# Entwicklungsumgebung:
  DELPHI 12 Athens

# Entwickler:
  Jens Henske
	
# Abhängigkeiten zu folgenden Sub-Modulen:
  - PCM-Functions
  (Dokumentation:
  [Azure DevOps](https://pcmapps.ddns.net:2443/PCM-DEV/PCM/PCMFunctions)
  [GitHub](https://github.com/JtheK1984/PCMFunctions))

# Abhängigkeiten zu folgenden DLL's:
  - 32-Bit 
    - libmysql.dll (DLL für Verbindung zur MySQL-Datenbank)
    - libeay32.dll (DLL für SSL-Verbindungen)
    - ssleay32.dll (DLL für SSL-Verbindungen)
  - 64-Bit 
    - libmysql.dll (DLL für Verbindung zur MySQL-Datenbank)
    - libeay32.dll (DLL für SSL-Verbindungen)
    - ssleay32.dll (DLL für SSL-Verbindungen)
	
# Erforderliche Komponenten (DELPHI-IDE):
  - Devexpress
	
# Erforderliche Scripte (nur für die Buildpipelines in Azure DevOps): 
  - PrepareBuild.cmd (Umgebungsvariablen für Delphi anpassen, wird für den Build benötigt)
  - PrepareCopy.cmd (erzeugte Versionen werden in das Inno-Setupverzeichnis abgelgt)

# Stand:
  31.01.2025