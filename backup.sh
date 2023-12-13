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
	clear
	if [ -s folder.list ]
	then
		echo "~~~~~~~~~~~~~~~~~~~~~~~~~"
		echo "Dossiers à sauvegarder"
		echo "~~~~~~~~~~~~~~~~~~~~~~~~~"
		cat folder.list
		echo
	else
		echo "La liste de dossier à sauvegarder est vide"
	fi
}

# Afficher le menu 
show_menu()
{	
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "Menu Principal"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~"
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
	pause
	read -p "Entrez le chemin à ajouter : " new_source
	read -p "Voulez vous rajouter $new_source à vos dossier à sauvegarder : Y/N " validation
	case $validation in
	[Yy]* )
		echo "$new_source" >>. folder.list
		echo "Le dossier $new_source à bien été ajouté"
		pause
	;;
	* )
		echo "Le dossier $new_source n'a pas été ajouté"
		pause
	esac
}

# Supprimer une entrée à folder.list
del_source()
{
	echo "supppression"
}

# Editer la destination de sauvegarde
edit_destination()
{
	echo "edition de la destination"
}

# Effectuer la sauvegarde
launch_backup()
{
	echo "début de la sauvegarde"
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
		*) echo "Selection invalide"
	esac
}

##! SCRIPT
check_files

while true
do
	show_folder
	show_menu
	read_option	
done