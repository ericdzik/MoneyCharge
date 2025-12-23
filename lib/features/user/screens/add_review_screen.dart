import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/constants/app_dimensions.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/core/widgets/custom_button.dart';
import 'package:locacharge/core/widgets/custom_text_field.dart';
import 'package:locacharge/models/review_model.dart';
import 'package:locacharge/providers/auth_provider.dart';

class AddReviewScreen extends StatefulWidget {
  final String merchantId;

  const AddReviewScreen({super.key, required this.merchantId});

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = context.read<AuthProvider>().appUserProfile;

    if (user == null) {
      if (mounted) {
        _showSnackBar('Vous devez être connecté pour laisser un avis.');
        setState(() => _isLoading = false);
      }
      return;
    }

    final review = Review(
      id: '',
      merchantId: widget.merchantId,
      userId: user.id,
      userName: user.name,
      userProfileImageUrl: user.profileImageUrl,
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await FirebaseFirestore.instance
          .collection('reviews')
          .add(review.toJson());

      if (mounted) {
        _showSnackBar('Avis ajouté avec succès !');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur lors de l\'ajout de l\'avis: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (isError) {
      SnackBarHelper.showError(context, message);
    } else {
      SnackBarHelper.showSuccess(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Laisser un avis',
        showLogo: false,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
                margin: const EdgeInsets.all(AppDimensions.paddingM),
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RatingSection(
                          rating: _rating,
                          onRatingChanged: (value) => setState(() => _rating = value),
                        ),
                        const SizedBox(height: AppDimensions.paddingL),
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
                        const SizedBox(height: AppDimensions.paddingL),
                        CustomButton(
                          text: _isLoading ? 'Envoi...' : 'Envoyer l\'avis',
                          onPressed: _isLoading ? null : _submitReview,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      );
    }
  }

class _RatingSection extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;

  const _RatingSection({
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votre note',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1.0;
            return IconButton(
              iconSize: 40,
              onPressed: () => onRatingChanged(starValue),
              icon: Icon(
                rating >= starValue ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
            );
          }),
        ),
        Center(
          child: Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}