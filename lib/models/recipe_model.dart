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

  // Ajout de la méthode copyWith manquante
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

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'title': title,
      'ingredients': ingredients,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'datePublication': datePublication.toIso8601String(),
    };
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      recipeId: map['recipeId'] ?? '',
      title: map['title'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: map['instructions'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      datePublication: map['datePublication'] != null
          ? DateTime.parse(map['datePublication'])
          : DateTime.now(),
    );
  }
}
