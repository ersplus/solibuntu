#!/bin/bash
# Relance le script en root pour les assistants graphiques (remplace gksudo / gksu)

solibuntu_ensure_root() {
	if [ "$(id -u)" -eq 0 ]; then
		return 0
	fi
	if command -v pkexec >/dev/null 2>&1; then
		exec pkexec env DISPLAY="${DISPLAY:-:0}" XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}" "$0" "$@"
	fi
	exec sudo -E "$0" "$@"
}
