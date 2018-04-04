#! /bin/bash

# ======================================================================
# Fonctions communes
# ======================================================================

# ======================================================================
# Creation de l'ID unique lors du 1er lancement
# ======================================================================

getFirstID() {
    if [ ! -f /root/.uniqID ] ;then
        ret=1
        while [ $ret -eq 1 ]; do
	        ans=$(zenity  --forms --title "Mise en route" --text  "Mise en route" --add-entry "Nom de l'association")
	        ret=$?
	        if [ $ret -eq 0 ];then
		        nomAsso="`echo ${ans}`"
                mac="`getUniqID`"
                echo "${nomAsso}_${mac}" > /roresult=`testMdp $user $pass`ot/.uniqID
                chmod u=rx,go-rwx /root/.uniqID
            fi
        done
    fi
}

# ======================================================================
# Recupere le user par defaut de connexion
# ======================================================================

#getDefaultUser() {
    #defaultUser=`cat /etc/lightdm/lightdm.conf | grep -vE '^#' | grep -- 'autologin-user=' | awk -F= '{print $NF}' | head -n 1 | sed 's/ //g'`
    #echo "${defaultUser}"
#}

# ======================================================================
# Genere un identifiant de date au format AAAMMJJ_HHmmss
# ======================================================================

getDateTime() {
    atDate=`date +%Y%m%d_%H%M%S`
    echo "${atDate}"
}

# Cree un identifiant unique a partir de l'adresse MAC de la carte reseau
# et l'encode en Base 64
getUniqID() {
    mac="`/sbin/ifconfig | grep enp | grep HWaddr | awk '{print $NF}' | sed -e 's/:/_/g'`"
    mac64=`echo "${mac}" | base64 -`
    echo "${mac64}"
}

# ======================================================================
# Logs erreur
# ======================================================================
pErr() {
    lvl="${1}"
    shift
    mess="${@}"

    niv='notice'
    case ${lvl} in
        warn*)
            niv='warn'
            ;;
        crit*)
            niv='crit'
            ;;
        fin)
            niv='notice'
            mess="Fin normale de ${mess}"
            ;;
        *)
            niv='notice'
            ;;
    esac
    logger -p local0.${niv} "${mess}"
}

# ======================================================================
# Test couple identifiant - mot de passe
# ======================================================================
testMdp() {
    utilisateur=$1
    MDP=$2
    export MDP

    id -u $utilisateur > /dev/null

    if [ $? = 0 ]
    then
        CRYPTPASS=`grep -w "$utilisateur" /etc/shadow | cut -d: -f2`
        export ALGO=`echo $CRYPTPASS | cut -d'$' -f2`
        export SALT=`echo $CRYPTPASS | cut -d'$' -f3`
        PASS=$(perl -le 'print crypt("$ENV{MDP}", "\$$ENV{ALGO}\$$ENV{SALT}\$")')
        if [ "$PASS" == "$CRYPTPASS" ]
        then
            return 0
        else
            echo "Mauvais mot de passe"
            return 1
        fi
    else
        echo "Erreur : Cet utilisateur n'existe pas"
        return 2
    fi
}


# =================
# Fin des fonctions
# =================
