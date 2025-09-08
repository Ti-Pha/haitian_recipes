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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<RecipeModel> _recipes = [];
  bool _isLoading = false;

  List<RecipeModel> get recipes => _recipes;
  bool get isLoading => _isLoading;

  // Getter pour récupérer les temps de cuisson uniques
  List<String> get uniqueCookingTimes {
    final Set<String> times = {};
    for (var recipe in _recipes) {
      if (recipe.cookingTime != null && recipe.cookingTime!.isNotEmpty) {
        times.add(recipe.cookingTime!);
      }
    }
    final sortedTimes = times.toList();
    sortedTimes.sort();
    return sortedTimes;
  }

  // Charge toutes les recettes
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

  // Obtient une liste filtrée de recettes basée sur la difficulté, le temps de cuisson et le nom
  List<RecipeModel> getFilteredRecipes({
    String? difficulty,
    String? cookingTime,
    String? searchQuery, // Ajout du paramètre de recherche
  }) {
    List<RecipeModel> filtered = _recipes;

    if (difficulty != null && difficulty.isNotEmpty) {
      filtered = filtered
          .where((recipe) => recipe.difficulty == difficulty)
          .toList();
    }

    if (cookingTime != null && cookingTime.isNotEmpty) {
      filtered = filtered
          .where((recipe) => recipe.cookingTime == cookingTime)
          .toList();
    }

    // Ajout du filtre par nom de recette
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((recipe) {
        final recipeTitle = recipe.title.toLowerCase();
        final query = searchQuery.toLowerCase();
        return recipeTitle.contains(query);
      }).toList();
    }

    return filtered;
  }

  // Ajoute une recette
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

  // Met à jour une recette
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

  // Supprime une recette
  Future<void> deleteRecipe(RecipeModel recipe, BuildContext context) async {
    try {
      if (recipe.localImagePath != null) {
        final file = File(recipe.localImagePath!);
        if (await file.exists()) {
          await file.delete();
          print('Image locale supprimée pour la recette: ${recipe.title}');
        }
      }

      await _databaseService.deleteRecipe(recipe.recipeId);

      final usersSnapshot = await _firestore
          .collection('users')
          .where('favoriteRecipes', arrayContains: recipe.recipeId)
          .get();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      for (var userDoc in usersSnapshot.docs) {
        await authProvider.removeFavoriteFromUser(userDoc.id, recipe.recipeId);
      }

      _recipes.removeWhere((r) => r.recipeId == recipe.recipeId);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la suppression de la recette: $e');
    }
  }

  // Obtient une image de recette à partir de son chemin local
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
