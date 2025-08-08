import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Utilitaire pour créer et mettre en cache des icônes de marqueur personnalisées
class MarkerUtils {
  static BitmapDescriptor? _cachedGeoMarker;

  /// Retourne un BitmapDescriptor représentant un pin bleu avec le texte "Géo" en jaune
  /// Généré via Canvas pour éviter un asset externe et garder une bonne qualité.
  static Future<BitmapDescriptor> getGeoMarkerDescriptor({double size = 120}) async {
    if (_cachedGeoMarker != null) return _cachedGeoMarker!;

    final double width = size;
    final double height = size * 1.35; // un peu plus haut pour la pointe
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Fond transparent
    final Paint clearPaint = Paint()..color = Colors.transparent;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), clearPaint);

    // Couleurs
    const Color pinBlue = Color(0xFF1D4ED8); // Bleu
    const Color textYellow = Color(0xFFF59E0B); // Jaune

    // Dessin du pin (cercle + pointe)
    final double circleRadius = width * 0.35;
    final Offset circleCenter = Offset(width / 2, circleRadius + 8);
    final Paint pinPaint = Paint()..color = pinBlue;
    canvas.drawCircle(circleCenter, circleRadius, pinPaint);

    // Pointe triangulaire
    final Path pointer = Path()
      ..moveTo(width / 2 - circleRadius * 0.4, circleCenter.dy + circleRadius * 0.6)
      ..lineTo(width / 2 + circleRadius * 0.4, circleCenter.dy + circleRadius * 0.6)
      ..lineTo(width / 2, height - 8)
      ..close();
    canvas.drawPath(pointer, pinPaint);

    // Texte "Géo"
    final TextPainter textPainter = TextPainter(
      text: const TextSpan(
        text: 'Géo',
        style: TextStyle(
          color: textYellow,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);

    final Offset textOffset = Offset(
      (width - textPainter.width) / 2,
      circleCenter.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);

    final ui.Image img = await recorder.endRecording().toImage(width.toInt(), height.toInt());
    final ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List bytes = byteData!.buffer.asUint8List();

    _cachedGeoMarker = BitmapDescriptor.fromBytes(bytes);
    return _cachedGeoMarker!;
  }
}


