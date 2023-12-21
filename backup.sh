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
	echo -e "\033[1m⬇️  Dossiers à sauvegarder\033[0m"
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
	echo -e "\033[1m⬇️  Destination de la sauvegarde\033[0m"
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
	echo -e '\E[37;44m'"\033[1m              Menu Principal            \033[0m"
	echo; echo
	echo -en '\E[67;33m'"\033[1m1) Ajouter une source de sauvegarde\033[0m"
	echo; echo
	echo -en '\E[67;36m'"\033[1m2) Supprimer une source de sauvegarde\033[0m"
	echo; echo
	echo -en '\E[67;35m'"\033[1m3) Modifier la destination de sauvegarde\033[0m"
	echo; echo
	echo -en '\E[67;37m'"\033[1m4) Lancer la sauvegarde\033[0m"
	echo; echo
	echo -en '\E[67;32m'"\033[1m5) Plannifier la sauvegarde\033[0m"
	echo; echo
	echo -en '\E[67;39m'"\033[1m6) Quitter\033[0m"
	echo; echo
	
	
}

# Ajouter une entrée à folder.list
add_source()
{	
	echo; echo
	echo -en '\E[67;33m'"\033[1mAjout de source sélectionné\033[0m"
	echo; echo
	
	pause
	read -p "Entrez le chemin à ajouter : " new_source
	if [ -d $new_source ]
	then
		read -p "Voulez vous rajouter $new_source à vos dossier à sauvegarder : Y/N " validation
		case $validation in
		[Yy]* )
			echo "$new_source" >> folder.list
			echo; echo
			echo -en '\E[47;32m'"\033[1mLe dossier $new_source à bien été ajouté1\033[0m"
			echo; echo
			pause
		;;
		* )
			echo; echo
			echo -en '\E[47;31m'"\033[1mLe dossier $new_source n'a pas été ajouté1\033[0m"
			echo; echo
			pause
		esac
	else
		echo -e "\033[1m$new_source n'est pas un dossier\033[0m"
		pause
	fi
}

# Supprimer une entrée à folder.list
del_source()
{
	echo; echo
	echo -en '\E[67;36m'"\033[1mSuppression de source sélectionné\033[0m"
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
				echo -en '\E[67;31m'"\033[1mErreur lors de la supression du dossier $source1\033[0m"
				echo; echo
				pause

			else
				echo; echo
				echo -en '\E[47;32m'"\033[1mLe dossier $source à bien été enlevé1\033[0m"
				echo; echo
				pause
			fi
		;;
		* )
			echo; echo
			echo -en '\E[47;31m'"\033[1mAnnulation, Le dossier $source n'a pas été enlevé1\033[0m"
			echo; echo
			pause
		esac
	else
		echo; echo
		echo -en '\E[67;31m'"\033[1m$source n'est pas dans la liste des sources de sauvegardes\033[0m"
		echo; echo
		
		pause
	fi
}

# Editer la destination de sauvegarde
edit_destination()
{
	echo "Ajout de la destination"
	pause
	echo  "Entrez le chemin de la destination"
	read -p "(Pour supprimer valider sans entrer de valeur) : " new_destination

	if [ -z "$new_destination" ]
	then
		echo; echo
		echo -en '\E[47;32m'"\033[1mSuppression de la destination de sauvegarde\033[0m"
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
				echo -en '\E[47;32m'"\033[1mLe dossier $new_destination à bien été ajouté\033[0m"
				echo; echo
				#echo "Le dossier $new_destination à bien été ajouté"
				pause
			;;
			* )
				echo; echo
				echo -en '\E[47;31m'"\033[1mLe dossier $new_destination n'a pas été ajouté\033[0m"
				echo; echo
				#echo "Le dossier $new_destination n'a pas été ajouté"
				pause
			esac
		else	
			read -p " Le dossier n'existe pas, voulez-vous le créer : y/n " test
			if [ "$test" = "y" ] || [ "$test" = "Y" ]; then
				mkdir -p "$new_destination"
				echo; echo
				echo -en '\E[47;32m'"\033[1mle dossier est créé \033[0m"
				echo; echo
				echo "$new_destination" > destination.list
				pause
			else
				echo; echo
				echo -en '\E[47;31m'"\033[1mAnnulation, $new_destination n'est pas un dossier \033[0m"
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
		echo -en '\E[67;37m'"\033[1mDébut de la sauvegarde\033[0m"
		echo; echo
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