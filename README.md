# LocaCharge

Application de location de chargeurs de téléphone avec interface unifiée.

## 🚀 Fonctionnalités

### Interface de Connexion Unifiée
- **Une seule page de connexion** pour tous les types d'utilisateurs.
- **Détection du rôle** basée sur le profil utilisateur sécurisé.
- **Redirection intelligente** vers l'interface appropriée.

### Types d'Utilisateurs

#### 👤 Utilisateur Standard
- **Exemple d'Email** : `user@example.com`
- **Interface** : Recherche et location de chargeurs.
- **Fonctionnalités** : Carte, liste, historique, profil.

#### 🏪 Marchand
- **Exemple d'Email** : `marchand@example.com`
- **Interface** : Dashboard marchand.
- **Fonctionnalités** : Gestion des points de service, stock, analytics.

#### ⚙️ Administrateur
- **Exemple d'Email** : `admin@example.com`
- **Interface** : Dashboard administrateur.
- **Fonctionnalités** : Gestion des utilisateurs, marchands, analytics.

## 🛠️ Installation

```bash
# Cloner le projet
git clone [url-du-projet]

# Créer le fichier de configuration local
cp .env.example .env

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

## 🧪 Test de Connexion

### Identifiants de Test
- **Utilisateur** : `user@example.com` / `password123`
- **Marchand** : `boutique@example.com` / `password123`
- **Admin** : `admin@locacharge.com` / `password123`
*(Note: Ces utilisateurs doivent être créés dans votre base de données Firebase.)*

## 🏗️ Architecture

### Structure des Dossiers
```
lib/
├── core/           # Composants de base
├── features/       # Fonctionnalités par domaine
│   ├── user/       # Interface utilisateur
│   ├── merchant/   # Interface marchand
│   └── admin/      # Interface administrateur
├── providers/      # Gestion d'état
└── services/       # Services métier
```

### Système d'Authentification
- **Connexion unifiée** : Une seule méthode pour tous les types.
- **Détection du rôle** : Rôle stocké de manière sécurisée dans le profil utilisateur (Firestore).
- **Route Guards** : Protection des routes selon le rôle.
- **Persistance** : État d'authentification sauvegardé via Firebase.

## 🔧 Configuration

### Variables d'Environnement
La configuration de l'application, comme l'URL de l'API, est gérée via un fichier `.env`.

1.  Copiez le fichier `.env.example` et renommez-le en `.env`.
2.  Modifiez les valeurs dans `.env` pour votre environnement.

```
# .env
BASE_URL=https://api.locacharge.com/v1
```

Le fichier `lib/services/api_service.dart` charge cette variable au démarrage.

## 🚨 Notes Importantes

### Production
- **Sécurité** : Les règles de sécurité de Firestore et Storage (`firestore.rules`, `storage.rules`) ont été ajoutées pour protéger les données. Assurez-vous de les déployer sur votre projet Firebase.
- **Tests** : Des tests unitaires pour le `AuthProvider` ont été ajoutés. La couverture des tests peut encore être améliorée.

### Sécurité
- **Rôles** : Les rôles des utilisateurs sont protégés contre la modification par les utilisateurs eux-mêmes grâce aux règles Firestore.
- **JWT** : L'authentification Firebase gère automatiquement les jetons JWT.
- **Validation Côté Serveur** : Les règles Firestore fournissent une validation robuste côté serveur pour les accès à la base de données.

## 📄 Licence

© 2024 LocaCharge - Tous droits réservés
