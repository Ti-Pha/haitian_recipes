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
  final _descriptionController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String _difficulty = 'Easy';
  bool _takePhotoSelected = false;
  bool _uploadFromGallerySelected = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Recipe', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Recipe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'No photo selected',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(
                          _takePhotoSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: _takePhotoSelected
                              ? Colors.deepOrange
                              : Colors.grey,
                        ),
                        label: Text('Take Photo'),
                        onPressed: () {
                          setState(() {
                            _takePhotoSelected = true;
                            _uploadFromGallerySelected = false;
                          });
                          _takePhoto();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _takePhotoSelected
                              ? Colors.deepOrange
                              : Colors.grey,
                          side: BorderSide(
                            color: _takePhotoSelected
                                ? Colors.deepOrange
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(
                          _uploadFromGallerySelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: _uploadFromGallerySelected
                              ? Colors.deepOrange
                              : Colors.grey,
                        ),
                        label: Text('Upload from Gallery'),
                        onPressed: () {
                          setState(() {
                            _uploadFromGallerySelected = true;
                            _takePhotoSelected = false;
                          });
                          _pickImage();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _uploadFromGallerySelected
                              ? Colors.deepOrange
                              : Colors.grey,
                          side: BorderSide(
                            color: _uploadFromGallerySelected
                                ? Colors.deepOrange
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 16),
                Text(
                  'Recipe Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Recipe Title',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter recipe name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a recipe title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Short Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Brief description of your recipe',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cooking Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _cookingTimeController,
                            decoration: InputDecoration(
                              hintText: 'e.g., 30 min',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter cooking time';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Difficulty',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _difficulty,
                            items: ['Easy', 'Medium', 'Hard'].map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _difficulty = newValue!;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Divider(),
                SizedBox(height: 16),
                Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add each ingredient on a separate line',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _ingredientsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ingredient 1\nIngredient 2\n...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter at least one ingredient';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Cooking Instructions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Step-by-step instructions',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Step 1: ...\nStep 2: ...\n...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter cooking instructions';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                if (recipeProvider.isLoading)
                  Center(child: CircularProgressIndicator())
                else
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _addRecipe(authProvider, recipeProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                      ),
                      child: Text(
                        'Submit Recipe',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _addRecipe(
    AuthProvider authProvider,
    RecipeProvider recipeProvider,
  ) async {
    if (_formKey.currentState!.validate() && authProvider.currentUser != null) {
      try {
        // Préparer la liste des ingrédients
        List<String> ingredients = _ingredientsController.text
            .split('\n')
            .map((ingredient) => ingredient.trim())
            .where((ingredient) => ingredient.isNotEmpty)
            .toList();

        // Créer l'objet Recipe
        RecipeModel newRecipe = RecipeModel(
          recipeId: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          ingredients: ingredients,
          instructions: _instructionsController.text,
          imageUrl: null, // On n'utilise plus Firebase Storage
          localImagePath: null, // Sera rempli après la sauvegarde locale
          authorId: authProvider.currentUser!.userId,
          authorName:
              authProvider.currentUser!.displayName ??
              authProvider.currentUser!.email,
          datePublication: DateTime.now(),
        );

        // Ajouter la recette avec l'image locale
        final success = await recipeProvider.addRecipe(newRecipe, _imageFile);

        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recette ajoutée avec succès!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'ajout de la recette')),
          );
        }
      } catch (e) {
        print('Erreur: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      }
    }
  }
}
