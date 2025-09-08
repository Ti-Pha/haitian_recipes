import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> addRecipe(RecipeModel recipe) async {
    await _firestore
        .collection('recipes')
        .doc(recipe.recipeId)
        .set(recipe.toMap());
  }

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

  Future<void> updateRecipe(RecipeModel recipe) async {
    await _firestore
        .collection('recipes')
        .doc(recipe.recipeId)
        .update(recipe.toMap());
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _firestore.collection('recipes').doc(recipeId).delete();
  }

  Future<void> addComment(CommentModel comment) async {
    try {
      await _firestore
          .collection('comments')
          .doc(comment.commentId)
          .set(comment.toMap());
      print("Comment add successfully !");
    } catch (e) {
      print("Error while adding the comming: $e");
    }
  }

  Stream<List<CommentModel>> getCommentsForRecipe(String recipeId) {
    print('Retrieving comments for recipe ID: $recipeId');
    return _firestore
        .collection('comments')
        .where('recipeId', isEqualTo: recipeId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          print('Number of document received: ${snapshot.docs.length}');
          return snapshot.docs.map((doc) {
            return CommentModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  Stream<UserModel> getUser(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }

      return UserModel(userId: userId, email: '', displayName: 'Uknown user');
    });
  }
}
