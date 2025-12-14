# Changelog Solibuntu 24.04

## Adaptations pour Xubuntu 24.04 LTS

### Changements majeurs par rapport à la version 18.04

#### 1. Processus de création ISO

**Avant (18.04):**
- Utilisation de `genisoimage` pour créer l'ISO
- Bootloader : isolinux/syslinux
- Fichier de configuration : `isolinux.cfg`

**Maintenant (24.04):**
- Utilisation de `xorriso` (remplace genisoimage, obsolète)
- Bootloader : GRUB2 (BIOS et UEFI)
- Support UEFI natif avec Secure Boot
- Fichiers de configuration GRUB dans `/boot/grub/`

#### 2. Système de fichiers

**Compression SquashFS :**
- 18.04 : Compression gzip par défaut
- 24.04 : Compression XZ avec `-comp xz -b 1M` pour une meilleure compression

**Manifest :**
- Ajout du fichier `filesystem.size` pour indiquer la taille du système de fichiers

#### 3. Dépendances

**Paquets mis à jour :**
```bash
# Ancienne version (18.04)
squashfs-tools schroot genisoimage syslinux-utils

# Nouvelle version (24.04)
squashfs-tools schroot xorriso syslinux-utils rsync
```

#### 4. Structure de l'ISO

**Changements de structure :**
- `/isolinux/` → `/boot/grub/` (changement de bootloader)
- Ajout de `/EFI/BOOT/` pour le support UEFI
- Partition EFI séparée dans l'ISO

#### 5. Preseed et installation

**Compatibilité maintenue :**
- Le fichier `preseed.cfg` reste compatible
- Ubiquity (installateur Ubuntu) fonctionne de manière similaire
- Les scripts `preInstall.sh` et post-installation sont compatibles

**Points d'attention :**
- Vérifier la compatibilité des chemins dans preseed
- Tester l'installation en mode BIOS et UEFI

### Améliorations apportées

1. **Script makeIsoRemasterSquashfs.sh :**
   - Vérification automatique des prérequis
   - Messages d'erreur plus explicites
   - Nettoyage automatique des dossiers temporaires
   - Support UEFI complet
   - Meilleure gestion des erreurs

2. **Script crt.sh :**
   - Utilisation de heredoc pour le chroot
   - Meilleure gestion de DEBIAN_FRONTEND
   - Nettoyage plus complet du système

3. **Documentation :**
   - README.md mis à jour pour 24.04
   - Instructions claires et détaillées
   - Commandes testées et vérifiées

### Tests recommandés

Avant de déployer l'ISO Solibuntu 24.04, testez :

1. **Boot en BIOS Legacy**
   - Machine virtuelle avec BIOS
   - Clé USB sur machine physique BIOS

2. **Boot en UEFI**
   - Machine virtuelle avec UEFI
   - Clé USB sur machine physique UEFI
   - Tester avec et sans Secure Boot

3. **Installation complète**
   - Partitionnement automatique
   - Création des utilisateurs
   - Exécution du script d'installation Solibuntu
   - Vérification du filtrage parental

4. **Fonctionnalités Solibuntu**
   - Session administrateur
   - Session gestionnaire
   - Session invité
   - Gestion de la clé USB
   - Scripts de configuration

### Migration depuis 18.04

Si vous avez une version Solibuntu basée sur 18.04 :

1. **Sauvegardez vos données et configurations**
2. **Créez une nouvelle ISO 24.04**
3. **Testez en machine virtuelle avant déploiement**
4. **Les scripts Solibuntu dans `/opt/borne/scripts/` sont compatibles**

### Problèmes connus et solutions

#### Problème : xorriso non trouvé
```bash
sudo apt install xorriso
```

#### Problème : Erreur de permissions
```bash
sudo chown -R $USER:$USER /opt/borne
```

#### Problème : ISO non bootable
- Vérifier que tous les fichiers GRUB sont présents
- Vérifier la partition EFI
- Utiliser `isohybrid --uefi` pour rendre l'ISO hybride

### Ressources

- Documentation Ubuntu 24.04 : https://help.ubuntu.com/24.04/
- Xubuntu 24.04 Release Notes : https://xubuntu.org/release/24-04/
- ISO Remastering : https://help.ubuntu.com/community/LiveCDCustomization
- Projet Solisol : https://solisol.org

### Contributeurs

Basé sur le travail original de ISO-solibuntu pour Xubuntu 18.04
Adapté pour Xubuntu 24.04 LTS - $(date +%Y)
