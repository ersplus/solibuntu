#!/bin/bash

### Projet Solisol.org               ###
### Solibuntu 24.04                  ###
### Création ISO Solibuntu           ###
### Adapté pour Xubuntu 24.04        ###
### $(date +%d/%m/%Y)                ###

# Configuration stricte du script
set -euo pipefail

# Variables de logging
LOG_FILE="/tmp/solibuntu-iso-$(date +%Y%m%d-%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

# Fonction de gestion des erreurs
cleanup_on_error() {
	local exit_code=$?
	local line_number=$1
	
	echo ""
	echo "❌ ERREUR : Le script s'est arrêté à la ligne $line_number (code: $exit_code)"
	echo "Logs disponibles : $LOG_FILE"
	echo ""
	
	# Démontage d'urgence
	echo "Nettoyage des montages..."
	umount -lf "$local/squashfs/sys" 2>/dev/null || true
	umount -lf "$local/squashfs/proc" 2>/dev/null || true
	umount -lf "$local/squashfs/dev/pts" 2>/dev/null || true
	umount -lf "$local/squashfs/dev" 2>/dev/null || true
	umount -lf /mnt 2>/dev/null || true
	
	exit "$exit_code"
}

# Enregistrement du trap
trap 'cleanup_on_error ${LINENO}' ERR

# Fonction de logging avec timestamp
log_info() {
	echo "[$(date +'%Y-%m-%d %H:%M:%S')] ℹ️  $*"
}

log_success() {
	echo "[$(date +'%Y-%m-%d %H:%M:%S')] ✓ $*"
}

log_warning() {
	echo "[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️  $*"
}

log_error() {
	echo "[$(date +'%Y-%m-%d %H:%M:%S')] ❌ $*" >&2
}

# Choix de la branche pour générer l'ISO
log_info "Sélection de la version..."
choix=$(zenity --list --radiolist --column "Choix" --column "Version" FALSE "Main" FALSE "Dev" --title="Solibuntu 24.04 - Génération ISO")

# Définit dans quel dossier est exécuté le script : dossier courant
local=$(pwd)

# Récupère l'iso, le fichier de preseed et les fichiers de configuration
iso="$local/xubuntu-24.04.3-desktop-amd64.iso"
iso_sha256="$local/SHA256SUMS"
preseed="$local/preseed.cfg"
txt="$local/txt.cfg"

case "${choix}" in
	"Main")
		postInstall="$local/install_m.sh"
	;;
	"Dev")
		postInstall="$local/install_d.sh"
	;;
	*)
		log_error "Aucune version sélectionnée. Arrêt."
		exit 1
	;;
esac

preInstall="$local/preInstall.sh"

# Vérification et chargement du module loop
log_info "Vérification du module loop..."
if ! lsmod | grep -q "^loop"; then
	log_warning "Module loop non chargé, chargement en cours..."
	if sudo modprobe loop; then
		log_success "Module loop chargé"
	else
		log_error "Impossible de charger le module loop"
		exit 1
	fi
else
	log_success "Module loop disponible"
fi

# Vérification des prérequis
log_info "Vérification des prérequis..."
required_packages="squashfs-tools schroot xorriso wget imagemagick"
missing_packages=""

for pkg in $required_packages; do
	if ! dpkg -l | grep -q "^ii  $pkg"; then
		missing_packages="$missing_packages $pkg"
	fi
done

if [ -n "$missing_packages" ]; then
	log_warning "Les paquets suivants vont être installés :$missing_packages"
	log_info "Installation en cours..."
	
	# Installation automatique avec apt-get
	if sudo apt-get update && sudo apt-get install -y $missing_packages; then
		log_success "Installation des prérequis réussie"
	else
		log_error "Erreur lors de l'installation des prérequis"
		log_error "Exécutez manuellement : sudo apt-get install$missing_packages"
		exit 1
	fi
else
	log_success "Tous les prérequis sont installés."
fi

log_info ""
log_info "Vérification et téléchargement de l'ISO si nécessaire..."

if [ ! -f "$iso" ]; then
	log_warning "ISO Xubuntu 24.04 introuvable."
	log_info "Téléchargement automatique en cours..."
	
	iso_url="https://cdimage.ubuntu.com/xubuntu/releases/24.04/release/xubuntu-24.04.3-desktop-amd64.iso"
	sha256_url="https://cdimage.ubuntu.com/xubuntu/releases/24.04/release/SHA256SUMS"
	
	log_info "Téléchargement depuis : $iso_url"
	log_info "Taille attendue : ~3.5 Go"
	log_info "Cela peut prendre plusieurs minutes selon votre connexion..."
	
	wget --progress=bar:force:noscroll -c "$iso_url" -O "$iso"
	
	log_success "Téléchargement terminé."
	
	# Télécharger aussi les SHA256SUMS pour validation
	log_info "Téléchargement des checksums SHA256..."
	wget -q "$sha256_url" -O "$iso_sha256" || log_warning "Impossible de télécharger les checksums"
	
	# Vérifier la taille du fichier (l'ISO doit faire au moins 2 Go)
	file_size=$(stat -c%s "$iso" 2>/dev/null || echo "0")
	min_size=$((2 * 1024 * 1024 * 1024))  # 2 Go en octets
	
	if [ "$file_size" -lt "$min_size" ]; then
		log_error "La taille du fichier téléchargé semble incorrecte."
		log_error "Taille téléchargée : $(du -h "$iso" | cut -f1)"
		log_error "Taille minimale attendue : 2 Go"
		exit 1
	fi
else
	log_success "ISO Xubuntu 24.04 trouvée : $iso"
	log_info "Taille : $(du -h "$iso" | cut -f1)"
fi

# Validation SHA256 si disponible
if [ -f "$iso_sha256" ]; then
	log_info "Validation SHA256 de l'ISO..."
	if grep "xubuntu-24.04-desktop-amd64.iso" "$iso_sha256" | sha256sum -c --quiet 2>/dev/null; then
		log_success "Checksum SHA256 valide"
	else
		log_warning "Checksum SHA256 invalide ou non trouvé, continuant quand même..."
	fi
else
	log_info "Fichier SHA256SUMS non disponible, vérification ignorée"
fi

log_info ""

# Nettoyage des dossiers précédents si existants
log_info "Nettoyage des dossiers de travail..."
rm -rf "$local/FichierIso"
rm -rf "$local/squashfs"

# Décompresse l'iso dans le dossier "FichierIso"
log_info "Extraction de l'ISO..."
mkdir -p "$local/FichierIso"

# Monte l'iso
mount -o loop "$iso" /mnt
# Copie le contenu avec rsync
rsync -av /mnt/ "$local/FichierIso/" 2>&1 | tail -20
# Démonte /mnt
umount /mnt
log_success "ISO extraite."

# Crée le dossier squashfs
log_info "Extraction du filesystem..."
mkdir -p "$local/squashfs"

# Déterminer le fichier squashfs à utiliser (structure Xubuntu 24.04.3)
SQUASHFS_FILE=""
if [ -f "$local/FichierIso/casper/filesystem.squashfs" ]; then
	SQUASHFS_FILE="$local/FichierIso/casper/filesystem.squashfs"
	log_info "Utilisation de filesystem.squashfs"
elif [ -f "$local/FichierIso/casper/minimal.standard.live.squashfs" ]; then
	SQUASHFS_FILE="$local/FichierIso/casper/minimal.standard.live.squashfs"
	log_info "Utilisation de minimal.standard.live.squashfs (Xubuntu 24.04.3+)"
else
	log_error "Aucun fichier squashfs trouvé dans casper/"
	exit 1
fi

# Monte le filesystem
mount -t squashfs -o loop "$SQUASHFS_FILE" /mnt
# Récupère les fichiers
rsync -av /mnt/ "$local/squashfs/" 2>&1 | tail -20
# Démonte le squashfs
umount /mnt
log_success "Filesystem extrait."

#-----------------------------------------------------------
# Modification du système de fichier préinstallé
#-----------------------------------------------------------
log_info "Préparation de Solibuntu..."

# Rajoute les fichiers du projet Solibuntu
mkdir -p "$local/squashfs/Solibuntu/"

# Copie les scripts d'installation
cp -rv "$local/scripts" "$local/squashfs/Solibuntu/"
cp -rv "$local/share" "$local/squashfs/Solibuntu/"

# Déplace le script de post install dans le dossier Solibuntu
cp -v "$postInstall" "$local/squashfs/Solibuntu/install.sh"

log_success "Fichiers Solibuntu copiés."

#-----------------------------------------------------------
# Thème Plymouth personnalisé (splash au boot)
#-----------------------------------------------------------
log_info "Installation du thème Plymouth 'pix' avec splash personnalisé..."

# Dossier thème cible
PLYMOUTH_THEME_DIR="$local/squashfs/usr/share/plymouth/themes/pix"
mkdir -p "$PLYMOUTH_THEME_DIR"

# Copier les fichiers de thème
cp -v "$local/share/pix/pix.plymouth" "$PLYMOUTH_THEME_DIR/pix.plymouth"
cp -v "$local/share/pix/pix.script" "$PLYMOUTH_THEME_DIR/pix.script"

# Générer/adapter l'image splash.png
SPLASH_SRC_PNG="$local/share/splash.png"
SPLASH_SRC_XCF="$local/share/splash.xcf"
SPLASH_DST="$PLYMOUTH_THEME_DIR/splash.png"

if [ -f "$SPLASH_SRC_PNG" ]; then
	log_info "Utilisation de share/splash.png comme source"
	convert "$SPLASH_SRC_PNG" -background black -alpha remove -alpha off -resize 1920x1080\> -strip "$SPLASH_DST"
elif [ -f "$SPLASH_SRC_XCF" ]; then
	log_info "Conversion de share/splash.xcf en PNG"
	convert "$SPLASH_SRC_XCF" -background black -flatten -resize 1920x1080\> -strip "$SPLASH_DST"
else
	log_warning "Aucun splash.png ou splash.xcf trouvé dans share/. Utilisation du fichier présent si disponible."
	# Si aucun fichier source, laisser tel quel; le thème attend splash.png
fi

if [ -f "$SPLASH_DST" ]; then
	log_success "splash.png installé dans le thème Plymouth"
else
	log_warning "splash.png manquant dans le thème Plymouth; le thème pourrait ne pas s'afficher."
fi

#-----------------------------------------------------------
# Configuration chroot pour personnalisation
#-----------------------------------------------------------
log_info "Configuration du chroot..."

log_info "Montage des systèmes de fichiers..."
mount --bind /proc "$local/squashfs/proc" 
mount --bind /sys "$local/squashfs/sys"
mount -t devpts none "$local/squashfs/dev/pts"
mount --bind /dev "$local/squashfs/dev"
mount --bind /dev/pts "$local/squashfs/dev/pts"

log_info "Copie des fichiers de configuration réseau..."
cp /etc/resolv.conf "$local/squashfs/etc/resolv.conf"
cp /etc/hosts "$local/squashfs/etc/hosts"

log_info "Lancement des commandes en chroot..."
cd "$local"

# Exécute les commandes de personnalisation
bash < crt.sh

# Applique le thème Plymouth 'pix' par défaut et régénère l'initramfs
log_info "Activation du thème Plymouth 'pix' dans le chroot..."
if chroot "$local/squashfs" plymouth-set-default-theme pix 2>/dev/null; then
	log_success "Thème Plymouth défini"
	chroot "$local/squashfs" update-initramfs -u || log_warning "Échec update-initramfs, continuant"
else
	log_warning "plymouth-set-default-theme non disponible; le thème pourrait ne pas être activé"
fi

log_info "Démontage des systèmes de fichiers..."
umount -lf "$local/squashfs/sys"
umount -lf "$local/squashfs/proc"
umount -lf "$local/squashfs/dev/pts"
umount -lf "$local/squashfs/dev"

log_info "Nettoyage..."
rm -f "$local/squashfs/etc/resolv.conf"
rm -f "$local/squashfs/etc/hosts"

log_success "Chroot terminé."

log_info "Mise à jour du manifest..."
# Déterminer le fichier manifest à mettre à jour
MANIFEST_FILE="$local/FichierIso/casper/filesystem.manifest"
if [ ! -f "$MANIFEST_FILE" ] && [ -f "$local/FichierIso/casper/minimal.standard.live.manifest" ]; then
	MANIFEST_FILE="$local/FichierIso/casper/minimal.standard.live.manifest"
fi

chmod a+w "$MANIFEST_FILE"
chroot "$local/squashfs" dpkg-query -W --showformat='${Package} ${Version}\n' > "$MANIFEST_FILE"
chmod go-w "$MANIFEST_FILE"
log_success "Manifest mis à jour."

#-----------------------------------------------------------
# Reconstruction du filesystem
#-----------------------------------------------------------
log_info "Reconstruction du filesystem..."

# Déterminer le fichier squashfs de sortie (selon version détectée)
OUTPUT_SQUASHFS=""
OUTPUT_SIZE=""
if [ -f "$local/FichierIso/casper/filesystem.squashfs" ] || [ ! -f "$local/FichierIso/casper/minimal.standard.live.squashfs" ]; then
	OUTPUT_SQUASHFS="$local/FichierIso/casper/filesystem.squashfs"
	OUTPUT_SIZE="$local/FichierIso/casper/filesystem.size"
	log_info "Mode: filesystem.squashfs (classique)"
else
	OUTPUT_SQUASHFS="$local/FichierIso/casper/minimal.standard.live.squashfs"
	OUTPUT_SIZE="$local/FichierIso/casper/minimal.standard.live.size"
	log_info "Mode: minimal.standard.live.squashfs (Xubuntu 24.04.3+)"
fi

# Efface l'ancien filesystem
rm -f "$OUTPUT_SQUASHFS"

# Recrée un nouveau filesystem avec compression optimale
cd "$local/squashfs"
log_info "Compression avec mksquashfs (xz)..."
mksquashfs . "$OUTPUT_SQUASHFS" -comp xz -b 1M -progress
cd "$local"

# Mise à jour de la taille du filesystem
filesystem_size=$(du -sx --block-size=1 "$local/squashfs" | cut -f1)
printf "%s" "$filesystem_size" > "$OUTPUT_SIZE"
log_success "Filesystem reconstruit ($(numfmt --to=iec-i --suffix=B "$filesystem_size" 2>/dev/null || echo "$filesystem_size bytes"))."

#-----------------------------------------------------------
# Configuration de l'installateur
#-----------------------------------------------------------
log_info "Configuration de l'installateur..."

# Remplace le fichier de preseed
if [ -f "$preseed" ]; then
	cp "$preseed" "$local/FichierIso/preseed/xubuntu.seed"
	log_success "Preseed configuré"
fi

# Copie le script de pre-installation
if [ -f "$preInstall" ]; then
	cp "$preInstall" "$local/FichierIso/preInstall.sh"
	chmod +x "$local/FichierIso/preInstall.sh"
	log_success "Script preInstall configuré"
fi

#-----------------------------------------------------------
# Génération de l'ISO finale
#-----------------------------------------------------------
log_info "Génération de l'ISO..."

# Régénère la somme de contrôle MD5
cd "$local/FichierIso"
find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt
log_success "Checksums MD5 générés"

# Crée l'ISO selon la version choisie
cd "$local/FichierIso"
case "${choix}" in
	"Main")
		output_iso="$local/solibuntu-24.04-main.iso"
	;;
	"Dev")
		output_iso="$local/solibuntu-24.04-dev.iso"
	;;
esac

# Utilise xorriso pour créer l'ISO bootable (remplace genisoimage pour 24.04)
log_info "Création ISO avec xorriso (peut prendre quelques minutes)..."
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
	. 2>&1 | tail -5

# Rend l'ISO hybride pour clé USB
log_info "Configuration du boot hybride UEFI/BIOS..."
isohybrid --uefi "$output_iso" 2>/dev/null || log_warning "isohybrid non disponible, l'ISO reste bootable en UEFI"
log_success "ISO hybride configurée"

#-----------------------------------------------------------
# Nettoyage final
#-----------------------------------------------------------
log_info "Nettoyage final des dossiers de travail..."

cd "$local"
rm -rf FichierIso/ 
rm -rf squashfs/

log_success "Nettoyage terminé"

#-----------------------------------------------------------
# Résumé final
#-----------------------------------------------------------
echo ""
log_success "ISO créée avec succès !"
echo "═══════════════════════════════════════════════════════"
log_info "Fichier: $output_iso"
log_info "Taille: $(du -h "$output_iso" | cut -f1)"
log_info "Logs complets: $LOG_FILE"
echo "═══════════════════════════════════════════════════════"
echo ""
log_info "Pour copier sur une clé USB :"
log_info "  sudo dd if=$output_iso of=/dev/sdX bs=4M status=progress && sync"
log_info "  (Remplacez sdX par votre périphérique USB - attention : destructif)"
echo ""
