import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe_model.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);

    // Filtrer les recettes de l'utilisateur connecté
    final userRecipes = recipeProvider.recipes
        .where((recipe) => recipe.authorId == authProvider.currentUser?.userId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du profil
            _buildProfileHeader(authProvider),
            SizedBox(height: 24),

            // Statistiques
            _buildStatsSection(userRecipes.length),
            SizedBox(height: 24),

            // Ligne séparatrice
            Divider(thickness: 1),
            SizedBox(height: 24),

            // Account Settings
            _buildAccountSettings(),
            SizedBox(height: 24),

            // Bouton de déconnexion
            _buildLogoutButton(authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider) {
    return Center(
      child: Column(
        children: [
          // Avatar avec initiales
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getInitials(
                  authProvider.currentUser?.displayName ??
                      authProvider.currentUser?.email ??
                      '',
                ),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            authProvider.currentUser?.displayName ??
                authProvider.currentUser?.email?.split('@')[0] ??
                'Utilisateur',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            authProvider.currentUser?.email ?? '',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Member since January 2024', // À adapter avec la date réelle d'inscription
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(int recipeCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(recipeCount.toString(), 'Recipes Shared'),
        _buildStatItem(
          '8',
          'Favorites',
        ), // À implémenter avec les vrais favoris
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.person,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
        ),
        SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.settings,
          title: 'App Settings',
          subtitle: 'Notifications and preferences',
        ),
        SizedBox(height: 16),
        _buildSettingsItem(
          icon: Icons.share,
          title: 'Share App',
          subtitle: 'Tell friends about Haitian Recipes',
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Implémenter les actions pour chaque élément
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrange, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          await authProvider.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        icon: Icon(Icons.logout, size: 20),
        label: Text('Logout'),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';

    List<String> nameParts = name.split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    } else {
      return (nameParts[0][0] + nameParts[nameParts.length - 1][0])
          .toUpperCase();
    }
  }
}
