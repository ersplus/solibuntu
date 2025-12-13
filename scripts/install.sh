#! /bin/bash

### Projet Solisol.org               ###
### Solibuntu dev                    ###
### Installation Solibuntu dev       ###
### Compatible Xubuntu 24.04        ###

repinstallation="/opt/borne"
action="${1:-}"

export DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-noninteractive}

ensure_root() {
	if [ "$(id -u)" -ne 0 ]; then
		echo "Ce script doit être exécuté en tant que root" >&2
		exit 1
	fi
}

ensure_group_and_users() {
	# Crée le groupe s'il n'existe pas déjà
	groupadd -f Solibuntu
	# Ajoute les comptes au groupe Solibuntu (création si besoin)
	usermod -a -G Solibuntu root 2>/dev/null || true

	if ! id -u administrateur >/dev/null 2>&1; then
		useradd -m -s /bin/bash -G Solibuntu administrateur
	fi

	if ! id -u gestionnaire >/dev/null 2>&1; then
		useradd -m -s /bin/bash -G Solibuntu gestionnaire
	fi

	chgrp Solibuntu /root/ 2>/dev/null || true
	chmod 774 /root/ 2>/dev/null || true
}

filter_available_packages() {
	local available=()
	for pkg in "$@"; do
		if apt-cache show "$pkg" >/dev/null 2>&1; then
			available+=("$pkg")
		else
			echo "Paquet indisponible sur cette version, ignoré : $pkg"
		fi
	done
	printf '%s\n' "${available[@]}"
}

install_if_available() {
	local packages=($(filter_available_packages "$@"))
	if [ ${#packages[@]} -gt 0 ]; then
		apt-get install -y "${packages[@]}"
	fi
}

set_default_browser() {
	local firefox_desktop=""
	if [ -f /usr/share/applications/firefox.desktop ]; then
		firefox_desktop="firefox.desktop"
	elif [ -f /var/lib/snapd/desktop/applications/firefox_firefox.desktop ]; then
		firefox_desktop="firefox_firefox.desktop"
	fi

	if [ -n "$firefox_desktop" ]; then
		xdg-settings set default-web-browser "$firefox_desktop" || true
	fi
}

configure_firefox_prefs() {
	if [ -d /etc/firefox ]; then
		cp -f "$repinstallation/share/firefox/syspref.js" /etc/firefox/syspref.js
	else
		echo "Répertoire /etc/firefox absent (Firefox en snap ?) - préférences non copiées"
	fi
}

ensure_root

mkdir -p /etc/lightdm/lightdm.conf.d
mkdir -p /etc/guest-session
mkdir -p /etc/xdg/autostart

if [ "$action" = "installation" ]; then
	ensure_group_and_users
fi

echo "Installation et configuration de Solibuntu"

# attribution exe
chmod +rx "$repinstallation/scripts/bmGuestwrapper.sh"
chmod +rx "$repinstallation/share/charte.html"

# Personnalisation Plymouth
cd /usr/share/plymouth/themes/
tar -xvf "$repinstallation/share/plymouth.tar.gz"
echo "[Plymouth Theme] \n Name=solibuntu \n Description=Solibuntu theme \n ModuleName=script \n \n [script] \n ImageDir=/usr/share/plymouth/themes/solibuntu \n ScriptFile=/usr/share/plymouth/themes/solibuntu/solibuntu.script \n" > /usr/share/plymouth/themes/default.plymouth

#-------------------------------------------------------
# Copie profil de base dans Skel
#-------------------------------------------------------

# À FAIRE

#-------------------------------------------------------
# Création du compte gestionnaire
#-------------------------------------------------------

echo "Copie des profils par defaut des utilisateurs"

#-------------------------------------------------------
# Autologin session Invité
#-------------------------------------------------------

echo "Squelette environnement Invité"
ln -sfn /home/gestionnaire /etc/guest-session/skel

# Configuration Autologin et les scripts de lightdm
cp -f "$repinstallation/scripts/lightdm.conf.d/50-logout-restoreinvite.conf" /etc/lightdm/lightdm.conf.d/50-logout-restoreinvite.conf
cp -f "$repinstallation/scripts/lightdm/lightdm-gtk-greeter.conf" /etc/lightdm/lightdm-gtk-greeter.conf

#-------------------------------------------------------
# Configuration des paquets
#-------------------------------------------------------

apt-get install -y debconf-utils
if [ -f /opt/borne/share/setselection.txt ]; then
	while read -r line; do
		echo "$line"
		echo "$line" | debconf-set-selections
	done < /opt/borne/share/setselection.txt
fi

#-------------------------------------------------------
# Installation des logiciels
#-------------------------------------------------------

echo "Installation logicielle"
apt-get update
if [ "$action" != "iso" ]; then
	apt-get full-upgrade -y && apt-get install -f -y && apt-get clean
fi

# Suppression des applications obsolètes ou non souhaitées
apt-get remove -y synapse seahorse thunderbird transmission-* pidgin xfce4-notes xfce4-mailwatch-plugin xfce4-weather-plugin || true

# Les jeux
apt-get remove -y sgt-launcher sgt-puzzles gnome-sudoku gnome-mines || true

# Installation des applications complémentaires
install_if_available exfatprogs exfat-fuse feh yad imagemagick simple-scan dmidecode gdebi gdebi-core

# Installation des polices complémentaires (paquets encore disponibles sur 24.04)
install_if_available gsfonts fonts-dejavu fonts-ubuntu ttf-mscorefonts-installer fonts-noto-core fonts-noto-cjk fonts-unfonts-core

# Installation de l'imprimante
install_if_available hplip hplip-data hplip-doc hpijs-ppds hplip-gui printer-driver-hpcups printer-driver-hpijs printer-driver-pxljr

# Installation des locales et correctifs linguistiques
install_if_available firefox-locale-fr aspell-fr hunspell-fr

# Désinstallation des extensions de Thunar Ouvrir dans un terminal etc.
if [ "$action" != "iso" ]; then
	dconf write /org/mate/caja/extensions/disabled-extensions "['libcaja-main-menu,'libcaja-sento','libcaja-python','libcaja-pythin','libcaja-wallpaper','libcaja-gksu','libcaja-engrampa','libcaja-open-terminal','libcatril-properties-page']" || true
	install_if_available printer-driver-cups-pdf
fi

# hp-plugin -i

echo "Gestion des droits administrateur et gestionnaire"

# copie configuration feh
cp -r /opt/borne/share/feh /etc/

#-------------------------------------------------------
#  Écran de connexion de la session invité
#-------------------------------------------------------

cp "$repinstallation/scripts/lightdm/lightdm-gtk-greeter.conf" /etc/lightdm/
cp "$repinstallation/scripts/lightdm.conf.d"/* /etc/lightdm/lightdm.conf.d/

#-------------------------------------------------------
#  Configuration du navigateur
#-------------------------------------------------------
set_default_browser
configure_firefox_prefs

#-------------------------------------------------------
#  Configuration fichier sudoers
#-------------------------------------------------------

cp /opt/borne/share/sudoers /tmp/sudoers.bak

if visudo -cf /tmp/sudoers.bak; then
	cp /tmp/sudoers.bak /etc/sudoers
else
	echo "Impossible de modifier le fichier sudoers"
fi

cp /opt/borne/scripts/sessionStart.desktop /etc/xdg/autostart/sessionStart.desktop

#Copie des profils
if [ "$action" != "maj" ]; then
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
exit 0