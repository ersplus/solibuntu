#!/bin/bash

#-------------------------------------------------------
# Install filtrage + dépendances
#-------------------------------------------------------
installFiltrage() {
	#sudo dpkg -i /opt/borne/share/ctparental_ubuntu16.04_4.21.06-1.0_all.deb
	gdebi-gtk --auto-close /opt/borne/share/ctparental_ubuntu16.04_4.21.06-1.0_all.deb
	cp -rf /opt/borne/CTParental /usr/bin/CTParental
}

# ======================================================================
# Script d'installation du filtrage
# ======================================================================

repinstallation="/opt/borne"

[ `whoami` = root ] || { gksudo "$0" "$@"; exit $?; }

(
	echo "10" ; sleep 1
	echo "# Vérification des mises à jour" ; sudo apt update
	echo "20" ; sleep 1
	echo "# Application des mises à jour" ; sudo apt upgrade -y
	echo "30" ; sleep 1
	echo "# Mise à jour" ; sudo apt clean
	echo "40" ; sleep 1
	echo "# Installation debconf-utils" ;  sudo apt-get install debconf-utils
	echo "45" ; sleep 1
	echo "# Configuation des dépendances"; config
	echo "50" ; sleep 1
	echo "# Installation des dépendances"; sudo apt-get install -y clamav clamav-base clamav-freshclam console-data dansguardian dnsmasq gamin iptables-persistent libclamav7 libgamin0 libllvm3.6v5 liblua5.1-0 libnss3-tools lighttpd lighttpd-mod-magnet netfilter-persistent php-cgi php-common php-xml php7.0-cgi php7.0-cli php7.0-common php7.0-json php7.0-opcache php7.0-readline php7.0-xml privoxy spawn-fcgi
	echo "60" ; sleep 1
	echo "# Installation filtrage"; installFiltrage
	echo "70" ; sleep 1
	echo "# Configuation du proxy" ; sudo cp -rf /opt/borne/share/proxy/defaulton /etc/chromium-browser/default
	echo "80" ; sleep 1
	echo "# Fin de l'installation" ;
	echo "99" ; sleep 1
	) |
	zenity --progress \
	  --title="Progression de installation" \
	  --text="Installation du filtrage..." \
	  --percentage=0

	if [ "$?" = -1 ] ; then
		zenity --error --text="Installation annulée."
	fi
exit 0



# sudo apt-get install clamav clamav-base clamav-freshclam console-data dansguardian dnsmasq gamin iptables-persistent libclamav7 libgamin0 libllvm3.6v5 liblua5.1-0 libnss3-tools lighttpd lighttpd-mod-magnet netfilter-persistent php-cgi php-common php-xml php7.0-cgi php7.0-cli php7.0-common php7.0-json php7.0-opcache php7.0-readline php7.0-xml privoxy spawn-fcgi

