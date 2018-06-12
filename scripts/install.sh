#! /bin/bash

### Projet Solisol.org               ###
### Solibuntu dev                    ###
### Installation Solibuntu dev       ###
### 28/04/2018                       ###


repinstallation="/opt/borne"

#-------------------------------------------------------
#  Réccupération des sources Dev du projet
#-------------------------------------------------------

cd /opt/
# Check branche dev
wget https://github.com/bastlenoob/solibuntu/archive/Dev.zip

#if [ $1 == "iso" ] ; then
	#useradd -m administrateur
	#echo -e "AdminSolibuntu\nAdminSolibuntu" | passwd administrateur
	#usermod -c "Administrateur Solibuntu" administrateur
#fi
if [ $? == 0 ] ; then
	#check branche master 
	# wget https://github.com/ersplus/solibuntu/archive/master.zip

	unzip Dev.zip
	mv /opt/solibuntu-Dev $repinstallation
	chmod +x $repinstallation/scripts/*.sh

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
	# Copie profil de base dans Skel
	#-------------------------------------------------------

	# À FAIRE

	#-------------------------------------------------------
	# Création du compte gestionnaire
	#-------------------------------------------------------

	echo "Création des utilisateurs"

	# Ajout du compte gestionnaire Solibuntu
	#useradd -m gestionnaire
	#echo -e "AdminAsso\nAdminAsso" | passwd gestionnaire
	#usermod -c "Gestionnaire Solibuntu" gestionnaire

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

	while read line; do
		echo $line | debconf-set-selections
	done < /opt/borne/share/setselection.txt


	#-------------------------------------------------------
	# Installation des logiciels
	#-------------------------------------------------------

	echo "Installation logicielle"
	apt-get update
	if [ $1 != "iso" ] ; then
		apt-get full-upgrade -y && apt install -f && apt-get clean
	fi

	# Suppression des applications
	apt remove synapse seahorse thunderbird transmission-* pidgin xfce4-notes xfce4-mailwatch-plugin xfce4-weather-plugin -y

	# Les jeux
	apt remove sgt-launcher sgt-puzzles gnome-sudoku gnome-mines -y

	# Installation des applications complémentaires
	apt-get install -y exfat-utils feh yad imagemagick xsane

	# Installation des polices complémentaires
	apt-get install -y gsfonts gsfonts-other gsfonts-x11 ttf-mscorefonts-installer t1-xfree86-nonfree fonts-alee ttf-ancient-fonts fonts-arabeyes fonts-arphic-bsmi00lp fonts-arphic-gbsn00lp fonts-bpg-georgian fonts-dustin fonts-f500 fonts-sil-gentium ttf-georgewilliams ttf-isabella fonts-larabie-deco fonts-larabie-straight fonts-larabie-uncommon ttf-sjfonts ttf-staypuft ttf-summersby fonts-ubuntu-title ttf-xfree86-nonfree xfonts-intl-european xfonts-jmk xfonts-terminus fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core hplip exfat-utils chromium-browser imagemagick xsane

	# Installation de l'imprimante
	apt-get install -y hplip hplip-data hplip-doc hpijs-ppds hplip-gui printer-driver-hpcups printer-driver-hpijs printer-driver-pxljr
	bash apt-get install printer-driver-cups-pdf &

	# Installation de Gdebi pour résoudre les dépendances de l'installation de CTparental
	apt-get install -y gdebi

	# Désinstallation des extensions de Thunar Ouvrir dans un terminal etc.
	if [ $1 != "iso" ] ; then
		dconf write /org/mate/caja/extensions/disabled-extensions "['libcaja-main-menu,'libcaja-sento','libcaja-python','libcaja-pythin','libcaja-wallpaper','libcaja-gksu','libcaja-engrampa','libcaja-open-terminal','libcatril-properties-page']"
	fi

	# hp-plugin -i

	#
	# Sudoers copy du fichier de configuration
	# /etc/sudoers
	#


	#
	# copie configuration feh
	# /etc/feh/* /opt/borne/share/feh
	#


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
	xdg-settings set default-web-browser firefox-browser.desktop
	cp -r $repinstallation/share/firefox/syspref.js /etc/firefox/syspref.js 

	echo "Fin de l'installation"
fi
exit 0
