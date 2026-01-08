import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/core/common.dart';
import 'package:locacharge/features/user/models/content_item_model.dart';
import 'package:locacharge/features/user/services/feed_manager.dart';
import 'package:locacharge/providers/merchant_provider.dart';

class MerchantDebugWidget extends StatelessWidget {
  final FeedManager feedManager;

  const MerchantDebugWidget({
    Key? key,
    required this.feedManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MerchantProvider>(
      builder: (context, merchantProvider, child) {
        final contentItems = feedManager.contentItems;
        final merchants = contentItems.whereType<MerchantContentItem>().toList();
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔍 DIAGNOSTIC MARCHANDS',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 8),
              
              Text('📊 MerchantProvider:'),
              Text('  - Chargement: ${merchantProvider.isLoading}'),
              Text('  - Erreur: ${merchantProvider.error ?? "Aucune"}'),
              Text('  - Marchands Firebase: ${merchantProvider.merchants.length}'),
              
              const SizedBox(height: 8),
              Text('📱 FeedManager:'),
              Text('  - Chargement: ${feedManager.isLoading}'),
              Text('  - Erreur: ${feedManager.errorMessage ?? "Aucune"}'),
              Text('  - Total éléments: ${contentItems.length}'),
              Text('  - Marchands dans feed: ${merchants.length}'),
              
              const SizedBox(height: 8),
              if (merchantProvider.merchants.isNotEmpty) ...[
                Text('✅ Échantillon Firebase:', style: TextStyle(color: Colors.green)),
                ...merchantProvider.merchants.take(2).map((m) => 
                  Text('  • ${m.name} (${(m.isVerified ?? false) ? "✓" : "✗"})', style: TextStyle(fontSize: 12))
                ),
              ] else ...[
                Text('❌ Aucun marchand Firebase', style: TextStyle(color: Colors.red)),
              ],
              
              const SizedBox(height: 8),
              if (merchants.isNotEmpty) ...[
                Text('✅ Marchands feed:', style: TextStyle(color: Colors.green)),
                ...merchants.take(2).map((m) => 
                  Text('  • ${m.name} (${m.distanceKm?.toStringAsFixed(1) ?? "?"}km)', style: TextStyle(fontSize: 12))
                ),
              ] else ...[
                Text('❌ Aucun marchand dans feed', style: TextStyle(color: Colors.red)),
              ],
              
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  print('🔄 Rechargement forcé...');
                  merchantProvider.refreshMerchants();
                  await Future.delayed(Duration(seconds: 2));
                  await feedManager.refreshContent();
                },
                child: Text('🔄 Forcer Rechargement'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  print('🧪 Test direct MerchantProvider...');
                  print('Merchants count: ${merchantProvider.merchants.length}');
                  print('Is loading: ${merchantProvider.isLoading}');
                  print('Error: ${merchantProvider.error}');
                  
                  if (merchantProvider.merchants.isEmpty) {
                    print('Calling listenToMerchants...');
                    merchantProvider.listenToMerchants();
                  } else {
                    for (var merchant in merchantProvider.merchants.take(3)) {
                      print('Merchant: ${merchant.name} - Verified: ${merchant.isVerified ?? false} - Lat: ${merchant.latitude}, Lng: ${merchant.longitude}');
                    }
                  }
                },
                child: Text('🧪 Test Provider'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
        );
      },
    );
  }
}