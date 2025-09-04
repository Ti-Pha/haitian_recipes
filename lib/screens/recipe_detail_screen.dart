import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/auth_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la recette'),
        actions: [
          // Bouton favoris (à implémenter ultérieurement)
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Implémenter l'ajout aux favoris
            },
          ),
          // Bouton partage
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _shareRecipe(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'recipe-image-${recipe.recipeId}',
              child: recipe.imageUrl.isNotEmpty
                  ? Image.network(
                      recipe.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.fastfood,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Par ${recipe.authorName}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  Text(
                    'Ingrédients:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: recipe.ingredients
                        .map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text('• $ingredient'),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  Text(
                    'Instructions:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(recipe.instructions),
                  SizedBox(height: 20),
                  // Bouton pour modifier (si l'utilisateur est l'auteur)
                  if (authProvider.currentUser != null &&
                      authProvider.currentUser!.userId == recipe.authorId)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implémenter la modification de recette
                        },
                        child: Text('Modifier la recette'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareRecipe(BuildContext context) {
    final String shareText =
        'Découvrez cette délicieuse recette: ${recipe.title}\n\n'
        'Ingrédients:\n${recipe.ingredients.join('\n')}\n\n'
        'Instructions:\n${recipe.instructions}';

    // TODO: Implémenter le partage natif
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fonctionnalité de partage à implémenter')),
    );
  }
}
