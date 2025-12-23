# 🔐 Guide de Sécurité des Clés API - MoneyCharge

## 📋 Table des matières
1. [Configuration initiale](#configuration-initiale)
2. [Clés API utilisées](#clés-api-utilisées)
3. [Bonnes pratiques](#bonnes-pratiques)
4. [Sécurisation AndroidManifest](#sécurisation-androidmanifest)
5. [Rotation des clés](#rotation-des-clés)
6. [Checklist de déploiement](#checklist-de-déploiement)

---

## 🚀 Configuration initiale

### 1. Copier le fichier d'exemple
```bash
cp .env.example .env
```

### 2. Remplir les clés dans `.env`
Éditez le fichier `.env` avec vos vraies clés API :
```bash
nano .env  # ou utilisez votre éditeur préféré
```

### 3. Vérifier que `.env` est ignoré par Git
```bash
git status  # .env ne doit PAS apparaître
```

⚠️ **IMPORTANT**: Le fichier `.env` contient des secrets et ne doit JAMAIS être commité dans Git !

---

## 🔑 Clés API utilisées

### Google Maps & Directions
| Clé | Usage | Plateforme | Restrictions recommandées |
|-----|-------|------------|---------------------------|
| `GOOGLE_MAPS_API_KEY_ANDROID` | Google Maps SDK | Android | Restreindre par SHA-1 |
| `GOOGLE_MAPS_API_KEY_IOS` | Google Maps SDK | iOS | Restreindre par Bundle ID |
| `GOOGLE_MAPS_API_KEY_WEB` | Google Maps JS | Web | Restreindre par domaine |
| `GOOGLE_DIRECTIONS_API_KEY` | Directions API | Backend | Restreindre par IP serveur |

### Firebase
| Clé | Usage | Plateforme |
|-----|-------|------------|
| `FIREBASE_API_KEY_WEB` | Firebase Web | Web |
| `FIREBASE_API_KEY_ANDROID` | Firebase Android | Android |
| `FIREBASE_API_KEY_IOS` | Firebase iOS | iOS |
| `FIREBASE_PROJECT_ID` | Identifiant projet | Toutes |
| `FIREBASE_APP_ID_*` | Identifiants app | Par plateforme |

### Paystack
| Clé | Usage | Sécurité |
|-----|-------|----------|
| `PAYSTACK_PUBLIC_KEY` | Paiements côté client | ✅ Public |
| `PAYSTACK_SECRET_KEY` | API serveur | ⚠️ CONFIDENTIEL - Ne jamais exposer côté client |

---

## ✅ Bonnes pratiques

### 1. Séparation des clés par environnement
```bash
.env              # Développement local
.env.staging      # Staging/test
.env.production   # Production
```

### 2. Restrictions sur Google Cloud Console
Pour chaque clé Google Maps/Directions :

**Android:**
```
Application restrictions: Android apps
- Add package name: com.example.locacharge
- Add SHA-1 fingerprints (debug + release)
```

**iOS:**
```
Application restrictions: iOS apps
- Add bundle identifier: com.example.locacharge
```

**Web:**
```
Application restrictions: HTTP referrers
- Add website: https://votredomaine.com/*
- Add website: http://localhost:* (dev uniquement)
```

### 3. Activer la facturation et les alertes
```
Google Cloud Console > Billing > Budgets & Alerts
- Définir un budget mensuel (ex: 50€)
- Alertes à 50%, 90%, 100%
```

### 4. Règles Firebase Security
Exemple pour Firestore :
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Accès lecture publique, écriture authentifiée uniquement
    match /merchants/{merchantId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == merchantId;
    }
  }
}
```

---

## 📱 Sécurisation AndroidManifest

### Configuration actuelle
Le fichier `android/app/src/main/AndroidManifest.xml` contient actuellement :
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyAnxu5s34xXzvg123FkxNxGucEd5fNlnwI"/>
```

### ⚠️ Recommandations

**Option 1: Utiliser BuildConfig (Recommandé)**

1. Modifier `android/app/build.gradle.kts` :
```kotlin
android {
    defaultConfig {
        // ...
        manifestPlaceholders["GOOGLE_MAPS_KEY"] = project.findProperty("GOOGLE_MAPS_KEY") ?: ""
    }
}
```

2. Créer `android/local.properties` :
```properties
GOOGLE_MAPS_KEY=AIzaSyAnxu5s34xXzvg123FkxNxGucEd5fNlnwI
```

3. Mettre à jour AndroidManifest.xml :
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_KEY}"/>
```

4. Ajouter à `.gitignore` :
```
android/local.properties
```

**Option 2: Rotation de la clé**
Si la clé actuelle est compromise :
1. Générer une nouvelle clé sur Google Cloud Console
2. Mettre à jour `.env` avec la nouvelle clé
3. Révoquer l'ancienne clé

---

## 🔄 Rotation des clés

### Quand faire une rotation ?
- ✅ Tous les 90 jours (bonne pratique)
- ⚠️ Immédiatement si clé compromise
- ⚠️ Si clé visible dans un commit Git public
- ⚠️ Après départ d'un développeur ayant accès

### Procédure de rotation

1. **Créer une nouvelle clé**
   ```bash
   Google Cloud Console > APIs & Services > Credentials > Create Credentials
   ```

2. **Mettre à jour `.env`**
   ```bash
   # Sauvegarder l'ancienne clé
   cp .env .env.backup
   
   # Mettre à jour avec la nouvelle clé
   nano .env
   ```

3. **Tester l'application**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Révoquer l'ancienne clé**
   ```bash
   Google Cloud Console > Delete old key (après 24-48h de transition)
   ```

---

## 📋 Checklist de déploiement

### Avant chaque build de production

- [ ] Vérifier que `.env` contient les clés de **PRODUCTION**
- [ ] Confirmer `ENVIRONMENT=production` dans `.env`
- [ ] Confirmer `DEBUG_MODE=false` dans `.env`
- [ ] Vérifier `PAYSTACK_MODE=live` (si prêt pour paiements réels)
- [ ] Tester que `.env` n'est PAS dans Git : `git status`
- [ ] Vérifier restrictions API sur Google Cloud Console
- [ ] Activer ProGuard/R8 pour Android (obfuscation)
- [ ] Tester l'app en mode release : `flutter run --release`
- [ ] Vérifier les logs : aucune clé API ne doit apparaître
- [ ] Valider Firebase Security Rules en production
- [ ] Configurer les alertes de facturation
- [ ] Documenter les clés utilisées dans un gestionnaire de secrets (1Password, etc.)

### Après déploiement

- [ ] Monitorer l'utilisation des APIs
- [ ] Vérifier les alertes de sécurité Firebase
- [ ] Surveiller les coûts Google Cloud
- [ ] Planifier la prochaine rotation de clés (dans 90 jours)

---

## 🆘 En cas de fuite de clé

### Réaction immédiate (dans l'heure)

1. **Révoquer la clé compromise**
   ```
   Google Cloud Console > Credentials > Delete Key
   Firebase Console > Project Settings > Regenerate tokens
   ```

2. **Générer de nouvelles clés**
   - Créer immédiatement des clés de remplacement
   - Activer toutes les restrictions possibles

3. **Mettre à jour l'application**
   ```bash
   # Mettre à jour .env avec nouvelles clés
   flutter clean
   flutter pub get
   
   # Build d'urgence
   flutter build apk --release
   flutter build ios --release
   ```

4. **Déployer la mise à jour**
   - Publier sur Play Store (fast track)
   - Publier sur App Store (expedited review)
   - Forcer la mise à jour si possible

5. **Notification**
   - Informer l'équipe
   - Documenter l'incident
   - Analyser la cause

---

## 📚 Ressources

- [Google Maps API Security](https://developers.google.com/maps/api-security-best-practices)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Paystack Security](https://paystack.com/docs/security)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security-testing-guide/)

---

## 👨‍💻 Support

Pour toute question de sécurité :
- 📧 Email: security@locacharge.com
- 🔐 Gestionnaire de secrets: [Lien vers 1Password/Vault]
- 📖 Wiki équipe: [Lien vers documentation interne]

**Dernière mise à jour:** 19 décembre 2025
