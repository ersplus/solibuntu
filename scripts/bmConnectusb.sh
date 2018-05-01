#!/bin/bash


# ======================================================================
# Fonction de vérification de la clé
# ======================================================================

getUsbkey() {
if  !  udevadm info --name=/dev/sdb > /dev/null 2>&1 ; then
	# pas de cle / affichage page accueil
		ret=2
else

	# identification de la cle detenant
	# les donnees sources (identifiants uniques)

	# au moins une clé est branchée
	serialPc=$(dmidecode -s system-serial-number)

	serialKeyB=$(udevadm info --name=/dev/sdb | grep SERIAL_SHORT| cut -d= -f2)
	echo $serialPc:$serialKeyB > /tmp/.KEYB
	
		if  diff /tmp/.KEYB /root/.uniqUSBKEY ; then
		# la clé B est la bonne
			echo "b" > /tmp/.cle
			rm /tmp/.KEYB
			pkill feh
			exit 0
		fi

	# il y a deux cles : la seconde est-elle la source ?
	serialKeyC=$(udevadm info --name=/dev/sdc | grep SERIAL_SHORT| cut -d= -f2)
	echo $serialPc:$serialKeyC > /tmp/.KEYC
		
		if diff /tmp/.KEYC /root/.uniqUSBKEY ; then
			echo "c" > /tmp/.cle
			rm /tmp/.KEYC
            pkill  feh
			exit 0
		fi

	# aucune des deux cles
	rm /tmp/.KEY*
	zenity --info --text="Pas de clé"
	ret=2
fi
}
# Définition des locales
export LANG=fr_FR.UTF-8


# ======================================================================
#Chargement librairie
# ======================================================================

repinstallation="/opt/borne"

[ ! -f $repinstallation/scripts/bmLib.sh ] && logger -p local0.crit 'Impossible de trouver la bibliothèque standard. Abandon.' && exit 1
. $repinstallation/scripts/bmLib.sh

# On modifie le curseur X par défaut de la souris
xsetroot -cursor_name left_ptr&

# Creation de l'identifiant unique lors de la premiere mise en route de la borne
getFirstID

# largeur de l'écran
largeurEcran=$(xwininfo -root | awk '$1=="Width:" {print $2}')

# Hauteur de l'écran
hauteurEcran=$(xwininfo -root | awk '$1=="Height:" {print $2}')
#pointX=$(echo $((($largeurEcran-500)/2)))
pointX="0"
pointY=$(echo $((($hauteurEcran-300)/1)))

nohup feh -ZFx /opt/borne/share/background.png &
nohup xterm &
# On fixe la valeur de ret pour la boucle
ret=2

# ======================================================================
# Ecran d'accueil connection USB
# ======================================================================

# Tant que la clé n'est pas insérée on boucle sur le script

while [ $ret -ne 0 ]
	do
	# Ecran Yad
	ans=$(yad --no-escape --width=300 --height=300 --fixed --geometry="+$pointX+$pointY" \
	--image=$repinstallation/share/connectUSB.jpg --image-on-top  \
	--text "<big><big><big><big>Pour vous connecter à cet ordinateur, veuillez insérer la clé USB qui vous a été fournie puis cliquez sur <b>Suivant</b> en bas à droite.</big></big></big></big>"  \
	--buttons-layout=edge --text-align=center \
	--button="Configuration!gtk-execute:1" \
	--button="Suivant:0" )

	ret=$?

# [ `whoami` = root ] || { gksudo "$0" "$@"; exit $?; }

		case ${ret} in
			1) 
			#if [ $(zenity --password) == "AdminAsso" ] ; then 
			#	$repinstallation/scripts/bmConfigborne.sh; 
			#fi
			user="gestionnaire" 
			pass=$(zenity --password)
			testMdp $user $pass
			#nohup xterm &

			if [ $? == 0 ];then
				$repinstallation/scripts/bmConfigborne.sh
			elif [ $? == 1 ];then
				user="administrateur"
				testMdp $user $pass
				if [ $? == 0 ];then
					$user="gestionnaire"
					$repinstallation/scripts/bmConfigborne.sh
				fi
			fi
			;;
			0)
			getUsbkey
			;;
		esac

	done
exit 0