// lib/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import 'dart:io';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    // 👇 AJOUTEZ CES LIGNES POUR DÉBOGUER
    print('Current User ID: ${authProvider.currentUser?.userId}');
    print('Recipe Author ID: ${recipe.authorId}');
    print(
      'Is Current User the Author? ${authProvider.currentUser?.userId == recipe.authorId}',
    );

    final isAuthor =
        authProvider.currentUser != null &&
        authProvider.currentUser!.userId == recipe.authorId;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails de la recette',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (isAuthor)
            PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'edit') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditRecipeScreen(recipe: recipe),
                    ),
                  );
                } else if (result == 'delete') {
                  _confirmDelete(context, recipe, recipeProvider);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.deepOrange),
                      SizedBox(width: 8),
                      Text('Modifier'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'recipe-image-${recipe.recipeId}',
              child: _buildRecipeImage(recipe.localImagePath),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Par ${recipe.authorName}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.deepOrange),
                  SizedBox(height: 16),
                  Text(
                    'Ingrédients:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: recipe.ingredients
                        .map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              '• $ingredient',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.deepOrange),
                  SizedBox(height: 16),
                  Text(
                    'Instructions:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    recipe.instructions,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage(String? localImagePath) {
    if (localImagePath != null && localImagePath.isNotEmpty) {
      final imageFile = File(localImagePath);
      if (imageFile.existsSync()) {
        return Image.file(
          imageFile,
          width: double.infinity,
          height: 280,
          fit: BoxFit.cover,
        );
      }
    }
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Center(
        child: Icon(Icons.fastfood, size: 70, color: Colors.grey[600]),
      ),
    );
  }

  void _shareRecipe(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fonctionnalité de partage à implémenter')),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    RecipeModel recipe,
    RecipeProvider recipeProvider,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer cette recette? Cette action est irréversible.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              onPressed: () {
                recipeProvider.deleteRecipe(recipe);
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
