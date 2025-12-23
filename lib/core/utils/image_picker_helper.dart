import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Helper professionnel pour la sélection et le recadrage d'images
/// 
/// Centralise toute la logique de gestion d'images (picker + cropper)
/// pour éviter la duplication de code dans les écrans.
/// 
/// Usage:
/// ```dart
/// final file = await ImagePickerHelper.pickAndCropImage(
///   context: context,
///   source: ImageSource.gallery,
///   aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
/// );
/// if (file != null) {
///   // Utiliser l'image
/// }
/// ```
class ImagePickerHelper {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  static final ImagePicker _picker = ImagePicker();

  /// Sélectionne une image depuis la galerie ou la caméra et la recadre
  /// 
  /// [context] - BuildContext pour les dialogues
  /// [source] - Source de l'image (galerie ou caméra)
  /// [aspectRatio] - Ratio de recadrage (défaut: 1:1)
  /// [maxWidth] - Largeur maximale de l'image finale
  /// [maxHeight] - Hauteur maximale de l'image finale
  /// [imageQuality] - Qualité JPEG (0-100, défaut: 85)
  /// [cropStyle] - Style de recadrage (rectangle ou cercle)
  /// [compressFormat] - Format de compression de l'image
  /// 
  /// Retourne [File] si succès, [null] si annulé ou erreur
  static Future<File?> pickAndCropImage({
    required BuildContext context,
    required ImageSource source,
    CropAspectRatio aspectRatio = const CropAspectRatio(ratioX: 1, ratioY: 1),
    int? maxWidth,
    int? maxHeight,
    int imageQuality = 85,
    CropStyle cropStyle = CropStyle.rectangle,
    ImageCompressFormat compressFormat = ImageCompressFormat.jpg,
  }) async {
    try {
      // Étape 1: Sélection de l'image
      _logger.d('Sélection d\'image depuis: ${source.name}');
      
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile == null) {
        _logger.i('Sélection d\'image annulée par l\'utilisateur');
        return null;
      }

      _logger.d('Image sélectionnée: ${pickedFile.path}');

      // Étape 2: Recadrage de l'image
      final File imageFile = File(pickedFile.path);
      final File? croppedFile = await _cropImage(
        context: context,
        file: imageFile,
        aspectRatio: aspectRatio,
        cropStyle: cropStyle,
        compressFormat: compressFormat,
      );

      if (croppedFile == null) {
        _logger.i('Recadrage annulé par l\'utilisateur');
        return null;
      }

      _logger.i('✅ Image traitée avec succès: ${croppedFile.path}');
      return croppedFile;
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Erreur lors de la sélection/recadrage d\'image',
        error: e,
        stackTrace: stackTrace,
      );
      
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          'Impossible de traiter l\'image. Veuillez réessayer.',
        );
      }
      
      return null;
    }
  }

  /// Sélectionne et recadre une image de profil (format circulaire)
  /// 
  /// Raccourci pour profils utilisateurs avec paramètres optimisés
  static Future<File?> pickProfileImage({
    required BuildContext context,
    required ImageSource source,
  }) async {
    return pickAndCropImage(
      context: context,
      source: source,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      cropStyle: CropStyle.circle,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 90,
    );
  }

  /// Sélectionne et recadre une image de couverture (format 16:9)
  /// 
  /// Raccourci pour images de couverture avec paramètres optimisés
  static Future<File?> pickCoverImage({
    required BuildContext context,
    required ImageSource source,
  }) async {
    return pickAndCropImage(
      context: context,
      source: source,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      cropStyle: CropStyle.rectangle,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
  }

  /// Sélectionne plusieurs images (sans recadrage)
  /// 
  /// Utile pour galeries ou uploads multiples
  static Future<List<File>> pickMultipleImages({
    required BuildContext context,
    int? maxImages,
    int imageQuality = 85,
  }) async {
    try {
      _logger.d('Sélection multiple d\'images');
      
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: imageQuality,
      );

      if (pickedFiles.isEmpty) {
        _logger.i('Aucune image sélectionnée');
        return [];
      }

      // Limiter le nombre d'images si spécifié
      final List<XFile> limitedFiles = maxImages != null && pickedFiles.length > maxImages
          ? pickedFiles.take(maxImages).toList()
          : pickedFiles;

      _logger.i('${limitedFiles.length} image(s) sélectionnée(s)');

      return limitedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Erreur lors de la sélection multiple d\'images',
        error: e,
        stackTrace: stackTrace,
      );
      
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          'Impossible de sélectionner les images. Veuillez réessayer.',
        );
      }
      
      return [];
    }
  }

  /// Affiche un dialogue pour choisir la source (caméra ou galerie)
  /// 
  /// Retourne [ImageSource] si sélectionné, [null] si annulé
  static Future<ImageSource?> showImageSourceDialog(
    BuildContext context,
  ) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Choisir la source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () => Navigator.pop(dialogContext, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Caméra'),
                onTap: () => Navigator.pop(dialogContext, ImageSource.camera),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  /// Workflow complet: Dialogue source + Sélection + Recadrage
  /// 
  /// Simplifie l'usage en une seule méthode
  static Future<File?> pickImageWithDialog({
    required BuildContext context,
    CropAspectRatio aspectRatio = const CropAspectRatio(ratioX: 1, ratioY: 1),
    CropStyle cropStyle = CropStyle.rectangle,
  }) async {
    final ImageSource? source = await showImageSourceDialog(context);
    
    if (source == null || !context.mounted) {
      return null;
    }

    return pickAndCropImage(
      context: context,
      source: source,
      aspectRatio: aspectRatio,
      cropStyle: cropStyle,
    );
  }

  // ==================== MÉTHODES PRIVÉES ====================

  /// Recadre une image avec ImageCropper
  static Future<File?> _cropImage({
    required BuildContext context,
    required File file,
    required CropAspectRatio aspectRatio,
    required CropStyle cropStyle,
    required ImageCompressFormat compressFormat,
  }) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: aspectRatio,
        compressFormat: compressFormat,
        compressQuality: 85,
        uiSettings: [
          // Configuration Android
          AndroidUiSettings(
            toolbarTitle: 'Recadrer l\'image',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true,
            cropStyle: cropStyle,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          // Configuration iOS
          IOSUiSettings(
            title: 'Recadrer l\'image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          // Configuration Web
          WebUiSettings(
            context: context,
          ),
        ],
      );

      if (croppedFile == null) {
        return null;
      }

      return File(croppedFile.path);
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Erreur lors du recadrage',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Affiche un SnackBar d'erreur
  static void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Valide si un fichier est une image valide
  static bool isValidImageFile(File file) {
    final String extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// Obtient la taille d'une image en octets
  static Future<int> getImageSize(File file) async {
    return await file.length();
  }

  /// Formate la taille d'un fichier en string lisible
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
