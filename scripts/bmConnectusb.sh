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
#nohup xterm &
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
			user="gestionnaire" 
			pass=$(zenity --forms --title="Configuration" \
--text="Saisissez votre mot de passe\n(administrateur ou gestionnaire)" \
--add-password="Mot de passe")

			# Teste si le mot de passe correspond au compte "gestionnaire"
			testMdp $user $pass

			if [ $? == 0 ];then

				# Teste si le mot de passe du gestionnaire est celui par défaut
				if [ $pass == "AdminAsso" ] ; then
					# Teste si le mot de passe de l'administrateur est également celui par défaut
					testMdp "administrateur" "AdminSolibuntu"
					if [ $? == 0 ] ; then
						# Affiche un message d'avertissement
						zenity --info --text "Attention, les mots de passe du compte administrateur et du \
						compte gestionnaire n'ont jamais été changés. Veuillez le signaler."
					else
						# Affiche un message d'avertissement
						zenity --info --text "Attention, le mot de passe du compte gestionnaire n'a \
						jamais été changé. Veuillez le signaler."
					fi
				else
					# Teste si seul le mot de passe administrateur est celui par défaut
					testMdp "administrateur" "AdminSolibuntu"
					if [ $? == 0 ] ; then
						# Affiche un message d'avertissement
						zenity --info --text "Attention, le mot de passe du compte administrateur n'a \
						jamais été changé. Veuillez le signaler."
					fi
				fi
				# Appel le script du panneau de configuration en indiquant le compte gestionnaire
				$repinstallation/scripts/bmConfigborne.sh gestionnaire
			elif [ $? == 1 ];then
				# Teste si le mot de passe est celui du compte administrateur
				user="administrateur"
				testMdp $user $pass
				if [ $? == 0 ];then
					# Teste si le mot de passe du gestionnaire est celui par défaut
					testMdp "gestionnaire" "AdminAsso"
					if [ $? == 0 ]; then
						# Teste si le mot de passe administrater est celui par défaut
						if [ $pass == "AdminSolibuntu" ] ; then
							# Affiche un avertissement et propose de changer les mots de passe car
							# l'utilisateur qui vient de se connecter est l'administrateur
							zenity --question --text="Les mots de passe administrateur et gestionnaire sont \
							toujours les mots de passe par défaut, désirez-vous les modifier ?" \
							--ok-label "Oui" --cancel-label="Non"
							if [ $? == 0 ] ; then
								# Appel la fonction permettant de changer le mot de passe
								changerMdp "administrateur" "gestionnaire"
							fi
						else
							# Affiche un avertissement et propose de changer le mot de passe car
							# l'utilisateur qui vient de se connecter est l'administrateur
							zenity --question --text="Le mot de passe gestionnaire est \
							toujours le mot de passe par défaut, désirez-vous le modifier ?" \
							--ok-label "Oui" --cancel-label="Non"
							if [ $? == 0 ] ; then
								# Appel la fonction permettant de changer le mot de passe
								changerMdp "gestionnaire"
							fi
						fi
					else
						# Teste si seul le mot de passe administrateur est celui par défaut
						if [ $pass == "AdminSolibuntu" ] ; then
							# Affiche un avertissement et propose de changer le mot de passe car
							# l'utilisateur qui vient de se connecter est l'administrateur
							zenity --question --text="Le mot de passe administrateur est \
							toujours le mot de passe par défaut, désirez-vous le modifier ?" \
							--ok-label "Oui" --cancel-label="Non"
							if [ $? == 0 ] ; then
								# Appel la fonction permettant de changer le mot de passe
								changerMdp "administrateur"
							fi
						fi
					fi
					# Appel le script du panneau de configuration en indiquant le compte administrateur
					$repinstallation/scripts/bmConfigborne.sh administrateur
				fi
			fi
			;;
			0)
			getUsbkey
			;;
		esac

	done
exit 0