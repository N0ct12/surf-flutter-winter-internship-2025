import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/fruit.dart';
import '../../../data/models/nutrition.dart';
import '../../state/recipes_view_model.dart';
import 'recipe_create_screen.dart';
import 'recipe_details_screen.dart';

class RecipesListScreen extends StatelessWidget {
  const RecipesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecipesViewModel>();
    final theme = Theme.of(context);

    Widget body;

    switch (vm.status) {
      case RecipesStatus.loading:
      case RecipesStatus.initial:
        body = const Center(child: CircularProgressIndicator());
        break;
      case RecipesStatus.error:
        body = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Произошла ошибка'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => vm.load(),
                child: const Text('Перезагрузить'),
              ),
            ],
          ),
        );
        break;
      case RecipesStatus.loaded:
        if (vm.items.isEmpty) {
          body = Center(
            child: Text(
              'Создайте свой первый рецепт',
              style: theme.textTheme.bodyMedium,
            ),
          );
        } else {
          body = ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: vm.items.length,
            itemBuilder: (context, index) {
              final item = vm.items[index];
              return RecipeListCard(
                item: item,
                onDelete: () => vm.deleteRecipe(item.recipe.id),
                onOpenDetails: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailsScreen(item: item),
                    ),
                  );
                  await context.read<RecipesViewModel>().load();
                },
              );
            },
          );
        }
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Рецепты'),
        actions: [
          IconButton(
            tooltip: 'Создать рецепт',
            icon: const Icon(Icons.add),
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => const RecipeCreateScreen(),
                ),
              );
              if (created == true && context.mounted) {
                await context.read<RecipesViewModel>().load();
              }
            },
          ),
        ],
      ),
      body: body,
    );
  }
}

class RecipeListCard extends StatelessWidget {
  final RecipeWithDetails item;
  final VoidCallback onDelete;
  final VoidCallback onOpenDetails;

  const RecipeListCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipe = item.recipe;
    final fruits = item.fruits;
    final total = item.totalNutrition;

    final description = recipe.description ?? '';
    final fruitsLine =
    fruits.isEmpty ? 'Фрукты не выбраны' : fruits.map((f) => f.name).join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 2,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onOpenDetails,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // шапка
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        recipe.title.isNotEmpty ? recipe.title[0] : '?',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (description.trim().isNotEmpty)
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      tooltip: 'Удалить рецепт',
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // состав
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 18,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Состав: $fruitsLine',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // нутриенты (кратко)
                _NutritionSummary(total: total),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Подробнее',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NutritionSummary extends StatelessWidget {
  final Nutrition total;

  const _NutritionSummary({required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Text span(String label, String value) => Text(
      '$label $value',
      style: theme.textTheme.labelSmall,
    );

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        span('ккал', '${total.calories}'),
        span('жиры', '${total.fat}'),
        span('сахар', '${total.sugar}'),
        span('углеводы', '${total.carbohydrates}'),
        span('белок', '${total.protein}'),
      ],
    );
  }
}
