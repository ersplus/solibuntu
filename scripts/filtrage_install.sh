#!/bin/bash

# ======================================================================
# Script d'installation du filtrage
# ======================================================================

repinstallation="/opt/borne"

[ `whoami` = root ] || { gksudo "$0" "$@"; exit $?; }

(
	echo "10" ; sleep 1
	echo "# Vérification des mises à jour" ; sudo apt update
	echo "20" ; sleep 1
	echo "# Application des mises à jour" ; sudo apt upgrade -y
	echo "30" ; sleep 1
	echo "# Mise à jour" ; sudo apt clean
	echo "40" ; sleep 1
	echo "# Installation filtrage" ; sudo gdebi-gtk --auto-close /opt/borne/share/ctparental_ubuntu16.04_4.21.06-1.0_all.deb
	echo "70" ; sleep 1
	echo "# Configuation du proxy" ; sudo cp -rf /opt/borne/share/proxy/defaulton /etc/chromium-browser/default
	echo "80" ; sleep 1
	echo "# Fin de l'installation" ;
	echo "99" ; sleep 1
	) |
	zenity --progress \
	  --title="Progression de installation" \
	  --text="Installation du filtrage..." \
	  --percentage=0

	if [ "$?" = -1 ] ; then
			zenity --error --text="Installation annulée."
	fi



exit 0
