#!/bin/bash

repinstallation="/opt/borne"

[ "$(id -u)" -eq 0 ] || exec sudo -E "$0" "$@"

#-------------------------------------------------------
# Installation filtrage
#-------------------------------------------------------
installFiltrage() {
	if [ -f /root/.filtragepurged ] ; then
		while read -r line; do
			echo "$line"
			echo "$line" | debconf-set-selections
		done < /opt/borne/share/setselection.txt
		rm /root/.filtragepurged
	fi

	if [ -d /etc/firefox ] && [ -f /etc/firefox/syspref.js ]; then
		mv /etc/firefox/syspref.js /etc/firefox/syspref.js.back
	fi
	if [ -d /etc/firefox ]; then
		cp /opt/borne/share/prefs.js /etc/firefox/syspref.js
	fi

	if command -v gdebi-gtk >/dev/null 2>&1; then
		gdebi-gtk -n --auto-close /opt/borne/share/ctparental.deb
	elif command -v gdebi >/dev/null 2>&1; then
		gdebi -n /opt/borne/share/ctparental.deb
	else
		dpkg -i /opt/borne/share/ctparental.deb || apt-get install -f -y
	fi
}

# ======================================================================
# Script d'installation du filtrage
# ======================================================================

(
	echo "10" ; sleep 1
	echo "# Vérification des mises à jour" ; apt-get update
	echo "20" ; sleep 1
	echo "# Application des mises à jour" ; apt-get upgrade -y
	echo "30" ; sleep 1
	echo "# Nettoyage" ; apt-get clean
	echo "40" ; sleep 1
	echo "# Installation debconf-utils" ;  apt-get install -y debconf-utils
	echo "50" ; sleep 1
	echo "# Installation filtrage" ; installFiltrage
	result=$?
	echo "70" ; sleep 1
	echo "80" ; sleep 1
	echo "# Le filtrage internet a été installé avec succès, le filtrage par défaut sera activé lors de l’utilisation de Solibuntu. Vous pourrez configurer celui-ci, si nécessaire, avec le compte administrateur. Le mot de passe par défaut est : AdminSolibuntu. Vous pouvez le modifier en changeant le mot de passe administrateur, une fois ceci fait, le mot de passe du filtrage correspondra au nouveau mot de passe du compte administrateur. Rendez-vous à cette adresse pour pouvoir configurer le filtrage : http://admin.ct.local" ;
	echo "99" ; sleep 1
	exit $result
)  |
zenity --progress \
  --title="Progression de installation" \
  --text="Installation du filtrage..." \
  --width=500 \
  --percentage=0

result=${PIPESTATUS[0]}
exit $result



# sudo apt-get install clamav clamav-base clamav-freshclam console-data dansguardian dnsmasq gamin iptables-persistent libclamav7 libgamin0 libllvm3.6v5 liblua5.1-0 libnss3-tools lighttpd lighttpd-mod-magnet netfilter-persistent php-cgi php-common php-xml php7.0-cgi php7.0-cli php7.0-common php7.0-json php7.0-opcache php7.0-readline php7.0-xml privoxy spawn-fcgi

