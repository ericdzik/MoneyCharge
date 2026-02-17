# Interface Visuelle - Suppression de Compte

## 📱 Aperçu de l'interface utilisateur

### 1. Page Profil - Zone Dangereuse

```
┌─────────────────────────────────────────────────┐
│  ← Profil                                    👤 │
├─────────────────────────────────────────────────┤
│                                                 │
│  [Photo de profil]                              │
│  Jean Dupont                                    │
│  jean.dupont@email.com                          │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │ 🏪 Espace Marchand                        │ │
│  │ Accéder à votre tableau de bord marchand  │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │ 📄 Conditions d'Utilisation               │ │
│  │ Lire les CGU de l'application             │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  ╔═══════════════════════════════════════════╗ │
│  ║ ⚠️  Zone dangereuse                       ║ │
│  ║                                           ║ │
│  ║ La suppression de votre compte est       ║ │
│  ║ définitive et irréversible.              ║ │
│  ║                                           ║ │
│  ║ ┌───────────────────────────────────────┐ ║ │
│  ║ │ 🗑️  Supprimer mon compte              │ ║ │
│  ║ └───────────────────────────────────────┘ ║ │
│  ╚═══════════════════════════════════════════╝ │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Caractéristiques :**
- 🔴 Fond rouge clair pour attirer l'attention
- ⚠️ Icône d'avertissement
- 📝 Message clair sur l'irréversibilité
- 🗑️ Bouton avec bordure rouge

---

### 2. Dialog de Confirmation

```
┌─────────────────────────────────────────────────┐
│  ⚠️  Supprimer le compte                    ✕  │
├─────────────────────────────────────────────────┤
│                                                 │
│  Cette action est irréversible !               │
│                                                 │
│  La suppression de votre compte entraînera :   │
│                                                 │
│  ✗ Suppression de toutes vos données           │
│    personnelles                                 │
│                                                 │
│  ✗ Suppression de votre historique de          │
│    transactions                                 │
│                                                 │
│  ✗ Suppression de vos avis et commentaires     │
│                                                 │
│  ✗ Perte définitive de l'accès à votre         │
│    compte                                       │
│                                                 │
│  ╔═══════════════════════════════════════════╗ │
│  ║ Pour confirmer, tapez "SUPPRIMER"         ║ │
│  ║ ci-dessous :                              ║ │
│  ║                                           ║ │
│  ║ ┌───────────────────────────────────────┐ ║ │
│  ║ │ SUPPRIMER                             │ ║ │
│  ║ └───────────────────────────────────────┘ ║ │
│  ╚═══════════════════════════════════════════╝ │
│                                                 │
│              [Annuler] [Supprimer définitivement]│
│                                                 │
└─────────────────────────────────────────────────┘
```

**Caractéristiques :**
- ⚠️ Titre avec icône d'avertissement
- 📋 Liste claire des conséquences
- 🔴 Zone rouge pour le champ de confirmation
- ⌨️ Champ de saisie pour taper "SUPPRIMER"
- 🔘 Bouton désactivé jusqu'à saisie correcte

---

### 3. États du bouton de confirmation

#### État désactivé (par défaut)
```
┌─────────────────────────────────────┐
│  Supprimer définitivement           │  ← Grisé
└─────────────────────────────────────┘
```

#### État activé (après saisie de "SUPPRIMER")
```
┌─────────────────────────────────────┐
│  Supprimer définitivement           │  ← Rouge vif
└─────────────────────────────────────┘
```

---

### 4. Loader pendant la suppression

```
┌─────────────────────────────────────────────────┐
│                                                 │
│                                                 │
│                                                 │
│                    ⏳                           │
│                                                 │
│            Suppression en cours...              │
│                                                 │
│                                                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

### 5. Message de succès

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  ✅ Votre compte a été supprimé avec succès.   │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Puis redirection automatique vers :**

```
┌─────────────────────────────────────────────────┐
│                                                 │
│              [Logo LocaCharge]                  │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │ Email                                     │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │ Mot de passe                              │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │           Se connecter                    │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  Pas encore de compte ? S'inscrire             │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

### 6. Messages d'erreur possibles

#### Erreur : Session expirée
```
┌─────────────────────────────────────────────────┐
│  ❌ Pour des raisons de sécurité, veuillez     │
│     vous reconnecter avant de supprimer votre   │
│     compte.                                     │
└─────────────────────────────────────────────────┘
```

#### Erreur : Transactions en attente (marchands)
```
┌─────────────────────────────────────────────────┐
│  ❌ Vous avez des transactions en attente.     │
│     Veuillez les finaliser avant de supprimer   │
│     votre compte.                               │
└─────────────────────────────────────────────────┘
```

#### Erreur générique
```
┌─────────────────────────────────────────────────┐
│  ❌ Une erreur est survenue lors de la         │
│     suppression du compte. Veuillez réessayer.  │
└─────────────────────────────────────────────────┘
```

---

## 🎨 Palette de couleurs

### Zone dangereuse
- **Fond** : `AppColors.error.withOpacity(0.05)` (rouge très clair)
- **Bordure** : `AppColors.error.withOpacity(0.2)` (rouge clair)
- **Texte** : `AppColors.error` (rouge)
- **Icône** : `AppColors.error` (rouge)

### Bouton de suppression
- **Bordure** : `AppColors.error` (rouge)
- **Texte** : `AppColors.error` (rouge)
- **Fond hover** : `AppColors.error.withOpacity(0.1)` (rouge très clair)

### Dialog de confirmation
- **Fond zone confirmation** : `AppColors.error.withOpacity(0.1)` (rouge très clair)
- **Bordure zone confirmation** : `AppColors.error.withOpacity(0.3)` (rouge clair)
- **Bouton confirmer** : `AppColors.error` (rouge)
- **Bouton annuler** : `AppColors.textSecondary` (gris)

---

## 📐 Dimensions et espacements

### Zone dangereuse
- **Padding** : `AppDimensions.paddingM` (16px)
- **Border radius** : `AppDimensions.radiusM` (12px)
- **Espacement interne** : 12px entre les éléments

### Dialog
- **Border radius** : `AppDimensions.radiusL` (16px)
- **Padding** : 24px
- **Espacement entre sections** : 16-20px

### Boutons
- **Height** : 48px
- **Border radius** : `AppDimensions.radiusM` (12px)
- **Padding horizontal** : 16px
- **Padding vertical** : 12px

---

## 🔤 Typographie

### Titres
- **Zone dangereuse** : `AppTextStyles.h3` + `fontWeight: w600`
- **Dialog titre** : `AppTextStyles.h2`

### Corps de texte
- **Description** : `AppTextStyles.body2`
- **Liste conséquences** : `AppTextStyles.body2`
- **Avertissement** : `AppTextStyles.body1` + `fontWeight: bold`

### Boutons
- **Texte bouton** : `AppTextStyles.body1` + `fontWeight: w600`

---

## 📱 Responsive

### Mobile (< 600px)
- Zone dangereuse : pleine largeur
- Dialog : pleine largeur avec padding réduit
- Boutons : pleine largeur

### Tablet (600-1024px)
- Zone dangereuse : largeur maximale 600px
- Dialog : largeur maximale 500px
- Boutons : largeur adaptative

### Desktop (> 1024px)
- Zone dangereuse : largeur maximale 700px
- Dialog : largeur maximale 600px
- Boutons : largeur fixe

---

## ♿ Accessibilité

### Contraste
- ✅ Ratio de contraste > 4.5:1 pour tous les textes
- ✅ Icônes avec taille minimale 24px
- ✅ Zone cliquable minimale 48x48px

### Navigation
- ✅ Support du clavier (Tab, Enter, Escape)
- ✅ Focus visible sur tous les éléments interactifs
- ✅ Ordre de tabulation logique

### Lecteurs d'écran
- ✅ Labels descriptifs sur tous les champs
- ✅ Messages d'erreur annoncés
- ✅ État des boutons annoncé (activé/désactivé)

---

## 🎬 Animations

### Apparition du dialog
- **Type** : Fade in + Scale
- **Durée** : 300ms
- **Courbe** : easeInOut

### Activation du bouton
- **Type** : Color transition
- **Durée** : 200ms
- **Courbe** : easeIn

### Loader
- **Type** : Circular progress indicator
- **Couleur** : `AppColors.primary`

---

**Design conforme aux standards Material Design 3**  
**Compatible iOS et Android**  
**Testé sur différentes tailles d'écran**
