import 'dart:io';

class RecipeModel {
  final String recipeId;
  final String title;
  final String description; // Ajouté
  final List<String> ingredients;
  final String instructions;
  final String cookingTime; // Ajouté
  final String difficulty; // Ajouté
  final String? imageUrl;
  final String? localImagePath;
  final String authorId;
  final String authorName;
  final DateTime datePublication;

  RecipeModel({
    required this.recipeId,
    required this.title,
    required this.description, // Ajouté
    required this.ingredients,
    required this.instructions,
    required this.cookingTime, // Ajouté
    required this.difficulty, // Ajouté
    this.imageUrl,
    this.localImagePath,
    required this.authorId,
    required this.authorName,
    required this.datePublication,
  });

  RecipeModel copyWith({
    String? recipeId,
    String? title,
    String? description,
    List<String>? ingredients,
    String? instructions,
    String? cookingTime,
    String? difficulty,
    String? imageUrl,
    String? localImagePath,
    String? authorId,
    String? authorName,
    DateTime? datePublication,
  }) {
    return RecipeModel(
      recipeId: recipeId ?? this.recipeId,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      cookingTime: cookingTime ?? this.cookingTime,
      difficulty: difficulty ?? this.difficulty,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      datePublication: datePublication ?? this.datePublication,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'cookingTime': cookingTime,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'authorId': authorId,
      'authorName': authorName,
      'datePublication': datePublication.toIso8601String(),
    };
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          print('Erreur de parsing de date: $e');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return RecipeModel(
      recipeId: map['recipeId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: map['instructions'] ?? '',
      cookingTime: map['cookingTime'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      imageUrl: map['imageUrl'],
      localImagePath: map['localImagePath'],
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      datePublication: parseDate(map['datePublication']),
    );
  }

  Future<void> delete() async {
    try {
      if (localImagePath != null) {
        final file = File(localImagePath!);
        if (await file.exists()) {
          await file.delete();
          print('Image locale supprimée pour la recette: $title');
        }
      }
    } catch (e) {
      print('Erreur lors de la suppression de l\'image locale: $e');
    }
  }
}
