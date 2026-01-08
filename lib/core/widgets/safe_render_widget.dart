import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Widget wrapper qui aide à prévenir les erreurs de rendu OpenGL
class SafeRenderWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRenderError;

  const SafeRenderWidget({
    super.key,
    required this.child,
    this.onRenderError,
  });

  @override
  State<SafeRenderWidget> createState() => _SafeRenderWidgetState();
}

class _SafeRenderWidgetState extends State<SafeRenderWidget> {
  bool _isRendering = false;

  @override
  void initState() {
    super.initState();
    // Attendre que le widget soit complètement initialisé
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isRendering = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRendering) {
      // Afficher un placeholder pendant l'initialisation
      return Container(
        color: Colors.white,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return widget.child;
  }

  @override
  void dispose() {
    _isRendering = false;
    super.dispose();
  }
}