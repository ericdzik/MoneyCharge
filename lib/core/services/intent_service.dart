import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:locacharge/core/config/phone_config.dart';

/// Service pour gérer les intents Android de manière plus directe
class IntentService {
  static const MethodChannel _channel = MethodChannel('com.locacharge/intents');

  /// Essaie de passer un appel téléphonique en utilisant les intents Android natifs
  static Future<bool> makePhoneCallNative(String phoneNumber) async {
    if (kIsWeb || !Platform.isAndroid) {
      return false;
    }

    try {
      // Utiliser la configuration pour nettoyer le numéro
      String cleanNumber = PhoneConfig.cleanPhoneNumber(phoneNumber);
      
      if (cleanNumber.isEmpty) {
        return false;
      }

      print('[IntentService] Attempting native phone call: $cleanNumber');
      
      final bool result = await _channel.invokeMethod('makePhoneCall', {
        'phoneNumber': cleanNumber,
      });
      
      print('[IntentService] Native phone call result: $result');
      return result;
    } on PlatformException catch (e) {
      print('[IntentService] Platform exception: ${e.message}');
      return false;
    } catch (e) {
      print('[IntentService] Error: $e');
      return false;
    }
  }

  /// Ouvre l'application de téléphone avec le numéro pré-rempli (ACTION_DIAL)
  static Future<bool> openDialer(String phoneNumber) async {
    if (kIsWeb || !Platform.isAndroid) {
      return false;
    }

    try {
      String cleanNumber = PhoneConfig.cleanPhoneNumber(phoneNumber);
      
      if (cleanNumber.isEmpty) {
        return false;
      }

      print('[IntentService] Attempting to open dialer: $cleanNumber');
      
      final bool result = await _channel.invokeMethod('openDialer', {
        'phoneNumber': cleanNumber,
      });
      
      print('[IntentService] Open dialer result: $result');
      return result;
    } on PlatformException catch (e) {
      print('[IntentService] Platform exception: ${e.message}');
      return false;
    } catch (e) {
      print('[IntentService] Error: $e');
      return false;
    }
  }

  /// Vérifie si une application de téléphone est disponible
  static Future<bool> isPhoneAppAvailable() async {
    if (kIsWeb || !Platform.isAndroid) {
      return false;
    }

    try {
      final bool result = await _channel.invokeMethod('isPhoneAppAvailable');
      print('[IntentService] Phone app available: $result');
      return result;
    } on PlatformException catch (e) {
      print('[IntentService] Platform exception: ${e.message}');
      return false;
    } catch (e) {
      print('[IntentService] Error: $e');
      return false;
    }
  }
}