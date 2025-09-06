import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe_model.dart';
import '../widgets/recipe_card.dart';
import 'add_recipe_screen.dart';
import 'profil_screen.dart'; // Import ajouté

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false).loadRecipes();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Haitian Recipes',
          style: TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.deepOrange),
            onPressed: () async {
              await authProvider.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildHomeContent(recipeProvider)
          : _buildOtherTabs(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeContent(RecipeProvider recipeProvider) {
    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Q Search recipes...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Liste des recettes
        Expanded(
          child: recipeProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : recipeProvider.recipes.isEmpty
              ? Center(
                  child: Text(
                    'Aucune recette disponible.\nSoyez le premier à partager une recette!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  // padding: EdgeInsets.all(16.0), // 👈 Suppression de ce padding
                  padding: EdgeInsets
                      .zero, // 👈 Remplacez-le par EdgeInsets.zero si nécessaire
                  itemCount: recipeProvider.recipes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      // 👈 Ajout d'un Padding autour de chaque élément
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: RecipeCard(recipe: recipeProvider.recipes[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOtherTabs() {
    switch (_selectedIndex) {
      case 1: // Favorites
        return Center(child: Text('Favorites - À implémenter'));
      case 2: // Add
        return AddRecipeScreen();
      case 3: // Profile
        return ProfileScreen(); // Modifié pour afficher l'écran de profil
      default:
        return _buildHomeContent(Provider.of<RecipeProvider>(context));
    }
  }
}
