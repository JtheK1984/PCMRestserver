# Projekt:
  PCMRestserver.exe Version: 1.0.0.0

# Kurzbeschreibung:
  PCM - Restserver

# Beschreibung:
  Service mit kompletter RestAPI für alle Projekte

# Entwicklungsumgebung:
  DELPHI 12.3 Athens

# Entwickler:
  Jens Henske

# Abhängigkeiten zu folgenden Sub-Modulen:
  - PCM-Functions
  (Dokumentation: [Azure DevOps](https://pcmapps.ddns.net:2443/PCM-DEV/PCM/PCMFunctions) [GitHub](https://github.com/JtheK1984/PCMFunctions))

# Abhängigkeiten zu folgenden DLLs:
  - 32-Bit 
    - libmysql.dll (DLL für Verbindung zur MySQL-Datenbank)
    - libeay32.dll (DLL für SSL-Verbindungen)
    - ssleay32.dll (DLL für SSL-Verbindungen)
    - WebView2Loader.dll (DLL für Edgebrowser)
  - 64-Bit 
    - libmysql.dll (DLL für Verbindung zur MySQL-Datenbank)
    - libeay32.dll (DLL für SSL-Verbindungen)
    - ssleay32.dll (DLL für SSL-Verbindungen)
    - WebView2Loader.dll (DLL für Edgebrowser)

# Erforderliche Komponenten (DELPHI-IDE):
  - Devexpress 24.2.4

# Erforderliche Scripte (nur für die Buildpipelines in Azure DevOps):
  - PrepareBuild.cmd (Umgebungsvariablen für Delphi anpassen, wird für den Build benötigt)
  - PrepareCopy.cmd (erzeugte Versionen werden in das Inno-Setupverzeichnis abgelgt)

# Stand:
  12.07.2026
