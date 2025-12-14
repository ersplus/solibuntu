# Guide de démarrage rapide - Solibuntu 24.04

## Création rapide d'une ISO Solibuntu

### En 5 étapes simples

```bash
# 1. Cloner le projet
git clone https://github.com/ersplus/Solibuntu-24.04.git
cd Solibuntu-24.04/

# 2. Télécharger Xubuntu 24.04
wget https://cdimage.ubuntu.com/xubuntu/releases/24.04/release/xubuntu-24.04-desktop-amd64.iso

# 3. Installer les dépendances
sudo apt update
sudo apt install squashfs-tools schroot xorriso syslinux-utils rsync zenity

# 4. Créer l'ISO
sudo ./makeIsoRemasterSquashfs.sh

# 5. Créer une clé USB bootable
sudo dd if=solibuntu-24.04-master.iso of=/dev/sdX bs=4M status=progress && sync
```

## Prochaines étapes

### Tester l'ISO

**En machine virtuelle (VirtualBox/VMware) :**
1. Créer une nouvelle VM avec 4 Go RAM minimum
2. Activer UEFI dans les paramètres (optionnel)
3. Monter l'ISO comme lecteur CD
4. Démarrer et tester l'installation

**Sur clé USB :**
1. Identifier la clé : `lsblk`
2. Copier l'ISO : `sudo dd if=solibuntu-24.04-master.iso of=/dev/sdX bs=4M status=progress`
3. Booter depuis la clé sur une machine de test

### Après installation

**Comptes par défaut :**
- Administrateur : `administrateur` / `AdminSolibuntu`
- Gestionnaire : `gestionnaire` / `AdminAsso`

**IMPORTANT :** Changez ces mots de passe après la première connexion !

### Installer le filtrage parental

```bash
sudo /opt/borne/scripts/filtrage_install.sh
```

Accès web : https://admin.ct.local/

## Structure du projet

```
Solibuntu-24.04/
├── makeIsoRemasterSquashfs.sh  # Script principal de création ISO
├── crt.sh                       # Commandes exécutées en chroot
├── preseed.cfg                  # Configuration installation automatique
├── preInstall.sh                # Script pré-installation
├── install_m.sh                 # Installation version Master
├── install_d.sh                 # Installation version Dev
├── scripts/                     # Scripts Solibuntu
│   ├── bmConfigborne.sh
│   ├── bmConnectusb.sh
│   ├── filtrage_install.sh
│   └── ...
└── share/                       # Ressources Solibuntu
    ├── Solibuntu.tar.bz2
    ├── config.tar.gz
    └── ...
```

## Personnalisation

### Modifier les utilisateurs

Éditez `crt.sh` pour changer les utilisateurs/mots de passe par défaut.

### Ajouter des paquets

Dans `crt.sh`, ajoutez vos paquets dans la section `apt-get install -y`.

### Personnaliser l'apparence

Modifiez les fichiers dans `share/config.tar.gz` pour personnaliser le thème, les icônes, etc.

## Dépannage

### L'ISO ne boot pas
- Vérifiez que xorriso est installé
- Testez en mode BIOS et UEFI
- Vérifiez les permissions des fichiers

### Erreur de permissions
```bash
sudo chown -R $USER:$USER /chemin/vers/Solibuntu-24.04
```

### Manque d'espace disque
La création de l'ISO nécessite environ 15 Go d'espace libre.

### Erreurs apt en chroot
Vérifiez votre connexion internet et que `/etc/resolv.conf` est correctement copié.

## Aide et support

- Documentation complète : [README.md](README.md)
- Changelog 24.04 : [CHANGELOG-24.04.md](CHANGELOG-24.04.md)
- Projet original : https://github.com/ersplus/ISO-solibuntu
- Site Solisol : https://solisol.org

## Développement

### Contribuer

1. Fork le projet sur GitHub
2. Créez une branche : `git checkout -b ma-fonctionnalite`
3. Committez : `git commit -am 'Ajout de ma fonctionnalité'`
4. Push : `git push origin ma-fonctionnalite`
5. Créez une Pull Request

### Tests recommandés

- [ ] Boot BIOS Legacy
- [ ] Boot UEFI
- [ ] Installation complète
- [ ] Sessions administrateur/gestionnaire
- [ ] Session invité
- [ ] Filtrage parental
- [ ] Scripts de configuration

## Licence

Voir le fichier [LICENSE](LICENSE) pour plus de détails.
