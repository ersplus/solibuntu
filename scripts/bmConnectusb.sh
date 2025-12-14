#!/bin/bash

# ======================================================================
# Fonction de vérification de la clé
# ======================================================================

getUsbkey() {
	if ! udevadm info --name=/dev/sdb > /dev/null 2>&1 ; then
		# pas de cle / affichage page accueil
		ret=2
	else
		# identification de la cle detenant
		# les donnees sources (identifiants uniques)

		# au moins une clé est branchée
		serialPc=$(dmidecode -s system-serial-number)

		# Utiliser des fichiers temporaires sûrs
		KEYB=$(mktemp /tmp/bmkey.XXXXXX) || KEYB="/tmp/.KEYB.$$"
		KEYC=$(mktemp /tmp/bmkey.XXXXXX) || KEYC="/tmp/.KEYC.$$"
		# nettoyer en sortie
		trap 'rm -f "$KEYB" "$KEYC"' RETURN INT TERM

		serialKeyB=$(udevadm info --name=/dev/sdb | grep SERIAL_SHORT | cut -d= -f2)
		echo "${serialPc}:${serialKeyB}" > "$KEYB"

		if diff -q "$KEYB" /root/.uniqUSBKEY > /dev/null 2>&1 ; then
			# la clé B est la bonne
			echo "b" > /tmp/.cle
			rm -f "$KEYB"
			pkill nitrogen 2>/dev/null || true
			exit 0
		fi

		# il y a deux cles : la seconde est-elle la source ?
		serialKeyC=$(udevadm info --name=/dev/sdc | grep SERIAL_SHORT | cut -d= -f2)
		echo "${serialPc}:${serialKeyC}" > "$KEYC"

		if diff -q "$KEYC" /root/.uniqUSBKEY > /dev/null 2>&1 ; then
			echo "c" > /tmp/.cle
			rm -f "$KEYC"
		    pkill nitrogen 2>/dev/null || true
			exit 0
		fi

		# aucune des deux cles
		rm -f "$KEYB" "$KEYC"
		zenity --info --text="Pas de clé"
		ret=2
	fi
}
# Définition des locales
export LANG=fr_FR.UTF-8

# ======================================================================
# Installation des prérequis
# ======================================================================

# Vérifier et installer les dépendances obligatoires
REQUIRED_PACKAGES="nitrogen yad zenity imagemagick numlockx"
MISSING_PACKAGES=""

for pkg in $REQUIRED_PACKAGES; do
	if ! command -v "$pkg" >/dev/null 2>&1 && ! dpkg -l | grep -q "^ii  $pkg"; then
		MISSING_PACKAGES="$MISSING_PACKAGES $pkg"
	fi
done

if [ -n "$MISSING_PACKAGES" ]; then
	echo "Installation des paquets manquants:$MISSING_PACKAGES"
	if [ "$(id -u)" -eq 0 ]; then
		apt-get update -qq && apt-get install -y $MISSING_PACKAGES 2>/dev/null || true
	else
		sudo apt-get update -qq && sudo apt-get install -y $MISSING_PACKAGES 2>/dev/null || true
	fi
fi

# Vérifier que les paquets essentiels sont bien installés
for pkg in nitrogen yad zenity imagemagick numlockx; do
	if ! dpkg -l 2>/dev/null | grep -q "^ii  $pkg"; then
		logger -p local0.crit "Paquet obligatoire $pkg non installé. Abandon."
		exit 1
	fi
done

# ======================================================================
#Chargement librairie
# ======================================================================

repinstallation="/opt/borne"

[ ! -f "$repinstallation/scripts/bmLib.sh" ] && logger -p local0.crit 'Impossible de trouver la bibliothèque standard. Abandon.' && exit 1
. "$repinstallation/scripts/bmLib.sh"

# On modifie le curseur X par défaut de la souris
xsetroot -cursor_name left_ptr &

# Activer la touche Vernum (NumLock)
if command -v numlockx >/dev/null 2>&1; then
	numlockx on
elif command -v xdotool >/dev/null 2>&1; then
	xdotool key Num_Lock
else
	logger -p local0.warning "Aucun outil pour activer NumLock (numlockx ou xdotool manquants)"
fi

# Creation de l'identifiant unique lors de la premiere mise en route de la borne
getFirstID

# Cache screen dimensions to avoid multiple xwininfo calls
screenInfo=$(xwininfo -root)
largeurEcran=$(echo "$screenInfo" | awk '$1=="Width:" {print $2}')
hauteurEcran=$(echo "$screenInfo" | awk '$1=="Height:" {print $2}')

pointX="0"
pointY=$(( hauteurEcran-300 ))

# Afficher l'image de fond avec nitrogen (compatible Xubuntu 24.04)
# Redimensionner l'image à la résolution de l'écran avant de l'afficher
if command -v nitrogen >/dev/null 2>&1; then
	# Créer une version redimensionnée de l'image
	bgimage_resized="/tmp/background_${largeurEcran}x${hauteurEcran}.png"
	
	if command -v convert >/dev/null 2>&1; then
		# Utiliser ImageMagick si disponible pour redimensionner en conservant le ratio
		convert /opt/borne/share/background.png -resize ${largeurEcran}x${hauteurEcran} -gravity center -background black -extent ${largeurEcran}x${hauteurEcran} "$bgimage_resized" 2>/dev/null || bgimage_resized="/opt/borne/share/background.png"
	else
		bgimage_resized="/opt/borne/share/background.png"
	fi
	
	nohup nitrogen --set-zoom-fill "$bgimage_resized" >/dev/null 2>&1 &
else
	logger -p local0.warning "nitrogen n'est pas installé. Installation recommandée : sudo apt-get install nitrogen"
fi

#nohup xterm &
# On fixe la valeur de ret pour la boucle
ret=2

# ======================================================================
# Ecran d'accueil connection USB
# ======================================================================

# Tant que la clé n'est pas insérée on boucle sur le script

while [ "$ret" -ne 0 ]
	do
	# Ecran Yad
	ans=$(yad --no-escape --width=300 --height=300 --fixed --geometry="+${pointX}+${pointY}" \
	--image="$repinstallation/share/connectUSB.jpg" --image-on-top  \
	--text "<big><big><big><big>Pour vous connecter à cet ordinateur, veuillez insérer la clé USB qui vous a été fournie puis cliquez sur <b>Suivant</b> en bas à droite.</big></big></big></big>[...]" \
	--buttons-layout=edge --text-align=center \
	--button="Configuration!gtk-execute:1" \
	--button="Suivant:0" )

	ret=$?

	# [ `whoami` = root ] || { gksudo "$0" "$@"; exit $?; }

		case "${ret}" in
			1)
				user="gestionnaire"
				pass=$(zenity --forms --title="Configuration" \
				--text="Saisissez votre mot de passe\\n(administrateur ou gestionnaire)" \
				--add-password="Mot de passe")

				# Teste si le mot de passe correspond au compte \"gestionnaire\"
				testMdp "$user" "$pass"

				if [ $? = 0 ];then

					# Teste si le mot de passe du gestionnaire est celui par défaut
					if [ "$pass" = "AdminAsso" ] ; then
						# Teste si le mot de passe de l'administrateur est également celui par défaut
						testMdp "administrateur" "AdminSolibuntu"
						if [ $? = 0 ] ; then
							# Affiche un message d'avertissement
							zenity --info --width=250 --text "Attention, les mots de passe du compte administrateur et du \\ncompte gestionnaire n'ont jamais été changés. Veuillez le signaler à l'administrateur de Solibuntu."
						else
							# Affiche un message d'avertissement
							zenity --info --width=250 --text "Attention, le mot de passe du compte gestionnaire n'a \\njamais été changé. Veuillez le signaler à l'administrateur de Solibuntu."
						fi
					else
						# Teste si seul le mot de passe administrateur est celui par défaut
						testMdp "administrateur" "AdminSolibuntu"
						if [ $? = 0 ] ; then
							# Affiche un message d'avertissement
							zenity --info --width=250 --text "Attention, le mot de passe du compte administrateur n'a \\njamais été changé. Veuillez le signaler à l'administrateur de Solibuntu."
						fi
					fi
					# Appel le script du panneau de configuration en indiquant le compte gestionnaire
					"$repinstallation/scripts/bmConfigborne.sh" gestionnaire
				elif [ $? = 1 ];then
					# Teste si le mot de passe est celui du compte administrateur
					user="administrateur"
					testMdp "$user" "$pass"
					if [ $? = 0 ];then
						# Teste si le mot de passe du gestionnaire est celui par défaut
						testMdp "gestionnaire" "AdminAsso"
						if [ $? = 0 ]; then
							# Teste si le mot de passe administrater est celui par défaut
							if [ "$pass" = "AdminSolibuntu" ] ; then
								# Affiche un avertissement et propose de changer les mots de passe car
								# l'utilisateur qui vient de se connecter est l'administrateur
								zenity --question --width=250 --text="Les mots de passe administrateur et gestionnaire sont \\n								toujours les mots de passe par défaut, désirez-vous les modifier ?" \
								--ok-label "Oui" --cancel-label="Non"
								if [ $? = 0 ] ; then
									# Appel la fonction permettant de changer le mot de passe
									changerMdp "administrateur" "gestionnaire"
								fi
							else
								# Affiche un avertissement et propose de changer le mot de passe car
								# l'utilisateur qui vient de se connecter est l'administrateur
								zenity --question --width=250 --text="Le mot de passe gestionnaire est \\n								toujours le mot de passe par défaut, désirez-vous le modifier ?" \
								--ok-label "Oui" --cancel-label="Non"
								if [ $? = 0 ] ; then
									# Appel la fonction permettant de changer le mot de passe
									changerMdp "gestionnaire"
								fi
							fi
						else
							# Teste si seul le mot de passe administrateur est celui par défaut
							if [ "$pass" = "AdminSolibuntu" ] ; then
								# Affiche un avertissement et propose de changer le mot de passe car
								# l'utilisateur qui vient de se connecter est l'administrateur
								zenity --question --width=250 --text="Le mot de passe administrateur est \\n								toujours le mot de passe par défaut, désirez-vous le modifier ?" \
								--ok-label "Oui" --cancel-label="Non"
								if [ $? = 0 ] ; then
									# Appel la fonction permettant de changer le mot de passe
									changerMdp "administrateur"
								fi
							fi
						fi
						# Appel le script du panneau de configuration en indiquant le compte administrateur
						"$repinstallation/scripts/bmConfigborne.sh" administrateur
					fi
				fi
				;;
			0)
				getUsbkey
				;;
		esac

	done
exit 0
