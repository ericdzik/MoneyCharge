# 🔧 Guide de Résolution du Problème de Permissions

## ✅ Problème Résolu

**Symptôme:** "Accès refusé" lors de la connexion en tant que marchand

**Cause:** Le `PermissionProvider` ne se mettait pas à jour correctement lors de la connexion

**Solution appliquée:** Correction de la logique de mise à jour dans `PermissionProvider`

---

## 🧪 Comment Tester la Correction

### 1. Lancer l'Application

```bash
flutter run
```

### 2. Se Connecter en Tant que Marchand

Utilisez vos identifiants de compte marchand.

### 3. Vérifier les Logs dans la Console

Vous devriez voir des logs comme ceci :

```
🔐 RoleManager: Building permissions for MERCHANT
   📋 User permissions inherited: viewHome, viewUserProfile, editUserProfile, viewMarketplace, viewFavorites
   📋 Merchant permissions added: accessMerchantDashboard, manageStock, createInvoice, viewSalesByType, manageBusinessProfile, respondToReviews
   ✅ Total permissions: 11

🔐 PermissionProvider: Calculated permissions for UserType.merchant
🔐 Permissions: viewHome, viewUserProfile, editUserProfile, viewMarketplace, viewFavorites, accessMerchantDashboard, manageStock, createInvoice, viewSalesByType, manageBusinessProfile, respondToReviews
```

### 4. Vérifier l'Accès aux Écrans

Le marchand devrait maintenant avoir accès à :

**✅ Écrans User (Hérités):**
- Home Feed
- Map View
- List View
- Favorites
- User Profile

**✅ Écrans Merchant (Spécifiques):**
- Merchant Dashboard
- Merchant Card
- Sales Screen
- Stock Management
- Merchant Profile
- Reviews

---

## 🐛 Si le Problème Persiste

### Option 1: Ajouter le Widget de Debug

Ajoutez temporairement le widget de debug dans votre `MerchantDashboardScreen` :

```dart
import 'package:locacharge/core/widgets/permission_debug_widget.dart';

// Dans le build method
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Votre contenu existant
        SafeArea(child: screens[_currentIndex]),
        
        // Widget de debug (TEMPORAIRE)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: PermissionDebugWidget(),
        ),
      ],
    ),
    bottomNavigationBar: ModernFloatingNavBarWithLabels(...),
  );
}
```

Cela affichera en temps réel :
- Le type d'utilisateur
- L'état d'authentification
- Toutes les permissions disponibles

### Option 2: Vérifier le Profil Firestore

Assurez-vous que dans Firestore, le document de votre marchand a :

```json
{
  "role": "merchant",  // IMPORTANT: doit être exactement "merchant" (minuscules)
  "email": "...",
  "name": "...",
  // autres champs...
}
```

### Option 3: Hot Restart

Parfois, un simple hot restart résout le problème :

```bash
# Dans le terminal où l'app tourne
R  (majuscule R pour hot restart)
```

---

## 📊 Validation Complète

### Checklist de Test

- [ ] Connexion en tant que marchand réussie
- [ ] Logs de debug visibles dans la console
- [ ] Accès au Home Feed (écran User)
- [ ] Accès à la Map View (écran User)
- [ ] Accès aux Favoris (écran User)
- [ ] Accès au Merchant Dashboard
- [ ] Accès à la gestion de stock
- [ ] Accès aux ventes
- [ ] Aucun message "Accès refusé"

---

## 🎯 Prochaines Actions

Une fois que tout fonctionne :

1. **Retirer les logs de debug** (optionnel) :
   - Commenter les `print()` dans `role_manager.dart`
   - Commenter les `debugPrint()` dans `permission_provider.dart`

2. **Retirer le PermissionDebugWidget** si vous l'avez ajouté

3. **Tester avec différents types d'utilisateurs** :
   - User standard
   - Merchant
   - Admin (si applicable)

---

## 💡 Comprendre la Correction

### Avant (Bug)

```dart
void update(AuthProvider authProvider) {
  // ❌ Comparait toujours la même référence
  if (authProvider.userType != _authProvider.userType) {
    _calculatePermissions();
  }
}
```

### Après (Corrigé)

```dart
void update(AuthProvider authProvider) {
  _authProvider = authProvider;  // ✅ Met à jour la référence
  
  // ✅ Compare avec l'état précédent stocké
  if (authProvider.userType != _lastUserType ||
      authProvider.isAuthenticated != _lastAuthState) {
    _lastUserType = authProvider.userType;
    _lastAuthState = authProvider.isAuthenticated;
    _calculatePermissions();
  }
}
```

---

## 📞 Besoin d'Aide ?

Si le problème persiste après ces étapes :

1. Vérifiez les logs complets de la console
2. Vérifiez que le rôle dans Firestore est correct
3. Essayez de vous déconnecter et reconnecter
4. Essayez un hot restart complet de l'application

---

## ✨ Résumé

Le système RBAC est maintenant correctement configuré avec :
- ✅ Héritage des permissions (Merchant → User)
- ✅ Mise à jour automatique lors de la connexion
- ✅ Logs de debug pour faciliter le diagnostic
- ✅ Widget de debug disponible si nécessaire

Votre marchand devrait maintenant avoir accès à **toutes** les fonctionnalités User **plus** ses fonctionnalités spécifiques Merchant !
