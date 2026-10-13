# Firebase-Push-Test einrichten

Der App-Test sendet POST /PCM/api/v1/SendPushTest mit DeviceToken. Die DataSnap-Methode UpdateSendPushTest prueft die Anmeldung und ob der Token in manager_devices zum Benutzer gehoert. Nachrichtentitel und Text sind serverseitig festgelegt.

## Server konfigurieren

1. Im Firebase-Projekt pcm-manager unter Projekteinstellungen > Dienstkonten einen neuen privaten Schluessel als JSON erzeugen. google-services.json aus der App ist keine Service-Account-Datei.
2. Die JSON-Datei ausserhalb des Repositorys auf dem Server speichern. Nur dem Dienstkonto und Administratoren Lesezugriff geben.
3. GOOGLE_APPLICATION_CREDENTIALS fuer den Serverprozess auf den absoluten Dateipfad setzen. Bei einem Windows-Dienst muss die Variable im Dienstprozess verfuegbar sein; anschliessend den Dienst neu starten.
4. Firebase Cloud Messaging API aktivieren und dem Service Account die Berechtigung cloudmessaging.messages.create im selben Projekt geben (z.B. Firebase Cloud Messaging API Admin).
5. Neue Serverversion bereitstellen. Der Server nutzt Windows CNG fuer RSA-SHA256, tauscht die Signatur bei oauth2.googleapis.com gegen ein kurzlebiges Token und sendet an fcm.googleapis.com. Es werden keine zusaetzlichen Python-/Node-Pakete benoetigt.

## Auf dem Android-Geraet testen

1. Neue App installieren, Internet und Google Play-Dienste sicherstellen.
2. Benachrichtigungen fuer die App erlauben.
3. Anmelden und synchronisieren, damit der aktuelle Geraetetoken in manager_devices registriert ist.
4. Einstellungen > FCM-Informationen antippen.
5. Bei Erfolg meldet die App, dass Firebase die Nachricht angenommen hat. Das bestaetigt den Versand, nicht die Anzeige auf dem Geraet.

Fehlende Serverkonfiguration, fehlende Geraeteregistrierung und Firebase-Fehler werden in der App angezeigt. Service-Account-Dateien niemals in die App oder ins Repository aufnehmen. Den frueher in der App enthaltenen Legacy-Serverschluessel in Google widerrufen, sofern er noch vorhanden ist.

## Validierung

Android64-App und Win64-Server wurden kompiliert. Ein echter Versand benoetigt die konfigurierte Service-Account-Datei und ein registriertes Android-Geraet und wurde noch nicht durchgefuehrt.

Referenz: https://firebase.google.com/docs/cloud-messaging/send/v1-api