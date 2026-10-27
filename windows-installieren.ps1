# Installiert oder aktualisiert Moodle Sync unter Windows, ohne dass Windows warnt
# («Der Computer wurde durch Windows geschützt»).
#
# Für Freunde: PowerShell öffnen (Start, «PowerShell» tippen, Enter), diese Zeile einfügen, Enter:
#
#   irm https://raw.githubusercontent.com/Vale1932/moodlesync-download/HEAD/windows-installieren.ps1 | iex
#
# Warum das hilft: SmartScreen prüft nur Dateien, die der Browser als «aus dem Internet geladen»
# markiert (Mark of the Web). Was PowerShell herunterlädt, ist nicht markiert. Der Installer ist
# derselbe wie im neusten Release. Später nochmals ausführen = Update.
#
# Die Quelle liegt im Projekt unter build/windows-installieren.ps1; ins öffentliche Download-Repo
# kopiert wird sie von Hand (build/README.md). $REPO muss zu DOWNLOAD_REPO in app/config.py passen.
#
# Alles steckt in & { … }, damit ein abgebrochener Download nichts Halbes ausführt.
# Kein «exit»: das würde das PowerShell-Fenster des Nutzers schliessen. Abbruch mit Fail + return.

& {
  $REPO = 'Vale1932/moodlesync-download'
  $APP = 'Moodle Sync'
  $DOWNLOAD_PAGE = "https://github.com/$REPO/releases/latest"
  $ErrorActionPreference = 'Stop'
  $ProgressPreference = 'SilentlyContinue'           # sonst lädt PowerShell 5 sehr langsam

  function Ok([string]$text) { Write-Host "  OK  $text" -ForegroundColor Green }

  function Fail([string]$text, [string]$hint) {
    Write-Host ""
    Write-Host "Das hat nicht geklappt: $text" -ForegroundColor Red
    if ($hint) { Write-Host $hint }
    Write-Host ""
  }

  Write-Host ""
  Write-Host "$APP wird installiert ..."

  if (-not [Environment]::Is64BitOperatingSystem) {
    Fail "$APP braucht ein 64-Bit-Windows (10 oder 11)." "Bitte melde dich bei der Person, von der du deine Lizenz hast."
    return
  }
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

  # Neustes Release über die GitHub-API finden (MSYNC_SETUP_URL nur für den Test im Workflow)
  $url = $env:MSYNC_SETUP_URL
  if (-not $url) {
    try {
      $release = Invoke-RestMethod -UseBasicParsing -Uri "https://api.github.com/repos/$REPO/releases/latest"
    } catch {
      Fail "Keine Verbindung zu GitHub." "Bitte Internet prüfen und den Befehl nochmals ausführen."
      return
    }
    $asset = $release.assets | Where-Object { $_.name -like '*-Setup-*.exe' } | Select-Object -First 1
    if (-not $asset) {
      Fail "Keine Windows-Version zum Herunterladen gefunden." "Download-Seite: $DOWNLOAD_PAGE"
      return
    }
    $url = $asset.browser_download_url
  }
  $name = Split-Path $url -Leaf
  $version = [IO.Path]::GetFileNameWithoutExtension($name) -replace '^.*-Setup-', ''
  Ok "Neuste Version: $version"

  $setup = Join-Path ([IO.Path]::GetTempPath()) $name
  try {
    if (Test-Path -LiteralPath $url) { Copy-Item -LiteralPath $url -Destination $setup -Force }
    else { Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $setup }
    Unblock-File -LiteralPath $setup                  # sicher ist sicher: keine Internet-Markierung
  } catch {
    Fail "Der Download wurde abgebrochen." "Bitte Internet prüfen und den Befehl nochmals ausführen."
    return
  }
  Ok "Heruntergeladen"

  # Laufende App beenden, damit der Installer die Dateien ersetzen kann
  $running = Get-Process -Name $APP, 'moodlesync' -ErrorAction SilentlyContinue
  if ($running) {
    $running | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Ok "Offene App beendet"
  }

  Write-Host "  ..  Wird installiert (ein kleines Fenster zeigt den Fortschritt)"
  try {
    $p = Start-Process -FilePath $setup -ArgumentList '/SILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/SP-' -Wait -PassThru
  } catch {
    Fail "Der Installer liess sich nicht starten." "Download-Seite: $DOWNLOAD_PAGE"
    return
  } finally {
    Remove-Item -LiteralPath $setup -ErrorAction SilentlyContinue
  }
  $exe = Join-Path $env:LOCALAPPDATA "Programs\$APP\$APP.exe"
  if ($p.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $exe)) {
    Fail "Die Installation wurde abgebrochen (Code $($p.ExitCode))." "Bitte den Befehl nochmals ausführen."
    return
  }
  Ok "Installiert"

  Start-Process -FilePath $exe
  Write-Host ""
  Write-Host "Fertig! $APP $version startet jetzt."
  Write-Host "Künftig öffnest du es über das Startmenü oder das Symbol auf dem Desktop."
  Write-Host "Für ein Update später einfach denselben Befehl nochmals ausführen."
  Write-Host ""
}
