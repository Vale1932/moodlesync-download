# Datenschutzerklärung – Sync for Moodle (Moodle Sync)

Stand: 18. November 2026

Diese Erklärung gilt für die App «Sync for Moodle» aus dem Microsoft Store und für «Moodle Sync»
(Installer für Windows und macOS). Kurz gesagt: **Deine Moodle-Dateien und deine Anmeldung bleiben
auf deinem Computer.** Die App enthält keine Werbung, keine Analyse- oder Tracking-Dienste und
verkauft keine Daten.

## Verantwortlich

Valentin V., VLTN Apps, Zürich, Schweiz
Kontakt: tschegsch@gmail.com

## Welche Daten wohin gehen

### 1. Deine Moodle-Seite (z. B. Moodle der ETH Zürich)

- Du meldest dich im Browser direkt bei deiner Hochschule an. Dein Passwort sieht die App nie.
- Danach erhält die App einen Moodle-Zugangsschlüssel (Token). Er bleibt **auf deinem Computer**
  (Windows: verschlüsselt und an dein Benutzerkonto gebunden; macOS: in einer Datei, die nur dein
  Benutzerkonto lesen darf) und wird **nur an deine Moodle-Seite** geschickt.
- Die App lädt von dort deine Kurse, Kursdateien, Termine und Forumsbeiträge herunter. Zu den
  Forumsbeiträgen gehören die Namen der Verfasser und ihre Rolle im Kurs (Dozent, Assistent,
  Student). Die App sieht damit nur, was du in Moodle ohnehin sehen darfst.
- Für diese Daten ist deine Hochschule verantwortlich. Es gelten ihre Datenschutzbestimmungen.

### 2. Lizenz

**Store-Version:** Du kaufst die App im Microsoft Store. Den Kauf wickelt Microsoft ab, es gilt die
Datenschutzerklärung von Microsoft. Ich erhalte dabei keine Zahlungsdaten. Die Store-Version nutzt den
Lizenzdienst nicht.

**Installer-Version (Windows und macOS):** Sie braucht einen Lizenzschlüssel und nutzt dafür einen
eigenen Lizenzdienst (betrieben vom Verantwortlichen, gehostet bei Cloudflare):

- **Beim Aktivieren** schickt die App den Lizenzschlüssel und eine **Gerätekennung**. Die
  Gerätekennung ist ein nicht umkehrbarer Hashwert (SHA-256) der Windows- bzw. Mac-Gerätenummer, die
  Gerätenummer selbst wird nie übertragen. So funktioniert ein Schlüssel nur auf einem Gerät.
- **Etwa alle 14 Tage** fragt die App kurz nach, ob die Lizenz noch gültig ist. Dabei schickt sie
  die Lizenznummer (kurze Kennung) und die Gerätekennung.
- Gespeichert werden: ein Hashwert des Schlüssels (nicht der Schlüssel selbst), der Name, unter dem
  die Lizenz ausgestellt wurde, die Gerätekennung sowie die Zeitpunkte von Ausstellung und
  Aktivierung.
- Zum Schutz vor Missbrauch wird die **IP-Adresse** zusammen mit der Zahl der Anfragen pro Stunde
  gespeichert und nach spätestens 2 Stunden gelöscht. Cloudflare verarbeitet als Hoster technisch
  ebenfalls die IP-Adresse (siehe Datenschutzerklärung von Cloudflare). Die Server können
  ausserhalb der Schweiz liegen.
- Die Lizenzdaten bleiben gespeichert, solange die Lizenz besteht. Auf Wunsch lösche ich sie.

### 3. Updates

- **Store-Version:** Updates kommen über den Microsoft Store. Es gilt die Datenschutzerklärung von
  Microsoft.
- **Installer-Version:** Höchstens einmal pro Tag lädt die App eine kleine Datei mit der neusten
  Versionsnummer von GitHub. Erst wenn du «Jetzt aktualisieren» klickst, lädt sie den neuen
  Installer herunter. Dabei sieht GitHub deine IP-Adresse (siehe Datenschutzerklärung von GitHub).

### 4. Download-Seite

Die Download-Seite (https://vale1932.github.io/moodlesync-download) liegt bei GitHub Pages. Beim Aufruf
sieht GitHub deine IP-Adresse (siehe Datenschutzerklärung von GitHub). Die Seite fragt bei GitHub nach,
welche Mac-Version die neuste ist. Sie setzt keine Cookies und enthält keine Werbung und kein Tracking.
Schreibst du mir über «Lizenz anfragen» eine E-Mail, verwende ich deine Angaben nur, um dir die Lizenz zu
schicken.

## Was auf deinem Computer bleibt

Einstellungen, Moodle-Token, Lizenz-Zertifikat, Protokolle und der Stand der
Foren liegen im Ordner `.moodle-sync` in deinem Benutzerordner. Die heruntergeladenen Dateien
liegen in dem Zielordner, den du gewählt hast. Mitteilungen nach dem täglichen Sync zeigt Windows
bzw. macOS lokal an. Über «Abmelden» in der App wird der Moodle-Token gelöscht. Wenn du die App
deinstallierst und den Ordner `.moodle-sync` löschst, ist alles entfernt.

## Deine Rechte

Du kannst jederzeit Auskunft über die zu deiner Lizenz gespeicherten Daten verlangen. Du kannst sie
auch berichtigen oder löschen lassen. Melde dich dafür unter tschegsch@gmail.com. Für Daten in Moodle wende
dich an deine Hochschule.

## Änderungen

Ändert sich etwas an dieser Erklärung, steht die neue Fassung an dieser Stelle, mit neuem Datum.
