#!/bin/bash

# ======================================================================
# Restoration de la session invité de la borne
# ======================================================================

repinstallation="/opt/borne"

if [ ! -f "/etc/lightdm/lightdm.conf.d/50-guest-wrapper.conf" ];then

	cp -i $repinstallation/scripts/lightdm.conf.d/50-auto-guest.conf /etc/lightdm/lightdm.conf.d/
	cp -i $repinstallation/scripts/lightdm.conf.d/50-guest-wrapper.conf /etc/lightdm/lightdm.conf.d/
	pkill lightdm

fi

exit 0
