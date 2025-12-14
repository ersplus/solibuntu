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
# Check branche dev (depuis Solibuntu-24.04)
wget https://github.com/ersplus/Solibuntu-24.04/archive/main.zip -O /opt/Dev.zip

if [ $? == 0 ] ; then
	rm -rf /opt/borne
	unzip Dev.zip
	mv /opt/Solibuntu-24.04-main $repinstallation
	chmod +x $repinstallation/scripts/*.sh
	rm Dev.zip

	cd /opt/borne/scripts
	./install.sh $1

	echo "Fin de l'installation"
fi
exit 0