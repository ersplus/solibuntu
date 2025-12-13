# Solibuntu — Notes de version

## Compatibilité Xubuntu 24.04 (noble)

Principales évolutions:
- Mise à jour des scripts pour 24.04 (paquets disponibles, Firefox paquet vs snap, durcissement LightDM/Firefox).
- Remplacement d'outils obsolètes (ifconfig → ip) et gksudo → sudo.
- Scripts de filtrage: installation/suppression robustes (gdebi/dpkg), copies prudentes des préférences Firefox.
- Nettoyage de l'arborescence: suppression des dossiers dupliqués locaux non suivis.

Vérifications recommandées:
- LightDM: fichiers actifs sous `/etc/lightdm/lightdm.conf.d/` et greeter.
- Autostart: `sessionStart.desktop` dans `/etc/xdg/autostart/`.
- Firefox: navigateur par défaut défini; si paquet, `/etc/firefox/syspref.js` présent.
- CTparental: installation depuis `share/ctparental.deb`, accès `http://admin.ct.local`.
- Comptes: `administrateur` et `gestionnaire` membres du groupe `Solibuntu`.

Compatibilité et limites connues:
- Certaines polices historiques peuvent ne plus exister dans 24.04; les paquets sont filtrés automatiquement.
- Firefox en snap ne fournit pas `/etc/firefox`; les préférences système sont ignorées dans ce cas.
- Quelques avertissements `shellcheck` subsistent (quotes unicode et variables non utilisées) sans impact fonctionnel.
