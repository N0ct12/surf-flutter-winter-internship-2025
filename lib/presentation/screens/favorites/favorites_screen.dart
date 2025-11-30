import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/fruit.dart';
import '../../state/fruits_view_model.dart';
import '../fruits/fruit_details_screen.dart';
import '../fruits/fruits_list_screen.dart' show FruitListCard;

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FruitsViewModel>();
    final theme = Theme.of(context);

    Widget body;

    if (vm.status == FruitsStatus.loading ||
        vm.status == FruitsStatus.initial) {
      body = const Center(child: CircularProgressIndicator());
    } else if (vm.status == FruitsStatus.error) {
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
    } else {
      final Set<int> favIds = vm.favoriteIds;
      final List<Fruit> all = vm.allFruits;
      final List<Fruit> favorites =
      all.where((f) => favIds.contains(f.id)).toList();

      if (favorites.isEmpty) {
        body = Center(
          child: Text(
            'Вы пока ничего не добавили в избранное',
            style: theme.textTheme.bodyMedium,
          ),
        );
      } else {
        body = ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final fruit = favorites[index];
            return FruitListCard(
              fruit: fruit,
              isFavorite: true,
              onToggleFavorite: () => vm.toggleFavorite(fruit.id),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FruitDetailsScreen(fruit: fruit),
                  ),
                );
              },
            );
          },
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
      ),
      body: body,
    );
  }
}
