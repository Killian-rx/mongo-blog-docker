-- ============================================================================
-- 01_init_utilisateurs.sql
-- Script de migration exécuté automatiquement au PREMIER démarrage
-- du conteneur MySQL (via /docker-entrypoint-initdb.d/).
-- La table utilisateur est déjà créée par l'image de base.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS blog_db;
USE blog_db;

CREATE TABLE IF NOT EXISTS utilisateurs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nom VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  role ENUM('admin', 'auteur', 'lecteur') NOT NULL DEFAULT 'lecteur',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- INSERT IGNORE évite les erreurs si les lignes existent déjà (clé UNIQUE sur email)
INSERT IGNORE INTO utilisateurs (nom, email, role) VALUES
  ('Kiks',    'kiks@blog.dev',    'admin'),
  ('Alice',   'alice@blog.dev',   'auteur'),
  ('Bob',     'bob@blog.dev',     'auteur'),
  ('Charlie', 'charlie@blog.dev', 'lecteur');

SELECT CONCAT('==> Utilisateurs insérés : ', COUNT(*)) AS info FROM utilisateurs;
