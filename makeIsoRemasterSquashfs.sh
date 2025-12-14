#!/bin/bash

### Projet Solisol.org               ###
### Solibuntu 24.04                  ###
### Création ISO Solibuntu           ###
### Adapté pour Xubuntu 24.04        ###
### $(date +%d/%m/%Y)                ###

# Choix de la branche pour générer l'ISO
choix=`zenity --list --radiolist --column "Choix" --column "Version" FALSE "Master" FALSE "Dev" --title="Solibuntu 24.04 - Génération ISO"`

# Définit dans quel dossier est exécuté le script : dossier courant
local=`pwd`

# Récupère l'iso, le fichier de preseed et les fichiers de configuration
iso="$local/xubuntu-24.04-desktop-amd64.iso"
preseed="$local/preseed.cfg"
txt="$local/txt.cfg"

case ${choix} in
	"Master")
		postInstall="$local/install_m.sh"
	;;
	"Dev")
		postInstall="$local/install_d.sh"
	;;
	*)
		echo "Aucune version sélectionnée. Arrêt."
		exit 1
	;;
esac

preInstall="$local/preInstall.sh"

# Vérification des prérequis
echo "==========================================="
echo "Vérification des prérequis..."
echo "==========================================="
required_packages="squashfs-tools schroot xorriso"
missing_packages=""

for pkg in $required_packages; do
	if ! dpkg -l | grep -q "^ii  $pkg"; then
		missing_packages="$missing_packages $pkg"
	fi
done

if [ -n "$missing_packages" ]; then
	echo "Les paquets suivants doivent être installés :$missing_packages"
	echo "Exécutez : sudo apt install$missing_packages"
	exit 1
fi

# Vérification de l'ISO
if [ ! -f "$iso" ]; then
	echo "Erreur : ISO Xubuntu 24.04 introuvable : $iso"
	echo "Téléchargez-la avec :"
	echo "wget https://cdimage.ubuntu.com/xubuntu/releases/24.04/release/xubuntu-24.04-desktop-amd64.iso"
	exit 1
fi

echo "Tous les prérequis sont installés."
echo ""

# Nettoyage des dossiers précédents si existants
echo "Nettoyage des dossiers de travail..."
rm -rf $local/FichierIso
rm -rf $local/squashfs

# Décompresse l'iso dans le dossier "FichierIso"
echo "==========================================="
echo "Extraction de l'ISO..."
echo "==========================================="
mkdir -p $local/FichierIso

# Monte l'iso
mount -o loop $iso /mnt

# Copie le contenu
rsync -av /mnt/ $local/FichierIso/

# Démonte /mnt
umount /mnt

# Crée le dossier squashfs
echo "==========================================="
echo "Extraction du filesystem..."
echo "==========================================="
mkdir -p $local/squashfs

# Monte le filesystem
mount -t squashfs -o loop $local/FichierIso/casper/filesystem.squashfs /mnt

# Récupère les fichiers
rsync -av /mnt/ $local/squashfs/

# Démonte le squashfs
umount /mnt

#-----------------------------------------------------------
# Modification du système de fichier préinstallé
#-----------------------------------------------------------
echo "==========================================="
echo "Préparation de Solibuntu..."
echo "==========================================="

# Rajoute les fichiers du projet Solibuntu
mkdir -p $local/squashfs/Solibuntu/

# Copie les scripts d'installation
cp -rv $local/scripts $local/squashfs/Solibuntu/
cp -rv $local/share $local/squashfs/Solibuntu/

# Déplace le script de post install dans le dossier Solibuntu
cp -v $postInstall $local/squashfs/Solibuntu/install.sh

#-----------------------------------------------------------
# Configuration chroot pour personnalisation
#-----------------------------------------------------------
echo "==========================================="
echo "Configuration du chroot..."
echo "==========================================="

echo "Montage des systèmes de fichiers..."
mount --bind /proc $local/squashfs/proc 
mount --bind /sys $local/squashfs/sys
mount -t devpts none $local/squashfs/dev/pts
mount --bind /dev $local/squashfs/dev
mount --bind /dev/pts $local/squashfs/dev/pts

echo "Copie des fichiers de configuration réseau..."
cp /etc/resolv.conf $local/squashfs/etc/resolv.conf
cp /etc/hosts $local/squashfs/etc/hosts

echo "Lancement des commandes en chroot..."
cd $local

# Exécute les commandes de personnalisation
bash < crt.sh

echo "Démontage des systèmes de fichiers..."
umount -lf $local/squashfs/sys
umount -lf $local/squashfs/proc
umount -lf $local/squashfs/dev/pts
umount -lf $local/squashfs/dev

echo "Nettoyage..."
rm -f $local/squashfs/etc/resolv.conf
rm -f $local/squashfs/etc/hosts

echo "==========================================="
echo "Mise à jour du manifest..."
echo "==========================================="
chmod a+w $local/FichierIso/casper/filesystem.manifest
chroot $local/squashfs dpkg-query -W --showformat='${Package} ${Version}\n' > $local/FichierIso/casper/filesystem.manifest
chmod go-w $local/FichierIso/casper/filesystem.manifest

#-----------------------------------------------------------
# Reconstruction du filesystem
#-----------------------------------------------------------
echo "==========================================="
echo "Reconstruction du filesystem..."
echo "==========================================="

# Efface l'ancien filesystem
rm -f $local/FichierIso/casper/filesystem.squashfs

# Recrée un nouveau filesystem avec compression optimale
cd $local/squashfs
mksquashfs . ../FichierIso/casper/filesystem.squashfs -comp xz -b 1M
cd $local

# Mise à jour de la taille du filesystem
printf $(du -sx --block-size=1 $local/squashfs | cut -f1) > $local/FichierIso/casper/filesystem.size

#-----------------------------------------------------------
# Configuration de l'installateur
#-----------------------------------------------------------
echo "==========================================="
echo "Configuration de l'installateur..."
echo "==========================================="

# Remplace le fichier de preseed
if [ -f "$preseed" ]; then
	cp $preseed $local/FichierIso/preseed/xubuntu.seed
fi

# Copie le script de pre-installation
if [ -f "$preInstall" ]; then
	cp $preInstall $local/FichierIso/preInstall.sh
	chmod +x $local/FichierIso/preInstall.sh
fi

#-----------------------------------------------------------
# Génération de l'ISO finale
#-----------------------------------------------------------
echo "==========================================="
echo "Génération de l'ISO..."
echo "==========================================="

# Régénère la somme de contrôle MD5
cd $local/FichierIso
find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt

# Crée l'ISO selon la version choisie
cd $local/FichierIso
case ${choix} in
	"Master")
		output_iso="$local/solibuntu-24.04-master.iso"
	;;
	"Dev")
		output_iso="$local/solibuntu-24.04-dev.iso"
	;;
esac

# Utilise xorriso pour créer l'ISO bootable (remplace genisoimage pour 24.04)
xorriso -as mkisofs \
	-iso-level 3 \
	-full-iso9660-filenames \
	-volid "Solibuntu 24.04" \
	-output "$output_iso" \
	-eltorito-boot boot/grub/bios.img \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		--eltorito-catalog boot/grub/boot.cat \
		--grub2-boot-info \
		--grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
	-eltorito-alt-boot \
		-e EFI/BOOT/mmx64.efi \
		-no-emul-boot \
	-append_partition 2 0xef FichierIso/boot/grub/efi.img \
	-m "isolinux" \
	.

# Rend l'ISO hybride pour clé USB
isohybrid --uefi "$output_iso" 2>/dev/null || echo "Note: isohybrid non disponible, l'ISO reste bootable"

#-----------------------------------------------------------
# Nettoyage final
#-----------------------------------------------------------
echo "==========================================="
echo "Nettoyage..."
echo "==========================================="

cd $local/
rm -rf FichierIso/ 
rm -rf squashfs/

echo "==========================================="
echo "ISO créée avec succès !"
echo "==========================================="
echo "Fichier: $output_iso"
echo ""
echo "Pour copier sur une clé USB :"
echo "sudo dd if=$output_iso of=/dev/sdX bs=4M status=progress && sync"
echo "(Remplacez sdX par votre périphérique USB)"
