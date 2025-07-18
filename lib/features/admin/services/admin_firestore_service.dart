import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locacharge/features/user/models/user_model.dart';
import '../models/admin_model.dart';
// Import User model if you have one for 'role' == 'user'
// For now, we'll count documents directly.

class AdminFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AdminModel?> getAdminProfile(String adminId) async {
    try {
      final docSnapshot =
          await _firestore.collection('users').doc(adminId).get();
      if (docSnapshot.exists && docSnapshot.data()?['role'] == 'admin') {
        return AdminModel.fromFirestore(
            docSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      }
      return null;
    } catch (e) {
      print('Error fetching admin profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPlatformStatistics() async {
    try {
      // Fetch user counts, merchant details, and transaction aggregates in parallel
      final usersCountFuture =
          _firestore.collection('users').where('role', isEqualTo: 'user').count().get();
      final merchantsQueryFuture =
          _firestore.collection('users').where('role', isEqualTo: 'merchant').get();
      final transactionsQueryFuture = _firestore
          .collection('transactions')
          .where('status', isEqualTo: 'completed') // Consider only completed transactions for revenue and count
          .get();

      final usersCountSnapshot = await usersCountFuture;
      final merchantsSnapshot = await merchantsQueryFuture;
      final transactionsSnapshot = await transactionsQueryFuture;

      int totalUsers = usersCountSnapshot.count ?? 0;
      int totalMerchants = merchantsSnapshot.size;
      int activeMerchants = 0;
      int pendingVerifications = 0;

      for (var doc in merchantsSnapshot.docs) {
        final data = doc.data();
        if (data['isActive'] == true) {
          activeMerchants++;
        }
        if (data['isVerified'] == false) { // Assuming 'isVerified' exists and is a boolean
          pendingVerifications++;
        }
      }

      int totalCompletedTransactions = transactionsSnapshot.size;
      double totalRevenueFromTransactions = 0.0;

      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data();
        // Assuming 'amount' field holds the transaction value for revenue calculation
        totalRevenueFromTransactions += (data['amount'] as num?)?.toDouble() ?? 0.0;
      }

      // Placeholders for stats that might require Cloud Functions or more complex queries/external APIs
      // TODO: Investigate actual sources or implement Cloud Functions for:
      // - averageTransactionsPerDay (could be complex client-side)
      // - customerSatisfaction (likely needs a feedback system/collection)
      // - totalChargerRentals (needs a 'rentals' collection or specific transaction type)
      final int averageTransactionsPerDay = 0; // Placeholder
      final double customerSatisfaction = 0.0; // Placeholder, e.g. 0.0 to 1.0
      final int totalChargerRentals = 0; // Placeholder

      return {
        'totalUsers': totalUsers,
        'totalMerchants': totalMerchants,
        'activeMerchants': activeMerchants,
        'pendingVerifications': pendingVerifications,
        'totalRevenue': totalRevenueFromTransactions,
        'totalTransactions': totalCompletedTransactions,
        'averageTransactionsPerDay': averageTransactionsPerDay,
        'customerSatisfaction': customerSatisfaction,
        'totalChargerRentals': totalChargerRentals,
      };
    } catch (e) {
      print('Error fetching platform statistics: $e');
      // Return zeroed/default stats on error to prevent UI crashes
      return {
        'totalUsers': 0,
        'totalMerchants': 0,
        'activeMerchants': 0,
        'pendingVerifications': 0,
        'totalRevenue': 0.0,
        'totalTransactions': 0,
        'averageTransactionsPerDay': 0,
        'customerSatisfaction': 0.0,
        'totalChargerRentals': 0,
      };
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      return querySnapshot.docs
          .map((doc) => User.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print('Error fetching all users: $e');
      rethrow;
    }
  }

  Future<void> updateUserSuspension(String userId, bool isSuspended) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isSuspended': isSuspended,
      });
    } catch (e) {
      print('Error updating user suspension: $e');
      rethrow;
    }
  }
}
