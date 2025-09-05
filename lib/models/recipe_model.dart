import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String recipeId;
  final String title;
  final List<String> ingredients;
  final String instructions;
  final String imageUrl;
  final String authorId;
  final String authorName;
  final DateTime datePublication;

  RecipeModel({
    required this.recipeId,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.imageUrl,
    required this.authorId,
    required this.authorName,
    required this.datePublication,
  });

  // Méthode pour convertir l'objet en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'title': title,
      'ingredients': ingredients,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'datePublication':
          datePublication, // Firestore gère directement le type DateTime
    };
  }

  // Méthode pour créer un objet depuis un Map de Firestore
  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    // Gérer la conversion du Timestamp de Firestore en DateTime de Dart
    final date = map['datePublication'];
    final DateTime publicationDate;

    if (date is Timestamp) {
      publicationDate = date.toDate();
    } else if (date is String) {
      publicationDate = DateTime.parse(date);
    } else {
      publicationDate =
          DateTime.now(); // Valeur par défaut si le type est incorrect
    }

    return RecipeModel(
      recipeId: map['recipeId'] ?? '',
      title: map['title'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: map['instructions'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      datePublication: publicationDate,
    );
  }

  // Méthode copyWith pour la mise à jour des objets
  RecipeModel copyWith({
    String? recipeId,
    String? title,
    List<String>? ingredients,
    String? instructions,
    String? imageUrl,
    String? authorId,
    String? authorName,
    DateTime? datePublication,
  }) {
    return RecipeModel(
      recipeId: recipeId ?? this.recipeId,
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      datePublication: datePublication ?? this.datePublication,
    );
  }
}
