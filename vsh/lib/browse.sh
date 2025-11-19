browse_archive() {
    archive="$1"

    if [ ! -f "archives/$archive" ]; then
        echo "Archive introuvable."
        exit 1
    fi

    curr="\."

    while true
    do
        echo -n "vsh:$curr> "
        read cmd arg
        result=""


        case $cmd in
            pwd)
                echo "$curr"
            ;;
            ls)
                browse_ls "$archive" "$curr"
            ;;
            cd)
                browse_cd "$archive" "$curr" "$arg"
            ;;
            cat)
                browse_cat "$archive" "$curr" "$arg"
            ;;
            exit)
                return
            ;;
            *)
                echo "Commande inconnue"
        esac
    done
}

browse_ls() {
    archive=$1
    path=$2

    # Récupération du header
    header=$(get_header "$archive")

    # Parcours du header pour trouver le bon répertoire
    inside=0

    while read line; do
        # Début de directory
        if [[ "$line" == "directory $path" ]]; then
            inside=1
            continue
        fi

        # Fin directory
        if [[ "$line" == "@" ]]; then
            inside=0
        fi

        # Si on est dans le bon dir
        if [[ $inside -eq 1 ]]; then
            # Première colonne -> nom
            echo "$line" | awk '{print $1}'
        fi

    done <<< "$header"
}

browse_cd() {
    archive=$1
    curr=$2
    target=$3

    if [ -z "$target" ]; then
        echo "Usage: cd <dir>"
        return
    fi

    # On reconstruit le nouveau chemin
    if [ "$target" == ".." ]; then
        curr=$(dirname "$curr")
        [ "$curr" == "/" ] && curr="."
        echo "$curr"
        return
    fi

    new="$curr/$target"

    # Vérification si ce répertoire existe dans le header
    if get_header "$archive" | grep -q "directory $new"; then
        echo "$new"
    else
        echo "Répertoire introuvable"
        echo "$curr"
    fi
}

browse_cat() {
    archive=$1
    curr=$2
    filename=$3

    if [ -z "$filename" ]; then
        echo "Usage: cat <file>"
        return
    fi

    header=$(get_header "$archive")
    body=$(get_body "$archive")

    path="$curr/$filename"

    # Chercher la ligne du fichier dans le header
    infos=$(echo "$header" | grep "^$filename " | head -n 1)

    if [ -z "$infos" ]; then
        echo "Fichier introuvable"
        return
    fi

    # Parsing
    start=$(echo "$infos" | awk '{print $4}')
    nb=$(echo "$infos" | awk '{print $5}')

    # Extraction du contenu
    echo "$body" | dd bs=1 skip=$start count=$nb 2>/dev/null
}
