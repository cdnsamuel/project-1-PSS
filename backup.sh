#!/bin/bash

##! FONCTIONS PERSONNALISEES
# vérifier la présence des fichiers, les créer si besoin
check_files()
{
	if [ ! -e folder.list ]; then touch folder.list; fi
	if [ ! -e destination.list ]; then touch destination.list; fi
}

# demander confirmation avant execution
pause(){
  read -p "Appuyez sur la touche [Entrée] pour continuer..." fackEnterKey
}

# Afficher la liste des cibles
show_folder()
{
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "⬇️  Dossiers à sauvegarder"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	if [ -s folder.list ]
	then
		cat folder.list
	else
		echo "Aucune source définie"
	fi
}

# Option 3:
show_destination()
{
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "⬇️  Destination de la sauvegarde"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	if [ -s destination.list ]
	then
		cat destination.list
	else
		echo "Aucune destination définie"
	fi
}

# Afficher le menu 
show_menu()
{	
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "🎛️  Menu Principal"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "1) Ajouter une source de sauvegarde"
	echo "2) Supprimer une source de sauvegarde"
	echo "3) Modifier la destination de sauvegarde"
	echo "4) Lancer la sauvegarde "
	echo "5) Plannifier la sauvegarde"
	echo "6) Quitter"
	
}

# Ajouter une entrée à folder.list
add_source()
{	
	echo "Ajout de source sélectionné"
	read -p "Entrez le chemin à ajouter : " new_source
	if [ -d $new_source ]
	then
		read -p "Voulez vous rajouter $new_source à vos dossier à sauvegarder : Y/N " validation
		case $validation in
		[Yy]* )
			absolute_new_source=$(realpath $new_source)
			echo "$absolute_new_source" >> folder.list
			echo "Le dossier $absolute_new_source à bien été ajouté"
			pause
		;;
		* )
			echo "Le dossier $new_source n'a pas été ajouté"
			pause
		esac
	else
		echo "$new_source n'est pas un dossier"
		pause
	fi
}

# Supprimer une entrée à folder.list
del_source()
{
	if [ -s folder.list ]
	then
		echo "Suppression de source sélectionné"	
		PS3="Choisissez une option : "

		items=($(cat folder.list))
		lines=$(wc -l < folder.list)
		select item in "${items[@]}" Annuler
		do
			if [ "$REPLY" = $((${#items[@]}+1)) ]
			then
				echo "Annulation de la suppresion"
				pause
				break
			elif (( "$REPLY" > 0 && "$REPLY" <= lines ))
			then
				read -p "Voulez vous enlever $item : Y/N " validation
				case $validation in
				[Yy]* )
					if [ $(wc -l < folder.list) -eq 1 ]
					then
						cp /dev/null folder.list
					else
						grep -v "$item$" folder.list > tmpfile && mv tmpfile folder.list
					fi
					if [ $? -ne 0 ] 
					then
						echo "Erreur lors de la supression du dossier $item"
						pause

					else
						echo "Le dossier $item à bien été enlevé"
						pause
					fi
					;;
				* )
					echo "Annulation, Le dossier $item n'a pas été enlevé"
					pause
				esac
				break
			else
				echo "Choix invalide"
				pause
				break
			fi
		done
	else
		echo "Aucune source à supprimer"
		pause
	fi
}

# Editer la destination de sauvegarde
edit_destination()
{
	echo "Ajout de la destination"
	echo  "Entrez le chemin de la destination"
	read -p "(Pour supprimer valider sans entrer de valeur) : " new_destination

	if [ -z "$new_destination" ]
	then
		echo "Suppression de la destination de sauvegarde"
		cp /dev/null destination.list
		pause
	else
		if [ -d "$new_destination" ]
		then
			read -p "Voulez vous que $new_destination devienne votre chemin de sauvegarde : Y/N " validation
			case $validation in
			[Yy]* )
				absolute_new_destination=$(realpath $new_destination)
				echo "$absolute_new_destination" > destination.list
				echo "Le dossier $absolute_new_destination à bien été ajouté"
				pause
			;;
			* )
				echo "Le dossier $new_destination n'a pas été ajouté"
				pause
			esac
		else	
			read -p " Le dossier n'existe pas, voulez-vous le créer : y/n " test
			if [ "$test" = "y" ] || [ "$test" = "Y" ]; then
				mkdir -p "$new_destination"
				echo " le dossier est créé "
				echo "$new_destination" > destination.list
				pause
			else
				echo "Annulation, $new_destination n'est pas un dossier"
				pause
			fi

			
		fi
	fi
}

# Effectuer la sauvegarde
launch_backup()
{	
	echo Initialisation de la sauvegarde
	if [ -s folder.list -a -s destination.list ]
	then
		conflict=0
		absolute_destination_path=$(realpath $(cat destination.list))
		for source in $(cat folder.list)
		do
			if [[ $absolute_destination_path == *$source* ]]
			then
				conflict=1
				echo "$absolute_destination_path est dans une source veuiller modifier les chemins"
			fi
		done

		if [ $conflict -eq 0 ]
		then 
			timestamp=$(date +%Y%m%d-%H%M%S)
			backup_destination=$absolute_destination_path/BKP-$timestamp
			echo "Début de la sauvegarde $timestamp"
			mkdir $backup_destination
			for source in $(cat folder.list)
			do
				folder=$(basename $source)
				tar -czf $backup_destination/$folder.tgz $source && printf "Sauvegarde terminée\n" || printf "Erreur lors de la sauvegarde\n"
			done
		fi
		pause
	else
		if [ ! -s folder.list ]; then echo "Aucune source définie"; fi
		if [ ! -s destination.list ]; then echo "Aucune destination définie"; fi
		pause
	fi
}

# Changer la plannification
edit_cron()
{
	echo "édition de la planification"
}

# Lire la sélection
read_option()
{
	read -p "Choisissez une option [ 1 - 6 ]: " option
	case $option in
		1) add_source ;;
		2) del_source ;;
		3) edit_destination ;;
		4) launch_backup ;;
		5) edit_cron ;;
		6) echo "Arret du script de sauvegarde" ; exit 0 ;;
		*) echo "Selection invalide"; pause
	esac
}

##! SCRIPT
check_files

while true
do
	clear
	show_folder
	show_destination
	show_menu
	read_option	
done