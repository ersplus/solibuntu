# Solibuntu 24.04

Solibuntu : une SOLution Informatique SOLidaire pour les associations du secteur social du projet https://solisol.org

Version basée sur **Xubuntu 24.04 LTS (Noble Numbat)**

## Créer une ISO Solibuntu 24.04

### Prérequis

Ces étapes doivent être réalisées sur un système Ubuntu/Xubuntu 24.04 (machine virtuelle ou physique).

### Installation

1. **Récupérez les sources de ce projet :**

```bash
git clone https://github.com/ersplus/Solibuntu-24.04.git
cd Solibuntu-24.04/
```

2. **Téléchargez l'image ISO de Xubuntu 24.04 64 bits :**

```bash
wget https://cdimage.ubuntu.com/xubuntu/releases/24.04/release/xubuntu-24.04-desktop-amd64.iso
```

3. **Installez les dépendances nécessaires :**

```bash
sudo apt-get update
sudo apt-get install squashfs-tools schroot xorriso syslinux-utils rsync
```

4. **Exécutez le script de création d'ISO :**

```bash
sudo chmod +x makeIsoRemasterSquashfs.sh
sudo ./makeIsoRemasterSquashfs.sh
```

Une interface graphique vous demandera de choisir entre la version **Master** (stable) ou **Dev** (développement).

5. **Créez une clé USB bootable :**

```bash
# Identifiez votre clé USB
lsblk

# Copiez l'ISO sur la clé (remplacez sdX par votre périphérique)
sudo dd if=solibuntu-24.04-master.iso of=/dev/sdX bs=4M status=progress && sync
```

### Utilisation

**Comptes par défaut après installation :**
- **Administrateur** : Login `administrateur` / Mot de passe `AdminSolibuntu`
- **Gestionnaire** : Login `gestionnaire` / Mot de passe `AdminAsso`

Une fois l'installation terminée, le filtrage parental peut être installé et est accessible depuis l'URL https://admin.ct.local/

## Scripts de création ISO

### makeIsoRemasterSquashfs.sh
Script principal pour construire l'image Solibuntu. Il :
- Extrait l'ISO Xubuntu 24.04
- Décompresse le système de fichiers
- Exécute les commandes de personnalisation en chroot
- Intègre les scripts Solibuntu
- Configure le preseed pour l'installation automatique
- Génère l'ISO finale bootable

### crt.sh
Contient les commandes exécutées en chroot dans l'ISO lors de sa fabrication :
- Création des utilisateurs administrateur et gestionnaire
- Installation des dépendances
- Exécution du script d'installation Solibuntu

### install_m.sh
Télécharge la version stable (Master) de Solibuntu et lance son installation.

### install_d.sh
Télécharge la version de développement de Solibuntu et lance son installation.

### preInstall.sh
Script exécuté avant le formatage du disque par l'installateur. Affiche des boîtes de dialogue d'avertissement et d'acceptation des licences.

### preseed.cfg
Fichier de configuration de l'installation automatique :
- Configuration locale (français, Europe/Paris)
- Partitionnement automatique
- Comptes utilisateurs
- Configuration réseau
- Appel du script d'installation Solibuntu

## Scripts Solibuntu

lightdm/*	Fichiers de configuration de lightdm.

lightdm.conf.d/*	Fichiers de configuration de lightdm.

bmConfigborne.sh	Gère l’interface administrateur/gestionnaire de configuration de la borne. Permet à l’utilisateur d’effectuer différentes actions, comme arrêter la borne, la mettre à jour, la redémarrer ou encore accéder à l’écran de démarrage des sessions administrateur ou gestionnaire...

bmConnectusb.sh	Écran d’accueil de Solibuntu. Vérifie si les identifiants sont toujours par défaut, propose de lancer la session invité et vérifie si la clé de démarrage de la machine est insérée.

bmGuestwrapper.sh	Affiche la charte d’utilisation du réseau lorsque la session invité est lancée.

bmLib.sh	Contient la plupart des fonctions utilisées dans les autres scripts.

bmLogout.sh	Script de fin de session, qui permet d’indiquer si on quitte la session administrateur ou gestionnaire.

bmRestoreInvite.sh	Restaure la configuration de lightdm lors de la fin de la session invité.

bmUsbin.sh	Tue le processus bmConnectusb.sh.

bmUsbout.sh	Ferme la session lors du retrait de la clé.

filtrage_install.sh	Script d’installation du filtrage.

filtrage_remove.sh	Script de désinstallation du filtrage.

install.sh	Script d’installation du projet Solibuntu. À lancer avec les arguments « maj » pour une mise à jour, « installation » pour une installation ou « iso » pour l’installation dans l’iso.

sessionStart.desktop	Lanceur du script sessionStart.sh. À placer dans le répertoir /etc/xdg/autostart/.
pour qu’il soit appelé au démarrage des sessions.
sessionStart.sh	Crée un fichier temporaire indiquant qu’une session a été lancée et écris « 1 » dans le fichier /root/.lastadminlogin si la session était administrateur ou gestionnaire.
