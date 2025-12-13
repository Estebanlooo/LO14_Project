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
    
    if [ $? -ne 0 ]; then
        echo "Erreur critique : Impossible de créer le chemin de destination $ARCHIVE_DEST_DIR." >&2
        return 1
    fi
   
    local PHYSICAL_ROOT_PATH="./src" 
    local ARCHIVE_ROOT_NAME="src" 
    
    local temp_dir="temp"
    local header_file="$temp_dir/header.tmp"
    local body_file="$temp_dir/body.tmp"
    
    if [ ! -d "$PHYSICAL_ROOT_PATH" ]; then
        echo "Erreur : Le répertoire source '$PHYSICAL_ROOT_PATH' n'existe pas." >&2
        return 1
    fi
    
    mkdir -p "$temp_dir" 

    > "$header_file" 
    > "$body_file"    
    
    build_directory_entry() {
        local dir_path="$1" 
        local archive_name="$2" 
        
        echo "directory $archive_name" >> "$header_file" 

        # Inclure les fichiers cachés (commençant par .)
        for f in "$dir_path"/* "$dir_path"/.*; do
            [ -e "$f" ] || continue
            # Exclure . et ..
            [ "$(basename "$f")" = "." ] && continue
            [ "$(basename "$f")" = ".." ] && continue
            
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
        local dir_path="$1"
        local archive_name="$2"
        
        build_directory_entry "$dir_path" "$archive_name"

        # Inclure les dossiers cachés (commençant par .)
        for d in "$dir_path"/* "$dir_path"/.*; do
            [ -d "$d" ] || continue
            # Exclure . et ..
            [ "$(basename "$d")" = "." ] && continue
            [ "$(basename "$d")" = ".." ] && continue
            
            local sub_name=$(basename "$d")
            local next_archive_name="$archive_name/$sub_name"
            
            build_recursive_header "$d" "$next_archive_name"
        done
    }

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

Esteban_create_archive() {
  local nom_archive="$1"
  local serveur="$2"
  local port="$3"

  local Dos_archive="./archives/$serveur/$port"
  local archives="$Dos_archive/$nom_archive"

  mkdir -p "$Dos_archive"

  if [ $? -ne 0 ]; then
      echo "Erreur critique : Impossible de créer le chemin de destination $ARCHIVE_DEST_DIR." >&2
      return 1
  fi

  local emp_save="./src"
  local save="src"

  local header="./temp/header.tmp"
  local body="./temp/body.tmp"

  mkdir -p "temp"
  ## on commence a faire un truc la
  lh=0
  lb=0
  nbr_element=$(ls $emp_save | awk 'END{print NR}')
  for (( i=1; i<=$nbr_element; i++ ))
  do
    nom=$(ls -l $emp_save | awk -v var=$i  '{if (NF=var){print $9} }')
    if [ -d $nom ]
    then
      size=$(stat -c %s "$f")
      (ls -l $emp_save | awk -v var=$i -v oldlb=$oldlb -v lb=$lb '{if (NF=var){print $9 $1 oldlb lb} }') > header
    else
      (cat $nom) > $body
      oldlb=$lb
      lb=$(cat $body | wc -l)
      (ls -l $emp_save | awk -v var=$i -v oldlb=$oldlb -v lb=$lb '{if (NF=var){print $9 $1 oldlb lb} }') > header
    fi
  done

}