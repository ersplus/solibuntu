#! /bin/bash

# ======================================================================
# identification de la cle detenant
# les donnees sources (identifiants uniques)
# ======================================================================

# au moins une clé est branchée
#serialPi=$(grep  Serial /proc/cpuinfo | tr -d ' '  |cut -d: -f2)

#serialKeyB=$(udevadm info --name=/dev/sdb | grep SERIAL_SHORT| cut -d= -f2)
#echo $serialPi:$serialKeyB > /tmp/.KEYB
#if  diff /tmp/.KEYB /root/.uniqUSBKEY ; then
# la clé A est la bonne
#	rm /tmp/.KEYB
#	exit 1
#fi

# il y a deux cles : la seconde est-elle la source ?
#serialKeyC=$(udevadm info --name=/dev/sdc | grep SERIAL_SHORT| cut -d= -f2)
#echo $serialPi:$serialKeyC > /tmp/.KEYC
#if diff /tmp/.KEYC /root/.uniqUSBKEY ; then
#	rm /tmp/.KEY*
#	exit 2
#fi

# aucune des deux cles
#rm /tmp/.KEY* 
 

kill -SIGUSR1 $(pgrep bmConnectusb.sh)
pkill yad

exit 0
