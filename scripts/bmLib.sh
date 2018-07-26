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
            ans=$(zenity  --forms --title "Mise en route" --text  "Mise en route" --add-entry "Bienvenue dans l’assistant de démarrage de Solibuntu. 
Pour commencer la configuration, veuillez saisir le nom de l’association : 
")
            ret=$?
            if [ $ret -eq 0 ];then
                nomAsso="`echo ${ans}`"
                mac="`getUniqID`"
                echo "${nomAsso}_${mac}" > /root/.uniqID
                chmod u=rx,go-rwx /root/.uniqID
            fi

            zenity --width=550 --height=50 --question --text="Deux mots de passe sont nécessaires pour utiliser et personnaliser Solibuntu. Ils sont définis par défaut :

- Pour l’administrateur, responsable du poste : AdminSolibuntu

- Pour le gestionnaire, qui pourra modifier l’environnement de l’utilisateur : AdminAsso

Ces mots de passes sont confidentiels, ils ne seront plus communiqués ultérieurement.
Afin de garantir la sécurité de votre installation, désirez-vous modifier maintenant ces mots de passe ?  " \
--ok-label "Oui" --cancel-label="Non"
            if [ $? == 0 ] ; then
                changerMdp "administrateur" "gestionnaire"
            fi

            zenity --question --width=450 --text 'Pour répondre aux contraintes de sécurité, il est nécessaire de bloquer les sites inappropriés (sites pour adultes, agressif, drogue, téléchargement illégaux, …).

Si votre association ne dispose d’aucun dispositif pour bloquer ces sites, Solibuntu peut installer une solution logicielle pour les filtrer.

Ce dispositif de filtrage (CTParental) sera ensuite configurable par l’administrateur en utilisant ses identifiants via l’adresse internet 
http://admin.ct.local
Désirez-vous installer cette solution ?' \
--ok-label "Oui" --cancel-label="Non"
            if [ $? == 0 ] ; then
                cd /opt/borne/scripts/
                sudo ./filtrage_install.sh
                if [ $? == 0 ] ; then
                    zenity --info --width=300 --text "Le filtrage a bien été installé
L’ordinateur va redémarrer pour finaliser l’installation"
                    #zenity --info --width=300 --text "Votre ordinateur va redémarrer"
                else
                    zenity --info --width=300 --text "Une erreur s'est produite
Votre ordinateur va redémarrer"
                fi
                reboot
            else 
                zenity --info --width=300 --text "Le filtrage n'a pas été installé
L'ordinateur va redémarrer."
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
    if [ "${#password}" -ge 8 ] ; then
        echo "$password" | grep -E "[a-z]"
        if [ $? == 1 ] ; then
            # Le mot de passe est incorrect
            return 1
        fi
        echo "$password" | grep -E "[A-Z]"
        if [ $? == 1 ] ; then
            # Le mot de passe est incorrect
            echo "C'est pas correct !"
            return 1
        fi
        echo "$password" | grep -E "[0-9]"
        if [ $? == 1 ] ; then
            # Le mot de passe est incorrect
            return 1
        fi
        # Le mot de passe est sécurisé
        return 0
    else
        # Le mot de passe est incorrect
        return 1
    fi
}

changerMdp() {
    if [ $# == 2 ] ; then
        entr=`zenity --forms \
        --title="Changement des mot de passe" \
        --text="Modification du mot de passe administrateur et gestionnaire
Les mots de passe doivent respecter les règles suivantes : 
8 caractères minimum dont au moins une lettre majuscule et un chiffre." \
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
                if [ "$passAdmin" -ne "$passGest" ] ; then
                    testSecu $passAdmin
                    if [ $? == 0 ]; then
                        testSecu $passGest
                        if [ $? == 0 ]; then
                            zenity --question --width=250 --text "Voulez-vous vraiment modifier les mots de passe administrateur et gestionnaire ?"
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
                                zenity --info --width=300 --text="Les mots de passe ont été modifiés avec succès
En cas de perte ou d’oubli du mot de passe de l’administrateur, il sera nécessaire de réinstaller Solibuntu."
                            fi
                        else
                            zenity --info --width=300 --text="Le mot de passe gestionnaire n'est pas assez fort, il doit contenir au moins 8 caractères dont au minimum une lettre majuscule, minuscule et un chiffre."
                        fi
                    else
                        zenity --info --width=300 --text="Le mot de passe administrateur n'est pas assez fort, il doit contenir au moins 8 caractères dont au minimum une lettre majuscule, minuscule et un chiffre."
                    fi
                else
                    zenity --info --width=300 --text="Les mots de passe administrateur et gestionnaire ne doivent pas être identiques"
                fi
            else
                zenity --info --width=300 --text="Les mots de passe et leurs confirmation ne correspondent pas !"
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
                    zenity --question --width=300 --text "Voulez-vous vraiment modifier le mot de passe $1 ?"
                    if [ $? == 0 ] ; then
                        if [ $pass != "" ] ; then
                            echo -e "$pass\n$pass" | passwd $1
                            if [ $1 == "administrateur" ] ; then
                                CTparental -setadmin administrateur $pass
                            fi
                            zenity --info --width=300 --text="Le mot de passe $1 a été modifié avec succès"
                        fi
                    fi
                else
                    zenity --info --width=300 --text="Le mot de passe $1 n'est pas assez fort, il doit contenir au moins 8 caractères dont au minimum une lettre majuscule, minuscule, un chiffre et un caractère spécial"
                fi
            else
                zenity --info --width=300 --text="Les mots de passe doivent être identiques !"
            fi
        fi
    fi
}

# =================
# Fin des fonctions
# =================
