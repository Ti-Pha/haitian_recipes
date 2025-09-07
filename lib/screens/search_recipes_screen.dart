// Dans votre fichier search_recipes_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import '../models/recipe_model.dart'; // Importez le modèle

class SearchRecipesScreen extends StatefulWidget {
  const SearchRecipesScreen({super.key});

  @override
  State<SearchRecipesScreen> createState() => _SearchRecipesScreenState();
}

class _SearchRecipesScreenState extends State<SearchRecipesScreen> {
  String? _selectedDifficulty;
  String? _selectedCookingTime;

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);

    // Utilisez la nouvelle méthode pour obtenir la liste filtrée
    final List<RecipeModel> filteredRecipes = recipeProvider.getFilteredRecipes(
      difficulty: _selectedDifficulty,
      cookingTime: _selectedCookingTime,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Rechercher des recettes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Difficulté'),
                    value: _selectedDifficulty,
                    items: ['Easy', 'Medium', 'Hard'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDifficulty = newValue;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Temps de cuisson'),
                    value: _selectedCookingTime,
                    items: ['15 min', '30 min', '1 hr'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCookingTime = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: recipeProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredRecipes.isEmpty
                ? Center(child: Text('Aucune recette trouvée.'))
                : ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      return RecipeCard(recipe: filteredRecipes[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
