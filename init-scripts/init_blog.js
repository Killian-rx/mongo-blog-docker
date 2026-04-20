// ============================================================================
// init-blog.js
// Script d'initialisation exécuté automatiquement au PREMIER démarrage
// du conteneur (via /docker-entrypoint-initdb.d/).
// Il s'exécute sur la base définie par MONGO_INITDB_DATABASE (blog_db).
// ============================================================================

// On bascule explicitement sur la base blog_db (sécurité)
db = db.getSiblingDB('blog_db');

print('==> Création de la collection "posts" avec JSON Schema Validator...');

// ----------------------------------------------------------------------------
// 1. Création de la collection "posts" avec validation de schéma stricte
// ----------------------------------------------------------------------------
db.createCollection('posts', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['titre', 'auteur', 'vues'],
      additionalProperties: false,
      properties: {
        _id: {
          // Mongo ajoute automatiquement un _id, on l'autorise
          bsonType: 'objectId'
        },
        titre: {
          bsonType: 'string',
          minLength: 1,
          maxLength: 200,
          description: 'titre — doit être une chaîne de 1 à 200 caractères (obligatoire)'
        },
        auteur: {
          bsonType: 'string',
          minLength: 1,
          maxLength: 100,
          description: 'auteur — doit être une chaîne de 1 à 100 caractères (obligatoire)'
        },
        vues: {
          bsonType: 'int',
          minimum: 0,
          description: 'vues — doit être un entier >= 0 (obligatoire)'
        }
      }
    }
  },
  // validationLevel strict : applique la validation à TOUTES les insertions ET mises à jour
  validationLevel: 'strict',
  // validationAction error : rejette (ne se contente pas d'un warning)
  validationAction: 'error'
});

print('==> Insertion de 5 articles de test...');

// ----------------------------------------------------------------------------
// 2. Insertion de 5 articles — NumberInt() garantit le type "int" (pas "double")
//    car par défaut, les nombres JS sont des doubles côté Mongo.
// ----------------------------------------------------------------------------
db.posts.insertMany([
  {
    titre: 'Premiers pas avec Docker',
    auteur: 'Kiks',
    vues: NumberInt(1540)
  },
  {
    titre: 'MongoDB et la validation de schéma',
    auteur: 'Alice',
    vues: NumberInt(872)
  },
  {
    titre: 'Pourquoi ne jamais tourner en root dans un conteneur',
    auteur: 'Bob',
    vues: NumberInt(2301)
  },
  {
    titre: 'React + Vite : un combo gagnant',
    auteur: 'Kiks',
    vues: NumberInt(4120)
  },
  {
    titre: 'Introduction au NoSQL',
    auteur: 'Charlie',
    vues: NumberInt(655)
  }
]);

print('==> Initialisation terminée avec succès.');
print('==> Nombre de documents insérés : ' + db.posts.countDocuments());