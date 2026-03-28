#! /bin/bash

### Projet Solisol.org               ###
### Solibuntu Master                 ###
### Installation Solibuntu Master    ###
### 28/07/2018                       ###
### Paquets révisés pour Xubuntu 24.04+ / 25.x (Noble, Plucky) ###

repinstallation="/opt/borne"

if [ "$1" = "installation" ] ; then
	getent group Solibuntu >/dev/null 2>&1 || groupadd Solibuntu
	if ! id -u administrateur >/dev/null 2>&1; then
		useradd -m -g Solibuntu administrateur
	fi
	if ! id -u gestionnaire >/dev/null 2>&1; then
		useradd -m -g Solibuntu gestionnaire
	fi
	chgrp Solibuntu /root/
	chmod 774 /root/
fi
#-------------------------------------------------------
#  Réccupération des sources Dev du projet
#-------------------------------------------------------

#if [ $1 == "iso" ] ; then
	#useradd -m administrateur
	#echo -e "AdminSolibuntu\nAdminSolibuntu" | passwd administrateur
	#usermod -c "Administrateur Solibuntu" administrateur
#fi
if [ $? == 0 ] ; then
	#check branche master 

	#-------------------------------------------------------
	# Environnement Solibuntu
	#-------------------------------------------------------

	echo "Installation et configuration de Solibuntu"

	# attribution exe
	chmod +rx $repinstallation/scripts/bmGuestwrapper.sh
	chmod +rx $repinstallation/share/charte.html

	# Personnalisation Plymouth
	cd /usr/share/plymouth/themes/
	tar -xvf $repinstallation/share/plymouth.tar.gz
	echo "[Plymouth Theme] \n Name=solibuntu \n Description=Solibuntu theme \n ModuleName=script \n \n [script] \n ImageDir=/usr/share/plymouth/themes/solibuntu \n ScriptFile=/usr/share/plymouth/themes/solibuntu/solibuntu.script \n" > /usr/share/plymouth/themes/default.plymouth

	#-------------------------------------------------------
	# Création du compte gestionnaire
	#-------------------------------------------------------

	echo "Copie des profils par defaut des utilisateurs"

	# exemple sur le code Solipi



	#-------------------------------------------------------
	# Autologin session Invité
	#-------------------------------------------------------

	# Liaison vers le profil utilisateur
	echo "Squelette environnement Invité"
	ln -s /home/gestionnaire /etc/guest-session/skel

	# Configuration Autologin et les scripts de lightdm
	cp -f $repinstallation/scripts/lightdm.conf.d/50-logout-restoreinvite.conf /etc/lightdm/lightdm.conf.d/50-logout-restoreinvite.conf
	cp -f $repinstallation/scripts/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf


	#-------------------------------------------------------
	# Configuration des paquets
	#-------------------------------------------------------

	# problématique des licences !!
	apt-get install debconf-utils
	while read line; do
		echo $line
		echo $line | debconf-set-selections
	done < /opt/borne/share/setselection.txt


	#-------------------------------------------------------
	# Installation des logiciels
	#-------------------------------------------------------

	echo "Installation logicielle"
	apt-get update
	if [ "$1" != "iso" ] ; then
		apt-get full-upgrade -y && apt install -f && apt-get clean
	fi

	# Suppression des applications (paquets absents selon la version : ignorés)
	apt-get remove -y --ignore-missing \
		synapse seahorse \
		transmission-gtk transmission-common transmission-cli \
		pidgin xfce4-notes xfce4-mailwatch-plugin xfce4-weather-plugin
	# Thunderbird est souvent installé en snap sur Xubuntu 25.x
	if command -v snap >/dev/null 2>&1; then
		snap remove thunderbird 2>/dev/null || true
	fi
	apt-get remove -y --ignore-missing thunderbird || true

	# Les jeux
	apt-get remove -y --ignore-missing sgt-launcher sgt-puzzles gnome-sudoku gnome-mines || true

	# Outils borne : exFAT (exfatprogs sur les Ubuntu récents, sinon exfat-utils)
	apt-get install -y exfatprogs feh yad imagemagick xsane \
		|| apt-get install -y exfat-utils feh yad imagemagick xsane

	# Polices (jeu réduit — plusieurs anciens paquets ttf-* ne sont plus fournis)
	apt-get install -y \
		gsfonts gsfonts-other gsfonts-x11 \
		ttf-mscorefonts-installer \
		fonts-liberation fonts-dejavu-core fonts-noto-core \
		fonts-ubuntu-title \
		xfonts-terminus xfonts-intl-european xfonts-jmk \
		fonts-ipafont-gothic fonts-ipafont-mincho \
		t1-xfree86-nonfree fonts-alee

	# Chromium : métapaquet chromium-browser (transitional → snap) ou paquet chromium selon les dépôts
	apt-get install -y chromium-browser \
		|| apt-get install -y chromium

	# Impression (jeu minimal — hpijs / vieux pilotes souvent fusionnés dans hplip)
	apt-get install -y hplip hplip-gui printer-driver-hpcups \
		|| apt-get install -y hplip hplip-data hplip-doc hplip-gui printer-driver-hpcups hpijs-ppds

	# Gdebi (CTparental / paquets .deb locaux)
	apt-get install -y gdebi

	# Français : orthographe ; firefox-locale-fr utile si Firefox est en paquet deb (sinon snap : langue à régler autrement)
	apt-get install -y aspell-fr hunspell-fr myspell-fr || apt-get install -y aspell-fr hunspell-fr
	apt-get install -y firefox-locale-fr || true


	# Thunar / Xfce : le profil est surtout défini dans share/xfce4 (skel). Ancien réglage MATE Caja sans effet ici.
	if [ "$1" != "iso" ] ; then
		if command -v xfconf-query >/dev/null 2>&1 && [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
			xfconf-query -c thunar -p /misc-open-terminal -n -t bool -s false 2>/dev/null || true
		fi
		dconf write /org/mate/caja/extensions/disabled-extensions "['libcaja-main-menu,'libcaja-sento','libcaja-python','libcaja-pythin','libcaja-wallpaper','libcaja-gksu','libcaja-engrampa','libcaja-open-terminal','libcatril-properties-page']" 2>/dev/null || true
		apt-get install printer-driver-cups-pdf
	fi

	# hp-plugin -i

	echo "Gestion des droits administrateur et gestionnaire"

	#
	# Sudoers copy du fichier de configuration et validation
	# /etc/sudoers
	#

	echo "Visionneuse d image"


	#
	# copie configuration feh
	# /etc/feh/* /opt/borne/share/feh
	#
	cp -r /opt/borne/share/feh /etc/

	#-------------------------------------------------------
	#  Écran de connexion de la session invité
	#-------------------------------------------------------

	cp $repinstallation/scripts/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/
	cp $repinstallation/scripts/lightdm.conf.d/* /etc/lightdm/lightdm.conf.d/

	#-------------------------------------------------------
	#  Configuration du navigateur
	#-------------------------------------------------------
	# Navigateur par défaut Firefox
	# Proxy, Gestion de l'historique, page de démarrage etc...

	# Firefox deb ou Snap : essayer plusieurs .desktop (Xubuntu 24.04+ / 25.x)
	_firefox_set=0
	for _desk in firefox.desktop firefox_firefox.desktop mozilla-firefox.desktop; do
		if xdg-settings set default-web-browser "$_desk" 2>/dev/null; then
			_firefox_set=1
			break
		fi
	done
	[ "${_firefox_set:-0}" -eq 1 ] || xdg-settings set default-web-browser firefox-browser.desktop 2>/dev/null || true
	mkdir -p /etc/firefox
	cp -r $repinstallation/share/firefox/syspref.js /etc/firefox/syspref.js
	
	#-------------------------------------------------------
	#  Configuration fichier sudoers
	#-------------------------------------------------------

	# Création fichier backup
	cp /opt/borne/share/sudoers /tmp/sudoers.bak
	
	visudo -cf /tmp/sudoers.bak

	if [ $? == 0 ] ; then
		cp /tmp/sudoers.bak /etc/sudoers
	else
		echo "Impossible de modifier le fichier sudoers"
	fi

	cp /opt/borne/scripts/sessionStart.desktop /etc/xdg/autostart/sessionStart.desktop

	#Copie des profils
	if [ "$1" != "maj" ] ; then
		cp /opt/borne/share/skel_admin.tar.gz /home/
		cp /opt/borne/share/skel_gest.tar.gz /home/
		cd /home/
		rm -rf gestionnaire/
		tar -xvzf skel_gest.tar.gz
		rm -rf administrateur/
		tar -xvzf skel_admin.tar.gz
		rm skel_admin.tar.gz
		rm skel_gest.tar.gz
	fi

	echo "Fin de l'installation"
fi
exit 0
