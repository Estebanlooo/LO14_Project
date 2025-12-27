#!/bin/bash
# Fichier : lib/create.sh
# Implémentation du mode -create de la commande vsh.

create_archive() {
  local nom_archive="$1"
  local serveur="$2"
  local port="$3"
  local source_dir="$4"

  if [ -z "$source_dir" ]; then
    local temp_save="src"
  else
    local temp_save="$source_dir"
  fi

  # Vérification : le dossier source doit exister physiquement
  if [ ! -d "$temp_save" ]; then
      echo "Erreur : Le dossier source '$temp_save' n'existe pas." >&2
      return 1
  fi

  local Dos_archive="./archives/$serveur/$port"
  local archives="$Dos_archive/$nom_archive"

  mkdir -p "$Dos_archive"

  if [ $? -ne 0 ]; then
      echo "Erreur critique : Impossible de créer le chemin de destination $Dos_archive." >&2
      return 1
  fi

  # On s'assure que le dossier temp existe
  mkdir -p "temp"
  local header="./temp/header.tmp"
  local body="./temp/body.tmp"

  # On vide les fichiers temporaires au début
  > "$header"
  > "$body"

  # Initialisation des compteurs de lignes pour le Body
  # lb servira à stocker la ligne de début dans le body
  local lb=1

  recherche() {
      local dossier_actuel="$1"

      # Étape 1 : On écrit l'en-tête du répertoire courant
      echo "directory $dossier_actuel" >> "$header"

      # Étape 2 : Premier passage pour lister TOUS les éléments du dossier (fichiers et dossiers)
      for nom_court in $(ls -a "$dossier_actuel")
      do

        [ "$nom_court" = "." ] || [ "$nom_court" = ".." ] && continue

        local chemin_complet="$dossier_actuel/$nom_court"
        local infos=$(ls -ld "$chemin_complet" | awk '{print $1" "$5}') # Utilisation de -ls pour afficher les droits et la taille
        local droits=$(echo $infos | cut -d' ' -f1)
        local taille=$(echo $infos | cut -d' ' -f2)

        if [ -d "$chemin_complet" ]; then
          # On inscrit le dossier dans le Header (sans descendre dedans pour l'instant)
          echo "$nom_court $droits $taille" >> "$header"
        else
          # Gestion des fichiers et remplissage du Body
          local nb_lignes_fich=$(wc -l < "$chemin_complet")
          cat "$chemin_complet" >> "$body"
          echo "" >> "$body" # Séparateur de fin de fichier

          local total_lignes_ajoutees=$((nb_lignes_fich + 1))

          # Inscription du fichier avec ses coordonnées relatives au Body
          echo "$nom_court $droits $taille $lb $total_lignes_ajoutees" >> "$header"
          lb=$((lb + total_lignes_ajoutees))
        fi
      done

      # Marqueur de fin pour le répertoire courant
      echo "@" >> "$header"

      # Étape 3 : Second passage pour la récursivité (descendre dans les sous-dossiers)
      # Cela garantit que les sections "directory" des sous-dossiers apparaissent après celle du parent
      for nom_court in $(ls "$dossier_actuel")
      do
        local chemin_complet="$dossier_actuel/$nom_court"
        if [ -d "$chemin_complet" ]; then
          recherche "$chemin_complet"
        fi
      done
    }

  recherche "$temp_save"

  # --- PHASE FINALE : ASSEMBLAGE DE L'ARCHIVE ---

  # 1. On calcule la ligne où commence le Body
  # La ligne 1 est le "2:BodyStart", donc le body commence après le header + 1
  local nb_lignes_header=$(wc -l < "$header")
  local body_start=$((nb_lignes_header + 2))

  # 2. Création du fichier final
  echo "2:$body_start" > "$archives"
  cat "$header" >> "$archives"
  cat "$body" >> "$archives"

  echo "Archive créée avec succès : $archives"

  # Nettoyage des fichiers temporaires
  rm "$header" "$body"
}