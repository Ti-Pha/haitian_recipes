import 'package:flutter/foundation.dart';
import 'dart:io';
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
      // S'abonner au stream des recettes
      _databaseService.getRecipes().listen(
        (recipes) {
          _recipes = recipes;
          _setLoading(
            false,
          ); // Mettre à jour le chargement une fois les données reçues
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

  // Ajouter une recette
  Future<bool> addRecipe(RecipeModel recipe, File? imageFile) async {
    _setLoading(true);
    try {
      String imageUrl = '';

      // Uploader l'image si elle existe
      if (imageFile != null) {
        imageUrl = await _storageService.uploadImage(
          imageFile,
          recipe.authorId,
        );
      }

      // Créer une copie de la recette avec l'URL de l'image
      RecipeModel recipeWithImage = recipe.copyWith(imageUrl: imageUrl);

      // Ajouter la recette à la base de données
      await _databaseService.addRecipe(recipeWithImage);

      // Recharger les recettes
      await loadRecipes();

      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
