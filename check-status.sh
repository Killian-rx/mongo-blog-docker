CONTAINER="blog-mongo"
source .env

# 1. L'utilisateur n'est pas root
USER=$(docker exec "$CONTAINER" whoami)
if [ "$USER" != "root" ]; then
  echo "[OK] Utilisateur : $USER (non-root)"
else
  echo "[FAIL] Le conteneur tourne en root"
  exit 1
fi

# 2. La base blog_db répond et contient les posts
COUNT=$(docker exec "$CONTAINER" mongosh --quiet \
  -u "$MONGO_INITDB_ROOT_USERNAME" \
  -p "$MONGO_INITDB_ROOT_PASSWORD" \
  --authenticationDatabase admin \
  --eval "db.getSiblingDB('blog_db').posts.countDocuments()" | tail -n1)

if [ "$COUNT" -ge 5 ] 2>/dev/null; then
  echo "[OK] Base blog_db : $COUNT posts trouvés"
  echo "[SUCCES] Tous les contrôles sont passés."
else
  echo "[FAIL] Base blog_db injoignable (réponse: $COUNT)"
  exit 1
fi