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
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo -n "          "
	echo -e '\E[37;44m'"\033[1m              Menu Principal            \033[0m"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo; echo
	echo -en '\E[67;34m'"\033[1m1) Ajouter une source de sauvegarde\033[0m"
	echo; echo
	echo -en '\E[67;36m'"\033[1m2) Supprimer une source de sauvegarde\033[0m"
	echo; echo
	echo -en '\E[67;34m'"\033[1m3) Modifier la destination de sauvegarde\033[0m"
	echo; echo
	echo -en '\E[67;34m'"\033[1m4) Lancer la sauvegarde\033[0m"
	echo; echo
	echo -en '\E[67;34m'"\033[1m5) Plannifier la sauvegarde\033[0m"
	echo; echo
	echo -en '\E[67;34m'"\033[1m6) Quitter\033[0m"
	echo; echo
	
	#echo "1) Ajouter une source de sauvegarde"
	
	#echo "2) Supprimer une source de sauvegarde"
	#echo "3) Modifier la destination de sauvegarde"
	#echo "4) Lancer la sauvegarde "
	#echo "5) Plannifier la sauvegarde"
	#echo "6) Quitter"
	
}

# Ajouter une entrée à folder.list
add_source()
{	
	echo "Ajout de source sélectionné"
	
	pause
	read -p "Entrez le chemin à ajouter : " new_source
	if [ -d $new_source ]
	then
		read -p "Voulez vous rajouter $new_source à vos dossier à sauvegarder : Y/N " validation
		case $validation in
		[Yy]* )
			echo "$new_source" >> folder.list
			echo "Le dossier $new_source à bien été ajouté"
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
	echo "Suppression de source sélectionné"
	pause
	read -p "Entrez le chemin à enlever : " source
	if grep -q "$source" folder.list
	then
		read -p "Voulez vous enlever $source de vos dossier à sauvegarder : Y/N " validation
		case $validation in
		[Yy]* )
			grep -v "$source" folder.list > tmpfile && mv tmpfile folder.list || cp /dev/null folder.list && rm tmpfile
			if [ $? ] 
			then
				echo "Le dossier $source à bien été enlevé"
				pause
			else
				echo "Erreur lors de la supression du dossier $source"
				pause
			fi
		;;
		* )
			echo "Annulation, Le dossier $source n'a pas été enlevé"
			pause
		esac
	else
		echo "$source n'est pas dans la liste des sources de sauvegardes"
		pause
	fi
}

# Editer la destination de sauvegarde
edit_destination()
{
	echo "Ajout de la destination"
	pause
	read -p "Entrez le chemin de la destination : " new_destination
	if [ -z $new_destination ]
	then
		echo "Suppression de la destination de sauvegarde"
		cp /dev/null destination.list
		pause
	else
		if [ -d $new_destination ]
		then
			read -p "Voulez vous que $new_destination devienne votre chemin de sauvegarde : Y/N " validation
			case $validation in
			[Yy]* )
				echo "$new_destination" > destination.list
				echo "Le dossier $new_destination à bien été ajouté"
				pause
			;;
			* )
				echo "Le dossier $new_destination n'a pas été ajouté"
				pause
			esac
		else	
			read -p " Le dossier n'existe pas, voulez-vous le créer : y/n " test
			if [ "$test" = "y" ] || [ "$test" = "Y" ]; then
				mkdir -p $new_destination
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
	if [ -s folder.list -a -s destination.list ]
	then
		echo "Début de la sauvegarde"
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