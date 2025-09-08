class UserModel {
  final String userId;
  final String email;
  final String? displayName;
  final List<String> favoriteRecipes;

  UserModel({
    required this.userId,
    required this.email,
    this.displayName,
    this.favoriteRecipes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'favoriteRecipes': favoriteRecipes,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      userId: id,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      favoriteRecipes: List<String>.from(map['favoriteRecipes'] ?? []),
    );
  }

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
