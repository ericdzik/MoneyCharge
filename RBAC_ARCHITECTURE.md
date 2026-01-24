# Architecture RBAC - MoneyCharge

## 🎯 Vue d'Ensemble

Ce document décrit l'architecture du système de contrôle d'accès basé sur les rôles (RBAC) implémenté dans l'application MoneyCharge.

### Principe Fondamental

**Le rôle Merchant hérite automatiquement de toutes les fonctionnalités et permissions du rôle User.**

Cela signifie :
- Un Merchant **EST UN** User avec des capacités supplémentaires
- Aucune duplication de code n'est nécessaire
- Les écrans User sont réutilisés tels quels par les Merchants

---

## 🏗️ Architecture en Couches

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ User Screens │  │Merchant Screens│ │Admin Screens │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   Access Control Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │PermissionGuard│ │AccessControl │ │RoleAwareNav  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   Permission Layer                           │
│  ┌──────────────────────────────────────────────────┐       │
│  │           PermissionProvider                      │       │
│  │  - Expose les permissions de l'utilisateur actuel│       │
│  │  - Se met à jour automatiquement avec AuthProvider│      │
│  └──────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic Layer                      │
│  ┌──────────────────────────────────────────────────┐       │
│  │              RoleManager                          │       │
│  │  - Définit les permissions par rôle               │       │
│  │  - Implémente la logique d'héritage               │       │
│  │  - Support pour permissions dynamiques backend    │       │
│  └──────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  ┌──────────────────────────────────────────────────┐       │
│  │           AppPermission (Enum)                    │       │
│  │  - Définit toutes les permissions disponibles     │       │
│  └──────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Composants Clés

### 1. **AppPermission** (Enum)
**Fichier:** `lib/core/security/rbac_constants.dart`

Définit toutes les permissions disponibles dans l'application.

```dart
enum AppPermission {
  // User permissions
  viewHome,
  viewUserProfile,
  editUserProfile,
  viewMarketplace,
  viewFavorites,
  
  // Merchant permissions
  accessMerchantDashboard,
  manageStock,
  createInvoice,
  viewSalesByType,
  manageBusinessProfile,
  respondToReviews,
  
  // Admin permissions
  accessAdminDashboard,
  manageUsers,
  approveMerchants,
  manageSystemAds,
  viewSystemAnalytics,
}
```

**Principe:** Utiliser des permissions granulaires plutôt que des rôles hard-codés.

---

### 2. **RoleManager**
**Fichier:** `lib/core/security/role_manager.dart`

Cerveau du système RBAC. Définit quelles permissions chaque rôle possède.

**Logique d'héritage:**
```dart
Set<AppPermission> getPermissionsForRole(UserType role) {
  final permissions = <AppPermission>{};
  
  if (role == UserType.merchant) {
    // Merchant hérite de User
    permissions.addAll(_roleDefinitions[UserType.user] ?? {});
    // Plus ses permissions spécifiques
    permissions.addAll(_roleDefinitions[UserType.merchant] ?? {});
  } else {
    // Autres rôles
    permissions.addAll(_roleDefinitions[role] ?? {});
  }
  
  return permissions;
}
```

**Avantages:**
- Logique d'héritage centralisée
- Facile à étendre pour de nouveaux rôles
- Support pour permissions dynamiques du backend

---

### 3. **PermissionProvider**
**Fichier:** `lib/core/security/permission_provider.dart`

Provider qui expose les permissions de l'utilisateur actuel.

**Caractéristiques:**
- Se met à jour automatiquement quand l'utilisateur change
- Utilise `ChangeNotifierProxyProvider` pour écouter `AuthProvider`
- Fournit des méthodes de vérification de permissions

**API:**
```dart
// Vérifier une permission
bool hasPermission(AppPermission permission)

// Vérifier plusieurs permissions (AND)
bool hasAllPermissions(List<AppPermission> permissions)

// Vérifier plusieurs permissions (OR)
bool hasAnyPermission(List<AppPermission> permissions)
```

---

### 4. **PermissionGuard**
**Fichier:** `lib/core/security/permission_guard.dart`

Protège les routes en vérifiant les permissions.

**Utilisation:**
```dart
case AppRoutes.merchantDashboard:
  return MaterialPageRoute(
    builder: (context) => PermissionGuard.check(
      context: context,
      permission: AppPermission.accessMerchantDashboard,
      child: const MerchantDashboardScreen(),
    ),
  );
```

**Comportement:**
- Vérifie la permission avant d'afficher l'écran
- Redirige vers login si non autorisé
- Affiche un message d'erreur clair

---

### 5. **AccessControl** (Widget)
**Fichier:** `lib/core/security/access_control_widget.dart`

Widget pour contrôle d'accès conditionnel dans l'UI.

**Utilisation:**
```dart
AccessControl(
  permission: AppPermission.manageStock,
  child: StockManagementButton(),
  fallback: SizedBox.shrink(), // Optionnel
)
```

**Avantages:**
- Déclaratif et facile à lire
- Réagit automatiquement aux changements de permissions
- Évite les conditions if/else dans le code UI

---

### 6. **RoleAwareNavigation**
**Fichier:** `lib/core/widgets/role_aware_navigation.dart`

Système de navigation intelligent qui vérifie les permissions.

**Utilisation:**
```dart
// Méthode 1: Via la classe
RoleAwareNavigation.navigateTo(
  context: context,
  routeName: AppRoutes.merchantDashboard,
  requiredPermission: AppPermission.accessMerchantDashboard,
);

// Méthode 2: Via l'extension
context.navigateToWithPermission(
  routeName: AppRoutes.merchantDashboard,
  requiredPermission: AppPermission.accessMerchantDashboard,
);
```

---

### 7. **NavigationConfig**
**Fichier:** `lib/core/security/navigation_config.dart`

Configuration centralisée de la navigation.

**Avantages:**
- Mapping clair routes → permissions
- Facile de voir quelles routes nécessitent quelles permissions
- Point unique de vérité pour la configuration

---

### 8. **AdaptiveNavigation**
**Fichier:** `lib/core/widgets/adaptive_navigation.dart`

Barre de navigation qui s'adapte automatiquement aux permissions.

**Fonctionnement:**
- Génère les items de navigation en fonction des permissions
- Les Merchants voient les items User (grâce à l'héritage)
- Pas de duplication de code

---

## 🔄 Flux de Données

### 1. Connexion de l'Utilisateur

```
User Login
    ↓
AuthProvider.loginUnified()
    ↓
Firebase Auth
    ↓
AuthProvider._fetchUserProfile()
    ↓
AuthProvider.userType = UserType.merchant
    ↓
PermissionProvider.update() (via ProxyProvider)
    ↓
RoleManager.getPermissionsForRole(UserType.merchant)
    ↓
PermissionProvider._currentPermissions = {
  viewHome,           // Hérité de User
  viewMarketplace,    // Hérité de User
  viewFavorites,      // Hérité de User
  accessMerchantDashboard,  // Spécifique Merchant
  manageStock,        // Spécifique Merchant
  ...
}
    ↓
UI se reconstruit avec les nouvelles permissions
```

### 2. Navigation vers un Écran

```
User taps "Dashboard Marchand"
    ↓
Navigator.pushNamed(AppRoutes.merchantDashboard)
    ↓
app.dart._generateRoute()
    ↓
PermissionGuard.check(
  permission: AppPermission.accessMerchantDashboard
)
    ↓
PermissionProvider.hasPermission(AppPermission.accessMerchantDashboard)
    ↓
Vérification: permission in _currentPermissions?
    ↓
✅ OUI → Afficher MerchantDashboardScreen
❌ NON → Rediriger vers login + message d'erreur
```

### 3. Affichage Conditionnel dans l'UI

```
Widget build() {
  return AccessControl(
    permission: AppPermission.manageStock,
    child: StockButton(),
  );
}
    ↓
Consumer<PermissionProvider>
    ↓
permissionProvider.hasPermission(AppPermission.manageStock)
    ↓
✅ OUI → Afficher StockButton
❌ NON → Afficher fallback (ou rien)
```

---

## 🎯 Héritage des Permissions

### Configuration Actuelle

```dart
// Dans RoleManager
if (role == UserType.merchant) {
  // Merchant hérite de User
  permissions.addAll(_roleDefinitions[UserType.user] ?? {});
  permissions.addAll(_roleDefinitions[UserType.merchant] ?? {});
}
```

### Résultat pour un Merchant

**Permissions héritées de User:**
- ✅ viewHome
- ✅ viewUserProfile
- ✅ editUserProfile
- ✅ viewMarketplace
- ✅ viewFavorites

**Permissions spécifiques Merchant:**
- ✅ accessMerchantDashboard
- ✅ manageStock
- ✅ createInvoice
- ✅ viewSalesByType
- ✅ manageBusinessProfile
- ✅ respondToReviews

**Total:** Un Merchant a 11 permissions (5 héritées + 6 spécifiques)

---

## 🚀 Extensibilité

### Ajouter une Nouvelle Permission

1. **Ajouter à l'enum:**
```dart
// rbac_constants.dart
enum AppPermission {
  // ...
  exportData, // NOUVELLE
}
```

2. **Assigner au rôle:**
```dart
// role_manager.dart
UserType.merchant: {
  // ...
  AppPermission.exportData, // NOUVELLE
}
```

3. **Utiliser dans l'UI:**
```dart
AccessControl(
  permission: AppPermission.exportData,
  child: ExportButton(),
)
```

### Ajouter un Nouveau Rôle

1. **Ajouter à l'enum UserType:**
```dart
// auth_provider.dart
enum UserType { user, merchant, admin, superAdmin } // NOUVEAU
```

2. **Définir les permissions:**
```dart
// role_manager.dart
UserType.superAdmin: {
  // Définir les permissions
}
```

3. **Implémenter l'héritage si nécessaire:**
```dart
if (role == UserType.superAdmin) {
  permissions.addAll(_roleDefinitions[UserType.admin] ?? {});
  permissions.addAll(_roleDefinitions[UserType.superAdmin] ?? {});
}
```

### Permissions Dynamiques du Backend

Le système est préparé pour recevoir des permissions du backend :

```dart
Set<AppPermission> getPermissionsForRole(
  UserType role, {
  List<String>? backendOverrides, // Support pour backend
}) {
  // ...
  if (backendOverrides != null) {
    for (final permissionName in backendOverrides) {
      final permission = _parsePermission(permissionName);
      if (permission != null) {
        permissions.add(permission);
      }
    }
  }
  return permissions;
}
```

---

## 📊 Avantages de cette Architecture

### 1. **Pas de Duplication de Code**
- Les écrans User sont utilisés tels quels par les Merchants
- Un seul endroit pour maintenir la logique User

### 2. **Scalabilité**
- Facile d'ajouter de nouveaux rôles
- Facile d'ajouter de nouvelles permissions
- Support pour permissions dynamiques

### 3. **Maintenabilité**
- Logique centralisée dans RoleManager
- Configuration claire dans NavigationConfig
- Séparation des responsabilités

### 4. **Sécurité**
- Vérifications à plusieurs niveaux (routes + UI)
- Impossible d'accéder à une fonctionnalité sans permission
- Messages d'erreur clairs

### 5. **Testabilité**
- Logique isolée et testable
- Facile de mocker les permissions pour les tests
- Tests unitaires possibles pour chaque composant

---

## 🔒 Sécurité

### Niveaux de Protection

1. **Route Level:** `PermissionGuard` dans `app.dart`
2. **UI Level:** `AccessControl` dans les widgets
3. **Navigation Level:** `RoleAwareNavigation` pour la navigation programmatique

### Principe de Défense en Profondeur

Même si un utilisateur contourne une protection, les autres niveaux le bloquent.

**Exemple:**
```
User essaie d'accéder à /merchant/dashboard
    ↓
1. PermissionGuard vérifie → ❌ Bloqué
    ↓
Si contourné (impossible normalement)
    ↓
2. AccessControl dans l'UI → ❌ Widgets cachés
    ↓
Si contourné
    ↓
3. Backend vérifie les permissions → ❌ API refuse
```

---

## 📝 Best Practices

### 1. Toujours Utiliser des Permissions, Jamais des Rôles

❌ **Mauvais:**
```dart
if (userType == UserType.merchant) {
  // Afficher le bouton
}
```

✅ **Bon:**
```dart
AccessControl(
  permission: AppPermission.manageStock,
  child: StockButton(),
)
```

### 2. Centraliser la Configuration

Toute la configuration des permissions doit être dans `RoleManager` et `NavigationConfig`.

### 3. Utiliser AccessControl pour l'UI Conditionnelle

Plutôt que des `if/else`, utiliser `AccessControl` pour un code plus déclaratif.

### 4. Documenter les Permissions

Chaque permission doit avoir un commentaire clair expliquant ce qu'elle permet.

---

## 🧪 Tests

Voir `RBAC_TEST_GUIDE.md` pour le guide de test complet.

**Tests essentiels:**
1. Test d'héritage des permissions
2. Test de navigation avec permissions
3. Test d'affichage conditionnel
4. Test de sécurité (tentatives d'accès non autorisé)

---

## 📚 Références

- **Fichiers principaux:**
  - `lib/core/security/rbac_constants.dart`
  - `lib/core/security/role_manager.dart`
  - `lib/core/security/permission_provider.dart`
  - `lib/core/security/permission_guard.dart`
  - `lib/core/security/access_control_widget.dart`
  - `lib/core/security/navigation_config.dart`
  - `lib/core/widgets/role_aware_navigation.dart`
  - `lib/core/widgets/adaptive_navigation.dart`

- **Documentation:**
  - `TODO_RBAC.md` - Plan d'intégration
  - `RBAC_TEST_GUIDE.md` - Guide de test
  - `RBAC_ARCHITECTURE.md` - Ce document

---

## 🎓 Conclusion

Cette architecture RBAC fournit :
- ✅ Héritage propre des permissions (Merchant → User)
- ✅ Aucune duplication de code
- ✅ Sécurité multi-niveaux
- ✅ Extensibilité pour de futurs besoins
- ✅ Code maintenable et testable

Le principe clé est : **Utiliser des permissions granulaires plutôt que des rôles hard-codés**, permettant une flexibilité maximale et une maintenance simplifiée.
