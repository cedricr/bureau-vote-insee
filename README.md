# Génération des contours des bureaux de vote

Ce script génère une approximation du contour des bureaux de vote à partir du
répertoire électoral unique et permanent de l’INSEE, en utilisant le code
proposé ici par l’INSEE : https://github.com/inseeFrLab/mapvotr

Pour plus de détail sur la méthodologie, voir le billet de blog de l’INSEE :
https://blog.insee.fr/a-vote-a-chaque-bureau-de-vote-ses-electeurs/

Une proposition de contours alternative a été réalisée par l’équipe de
data.gouv.fr. Elle est disponible ici :
https://www.data.gouv.fr/fr/datasets/proposition-de-contours-des-bureaux-de-vote/

Le code de l’INSEE ne génère les contours que d’une seule commune à la fois. On
se contente ici de :

- télécharger les données sources nécessaire
- faire tourner le code sur l’ensemble des communes, en le parallélisant
- utiliser le contour communal complet lorsqu’il n’y a qu’un seul bureau de vote
  dans une commune (le code l’INSEE ne renvoie rien dans ces cas-là)
- croiser les résultats avec la table des bureaux de vote, afin de récupérer
  l’identifiant officiel
- renommer les champs afin d’avoir un résultat relativement interchangeables
  avec les contours proposés par data.gouv
- exporter le résultat final au format topojson

Le fichier généré a été publié sur
[data.gouv.fr](https://www.data.gouv.fr/fr/datasets/proposition-de-contours-des-bureaux-de-vote-selon-la-methode-de-linsee/)

## Prérequis

- 7za
- R
- mapshaper

## Génération

`make all`, qui va générer le fichier `export/contours_bureaux_vote.topojson`

## Sources :

- Bureaux de vote et adresses de leurs électeurs :  
  https://www.data.gouv.fr/fr/datasets/bureaux-de-vote-et-adresses-de-leurs-electeurs/

  - Table des adresses
    https://static.data.gouv.fr/resources/bureaux-de-vote-et-adresses-de-leurs-electeurs/20230626-140445/table-adresses-reu.csv
  - Table des bureaux de vote  
    https://static.data.gouv.fr/resources/bureaux-de-vote-et-adresses-de-leurs-electeurs/20230626-135808/table-bv-reu.csv

- Contours communaux et données départementales IGN Admin Express COG Carto :
  https://data.geopf.fr/telechargement/download/ADMIN-EXPRESS/ADMIN-EXPRESS_3-2__SHP_WGS84G_FRA_2024-06-19/ADMIN-EXPRESS_3-2__SHP_WGS84G_FRA_2024-06-19.7z
