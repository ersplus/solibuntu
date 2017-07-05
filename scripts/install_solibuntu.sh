#!/bin/bash

# ======================================================================
# Script d'installation du filtrage
# ======================================================================

repinstallation="/opt/borne"

[ `whoami` = root ] || { gksudo "$0" "$@"; exit $?; }

sudo sh -c 'ubiquity gtk_ui'

exit 0