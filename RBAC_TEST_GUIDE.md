# Guide de Test RBAC - Validation de l'Héritage des Permissions

Ce document fournit un guide de test complet pour valider le système RBAC avec héritage de permissions.

## 🎯 Objectif

Valider que :
1. ✅ Les **Users** ont accès uniquement à leurs fonctionnalités
2. ✅ Les **Merchants** héritent de TOUTES les fonctionnalités User + leurs fonctionnalités spécifiques
3. ✅ Les **Admins** ont accès à leurs fonctionnalités spécifiques
4. ✅ Aucune duplication de code n'est nécessaire

## 📋 Scénarios de Test

### Test 1: Utilisateur Standard (User)

**Compte de test:**
- Email: `user@test.com`
- Mot de passe: `Test123!`

**Fonctionnalités attendues (ACCESSIBLES):**
- ✅ Écran d'accueil (Home Feed)
- ✅ Vue carte (Map View)
- ✅ Vue liste (List View)
- ✅ Favoris
- ✅ Profil utilisateur
- ✅ Édition du profil utilisateur
- ✅ Détails des marchands
- ✅ Détails des publicités

**Fonctionnalités attendues (NON ACCESSIBLES):**
- ❌ Dashboard marchand
- ❌ Gestion de stock
- ❌ Création de factures
- ❌ Ventes
- ❌ Profil marchand
- ❌ Dashboard admin
- ❌ Gestion des utilisateurs
- ❌ Approbation des marchands

**Comment tester:**
1. Se connecter avec le compte User
2. Vérifier que la barre de navigation affiche uniquement les 5 onglets User
3. Essayer d'accéder manuellement aux routes marchands (devrait être bloqué)
4. Vérifier qu'aucun bouton/option marchand n'est visible dans l'UI

---

### Test 2: Marchand (Merchant) - HÉRITAGE CRITIQUE

**Compte de test:**
- Email: `merchant@test.com`
- Mot de passe: `Test123!`

**Fonctionnalités attendues (ACCESSIBLES - Héritées de User):**
- ✅ Écran d'accueil (Home Feed) - **HÉRITÉ**
- ✅ Vue carte (Map View) - **HÉRITÉ**
- ✅ Vue liste (List View) - **HÉRITÉ**
- ✅ Favoris - **HÉRITÉ**
- ✅ Profil utilisateur - **HÉRITÉ**
- ✅ Détails des marchands - **HÉRITÉ**
- ✅ Détails des publicités - **HÉRITÉ**

**Fonctionnalités attendues (ACCESSIBLES - Spécifiques Merchant):**
- ✅ Dashboard marchand
- ✅ Carte marchand
- ✅ Gestion de stock
- ✅ Création de factures
- ✅ Ventes
- ✅ Profil marchand
- ✅ Avis clients
- ✅ Édition du profil marchand

**Fonctionnalités attendues (NON ACCESSIBLES):**
- ❌ Dashboard admin
- ❌ Gestion des utilisateurs
- ❌ Approbation des marchands
- ❌ Gestion des publicités système

**Comment tester:**
1. Se connecter avec le compte Merchant
2. **VÉRIFICATION CRITIQUE:** Vérifier que la barre de navigation affiche les onglets User (Home, Carte, Liste, Favoris, Profil)
3. Naviguer vers chaque écran User et vérifier qu'ils fonctionnent correctement
4. Accéder aux fonctionnalités marchands via le menu "Plus" ou les routes directes
5. Vérifier que toutes les fonctionnalités marchands sont accessibles
6. Essayer d'accéder aux routes admin (devrait être bloqué)

**Points de validation de l'héritage:**
- [ ] Le marchand peut voir le Home Feed comme un utilisateur standard
- [ ] Le marchand peut ajouter des favoris
- [ ] Le marchand peut voir la carte et la liste des marchands
- [ ] Le marchand peut voir son propre profil en tant que marchand dans la liste
- [ ] Le marchand a accès à ses fonctionnalités spécifiques en plus

---

### Test 3: Administrateur (Admin)

**Compte de test:**
- Email: `admin@test.com`
- Mot de passe: `Test123!`

**Fonctionnalités attendues (ACCESSIBLES):**
- ✅ Dashboard admin
- ✅ Gestion des utilisateurs
- ✅ Approbation des marchands
- ✅ Gestion des publicités système
- ✅ Analytiques système
- ✅ Écran d'accueil (Home) - pour voir l'app

**Fonctionnalités attendues (NON ACCESSIBLES):**
- ❌ Fonctionnalités marchands spécifiques (sauf si configuré autrement)

**Comment tester:**
1. Se connecter avec le compte Admin
2. Vérifier l'accès au dashboard admin
3. Vérifier les fonctionnalités de gestion
4. Vérifier que les routes marchands sont bloquées (sauf configuration spéciale)

---

## 🔍 Tests Techniques

### Test 4: Vérification du RoleManager

**Objectif:** Valider que la logique d'héritage fonctionne correctement

**Code de test:**
```dart
void testRoleInheritance() {
  final roleManager = RoleManager();
  
  // Test User permissions
  final userPerms = roleManager.getPermissionsForRole(UserType.user);
  assert(userPerms.contains(AppPermission.viewHome));
  assert(userPerms.contains(AppPermission.viewMarketplace));
  assert(!userPerms.contains(AppPermission.manageStock));
  
  // Test Merchant permissions (HÉRITAGE)
  final merchantPerms = roleManager.getPermissionsForRole(UserType.merchant);
  
  // Vérifier l'héritage des permissions User
  assert(merchantPerms.contains(AppPermission.viewHome), 'Merchant should inherit viewHome');
  assert(merchantPerms.contains(AppPermission.viewMarketplace), 'Merchant should inherit viewMarketplace');
  assert(merchantPerms.contains(AppPermission.viewFavorites), 'Merchant should inherit viewFavorites');
  
  // Vérifier les permissions spécifiques Merchant
  assert(merchantPerms.contains(AppPermission.manageStock), 'Merchant should have manageStock');
  assert(merchantPerms.contains(AppPermission.createInvoice), 'Merchant should have createInvoice');
  
  // Vérifier que Merchant n'a pas les permissions Admin
  assert(!merchantPerms.contains(AppPermission.accessAdminDashboard));
  
  print('✅ All role inheritance tests passed!');
}
```

---

### Test 5: Vérification de la Navigation

**Objectif:** Valider que les guards de navigation fonctionnent correctement

**Scénarios:**
1. **User essaie d'accéder à une route Merchant**
   - Résultat attendu: Redirection + message d'erreur
   
2. **Merchant essaie d'accéder à une route User**
   - Résultat attendu: Accès autorisé (héritage)
   
3. **Merchant essaie d'accéder à une route Admin**
   - Résultat attendu: Redirection + message d'erreur

---

### Test 6: Vérification de l'UI Conditionnelle

**Objectif:** Valider que les widgets AccessControl fonctionnent correctement

**Scénarios:**
1. **User voit l'écran Home**
   - Vérifier qu'aucun bouton marchand n'est visible
   
2. **Merchant voit l'écran Home**
   - Vérifier que l'écran est identique à celui du User
   - Vérifier que les boutons marchands sont visibles dans le profil/menu

---

## 📊 Checklist de Validation Finale

### Héritage des Permissions
- [ ] Merchant hérite de toutes les permissions User
- [ ] Aucune duplication de code pour les écrans User
- [ ] Les écrans User fonctionnent identiquement pour User et Merchant

### Navigation
- [ ] PermissionGuard bloque correctement les accès non autorisés
- [ ] Les routes sont protégées par les bonnes permissions
- [ ] Les messages d'erreur sont clairs et informatifs

### Interface Utilisateur
- [ ] AccessControl affiche/cache correctement les widgets selon les permissions
- [ ] La barre de navigation s'adapte au rôle de l'utilisateur
- [ ] Aucun bouton/option inaccessible n'est visible

### Architecture
- [ ] RoleManager centralise la logique des permissions
- [ ] PermissionProvider se met à jour correctement lors des changements d'auth
- [ ] Aucun hard-coding de rôles dans les widgets

### Extensibilité
- [ ] Facile d'ajouter une nouvelle permission
- [ ] Facile d'ajouter un nouveau rôle
- [ ] Support pour les permissions dynamiques du backend (préparé)

---

## 🚀 Prochaines Étapes

Une fois tous les tests validés :

1. **Documentation**
   - Documenter l'architecture RBAC pour les futurs développeurs
   - Créer des exemples d'utilisation

2. **Optimisation**
   - Vérifier les performances du système de permissions
   - Optimiser les rebuilds inutiles

3. **Évolution**
   - Préparer l'intégration avec le backend pour les permissions dynamiques
   - Implémenter un système de cache si nécessaire

---

## 📝 Notes Importantes

### Principe Clé: Héritage vs Composition

L'architecture actuelle utilise l'**héritage** pour les permissions :
- Merchant **EST UN** User avec des capacités supplémentaires
- Cela évite la duplication de code
- Les écrans User sont réutilisés tels quels

### Avantages de cette Approche

1. **DRY (Don't Repeat Yourself)**: Aucune duplication de code
2. **Maintenance**: Un seul endroit pour modifier les fonctionnalités User
3. **Cohérence**: L'expérience User est identique pour tous
4. **Scalabilité**: Facile d'ajouter de nouveaux rôles avec héritage

### Points d'Attention

1. **Permissions Backend**: Préparer l'intégration avec des permissions dynamiques
2. **Cache**: Surveiller les performances si le nombre de permissions augmente
3. **Tests**: Maintenir une couverture de tests pour l'héritage
