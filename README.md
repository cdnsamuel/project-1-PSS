# Projet 1 : Script de sauvegarde Bash

## Description :
Ce script est en cours de rédaction,
Son objectif est de pouvoir gérer des sauvegardes:
- le ficher **folder.list** :  
    ce fichier regroupe la liste des cibles de la sauvegarde
    les deux premières fonctions permettent de modifier ce fichier
    ce fichier est lu au lancement du script et retourné à l'utilisateur pour qu'il sache ce qui va être sauvegardé
      
- le fichier **destination.list** :  
    ce fichier stocke la dernière destination de l'utilisateur
    afin de la reproposer sur un lancement ultérieur ou lors d'un cron-job
       
- le fichier **backup.sh** :  
    contient les différentes fonctions exécutée par le script
    - 1 - Ajouter une source de sauvegarde  
        Permet l'ajout des dossiers à sauvegarder
    - 2 - Supprimer une source de sauvegarde  
        Permet la suppression des dossiers à sauvegarder
    - 3 - Modifier la destination de sauvegarde  
        Permet l'ajout ou la modification de l'emplacement ou stocker la sauvegarde
    - 4 - Lancer la sauvegarde   
        Lance la fontion de sauvegarde
    - 5 - Plannifier la sauvegarde  
        Permet de lancer le script de manière automatique régulièrement
    - 6 - Supprimer les tâches planifiées  
        Supprime TOUTES les tâches planifiées de l'utilisateur éxécutant le script
    - 7 - Quitter
