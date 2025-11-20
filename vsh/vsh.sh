#!/bin/bash
#Fichier : vsh.sh
#Corps du programme principal

# === Chargement des modules ===
source lib/list.sh
source lib/create.sh
source lib/browse.sh
source lib/extract.sh

# === Vérification des arguments ===
if [ $# -lt 2 ]; then
    echo "Usage : vsh <mode> <nom_serveur> <port> [archive]"
    exit 1
fi

mode=$1
serveur=$2
port=$3
archive=$4

archives_dir="./archives"

case $mode in

    -list)
        list_archives "$serveur" "$port"
    ;;

    -create)
        if [ -z "$archive" ]; then
            echo "Usage : vsh -create serveur port nom_archive"
            exit 1
        fi
        create_archive "$archive"
    ;;

    -browse)
        browse_archive "$archive"
    ;;

    -extract)
        extract_archive "$archive"
    ;;

    *)
        echo "Mode inconnu : $mode"
        ;;
esac
