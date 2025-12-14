#!/bin/bash

# ======================================================================
# Script de la charte
# ======================================================================

FILE="/opt/borne/share/charte.html"

# La fleche pour le pointeur de la souris
# xsetroot -cursor_name left_ptr &



zenity --text-info --title="Charte d’utilisation" --html --filename=$FILE \
--checkbox="En cochant cette case, je confirme avoir pris connaissance de la charte d'utilisation du réseau." 

	case $? in
		0)  exec /usr/lib/lightdm/lightdm-guest-session "$@"
			exit 0
			;;
		-1)	zenity --error --title="Attention" --text="Une erreur est survenue."
			reboot
			;;
	esac
	
exit 0
