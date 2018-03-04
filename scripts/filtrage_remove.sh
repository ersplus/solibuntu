#!/bin/bash

# ======================================================================
# Script de suppression du filtrage
# ======================================================================

repinstallation="/opt/borne"


[ `whoami` = root ] || { gksudo "$0" "$@"; exit $?; }

# ======================================================================
# test de présence du filtrage
# ======================================================================

if (test -f "/usr/sbin/dansguardian"); then
			zenity --question --text="Etês vous sûr de vouloir supprimer totalement le filtrage de cet ordinateur ?"
			apt-get autoremove --purge ctparental clamav-* privoxy dansguardian dnsmasq -y
			sudo rm -rf /etc/CTparental && rm -rf /etc/dansguardian && rm -rf /etc/squid
			sudo apt-get autoremove	
			sudo cp -rf /opt/borne/share/proxy/defaultoff /etc/chromium-browser/default
			# Message d'information
			zenity --info="Le filtrage a été supprimé. L'ordinateur va redémarrer"
			# Redémarrage
			reboot

else zenity --info --text="Le filrage n'est pas installé !"

fi

exit 0
