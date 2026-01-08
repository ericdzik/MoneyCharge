import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Helper pour gérer les problèmes de rendu OpenGL
class RenderHelper {
  /// Exécute une navigation de manière sécurisée pour éviter les erreurs OpenGL
  static Future<T?> safeNavigate<T extends Object?>(
    BuildContext context,
    Widget Function() builder, {
    bool replace = false,
  }) async {
    if (!context.mounted) return null;
    
    // Attendre que le frame actuel soit terminé
    await SchedulerBinding.instance.endOfFrame;
    
    if (!context.mounted) return null;
    
    if (replace) {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => builder()),
      );
    } else {
      return Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => builder()),
      );
    }
  }

  /// Navigation nommée sécurisée
  static Future<T?> safeNavigateNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool replace = false,
  }) async {
    if (!context.mounted) return null;
    
    // Attendre que le frame actuel soit terminé
    await SchedulerBinding.instance.endOfFrame;
    
    if (!context.mounted) return null;
    
    if (replace) {
      return Navigator.pushReplacementNamed(
        context,
        routeName,
        arguments: arguments,
      );
    } else {
      return Navigator.pushNamed(
        context,
        routeName,
        arguments: arguments,
      );
    }
  }

  /// Pop sécurisé
  static void safePop<T extends Object?>(
    BuildContext context, [
    T? result,
  ]) {
    if (!context.mounted) return;
    
    // Utiliser addPostFrameCallback pour éviter les conflits de rendu
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context, result);
      }
    });
  }

  /// Vérifie si le widget est toujours monté avant d'exécuter une action
  static void safeSetState(
    State state,
    VoidCallback callback,
  ) {
    if (state.mounted) {
      // Utiliser addPostFrameCallback pour éviter les conflits de rendu
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (state.mounted) {
          // ignore: invalid_use_of_protected_member
          state.setState(callback);
        }
      });
    }
  }

  /// Exécute une action après le prochain frame pour éviter les conflits de rendu
  static void executeAfterFrame(VoidCallback callback) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  /// Vérifie si le rendu est en cours
  static bool get isRenderingFrame {
    return SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle;
  }
}