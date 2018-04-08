#! /bin/bash

# ======================================================================
# Script d'installation
# Sur une base Xubuntu 16.04
# Utilisateur de base adminitrateur
# Script en cours...
# ======================================================================

repinstallation="/opt/borne"

chmod +x $repinstallation/scripts/*.sh

# ======================================================================
# Création des utilisateurs
# ======================================================================

echo "Création des utilisateurs"
echo "Modification du compte administtrateur"
usermod -c "Administrateur Solibuntu" administrateur

echo "Création du compte Gestionnaire Solibuntu"
adduser --quiet --gecos "Gestionnaire Solibuntu" gestionnaire
passwd gestionnaire

# ======================================================================
# Installation du filtrage
# ======================================================================

echo "Installation du filtrage"

# Reccuperation de la dernière version de CTParental
wget https://github.com/marsat/CTparental/releases/download/4.21.06d/ctparental_ubuntu16.04_4.21.06-1.0_all.deb
mv ctparental_ubuntu16.04_4.21.06-1.0_all.deb /opt/borne/share/

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

echo "Squelette environnement Invité"
ln -s /home/gestionnaire /etc/guest-session/skel


echo "Fin de l'installation"

exit 0
