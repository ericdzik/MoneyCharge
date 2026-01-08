import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locacharge/core/common.dart';
import 'package:locacharge/services/location_service.dart';
import 'package:locacharge/core/services/intent_service.dart';

/// Helper pour gérer les appels téléphoniques avec feedback utilisateur
class PhoneCallHelper {
  /// Tente de passer un appel téléphonique avec feedback utilisateur
  static Future<void> makePhoneCallWithFeedback(
    BuildContext context,
    String phoneNumber,
    String merchantName,
  ) async {
    if (!context.mounted) return;

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final locationService = LocationService();
      bool success = await locationService.makePhoneCall(phoneNumber);
      
      // Fermer l'indicateur de chargement
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (success) {
        // Succès - pas besoin de message, l'appel est en cours
        return;
      }

      // Échec - proposer des alternatives
      if (context.mounted) {
        await _showPhoneCallFailedDialog(context, phoneNumber, merchantName);
      }
    } catch (e) {
      // Fermer l'indicateur de chargement
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Afficher l'erreur
      if (context.mounted) {
        await _showPhoneCallErrorDialog(context, phoneNumber, merchantName, e.toString());
      }
    }
  }

  static Future<void> _showPhoneCallFailedDialog(
    BuildContext context,
    String phoneNumber,
    String merchantName,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appel impossible'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Impossible de passer l\'appel vers $merchantName.'),
            const SizedBox(height: 16),
            const Text('Vous pouvez :'),
            const SizedBox(height: 8),
            Text('• Composer manuellement : $phoneNumber'),
            const Text('• Vérifier qu\'une application de téléphone est installée'),
            const Text('• Essayer depuis les paramètres de votre téléphone'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _copyPhoneNumber(context, phoneNumber);
            },
            child: const Text('Copier le numéro'),
          ),
        ],
      ),
    );
  }

  static Future<void> _showPhoneCallErrorDialog(
    BuildContext context,
    String phoneNumber,
    String merchantName,
    String error,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur d\'appel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Une erreur s\'est produite lors de l\'appel vers $merchantName.'),
            const SizedBox(height: 16),
            Text('Numéro : $phoneNumber'),
            const SizedBox(height: 8),
            Text('Erreur : $error', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _copyPhoneNumber(context, phoneNumber);
            },
            child: const Text('Copier le numéro'),
          ),
        ],
      ),
    );
  }

  static Future<void> _copyPhoneNumber(BuildContext context, String phoneNumber) async {
    try {
      await Clipboard.setData(ClipboardData(text: phoneNumber));
      if (context.mounted) {
        SnackBarHelper.showSuccess(
          context,
          'Numéro copié : $phoneNumber',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.showError(
          context,
          'Impossible de copier le numéro',
        );
      }
    }
  }

  /// Vérifie si les appels téléphoniques sont disponibles sur cet appareil
  static Future<bool> isPhoneCallAvailable() async {
    try {
      return await IntentService.isPhoneAppAvailable();
    } catch (e) {
      return false;
    }
  }
}