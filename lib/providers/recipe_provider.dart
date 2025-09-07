import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';
import '../services/database_service.dart';
import '../services/local_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class RecipeProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Added Firestore instance

  List<RecipeModel> _recipes = [];
  bool _isLoading = false;

  List<RecipeModel> get recipes => _recipes;
  bool get isLoading => _isLoading;

  // Load all recipes without any filters
  Future<void> loadRecipes() async {
    _setLoading(true);
    try {
      _databaseService.getRecipes().listen(
        (allRecipes) {
          _recipes = allRecipes;
          _setLoading(false);
          notifyListeners();
        },
        onError: (error) {
          _setLoading(false);
          print('Erreur lors de l\'écoute des recettes: $error');
        },
      );
    } catch (e) {
      _setLoading(false);
      print('Erreur lors du chargement des recettes: $e');
    }
  }

  // Get a filtered list of recipes based on difficulty and/or cooking time
  List<RecipeModel> getFilteredRecipes({
    String? difficulty,
    String? cookingTime,
  }) {
    if ((difficulty == null || difficulty.isEmpty) &&
        (cookingTime == null || cookingTime.isEmpty)) {
      return _recipes;
    }

    return _recipes.where((recipe) {
      bool matchesDifficulty =
          difficulty == null ||
          difficulty.isEmpty ||
          recipe.difficulty == difficulty;
      bool matchesCookingTime =
          cookingTime == null ||
          cookingTime.isEmpty ||
          recipe.cookingTime == cookingTime;

      return matchesDifficulty && matchesCookingTime;
    }).toList();
  }

  // Add a recipe with a local image
  Future<bool> addRecipe(RecipeModel recipe, File? imageFile) async {
    _setLoading(true);
    try {
      String? localImagePath;

      if (imageFile != null) {
        final String fileName =
            '${recipe.recipeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        localImagePath = await _localStorageService.saveImageLocally(
          imageFile,
          fileName,
        );
      }

      RecipeModel recipeWithLocalImage = recipe.copyWith(
        localImagePath: localImagePath,
        imageUrl: null,
      );

      await _databaseService.addRecipe(recipeWithLocalImage);
      await loadRecipes();

      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update a recipe
  Future<void> updateRecipe(RecipeModel updatedRecipe) async {
    try {
      await _databaseService.updateRecipe(updatedRecipe);

      final index = _recipes.indexWhere(
        (recipe) => recipe.recipeId == updatedRecipe.recipeId,
      );
      if (index != -1) {
        _recipes[index] = updatedRecipe;
        notifyListeners();
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la recette: $e');
    }
  }

  // Delete a recipe
  // Dans votre fichier recipe_provider.dart

  // Dans votre fichier recipe_provider.dart

  Future<void> deleteRecipe(RecipeModel recipe, BuildContext context) async {
    try {
      // 1. Supprimer l'image locale associée
      if (recipe.localImagePath != null) {
        final file = File(recipe.localImagePath!);
        if (await file.exists()) {
          await file.delete();
          print('Image locale supprimée pour la recette: ${recipe.title}');
        }
      }

      // 2. Supprimer la recette de la base de données
      await _databaseService.deleteRecipe(recipe.recipeId);

      // 3. Trouver et mettre à jour tous les utilisateurs qui ont cette recette en favori
      final usersSnapshot = await _firestore
          .collection('users')
          .where('favoriteRecipes', arrayContains: recipe.recipeId)
          .get();

      // 4. Utiliser l'AuthProvider pour retirer le favori de chaque utilisateur
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      for (var userDoc in usersSnapshot.docs) {
        // Nous utilisons la méthode `removeFavoriteFromUser` que nous avons ajoutée à l'AuthProvider
        await authProvider.removeFavoriteFromUser(userDoc.id, recipe.recipeId);
      }

      // 5. Mettre à jour la liste locale
      _recipes.removeWhere((r) => r.recipeId == recipe.recipeId);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la suppression de la recette: $e');
      // Vous pouvez ajouter une gestion d'erreur plus sophistiquée ici
    }
  }

  // Get a recipe's image from its local path
  Future<File?> getRecipeImage(RecipeModel recipe) async {
    if (recipe.localImagePath != null) {
      try {
        return await _localStorageService.loadImageFromLocal(
          recipe.localImagePath!,
        );
      } catch (e) {
        print('Erreur lors du chargement de l\'image locale: $e');
        return null;
      }
    }
    return null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
