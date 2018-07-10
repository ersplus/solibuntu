#!/bin/bash
touch /tmp/sessionstarted

if [ ! -f $HOME/.config/solibuntu ] ; then
	#cp /opt/borne/share/config.tar.gz $HOME/
	#cd $HOME
	#rm -rf .config
	#tar -xvzf config.tar.gz
	#rm config.tar.gz
	if [ $USER == "gestionnaire" ] ; then
		chown gestionnaire:gestionnaire ~/.config/
	fi
	sudo xdg-user-dirs-update --set DOWNLOAD ~/Bureau
	reboot
fi