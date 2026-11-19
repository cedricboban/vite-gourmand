-- =====================================================================
--  Vite & Gourmand - Jeu de données de démonstration
--  Fichier : sql/02_data.sql  (à exécuter après 01_schema.sql)
--
--  Comptes de test (mots de passe hachés avec password_hash / bcrypt) :
--    Administrateur : jose@vitegourmand.fr     / Admin#Vg2026!
--    Employée       : julie@vitegourmand.fr    / Employe#Vg2026!
--    Utilisateur    : client@exemple.fr        / Client#Vg2026!
--  Le compte administrateur n'est créé QUE par ce script : il n'existe
--  aucun moyen d'en créer un depuis l'application (exigence de José).
-- =====================================================================
USE vite_gourmand;

INSERT INTO role (role_id, libelle) VALUES
 (1, 'utilisateur'), (2, 'employe'), (3, 'administrateur');

INSERT INTO utilisateur (email, password, nom, prenom, telephone, ville, code_postal, pays, adresse_postale, role_id) VALUES
 ('jose@vitegourmand.fr',  '$2y$10$Kf0r4mkftfgv20D2tpb0C.YCR5LcQOhF7nO9RZBm1Zxxz8caMtDwC', 'Martin',  'José',   '0600000001', 'Bordeaux', '33000', 'France', '12 rue Sainte-Catherine', 3),
 ('julie@vitegourmand.fr', '$2y$10$64Ops3qp09eooaRZoEwR9OPG/GP5zNQ1FYFzMKCDNUU/9qgDac3EO', 'Durand',  'Julie',  '0600000002', 'Bordeaux', '33000', 'France', '12 rue Sainte-Catherine', 2),
 ('client@exemple.fr',     '$2y$10$..Qwgylh9GgSKh86ubI9.OZjiT11jkJpSBm/raPaKBN8/WxY091jy', 'Lefèvre', 'Thomas', '0611223344', 'Mérignac', '33700', 'France', '5 avenue de la Marne',   1);

INSERT INTO theme (libelle) VALUES ('Noël'), ('Pâques'), ('Classique'), ('Évènement');
INSERT INTO regime (libelle) VALUES ('Classique'), ('Végétarien'), ('Vegan'), ('Sans gluten');
INSERT INTO allergene (libelle) VALUES
 ('Gluten'), ('Lait'), ('Œufs'), ('Fruits à coque'), ('Poisson'), ('Crustacés'), ('Céleri'), ('Moutarde'), ('Soja'), ('Sésame');

INSERT INTO menu (titre, description, nombre_personne_minimum, prix_par_personne, conditions, quantite_restante, theme_id, regime_id) VALUES
 ('Réveillon de Noël', 'Un menu festif et généreux pour célébrer Noël en famille : produits du terroir bordelais et douceurs de saison.',
   6, 42.00, 'À commander au minimum 2 semaines avant la prestation. Conserver au réfrigérateur entre 0 et 4 °C et consommer sous 24 h.', 10, 1, 1),
 ('Pâques gourmand', 'Agneau de sept heures, légumes printaniers et chocolat : le menu idéal pour le déjeuner de Pâques.',
   4, 35.00, 'À commander au minimum 7 jours avant la prestation. Réchauffer au four 20 min à 160 °C.', 8, 2, 1),
 ('Classique bordelais', 'Les incontournables de la maison, servis depuis 25 ans à nos fidèles clients.',
   2, 28.00, 'À commander au minimum 3 jours avant la prestation.', 20, 3, 1),
 ('Végétal & festif', 'Un menu 100 % végétal, coloré et de saison, pour tous vos évènements.',
   8, 30.00, 'À commander au minimum 5 jours avant la prestation. Conserver au frais.', 5, 4, 3),
 ('Buffet évènement végétarien', 'Un buffet convivial pour vos anniversaires, mariages ou séminaires. Du matériel (plats, chafing-dish) peut être prêté.',
   15, 25.00, 'À commander au minimum 3 semaines avant la prestation. Matériel prêté à restituer sous 10 jours ouvrés (600 € de frais sinon, voir CGV).', 3, 4, 2);

INSERT INTO menu_image (menu_id, chemin, texte_alt, ordre) VALUES
 (1, 'assets/img/menus/noel-1.jpg',      'Table de Noël dressée avec foie gras et chapon', 1),
 (1, 'assets/img/menus/noel-2.jpg',      'Bûche de Noël au chocolat', 2),
 (2, 'assets/img/menus/paques-1.jpg',    'Gigot d''agneau et légumes de printemps', 1),
 (3, 'assets/img/menus/classique-1.jpg', 'Entrecôte à la bordelaise et ses frites', 1),
 (4, 'assets/img/menus/vegan-1.jpg',     'Assiette végétale colorée', 1),
 (5, 'assets/img/menus/buffet-1.jpg',    'Buffet froid végétarien dressé', 1);

INSERT INTO plat (titre_plat, type_plat, photo) VALUES
 ('Foie gras maison et chutney de figues', 'entree',  NULL),  -- 1
 ('Velouté de potimarron',                 'entree',  NULL),  -- 2
 ('Salade de lentilles et légumes croquants','entree', NULL), -- 3
 ('Chapon farci aux marrons',              'plat',    NULL),  -- 4
 ('Agneau de sept heures',                 'plat',    NULL),  -- 5
 ('Entrecôte à la bordelaise',             'plat',    NULL),  -- 6
 ('Curry de légumes au lait de coco',      'plat',    NULL),  -- 7
 ('Quiches et cakes salés aux légumes',    'plat',    NULL),  -- 8
 ('Bûche chocolat praliné',                'dessert', NULL),  -- 9
 ('Nid de Pâques au chocolat',             'dessert', NULL),  -- 10
 ('Cannelés bordelais',                    'dessert', NULL),  -- 11
 ('Salade de fruits frais',                'dessert', NULL);  -- 12

-- Un même plat peut apparaître dans plusieurs menus (ex. velouté, cannelés)
INSERT INTO menu_plat (menu_id, plat_id) VALUES
 (1,1),(1,2),(1,4),(1,9),
 (2,2),(2,5),(2,10),
 (3,1),(3,6),(3,11),
 (4,3),(4,7),(4,12),
 (5,2),(5,3),(5,8),(5,11),(5,12);

-- allergenes : 1 Gluten, 2 Lait, 3 Œufs, 4 Fruits à coque, 7 Céleri
INSERT INTO plat_allergene (plat_id, allergene_id) VALUES
 (1,1),(2,2),(2,7),(4,1),(4,4),(6,2),(8,1),(8,2),(8,3),(9,1),(9,2),(9,3),(9,4),(10,2),(11,1),(11,2),(11,3);

INSERT INTO horaire (jour, heure_ouverture, heure_fermeture) VALUES
 ('Lundi',    '09:00', '18:00'),
 ('Mardi',    '09:00', '18:00'),
 ('Mercredi', '09:00', '18:00'),
 ('Jeudi',    '09:00', '18:00'),
 ('Vendredi', '09:00', '20:00'),
 ('Samedi',   '10:00', '20:00'),
 ('Dimanche', NULL,    NULL);

-- Une commande terminée avec avis validé, pour alimenter la page d'accueil
INSERT INTO commande (numero_commande, date_commande, date_prestation, heure_livraison, adresse_prestation, ville_prestation,
                      distance_km, nombre_personne, prix_menu, reduction, prix_livraison, statut, utilisateur_id, menu_id)
VALUES ('VG-20261001-0001', '2026-10-01 10:12:00', '2026-10-10', '12:00:00', '5 avenue de la Marne', 'Mérignac',
        8.00, 4, 112.00, 0.00, 9.72, 'terminee', 3, 3);
-- prix livraison hors Bordeaux : 5 € + 0,59 € x 8 km = 9,72 €

INSERT INTO commande_suivi (commande_id, statut, date_modification) VALUES
 (1, 'en_attente',         '2026-10-01 10:12:00'),
 (1, 'accepte',            '2026-10-01 14:30:00'),
 (1, 'en_preparation',     '2026-10-10 08:00:00'),
 (1, 'en_cours_livraison', '2026-10-10 11:20:00'),
 (1, 'livre',              '2026-10-10 11:55:00'),
 (1, 'terminee',           '2026-10-10 12:00:00');

INSERT INTO avis (note, description, statut, utilisateur_id, commande_id) VALUES
 (5, 'Entrecôte parfaite et livraison à l''heure, merci Julie et José !', 'valide', 3, 1);
