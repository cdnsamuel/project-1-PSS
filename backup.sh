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
  printf "${cyan_ft}Appuyez sur la touche${yellow_ft} [Entrée] ${cyan_ft}pour continuer...${clear}"
  read fackEnterKey
}

# Afficher la liste des cibles
show_folder()
{
	echo -e "${cyan_ft}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo -e "▶️  Dossiers à sauvegarder${cyan_ft}"
	if [ -s folder.list ]
	then
		for line in $(cat folder.list)
		do
			echo -e "${cyan_ft}▶️  $line${clear}"
		done
	else
		echo -e ${red_ft}"❌  Aucune source définie${clear}"
	fi
}

# Option 3:
show_destination()
{
	echo -e  "${green_ft}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo -e "✅ Destination de la sauvegarde${clear}"
	if [ -s destination.list ]
	then
		for line in $(cat destination.list)
		do
			echo -e "${green_ft}✅ $line${clear}"
		done
	else
		echo -e "${red_ft}❌  Aucune destination définie${clear}"
	fi
}

# Option 4:
show_cron()
{
	echo -e "${yellow_ft}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo -e "⏲️  Planification${clear}"
	crontab -l 1>/dev/null 2>&1 
	if (( $? == 0 ))
	then 
		echo -e ${yellow_ft}
		crontab -l
		echo -e ${clear}
	else
		echo -e ${red_ft}"❌  Aucune planification définie"${clear}
	fi
}

# Afficher le menu 
show_menu()
{	
	echo -e "${purple_ft}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo -e "🚀 Menu Principal "
	echo -e "1) Ajouter une source de sauvegarde"
	echo -e "2) Supprimer une source de sauvegarde"
	echo -e "3) Modifier la destination de sauvegarde"
	echo -e "4) Lancer la sauvegarde"
	echo -e "5) Plannifier la sauvegarde"
	echo -e "6) Supprimer les plannifications${clear}"
	echo -e ${red_ft}"7) Quitter"${clear}
}

# Ajouter une entrée à folder.list
add_source()
{	
	echo -e "${purple_ft}Ajout de source sélectionné${clear}"
	printf "Entrez le chemin à ajouter : ${green_ft}" 
	read new_source
	if [ -d $new_source ]
	then
		printf "${clear}Voulez vous rajouter ${green_ft}$new_source${clear} à vos dossier à sauvegarder - ${yellow_ft}Y${clear}/${yellow_ft}N${clear} : "
		read validation
		case $validation in
		[Yy]* )
			absolute_new_source=$(realpath $new_source)
			echo "$absolute_new_source" >> folder.list
			echo -e "✅ Le dossier ${green_ft}$absolute_new_source${clear} à bien été ajouté"
			pause
		;;
		* )
			echo -e "${red_ft}❌  Le dossier ${yellow_ft}$new_source${red_ft} n'a pas été ajouté${clear}"
			pause
		esac
	else
		echo -e "❌ ${yellow_ft}$new_source ${red_ft}n'est pas un dossier${clear}"
		pause
	fi
}

# Supprimer une entrée à folder.list
del_source()
{
	if [ -s folder.list ]
	then
		echo -e "${purple_ft}Suppression de source sélectionné${clear}"	
		PS3="Choisissez une option : "

		items=($(cat folder.list))
		lines=$(wc -l < folder.list)
		select item in "${items[@]}" Annuler
		do
			if [ "$REPLY" = $((${#items[@]}+1)) ]
			then
				echo -e "${red_ft}❌ Annulation de la suppresion"
				pause
				break
			elif (( "$REPLY" > 0 && "$REPLY" <= lines ))
			then
				printf "Voulez vous enlever ${green_ft}$item${clear} : ${yellow_ft}Y${clear}/${yellow_ft}N${clear} " 
				read validation
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
						echo -e "${red_ft}❌ Erreur lors de la supression du dossier $item"
						pause

					else
						echo -e "✅ Le dossier ${green_ft}$item${clear} à bien été enlevé"
						pause
					fi
					;;
				* )
					echo -e "${red_ft}❌ Annulation, Le dossier ${yellow_ft}$item${red_ft} n'a pas été enlevé${clear}"
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
		echo -e "${red_ft}❌ Aucune source à supprimer${clear}"
		pause
	fi
}

# Editer la destination de sauvegarde
edit_destination()
{
	echo -e "${purple_ft}Ajout de la destination${clear}"
	echo  "Entrez le chemin de la destination"
	printf "(Pour supprimer valider sans entrer de valeur) : ${green_ft}"
	read new_destination

	if [ -z "$new_destination" ]
	then
		echo -e "${green_ft}✅ Suppression de la destination de sauvegarde"
		cp /dev/null destination.list
		pause
	else
		if [ -d "$new_destination" ]
		then
			printf "${clear}Voulez vous que ${green_ft}$new_destination${clear} devienne votre chemin de sauvegarde : ${yellow_ft}Y${clear}/${yellow_ft}N${clear} " 
			read validation
			case $validation in
			[Yy]* )
				absolute_new_destination=$(realpath $new_destination)
				echo "$absolute_new_destination" > destination.list
				echo -e "✅ Le dossier ${green_ft}$absolute_new_destination${clear} à bien été ajouté"
				pause
			;;
			* )
				echo -e "${red_ft}❌Le dossier ${yellow_font}$new_destination${red_ft} n'a pas été ajouté${clear}"
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
		conflict=0
		absolute_destination_path=$(realpath $(cat destination.list))
		for source in $(cat folder.list)
		do
			if [[ $absolute_destination_path == *$source* ]]
			then
				conflict=1
				echo -e "❌ ${yellow_ft}$absolute_destination_path ${red_ft}est dans une source veuiller modifier les chemins${clear}"
			fi
		done

		if [ $conflict -eq 0 ]
		then 
			timestamp=$(date +%Y%m%d-%H%M%S)
			backup_destination=$absolute_destination_path/BKP-$timestamp
			echo -e "${purple_ft}Début de la sauvegarde ${yellow_ft}$timestamp${clear}"
			mkdir $backup_destination
			for source in $(cat folder.list)
			do
				folder=$(basename $source)
				tar -czf $backup_destination/$folder.tgz $source && printf "${green_ft}✅ Sauvegarde terminée ${clear}\n" || printf "${red_ft}❌ Erreur lors de la sauvegarde${clear}\n"
			done
		fi
		pause
	else
		if [ ! -s folder.list ]; then echo -e "${red_ft}❌ Aucune source définie${clear}"; fi
		if [ ! -s destination.list ]; then echo -e "${red_ft}❌ Aucune destination définie${clear}"; fi
		pause
	fi
}

# Changer la plannification
edit_cron()
{
	echo -e "${purple_ft}Choix de plannification${clear}"
	PS3="Choisissez une option : "
	select option in "Quotidien" "Hebdomadaire" "Annuler"
	do
		if [ "$REPLY" = 3 ]
		then
			echo -e "${red_ft}Annulation de la planification${clear}"
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
					echo -e "Vous avez sélectionné ${green_ft}$day${clear}"
					break;;
				2)
					cron_dow=2 
					echo -e "Vous avez sélectionné ${green_ft}$day${clear}"
					break
					;;
				3)
					cron_dow=3
					echo -e "Vous avez sélectionné ${green_ft}$day${clear}"
					break;;
				4)
					cron_dow=4
					echo -e "Vous avez sélectionné ${green_ft}$day${clear}"
					break;;
				5)
					cron_dow=5
					echo -e "Vous avez sélectionné ${green_ft}$day${clear}"
					break;;
				6)
					cron_dow=6
					echo -e "Vous avez sélectionné ${green_ft}$day${clear}"
					break;;
				7)
					cron_dow=0
					echo -e "Vous avez sélectionné ${green_ft}$day${clear}"
					break;;
				*)
					echo "${red_ft}Selection invalide${clear}" ;;
				esac
			done
			break
		elif [ "$REPLY" = 1 ]
		then
			cron_dow=*
			echo -e "Vous avez sélectionné ${green_ft}Quotidien${clear}"
			break;
		else
			echo -e "${red_ft}Choix invalide${clear}"
			pause
			break
		fi
	done
	while true
	do
	echo -e "Veuillez spécifier l'heure de la sauvegarde ( ${yellow_ft}hh:mm${clear}, ex. 08:30 ) : " 
	read cron_time
	if [[ $cron_time =~ ^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$ ]]
	then
		cron_hour=$(echo $cron_time | cut -d':' -f 1 )
		cron_minute=$(echo $cron_time | cut -d':' -f 2 )
		break
	else
		echo -e "{${red_ft}}Entrée invalide${clear}"
	fi
	done
	echo -e "Sauvegarde programmée $cron_dow à $cron_hour:$cron_minute"
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
	printf "Choisissez une option [ ${yellow_ft}1${clear} - ${yellow_ft}6${clear} ] : " 
	read option
	case $option in
		1) add_source ;;
		2) del_source ;;
		3) edit_destination ;;
		4) launch_backup ;;
		5) edit_cron ;;
		6) echo -e "${purple_ft}Suppression des tâches programmées${clear}"; crontab -r; pause ;;
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

