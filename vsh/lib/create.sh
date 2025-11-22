#!/bin/bash
# Fichier : lib/create.sh
# Implémentation du mode -create de la commande vsh.

create_archive() {
    local archive_name="$1"
    local serveur="$2"
    local port="$3"
    
    local ARCHIVE_DEST_DIR="./archives/$serveur/$port"
    local output_path="$ARCHIVE_DEST_DIR/$archive_name"
    
    mkdir -p "$ARCHIVE_DEST_DIR"
    
    # Vérification que la création du répertoire a réussi
    if [ $? -ne 0 ]; then
        echo "Erreur critique : Impossible de créer le chemin de destination $ARCHIVE_DEST_DIR." >&2
        return 1
    fi
    # ===============================================

    local PHYSICAL_ROOT_PATH="./Exemple" 
    local ARCHIVE_ROOT_NAME="Exemple" 
    
    # Préparation des fichiers temporaires (dans le répertoire d'exécution vsh/)
    local temp_dir="temp"
    local header_file="$temp_dir/header.tmp"
    local body_file="$temp_dir/body.tmp"
    
    # ----------------------------------------------------------------------
    # 1. Préparation et Vérification
    # ----------------------------------------------------------------------

    if [ ! -d "$PHYSICAL_ROOT_PATH" ]; then
        echo "Erreur : Le répertoire source '$PHYSICAL_ROOT_PATH' n'existe pas." >&2
        return 1
    fi
    
    mkdir -p "$temp_dir" 

    > "$header_file" 
    > "$body_file"    
    
    # ----------------------------------------------------------------------
    # 2. Fonctions de Construction du Header et du Body (inchangées, logiques)
    # ----------------------------------------------------------------------

    build_directory_entry() {
        # ... (Contenu de la fonction inchangé) ...
        local dir_path="$1" 
        local archive_name="$2" 
        
        echo "directory $archive_name" >> "$header_file" 

        for f in "$dir_path"/*; do
            [ -e "$f" ] || continue
            
            local name=$(basename "$f")
            local rights=$(ls -ld "$f" | awk '{print $1}')
            local size=$(stat -c %s "$f") 

            if [ -d "$f" ]; then
                echo "$name $rights 4096" >> "$header_file" 
            else
                if [ "$size" -eq 0 ]; then
                    echo "$name $rights 0" >> "$header_file"
                else
                    local current_body_lines=$(wc -l < "$body_file" | tr -d ' ')
                    local start_line=$((current_body_lines + 1))
                    
                    cat "$f" >> "$body_file"
                    echo "" >> "$body_file" 
                    
                    local new_body_lines=$(wc -l < "$body_file" | tr -d ' ')
                    local file_line_count=$((new_body_lines - current_body_lines))
                    
                    echo "$name $rights $size $start_line $file_line_count" >> "$header_file"
                fi
            fi
        done
        
        echo "@" >> "$header_file"
    }
    
    build_recursive_header() {
        # ... (Contenu de la fonction inchangé) ...
        local dir_path="$1"
        local archive_name="$2"
        
        build_directory_entry "$dir_path" "$archive_name"

        for d in "$dir_path"/*; do
            [ -d "$d" ] || continue
            
            local sub_name=$(basename "$d")
            local next_archive_name="$archive_name\\$sub_name"
            
            build_recursive_header "$d" "$next_archive_name"
        done
    }

    # ----------------------------------------------------------------------
    # 3. Démarrage et Finalisation de l'Archive
    # ----------------------------------------------------------------------

    build_recursive_header "$PHYSICAL_ROOT_PATH" "$ARCHIVE_ROOT_NAME"
    
    local header_lines=$(wc -l < "$header_file" | tr -d ' ')
    local body_start=$((header_lines + 2)) 

    echo "2:$body_start" > "$output_path"
    cat "$header_file" >> "$output_path"
    cat "$body_file" >> "$output_path"
    
    echo "Archive '$archive_name' créée à partir de '$PHYSICAL_ROOT_PATH' dans $output_path"

    # Nettoyage
    rm -f "$header_file" "$body_file"
    rmdir "$temp_dir" 2>/dev/null 
}