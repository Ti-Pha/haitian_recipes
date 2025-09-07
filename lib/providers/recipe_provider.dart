import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/recipe_model.dart';
import '../services/database_service.dart';
import '../services/local_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class RecipeProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final LocalStorageService _localStorageService = LocalStorageService();

  List<RecipeModel> _recipes = [];
  bool _isLoading = false;

  List<RecipeModel> get recipes => _recipes;
  bool get isLoading => _isLoading;

  // Charger toutes les recettes
  Future<void> loadRecipes() async {
    _setLoading(true);
    try {
      _databaseService.getRecipes().listen(
        (recipes) {
          _recipes = recipes;
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

  // Ajouter une recette avec image locale
  Future<bool> addRecipe(RecipeModel recipe, File? imageFile) async {
    _setLoading(true);
    try {
      String? localImagePath;

      // Sauvegarder l'image localement si elle existe
      if (imageFile != null) {
        final String fileName =
            '${recipe.recipeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        localImagePath = await _localStorageService.saveImageLocally(
          imageFile,
          fileName,
        );
        print('Image sauvegardée localement: $localImagePath');
      }

      // Creer une copie de la recette avec le chemin local de l'image
      RecipeModel recipeWithLocalImage = recipe.copyWith(
        localImagePath: localImagePath,
        imageUrl: null,
      );

      // Ajouter la recette a la base de donnees
      await _databaseService.addRecipe(recipeWithLocalImage);

      // Recharger les recettes pour mettre a jour la liste
      await loadRecipes();

      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 👇 Nouvelle methode pour mettre a jour une recette
  Future<void> updateRecipe(RecipeModel updatedRecipe) async {
    try {
      // Mettre a jour la recette dans la base de donnees
      await _databaseService.updateRecipe(updatedRecipe);

      // Mettre a jour la liste locale
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

  // 👇 Nouvelle méthode pour supprimer une recette
  Future<void> deleteRecipe(RecipeModel recipe, BuildContext context) async {
    try {
      // Supprimer l'image locale associée
      if (recipe.localImagePath != null) {
        final file = File(recipe.localImagePath!);
        if (await file.exists()) {
          await file.delete();
          print('Image locale supprimée pour la recette: ${recipe.title}');
        }
      }

      // Supprimer la recette de la base de données
      await _databaseService.deleteRecipe(recipe.recipeId);

      // 👇 L'AJOUT CRUCIAL : Supprimer l'ID de la recette des favoris
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.removeFavorite(recipe.recipeId);

      // Mettre à jour la liste locale
      _recipes.removeWhere((r) => r.recipeId == recipe.recipeId);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la suppression de la recette: $e');
    }
  }

  // Méthode pour recuperer une image a partir de son chemin local
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
