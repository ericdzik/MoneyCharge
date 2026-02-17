# Fonctionnalité de Suppression de Compte

## Vue d'ensemble

Cette fonctionnalité permet aux utilisateurs (clients et marchands) de supprimer définitivement leur compte de l'application LocaCharge.

## Fichiers créés/modifiés

### Nouveaux fichiers

1. **lib/features/auth/services/account_deletion_service.dart**
   - Service dédié à la suppression de compte
   - Gère la suppression de toutes les données utilisateur
   - Supprime les données spécifiques selon le rôle (user/merchant)
   - Nettoie les images dans Firebase Storage

2. **lib/features/auth/widgets/delete_account_dialog.dart**
   - Dialog de confirmation avec double vérification
   - L'utilisateur doit taper "SUPPRIMER" pour confirmer
   - Affiche les conséquences de la suppression

### Fichiers modifiés

1. **lib/features/auth/providers/auth_provider.dart**
   - Ajout de la méthode `deleteAccount()`
   - Intégration du service de suppression

2. **lib/features/profile/unified_profile_screen.dart**
   - Ajout du bouton "Supprimer mon compte" dans la zone dangereuse
   - Gestion du flux de suppression avec confirmation

## Fonctionnement

### 1. Déclenchement
- L'utilisateur accède à son profil
- Un bouton rouge "Supprimer mon compte" est affiché dans une zone dangereuse

### 2. Confirmation
- Un dialog s'affiche avec :
  - Liste des conséquences de la suppression
  - Champ de confirmation où l'utilisateur doit taper "SUPPRIMER"
  - Boutons Annuler / Supprimer définitivement

### 3. Vérifications
- Vérification que l'utilisateur peut supprimer son compte
- Pour les marchands : vérification qu'il n'y a pas de transactions en attente

### 4. Suppression des données

#### Pour les utilisateurs (clients)
- Suppression des favoris
- Suppression des avis écrits
- Suppression des préférences utilisateur
- Suppression de l'image de profil

#### Pour les marchands
- Suppression des factures
- Suppression des transactions
- Suppression des avis reçus
- Suppression des publicités
- Suppression des images de profil et de galerie

#### Données communes
- Suppression du document utilisateur dans Firestore
- Suppression du compte Firebase Authentication

### 5. Redirection
- Message de succès
- Redirection vers la page de connexion

## Sécurité

### Réauthentification
Si Firebase Auth détecte que la session est trop ancienne, l'utilisateur devra se reconnecter avant de pouvoir supprimer son compte (erreur `requires-recent-login`).

### Confirmation stricte
L'utilisateur doit explicitement taper "SUPPRIMER" en majuscules pour activer le bouton de confirmation.

### Irréversibilité
Un avertissement clair indique que l'action est irréversible et définitive.

## Gestion des erreurs

Le service gère plusieurs types d'erreurs :
- Erreurs Firebase Auth (session expirée, etc.)
- Erreurs Firestore (problèmes de suppression de données)
- Erreurs Storage (problèmes de suppression d'images)

Les erreurs sont loggées et affichées à l'utilisateur de manière claire.

## Améliorations futures possibles

1. **Export des données** : Permettre à l'utilisateur d'exporter ses données avant suppression (RGPD)
2. **Période de grâce** : Marquer le compte comme "en attente de suppression" pendant 30 jours
3. **Email de confirmation** : Envoyer un email de confirmation après la suppression
4. **Raison de suppression** : Demander à l'utilisateur pourquoi il supprime son compte (feedback)
5. **Suppression partielle** : Permettre de désactiver le compte au lieu de le supprimer

## Tests recommandés

1. Tester la suppression d'un compte utilisateur simple
2. Tester la suppression d'un compte marchand avec données
3. Tester la suppression avec session expirée
4. Tester l'annulation du processus
5. Tester avec un marchand ayant des transactions en attente
6. Vérifier que toutes les données sont bien supprimées dans Firestore
7. Vérifier que les images sont bien supprimées dans Storage
