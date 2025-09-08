import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String recipeId;
  final String userId;
  final String content;
  final DateTime date;

  CommentModel({
    required this.commentId,
    required this.recipeId,
    required this.userId,
    required this.content,
    required this.date,
  });

  factory CommentModel.fromMap(Map<String, dynamic> data, String id) {
    return CommentModel(
      commentId: id,
      recipeId: data['recipeId'] ?? '',
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'content': content,
      'date': date,
    };
  }
}
