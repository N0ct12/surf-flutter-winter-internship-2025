import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/fruit.dart';
import '../../../data/models/nutrition.dart';
import '../../state/recipes_view_model.dart';
import 'recipe_edit_screen.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final RecipeWithDetails item;

  const RecipeDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipe = item.recipe;
    final fruits = item.fruits;
    final total = item.totalNutrition;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            tooltip: 'Редактировать рецепт',
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final changed = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => RecipeEditScreen(item: item),
                ),
              );
              if (changed == true && context.mounted) {
                await context.read<RecipesViewModel>().load();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // шапка
            _HeaderCard(recipeTitle: recipe.title, fruits: fruits),
            const SizedBox(height: 16),

            // описание
            if (recipe.description != null &&
                recipe.description!.trim().isNotEmpty) ...[
              _SectionTitle(text: 'Описание'),
              const SizedBox(height: 8),
              Material(
                borderRadius: BorderRadius.circular(16),
                color: theme.colorScheme.surface,
                elevation: 1,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    recipe.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // состав
            _SectionTitle(text: 'Состав'),
            const SizedBox(height: 8),
            _FruitsChipsCard(fruits: fruits),
            const SizedBox(height: 16),

            // нутриенты
            _SectionTitle(text: 'Питательные свойства (суммарно)'),
            const SizedBox(height: 8),
            _NutritionGrid(total: total),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String recipeTitle;
  final List<Fruit> fruits;

  const _HeaderCard({
    required this.recipeTitle,
    required this.fruits,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = fruits.length;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                recipeTitle.isNotEmpty ? recipeTitle[0] : '?',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipeTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    count == 0
                        ? 'Фрукты пока не выбраны'
                        : 'Фруктов в рецепте: $count',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FruitsChipsCard extends StatelessWidget {
  final List<Fruit> fruits;

  const _FruitsChipsCard({required this.fruits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (fruits.isEmpty) {
      return Material(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        elevation: 1,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Фрукты не выбраны'),
        ),
      );
    }

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surface,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          children: fruits
              .map(
                (f) => Chip(
              avatar: const Icon(Icons.local_grocery_store, size: 16),
              label: Text(f.name),
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}

class _NutritionGrid extends StatelessWidget {
  final Nutrition total;

  const _NutritionGrid({required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget tile(String label, String value, IconData icon) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.secondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surface,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3,
          ),
          children: [
            tile('Калории', '${total.calories}', Icons.local_fire_department),
            tile('Жиры (г)', '${total.fat}', Icons.water_drop),
            tile('Сахар (г)', '${total.sugar}', Icons.cake_outlined),
            tile('Углеводы (г)', '${total.carbohydrates}', Icons.grain),
            tile('Белок (г)', '${total.protein}', Icons.egg_outlined),
          ],
        ),
      ),
    );
  }
}
