# Fonctionnalité de Suppression de Compte - README Développeur

## 📦 Vue d'ensemble

Cette fonctionnalité permet aux utilisateurs de supprimer définitivement leur compte de l'application LocaCharge, conformément aux exigences du RGPD.

## 🏗️ Architecture

```
lib/features/auth/
├── services/
│   └── account_deletion_service.dart    # Service de suppression
├── widgets/
│   └── delete_account_dialog.dart       # Dialog de confirmation
└── providers/
    └── auth_provider.dart               # Méthode deleteAccount() ajoutée

lib/features/profile/
└── unified_profile_screen.dart          # Bouton de suppression ajouté

test/features/auth/services/
└── account_deletion_service_test.dart   # Tests unitaires
```

## 🔧 Composants principaux

### 1. AccountDeletionService

Service responsable de la suppression complète des données.

**Méthodes publiques :**
```dart
Future<bool> deleteAccount(String userId, String userRole)
Future<bool> canDeleteAccount(String userId, String userRole)
```

**Responsabilités :**
- Suppression des données Firestore
- Suppression des images Storage
- Suppression du compte Firebase Auth
- Vérification des conditions métier

### 2. DeleteAccountDialog

Widget de confirmation avec double vérification.

**Caractéristiques :**
- Champ de saisie pour taper "SUPPRIMER"
- Liste des conséquences
- Boutons Annuler/Confirmer
- Design avec zone d'avertissement

### 3. AuthProvider.deleteAccount()

Méthode orchestrant la suppression depuis le provider.

**Signature :**
```dart
Future<bool> deleteAccount()
```

**Retour :**
- `true` si succès
- `false` si échec (avec `error` rempli)

## 🔄 Flux de données

```
UnifiedProfileScreen
    ↓ (user clicks delete)
DeleteAccountDialog
    ↓ (user confirms)
AuthProvider.deleteAccount()
    ↓
AccountDeletionService.canDeleteAccount()
    ↓ (checks conditions)
AccountDeletionService.deleteAccount()
    ↓
    ├─→ _deleteMerchantData() ou _deleteUserData()
    ├─→ _deleteUserImages()
    ├─→ Firestore: delete user document
    └─→ FirebaseAuth: delete account
```

## 📊 Collections Firestore

### Utilisateurs (clients)
```dart
// Collections supprimées
- users/{userId}
- favorites (where userId == userId)
- reviews (where userId == userId)
- user_preferences (where userId == userId)
```

### Marchands
```dart
// Collections supprimées
- users/{merchantId}
- invoices (where merchantId == merchantId)
- transactions (where merchantId == merchantId)
- reviews (where merchantId == merchantId)
- advertisements (where merchantId == merchantId)
```

## 🗂️ Firebase Storage

### Chemins supprimés
```dart
// Utilisateurs
user_profile_images/{userId}.jpg

// Marchands
merchant_profile_images/{merchantId}.jpg
merchant_images/{merchantId}/*
```

## 🛡️ Sécurité

### Vérifications implémentées

1. **Session valide**
   - Firebase Auth vérifie la fraîcheur de la session
   - Erreur `requires-recent-login` si session trop ancienne

2. **Conditions métier**
   - Marchands : pas de transactions en attente
   - Extensible pour d'autres conditions

3. **Double confirmation**
   - L'utilisateur doit taper "SUPPRIMER"
   - Bouton désactivé tant que non saisi

### Gestion des erreurs

```dart
try {
  await service.deleteAccount(userId, userRole);
} on FirebaseAuthException catch (e) {
  if (e.code == 'requires-recent-login') {
    // Demander réauthentification
  }
} catch (e) {
  // Erreur générique
}
```

## 🧪 Tests

### Exécuter les tests
```bash
flutter test test/features/auth/services/account_deletion_service_test.dart
```

### Couverture des tests
- ✅ Suppression utilisateur
- ✅ Suppression marchand
- ✅ Vérification conditions
- ✅ Suppression données associées

## 🚀 Utilisation

### Dans le code

```dart
// Dans un widget
final authProvider = Provider.of<AuthProvider>(context, listen: false);

// Supprimer le compte
final success = await authProvider.deleteAccount();

if (success) {
  // Rediriger vers login
  Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.login,
    (route) => false,
  );
} else {
  // Afficher l'erreur
  final error = authProvider.error;
  SnackBarHelper.showError(context, error);
}
```

### Afficher le dialog

```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => const DeleteAccountDialog(),
);

if (confirmed == true) {
  // Procéder à la suppression
}
```

## 📝 Configuration requise

### Dépendances
```yaml
dependencies:
  firebase_auth: ^latest
  cloud_firestore: ^latest
  firebase_storage: ^latest
  logger: ^latest

dev_dependencies:
  fake_cloud_firestore: ^latest
  firebase_auth_mocks: ^latest
  firebase_storage_mocks: ^latest
```

### Permissions Firebase

Assurez-vous que les règles Firestore permettent :
```javascript
// Firestore Rules
match /users/{userId} {
  allow delete: if request.auth.uid == userId;
}

match /favorites/{favoriteId} {
  allow delete: if request.auth != null;
}

// etc. pour les autres collections
```

## 🔍 Debugging

### Logs

Le service utilise `Logger` pour tracer les opérations :

```dart
_logger.i('Début de la suppression du compte: $userId');
_logger.e('Erreur lors de la suppression: $e');
```

### Points de vérification

1. **Firestore Console** : Vérifier que les documents sont supprimés
2. **Storage Console** : Vérifier que les images sont supprimées
3. **Authentication Console** : Vérifier que le compte est supprimé

## ⚠️ Points d'attention

### Performance
- Utilisation de `batch.commit()` pour optimiser les suppressions
- Limite de 500 opérations par batch (à surveiller pour gros comptes)

### Erreurs silencieuses
- Les erreurs Storage ne bloquent pas la suppression
- Loggées mais ne font pas échouer le processus

### Transactions en attente
- Vérification uniquement pour les marchands
- Extensible pour d'autres vérifications

## 🔄 Améliorations futures

### Court terme
- [ ] Export des données avant suppression (RGPD)
- [ ] Email de confirmation après suppression
- [ ] Période de grâce (30 jours)

### Moyen terme
- [ ] Statistiques de suppression (anonymisées)
- [ ] Feedback sur la raison de suppression
- [ ] Désactivation temporaire au lieu de suppression

### Long terme
- [ ] Suppression asynchrone avec queue
- [ ] Archivage des données (compliance)
- [ ] API de suppression pour admin

## 📚 Documentation

- **Guide utilisateur** : `GUIDE_UTILISATEUR_SUPPRESSION.md`
- **Documentation technique** : `SUPPRESSION_COMPTE.md`
- **Résumé implémentation** : `IMPLEMENTATION_SUPPRESSION_COMPTE.md`

## 🤝 Contribution

Pour modifier cette fonctionnalité :

1. Modifier le service : `account_deletion_service.dart`
2. Ajouter des tests : `account_deletion_service_test.dart`
3. Mettre à jour la documentation
4. Tester manuellement avec un compte test

## 📞 Support

En cas de problème :
1. Vérifier les logs
2. Consulter la documentation
3. Vérifier les règles Firebase
4. Contacter l'équipe de développement

---

**Version :** 1.0.0  
**Date :** 17 février 2026  
**Auteur :** Équipe LocaCharge
