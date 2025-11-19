extract_archive() {
    local archive_name=$1
    echo "Extraction de l'archive : $archive_name"
    if [ -f "archives/$archive_name" ]; then
        tar -xf "archives/$archive_name" -C extracted/
        echo "Extraction terminée."
    else
        echo "L'archive $archive_name n'existe pas."
    fi
}