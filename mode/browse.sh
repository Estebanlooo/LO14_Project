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
          reclocDoss=$(echo "$locDoss" | awk -F/ '{for (i=1;i<=NF-1;i++){print $i}}')
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
        fi

      ;;

      cat)
        awk -v dos="$locDoss" -v fich="$choix2" 'NR==1 {split($1,tab,":")} {if($1=="@"){count=0}} {if(count==1){if($1==fich){recd=$3;recl=$4}}} {if($2==dos){count=1}} {if($1=="@"){count=0}} {if ((tab[2]+recd-1 <= NR ) && ( NR <= tab[2]+recd+recl-2)){print $0}}' ./archives/$serveur/$port/$archive_name
      ;;

      rm)
        echo "rm"
      ;;

      # Les deux suivant c'est une galere parce que il va forcement devoir réecrire dans le fichier et tout modifier
      touch)
        echo "touch"
      ;;

      mkdir)
        echo "mkdir"
      ;;

      exit)
        echo "Exit browse mode"
        exit
      ;;
    esac
  done
}