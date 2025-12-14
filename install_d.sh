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
wget https://github.com/ersplus/solibuntu/archive/Dev.zip -O /opt/Dev.zip

if [ $? == 0 ] ; then
	rm -rf /opt/borne
	unzip Dev.zip
	mv /opt/solibuntu-Dev $repinstallation
	chmod +x $repinstallation/scripts/*.sh
	rm Dev.zip

	cd /opt/borne/scripts
	./install.sh $1

	echo "Fin de l'installation"
fi
exit 0