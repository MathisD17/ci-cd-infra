# ToDoList CI/CD Project

**Auteur :** @Noah Louineau, Mathis Dizet  
**Date :** 2025-08-27

Ce projet regroupe le **backend** et le **frontend** de l’application ToDoList, avec **CI/CD**, **Docker**, et déploiement sur **AKS**. L’objectif est de mettre en place un workflow complet de production d’une application conteneurisée, avec tests automatisés, build/push des images, et orchestration Kubernetes.

---

## 🚀 Technologies utilisées

- Backend : Node.js, Express, Sequelize, MySQL  
- Frontend : Angular 15  
- Conteneurisation : Docker, Docker Compose  
- Orchestration : Kubernetes (AKS), Helm (NGINX Ingress)  
- Infrastructure as Code : Terraform (AKS, ressources Azure)  
- CI/CD : GitHub Actions  
- Monitoring : Prometheus + Grafana (exposition de métriques et dashboards)

---

## 🗂️ Structure du projet

```
ci-cd-infra/
├── .github/workflows/       # CI/CD : tests, build, push, deploy
├── iac/                     # Terraform pour AKS et ressources associées
├── k8s/                     # Manifests Kubernetes (PVC, Deployments, Services, Ingress)
├── projet_devops_backend/
│   ├── src/
│   ├── config/
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── services/
│   ├── docs/
│   ├── middlewares/
│   ├── app.js
│   └── server.js
│   ├── tests/
│   ├── scriptSQL.sql
│   ├── .env
│   └── package.json
├── projet_devops_frontend/
│   ├── src/
│   ├── angular.json
│   ├── Dockerfile
│   ├── package-lock.json
│   ├── package.json
│   └── README.md
├── monitoring/              # Prometheus + Grafana configuration
├── docker-compose.build.local.yml
├── docker-compose.prod.local.yml
└── README.md
```

---

## ⚙️ Préparation de l’infrastructure AKS

L’infrastructure est provisionnée avec **Terraform**.

1. Récupérer les fichiers Terraform depuis `iac/` :  
   ```bash
   cd iac
   ```
2. Personnaliser les variables (`variables.tf` et `terraform.tfvars`) pour votre abonnement Azure.  
3. Initialiser Terraform :  
   ```bash
   terraform init
   ```
4. Vérifier le plan :  
   ```bash
   terraform plan
   ```
5. Appliquer le plan pour créer le cluster AKS et ressources associées :  
   ```bash
   terraform apply
   ```
6. Assurez-vous d’être connecté à Azure (`az login`) pour que Terraform puisse créer les ressources.

**Choix techniques :**
- AKS pour orchestrer les conteneurs  
- PVC pour persistance MySQL  
- NGINX Ingress pour exposer le frontend et backend via une URL unique

---

## 🔑 Configuration des secrets GitHub pour l’accès AKS

Après avoir provisionné votre cluster AKS avec Terraform, vous devez récupérer le **fichier kubeconfig** pour permettre à GitHub Actions d’interagir avec votre cluster via `kubectl`.

1. **Récupérer le kubeconfig** généré par Terraform :

```bash
cd iac
terraform output kube_config > kubeconfig.yaml
```

2. **Extraire les valeurs importantes et les configurer comme secrets GitHub** :

| Variable | Description |
|----------|-------------|
| `KUBE_SERVER` | URL de l’API server AKS, ex: `https://aks-cluster-xxxx.hcp.region.azmk8s.io:443` |
| `KUBE_CERT` | Valeur de `client-certificate-data` dans kubeconfig |
| `KUBE_KEY` | Valeur de `client-key-data` dans kubeconfig |
| `KUBE_CA` | Valeur de `certificate-authority-data` dans kubeconfig |
| `KUBE_TOKEN` | Token si utilisé (optionnel selon votre configuration) |
| `KUBE_NAMESPACE` | Namespace Kubernetes où déployer l’application, ex: `todolist` |

3. **Ajouter ces secrets dans votre repository GitHub** :

- Aller dans **Settings → Secrets and Variables → Actions → New repository secret**  
- Créer chaque secret (`KUBE_SERVER`, `KUBE_CERT`, `KUBE_KEY`, `KUBE_CA`, `KUBE_TOKEN`, `KUBE_NAMESPACE`) avec les valeurs correspondantes extraites du kubeconfig.

4. **Utilisation dans GitHub Actions** :

- Le pipeline CI/CD utilisera ces secrets pour générer dynamiquement un fichier `kubeconfig.yaml` et configurer `kubectl` afin de déployer vos manifests dans le cluster AKS.
- Exemple dans le pipeline :

```yaml
- name: Configure kubeconfig
  run: |
    mkdir -p iac
    cat <<EOF > iac/kubeconfig.yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: ${{ secrets.KUBE_SERVER }}
    certificate-authority-data: ${{ secrets.KUBE_CA }}
  name: aks-cluster
contexts:
- context:
    cluster: aks-cluster
    user: aks-user
    namespace: ${{ secrets.KUBE_NAMESPACE }}
  name: aks-context
current-context: aks-context
users:
- name: aks-user
  user:
    client-certificate-data: ${{ secrets.KUBE_CERT }}
    client-key-data: ${{ secrets.KUBE_KEY }}
    token: ${{ secrets.KUBE_TOKEN }}
EOF
    echo "KUBECONFIG=$PWD/iac/kubeconfig.yaml" >> $GITHUB_ENV
```

**Pour exécuter le pipeline**, il suffit de faire un **push sur la branche `master`**.

---

## 📦 Conteneurisation et Docker

- Chaque composant possède son **Dockerfile** (backend & frontend)  
- Les images sont **buildées et poussées sur DockerHub** via Docker Compose et GitHub Actions  
- Exemple Docker Compose pour tester en local (`docker-compose.prod.local.yml`) :


```yaml
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: todolist_db
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql

  backend:
    image: teralti/todolist-backend:latest
    environment:
      DB_HOST: mysql
      DB_USER: root
      DB_PASSWORD: root
      DB_NAME: todolist_db
    ports:
      - "3000:3000"
    depends_on:
      - mysql
    command: sh -c "sleep 15 && npm run start"

  frontend:
    image: teralti/todolist-frontend:latest
    ports:
      - "4200:80"
    depends_on:
      - backend

volumes:
  mysql-data:
```

**Démarrage :**
```bash
docker-compose -f docker-compose.prod.local.yml up -d
docker ps
```

---

## 🏗️ CI/CD

Les pipelines GitHub Actions incluent :

1. **Tests unitaires**
   - Backend : Node.js + Jest + Supertest  
   - Frontend : Angular + Karma + ChromeHeadless  
2. **Build et push Docker**
   - Configuration des secrets DockerHub (`DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`)  
   - Build des images backend & frontend  
   - Push sur DockerHub
3. **Déploiement sur AKS**
   - Utilisation du kubeconfig avec les secrets GitHub pour se connecter à AKS (plus besoin de `azure/login@v2`)  
   - Installation NGINX Ingress (`helm upgrade --install`)  
   - Application des manifests Kubernetes (`kubectl apply -f k8s/`)  

**Remarque :** L’infra AKS est déjà déployée via Terraform, donc le pipeline ne gère que les tests, les build, push et déploiement.

**Déploiement manuel pour test** :  
Dans le projet, le déploiement est automatisé, mais si vous souhaitez tester les manifests sur votre machine, vous pouvez utiliser le kubeconfig localement et exécuter :

```bash
kubectl apply -f k8s/
kubectl get pods -n todolist
kubectl get svc -n todolist
kubectl rollout status deployment/backend -n todolist
kubectl rollout status deployment/frontend -n todolist
```

Cela permet de tester vos manifests sans passer par le pipeline.

---

## 🖥️ Déploiement manuel sur Kubernetes

1. Appliquer tous les manifests :  
```bash
kubectl apply -f k8s/
```

2. Vérifier les pods et services :  
```bash
kubectl get pods -n todolist
kubectl get svc -n todolist
```

3. Vérifier le rollout :  
```bash
kubectl rollout status deployment/backend -n todolist
kubectl rollout status deployment/frontend -n todolist
```

4. Accès via Ingress :  
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: todolist-ingress
  namespace: todolist
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
  rules:
    - host: todolist.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend
                port:
                  number: 80
          - path: /api/
            pathType: Prefix
            backend:
              service:
                name: backend
                port:
                  number: 3000
```

5. Configurer le fichier **hosts** pour accéder à `todolist.local` :
- Windows : `C:\Windows\System32\drivers\etc\hosts`  
- Linux/Mac : `/etc/hosts`

```
<INGRESS_PUBLIC_IP> todolist.local
```

---

## 📊 Monitoring

- **Prometheus** : collecte des métriques des pods et du cluster  
- **Grafana** : dashboards pour backend, frontend et base MySQL  
- Exposition des métriques personnalisées via endpoints `/metrics`

---

## ⚡ Difficultés rencontrées et solutions

| Problème | Solution |
|----------|---------|
| Backend dépendant de MySQL pour tests | Ajout d’un `initContainer` busybox pour attendre la readiness de MySQL |
| Build Angular dans Docker | Installation de Angular CLI globalement et ajustement de la commande `ng build --prod` |
| Déploiement AKS sécurisé | Utilisation d’Azure OIDC pour GitHub Actions, pas besoin de secrets JSON |
| Persistance des données MySQL | Définition d’un PVC dans Kubernetes avec 1Gi de stockage |
| Gestion de l’Ingress | Définition de règles pour frontend `/` et backend `/api` |

