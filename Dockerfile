FROM mongo:7.0

COPY --chown=mongodb:mongodb init-scripts/ /docker-entrypoint-initdb.d/

USER mongodb

EXPOSE 27017