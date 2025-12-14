#!/bin/bash

echo "=========================================="
echo "Solibuntu 24.04 - Configuration en chroot"
echo "=========================================="

# Entre dans le chroot
chroot squashfs /bin/bash <<'EOFCHROOT'

# Configuration des utilisateurs Solibuntu
echo "Création des utilisateurs..."

# Utilisateur administrateur
useradd -m administrateur -s /bin/bash
echo -e "AdminSolibuntu\nAdminSolibuntu" | passwd administrateur
usermod -c "Administrateur Solibuntu" administrateur
usermod -aG sudo administrateur

# Utilisateur gestionnaire
useradd -m gestionnaire -s /bin/bash
echo -e "AdminAsso\nAdminAsso" | passwd gestionnaire
usermod -c "Gestionnaire Solibuntu" gestionnaire

echo "Utilisateurs créés avec succès."

# Installation des dépendances nécessaires pour Solibuntu 24.04
echo "Mise à jour des paquets..."
apt-get update

echo "Installation des dépendances Solibuntu..."
# Évite les questions interactives
export DEBIAN_FRONTEND=noninteractive

# Paquets essentiels pour Solibuntu
apt-get install -y \
	lightdm \
	zenity \
	xterm \
	rsync \
	curl \
	wget \
	net-tools \
	openssh-server \
	vim \
	gparted

# Installation de Solibuntu depuis le script
echo "Installation de Solibuntu..."
if [ -f /Solibuntu/install.sh ]; then
	chmod +x /Solibuntu/install.sh
	/Solibuntu/install.sh iso
else
	echo "ATTENTION: Script d'installation Solibuntu introuvable!"
fi

# Nettoyage
echo "Nettoyage du système..."
apt-get clean
apt-get autoclean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
rm -rf /var/tmp/*

echo "Configuration terminée."

EOFCHROOT

echo "=========================================="
echo "Fin de la configuration en chroot"
echo "=========================================="
