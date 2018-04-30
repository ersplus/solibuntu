//
// Fichier de configuation de Firefox
// Pour générer facilement un fichier de congig :
// cat $HOME/.mozilla/firefox/*.default/prefs.js
// Prefixe de configuration :
// lockpref ou pref
//
// Page de démarrage
//
user_pref("browser.startup.homepage", "http://google.fr");
//
// Configuration du proxy
//
lockPref("network.proxy.http","address.of.proxy");
lockPref("network.proxy.http_port",80);
lockPref("network.proxy.ssl","address.of.proxy");
lockPref("network.proxy.ssl_port",80);
lockPref("network.proxy.type",1);
lockPref("network.proxy.share_proxy_settings", true)
//
// Gestion des données personnelles
//
lockPref("privacy.clearOnShutdown.cache", true);
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
