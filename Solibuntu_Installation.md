# Solibuntu

Solibuntu est une solution basée sur **Xubuntu 16.04** conçue pour les associations et espaces publics numériques. Elle propose un environnement simplifié avec trois types de comptes (Administrateur, Gestionnaire, Invité) et des fonctionnalités avancées comme la personnalisation, le filtrage Internet et la synchronisation des configurations.

---

## Objectifs
- Offrir une **session invitée sécurisée et personnalisable**.
- Simplifier la gestion des postes pour les animateurs et administrateurs.
- Intégrer un **filtrage Internet** (CTparental).
- Permettre la **synchronisation des configurations** entre plusieurs postes.
- Faciliter la **masterisation et déploiement** via Live CD.

---

## Fonctionnalités principales
- **Autologin invité** avec charte d’utilisation.
- **Gestion des comptes** :
  - Administrateur (`AdminSolibuntu`)
  - Gestionnaire (`AdminAsso`)
- **Filtrage Internet** via CTparental.
- **Personnalisation graphique** (Plymouth, XFCE).
- **Synchronisation locale** par clé USB ou réseau P2P.
- **Scripts automatisés** pour installation, mise à jour et restauration.

---

## Installation
1. **Créer les comptes** :
   ```bash
   sudo adduser gestionnaire
   # Mot de passe provisoire : AdminAsso
   ```
2. **Installer les logiciels nécessaires** :
   ```bash
sudo apt install gsfonts gsfonts-other gsfonts-x11 ttf-mscorefonts-installer t1-xfree86-nonfree ttf-alee ttf-ancient-fonts ttf-arabeyes fonts-arphic-bkai00mp fonts-arphic-bsmi00lp fonts-arphic-gbsn00lp ttf-atarismall fonts-bpg-georgian fonts-dustin fonts-f500 fonts-sil-gentium ttf-georgewilliams ttf-isabella fonts-larabie-deco fonts-larabie-straight fonts-larabie-uncommon ttf-sjfonts ttf-staypuft ttf-summersby fonts-ubuntu-title ttf-xfree86-nonfree xfonts-intl-european xfonts-jmk xfonts-terminus fonts-arphic-ukai fonts-arphic-uming fonts-ipafont-mincho fonts-ipafont-gothic fonts-unfonts-core hplip cups-pdf exfat-fuse exfat-utils chromium-browser imagemagick xsane


sudo apt-get install hplip hplip-data hplip-doc hpijs-ppds hplip-gui printer-driver-hpcups printer-driver-hpijs printer-driver-pxljr
   ```
3. **Configurer l’autologin invité** :
   ```bash
   sudo nano /etc/lightdm/lightdm.conf.d/50-autoguest.conf
   ```
4. **Installer le filtrage CTparental** :
   ```bash
   gdebi ctparental_ubuntu16.04_4.21.06-1.0_all.deb
   ```

---

## Scripts inclus
- `bmConnectusb.sh` : Gestion de la clé USB pour déverrouillage.
- `bmConfigborne.sh` : Configuration système.
- `bmRestoreInvite.sh` : Restauration de la session invitée.
- `install.sh` : Installation complète de Solibuntu.

---

## Synchronisation
- Principe : **clé USB ou réseau P2P** pour répliquer la configuration (profils, logiciels, mots de passe).
- Objectif : toute modification sur un poste est propagée aux autres.

---

## Personnalisation graphique
- Thème Plymouth : `/usr/share/plymouth/themes/solibuntu`.
- Écran de démarrage : image via `feh`.

---

## Publication et maintenance
- Code source disponible sur GitHub : [https://github.com/ersplus/solibuntu](https://github.com/ersplus/solibuntu)
- Mise à jour mensuelle des scripts et dépendances.

---

## Roadmap
- ✅ Masterisation propre.
- ✅ Création d’un PPA pour mises à jour.
- 🔄 Synchronisation locale améliorée.
- 🔄 Quotas d’impression par session.

---

## Licence
Projet open source sous licence GPL.
