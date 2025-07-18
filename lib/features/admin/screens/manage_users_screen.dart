import 'package:flutter/material.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/features/admin/services/admin_firestore_service.dart';
import 'package:locacharge/features/admin/widgets/user_table_widget.dart';
import 'package:locacharge/providers/auth_provider.dart' as auth;
import 'package:provider/provider.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({Key? key}) : super(key: key);

  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final AdminFirestoreService _adminService = AdminFirestoreService();
  late Future<List<auth.User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _adminService.getAllUsers();
  }

  void _reloadUsers() {
    setState(() {
      _usersFuture = _adminService.getAllUsers();
    });
  }

  void _handleSuspendUser(auth.User user) {
    // La logique de suspension sera ajoutée ici
    // Pour l'instant, on peut afficher un dialogue de confirmation
    final newStatus = !(user.isSuspended);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${newStatus ? "Suspendre" : "Réactiver"} cet utilisateur ?'),
        content: Text('Voulez-vous vraiment ${newStatus ? "suspendre" : "réactiver"} ${user.name} ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: Text(newStatus ? 'Suspendre' : 'Réactiver'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Appel à une méthode de service qui n'existe pas encore
              await _adminService.updateUserSuspension(user.id, newStatus);
              _reloadUsers();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _handleViewDetails(auth.User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Détails de ${user.name}'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('ID: ${user.id}'),
              Text('Email: ${user.email}'),
              Text('Téléphone: ${user.phone ?? 'Non fourni'}'),
              Text('Inscrit le: ${user.createdAt?.toLocal()}'),
              Text('Dernière connexion: ${user.lastLoginAt?.toLocal()}'),
              Text('Statut: ${user.isSuspended ? "Suspendu" : "Actif"}'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Fermer'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Gestion des Utilisateurs',
        showLogo: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadUsers,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: FutureBuilder<List<auth.User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun utilisateur trouvé.'));
          }

          final users = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: UserTableWidget(
              users: users,
              onSuspend: _handleSuspendUser,
              onViewDetails: _handleViewDetails,
            ),
          );
        },
      ),
    );
  }
}
