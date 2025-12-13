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

Changelog Version 03/03/2018
- Fonction de mise à jour modifiée
- Version de logiciel de filtrage modifiée
- Intégration Icones /usr/share/icons/
