#!/bin/bash

# ======================================================================
# Script de fin de sesion
# ======================================================================

repinstallation="/opt/borne"

# On vérifie la valeur contenue dans le fichier lastadminlogin
# Si 1 alors la dernière session était admin

adminConnect=$(cat /root/.lastadminlogin 2>/dev/null || echo "")

# Test
# Si la valeur est de 1 alors

if [ -f "/root/.lastadminlogin" ]; then
	cp -f "$repinstallation/scripts/lightdm.conf.d/"* /etc/lightdm/lightdm.conf.d/
	echo "0" > /root/.lastadminlogin
	pkill bmGreeter.sh
	pkill lightdm
	exit 1
else
	zenity --info --text "Le fichier n'est pas là"
fi

exit 0
