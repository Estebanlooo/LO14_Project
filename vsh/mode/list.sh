list_archives() {
    echo "Archives disponibles :"
    ls archives/$serveur/$port/ 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "Aucune archive trouvée sur le serveur $serveur:$port."
    fi
}