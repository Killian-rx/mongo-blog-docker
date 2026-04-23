db = db.getSiblingDB("blog_db");

db.createCollection("posts", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["titre", "auteur", "vues"],
      additionalProperties: false,
      properties: {
        _id: { bsonType: "objectId" },
        titre: { bsonType: "string", minLength: 1, maxLength: 200 },
        auteur: { bsonType: "string", minLength: 1, maxLength: 100 },
        vues: { bsonType: "int", minimum: 0 }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

db.posts.insertMany([
  { titre: "Premiers pas avec Docker", auteur: "Kiks", vues: NumberInt(1540) },
  { titre: "MongoDB et la validation de schema", auteur: "Alice", vues: NumberInt(872) },
  { titre: "Pourquoi ne jamais tourner en root", auteur: "Bob", vues: NumberInt(2301) },
  { titre: "React + Vite : un combo gagnant", auteur: "Kiks", vues: NumberInt(4120) },
  { titre: "Introduction au NoSQL", auteur: "Charlie", vues: NumberInt(655) }
]);
