# solibuntu
Solibuntu : une SOLution Informatique SOLidaire pour les associations du secteur social du projet https://solisol.org

Lors l'installation créer un compte administtrateur et choisir un mot de passe

Une fois l'installation terminée, le filtrage peut être installé

Une fois le filtrage installé, il est accessible depuis l'URL https://admin.ct.local/

Scripts Solibuntu

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
