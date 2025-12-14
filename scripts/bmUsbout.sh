#! /bin/bash

# ======================================================================
# Script de retrait de la clé USB
# ======================================================================

# Synchronisation des données des clé USB
sync -df

#for U in $(users); do
#    if [ "${U%%-*}" != 'guest' ]; then
#	su $(users) "DISPLAY=: xfce4-session-logout --logout"
#        break
#    fi
#done

pkill xfce4-session

exit 0

# ======================================================================
# Fin du programme
# ======================================================================
