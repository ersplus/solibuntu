#!/bin/bash

# ======================================================================
# Script de fin de sesion
# ======================================================================

repinstallation="/opt/borne"


# On vérifie la valeur contenue dans le fichier lastadminlogin
# Si 1 alors la dernière session était admin

# Le fichier /root/.lastadminlogin est géré par sessionStart.sh ; aucune lecture nécessaire ici

# Test
# Si la valeur est de 1 alors

	if [ -f /root/.lastadminlogin ]; then
		cp $repinstallation/scripts/lightdm.conf.d/* /etc/lightdm/lightdm.conf.d
		echo "0" > /root/.lastadminlogin
		pkill bmGreeter.sh
		pkill lightdm
		exit 1
	else
	zenity --info --text "Le fichier n'est pas la"
	fi

exit 0
