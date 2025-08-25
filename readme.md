Liste des commandes à effectuer pour build les images backend,frontend
docker-compose -f docker-compose.build.yml build

Liste des commandes à effectuer pour push les images sur le registres : 
docker tag projet-frontend teralti/todolist-fronted:latest
docker push teralti/todolist-frontend:latest

docker tag projet-backend teralti/todolist-backend:latest
docker push teralti/todolist-backend:latest


Commande à faire pour déployer l'app conteneurisé 
docker-compose -f docker-compose.prod.yml up -d



etape 1
push sur la branch

etape 2
lancer les test unitaires 

etape 3
runner qui build image docker

etape 4
runner qui tag et push sur docker les images sur le registre

etape 5 
runner déploi l'infra AKS avec terraform
#déployer le fichier docker-compose.prod.yml sur le AKS 

etape 6 sur aks
kubectl apply -f k8s/todolist-all.yml

par la suite grafana 