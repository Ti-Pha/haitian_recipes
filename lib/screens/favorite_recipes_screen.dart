import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';

class FavoriteRecipesScreen extends StatelessWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);

    if (authProvider.currentUser == null) {
      return Center(
        child: Text(
          'Login to see your favorite recipes.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    final favoriteRecipeIds = authProvider.currentUser!.favoriteRecipes;
    final favoriteRecipes = recipeProvider.recipes
        .where((recipe) => favoriteRecipeIds.contains(recipe.recipeId))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('My Favorite Recipes')),
      body: favoriteRecipes.isEmpty
          ? Center(
              child: Text(
                'No favorite recipe yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: favoriteRecipes.length,
              itemBuilder: (context, index) {
                return RecipeCard(recipe: favoriteRecipes[index]);
              },
            ),
    );
  }
}
