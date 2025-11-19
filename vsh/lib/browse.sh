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
