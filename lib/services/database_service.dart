import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer toutes les recettes
  Stream<List<RecipeModel>> getRecipes() {
    return _firestore
        .collection('recipes')
        .orderBy('datePublication', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RecipeModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Ajouter une nouvelle recette
  Future<void> addRecipe(RecipeModel recipe) async {
    await _firestore
        .collection('recipes')
        .doc(recipe.recipeId)
        .set(recipe.toMap());
  }

  // Récupérer les recettes d'un utilisateur
  Stream<List<RecipeModel>> getUserRecipes(String userId) {
    return _firestore
        .collection('recipes')
        .where('authorId', isEqualTo: userId)
        .orderBy('datePublication', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RecipeModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Mettre à jour une recette
  Future<void> updateRecipe(RecipeModel recipe) async {
    await _firestore
        .collection('recipes')
        .doc(recipe.recipeId)
        .update(recipe.toMap());
  }

  // Supprimer une recette
  Future<void> deleteRecipe(String recipeId) async {
    await _firestore.collection('recipes').doc(recipeId).delete();
  }
}
