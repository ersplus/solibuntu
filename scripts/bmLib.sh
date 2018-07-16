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
            cp /opt/borne/share/config.tar.gz /home/administrateur
            cd /home/administrateur
            rm -rf .config/
            tar -xvzf config.tar.gz

            ans=$(zenity  --forms --title "Mise en route" --text  "Mise en route" --add-entry "Nom de l'association")
            ret=$?
            if [ $ret -eq 0 ];then
                nomAsso="`echo ${ans}`"
                mac="`getUniqID`"
                echo "${nomAsso}_${mac}" > /root/.uniqID
                chmod u=rx,go-rwx /root/.uniqID
            fi

            zenity --question --text="Les mots de passe administrateur et gestionnaire sont \
            définis par défaut, désirez-vous les modifier ?" \
            --ok-label "Oui" --cancel-label="Non"
            if [ $? == 0 ] ; then
                changerMdp "administrateur" "gestionnaire"
            fi

            zenity --question --text 'Voulez-vous installer le filtrage ?' \
            --ok-label "Oui" --cancel-label="Non"
            if [ $? == 0 ] ; then
                cd /opt/borne/scripts/
                sudo ./filtrage_install.sh
                if [ $? == 0 ] ; then
                    zenity --info --width=300 --text "Le filtrage a bien été installé \n \
                    Votre ordinateur va redémarrer"
                    #zenity --info --width=300 --text "Votre ordinateur va redémarrer"
                else
                    zenity --info --width=300 --text "Une erreur s'est produite \n \
                    Votre ordinateur va redémarrer"
                fi
                reboot
            else 
                zenity --info --width=300 --text "Le filtrage n'a pas été installé \n \
                Votre système va redémarrer."
                reboot
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
        #zinity --info --text "Password is not complex enough, it must contain at least: \n \
        #                    8 characters total, 1 uppercase, lowercase 1, number 1 \n \
        #                    and one special character among the following : &éè~#{}()ç_@à?.;:/\!,\$<>=£\%"
        return 1
    fi
}

changerMdp() {
    if [ $# == 2 ] ; then
        entr=`zenity --forms \
        --title="Changement du mot de passe" \
        --text="Définir un nouveau mot de passe administrateur + gestionnaire" \
        --add-password="Nouveau mot de passe administrateur" \
        --add-password="Confirmer le mot de passe" \
        --add-password="Nouveau mot de passe gestionnaire" \
        --add-password="Confirmer le mot de passe" \
        --separator="|"`
                            
        if [ $? == 0 ]; then
            passAdmin=`echo $entr | cut -d'|' -f1`
            passVerifAdmin=`echo $entr | cut -d'|' -f2`
            passGest=`echo $entr | cut -d'|' -f3`
            passVerifGest=`echo $entr | cut -d'|' -f4`
            if [ $passAdmin == $passVerifAdmin ] && [ $passGest == $passVerifGest ]; then
                testSecu $passAdmin
                if [ 0 == 0 ]; then
                    testSecu $passGest
                    if [ 0 == 0 ]; then
                        zenity --question --text "Voulez-vous vraiment modifier les mots de passe administrateur et gestionnaire ?"
                        if [ $? == 0 ] ; then
                            if [ $passGest != "" ] ; then
                                echo -e "$passGest\n$passGest" | passwd gestionnaire
                            fi
                            if [ $passAdmin != "" ] ; then
                                echo -e "$passAdmin\n$passAdmin" | passwd administrateur
                                CTparental -setadmin administrateur $passAdmin
                            fi
                            # Fouiller dans fonction debconfadminhttp() de /usr/bin/CTparental
                            #CTparental -setadmin gestionnaire $pass
                            zenity --info --text="Les mots de passe ont été modifiés avec succès"
                        fi
                    else
                        zenity --info --text="Le mot de passe gestionnaire n'est pas assez fort, il doit contenir au moins 8 caractères dont au minimum une lettre majuscule, minuscule, un chiffre et un caractère spécial"
                    fi
                else
                    zenity --info --text="Le mot de passe administrateur n'est pas assez fort, il doit contenir au moins 8 caractères dont au minimum une lettre majuscule, minuscule, un chiffre et un caractère spécial"
                fi
            else
                zenity --info --text="Les mots de passe doivent être identiques !"
            fi
        fi
    elif [ $# == 1 ]; then
        entr=`zenity --forms \
        --title="Changement du mot de passe" \
        --text="Définir un nouveau mot de passe $1" \
        --add-password="Nouveau mot de passe $1" \
        --add-password="Confirmer le mot de passe" \
        --separator="|"`

        if [ $? == 0 ]; then
            pass=`echo $entr | cut -d'|' -f1`
            passVerif=`echo $entr | cut -d'|' -f2`
            if [ $pass == $passVerif ] ; then
                testSecu $pass
                if [ 0 == 0 ]; then
                    zenity --question --text "Voulez-vous vraiment modifier les mots de passe administrateur et gestionnaire ?"
                    if [ $? == 0 ] ; then
                        if [ $pass != "" ] ; then
                            echo -e "$pass\n$pass" | passwd $1
                            if [ $1 == "administrateur" ] ; then
                                CTparental -setadmin administrateur $pass
                            fi
                            zenity --info --text="Le mot de passe $1 a été modifié avec succès"
                        fi
                    fi
                else
                    zenity --info --text="Le mot de passe $1 n'est pas assez fort, il doit contenir au moins 8 caractères dont au minimum une lettre majuscule, minuscule, un chiffre et un caractère spécial"
                fi
            else
                zenity --info --text="Les mots de passe doivent être identiques !"
            fi
        fi
    fi
}

# =================
# Fin des fonctions
# =================
