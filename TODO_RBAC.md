# Plan d'Intégration RBAC (Role-Based Access Control)

Ce document suit l'avancement de l'intégration du nouveau système de sécurité basé sur les permissions.

## Phase 1 : Câblage (Core)
- [x] **Injecter le Provider** : Ajouter `PermissionProvider` dans `lib/app.dart` via `MultiProvider`. `// turbo`
- [x] **Connecter l'Auth** : S'assurer que `PermissionProvider` se met à jour quand `AuthProvider` change. `// turbo`
- [x] **FIX: Correction du bug de mise à jour** : Corriger la logique de comparaison dans `PermissionProvider.update()`

## Phase 2 : Migration de la Navigation (Routing)
- [x] **Remplacer les Guards** : Modifier `_generateRoute` dans `app.dart`.
    - [x] Remplacer `RouteGuards.requireUserType(..., UserType.merchant)` par `PermissionGuard.check(..., AppPermission.accessMerchantDashboard)`.
    - [x] Remplacer `RouteGuards.requireUserType(..., UserType.admin)` par `PermissionGuard.check(..., AppPermission.accessAdminDashboard)`.
- [x] **Nettoyage** : Supprimer ou déprécier les anciennes méthodes dans `RouteGuards` (optionnel mais recommandé).

## Phase 3 : Interface Utilisateur (UI)
- [x] **Adapter le Dashboard** : Utiliser `AccessControl` pour afficher les options admin/marchand uniquement si permis.
- [x] **Protéger les Actions** : Sécuriser les boutons critiques (ex: Création de facture, Gestion de stock).

## Phase 4 : Vérification et Debug
- [x] **Ajout de logs de debug** : Logs dans RoleManager et PermissionProvider pour faciliter le diagnostic
- [x] **Widget de debug** : Création de `PermissionDebugWidget` pour afficher les permissions en temps réel
- [ ] **Test Utilisateur** : Vérifier accès standard.
- [ ] **Test Marchand** : Vérifier accès fonctionnalités marchand + fonctionnalités utilisateur (Héritage).
- [ ] **Test Admin** : Vérifier accès admin.

## 🐛 Corrections Appliquées

### Bug Fix: PermissionProvider ne se mettait pas à jour
**Problème:** Lors de la connexion en tant que marchand, les permissions n'étaient pas calculées correctement.

**Cause:** Dans `PermissionProvider.update()`, la comparaison utilisait `_authProvider` qui était une référence constante, donc la condition ne se déclenchait jamais.

**Solution:** 
- Stocker `_lastUserType` et `_lastAuthState` pour comparer avec les nouvelles valeurs
- Mettre à jour `_authProvider` dans la méthode `update()`
- Ajouter des logs de debug pour faciliter le diagnostic

**Fichiers modifiés:**
- `lib/core/security/permission_provider.dart`
- `lib/core/security/role_manager.dart`

## 📚 Documentation Créée
- ✅ `RBAC_ARCHITECTURE.md` - Architecture complète du système
- ✅ `RBAC_TEST_GUIDE.md` - Guide de test détaillé
- ✅ `lib/core/widgets/permission_debug_widget.dart` - Widget de debug

## 🔍 Pour Tester

1. **Lancer l'app et se connecter en tant que marchand**
2. **Vérifier les logs dans la console** :
   - Vous devriez voir : `🔐 RoleManager: Building permissions for MERCHANT`
   - Suivi de la liste des permissions héritées et spécifiques
3. **Optionnel: Ajouter le PermissionDebugWidget** dans un écran pour voir les permissions en temps réel

## 🎯 Prochaines Étapes

1. Tester avec un compte marchand réel
2. Valider que toutes les fonctionnalités User sont accessibles
3. Valider que toutes les fonctionnalités Merchant sont accessibles
4. Retirer les logs de debug une fois validé (ou les mettre en mode dev uniquement)
