#!/bin/bash

# ======================================================================
# Script de suppression du filtrage
# ======================================================================

repinstallation="/opt/borne"


[ `whoami` = root ] || { gksudo "$0" "$@"; exit $?; }

# ======================================================================
# test de présence du filtrage
# ======================================================================


apt-get autoremove --purge ctparental clamav-* privoxy dansguardian dnsmasq -y
sudo rm -rf /etc/CTparental && rm -rf /etc/dansguardian && rm -rf /etc/squid
sudo apt-get autoremove	
sudo cp -rf /opt/borne/share/proxy/defaultoff /etc/chromium-browser/default
rm /etc/firefox/syspref.js
mv /etc/firefox/syspref.js.back /etc/firefox/syspref.js
# Message d'information
zenity --info="Le filtrage a été supprimé. L'ordinateur va redémarrer"
# Redémarrage
touch /root/.filtragepurged
reboot


exit 0
