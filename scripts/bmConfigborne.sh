#!/bin/bash

# Définition des locales
export LANG=fr_FR.UTF-8

# ======================================================================
#Chargement librairie
# ======================================================================

repinstallation="/opt/borne"

[ ! -f $repinstallation/scripts/bmLib.sh ] && logger -p local0.crit 'Impossible de trouver la bibliothèque standard. Abandon.' && exit 1
. $repinstallation/scripts/bmLib.sh

#[ ! -f /usr/bin/CTparental ] && logger -p local0.crit 'Impossible de trouver la bibliothèque CTparental. Abandon.' && exit 1
#. /usr/bin/CTparental

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
			false "Installer le filtrage" \
			false "Créer une clé USB" \
			false "Modifier mot de passe gestionnaire")
fi

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
	echo "# Vérification des mises à jour" ; apt update
	echo "20" ; sleep 1
	echo "# Application des mises à jour" ; apt full-upgrade -y
	echo "40" ; sleep 1
	echo "# Mise à jour" ; apt install -f
	echo "60" ; sleep 1
	echo "# Maj Solibuntu"
	echo "90" ; /opt/borne/scripts/install.sh
	nohup xterm &
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
	#nohup xterm &
	;;

	"Installer le filtrage|")
	/opt/borne/scripts/filtrage_install.sh
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
	"Modifier mot de passe gestionnaire|")
		entr=`zenity --forms \
			--title="Changement du mot de passe" \
			--text="Définir un nouveau mot de passe" \
			--add-password="Nouveau mot de passe" \
			--add-password="Confirmer le nouveau mot de passe" \
			-- separator="|"`
	
		if [ $? == 0 ]; then
			pass=`echo $entr | cut -d'|' -f1`
			passverif=`echo $entr | cut -d'|' -f2`
			if [ $pass == $passverif ]; then
				testSecu $pass
				if [ 0 == 0 ]; then
					testDispo $pass
					if [ $? == 0 ] ; then
					zenity --question --text "Voulez-vous vraiment modifier le mot de passe gestionnaire ?"
						if [ $? == 0 ] ; then
							echo -e "$pass\n$pass" | passwd gestionnaire
							# Fouiller dans fonction debconfadminhttp() de /usr/bin/CTparental
							#CTparental -setadmin gestionnaire $pass
							zenity --info --text="Le mot de passe a été modifié avec succès"
						fi
					else
						zenity --error
					fi
				else
					zenity --info --text="Le mot de passe n'est pas assez fort, il doit contenir au moins 8 caractères dont au minimum une lettre majuscule, minuscule, un chiffre et un caractère spécial"
				fi
			else
				zenity --info --text="Les mots de passe doivent être identiques !"
			fi
		fi
	;;
  esac

exit 0