#!/bin/bash
touch /tmp/sessionstarted

if [ "$USER" = "administrateur" ] || [ "$USER" = "gestionnaire" ]; then
	echo "1" | sudo -n /usr/bin/tee /root/.lastadminlogin >/dev/null || true
fi
