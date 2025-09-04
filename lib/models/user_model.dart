class UserModel {
  final String userId;
  final String email;
  final String? displayName;

  UserModel({required this.userId, required this.email, this.displayName});

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'email': email, 'displayName': displayName};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'],
      email: map['email'],
      displayName: map['displayName'],
    );
  }
}
