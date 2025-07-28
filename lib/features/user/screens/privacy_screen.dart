import 'package:flutter/material.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Politique de Confidentialité',
        showLogo: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text("""
**Politique de Confidentialité de l'Application GÉO**

**Dernière mise à jour : 28 juillet 2025**

Bienvenue sur GÉO. Votre vie privée est essentielle pour nous. Cette politique de confidentialité explique quelles données nous collectons, comment nous les utilisons et les protégeons.

**1. Collecte des données**

Nous collectons les informations suivantes :
- **Informations fournies par l’utilisateur :** Nom, prénom, adresse e-mail, numéro de téléphone, mot de passe, et autres informations nécessaires à la création de votre compte Client ou Marchand.
- **Données de localisation :** Avec votre permission, nous collectons votre position géographique pour vous fournir les services de géolocalisation.
- **Données d’utilisation :** Informations sur votre interaction avec l’application (pages visitées, fonctionnalités utilisées, etc.).
- **Données de transaction :** Historique des opérations effectuées via l’application.

**2. Utilisation des données**

Vos données sont utilisées pour :
- Fournir, gérer et améliorer nos services.
- Personnaliser votre expérience utilisateur.
- Communiquer avec vous concernant votre compte ou nos services.
- Assurer la sécurité de la plateforme et prévenir les fraudes.
- Analyser l’utilisation de l’application à des fins statistiques.

**3. Partage des données**

Nous ne partageons vos données personnelles avec des tiers que dans les cas suivants :
- **Avec les marchands :** Pour faciliter les transactions et la communication.
- **Pour des raisons légales :** Si la loi l’exige ou pour protéger nos droits.
- **Avec votre consentement :** Pour toute autre situation non décrite dans cette politique.

**4. Sécurité des données**

Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles pour protéger vos données contre l’accès non autorisé, la modification, la divulgation ou la destruction.

**5. Vos droits**

Conformément à la législation en vigueur, vous disposez des droits suivants :
- **Droit d’accès :** Vous pouvez demander une copie des données que nous détenons sur vous.
- **Droit de rectification :** Vous pouvez corriger les données inexactes ou incomplètes.
- **Droit à l’effacement (« droit à l’oubli ») :** Vous pouvez demander la suppression de vos données.
- **Droit à la limitation du traitement :** Vous pouvez demander de limiter l’utilisation de vos données.
- **Droit à la portabilité :** Vous pouvez recevoir vos données dans un format structuré et lisible par machine.

Pour exercer ces droits, veuillez nous contacter à [adresse e-mail de contact].

**6. Cookies et technologies similaires**

Nous utilisons des cookies et des technologies similaires pour améliorer votre expérience sur l’application.

**7. Modifications de cette politique**

Nous pouvons mettre à jour cette politique de confidentialité. Nous vous informerons de tout changement majeur via l’application ou par e-mail.

**8. Contact**

Pour toute question relative à cette politique de confidentialité, veuillez nous contacter à :
[Nom de l’entreprise]
[Adresse de l’entreprise]
[E-mail de contact]
        """),
      ),
    );
  }
}
