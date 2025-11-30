import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/fruit.dart';
import '../../state/fruits_view_model.dart';

class FruitDetailsScreen extends StatelessWidget {
  final Fruit fruit;

  const FruitDetailsScreen({super.key, required this.fruit});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FruitsViewModel>();
    final theme = Theme.of(context);
    final isFav = vm.isFavorite(fruit.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(fruit.name),
        actions: [
          IconButton(
            tooltip: isFav ? 'Убрать из избранного' : 'Добавить в избранное',
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () => vm.toggleFavorite(fruit.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "шапка" фрукта
            _HeaderCard(fruit: fruit),
            const SizedBox(height: 16),

            // таксономия
            Text(
              'Классификация',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text('Family: ${fruit.family}'),
                  avatar: const Icon(Icons.grass, size: 18),
                ),
                Chip(
                  label: Text('Order: ${fruit.order}'),
                  avatar: const Icon(Icons.category, size: 18),
                ),
                Chip(
                  label: Text('Genus: ${fruit.genus}'),
                  avatar: const Icon(Icons.science, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // питательные свойства
            Text(
              'Питательные свойства (на 100 г)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _NutritionCard(fruit: fruit),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Fruit fruit;

  const _HeaderCard({required this.fruit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                fruit.name.isNotEmpty ? fruit.name[0] : '?',
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
                    fruit.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fruit.family,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer
                          .withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Нажмите на сердечко вверху, чтобы добавить в избранное.',
                    style: theme.textTheme.bodySmall?.copyWith(
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

class _NutritionCard extends StatelessWidget {
  final Fruit fruit;

  const _NutritionCard({required this.fruit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget row(String label, String value, IconData icon) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label, style: theme.textTheme.bodyMedium),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final n = fruit.nutritions;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            row('Калории', '${n.calories}', Icons.local_fire_department),
            const Divider(height: 12),
            row('Жиры (г)', '${n.fat}', Icons.water_drop),
            const Divider(height: 12),
            row('Сахар (г)', '${n.sugar}', Icons.cake_outlined),
            const Divider(height: 12),
            row('Углеводы (г)', '${n.carbohydrates}', Icons.grain),
            const Divider(height: 12),
            row('Белок (г)', '${n.protein}', Icons.egg_outlined),
          ],
        ),
      ),
    );
  }
}
