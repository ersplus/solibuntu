#! /bin/bash
# Installer de façon sûre la liste de paquets adaptée pour Xubuntu 24.04 (Noble)
# - active universe/multiverse
# - pré-seed EULA pour ttf-mscorefonts-installer
# - vérifie la disponibilité des paquets avant installation
set -euo pipefail
IFS=$'\n\t'

if [ "$(id -u)" -ne 0 ]; then
  echo "Ce script doit être exécuté en root."
  exit 1
fi

# Liste désirée (exfatprogs remplace exfat-utils)
desired=(
  exfatprogs feh yad imagemagick xsane
  ttf-mscorefonts-installer
  hplip hplip-data hplip-gui hpijs-ppds printer-driver-hpcups printer-driver-hpijs printer-driver-pxljr
  gdebi
  firefox-locale-fr
  aspell-fr myspell-fr
  printer-driver-cups-pdf
  synapse seahorse thunderbird transmission pidgin
  gnome-sudoku gnome-mines sgt-launcher sgt-puzzles
)

echo "Vérification et activation des dépôts universe/multiverse..."
# add-apt-repository se trouve dans software-properties-common
if ! command -v add-apt-repository >/dev/null 2>&1; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common
fi

add-apt-repository -y universe || true
add-apt-repository -y multiverse || true
apt-get update

# Pré-seed pour la EULA des Microsoft fonts
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections || true

available=()
missing=()

echo "Vérification de la disponibilité des paquets dans les dépôts..."
for pkg in "${desired[@]}"; do
  # apt-cache policy renvoie Candidate: (vide si absent)
  if apt-cache policy "$pkg" | grep -q 'Candidate:'; then
    # Candidate peut être (none) — vérifier aussi
    cand=$(apt-cache policy "$pkg" | awk '/Candidate:/ {print $2}')
    if [ -n "$cand" ] && [ "$cand" != "(none)" ]; then
      available+=("$pkg")
      echo "  OK : $pkg (candidate: $cand)"
    else
      missing+=("$pkg")
      echo "  MANQUANT : $pkg (aucun candidate)"
    fi
  else
    missing+=("$pkg")
    echo "  MANQUANT : $pkg"
  fi
done

if [ "${#missing[@]}" -ne 0 ]; then
  echo
  echo "ATTENTION - paquets non trouvés dans les dépôts actuels :"
  printf "  %s\n" "${missing[@]}"
  echo "Vous pouvez activer des dépôts additionnels ou corriger les noms si nécessaire."
fi

if [ "${#available[@]}" -eq 0 ]; then
  echo "Aucun paquet disponible à l'installation. Fin."
  exit 1
fi

echo
echo "Installation des paquets disponibles (${#available[@]})..."
DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends "${available[@]}"

# Note pour Firefox Snap (Ubuntu installe souvent Firefox en snap)
if snap list firefox >/dev/null 2>&1; then
  echo
  echo "Note : Firefox est installé en tant que snap sur ce système."
  echo "Le paquet firefox-locale-fr s'applique au paquet deb. Pour le snap, la gestion des langues est différente."
fi

echo
echo "Installation terminée."
if [ "${#missing[@]}" -ne 0 ]; then
  echo "Paquets manquants (non installés) :"
  printf "  %s\n" "${missing[@]}"
else
  echo "Tous les paquets demandés ont été installés."
fi

exit 0
