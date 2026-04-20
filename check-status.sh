#!/usr/bin/env bash
# =============================================================================
# check-status.sh
# Vérifie la viabilité du conteneur MongoDB "blog":
#   1. Le conteneur est bien up
#   2. mongosh répond et la base blog_db contient bien les posts
#   3. Le process mongod ne tourne PAS en root
# =============================================================================

# Compat Git Bash / MSYS sous Windows : désactive la conversion automatique des paths
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL="*"

set -u

# --- Configuration ----------------------------------------------------------
CONTAINER_NAME="${CONTAINER_NAME:-blog-mongo}"
DB_NAME="${DB_NAME:-blog_db}"
if [ -f "$(dirname "$0")/.env" ]; then
  # shellcheck disable=SC1091
  set -a && . "$(dirname "$0")/.env" && set +a
fi
ROOT_USER="${MONGO_INITDB_ROOT_USERNAME:-admin}"
ROOT_PWD="${MONGO_INITDB_ROOT_PASSWORD:-changeme}"

# --- Couleurs ---------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC}   $*"; }
ko()   { echo -e "${RED}[FAIL]${NC} $*"; }
info() { echo -e "${YELLOW}[...]${NC}  $*"; }

EXIT_CODE=0

# --- 1. Le conteneur existe et tourne ? -------------------------------------
info "Vérification de l'état du conteneur '${CONTAINER_NAME}'..."
if ! docker ps --format '{{.Names}}' | grep -qx "${CONTAINER_NAME}"; then
  ko "Le conteneur '${CONTAINER_NAME}' n'est pas en cours d'exécution."
  echo "   Lance-le avec : docker run -d --name ${CONTAINER_NAME} --env-file .env -p 27017:27017 kiks/mongo-blog:1.0.0"
  exit 1
fi
ok "Conteneur '${CONTAINER_NAME}' en cours d'exécution."

# --- 2. L'utilisateur interne n'est PAS root --------------------------------
info "Vérification de l'utilisateur qui exécute le service..."
WHO=$(docker exec "${CONTAINER_NAME}" whoami 2>/dev/null | tr -d '[:space:]')
if [ "$WHO" = "root" ]; then
  ko "Le conteneur tourne en ROOT — inacceptable."
  EXIT_CODE=1
elif [ -z "$WHO" ]; then
  ko "Impossible de récupérer l'utilisateur via whoami."
  EXIT_CODE=1
else
  ok "Utilisateur interne : '${WHO}' (non-root) ✔"
fi

info "Vérification que le process mongod n'appartient pas à root..."
MONGO_OWNER=$(docker exec "${CONTAINER_NAME}" sh -c "ps -o user= -p \$(pgrep -n mongod)" 2>/dev/null | tr -d '[:space:]')
if [ -z "$MONGO_OWNER" ]; then
  ko "Process mongod introuvable dans le conteneur."
  EXIT_CODE=1
elif [ "$MONGO_OWNER" = "root" ]; then
  ko "Le process mongod est exécuté par root — inacceptable."
  EXIT_CODE=1
else
  ok "Process mongod exécuté par l'utilisateur '${MONGO_OWNER}' ✔"
fi

# --- 3. La base blog_db répond et contient des données ----------------------
info "Vérification de la base '${DB_NAME}' via mongosh..."

# On passe le JS via stdin puis on filtre : seule la ligne qui est purement
# un nombre est conservée (évite les prompts "test>" ajoutés par mongosh)
JS_CODE="print(db.getSiblingDB('${DB_NAME}').posts.countDocuments())"

RAW=$(echo "$JS_CODE" | docker exec -i "${CONTAINER_NAME}" mongosh \
  --quiet \
  -u "${ROOT_USER}" -p "${ROOT_PWD}" \
  --authenticationDatabase admin 2>/dev/null)

# Extrait le premier nombre présent dans la sortie, en ignorant prompts et bruit
COUNT=$(echo "$RAW" | grep -oE '[0-9]+' | head -n1)

if ! [[ "${COUNT:-}" =~ ^[0-9]+$ ]]; then
  ko "mongosh ne répond pas correctement (sortie brute: '${RAW}')."
  echo "   Vérifie tes credentials dans .env et les logs : docker logs ${CONTAINER_NAME}"
  EXIT_CODE=1
elif [ "$COUNT" -lt 5 ]; then
  ko "La collection 'posts' contient ${COUNT} document(s), attendu >= 5."
  EXIT_CODE=1
else
  ok "Base '${DB_NAME}' OK — ${COUNT} posts trouvés ✔"
fi

# --- Résultat final ---------------------------------------------------------
echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}  ✅  Tous les contrôles sont passés.   ${NC}"
  echo -e "${GREEN}========================================${NC}"
else
  echo -e "${RED}========================================${NC}"
  echo -e "${RED}  ❌  Un ou plusieurs contrôles ont échoué.${NC}"
  echo -e "${RED}========================================${NC}"
fi
exit $EXIT_CODE