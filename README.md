# LocaCharge

Application de location de chargeurs de téléphone avec interface unifiée.

## 🚀 Fonctionnalités

### Interface de Connexion Unifiée
- **Une seule page de connexion** pour tous les types d'utilisateurs
- **Détection automatique du rôle** basée sur l'email
- **Redirection intelligente** vers l'interface appropriée

### Types d'Utilisateurs

#### 👤 Utilisateur Standard
- **Email** : `user@example.com` ou tout email standard
- **Interface** : Recherche et location de chargeurs
- **Fonctionnalités** : Carte, liste, historique, profil

#### 🏪 Marchand
- **Email** : `boutique@example.com`, `merchant@example.com`, `shop@example.com`
- **Interface** : Dashboard marchand
- **Fonctionnalités** : Gestion des points de service, stock, analytics

#### ⚙️ Administrateur
- **Email** : `admin@locacharge.com`, `administrator@example.com`
- **Interface** : Dashboard administrateur
- **Fonctionnalités** : Gestion des utilisateurs, marchands, analytics

## 🛠️ Installation

```bash
# Cloner le projet
git clone [url-du-projet]

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

### Boutons de Test Rapide
L'interface de connexion inclut des boutons pour changer rapidement entre les différents types d'utilisateurs.

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
- **Connexion unifiée** : Une seule méthode pour tous les types
- **Détection automatique** : Rôle déterminé par l'email
- **Route Guards** : Protection des routes selon le rôle
- **Persistance** : État d'authentification sauvegardé

## 🎨 Design System

### Couleurs Panafricaines
- **Primaire** : Rouge (#DC2626)
- **Secondaire** : Jaune (#FBBF24)
- **Succès** : Vert (#10B981)

### Composants Réutilisables
- `CustomButton`
- `CustomTextField`
- `CustomAppBar`
- `RouteGuards`

## 📱 Fonctionnalités par Interface

### Interface Utilisateur
- Carte interactive des points de service
- Liste des marchands avec filtres
- Historique des locations
- Profil utilisateur

### Interface Marchand
- Dashboard avec statistiques
- Gestion du stock de chargeurs
- Analytics des ventes
- Profil marchand

### Interface Administrateur
- Dashboard global de la plateforme
- Gestion des utilisateurs et marchands
- Analytics détaillées
- Paramètres système

## 🔧 Configuration

### Variables d'Environnement
```dart
// Dans lib/services/api_service.dart
static const String baseUrl = 'https://api.locacharge.com/v1';
```

### Gestion des Rôles
Le rôle de chaque utilisateur (`user`, `merchant`, `admin`) est stocké de manière sécurisée dans un champ `role` au sein de son document utilisateur dans la base de données Firestore.

Lors de la connexion, l'application récupère ce rôle depuis Firestore pour déterminer l'interface à afficher. Cette approche garantit que les rôles sont gérés côté serveur et ne peuvent pas être usurpés par le client.

```dart
// Exemple de la structure de données dans Firestore (collection 'users')
{
  "uid": "...",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "user", // "user", "merchant", ou "admin"
  "createdAt": "..."
}
```

## 🚨 Notes Importantes

### Production
- Retirer les boutons de test rapide
- Vérifier et renforcer les règles de sécurité Firestore
- Configurer les variables d'environnement
- Ajouter des tests unitaires

### Sécurité
- Chiffrer les données sensibles
- Implémenter JWT
- Ajouter la validation côté serveur
- Gérer les sessions de manière sécurisée

## 📄 Licence

© 2024 LocaCharge - Tous droits réservés
