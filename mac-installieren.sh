#!/bin/bash
# Installiert oder aktualisiert Moodle Sync auf dem Mac, ohne dass macOS die App sperrt
# («Apple konnte nicht überprüfen …» bzw. «… kann nicht nach Schadsoftware suchen»).
#
# Für Freunde: Terminal öffnen, diese eine Zeile einfügen, Enter drücken:
#
#   curl -fsSL https://raw.githubusercontent.com/Vale1932/moodlesync-download/HEAD/mac-installieren.sh | bash
#
# Warum das hilft: Gatekeeper prüft nur Dateien, die der Browser als «aus dem Internet geladen»
# markiert (com.apple.quarantine). curl setzt diese Markierung nicht. Die App ist dieselbe wie
# in der .dmg des neusten Releases. Später nochmals ausführen = Update.
#
# Die Quelle liegt im Projekt unter build/mac-installieren.sh; ins öffentliche Download-Repo
# kopiert wird sie von Hand (build/README.md). REPO muss zu DOWNLOAD_REPO in app/config.py passen.
#
# Alles steckt in main(), damit ein abgebrochener Download nichts Halbes ausführt.

REPO="Vale1932/moodlesync-download"
APP="Moodle Sync"
DOWNLOAD_PAGE="https://github.com/$REPO/releases/latest"

TMP_DIR=""
MNT=""
OLD_APP=""
DEST=""

ok() { printf '  \033[32m✓\033[0m %s\n' "$1"; }

fail() {
  printf '\n\033[31mDas hat nicht geklappt:\033[0m %s\n' "$1" >&2
  [ -n "${2:-}" ] && printf '%s\n' "$2" >&2
  printf '\n' >&2
  exit 1
}

cleanup() {
  if [ -n "$MNT" ]; then
    hdiutil detach "$MNT" -quiet -force >/dev/null 2>&1 || true
  fi
  # Nach einem Fehler beim Kopieren die alte Version zurücklegen
  if [ -n "$OLD_APP" ] && [ -d "$OLD_APP" ] && [ ! -e "$DEST/$APP.app" ]; then
    mv "$OLD_APP" "$DEST/$APP.app" 2>/dev/null || true
  fi
  if [ -n "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR" 2>/dev/null || true
  fi
}

main() {
  set -euo pipefail
  PATH="/usr/bin:/bin:/usr/sbin:/sbin"
  trap cleanup EXIT

  echo ""
  echo "Moodle Sync wird installiert …"

  [ "$(uname -s)" = "Darwin" ] || fail "Dieser Befehl ist nur für den Mac."
  [ "$(sysctl -n hw.optional.arm64 2>/dev/null || echo 0)" = "1" ] || \
    fail "Moodle Sync läuft nur auf Macs mit Apple-Chip (M1 oder neuer)." \
         "Bitte melde dich bei der Person, von der du deine Lizenz hast."

  # Neustes Release über die GitHub-API finden. MSYNC_DMG_URL (file://…): schon geladene .dmg –
  # so ruft «Jetzt aktualisieren» in der App dieses Skript auf (app/updates.py), ebenso der Workflow-Test
  local info url version
  url="${MSYNC_DMG_URL:-}"
  if [ -z "$url" ]; then
    info=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest") || \
      fail "Keine Verbindung zu GitHub." "Bitte Internet prüfen und den Befehl nochmals ausführen."
    url=$(printf '%s\n' "$info" | grep -o '"browser_download_url": *"[^"]*\.dmg"' | head -n 1 \
          | sed 's/.*"\(https:[^"]*\)"$/\1/') || true
  fi
  [ -n "$url" ] || fail "Keine Mac-Version zum Herunterladen gefunden." "Download-Seite: $DOWNLOAD_PAGE"
  version=$(basename "$url" .dmg)
  version=${version##*-}
  ok "Neuste Version: $version"

  TMP_DIR=$(mktemp -d -t moodlesync)
  curl -fL --progress-bar -o "$TMP_DIR/app.dmg" "$url" || \
    fail "Der Download wurde abgebrochen." "Bitte Internet prüfen und den Befehl nochmals ausführen."
  ok "Heruntergeladen"

  mkdir "$TMP_DIR/mnt"
  hdiutil attach "$TMP_DIR/app.dmg" -nobrowse -readonly -noautoopen -mountpoint "$TMP_DIR/mnt" >/dev/null || \
    fail "Die heruntergeladene Datei lässt sich nicht öffnen." "Bitte den Befehl nochmals ausführen."
  MNT="$TMP_DIR/mnt"
  [ -d "$MNT/$APP.app" ] || fail "In der heruntergeladenen Datei fehlt die App." "Download-Seite: $DOWNLOAD_PAGE"

  # Ziel: wo die App schon liegt, sonst «Programme» (ohne Adminrechte: «Programme» im Benutzerordner)
  local d
  for d in "/Applications" "$HOME/Applications"; do
    if [ -d "$d/$APP.app" ] && [ -w "$d" ]; then DEST="$d"; break; fi
  done
  if [ -z "$DEST" ]; then
    if [ -w "/Applications" ]; then DEST="/Applications"; else DEST="$HOME/Applications"; mkdir -p "$DEST"; fi
  fi

  # Laufende App beenden, sonst öffnet sich am Ende wieder die alte Version
  if pgrep -xq "$APP"; then
    pkill -x "$APP" 2>/dev/null || true
    local i
    for i in 1 2 3 4 5; do pgrep -xq "$APP" || break; sleep 1; done
    ok "Offene App beendet"
  fi

  if [ -e "$DEST/$APP.app" ]; then
    OLD_APP="$TMP_DIR/alte-version.app"
    mv "$DEST/$APP.app" "$OLD_APP" 2>/dev/null || {
      OLD_APP=""
      fail "Die bisherige Version lässt sich nicht ersetzen." \
           "Bitte «$APP» aus dem Ordner «Programme» in den Papierkorb ziehen und den Befehl nochmals ausführen."
    }
  fi
  ditto "$MNT/$APP.app" "$DEST/$APP.app" || {
    rm -rf "$DEST/$APP.app" 2>/dev/null || true
    fail "Die App liess sich nicht nach $DEST kopieren." "Bitte den Befehl nochmals ausführen."
  }
  xattr -dr com.apple.quarantine "$DEST/$APP.app" 2>/dev/null || true
  if [ "$DEST" = "/Applications" ]; then ok "In «Programme» installiert"; else ok "Installiert in $DEST"; fi

  open "$DEST/$APP.app" || true
  echo ""
  echo "Fertig! Moodle Sync $version startet jetzt."
  echo "Künftig öffnest du es über das Launchpad oder den Ordner «Programme»."
  echo "Für ein Update später einfach denselben Befehl nochmals ausführen."
  echo ""
}

main "$@"
