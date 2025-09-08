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
  String _searchQuery = ''; // Nouvelle variable pour la recherche par nom

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);

    // Utilisez la liste dynamique des temps de cuisson, directement du provider
    final List<String> cookingTimes = recipeProvider.uniqueCookingTimes;

    // Utilisez la nouvelle méthode pour obtenir la liste filtrée
    final List<RecipeModel> filteredRecipes = recipeProvider.getFilteredRecipes(
      difficulty: _selectedDifficulty,
      cookingTime: _selectedCookingTime,
      searchQuery: _searchQuery, // Passez la valeur de la recherche
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Rechercher des recettes')),
      body: Column(
        children: [
          // Champ de texte pour la recherche par nom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Rechercher par nom',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Difficulté'),
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
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Temps de cuisson',
                    ),
                    value: _selectedCookingTime,
                    items: cookingTimes.map((String value) {
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
                ? const Center(child: CircularProgressIndicator())
                : filteredRecipes.isEmpty
                ? const Center(child: Text('Aucune recette trouvée.'))
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
