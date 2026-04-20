# 🐳 Mongo Blog Docker

> Image Docker personnalisée basée sur MongoDB, pré-configurée pour un moteur de blog, avec validation de schéma stricte et exécution en utilisateur non-root.

**Tag publié :** `kikslamenace/mongo-blog:1.0.0` — [Docker Hub](https://hub.docker.com/r/kikslamenace/mongo-blog)

---
## Structure du projet

```
.
├── Dockerfile                 # Image basée sur mongo:7.0
├── init-scripts/
│   └── init-blog.js          # Création collection + validator + seed 5 posts
├── check-status.sh            # Script de vérification (santé + non-root + data)
├── .env.example               # Modèle de variables d'env (à copier en .env)
├── .gitignore
└── README.md
```

## Démarrage rapide

### 1. Cloner et préparer l'environnement

```bash
git clone https://github.com/Killian-rx/mongo-blog-docker.git
cd mongo-blog-docker
cp .env.example .env
# → édite .env pour définir un VRAI mot de passe
```

### 2. Construire l'image

```bash
docker build -t kikslamenace/mongo-blog:1.0.0 .
```

### 3. Lancer le conteneur

```bash
docker run -d \
  --name blog-mongo \
  --env-file .env \
  -p 27017:27017 \
  kikslamenace/mongo-blog:1.0.0
```
### Script automatisé

```bash
chmod +x check-status.sh
./check-status.sh
```

Le script vérifie :
- Le conteneur tourne
- L'utilisateur interne n'est pas `root`
- Le process `mongod` n'est pas exécuté par `root`
- La base `blog_db` répond et contient ≥ 5 posts

### Manuel : `find()` sur la collection

```bash
docker exec -it blog-mongo mongosh \
  -u admin -p <ton_password> \
  --authenticationDatabase admin \
  --eval "db.getSiblingDB('blog_db').posts.find().pretty()"
```

### Manuel : vérifier l'utilisateur

```bash
docker exec blog-mongo whoami
# → mongodb (et non root)

docker ps
# → STATUS : Up, healthcheck OK
```

## Tests du validateur de schéma

Le validateur rejette toute insertion mal typée. Test à faire :

```bash
docker exec -it blog-mongo mongosh \
  -u admin -p <ton_password> \
  --authenticationDatabase admin \
  --eval "db.getSiblingDB('blog_db').posts.insertOne({ titre: 'Test', auteur: 'Kiks', vues: 'beaucoup' })"
```

**Résultat attendu :** une erreur `Document failed validation` car `vues` doit être un entier, pas une chaîne.

Autres cas rejetés :
- Champ manquant (ex : pas de `titre`)
- Type incorrect (`vues: 12.5` → double, pas int ; `titre: 42` → number au lieu de string)
- Champ supplémentaire non défini dans le schéma

## Publication Docker Hub

```bash
docker login
docker push kikslamenace/mongo-blog:1.0.0
```

## Sécurité

| Exigence | Implémentation |
|---|---|
| Image légère | `mongo:7.0`|
| Non-root | `USER mongodb` (UID 999) explicite dans le Dockerfile |
| Pas de secret en dur | Credentials via `--env-file .env`, `.env` dans `.gitignore` |
| Validation stricte | `validationLevel: strict`, `validationAction: error`, `additionalProperties: false` |
---