import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/recipe_provider.dart';
import '../providers/auth_provider.dart';
import '../models/recipe_model.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Ajouter une recette')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Sélection d'image
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, fit: BoxFit.cover)
                        : Icon(Icons.camera_alt, size: 50),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre de la recette',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _ingredientsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Ingrédients (séparés par des virgules)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer les ingrédients';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Instructions',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer les instructions';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                recipeProvider.isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              _addRecipe(authProvider, recipeProvider),
                          child: Text('Ajouter la recette'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  void _addRecipe(
    AuthProvider authProvider,
    RecipeProvider recipeProvider,
  ) async {
    if (_formKey.currentState!.validate() && authProvider.currentUser != null) {
      // Préparer la liste des ingrédients
      List<String> ingredients = _ingredientsController.text
          .split(',')
          .map((ingredient) => ingredient.trim())
          .where((ingredient) => ingredient.isNotEmpty)
          .toList();

      // Créer l'objet Recipe avec une URL d'image vide pour le moment
      RecipeModel newRecipe = RecipeModel(
        recipeId: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        ingredients: ingredients,
        instructions: _instructionsController.text,
        imageUrl: '', // Sera rempli après l'upload
        authorId: authProvider.currentUser!.userId,
        authorName:
            authProvider.currentUser!.displayName ??
            authProvider.currentUser!.email,
        datePublication: DateTime.now(),
      );

      // Ajouter la recette
      final success = await recipeProvider.addRecipe(newRecipe, _imageFile);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Recette ajoutée avec succès!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de la recette')),
        );
      }
    }
  }
}
