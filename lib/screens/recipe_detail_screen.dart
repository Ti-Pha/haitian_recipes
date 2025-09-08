import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/comment_model.dart';
import '../models/recipe_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import '../services/database_service.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final databaseService = DatabaseService();
  final commentController = TextEditingController();
  late Stream<List<CommentModel>> commentsStream;

  @override
  void initState() {
    super.initState();
    commentsStream = databaseService.getCommentsForRecipe(
      widget.recipe.recipeId!,
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    final isAuthor =
        authProvider.currentUser != null &&
        authProvider.currentUser!.userId == widget.recipe.authorId;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (isAuthor)
            PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'edit') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          EditRecipeScreen(recipe: widget.recipe),
                    ),
                  );
                } else if (result == 'delete') {
                  _confirmDelete(context, widget.recipe, recipeProvider);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.deepOrange),
                      SizedBox(width: 8),
                      Text('Update'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'recipe-image-${widget.recipe.recipeId}',
              child: _buildRecipeImage(widget.recipe.localImagePath),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipe.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Publish by ${widget.recipe.authorName}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.deepOrange),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingredients:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.recipe.ingredients
                        .map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              '• $ingredient',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.deepOrange),
                  const SizedBox(height: 16),
                  const Text(
                    'Directives:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.recipe.instructions,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  Text(
                    'Comments',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: const InputDecoration(
                              hintText: 'Add comment...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () async {
                            if (commentController.text.isNotEmpty &&
                                authProvider.currentUser != null) {
                              final newComment = CommentModel(
                                commentId: const Uuid().v4(),
                                recipeId: widget.recipe.recipeId!,
                                userId: authProvider.currentUser!.userId,
                                content: commentController.text,
                                date: DateTime.now(),
                              );
                              await databaseService.addComment(newComment);
                              commentController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  StreamBuilder<List<CommentModel>>(
                    stream: commentsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        print('Error: ${snapshot.error}');
                        return const Center(child: Text('An error occured.'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No comment yet.'));
                      }

                      final comments = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return StreamBuilder<UserModel>(
                            stream: databaseService.getUser(comment.userId),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return const ListTile(
                                  title: Text('Loading comment...'),
                                  subtitle: Text(''),
                                );
                              }
                              final user = userSnapshot.data!;
                              return ListTile(
                                title: Text(comment.content),
                                subtitle: Text(
                                  'By ${user.displayName ?? 'Unknown user'} on ${comment.date.day}/${comment.date.month}/${comment.date.year}',
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage(String? localImagePath) {
    if (localImagePath != null && localImagePath.isNotEmpty) {
      final imageFile = File(localImagePath);
      if (imageFile.existsSync()) {
        return Image.file(
          imageFile,
          width: double.infinity,
          height: 280,
          fit: BoxFit.cover,
        );
      }
    }
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Center(
        child: Icon(Icons.fastfood, size: 70, color: Colors.grey[600]),
      ),
    );
  }

  // void _shareRecipe(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('')),
  //   );
  // }

  Future<void> _confirmDelete(
    BuildContext context,
    RecipeModel recipe,
    RecipeProvider recipeProvider,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
            'Do you really want to delete the recipe? This action can not be undo.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await recipeProvider.deleteRecipe(recipe, context);
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
