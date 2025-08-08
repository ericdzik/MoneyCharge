import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/review_model.dart'; // Correction de l'import
import '../../../providers/auth_provider.dart';

class AddReviewScreen extends StatefulWidget {
  final String merchantId;

  const AddReviewScreen({super.key, required this.merchantId});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 3.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.appUserProfile;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être connecté pour laisser un avis.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final review = Review(
        id: '', // L'ID sera généré par Firestore
        merchantId: widget.merchantId, // Ajout de l'ID du marchand
        userId: user.id,
        userName: user.name,
        userProfileImageUrl: user.profileImageUrl, // Ajout de l'image de profil
        rating: _rating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      try {
        // Remplacer ApiService par un appel direct à Firestore
        await FirebaseFirestore.instance.collection('reviews').add(review.toJson());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Avis ajouté avec succès !')),
          );
          Navigator.pop(context, true); // Indique que l'avis a été ajouté
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'ajout de l\'avis: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laisser un avis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Votre note',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _rating,
                onChanged: (newRating) {
                  setState(() {
                    _rating = newRating;
                  });
                },
                divisions: 4,
                min: 1,
                max: 5,
                label: _rating.toString(),
              ),
              Center(
                child: Text(
                  _rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _commentController,
                labelText: 'Votre commentaire',
                hintText: 'Partagez votre expérience...',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un commentaire.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isLoading ? 'Envoi...' : 'Envoyer l\'avis',
                onPressed: _isLoading ? null : _submitReview,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
