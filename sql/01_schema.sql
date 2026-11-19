-- =====================================================================
--  Vite & Gourmand - Création de la base de données (MySQL 8 / MariaDB)
--  Fichier : sql/01_schema.sql
--  Basé sur le MCD fourni en annexe 1 de l'énoncé, avec quelques ajouts
--  justifiés (voir commentaires "AJOUT").
-- =====================================================================

DROP DATABASE IF EXISTS vite_gourmand;
CREATE DATABASE vite_gourmand CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE vite_gourmand;

-- ---------------------------------------------------------------------
-- Rôles : utilisateur, employe, administrateur
-- ---------------------------------------------------------------------
CREATE TABLE role (
    role_id  INT          NOT NULL AUTO_INCREMENT,
    libelle  VARCHAR(50)  NOT NULL UNIQUE,
    PRIMARY KEY (role_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Utilisateurs (clients, employés, administrateur)
-- utilisateur 1,1 ---possede--- 0,n role  => clé étrangère role_id
-- ---------------------------------------------------------------------
CREATE TABLE utilisateur (
    utilisateur_id  INT           NOT NULL AUTO_INCREMENT,
    email           VARCHAR(255)  NOT NULL UNIQUE,
    password        VARCHAR(255)  NOT NULL,           -- hash bcrypt (password_hash), jamais en clair
    nom             VARCHAR(50)   NOT NULL,           -- AJOUT : l'énoncé demande nom ET prénom
    prenom          VARCHAR(50)   NOT NULL,
    telephone       VARCHAR(20)   NOT NULL,
    ville           VARCHAR(50)   NOT NULL,
    code_postal     VARCHAR(10)   NOT NULL,           -- AJOUT : utile pour la livraison
    pays            VARCHAR(50)   NOT NULL DEFAULT 'France',
    adresse_postale VARCHAR(255)  NOT NULL,
    actif           BOOLEAN       NOT NULL DEFAULT TRUE, -- AJOUT : désactiver un compte employé (départ)
    date_creation   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    role_id         INT           NOT NULL,
    PRIMARY KEY (utilisateur_id),
    CONSTRAINT fk_utilisateur_role FOREIGN KEY (role_id) REFERENCES role(role_id)
) ENGINE=InnoDB;

-- AJOUT : réinitialisation du mot de passe (lien envoyé par mail)
-- On stocke le hash du jeton (pas le jeton lui-même) + une date d'expiration.
CREATE TABLE reinitialisation_mdp (
    reinitialisation_id INT          NOT NULL AUTO_INCREMENT,
    utilisateur_id      INT          NOT NULL,
    token_hash          CHAR(64)     NOT NULL,        -- SHA-256 du jeton
    date_expiration     DATETIME     NOT NULL,
    utilise             BOOLEAN      NOT NULL DEFAULT FALSE,
    PRIMARY KEY (reinitialisation_id),
    CONSTRAINT fk_reinit_utilisateur FOREIGN KEY (utilisateur_id)
        REFERENCES utilisateur(utilisateur_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Référentiels du menu
-- ---------------------------------------------------------------------
CREATE TABLE theme (
    theme_id INT          NOT NULL AUTO_INCREMENT,
    libelle  VARCHAR(50)  NOT NULL UNIQUE,
    PRIMARY KEY (theme_id)
) ENGINE=InnoDB;

CREATE TABLE regime (
    regime_id INT          NOT NULL AUTO_INCREMENT,
    libelle   VARCHAR(50)  NOT NULL UNIQUE,
    PRIMARY KEY (regime_id)
) ENGINE=InnoDB;

CREATE TABLE allergene (
    allergene_id INT          NOT NULL AUTO_INCREMENT,
    libelle      VARCHAR(50)  NOT NULL UNIQUE,
    PRIMARY KEY (allergene_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Menu
-- menu 1,1 ---propose--- 0,n theme   => clé étrangère theme_id
-- menu 1,1 ---adopte---  0,n regime  => clé étrangère regime_id
-- ---------------------------------------------------------------------
CREATE TABLE menu (
    menu_id                  INT            NOT NULL AUTO_INCREMENT,
    titre                    VARCHAR(100)   NOT NULL,
    description              TEXT           NOT NULL,
    nombre_personne_minimum  INT            NOT NULL CHECK (nombre_personne_minimum > 0),
    prix_par_personne        DECIMAL(8,2)   NOT NULL CHECK (prix_par_personne >= 0),
    conditions               TEXT           NOT NULL, -- délai de commande, stockage...
    quantite_restante        INT            NOT NULL DEFAULT 0 CHECK (quantite_restante >= 0),
    theme_id                 INT            NOT NULL,
    regime_id                INT            NOT NULL,
    PRIMARY KEY (menu_id),
    CONSTRAINT fk_menu_theme  FOREIGN KEY (theme_id)  REFERENCES theme(theme_id),
    CONSTRAINT fk_menu_regime FOREIGN KEY (regime_id) REFERENCES regime(regime_id)
) ENGINE=InnoDB;

-- AJOUT : galerie d'images d'un menu (l'énoncé parle d'une "galerie")
-- On stocke le chemin du fichier plutôt qu'un BLOB : base plus légère,
-- images servies directement par le serveur web et mises en cache.
CREATE TABLE menu_image (
    image_id    INT           NOT NULL AUTO_INCREMENT,
    menu_id     INT           NOT NULL,
    chemin      VARCHAR(255)  NOT NULL,
    texte_alt   VARCHAR(255)  NOT NULL,              -- obligatoire pour le RGAA
    ordre       INT           NOT NULL DEFAULT 0,
    PRIMARY KEY (image_id),
    CONSTRAINT fk_image_menu FOREIGN KEY (menu_id) REFERENCES menu(menu_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Plat (entrée, plat, dessert)
-- ---------------------------------------------------------------------
CREATE TABLE plat (
    plat_id     INT           NOT NULL AUTO_INCREMENT,
    titre_plat  VARCHAR(100)  NOT NULL,
    type_plat   VARCHAR(20)   NOT NULL,              -- AJOUT : 'entree', 'plat' ou 'dessert'
    photo       VARCHAR(255)  NULL,                       -- chemin au lieu du BLOB du MCD
    PRIMARY KEY (plat_id)
) ENGINE=InnoDB;

-- menu 0,n ---propose--- 0,n plat  => table d'association
-- (un même plat peut être présent dans plusieurs menus)
CREATE TABLE menu_plat (
    menu_id INT NOT NULL,
    plat_id INT NOT NULL,
    PRIMARY KEY (menu_id, plat_id),
    CONSTRAINT fk_mp_menu FOREIGN KEY (menu_id) REFERENCES menu(menu_id) ON DELETE CASCADE,
    CONSTRAINT fk_mp_plat FOREIGN KEY (plat_id) REFERENCES plat(plat_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- plat 0,n ---contient--- 0,n allergene  => table d'association
CREATE TABLE plat_allergene (
    plat_id      INT NOT NULL,
    allergene_id INT NOT NULL,
    PRIMARY KEY (plat_id, allergene_id),
    CONSTRAINT fk_pa_plat      FOREIGN KEY (plat_id)      REFERENCES plat(plat_id) ON DELETE CASCADE,
    CONSTRAINT fk_pa_allergene FOREIGN KEY (allergene_id) REFERENCES allergene(allergene_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Commande
-- commande 1,1 ---- 0,n utilisateur ; commande 1,1 ---- 0,n menu
-- ---------------------------------------------------------------------
CREATE TABLE commande (
    commande_id          INT            NOT NULL AUTO_INCREMENT,
    numero_commande      VARCHAR(50)    NOT NULL UNIQUE,
    date_commande        DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_prestation      DATE           NOT NULL,
    heure_livraison      TIME           NOT NULL,
    adresse_prestation   VARCHAR(255)   NOT NULL,     -- AJOUT : lieu de la prestation
    ville_prestation     VARCHAR(50)    NOT NULL,     -- AJOUT : sert au calcul de livraison
    distance_km          DECIMAL(6,2)   NOT NULL DEFAULT 0, -- AJOUT : km hors Bordeaux
    nombre_personne      INT            NOT NULL CHECK (nombre_personne > 0),
    prix_menu            DECIMAL(10,2)  NOT NULL,     -- prix figé au moment de la commande
    reduction            DECIMAL(10,2)  NOT NULL DEFAULT 0, -- AJOUT : remise de 10 %
    prix_livraison       DECIMAL(10,2)  NOT NULL DEFAULT 0,
    statut               VARCHAR(50)    NOT NULL DEFAULT 'en_attente', -- valeurs contrôlées en PHP
    pret_materiel        BOOLEAN        NOT NULL DEFAULT FALSE,
    restitution_materiel BOOLEAN        NOT NULL DEFAULT FALSE,
    motif_annulation     TEXT           NULL,         -- AJOUT : motif saisi par l'employé
    mode_contact         VARCHAR(10)    NULL,         -- AJOUT : 'gsm' ou 'mail'
    utilisateur_id       INT            NOT NULL,
    menu_id              INT            NOT NULL,
    PRIMARY KEY (commande_id),
    CONSTRAINT fk_commande_utilisateur FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(utilisateur_id),
    CONSTRAINT fk_commande_menu        FOREIGN KEY (menu_id)        REFERENCES menu(menu_id)
) ENGINE=InnoDB;

CREATE INDEX idx_commande_statut ON commande(statut);

-- AJOUT : suivi de commande (tous les états + date et heure de modification)
CREATE TABLE commande_suivi (
    suivi_id          INT          NOT NULL AUTO_INCREMENT,
    commande_id       INT          NOT NULL,
    statut            VARCHAR(50)  NOT NULL,
    date_modification DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (suivi_id),
    CONSTRAINT fk_suivi_commande FOREIGN KEY (commande_id) REFERENCES commande(commande_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Avis : utilisateur 1,1 ---publie--- 0,n avis
-- ---------------------------------------------------------------------
CREATE TABLE avis (
    avis_id         INT          NOT NULL AUTO_INCREMENT,
    note            TINYINT      NOT NULL CHECK (note BETWEEN 1 AND 5),
    description     TEXT         NOT NULL,
    statut          VARCHAR(50)  NOT NULL DEFAULT 'en_attente', -- en_attente, valide, refuse
    date_avis       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    utilisateur_id  INT          NOT NULL,
    commande_id     INT          NOT NULL UNIQUE,     -- AJOUT : un avis par commande terminée
    PRIMARY KEY (avis_id),
    CONSTRAINT fk_avis_utilisateur FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(utilisateur_id),
    CONSTRAINT fk_avis_commande    FOREIGN KEY (commande_id)    REFERENCES commande(commande_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Horaires (affichés dans le pied de page, du lundi au dimanche)
-- ---------------------------------------------------------------------
CREATE TABLE horaire (
    horaire_id       INT          NOT NULL AUTO_INCREMENT,
    jour             VARCHAR(20)  NOT NULL UNIQUE,
    heure_ouverture  TIME         NULL,               -- NULL = fermé
    heure_fermeture  TIME         NULL,
    PRIMARY KEY (horaire_id)
) ENGINE=InnoDB;
