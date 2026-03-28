#!/bin/bash

repinstallation="/opt/borne"

. "$repinstallation/scripts/libRootGui.sh"
solibuntu_ensure_root

. "$repinstallation/scripts/libChromiumProxy.sh"

# ======================================================================
# Script de suppression du filtrage
# ======================================================================

if [ ! -f /usr/bin/CTparental ] && [ ! -f /usr/bin/ctparental ]; then
	zenity --info --text="Le filtrage n'est pas installé !"
	exit 0
fi

if ! zenity --question --text="Êtes-vous sûr de vouloir supprimer totalement le filtrage de cet ordinateur ?"; then
	exit 0
fi

apt-get purge -y ctparental privoxy dansguardian dnsmasq 2>/dev/null || true
mapfile -t _clam < <(dpkg-query -W -f '${Package}\n' 2>/dev/null | grep -E '^clamav' || true)
[ "${#_clam[@]}" -gt 0 ] && apt-get purge -y "${_clam[@]}" 2>/dev/null || true

rm -rf /etc/CTparental /etc/dansguardian /etc/squid 2>/dev/null || true
apt-get autoremove -y

solibuntu_chromium_proxy_apply off

if [ -f /etc/firefox/syspref.js.back ]; then
	rm -f /etc/firefox/syspref.js
	mv -f /etc/firefox/syspref.js.back /etc/firefox/syspref.js
fi

zenity --info --text="Le filtrage a été supprimé. L'ordinateur va redémarrer."
touch /root/.filtragepurged
reboot

exit 0
