# Archiv-Konfiguration für Android

## Schnittstellen

Die DataSnap-Methoden verwenden wie die bestehenden UpdateGet-Methoden POST:

- `/PCM/api/v1/GetArchivConfiguration`: vollständiger Datenbestand aller sieben Listen; für die SQLite-Synchronisierung verwenden.
- `/PCM/api/v1/GetArchivMainCategories`: MainCategories.
- `/PCM/api/v1/GetArchivSubCategories`: SubCategories.
- `/PCM/api/v1/GetArchivIndices`: Indices und IndexTypes.
- `/PCM/api/v1/GetArchivAssignments`: MainCategoryAssignments, SubCategoryAssignments und IndexAssignments.

Authentifizierung: bestehende DataSnap-Anmeldung, Rolle WebAPI_PCM und CheckUser (Benutzer mit RestApi-Berechtigung). Keine ID_User erforderlich: Archiv-Konfiguration ist im Windows-Projekt global.

HTTP 200: HasError=false, ErrorCode=0, Errormessage="". Listen sind auch bei null Datensätzen vorhanden und leer. HTTP 401: Anmeldung abgelehnt. HTTP 500: Datenbankfehler; kein unvollständiger Konfigurationsbestand.

## Listen und Felder

| Liste | Felder |
| --- | --- |
| MainCategories | ID, Bezeichnung |
| SubCategories | ID, Bezeichnung |
| Indices | ID, Bezeichnung, ID_archiv_konfiguration_index_typ |
| IndexTypes | ID, Bezeichnung |
| MainCategoryAssignments | ID (= Hauptkategorie-ID) |
| SubCategoryAssignments | ID, ID_archiv_konfiguration_hauptkategorien, ID_archiv_konfiguration_unterkategorien |
| IndexAssignments | ID, ID_archiv_konfiguration_unterkategorien, ID_archiv_konfiguration_index |

IDs sind JSON-Zahlen, Bezeichnungen Zeichenketten, SQL NULL wird JSON null. Original-IDs beim lokalen Speichern beibehalten, keine neuen lokalen IDs generieren.

Wichtig: IndexAssignments.ID_archiv_konfiguration_unterkategorien verweist auf SubCategoryAssignments.ID, nicht auf SubCategories.ID. Diese Struktur entspricht dem Windows-Archiv. Unterkategorien können verschiedenen Hauptkategorien mit unterschiedlichen Indizes zugewiesen werden.

## Geplanter SQLite-Abgleich

1. Vollständigen Abruf GetArchivConfiguration ausführen und HTTP-Status, HasError, alle sieben Listen und Referenzen prüfen. Bei Fehler oder fehlenden Listen bleibt die lokale Datenbank erhalten.
2. SQLite-Fremdschlüssel aktivieren und eine Transaktion beginnen.
3. Bisherige Zuweisungen zuerst löschen: IndexAssignments, SubCategoryAssignments, MainCategoryAssignments. Danach Indices, IndexTypes, SubCategories, MainCategories löschen. Dokumenttabellen bleiben erhalten; deren Referenzen müssen vor der konkreten Client-Implementierung berücksichtigt werden.
4. Stammdaten mit Server-IDs einsetzen: MainCategories, SubCategories, IndexTypes, Indices. Anschließend MainCategoryAssignments, SubCategoryAssignments und IndexAssignments einsetzen.
5. Synchronisationszeit lokal speichern und COMMIT. Bei jedem Fehler ROLLBACK. Leere Listen sind gültig und entfernen bisherige Einträge.

Dies ist zunächst eine vollständige Server-zu-Android-Synchronisierung. Lokale Änderungen an der Konfiguration, Upload, inkrementeller Abgleich und Konfliktauflösung sind nicht implementiert. Die Android-SQLite-Implementierung erfolgt im nächsten Projektschritt.

## Validierung

Win32 Release mit Delphi 37.0 erfolgreich kompiliert. Der vorhandene Build enthält Dienst-Stopp/-Start-Ereignisse; beide scheiterten mit Zugriff verweigert. Kein Dienst wurde damit neu gestartet. Automatisch veränderte Versionsressourcen wurden zurückgesetzt. Endpunktaufrufe gegen eine laufende Datenbank müssen noch getestet werden.

## Dokumentmetadaten

POST /PCM/api/v1/GetArchivDocuments liefert Documents als vollständige Liste. Zusätzlich zur REST-Anmeldung wird das Archivrecht dm_archiv (1, 2 oder 3) geprüft. Ohne Leserecht HTTP 403. Enthält Dokumentfelder einschließlich dynamischer Indexwerte, aber keine Fullpath- oder Binärfelder. OneDriveRelativePath enthält den Pfad relativ zur OneDrive-Wurzel, wenn Fullpath mit %onedrive%\ beginnt, sonst null. Es wird kein Dateidownload angeboten. Der neue Servercode wurde für Win32 kompiliert; Live-Datenbanktest steht aus.
