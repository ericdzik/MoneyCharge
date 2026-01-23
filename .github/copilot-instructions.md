## But

Fournir aux agents IA des informations précises et actionnables pour travailler efficacement sur le projet MoneyCharge (Flutter + Firebase).

## Big picture

- **Application Flutter multi‑rôle** : client mobile (utilisateur), marchand et admin, organisée par domaine dans `lib/features/`.
- **Architecture simple** : UI par fonctionnalité, état centralisé dans `lib/providers/`, logique métier dans `lib/services/` et données dans Firestore.
- **Authentification & rôles** : rôle utilisateur (`user`, `merchant`, `admin`) stocké dans le document Firestore `users.role` — la logique de routage dépend directement de ce champ.

## Fichiers clés (exemples)

- **Entrées app** : [lib/main.dart](lib/main.dart) et [lib/app.dart](lib/app.dart)
- **Config Firebase** : [lib/firebase_options.dart](lib/firebase_options.dart) et [android/app/google-services.json](android/app/google-services.json)
- **API / services** : [lib/services/api_service.dart](lib/services/api_service.dart) (baseUrl configurable)
- **Domain features** : [lib/features/user/screens/home_feed_screen.dart](lib/features/user/screens/home_feed_screen.dart) (exemple de vue utilisateur)
- **Providers / état** : dossier [lib/providers](lib/providers)
- **Cloud Functions** : [functions/index.js](functions/index.js)
- **Manifest / dépendances** : [pubspec.yaml](pubspec.yaml)

## Workflows et commandes rapides

- Installer dépendances : `flutter pub get`
- Lancer en debug : `flutter run` (ou `flutter run -d <device>`)
- Tester : `flutter test` (exécuter depuis la racine)
- Construire APK / AppBundle : `flutter build apk` / `flutter build appbundle`
- Android local build : utiliser `android/gradlew.bat` pour tâches Gradle spécifiques

Note : les builds iOS exigent Xcode sur macOS ; vérifiez `ios/Runner` pour la configuration de provisioning.

## Patterns et conventions spécifiques au projet

- Structure par caractéristique : ajouter nouvelles pages, providers et services sous `lib/features/<domain>/`.
- Services métier centralisés : mettre les appels réseau et constantes (ex. `baseUrl`) dans `lib/services/`.
- State management : utiliser les providers existants sous `lib/providers/` — réutiliser les patterns existants plutôt que d'introduire un nouvel outil.
- Composants UI réutilisables : rechercher `CustomButton`, `CustomTextField`, `CustomAppBar` dans `lib/` et les utiliser pour cohérence.
- Ne pas modifier les dossiers `build/` ou les fichiers générés (ex : `generated/`) — ce sont des sorties de build.

## Intégrations externes et points d'attention

- Firebase (Auth, Firestore, Storage, Messaging) : config via `lib/firebase_options.dart` et `firebase.json`.
- Vérifier `functions/` pour la logique côté serveur (ex : hooks d'authentification ou webhooks).
- Google services : éviter de committer secrets; vérifier `android/app/google-services.json` et variables d'environnement pour production.

## Sécurité et production

- En production : supprimer les boutons de test et comptes de test exposés dans l'UI.
- Renforcer les règles Firestore avant déploiement (la logique de rôle est basée sur Firestore).

## Ce que l'agent IA peut faire immédiatement

- Localiser et modifier la `baseUrl` : [lib/services/api_service.dart](lib/services/api_service.dart)
- Ajouter une vue feature : créer dossier sous `lib/features/<new>/screens` et ajouter provider dans `lib/providers`
- Corriger un bug UI : éditer les fichiers dans `lib/features/...` et tester via `flutter run`

## Questions pour le mainteneur (à confirmer)

- Existe‑t‑il des scripts CI/CD (non présents) pour builds automatiques ?
- Quelles variables d'environnement secrets sont utilisées en production (où stockées) ?

Si une section est incomplète ou si vous voulez que j'ajoute des exemples de code précis, dites‑moi lesquels et j'itérerai.
