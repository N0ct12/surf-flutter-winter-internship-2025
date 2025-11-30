import 'package:flutter/material.dart';

import '../../state/recipes_view_model.dart';
import 'recipe_create_screen.dart';

class RecipeEditScreen extends StatelessWidget {
  final RecipeWithDetails item;

  const RecipeEditScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return RecipeFormScreen.edit(initialItem: item);
  }
}
