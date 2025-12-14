#! /bin/bash

### Projet Solisol.org                    ###
### Solibuntu Xubuntu 24.04               ###
### Installation Solibuntu Xubuntu 24.04  ###
### Mis à jour : 14/12/2025               ###


repinstallation="/opt/borne"

#-------------------------------------------------------
#  Récupération de la dernière release Xubuntu 24.04
#-------------------------------------------------------

cd /opt/

# Télécharger la dernière release stable depuis GitHub
echo "Téléchargement de la dernière version de Solibuntu Xubuntu 24.04..."
wget https://github.com/ersplus/solibuntu/releases/latest/download/solibuntu-xubuntu-24.04.zip -O /opt/solibuntu-latest.zip

if [ $? -eq 0 ]; then
	echo "Installation en cours..."
	
	# Extraire et installer
	unzip -q solibuntu-latest.zip
	mv /opt/solibuntu-xubuntu-24.04 $repinstallation
	chmod +x $repinstallation/scripts/*.sh
	rm solibuntu-latest.zip

	# Lancer le script d'installation
	cd /opt/borne/scripts
	./install.sh $1

	echo "✓ Installation terminée avec succès"
else
	echo "✗ Erreur lors du téléchargement de Solibuntu"
	echo "Vérifiez votre connexion Internet et que la release existe sur GitHub"
	exit 1
fi

exit 0
