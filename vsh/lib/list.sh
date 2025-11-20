list_archives() {
    echo "Archives disponibles :"
    ls archives/
}

# Renvoie la ligne où commence le body
get_body_start() {
    local archive="archives/$1"
    head -n 1 "$archive" | cut -d: -f2
}

# Renvoie tout le header (sans la première ligne)
get_header() {
    local archive="archives/$1"
    local body_start=$(get_body_start "$1")
    head -n $((body_start - 1)) "$archive" | tail -n +2
}

# Renvoie le body complet
get_body() {
    local archive="archives/$1"
    local body_start=$(get_body_start "$1")
    tail -n +$body_start "$archive"

    cat "$body" >> "$output"

    rm -f "$header" "$body"

    echo "Archive $archive créée avec succès."
}