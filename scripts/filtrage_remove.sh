#!/bin/bash

# ======================================================================
# Script de suppression du filtrage
# ======================================================================

repinstallation="/opt/borne"

[ "$(id -u)" -eq 0 ] || exec sudo -E "$0" "$@"

# ======================================================================
# Suppression du filtrage
# ======================================================================

apt-get autoremove --purge ctparental clamav-* privoxy dansguardian dnsmasq -y || true
rm -rf /etc/CTparental /etc/dansguardian /etc/squid
apt-get autoremove -y || true

if [ -d /etc/chromium-browser ]; then
	cp -rf "$repinstallation/share/proxy/defaultoff" /etc/chromium-browser/default
fi

if [ -f /etc/firefox/syspref.js ]; then
	rm /etc/firefox/syspref.js
fi
if [ -f /etc/firefox/syspref.js.back ]; then
	mv /etc/firefox/syspref.js.back /etc/firefox/syspref.js
fi

# Message d'information
zenity --info="Le filtrage a été supprimé. L'ordinateur va redémarrer"

# Redémarrage
touch /root/.filtragepurged
reboot

exit 0
