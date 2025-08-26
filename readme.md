Build et Test local de nos images

clone les répertoire projet_devops_frontend et projet_devops_backend dans un répertoir local sur votre machine

Dockerfile présent dans les répertoir de projet_devops_frontend et projet_devops_backend

A la racine de votre répertoir local, récupérer le fichier docker-compose-build.local.yml du dépot github ci-cd-infra

Arborescence :

|docker-compose-build.local.yml
|___projet_devops_frontend
    |___Dockerfile
|___projet_devops_backend
    |___Dockerfile


Liste des commandes à effectuer pour build les images backend,frontend

docker-compose -f docker-compose-build.local.yml build
Note : les images créer prendrons le nom du répertoir parent suivi du nom de service défini dans le fichier docker-compose-build.local.yml


Liste des commandes à effectuer pour push les images sur le registres : 

docker tag nom_repertoir_parent-frontend teralti/todolist-fronted:latest
docker push teralti/todolist-frontend:latest

docker tag  nom_repertoir_parent-backend teralti/todolist-backend:latest
docker push teralti/todolist-backend:latest

test depuis une autre machine avec docker d'installer :
Commande à faire pour déployer l'app conteneurisé depuis le registre Dockerhub

récupérer le fichier docker-compose-build.local.yml du dépot github ci-cd-infra

docker-compose -f docker-compose.prod.local.yml up -d

--------------------------------------------------------------------------------------------


Déploiement continue de l'application 

etape 1 : Activation des pipelines
push sur les branch master de frontend et backend

etape 2 : Execution des pipelines
Test unitaire qui se lance

etape 3 : conteneurisation avec le runner github
Si tests unitaire réussi => runner qui build et push les images docker sur docker hub

etape 4 : Activation pipepline du répertoir ci-cd-infra 
Si les pipeline de frontend et backend sont validé alors => runner déploi l'infra AKS avec terraform puis déploiement du manifest qui est sur dans le dépot ci-cd-infra

etape 6 sur aks depuis le pipeline
kubectl apply -f k8s/todolist-all.yml

par la suite grafana 




Historique de la première journée : 
Le matin 
fork des 2 dépots frontend et backend



Création des docker file 

(exemple des docker file)

Création docker-compose pour build les images 


(Version build local)

Création docker-compose pour récuperer et exécuter les images docker
(Version prod pull images et déploiement)



Aprem

création d'un depot ci-cd-infra qui va déployer l'infra aks, manifest ...



Le soir

Création de github\workflows pour les dépots : 
frontend 
backend



Création des pipeline test unitaires

Backend validé, j'ai du ajouté une BDD dans le pipe pour validé les tests
push de l'image sur docker validé

frontend  validé mais j'ai skip des tets
modification des tests unitaire pas bon
push de l'image sur docker validé


ensuite des que ces pipes sont validés 

le depot ci-cd-infr éxecute un pipe pour déployer l'infra aks avec terraform


déploi aussi le manifest sur aks