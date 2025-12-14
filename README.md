# Solibuntu Xubuntu 24.04

![Xubuntu 24.04](https://img.shields.io/badge/Xubuntu-24.04%20%28Noble%29-blue)
![Release](https://img.shields.io/badge/Release-v0.5.0-brightgreen)
![License](https://img.shields.io/badge/License-GPL--3.0-green)

**Solibuntu** : une **SOLution Informatique SOLidaire** pour les associations du secteur social.

**Projet :** https://solisol.org

Version basée sur **Xubuntu 24.04 LTS (Noble Numbat)**

## 🚀 Fonctionnalités v0.5.0

- ✅ **Compatible Xubuntu 24.04 (Noble)** - Support complet et testé
- ✅ **Affichage du fond d'écran adaptatif** - Redimensionnement automatique selon la résolution
- ✅ **Activation automatique de NumLock** - NumLock activé au démarrage
- ✅ **Installation automatique des prérequis** - Sans confirmation utilisateur
- ✅ **Gestion des clés USB sécurisée** - Avec identifiants uniques
- ✅ **Filtrage parental** - Avec CTParental
- ✅ **Code amélioré et documenté** - Lisibilité et maintenabilité
- ✅ **Versioning GitHub** - Releases stables et binaires

## 📋 Installation Rapide

### 🖥️ Installation sur Borne (depuis LiveCD)

```bash
# La borne télécharge automatiquement la dernière version
# depuis GitHub et l'installe

sudo bash /opt/borne/install_m.sh
```

### 💾 Installation Manuelle

```bash
# Télécharger la release v0.5.0
wget https://github.com/ersplus/Solibuntu-24.04/releases/download/v0.5.0/solibuntu-xubuntu-24.04.zip

# Extraire et installer
unzip solibuntu-xubuntu-24.04.zip
cd solibuntu-xubuntu-24.04
sudo bash scripts/install.sh
```

## 📦 Versions et Téléchargements

### v0.5.0 - Stable (14/12/2025)

**Changements :**
- Support complet Xubuntu 24.04 (Noble)
- Nitrogen pour fond d'écran adaptatif
- NumLock activation automatique
- ImageMagick redimensionnement images
- Installation prérequis sans confirmation
- Code amélioré et documenté
- GitHub releases configurées

**Liens de téléchargement :**
- 📥 [solibuntu-xubuntu-24.04.zip](https://github.com/ersplus/Solibuntu-24.04/releases/download/v0.5.0/solibuntu-xubuntu-24.04.zip) (44 MB)
- 🔗 [Release v0.5.0](https://github.com/ersplus/Solibuntu-24.04/releases/tag/v0.5.0)

## 📂 Structure du Projet

```
/opt/borne/
├── scripts/
│   ├── bmConnectusb.sh        # Écran d'accueil et connexion USB
│   ├── bmConfigborne.sh       # Interface de configuration
│   ├── bmLib.sh               # Bibliothèque commune
│   ├── install.sh             # Installation principale
│   ├── install_m.sh           # Installation depuis GitHub
│   ├── install_d.sh           # Installation dev
│   ├── filtrage_install.sh    # Installation filtrage parental
│   ├── filtrage_remove.sh     # Désinstallation filtrage
│   ├── sessionStart.sh        # Initialisation de session
│   ├── bmLogout.sh            # Fermeture de session
│   ├── bmGuestwrapper.sh      # Charte d'utilisation invité
│   └── lightdm/               # Configuration LightDM
├── share/
│   ├── background.png         # Fond d'écran
│   ├── connectUSB.jpg         # Image connexion USB
│   ├── charte.html            # Charte d'utilisation
│   ├── ctparental.deb         # Filtrage parental
│   ├── sudoers                # Configuration sudo
│   └── xfce4/                 # Configuration XFCE
├── releases/
│   └── solibuntu-xubuntu-24.04.zip   # Archive release v0.5.0
├── install_m.sh               # Installation Master (release)
├── install_d.sh               # Installation Dev
├── makeIsoRemasterSquashfs.sh # Générateur d'ISO
├── preInstall.sh              # Script pré-installation
├── README.md                  # Cette documentation
└── LICENSE                    # GPL-3.0
```

## 🔑 Configuration de Base

### Comptes par défaut

| Compte | Identifiant | Mot de passe | Rôle |
|--------|-------------|--------------|------|
| Administrateur | `administrateur` | `AdminSolibuntu` | Gestion complète |
| Gestionnaire | `gestionnaire` | `AdminAsso` | Configuration borne |
| Invité | `guest` | - | Accès public |

**⚠️ Important :** Changez ces mots de passe après l'installation !

### Clés USB

Configuration de l'identifiant unique de la borne :

```bash
# Créer le fichier de configuration
sudo touch /root/.uniqUSBKEY

# Format : NUMERO_SERIE_PC:NUMERO_SERIE_CLE
# Exemple :
echo "QWERTY123456:ABCDEF789" | sudo tee /root/.uniqUSBKEY
```

La détection se fait sur `/dev/sdb` ou `/dev/sdc`.

## 🎨 Interface et Affichage

### Fond d'écran Adaptatif

Le script `bmConnectusb.sh` configure automatiquement :

```bash
# Détection résolution écran
# Redimensionnement image avec ImageMagick
# Affichage via nitrogen
# Cache image redimensionnée

# Fichiers utilisés :
/opt/borne/share/background.png          # Original
/tmp/background_1920x1080.png            # Redimensionné
```

**Paquets requis :**
- `nitrogen` - Affichage fond d'écran
- `imagemagick` - Redimensionnement images
- `numlockx` - Activation NumLock
- `yad` - Dialogues texte formaté
- `zenity` - Dialogues simples

### Configuration XFCE

Fichiers de configuration XFCE :
```
share/xfce4/xfconf/xfce-perchannel-xml/
├── keyboards.xml
├── thunar.xml
├── xfce4-desktop.xml
├── xfce4-keyboard-shortcuts.xml
├── xfce4-panel.xml
└── xfwm4.xml
```

## 🔒 Filtrage Parental

Installation CTParental :

```bash
sudo bash /opt/borne/scripts/filtrage_install.sh
```

Accès web :
- URL : https://admin.ct.local/
- Port : 8080 (ou configuré)

## 🖥️ Générer une ISO Personnalisée

### Prérequis

```bash
sudo apt install \
  squashfs-tools \
  xorriso \
  schroot \
  wget \
  zenity \
  rsync
```

### Génération

```bash
cd /chemin/vers/script
sudo chmod +x makeIsoRemasterSquashfs.sh
sudo ./makeIsoRemasterSquashfs.sh
```

Le script proposera :
- **Master** : Version stable (release v0.5.0)
- **Dev** : Version développement

### Résultat

```bash
solibuntu-24.04-master.iso    # ~2.5 GB
solibuntu-24.04-dev.iso       # ~2.5 GB
```

## 💾 Créer une Clé USB Bootable

```bash
# Identifier votre clé
lsblk

# Copier l'ISO (remplacez sdX)
sudo dd if=solibuntu-24.04-master.iso of=/dev/sdX bs=4M status=progress && sync

# Support UEFI et Legacy BIOS
```

## 🚀 Scripts Principaux

### `bmConnectusb.sh`
**Écran d'accueil de la borne**
- Affichage du fond d'écran
- Activation NumLock
- Dialogue connexion USB
- Vérification clés USB
- Authentification configuration

### `install_m.sh`
**Installation depuis release GitHub**
- Télécharge solibuntu-xubuntu-24.04.zip
- Extrait l'archive
- Lance les scripts d'installation
- Version stable (v0.5.0)

### `install_d.sh`
**Installation depuis branche dev**
- Télécharge depuis la branche dev
- Version de développement
- Actualisations plus fréquentes

### `makeIsoRemasterSquashfs.sh`
**Générateur d'ISO bootable**
- Télécharge Xubuntu 24.04 auto
- Extrait et personnalise
- Intègre Solibuntu
- Génère ISO hybrid (USB + DVD)

### `filtrage_install.sh`
**Installation filtrage parental**
- Détecte version Ubuntu
- Installe CTParental
- Configuration preseed

## 📊 Logs et Débogage

### Fichiers logs

```bash
/var/log/syslog              # Logs système complets
/var/log/lightdm/            # Logs LightDM
/tmp/                        # Fichiers temporaires
/tmp/background_*            # Images redimensionnées
```

### Débogage

```bash
# Voir les logs en temps réel
sudo tail -f /var/log/syslog | grep -i "borne\|bmConnect\|nitrogen"

# Tester nitrogen
nitrogen --set-zoom-fill /opt/borne/share/background.png

# Tester NumLock
numlockx on

# Tester détection clé USB
udevadm info --name=/dev/sdb
```

## 📚 Dépôts GitHub

### Code Source
- **URL** : https://github.com/ersplus/solibuntu
- **Branche** : `xubuntu-24.04`
- **Tag** : `v0.5.0`

### Releases Binaires
- **URL** : https://github.com/ersplus/Solibuntu-24.04
- **Release** : [v0.5.0](https://github.com/ersplus/Solibuntu-24.04/releases/tag/v0.5.0)
- **Archive** : solibuntu-xubuntu-24.04.zip (44 MB)

### Git Configuration

```bash
# Remotes
origin          → github.com/ersplus/solibuntu (code)
solibuntu-24    → github.com/ersplus/Solibuntu-24.04 (releases)

# Branches
main            → Branche principale
xubuntu-24.04   → Branche pour Xubuntu 24.04

# Tags
v0.5.0          → Release stable
```

## 🔄 Mise à Jour

Depuis une borne installée :

```bash
# Installation Master (dernière release)
sudo bash /opt/borne/install_m.sh

# Depuis le LiveCD/USB :
# Le disque dur est formaté à chaque installation
```

## 🐛 Troubleshooting

### Fond d'écran ne s'affiche pas

```bash
# Vérifier installation
sudo apt install nitrogen imagemagick

# Tester manuellement
nitrogen --set-zoom-fill /opt/borne/share/background.png

# Vérifier les logs
grep -i nitrogen /var/log/syslog
```

### NumLock non activé

```bash
# Installer
sudo apt install numlockx

# Tester
numlockx on
numlockx status
```

### Clé USB non détectée

```bash
# Vérifier configuration
cat /root/.uniqUSBKEY

# Tester détection
udevadm info --name=/dev/sdb
udevadm info --name=/dev/sdc

# Voir les logs
sudo dmesg | tail -20
```

### Filtrage parental ne fonctionne pas

```bash
# Vérifier installation
dpkg -l | grep ctparental

# Tester le service
sudo systemctl status ctparental

# Réinstaller
sudo bash /opt/borne/scripts/filtrage_install.sh
```

## 📄 Licence

Solibuntu est distribué sous la licence **GPL-3.0**.

Voir le fichier `LICENSE` pour les détails complets.

## 👥 Contribuer

Les contributions sont bienvenues !

1. **Fork** le dépôt
2. **Branch** feature (`git checkout -b feature/ma-fonction`)
3. **Commit** (`git commit -m 'Ajout de ...'`)
4. **Push** (`git push origin feature/ma-fonction`)
5. **Pull Request**

## 📞 Support et Contact

- 🐛 **Issues** : https://github.com/ersplus/solibuntu/issues
- 📧 **Email** : admin@solibuntu.local
- 🌐 **Web** : https://solisol.org

## 📅 Historique des Versions

### v0.5.0 (14/12/2025)
- ✅ Support Xubuntu 24.04 (Noble)
- ✅ Nitrogen fond d'écran adaptatif
- ✅ NumLock automatique
- ✅ ImageMagick redimensionnement
- ✅ Installation prérequis automatique
- ✅ Code amélioré et documenté
- ✅ GitHub releases configurées
- ✅ Git avec versioning proper

### v0.4.x et antérieures
- Support versions Ubuntu antérieures
- Utilisation feh pour affichage

---

**Dernière mise à jour :** 14 décembre 2025  
**Version actuelle :** v0.5.0  
**Statut :** ✅ **Production Ready**

Merci d'utiliser **Solibuntu** ! 🎉
