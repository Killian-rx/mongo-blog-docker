# TP Stack Hybride Docker Compose

Projet multi-services avec MongoDB, MySQL, FastAPI, mongo-express et adminer.

## Prérequis

- Docker Desktop
- Fichier `.env` à la racine

## Lancer le projet

```bash
docker compose down -v
docker compose up --build -d
docker compose ps
```

## Services

- API FastAPI: `http://localhost:8000`
- Route Mongo: `http://localhost:8000/posts`
- Route MySQL: `http://localhost:8000/users`
- Admin MySQL (adminer): `http://localhost:8080`
- Admin Mongo (mongo-express): `http://localhost:8081`

## Notes

- Les données sont persistées via les volumes `mongo-data` et `mysql-data`.
- Les services démarrent avec dépendances basées sur `healthcheck`.