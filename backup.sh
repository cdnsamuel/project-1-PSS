#!/bin/bash

running=1

list=(
"1) Ajouter une source de sauvegarde"
"2) Supprimer une source de sauvegarde"
"3) Modifier la destination de sauvegarde"
"4) Lancer la sauvegarde "
"5) Plannifier la sauvegarde"
"6) Quitter"
)

message()
{
	echo
	printf "%s\n" "${list[@]}"
    echo
	read -p "Choisissez une tâche par son numéro: " task
	echo
}
message


while [[ $running = '1' ]]  
do
	case $task in
		1)
			echo "1" 
			running=0
			;;
		2)
			echo "2" 
			running=0
			;;
		3) 
			echo "3" 
			running=0
			;;
		4)
			echo "4" 
			running=0
			;;
		5)
			echo "5" 
			running=0
			;;
		6)
			echo "Quitter" 
			running=0
			;;
		*)
			echo "Selection invalide"
			running=1
			message
			 
			;;
	esac
done