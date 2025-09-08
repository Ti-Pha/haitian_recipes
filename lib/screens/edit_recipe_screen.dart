import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';

class EditRecipeScreen extends StatefulWidget {
  final RecipeModel recipe;

  const EditRecipeScreen({super.key, required this.recipe});

  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _instructionsController;
  late List<TextEditingController> _ingredientControllers;
  // Nouveau contrôleur de texte pour le temps de cuisson
  late TextEditingController _cookingTimeController;

  late String _selectedDifficulty;

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.title);
    _instructionsController = TextEditingController(
      text: widget.recipe.instructions,
    );
    _ingredientControllers = widget.recipe.ingredients
        .map((ingredient) => TextEditingController(text: ingredient))
        .toList();

    // Initialisation du contrôleur de temps de cuisson
    _cookingTimeController = TextEditingController(
      text: widget.recipe.cookingTime,
    );

    _selectedDifficulty = _difficulties.contains(widget.recipe.difficulty)
        ? widget.recipe.difficulty
        : _difficulties[0];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    _cookingTimeController.dispose(); // Libérer le nouveau contrôleur
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      if (_ingredientControllers.length > 1) {
        _ingredientControllers.removeAt(index);
      }
    });
  }

  void _updateRecipe() {
    if (_formKey.currentState!.validate()) {
      final updatedIngredients = _ingredientControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) => controller.text)
          .toList();

      final updatedRecipe = widget.recipe.copyWith(
        title: _titleController.text,
        instructions: _instructionsController.text,
        ingredients: updatedIngredients,
        difficulty: _selectedDifficulty,
        // Récupération de la valeur du nouveau contrôleur
        cookingTime: _cookingTimeController.text,
      );

      Provider.of<RecipeProvider>(
        context,
        listen: false,
      ).updateRecipe(updatedRecipe);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la recette'),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de la recette',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: const InputDecoration(labelText: 'Difficulté'),
                items: _difficulties.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDifficulty = newValue!;
                  });
                },
                validator: (value) => value == null
                    ? 'Veuillez sélectionner une difficulté'
                    : null,
              ),
              const SizedBox(height: 16),
              // Nouveau champ de texte pour le temps de cuisson
              TextFormField(
                controller: _cookingTimeController,
                decoration: const InputDecoration(
                  labelText: 'Temps de cuisson',
                  hintText: 'Ex: 45 min ou 1h30',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le temps de cuisson';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Ingrédients:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ..._ingredientControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Ingrédient ${index + 1}',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ne peut être vide';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeIngredientField(index),
                      ),
                    ],
                  ),
                );
              }),
              TextButton(
                onPressed: _addIngredientField,
                child: const Text('Ajouter un ingrédient'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(labelText: 'Instructions'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer les instructions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Mettre à jour la recette'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
