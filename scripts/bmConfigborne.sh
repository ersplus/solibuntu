#!/bin/bash

# Définition des locales
export LANG=fr_FR.UTF-8

# ======================================================================
#Chargement librairie
# ======================================================================

repinstallation="/opt/borne"

[ ! -f $repinstallation/scripts/bmLib.sh ] && logger -p local0.crit 'Impossible de trouver la bibliothèque standard. Abandon.' && exit 1
. $repinstallation/scripts/bmLib.sh

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

# Choix gestionnaire
if [ $1 == "gestionnaire" ] ; then
	reponse=$(yad --width=$largeurEcran --height=$hauteurEcran \
			--title="Configuration" --text="Ecran de configuration de l'ordinateur Solibuntu. Veuillez choisir une option ci-dessous :" \
			--image=info --image-on-top \
			--list --radiolist --no-headers \
			--column 1 --column 2 --print-column=2 \
			--margins="400" \
			true  "Arrêter l'ordinateur" \
			false "Redémarrer l'ordinateur" \
			false "Configurer l'ordinateur" \
			false "Créer une clé USB")

# Choix administrateur
elif [ $1 == "administrateur" ] ; then
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
			false "Filtrage" \
			false "Créer une clé USB" \
			false "Modifier les mots de passe")

fi

  case ${reponse} in
	"Arrêter l'ordinateur|")
	# Arrête l'ordinateur
	poweroff
	;;
	"Redémarrer l'ordinateur|")
	# Redémarre l'ordinateur
	reboot
	;;
	"Mettre à jour et redémarrer|")
	(
	echo "10" ; sleep 1
	echo "# Vérification des mises à jour" ; apt update
	echo "20" ; sleep 1
	echo "# Application des mises à jour" ; apt full-upgrade -y
	echo "40" ; sleep 1
	echo "# Mise à jour" ; apt install -f
	echo "60" ; sleep 1
	echo "# Maj Solibuntu"
	echo "90" ;
		# Lance le script d'installation
		cd /Solibuntu
		./install.sh maj
	echo "# Mise à jour" ; apt autoremove --purge -y
	echo "95" ; sleep 1
	echo "# Redémarrage du système" ; reboot
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
	service lightdm restart
	;;

	"Filtrage|")
		# Lance le script d'installation du filtrage
		if (test -f "/usr/bin/CTparental"); then
			zenity --question --text="Un filtrage est installé, désirez-vous le supprimer ?" --ok-label "Oui" --cancel-label="Non"
			if [ $? == 0 ] ; then
				/opt/borne/scripts/filtrage_remove.sh
			else
				zenity --info --text="Le filtrage n'a pas été désinstallé sur votre système."
			fi
		else
			zenity --question --text="Aucun filtrage n'est installé, désirez-vous en installer un ?" --ok-label "Oui" --cancel-label="Non"
			if [ $? == 0 ] ; then
				/opt/borne/scripts/filtrage_install.sh
		        if [ $? == 0 ] ; then
		            zenity --info --width=300 --text "Le filtrage a bien été installé \n \
Votre ordinateur va redémarrer"
		            #zenity --info --width=300 --text "Votre ordinateur va redémarrer"
		        else
		            zenity --info --width=300 --text "Une erreur s'est produite \n \
Votre ordinateur va redémarrer"
		        fi
        		reboot
			else
				zenity --info --text="Le filtrage n'a pas été installé sur votre système."
			fi
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
	"Modifier les mots de passe|")
		# Appel la fonction de changement des mots de passe
		changerMdp "administrateur" "gestionnaire"
	;;
  esac

exit 0