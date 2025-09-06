import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../screens/recipe_detail_screen.dart';
import 'dart:io';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeCard({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_hasLocalImage()) // 👈 Condition pour afficher l'image uniquement si elle existe
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: _buildRecipeImage(recipe.localImagePath),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.favorite_border, color: Colors.white),
                        onPressed: () {
                          // TODO: Implement favorites logic
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Easy',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '30 min',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Par ${recipe.authorName}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ajout d'une nouvelle méthode pour vérifier l'existence de l'image
  bool _hasLocalImage() {
    return recipe.localImagePath != null &&
        File(recipe.localImagePath!).existsSync();
  }

  Widget _buildRecipeImage(String? localImagePath) {
    return Image.file(
      File(localImagePath!),
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
