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
                echo "${nomAsso}_${mac}" > /root/.uniqID
                chmod u=rx,go-rwx /root/.uniqID
            fi
            opt1="Oui"
            opt2="Non"
            filtrage=`zenity --list --radiolist --text 'Voulez-vous installer le filtrage ?' \
            --column 'Sélectionner' --column 'Options' TRUE "$opt1" FALSE "$opt2"`
            if [ $filtrage == "Oui" ] ; then
                cd /opt/borne/scripts/
                sudo ./filtrage_install.sh
                zenity --info --width=300 --text "Le filtrage a bien été installé \n Votre ordinateur va redémarrer"
                #zenity --info --width=300 --text "Votre ordinateur va redémarrer"
                reboot
            else 
                zenity --info --width=300 --text "Le filtrage n'a pas été installé"
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
    #nohup xterm &
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
            # L'identifiant et le mot de passe correspondent
            return 0
        else
            # Mauvais mot de passe
            return 1
        fi
    else
        # Utilisateur inexistant
        return 2
    fi
}

# ======================================================================
# Test nouveau mot de passe != mot de passe administrateur
# ======================================================================
testDispo() {
    utilisateur="administrateur"
    pass=$1
    testMdp $utilisateur $pass
    if [ $? == 0 ]; then
        # Le mot de passe est celui de l'administrateur
        return 1
    elif [ $? == 1 ]; then
        # Le mot de passe n'est pas celui de l'administrateur
        return 0
    fi

}

# ======================================================================
# Test la sécurité du mot de passe
# ======================================================================
testSecu() {
    password=$1
    password="$(echo "$password" | grep -E "^([a-z0-9A-Z]|[&éè~#{}()ç_@à?.;:/\!,\$<>=£\%\])*$")"
    if [ "${#password}" -ge 8 ] ; then
        # Le mot de passe est valide
        return 0
    else
        # Le mot de passe n'est pas valide
        zinity --info --text "Password is not complex enough, it must contain at least: \n \
                            8 characters total, 1 uppercase, lowercase 1, number 1 \n \
                            and one special character among the following : &éè~#{}()ç_@à?.;:/\!,\$<>=£\%"
        return 1
    fi
}

# =================
# Fin des fonctions
# =================
