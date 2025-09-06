class UserModel {
  final String userId;
  final String email;
  final String? displayName;
  final List<String> favoriteRecipes;

  UserModel({
    required this.userId,
    required this.email,
    this.displayName,
    this.favoriteRecipes = const [], // Initialise la liste à vide par défaut
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'favoriteRecipes': favoriteRecipes, // Ajoute le champ pour les favoris
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      // Récupère la liste de favoris depuis la map, en gérant le cas où elle est nulle
      favoriteRecipes: List<String>.from(map['favoriteRecipes'] ?? []),
    );
  }

  // Ajoute une méthode copyWith pour mettre à jour l'objet de manière immuable
  UserModel copyWith({
    String? userId,
    String? email,
    String? displayName,
    List<String>? favoriteRecipes,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
    );
  }
}
