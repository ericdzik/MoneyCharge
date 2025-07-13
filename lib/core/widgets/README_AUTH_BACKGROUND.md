# Widget AuthBackgroundWidget

Ce widget fournit un background uniforme pour tous les écrans d'authentification de l'application LocaCharge.

## Utilisation

### Import
```dart
import '../../../core/widgets/auth_background_widget.dart';
```

### Utilisation basique
```dart
@override
Widget build(BuildContext context) {
  return AuthBackgroundWidget(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Mon Écran'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Votre contenu ici
            ],
          ),
        ),
      ),
    ),
  );
}
```

### Options disponibles

#### AuthBackgroundWidget
- `child` (requis) : Le widget enfant à afficher
- `showGradient` (optionnel) : Afficher le gradient par défaut (défaut: `true`)
- `overlayColor` (optionnel) : Couleur d'overlay personnalisée (utilisé si `showGradient` est `false`)

#### CustomAuthBackgroundWidget
- `child` (requis) : Le widget enfant à afficher
- `opacity` (optionnel) : Opacité de l'image de background
- `blendMode` (optionnel) : Mode de fusion pour l'effet de couleur
- `alignment` (optionnel) : Alignement de l'image
- `fit` (optionnel) : Mode d'ajustement de l'image

## Écrans modifiés

Les écrans suivants utilisent maintenant le widget `AuthBackgroundWidget` :

1. **user_login_screen.dart** - Écran de connexion utilisateur
2. **user_register_screen.dart** - Écran d'inscription utilisateur
3. **forgot_password_screen.dart** - Écran de mot de passe oublié
4. **merchant_register_screen.dart** - Écran d'inscription marchand

## Image utilisée

Le widget utilise l'image `assets/splash/25.png` comme background par défaut.

## Avantages

- **Uniformité** : Tous les écrans d'authentification ont le même background
- **Maintenabilité** : Un seul endroit pour modifier le background
- **Flexibilité** : Options de personnalisation disponibles
- **Performance** : Optimisé pour les performances

## Exemples d'utilisation

Voir le fichier `auth_background_example.dart` pour des exemples complets d'utilisation.

### Exemple avec gradient personnalisé
```dart
AuthBackgroundWidget(
  showGradient: false,
  overlayColor: Colors.black.withOpacity(0.5),
  child: Scaffold(
    // Votre contenu
  ),
)
```

### Exemple avec options avancées
```dart
CustomAuthBackgroundWidget(
  opacity: 0.8,
  fit: BoxFit.cover,
  child: Scaffold(
    // Votre contenu
  ),
)
``` 