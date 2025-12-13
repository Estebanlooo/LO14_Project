#!/bin/bash
# Fichier : lib/browse.sh
# Implémentation du mode -browse de la commande vsh.

browse_archive() {
  local archive_name=$1
  local serveur=$2
  local port=$3
  local chemin_archives="./archives/$serveur/$port/$archive_name"

  local fin=0
  local locDoss=src
  while [ $fin -ne 1 ];
  do

    read -p "vsh:>" choix1 choix2 choix3

    case $choix1 in

      pwd)
        echo "$locDoss"
      ;;

      ls)
        if [ $choix2 == "-l" ]
        then
          awk -v var="$locDoss" '{if($1=="@"){count=0}} {if(count==1){print $0}} {if($2==var){count=1}} {if($1=="@"){count=0}}' ./archives/$serveur/$port/$archive_name
        elif [ $choix2 == "-a" ]
        then
          echo "-a" # Create lit enfin les fichiers cachés seulement ils sont affiche juste avec un ls 
        elif [ -z $choix2 ]
        then
          awk -v var="$locDoss" '{if($1=="@"){count=0}} {if(count==1){printf "%s ", $1}} {if($2==var){count=1}} {if($1=="@"){count=0}} END{printf "\n"}' ./archives/$serveur/$port/$archive_name
        else
          reclocDoss=$locDoss/$choix2
          test=$(awk -v var="$reclocDoss" '{if($2==var){count=1}} END{print count}' ./archives/$serveur/$port/$archive_name)
          if [ $test -eq 1 ]
          then
            awk -v var="$locDoss" '{if($1=="@"){count=0}} {if(count==1){printf "%s ", $1}} {if($2==var){count=1}} {if($1=="@"){count=0}} END{printf "\n"}' ./archives/$serveur/$port/$archive_name
          else
            echo "ls: no such file or directory: $choix2"
          fi
        fi 2>/dev/null
      ;;

      cd)
        if [ $choix2 == ".." ]
        then
          reclocDoss=$(echo "$locDoss" | awk -F/ '{n=split($0,tab,"/"); for(i=1;i<n;i++){if(i==1){printf"%s",tab[i]}else{printf"/%s",tab[i]}}}')
          if [ $reclocDoss != 0 ]
          then
            locDoss=$reclocDoss
          else
            echo "Vous ne pouvez pas faire ça"
          fi
        else
          reclocDoss=$locDoss/$choix2
          test=$(awk -v var="$reclocDoss" '{if($2==var){count=1}} END{print count}' ./archives/$serveur/$port/$archive_name)
          if [ $test -eq 1 ]
          then
            locDoss=$reclocDoss
          else
            echo "cd: no such file or directory: $choix2"
          fi 2>/dev/null
        fi 2>/dev/null

      ;;

      cat)
        awk -v dos="$locDoss" -v fich="$choix2" 'NR==1 {split($1,tab,":")} {if($1=="@"){count=0}} {if(count==1){if($1==fich){recd=$3;recl=$4}}} {if($2==dos){count=1}} {if($1=="@"){count=0}} {if ((tab[2]+recd-1 <= NR ) && ( NR <= tab[2]+recd+recl-2)){print $0}}' ./archives/$serveur/$port/$archive_name
      ;;

      rm)
        fich_temp="./archives/$serveur/$port/$archive_name.tmp"
        awk -v dos="$locDoss" -v fich="$choix2" 'NR==1 {split($1,tab,":")} {if($2==dos){target=1}} {if(target==0){print $0}} {if(NR==tab[2]){target=1}} {if(target==1){if($1==fich){recd=$3;recl=$4;printf("\n")} else if ((tab[2]+recd-1 <= NR ) && ( NR <= tab[2]+recd+recl-2)){printf("\n")}else{print $0}}}' ./archives/$serveur/$port/$archive_name > $fich_temp
        if [ $? -eq 0 ]; then
            mv "$fich_temp" "./archives/$serveur/$port/$archive_name"
        else
            echo "Erreur lors de la création du fichier temporaire, l'archive originale n'a pas été modifiée." >&2
            rm -f "$fich_temp"
        fi
      ;;

      # Les deux suivant c'est une galere parce que il va forcement devoir réecrire dans le fichier et tout modifier
      touch)
        # Selon moi, ici on rajoute un fichier vide, il faut donc juste attraper la premiere ligne, faire +1 au deuxième elements, aller dans le dossier ou l'on souhaite, rajouter un ligne avec les donnée de base et tout réecrire
        fich_temp="./archives/$serveur/$port/$archive_name.tmp"
        awk -v doss="$locDoss" -v fich="$choix2" '{if(NR==1){n=split($1,tab,":");printf"%s:%s\n", tab[1],tab[2]+1}else{if($2==doss){target=1}if((target==1) && ($1 == "@")){target=0;printf"%s %s 0 0\n@\n", fich, "-rw-r--r--"}else{print $0}}}' ./archives/$serveur/$port/$archive_name > $fich_temp
        if [ $? -eq 0 ]; then
            mv "$fich_temp" "./archives/$serveur/$port/$archive_name"
        else
            echo "Erreur lors de la création du fichier temporaire, l'archive originale n'a pas été modifiée." >&2
            rm -f "$fich_temp"
        fi
      ;;

      mkdir)
        # la même chose que touch, on prends la premiere ligne on fait +3, on cherche dans quelle dossier nous sommes, on ajoute le dossier dedans puis on va  ala fin du header et on ajoute le dossier sur 2 ligne
        fich_temp="./archives/$serveur/$port/$archive_name.tmp"
        awk -v doss="$locDoss" -v ndos="$choix2" '{if(NR==1){n=split($1,tab,":");printf"%s:%s\n",tab[1],tab[2]+3}else{if($2==doss){target=1}if(($1=="@") && (target==1)){target=0;printf"%s drwxr-xr-x 4096\n",ndos}if(NR==tab[2]){printf"directory %s/%s\n@\n\n",doss,ndos}else{print $0}}}' ./archives/$serveur/$port/$archive_name > $fich_temp
        if [ $? -eq 0 ]; then
            mv "$fich_temp" "./archives/$serveur/$port/$archive_name"
        else
            echo "Erreur lors de la création du fichier temporaire, l'archive originale n'a pas été modifiée." >&2
            rm -f "$fich_temp"
        fi
      ;;

      exit)
        echo "Exit browse mode"
        exit
      ;;

      *)
        echo "$choix1: Unknown Command"
    esac
  done
}