FROM mongodb/mongodb-community-server:8.0-ubi8-slim

COPY --chown=mongod:mongod init-scripts/ /docker-entrypoint-initdb.d/

USER mongod

EXPOSE 27017