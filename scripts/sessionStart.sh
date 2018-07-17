#!/bin/bash
touch /tmp/sessionstarted

if [ $USER == "administrateur" -o $USER == "gestionnaire" ] ; then
	echo "1" > /root/.lastadminlogin
fi
