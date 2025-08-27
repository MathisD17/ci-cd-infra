# ToDoList Fullstack CI/CD Project

Projet d’application **ToDoList** mono-utilisateur avec déploiement automatisé sur **Azure Kubernetes Service (AKS)**, conteneurisation Docker, pipelines CI/CD et infrastructure gérée avec **Terraform**.

---

## 🏗️ Structure du projet

```
ci-cd-infra/
├── .github/workflows/           # Pipelines GitHub Actions
├── iac/                         # Infrastructure as Code (Terraform)
├── k8s/                         # Manifests Kubernetes (Deployments, Services, Ingress)
├── projet_devops_backend/       # Backend Node.js + MySQL
│   ├── src/
│   ├── config/
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── services/
│   ├── docs/
│   ├── middlewares/
│   ├── app.js
│   ├── server.js
│   ├── tests/
│   ├── scriptSQL.sql
│   ├── .env
│   ├── package.json
│   └── README.md
├── projet_devops_frontend/      # Frontend Angular
│   ├── src/
│   ├── angular.json
│   ├── package.json
│   ├── Dockerfile
│   ├── README.md
├── monitoring/
├── .gitignore
├── docker-compose.build.local.yml
├── docker-compose.prod.local.yml
└── README.md                    # Ce fichier
```

---

## 🚀 Technologies utilisées

- **Backend** : Node.js, Express, Sequelize, MySQL, Jest + Supertest, Swagger UI  
- **Frontend** : Angular 15, Karma + Jasmine  
- **CI/CD** : GitHub Actions, Docker, Docker Hub  
- **Infra / Déploiement** : Terraform, AKS, Helm, Kubernetes, Ingress NGINX  
- **Monitoring / Logs** : optionnel selon projet

---

## ⚙️ Préparation de l’infrastructure

1. Cloner le dépôt et accéder au dossier `iac/` contenant les fichiers Terraform.
2. Personnaliser les fichiers Terraform pour votre abonnement Azure.
3. Se connecter à Azure :

```bash
az login
```

4. Initialiser et appliquer Terraform :

```bash
terraform init
terraform plan
terraform apply
```

Cela crée le **cluster AKS** et les ressources nécessaires.

---

## 📦 Conteneurisation et Docker

### Dockerfiles

- Backend : `projet_devops_backend/Dockerfile`  
- Frontend : `projet_devops_frontend/Dockerfile`

### Docker Compose local pour tests

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
    build: ./projet_devops_backend
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
    build: ./projet_devops_frontend
    ports:
      - "4200:80"
    depends_on:
      - backend

volumes:
  mysql-data:
```

- Pour tests en production (images Docker Hub) : `docker-compose.prod.local.yml`.

---

## 🧪 Pipelines CI/CD

### Backend CI

- Test unitaire avec **Jest** + **MySQL service**.  
- Build et push de l’image Docker sur Docker Hub.  
- Context : `projet_devops_backend`.

### Frontend CI

- Test unitaire avec **Angular CLI / Karma / Jasmine**.  
- Build et push de l’image Docker sur Docker Hub.  
- Context : `projet_devops_frontend`.

### Déploiement AKS

- Workflow GitHub Actions déclenché après validation des pipelines frontend & backend.
- Authentification Azure via OIDC.
- Application des manifests Kubernetes dans `k8s/` :
  - Namespace `todolist`
  - Deployments & Services : MySQL, Backend, Frontend
  - Ingress NGINX pour exposer l’application web

---

## 🖥️ Accès à l’application

- **Frontend** : via Ingress NGINX sur le cluster AKS  
- **Backend API** : exposée sur `/api`  
- Documentation Swagger backend : `/api/docs`

---

## 📝 Tests unitaires

- Backend :

```bash
cd projet_devops_backend
npm install
npm test
```

- Frontend :

```bash
cd projet_devops_frontend
npm install
ng test --watch=false --browsers=ChromeHeadless
```

---

## 📌 Endpoints principaux

| Méthode | Endpoint         | Description                  |
|--------:|-----------------|------------------------------|
| GET     | /api/tasks      | Récupère toutes les tâches   |
| GET     | /api/tasks/:id  | Récupère une tâche           |
| POST    | /api/tasks      | Crée une tâche               |
| PUT     | /api/tasks/:id  | Met à jour une tâche         |
| DELETE  | /api/tasks/:id  | Supprime une tâche           |

---

## ✅ Bonnes pratiques CI/CD et déploiement

- Séparation des workflows **backend / frontend / déploiement**.  
- Déploiement conditionnel uniquement si tests backend et frontend sont réussis.  
- Rolling update AKS via `kubectl rollout`.  
- Utilisation de secrets GitHub pour Docker Hub et Azure.  
- Documentation Swagger générée automatiquement.  
- Dockerfiles optimisés pour build et déploiement rapide.

---

## 🎯 Grille d’évaluation C8 couverte

| Axe | Critère | Points |
|-----|---------|-------|
| 1   | Déploiement automatisé via CI/CD (tests exécutés, build, push image, déclenchement) | 4 |
| 2   | Déploiement fonctionnel sur AKS à l’aide de fichiers YAML | 4 |
| 3   | Conteneurisation claire et complète de l'application (Dockerfile, variables, ports…) | 2 |
| 4   | Utilisation cohérente de Terraform pour l’infrastructure cible (cluster, ressources) | 2 |
| 5   | Mise à jour de l’application par changement d’image/version via AKS (rolling update) | 1.5 |
| 6   | Présence d'une procédure d'installation et déploiement claire | 1.5 |
| 7   | Qualité de la documentation globale du projet (README principal, clarté, structure, complétude) | 1 |

