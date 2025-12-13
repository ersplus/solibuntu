#!/bin/bash

# Script pour télécharger et installer Solibuntu depuis la pré-release Dev
# Utilisation: sudo ./install_dev_release.sh

set -e

REPO="ersplus/solibuntu"
TEMP_DEB="/tmp/solibuntu_dev.deb"

echo "Solibuntu Dev - Installation depuis pré-release"
echo "================================================"

if [ "$(id -u)" -ne 0 ]; then
  echo "Ce script doit être exécuté en tant que root" >&2
  exit 1
fi

echo "Récupération du dernier .deb de la pré-release Dev..."
DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/${REPO}/releases" | \
  jq -r 'first(.[] | select(.prerelease == true) | .assets[] | select(.name | endswith(".deb")) | .browser_download_url)')

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Erreur: aucun .deb trouvé dans les pré-releases Dev" >&2
  exit 1
fi

echo "Téléchargement de: $DOWNLOAD_URL"
curl -L -o "$TEMP_DEB" "$DOWNLOAD_URL"

echo "Installation du paquet..."
dpkg -i "$TEMP_DEB" || apt-get install -f -y

echo "Nettoyage..."
rm -f "$TEMP_DEB"

echo ""
echo "Installation terminée!"
echo "Vérifications recommandées:"
echo "  - LightDM: vérifier /etc/lightdm/lightdm.conf.d/"
echo "  - Autostart: ls /etc/xdg/autostart/sessionStart.desktop"
echo "  - Comptes: id administrateur && id gestionnaire"
echo "  - Filtrage (optionnel): sudo /opt/borne/scripts/filtrage_install.sh"

exit 0
