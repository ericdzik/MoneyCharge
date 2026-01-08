import 'package:flutter/material.dart';
import 'package:locacharge/core/widgets/phone_call_helper.dart';
import 'package:locacharge/core/constants/app_colors.dart';

/// Widget de test pour les appels téléphoniques (à utiliser en développement)
class PhoneTestWidget extends StatefulWidget {
  const PhoneTestWidget({super.key});

  @override
  State<PhoneTestWidget> createState() => _PhoneTestWidgetState();
}

class _PhoneTestWidgetState extends State<PhoneTestWidget> {
  final TextEditingController _phoneController = TextEditingController(text: '93047800');
  bool _isPhoneAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkPhoneAvailability();
  }

  Future<void> _checkPhoneAvailability() async {
    final available = await PhoneCallHelper.isPhoneCallAvailable();
    if (mounted) {
      setState(() {
        _isPhoneAvailable = available;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.phone,
                  color: _isPhoneAvailable ? AppColors.primary : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Test d\'appel téléphonique',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Application de téléphone : ${_isPhoneAvailable ? "Disponible" : "Non disponible"}',
              style: TextStyle(
                color: _isPhoneAvailable ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                hintText: 'Ex: 93047800',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isPhoneAvailable ? _testPhoneCall : null,
                    icon: const Icon(Icons.phone),
                    label: const Text('Tester l\'appel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _checkPhoneAvailability,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Vérifier à nouveau',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testPhoneCall() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un numéro de téléphone')),
      );
      return;
    }

    await PhoneCallHelper.makePhoneCallWithFeedback(
      context,
      phoneNumber,
      'Test Marchand',
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}