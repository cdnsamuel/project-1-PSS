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
	if [ -s destination.list ]
	then
		cat destination.list
	else
		echo "Aucune destination définie"
	fi
}

# Option 4:
show_cron()
{
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "⬇️  Planification"
	crontab -l 1>/dev/null 2>&1 
	if (( $? == 0 ))
	then 
		crontab -l
	else
		echo "Aucune tâche planifiée"
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
	echo "6) Supprimer les planifications"
	echo "7) Quitter"
	
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
			echo "Annulation, $new_source n'est pas un dossier"
			pause
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

	PS3="Choisissez une option : "
	select option in "Quotidien" "Hebdomadaire" "Annuler"
	do
		if [ "$REPLY" = 3 ]
		then
			echo "Annulation de la planification"
			pause
			break
		elif [ "$REPLY" = 2 ]
		then
			PS3="Choisissez un jour de la semaine - [ 1 - 7 ] : "
			select day in "Lundi" "Mardi" "Mercredi" "Jeudi" "Vendredi" "Samedi" "Dimanche"
			do
				case $REPLY in
				1)
					cron_dow=1 
					echo "Vous avez sélectionné $day"
					break;;
				2)
					cron_dow=2 
					echo "Vous avez sélectionné $day"
					break
					;;
				3)
					cron_dow=3
					echo "Vous avez sélectionné $day"
					break;;
				4)
					cron_dow=4
					echo "Vous avez sélectionné $day"
					break;;
				5)
					cron_dow=5
					echo "Vous avez sélectionné $day"
					break;;
				6)
					cron_dow=6
					echo "Vous avez sélectionné $day" 
					break;;
				7)
					cron_dow=0
					echo "Vous avez sélectionné $day" 
					break;;
				*)
					echo "Selection invalide" ;;
				esac
			done
			break
		elif [ "$REPLY" = 1 ]
		then
			cron_dow=*
			echo "Vous avez sélectionné Quotidien"
			break;
		else
			echo "Choix invalide"
			pause
			break
		fi
	done
	while true
	do
	echo "Veuillez spécifier l'heure de la sauvegarde ( hh:mm, ex. 14:30 ) : " 
	read cron_time
	if [[ $cron_time =~ ^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$ ]]
	then
		cron_hour=$(echo $cron_time | cut -d':' -f 1 )
		cron_minute=$(echo $cron_time | cut -d':' -f 2 )
		break
	else
		echo -e "{$red_ft}Entrée invalide$clear"
	fi
	done
	echo "Sauvegarde programmée $cron_dow à $cron_hour:$cron_minute"
	(crontab -l 2>&1 | echo "$cron_minute $cron_hour * * $cron_dow $(realpath $(basename "$0")) auto >> $(realpath .)/cron.log") | crontab -
	pause
}

# Commande executée lors du cron
launch_cron_backup()
{
	echo "cron backup"
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
		6) echo "Suppression des tâches programmées"; crontab -r; pause ;;
		7) echo "Arret de script" ; exit 0 ;;
		*) echo "Selection invalide"; pause
	esac
}

##! SCRIPT
check_files

if [ $# == 1 -a $1 == "auto" ]
then
	echo "$(realpath $(basename "$0"))"
	launch_cron_backup
else
	while true
	do
		clear
		show_folder
		show_destination
		show_cron
		show_menu
		read_option	
	done
fi

