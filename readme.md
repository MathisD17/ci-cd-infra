# README - Projet DevOps (Frontend & Backend)

## Table des matières
1. [Prérequis](#prérequis)  
2. [Build et test local des images Docker](#build-et-test-local-des-images-docker)  
3. [Push des images sur le registre Docker](#push-des-images-sur-le-registre-docker)  
4. [Test depuis une autre machine](#test-depuis-une-autre-machine)  
5. [Déploiement continu](#déploiement-continu)  
6. [Historique de la première journée](#historique-de-la-première-journée)  
7. [À faire](#à-faire)  

---

## Prérequis
- Docker et Docker Compose installés sur votre machine.
- Clone des dépôts suivants : `projet_devops_frontend` et `projet_devops_backend`.
- Récupérer le fichier `docker-compose-build.local.yml` depuis le dépôt `ci-cd-infra`.

### Arborescence locale
\```
| docker-compose-build.local.yml
|___ projet_devops_frontend
     |___ Dockerfile
|___ projet_devops_backend
     |___ Dockerfile
\```


---

## Build et test local des images Docker

### Étapes :
1. Placer le fichier `docker-compose-build.local.yml` à la racine de votre répertoire local.
2. Exécuter la commande suivante pour build les images :

\```bash
docker-compose -f docker-compose-build.local.yml build
\```
> Note : Les images créées prendront le nom du répertoire parent suivi du nom de service défini dans le fichier `docker-compose-build.local.yml`.


---

## Push des images sur le registre Docker

### Commandes pour le push :
\```bash
docker tag nom_repertoire_parent-frontend teralti/todolist-frontend:latest
docker push teralti/todolist-frontend:latest

docker tag nom_repertoire_parent-backend teralti/todolist-backend:latest
docker push teralti/todolist-backend:latest
\```

---

## Test depuis une autre machine
1. Récupérer le fichier `docker-compose.prod.local.yml` depuis le dépôt `ci-cd-infra`.
2. Déployer l’application conteneurisée depuis Docker Hub :
\```bash
docker-compose -f docker-compose.prod.local.yml up -d
\```

---

## Déploiement continu de l'application

### Étapes :

1. **Activation des pipelines**
   - Push sur la branche `master` des dépôts frontend et backend.

2. **Exécution des pipelines**
   - Lancement des tests unitaires.

3. **Conteneurisation avec GitHub Runner**
   - Si les tests unitaires réussissent, le runner build et push les images Docker sur Docker Hub.

4. **Activation du pipeline du dépôt `ci-cd-infra`**
   - Si les pipelines frontend et backend sont validés, le runner déploie l’infra AKS avec Terraform et déploie les manifests Kubernetes présents dans le dépôt `ci-cd-infra`.

5. **Déploiement sur AKS**
\```bash
kubectl apply -f k8s/todolist-all.yml
\```

6. **Monitoring**
   - Grafana pourra être utilisé pour surveiller les applications et les conteneurs.

---

## Historique de la première journée

### Matin
- Fork des dépôts `frontend` et `backend`.
- Création des Dockerfile.
- Création du Docker Compose pour build les images (version **local**).

### Après-midi
- Création du dépôt `ci-cd-infra` pour déployer l’infra AKS et les manifests.

### Soir
- Création des workflows GitHub Actions pour :
  - `frontend`  
  - `backend`
- Pipelines de tests unitaires :
  - Backend : tests validés après ajout de la BDD, push de l’image Docker validé.
  - Frontend : tests unitaires partiellement ignorés, push de l’image Docker validé.
- Test des images Docker déployées depuis GitHub Actions :
  - Utilisation du fichier `docker-compose.prod.local.yml` → fonctionnement OK.

---

## À faire
- Une fois les pipelines validés, le dépôt `ci-cd-infra` doit :
  1. Déployer l’infrastructure AKS via Terraform.
  2. Déployer le manifest Kubernetes sur AKS.