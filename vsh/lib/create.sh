create_archive() {
    archive="$1"
    output="archives/$archive"

    rm -f "$output"

    header="temp/header.tmp"
    body="temp/body.tmp"

    > "$header"
    > "$body"

    read -r liste

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
                start=$(stat -c %s "$body")
                cat "$f" >> "$body"
                end=$(stat -c %s "$body")
                nb=$((end - start))

                echo "$name $rights $size $start $nb" >> "$header"
            fi
        done
        echo "@" >> "$header"
    }

    for elem in $liste; do
        if [ -d "$elem" ]; then
            build_header "$elem"
        elif [ -f "$elem" ]; then
            name=$(basename "$elem")
            rights=$(stat -c %A "$elem")
            size=$(stat -c %s "$elem")

            start=$(stat -c %s "$body")
            cat "$elem" >> "$body"
            end=$(stat -c %s "$body")
            nb=$((end - start))

            echo "$name $rights $size $start $nb" >> "$header"
        fi
    done

    header_lines=$(wc -l < "$header")
    body_start=$((header_lines + 2))

    echo "1:$body_start" > "$output"
    cat "$header" >> "$output"
    cat "$body" >> "$output"
}
