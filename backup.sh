#!/bin/bash

##! VARIABLES
# Ajout des variables de couleur
# Couleurs de police
black_ft='\e[30m]'
red_ft='\e[31m'
green_ft='\e[32m'
yellow_ft='\e[33m'
blue_ft='\e[34m'
purple_ft='\e[35m'
cyan_ft='\e[36m'
grey_ft='\e[37m'
# Couleurs de fond
black_bg='\e[40m]'
red_bg='\e[41m'
green_bg='\e[42m'
yellow_bg='\e[43m'
blue_bg='\e[44m'
purple_bg='\e[45m'
cyan_bg='\e[46m'
grey_bg='\e[47m'
# couleur par defaut
clear='\e[0m'
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
	echo -e "⬇️ $cyan_ft Dossiers à sauvegarder $clear"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	if [ -s folder.list ]
	then
		cat folder.list
	else
		echo -e "Aucune$red_ft source$clear définie "
	fi
}

# Option 3:
show_destination()
{
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo -e "⬇️  $red_ft Destination de la sauvegarde $clear"
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
	echo; echo
	echo -n "          "
	echo -e "$blue_bg $red_ft             Menu Principal            $clear"
	echo; echo
	echo -en "$yellow_ft 1) Ajouter une source de sauvegarde $clear"
	echo; echo
	echo -en "$cyan_ft 2) Supprimer une source de sauvegarde $clear"
	echo; echo
	echo -en "$purple_ft 3) Modifier la destination de sauvegarde $clear"
	echo; echo
	echo -en "$grey_ft 4) Lancer la sauvegarde $clear"
	echo; echo
	echo -en "$green_ft 5) Plannifier la sauvegarde $clear"
	echo; echo
	echo -en "$black_ft 6) Quitter $clear"
	echo; echo
	
	
}

# Ajouter une entrée à folder.list
add_source()
{	
	echo; echo
	echo -en "$yellow_ft Ajout de source sélectionné $clear"
	echo; echo
	
	pause
	read -p "Entrez le chemin à ajouter : " new_source
	if [ -d $new_source ]
	then
		read -p " Voulez vous rajouter  $new_source à vos dossier à sauvegarder : Y/N " validation
		case $validation in
		[Yy]* )
			echo "$new_source" >> folder.list
			echo; echo
			echo -en " $green_bg Le dossier $new_source à bien été ajouté $clear"
			echo; echo
			pause
		;;
		* )
			echo; echo
			echo -en "$red_bg Le dossier $new_source n'a pas été ajouté $clear"
			echo; echo
			pause
		esac
	else
		echo -e "$red_ft $new_source n'est pas un dossier $clear"
		pause
	fi
}

# Supprimer une entrée à folder.list
del_source()
{
	echo; echo
	echo -en "$cyan_ft Suppression de source sélectionné $clear"
	echo; echo
	pause
	read -p "Entrez le chemin à enlever : " source
	if grep -q "$source$" folder.list
	then
		read -p "Voulez vous enlever $source de vos dossier à sauvegarder : Y/N " validation
		case $validation in
		[Yy]* )
			if [ $(wc -l < folder.list) -eq 1 ]
			then
				cp /dev/null folder.list
			else
				grep -v "$source$" folder.list > tmpfile && mv tmpfile folder.list
			fi
			if [ $? -ne 0 ] 
			then
				echo; echo
				echo -en "$red_ft Erreur lors de la supression du dossier $source $clear"
				echo; echo
				pause

			else
				echo; echo
				echo -en "$green_ft Le dossier $source à bien été enlevé $clear"
				echo; echo
				pause
			fi
		;;
		* )
			echo; echo
			echo -en "$red_ft annulation, Le dossier $source n'a pas été enlevé $clear"
			echo; echo
			pause
		esac
	else
		echo; echo
		echo -en "$red_ft $source n'est pas dans la liste des sources de sauvegardes $clear"
		echo; echo
		
		pause
	fi
}

# Editer la destination de sauvegarde
edit_destination()
{	echo; echo
	echo -en "$purple_ft Ajout de la destination $clear"
	echo; echo
	pause
	echo  "Entrez le chemin de la destination"
	read -p "(Pour supprimer valider sans entrer de valeur) : " new_destination

	if [ -z "$new_destination" ]
	then
		echo; echo
		echo -en "$green_bg Suppression de la destination de sauvegarde $clear"
		echo; echo
		cp /dev/null destination.list
		pause
	else
		if [ -d "$new_destination" ]
		then
			read -p "Voulez vous que $new_destination devienne votre chemin de sauvegarde : Y/N " validation
			case $validation in
			[Yy]* )
				echo "$new_destination" > destination.list
				echo; echo
				echo -en "$green_ft Le dossier $new_destination à bien été ajouté $clear"
				echo; echo
				pause
			;;
			* )
				echo; echo
				echo -en "$red_ft Le dossier $new_destination n'a pas été ajouté $clear"
				echo; echo
				pause
			esac
		else	
			read -p " Le dossier n'existe pas, voulez-vous le créer : y/n " test
			if [ "$test" = "y" ] || [ "$test" = "Y" ]; then
				mkdir -p "$new_destination"
				echo; echo
				echo -en "$green_bg le dossier est créé $clear"
				echo; echo
				echo "$new_destination" > destination.list
				pause
			else
				echo; echo
				echo -en "$red_bg Annulation, $new_destination n'est pas un dossier $clear"
				echo; echo
				pause
			fi

			
		fi
	fi
}

# Effectuer la sauvegarde
launch_backup()
{	
	if [ -s folder.list -a -s destination.list ]
	then
		echo; echo
		echo -en "$grey_ft Début de la sauvegarde $clear"
		echo; echo
		pause
	else
		if [ ! -s folder.list ]; then echo -en "$red_ft Aucune source définie $clear"; fi
		if [ ! -s destination.list ]; then echo "$red_ft Aucune destination définie $clear"; fi
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
		6) echo "Arret de script" ; exit 0 ;;
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