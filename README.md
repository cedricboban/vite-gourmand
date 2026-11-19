# Vite & Gourmand

Application web de commande de menus traiteur pour l'entreprise bordelaise **Vite & Gourmand** (ECF – Titre professionnel Développeur Web et Web Mobile).

## Stack technique

| Couche | Technologie |
|---|---|
| Front-end | HTML 5, CSS (Bootstrap 5), JavaScript (fetch pour les filtres dynamiques) |
| Back-end | PHP 8 natif, PDO (requêtes préparées) |
| Base relationnelle | MySQL 8 / MariaDB |
| Base NoSQL | MongoDB (statistiques de commandes pour l'espace administrateur) |
| Envoi de mails | PHPMailer (SMTP) |

## Installation en local

### Prérequis
- PHP ≥ 8.1 avec les extensions `pdo_mysql` et `mongodb`
- MySQL 8 ou MariaDB 10.6+
- MongoDB 6+
- Composer
- Git

### Étapes

```bash
# 1. Cloner le dépôt
git clone https://github.com/<votre-compte>/vite-gourmand.git
cd vite-gourmand

# 2. Créer la base de données et insérer les données de démonstration
mysql -u root -p < sql/01_schema.sql
mysql -u root -p < sql/02_data.sql

# 3. Configurer les variables d'environnement
cp .env.example .env    # puis renseigner les accès BDD / SMTP / MongoDB

# 4. Installer les dépendances PHP
composer install

# 5. Lancer le serveur de développement
php -S localhost:8000 -t public
```

L'application est alors disponible sur http://localhost:8000.

## Comptes de démonstration

| Rôle | Email | Mot de passe |
|---|---|---|
| Administrateur | jose@vitegourmand.fr | Admin#Vg2026! |
| Employée | julie@vitegourmand.fr | Employe#Vg2026! |
| Utilisateur | client@exemple.fr | Client#Vg2026! |

## Organisation Git

- `main` : branche principale, version déployée
- `develop` : branche de développement
- `feature/<nom>` : une branche par fonctionnalité, créée depuis `develop`, fusionnée dans `develop` après test

## Structure du projet

```
vite-gourmand/
├── sql/            # Scripts de création et de peuplement de la base
├── docs/           # Manuel d'utilisation, charte graphique, docs techniques (PDF)
├── public/         # Point d'entrée web (index.php, assets)
└── src/            # Code PHP (contrôleurs, modèles, services)
```
