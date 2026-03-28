#!/bin/bash

repinstallation="/opt/borne"

. "$repinstallation/scripts/libRootGui.sh"
solibuntu_ensure_root

. "$repinstallation/scripts/libChromiumProxy.sh"

#-------------------------------------------------------
# Installation filtrage
#-------------------------------------------------------
installFiltrage() {
	if [ -f /root/.filtragepurged ] ; then
		while read -r line; do
			echo "$line"
			echo "$line" | debconf-set-selections
		done < /opt/borne/share/setselection.txt
		rm -f /root/.filtragepurged
	fi

	mkdir -p /etc/firefox
	if [ -f /etc/firefox/syspref.js ]; then
		mv -f /etc/firefox/syspref.js /etc/firefox/syspref.js.back
	fi
	cp -f /opt/borne/share/prefs.js /etc/firefox/syspref.js

	if ! gdebi-gtk -n --auto-close /opt/borne/share/ctparental.deb; then
		return 1
	fi

	solibuntu_chromium_proxy_apply on
	return 0
}

# ======================================================================
# Script d'installation du filtrage
# ======================================================================

result_file=$(mktemp)
trap 'rm -f "$result_file"' EXIT
(
	echo "10" ; sleep 1
	echo "# Vérification des mises à jour" ; apt-get update
	echo "20" ; sleep 1
	echo "# Application des mises à jour" ; apt-get upgrade -y
	echo "30" ; sleep 1
	echo "# Mise à jour" ; apt-get clean
	echo "40" ; sleep 1
	echo "# Installation debconf-utils" ; apt-get install -y debconf-utils
	echo "50" ; sleep 1
	echo "# Installation filtrage"
	installFiltrage
	echo $? > "$result_file"
	echo "70" ; sleep 1
	echo "80" ; sleep 1
	echo "# Le filtrage internet a été installé avec succès, le filtrage par défaut sera activé lors de l'utilisation de Solibuntu. Vous pourrez configurer celui-ci, si nécessaire, avec le compte administrateur. Le mot de passe par défaut est : AdminSolibuntu. Vous pouvez le modifier en changeant le mot de passe administrateur, une fois ceci fait, le mot de passe du filtrage correspondra au nouveau mot de passe du compte administrateur. Rendez-vous à cette adresse pour pouvoir configurer le filtrage : http://admin.ct.local" ;
	echo "99" ; sleep 1
) |
zenity --progress \
  --title="Progression de installation" \
  --text="Installation du filtrage..." \
  --width=500 \
  --percentage=0

result=$(tr -d '\n' <"$result_file")
exit "${result:-1}"
