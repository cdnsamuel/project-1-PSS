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

# Option 4:
show_cron()
{
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "⬇️  Tache Cron En Cours"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	if [ -s cron.list ]
	then
		cat cron.list
	else
		echo "Aucune Sauvegarde planifiée"
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

    echo "Veuillez spécifier la fréquence des sauvegardes (quotidien/hebdomadaire) :"
    read frequency

    if [ "$frequency" != "quotidien" ] && [ "$frequency" != "hebdomadaire" ]; then
        echo "Erreur : Fréquence invalide. Choisissez 'quotidien' ou 'hebdomadaire'."
        pause
    fi

    echo "Veuillez spécifier l'heure de la sauvegarde (En format 24 heures, ex. 02:30) :"
    read cron_time
cron_command="$cron_time * *"

    if [ "$frequency" == "quotidien" ]; then
        cron_command="$cron_command *"
    elif [ "$frequency" == "hebdomadaire" ]; then
        echo "Veuillez spécifier le jour de la semaine pour la sauvegarde (de 0 a 7) 
		0 = dimanche
		1 = lundi
		2 = mardi
		3 = mercredi
		4 = jeudi
		5 = vendredi
		6 = samedi
		7 = dimanche"
        read day_of_week
        cron_command="$cron_command $day_of_week"
		pause
    fi

	echo "Vous avez plannifié la frequence maintenant veuillez ajouter la source à sauvegarder"
	pause
	read -p "Entrez le chemin à ajouter : " new_source
	if [ -d $new_source ]
	then
		read -p "Voulez vous rajouter $new_source à vos dossier à sauvegarder : Y/N " validation
		case $validation in
		[Yy]* )
			echo "$new_source" >> cron.list
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

    (crontab -l ; echo "$cron_command $sauvegarde backup_now") | crontab -
    echo "Tâche cron ajoutée avec succès."
	pause
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
	show_cron
	show_menu
	read_option	
done