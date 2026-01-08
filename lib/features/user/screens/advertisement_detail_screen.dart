import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:locacharge/core/common.dart';
import 'package:locacharge/features/user/models/advertisement_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class AdvertisementDetailScreen extends StatelessWidget {
  final Advertisement advertisement;

  const AdvertisementDetailScreen({
    Key? key,
    required this.advertisement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Image principale en plein écran
          Expanded(
            child: Container(
              width: double.infinity,
              child: InteractiveViewer(
                child: Image.network(
                  advertisement.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Image non disponible',
                            style: AppTextStyles.body1.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Informations de la publicité en bas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusL),
                topRight: Radius.circular(AppDimensions.radiusL),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge sponsorisé
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    'Sponsorisé',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppDimensions.paddingM),
                
                // Titre
                Text(
                  advertisement.title,
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.paddingS),
                
                // Description
                Text(
                  advertisement.description,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: AppDimensions.paddingL),
                
                // Espace pour le safe area
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Options de publicité',
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              context,
              icon: Icons.info_outline,
              title: 'Pourquoi cette pub ?',
              subtitle: 'Comprendre pourquoi vous voyez cette publicité',
              onTap: () {
                Navigator.pop(context);
                _showTargetingExplanation(context);
              },
            ),
            _buildOptionTile(
              context,
              icon: Icons.report_outlined,
              title: 'Signaler cette publicité',
              subtitle: 'Signaler un contenu inapproprié',
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context);
              },
            ),
            _buildOptionTile(
              context,
              icon: Icons.download,
              title: 'Télécharger l\'image',
              subtitle: 'Sauvegarder l\'image dans la galerie',
              onTap: () {
                Navigator.pop(context);
                _downloadImage(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption.copyWith(color: Colors.grey.shade600),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showTargetingExplanation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pourquoi cette publicité ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cette publicité vous est montrée pour les raisons suivantes :',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: 16),
            _buildExplanationItem(
              icon: Icons.location_on,
              text: advertisement.targetLocation != null
                  ? 'Basée sur votre localisation'
                  : 'Publicité générale',
            ),
            if (advertisement.targetingCriteria.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildExplanationItem(
                icon: Icons.person,
                text: 'Basée sur vos préférences',
              ),
            ],
            const SizedBox(height: 8),
            _buildExplanationItem(
              icon: Icons.schedule,
              text: 'Publicité active et récente',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler cette publicité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pourquoi souhaitez-vous signaler cette publicité ?',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: 16),
            ...['Contenu inapproprié', 'Publicité trompeuse', 'Spam', 'Autre']
                .map((reason) => ListTile(
                      title: Text(reason),
                      onTap: () {
                        Navigator.pop(context);
                        _reportAd(context, reason);
                      },
                      contentPadding: EdgeInsets.zero,
                    )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _reportAd(BuildContext context, String reason) {
    SnackBarHelper.showSuccess(
      context,
      'Publicité signalée. Merci pour votre retour.',
    );
  }

  Future<void> _downloadImage(BuildContext context) async {
    bool isDialogOpen = false;
    
    try {
      // Demander la permission de stockage
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        SnackBarHelper.showError(
          context,
          'Permission de stockage requise pour télécharger l\'image',
        );
        return;
      }

      // Afficher un indicateur de chargement
      isDialogOpen = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Téléchargement en cours...'),
            ],
          ),
        ),
      );

      // Obtenir le répertoire de téléchargement
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        if (isDialogOpen) {
          Navigator.pop(context);
          isDialogOpen = false;
        }
        SnackBarHelper.showError(
          context,
          'Impossible d\'accéder au répertoire de téléchargement',
        );
        return;
      }

      // Générer un nom de fichier unique
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'pub_${advertisement.id}_$timestamp.jpg';
      final filePath = '${directory.path}/$fileName';

      // Télécharger l'image
      final response = await http.get(Uri.parse(advertisement.imageUrl));
      
      if (response.statusCode == 200) {
        // Écrire l'image dans le fichier
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        // Fermer le dialog de chargement
        if (isDialogOpen) {
          Navigator.pop(context);
          isDialogOpen = false;
        }

        // Afficher un message de succès
        SnackBarHelper.showSuccess(
          context,
          'Image téléchargée avec succès dans $fileName',
        );
      } else {
        if (isDialogOpen) {
          Navigator.pop(context);
          isDialogOpen = false;
        }
        SnackBarHelper.showError(
          context,
          'Erreur lors du téléchargement: ${response.statusCode}',
        );
      }

    } catch (e) {
      // Fermer le dialog de chargement s'il est ouvert
      if (isDialogOpen) {
        try {
          Navigator.pop(context);
        } catch (_) {
          // Ignorer si le dialog n'est pas ouvert
        }
      }
      
      SnackBarHelper.showError(
        context,
        'Erreur lors du téléchargement: ${e.toString()}',
      );
    }
  }
}