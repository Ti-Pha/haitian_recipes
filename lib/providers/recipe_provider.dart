import 'package:flutter/foundation.dart';
import 'dart:io'; // Import manquant pour la classe File
import '../models/recipe_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class RecipeProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  List<RecipeModel> _recipes = [];
  bool _isLoading = false;

  List<RecipeModel> get recipes => _recipes;
  bool get isLoading => _isLoading;

  // Charger toutes les recettes
  Future<void> loadRecipes() async {
    _setLoading(true);
    try {
      _databaseService.getRecipes().listen((recipes) {
        _recipes = recipes;
        notifyListeners();
      });
    } catch (e) {
      print('Erreur lors du chargement des recettes: $e');
    }
    _setLoading(false);
  }

  // Ajouter une recette
  Future<bool> addRecipe(RecipeModel recipe, File? imageFile) async {
    _setLoading(true);
    try {
      if (imageFile != null) {
        String imageUrl = await _storageService.uploadImage(
          imageFile,
          recipe.authorId,
        );
        recipe = recipe.copyWith(imageUrl: imageUrl);
      }

      await _databaseService.addRecipe(recipe);
      _setLoading(false);
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout: $e');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
