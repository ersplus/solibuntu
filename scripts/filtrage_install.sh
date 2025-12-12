#!/bin/bash
set -euo pipefail

repinstallation="/opt/borne"

# Assurez-vous d'être root ; sinon relancer avec sudo
if [ "$(id -u)" -ne 0 ]; then
  echo "Relance avec sudo..." >&2
  exec sudo "$0" "$@"
fi

install_ctparental() {
  local deb
  deb="$repinstallation/share/ctparental.deb"

  # Appliquer les debconf selections si présentes
  if [ -f "$repinstallation/share/setselection.txt" ] && command -v debconf-set-selections >/dev/null 2>&1; then
    while IFS= read -r line; do
      echo "$line" | debconf-set-selections
    done < "$repinstallation/share/setselection.txt"
  fi

  # Si le paquet local n'existe pas, tenter un téléchargement de secours
  if [ ! -f "$deb" ]; then
    echo "Paquet local CTparental introuvable: $deb"
    # URL de secours — adapter si vous avez une URL officielle pour bionic
    CT_URL="https://gitlab.com/marsat/CTparental/-/releases/latest/download/ctparental_bionic_all.deb"
    mkdir -p "$repinstallation/share"
    if command -v curl >/dev/null 2>&1; then
      if ! curl -fSL -o "$deb" "$CT_URL"; then
        echo "Échec du téléchargement depuis $CT_URL" >&2
        return 2
      fi
    elif command -v wget >/dev/null 2>&1; then
      if ! wget -O "$deb" "$CT_URL"; then
        echo "Échec du téléchargement depuis $CT_URL" >&2
        return 2
      fi
    else
      echo "Ni curl ni wget disponibles pour télécharger CTparental" >&2
      return 2
    fi
  fi

  # Installer gdebi-core pour installation non interactive si besoin
  if ! dpkg -s gdebi-core >/dev/null 2>&1; then
    apt-get update -y || true
    apt-get install -y gdebi-core || true
  fi

  # Installer le paquet avec gdebi si présent, sinon dpkg + apt-get -f install
  if command -v gdebi >/dev/null 2>&1; then
    gdebi -n "$deb"
    return $?
  else
    if dpkg -i "$deb"; then
      return 0
    else
      apt-get install -f -y
      dpkg -i "$deb" || return 3
    fi
  fi
}

main() {
  local result=0

  (
    echo "10"
    echo "# Vérification des mises à jour"
    apt update -y >/dev/null 2>&1 || true
    echo "30"
    echo "# Installation des dépendances requises"
    apt-get install -y debconf-utils curl >/dev/null 2>&1 || true
    echo "50"
    echo "# Installation CTparental"
    install_ctparental
    result=$?
    echo "80"
    if [ "$result" -eq 0 ]; then
      echo "# Installation terminée avec succès"
    else
      echo "# Erreur lors de l'installation (code $result)"
    fi
    echo "99"
  ) | zenity --progress --title="Progression de installation" --text="Installation du filtrage..." --width=500 --percentage=0

  return $result
}

main "$@"
