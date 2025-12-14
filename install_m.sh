#! /bin/bash

### Projet Solisol.org               ###
### Solibuntu master                 ###
### Installation Solibuntu master    ###
### 28/07/2018                       ###


repinstallation="/opt/borne"

#-------------------------------------------------------
#  Réccupération des sources MAster du projet
#-------------------------------------------------------

cd /opt/
# Check branche master
wget https://github.com/ersplus/solibuntu/archive/master.zip -O /opt/master.zip

if [ $? == 0 ] ; then
	rm -rf /opt/borne
	unzip master.zip
	mv /opt/solibuntu-master $repinstallation
	chmod +x $repinstallation/scripts/*.sh
	rm master.zip

	cd /opt/borne/scripts
	./install.sh $1

	echo "Fin de l'installation"
fi
exit 0
