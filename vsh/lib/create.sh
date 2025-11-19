create_archive() {
    archive="$1"
    output="archives/$archive"

    echo "Création de l’archive $archive ..."
    rm -f "$output"

    # HEADER et BODY temporaires
    header="temp/header.tmp"
    body="temp/body.tmp"
    > "$header"
    > "$body"

    # fonction récursive
    build_header() {
        local dir="$1"
        echo "directory $dir" >> "$header"

        for f in "$dir"/*; do
            name=$(basename "$f")
            rights=$(stat -c %A "$f")
            size=$(stat -c %s "$f")

            if [ -d "$f" ]; then
                echo "$name $rights $size" >> "$header"
                echo "@" >> "$header"
                build_header "$f"
            else
                # fichier
                start=$(wc -l < "$body")
                [ "$size" -gt 0 ] && cat "$f" >> "$body"
                lines=$(wc -l < "$body")
                nb=$((lines-start))
                echo "$name $rights $size $start $nb" >> "$header"
            fi
        done
        echo "@" >> "$header"
    }

    build_header .

    header_lines=$(wc -l < "$header")
    body_start=$((header_lines + 2))

    echo "1:$body_start" > "$output"
    cat "$header" >> "$output"
    cat "$body" >> "$output"

    echo "Archive créée dans archives/$archive"
}
