#!/bin/bash
# Proxy Chromium pour CTparental : anciens chemins deb + Snap (Xubuntu 24.04+ / 25.x)
# À sourcer après avoir défini repinstallation (ex. /opt/borne)

solibuntu_chromium_proxy_apply() {
	local mode="${1:-on}"
	local src
	if [ "$mode" = "on" ]; then
		src="${repinstallation}/share/proxy/defaulton"
	else
		src="${repinstallation}/share/proxy/defaultoff"
	fi
	[ -f "$src" ] || return 1

	# Wrappers deb / transitional (CHROMIUM_FLAGS=…)
	mkdir -p /etc/chromium-browser 2>/dev/null || true
	cp -f "$src" /etc/chromium-browser/default 2>/dev/null || true

	mkdir -p /etc/chromium.d 2>/dev/null || true
	cp -f "$src" /etc/chromium.d/default 2>/dev/null || true

	# Snap : une option par ligne dans chromium-flags.conf
	local snap_flags="/var/snap/chromium/common/chromium-flags.conf"
	if [ -d /var/snap/chromium/common ] || mkdir -p /var/snap/chromium/common 2>/dev/null; then
		if grep -q 'proxy-server=127.0.0.1:8080' "$src" 2>/dev/null; then
			printf '%s\n' '--proxy-server=127.0.0.1:8080' >"$snap_flags" 2>/dev/null || true
		else
			: >"$snap_flags" 2>/dev/null || true
		fi
	fi
	return 0
}
