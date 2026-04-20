# 🐳 Mongo Blog Docker

**Tag publié :** `kikslamenace/mongo-blog:1.0.0` — [Docker Hub](https://hub.docker.com/r/kikslamenace/mongo-blog)

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
  kikslamenace/mongo-blog:1.0.0
```