#! /bin/bash

### Projet Solisol.org               ###
### Solibuntu                        ###
### Installation Solibuntu           ###
### 08/04/2018                       ###


repinstallation="/opt/borne"

#-------------------------------------------------------
# Création du compte gestionnaire
#-------------------------------------------------------
sudo useradd -m gestionnaire
echo -e "AdminAsso\nAdminAsso" | passwd gestionnaire

#-------------------------------------------------------
#  Création du dossier d'installation et copie du projet
#-------------------------------------------------------
cd /opt/
wget https://github.com/ersplus/solibuntu/archive/Bastien.zip
unzip Bastien.zip
mv /opt/solibuntu-Bastien /opt/borne
#cp -r /home/administrateur/Bureau/sf_solibuntu /opt/borne

chmod +x $repinstallation/scripts/*.sh

# ======================================================================
# Création des utilisateurs
# ======================================================================

echo "Création des utilisateurs"
echo "Modification du compte administtrateur"
usermod -c "Administrateur Solibuntu" administrateur

#echo "Création du compte Gestionnaire Solibuntu"
#adduser --quiet --gecos "Gestionnaire Solibuntu" gestionnaire
#passwd gestionnaire

#-------------------------------------------------------
# Configuration des paquets
#-------------------------------------------------------
while read line; do
	echo $line | debconf-set-selections
done < /opt/borne/share/setselection.txt


#-------------------------------------------------------
# Installation des logiciels
#-------------------------------------------------------

sudo apt install -y gsfonts gsfonts-other gsfonts-x11 ttf-mscorefonts-installer t1-xfree86-nonfree ttf-alee ttf-ancient-fonts ttf-arabeyes fonts-arphic-bsmi00lp fonts-arphic-gbsn00lp ttf-atarismall fonts-bpg-georgian fonts-dustin fonts-f500 fonts-sil-gentium ttf-georgewilliams ttf-isabella fonts-larabie-deco fonts-larabie-straight fonts-larabie-uncommon ttf-sjfonts ttf-staypuft ttf-summersby fonts-ubuntu-title ttf-xfree86-nonfree xfonts-intl-european xfonts-jmk xfonts-terminus fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core hplip cups-pdf exfat-utils chromium-browser imagemagick xsane
sudo apt-get install -y hplip hplip-data hplip-doc hpijs-ppds hplip-gui printer-driver-hpcups printer-driver-hpijs printer-driver-pxljr 
sudo apt-get install -y gdebi

# ======================================================================
# Installation du filtrage
# ======================================================================

echo "Installation du filtrage"

# Reccuperation de la dernière version de CTParental
wget https://github.com/marsat/CTparental/releases/download/4.21.06d/ctparental_ubuntu16.04_4.21.06-1.0_all.deb
mv ctparental_ubuntu16.04_4.21.06-1.0_all.deb $repinstallation/share/
cd $repinstallation/scripts
sudo ./filtrage_install.sh

# ======================================================================
# Installation logicielle
# ======================================================================

echo "Installation logicielle"
apt update && apt upgrade -y && apt-get clean 


# Suppression des applications
apt remove synapse seahorse thunderbird transmission-* pidgin xfce4-notes xfce4-mailwatch-plugin xfce4-weather-plugin -y


# Installation des applications complémentaires
apt install exfat-utils hplip hplip-gui gksu feh yad -y

# Pour installer le greffon sans installer l'imprimante
# a automatiser
hp-plugin -i

# Nettoyage
apt-get autoremove -y 

# ======================================================================
# Environnement Solibuntu
# ======================================================================

echo "Installation et configuration de Solibuntu"
chmod +rx /usr/share/xfpanel-switch/layouts/
chmod +rx /opt/borne/scripts/bmGuestwrapper.sh
chmod +rx /opt/borne/share/charte.html

# Autologin
cp -f $repinstallation/scripts/lightdm.conf.d/50-logout-restoreinvite.conf /etc/lightdm/lightdm.conf.d/50-logout-restoreinvite.conf
cp -f $repinstallation/scripts/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

# Personnalisation Plymouth
cd /usr/share/plymouth/themes/
tar -xvf $repinstallation/share/plymouth.tar.gz
echo "[Plymouth Theme] \n Name=solibuntu \n Description=Solibuntu theme \n ModuleName=script \n \n [script] \n ImageDir=/usr/share/plymouth/themes/solibuntu \n ScriptFile=/usr/share/plymouth/themes/solibuntu/solibuntu.script \n" > /usr/share/plymouth/themes/default.plymouth

# Liaison vers le profil utilisateur
echo "Squelette environnement Invité"
ln -s /home/gestionnaire /etc/guest-session/skel

#-------------------------------------------------------
#  Écran de connexion de la session invité
#-------------------------------------------------------
echo -e "[Seat: *]\nguest-wrapper=/usr/local/bin/bmGuestwrapper.sh\ngreeter-setup-script=/opt/borne/scripts/bmConnectusb.sh" > /etc/lightdm/lightdm.conf.d/50-guest-wrapper.conf
echo -e "[SeatDefaults]\nallow-guest=true\nautologin-guest=true\nautologin-user-timeout=1\nautologin-session=lightdm-autologin\nuser-session=xubuntu" > /etc/lightdm/lightdm.conf.d/50-autoguest.conf
sudo apt-get install -y dconf-cli
dconf reset /
echo "Fin de l'installation"

exit 0
