import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/fruit.dart';
import '../../../data/models/recipe.dart';
import '../../../data/repositories/fruit_repository.dart';
import '../../../data/repositories/recipe_repository.dart';
import '../../state/recipes_view_model.dart';

enum RecipeFormMode { create, edit }

class RecipeCreateScreen extends StatelessWidget {
  const RecipeCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RecipeFormScreen.create();
  }
}

/// Общий экран формы (создание/редактирование)
class RecipeFormScreen extends StatefulWidget {
  final RecipeFormMode mode;
  final RecipeWithDetails? initialItem;

  const RecipeFormScreen._({
    super.key,
    required this.mode,
    this.initialItem,
  });

  const RecipeFormScreen.create({super.key})
      : mode = RecipeFormMode.create,
        initialItem = null;

  const RecipeFormScreen.edit({
    super.key,
    required RecipeWithDetails initialItem,
  })  : mode = RecipeFormMode.edit,
        initialItem = initialItem;

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _loading = true;
  String? _error;

  List<Fruit> _favoriteFruits = [];
  final Set<int> _selectedFruitIds = {};

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  Future<void> _initForm() async {
    if (widget.mode == RecipeFormMode.edit && widget.initialItem != null) {
      final rec = widget.initialItem!.recipe;
      _titleController.text = rec.title;
      if (rec.description != null) {
        _descriptionController.text = rec.description!;
      }
      _selectedFruitIds.addAll(rec.fruitIds);
    }

    await _loadFavoriteFruits();
  }

  Future<void> _loadFavoriteFruits() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fruitRepo = context.read<FruitRepository>();
      final favFruits = await fruitRepo.getFavoriteFruits();
      setState(() {
        _favoriteFruits = favFruits;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFruitIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы один фрукт')),
      );
      return;
    }

    final repo = context.read<RecipeRepository>();

    if (widget.mode == RecipeFormMode.create) {
      final recipe = Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        fruitIds: _selectedFruitIds.toList(),
      );
      await repo.createRecipe(recipe);
    } else {
      final old = widget.initialItem!.recipe;
      final updated = Recipe(
        id: old.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        fruitIds: _selectedFruitIds.toList(),
      );
      await repo.updateRecipe(updated);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = widget.mode == RecipeFormMode.create
        ? 'Создание рецепта'
        : 'Редактирование рецепта';

    final theme = Theme.of(context);

    Widget body;

    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Произошла ошибка'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _loadFavoriteFruits,
              child: const Text('Перезагрузить'),
            ),
          ],
        ),
      );
    } else {
      if (_favoriteFruits.isEmpty) {
        body = Center(
          child: Text(
            'У вас нет избранных фруктов.\n'
                'Добавьте фрукты в избранное, чтобы собрать рецепт.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        );
      } else {
        body = Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // блок "Основное"
                Text(
                  'Основная информация',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Название рецепта',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Название обязательно';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Описание (необязательно)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // блок "Фрукты"
                Text(
                  'Фрукты из избранного',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Column(
                      children: _favoriteFruits
                          .map(
                            (fruit) => CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(fruit.name),
                          subtitle: Text(fruit.family),
                          secondary: const Icon(Icons.local_grocery_store),
                          value: _selectedFruitIds.contains(fruit.id),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedFruitIds.add(fruit.id);
                              } else {
                                _selectedFruitIds.remove(fruit.id);
                              }
                            });
                          },
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FilledButton(
                  onPressed: _saveRecipe,
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: body,
    );
  }
}
