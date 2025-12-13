# solibuntu
Solibuntu : une SOLution Informatique SOLidaire pour les associations du secteur social du projet https://solisol.org

Lors l'installation créer un compte administtrateur et choisir un mot de passe

Une fois l'installation terminée, le filtrage peut être installé

Une fois le filtrage installé, il est accessible depuis l'URL https://admin.ct.local/

## Compatibilité Xubuntu 24.04

- La branche Dev est mise à jour pour Xubuntu 24.04 (noble) et les paquets disponibles sur cette version.
- Déployer les sources dans /opt/borne puis lancer `sudo scripts/install.sh installation` pour une installation complète.
- Le filtrage CTparental peut être installé ou retiré via les scripts `scripts/filtrage_install.sh` et `scripts/filtrage_remove.sh`.
- Les préférences Firefox sont appliquées uniquement si le navigateur est installé via les paquets classiques (le snap Firefox ne fournit pas /etc/firefox).

### Guide rapide 24.04
- Préparer le système: `sudo apt update && sudo apt install -y feh yad zenity iproute2 dmidecode gdebi-core`
- Installer Solibuntu: `sudo /opt/borne/scripts/install.sh installation`
- Filtrage (optionnel): `sudo /opt/borne/scripts/filtrage_install.sh` puis, si besoin, `sudo /opt/borne/scripts/filtrage_remove.sh`

### Check-list de validation 24.04
- LightDM: fichiers copiés dans `/etc/lightdm/lightdm.conf.d/`, greeter configuré.
- Autostart: `sessionStart.desktop` présent dans `/etc/xdg/autostart/`.
- Firefox: navigateur par défaut défini; si paquet, `'/etc/firefox/syspref.js'` existe.
- CTparental: installation via le `.deb` fonctionne, accès `http://admin.ct.local`.
- Utilisateurs: `administrateur` et `gestionnaire` créés et membres du groupe `Solibuntu`.

Changelog Version 03/03/2018
- Fonction de mise à jour modifiée
- Version de logiciel de filtrage modifiée
- Intégration Icones /usr/share/icons/
