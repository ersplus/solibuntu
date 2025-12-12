#!/bin/bash
set -euo pipefail

LOG=/var/log/filtrage_remove.log
repinstallation="/opt/borne"

log() {
  echo "$(date --iso-8601=seconds) $*" | tee -a "$LOG"
}

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    exec sudo "$0" "$@"
  else
    echo "This script must be run as root." >&2
    exit 1
  fi
fi

# Determine UI availability
USE_ZENITY=0
if command -v zenity >/dev/null 2>&1 && [ -n "$DISPLAY" ]; then
  USE_ZENITY=1
fi

# Confirmation prompt function
confirm() {
  local prompt="${1:-Confirmer ?}"
  if [ "$USE_ZENITY" -eq 1 ]; then
    zenity --question --title="Confirmation" --text="$prompt" 2>/dev/null
    return $?
  else
    read -r -p "$prompt [y/N]: " ans
    case "$ans" in
      [Yy]|[Yy][Ee][Ss]) return 0 ;;
      *) return 1 ;;
    esac
  fi
}

# Check installed packages to remove (common names)
CANDIDATES=(ctparental ctparental-daemon ctparental-core ctparental-* privoxy dansguardian dnsmasq squid clamav dansguardian-common)
TO_REMOVE=()
for pkg in "${CANDIDATES[@]}"; do
  # direct check
  if dpkg-query -W -f='${Package}\n' "$pkg" 2>/dev/null | grep -q .; then
    TO_REMOVE+=("$pkg")
  else
    # handle glob-like entries by matching installed packages
    matches=$(dpkg-query -W -f='${Package}\n' 2>/dev/null | grep -E "^${pkg//\*/.*}$" || true)
    if [ -n "$matches" ]; then
      while IFS= read -r m; do TO_REMOVE+=("$m"); done <<<"$matches"
    fi
  fi
done

if [ ${#TO_REMOVE[@]} -eq 0 ]; then
  log "Aucun paquet CTparental détecté sur le système. Rien à faire."
  if [ "$USE_ZENITY" -eq 1 ]; then
    zenity --info --title="Suppression du filtrage" --text="Le filtrage CTparental ne semble pas être installé." || true
  else
    echo "Le filtrage CTparental ne semble pas être installé."
  fi
  exit 0
fi

log "Paquets détectés pour suppression: ${TO_REMOVE[*]}"

if ! confirm "Voulez-vous supprimer le filtrage et les paquets suivants ?\n${TO_REMOVE[*]}"; then
  log "Suppression annulée par l'utilisateur"
  exit 1
fi

# Perform purge
log "Exécution de apt-get purge --auto-remove -y ${TO_REMOVE[*]}"
apt-get update -y || true
if ! apt-get purge --auto-remove -y "${TO_REMOVE[@]}"; then
  log "Une erreur est survenue lors de la suppression des paquets"
  # try to continue with best effort
fi

# Cleanup config directories
for d in /etc/CTparental /etc/dansguardian /etc/squid /var/lib/ctparental; do
  if [ -d "$d" ]; then
    log "Suppression du répertoire $d"
    rm -rf "$d"
  fi
done

# Restore Firefox syspref if backup exists
if [ -f /etc/firefox/syspref.js.back ]; then
  log "Restauration de /etc/firefox/syspref.js à partir de la sauvegarde"
  mv -f /etc/firefox/syspref.js.back /etc/firefox/syspref.js || log "Impossible de restaurer /etc/firefox/syspref.js"
elif [ -f /etc/firefox/syspref.js ]; then
  log "Suppression de /etc/firefox/syspref.js modifiée par le filtrage"
  rm -f /etc/firefox/syspref.js
fi

# Restore chromium proxy default if present in repo
if [ -f "$repinstallation/share/proxy/defaultoff" ]; then
  log "Restauration du proxy Chromium par défaut"
  cp -f "$repinstallation/share/proxy/defaultoff" /etc/chromium-browser/default || log "Impossible de copier le fichier proxy par défaut"
fi

# Create marker file
echo "$(date --iso-8601=seconds) Purged: ${TO_REMOVE[*]}" > /root/.filtragepurged
log "Marqueur /root/.filtragepurged créé"

# Prompt for reboot
if confirm "Suppression terminée. Souhaitez-vous redémarrer maintenant ?"; then
  log "Redémarrage demandé par l'utilisateur"
  reboot
else
  log "Redémarrage non demandé"
fi

log "Fin du script"
exit 0
