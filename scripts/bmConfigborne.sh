#!/bin/bash

# Définition des locales
export LANG=fr_FR.UTF-8

# ======================================================================
# Script de gestion du mode de filtrage
# ======================================================================

repinstallation="/opt/borne"

# largeur de l'écran
largeurEcran=$(xwininfo -root | awk '$1=="Width:" {print $2}')

# Hauteur de l'écran
hauteurEcran=$(xwininfo -root | awk '$1=="Height:" {print $2}')

# ======================================================================
# Ecran configuration
# ======================================================================

reponse=$(yad --width=$largeurEcran --height=$hauteurEcran \
		--title="Configuration" --text="Ecran de configuration de l'ordinateur Solibuntu. Veuillez choisir une option ci-dessous :" \
		--image=info --image-on-top \
		--list --radiolist --no-headers \
		--column 1 --column 2 --print-column=2 \
		--margins="400" \
		true  "Arrêter l'ordinateur" \
		false "Redémarrer l'ordinateur" \
		false "Mettre à jour et redémarrer" \
		false "Configurer l'ordinateur" \
		false "Créer une clé USB")

  case ${reponse} in
	"Arrêter l'ordinateur|")
	sudo halt
	;;
	"Redémarrer l'ordinateur|")
	sudo reboot
	;;
	"Mettre à jour et redémarrer|")
	(
	echo "10" ; sleep 1
	echo "# Vérification des mises à jour" ; sudo apt update
	echo "20" ; sleep 1
	echo "# Application des mises à jour" ; sudo apt upgrade -y
	echo "50" ; sleep 1
	echo "# Mise à jour" ; sudo apt clean
	echo "75" ; sleep 1
	echo "# Redémarrage du système" ; sudo reboot
	echo "99" ; sleep 1
	) |
	zenity --progress \
	  --title="Mise à jour du système" \
	  --text="Vérification des mises à jour..." \
	  --percentage=0

	if [ "$?" = -1 ] ; then
			zenity --error --text="Mise à jour de l'ordinateur annulée."
	fi
	;;
	"Configurer l'ordinateur|")
	cp -i $repinstallation/scripts/lightdm.conf.d/50-logout-restoreinvite.conf /etc/lightdm/lightdm.conf.d/
	rm /etc/lightdm/lightdm.conf.d/50-auto-guest.conf
	rm /etc/lightdm/lightdm.conf.d/50-guest-wrapper.conf
	pkill bmGreeter.sh
	pkill lightdm
	;;
	"Créer une clé USB|")	
	# Message pour l'utilisateur
	yad --text="Veuillez connecter la clé USB que vous désirez associer à cet ordinateur pour pouvoir le dévérrouiller.\n\n Cliquez sur <b>Suivant</b>." --form --buttons-layout=edge --button="Annuler":1 --button="Suivant":0

	if [ $? -eq 0 ] ; then
		
		serialPc=$(dmidecode -s system-serial-number)
		udevadm info --name=/dev/sdb > /dev/null 2>&1 
		
		if [ $? -eq 0 ]; then
			
			# Reccuperation du numéro de série de la clé USB
			serialKey=$(udevadm info --name=/dev/sdb | grep SERIAL_SHORT| cut -d= -f2)
			
			# On stocke l'identifiant de la clé dans un fichier
			# ce fichier est écrasé lors de la création d'une nouvelle clé
			echo $serialPc:$serialKey > /root/.uniqUSBKEY
			
			# Création regle UDEV
			fichierRule="/etc/udev/rules.d/99-usbsources.rules"
			echo "ACTION==\"remove\", ENV{ID_SERIAL_SHORT}==\"${serialKey}\", RUN+=\"${repinstallation}/scripts/bmUsbout.sh\"" > $fichierRule 
			
			# On recharge les règles UDEV
			udevadm control --reload
			
			# Message d'information
			zenity --info --text="La clé USB est opérationnelle, vous pouvez désormais l'utiliser pour déverrouiller cet ordinateur."
			exit
		fi
	fi

	ret=2
	;;
  esac

exit 0
