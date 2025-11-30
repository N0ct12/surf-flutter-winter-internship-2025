import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/fruit.dart';
import '../../state/fruits_view_model.dart';
import '../../state/fruit_filters.dart';
import 'fruit_filters_screen.dart';
import 'fruit_details_screen.dart';

class FruitsListScreen extends StatefulWidget {
  const FruitsListScreen({super.key});

  @override
  State<FruitsListScreen> createState() => _FruitsListScreenState();
}

class _FruitsListScreenState extends State<FruitsListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 300;
      if (shouldShow != _showScrollToTop) {
        setState(() => _showScrollToTop = shouldShow);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FruitsViewModel>();

    Widget body;

    switch (vm.status) {
      case FruitsStatus.loading:
        body = const Center(child: CircularProgressIndicator());
        break;
      case FruitsStatus.error:
        body = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Произошла ошибка'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => vm.load(),
                child: const Text('Повторить'),
              ),
            ],
          ),
        );
        break;
      case FruitsStatus.loaded:
        if (vm.fruits.isEmpty) {
          body = const Center(
            child: Text('Список фруктов пуст'),
          );
        } else {
          body = ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: vm.fruits.length,
            itemBuilder: (context, index) {
              final fruit = vm.fruits[index];
              final isFav = vm.isFavorite(fruit.id);
              return FruitListCard(
                fruit: fruit,
                isFavorite: isFav,
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
        break;
      case FruitsStatus.initial:
        body = const SizedBox.shrink();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Фрукты'),
        actions: [
          IconButton(
            tooltip: 'Фильтры и сортировка',
            icon: const Icon(Icons.tune),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FruitFiltersScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: body,
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
        onPressed: _scrollToTop,
        child: const Icon(Icons.arrow_upward),
      )
          : null,
    );
  }
}

class FruitListCard extends StatelessWidget {
  final Fruit fruit;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const FruitListCard({
    super.key,
    required this.fruit,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 1.5,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap, // явный клик по карточке
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // аватар с первой буквой
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    fruit.name.isNotEmpty ? fruit.name[0] : '?',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // текстовая часть
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fruit.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fruit.family,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // быстрая инфа по нутриентам
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${fruit.nutritions.calories} ккал',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.cake_outlined,
                            size: 14,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${fruit.nutritions.sugar} сахара',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // избранное + chevron
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? theme.colorScheme.primary
                            : theme.iconTheme.color,
                      ),
                      onPressed: onToggleFavorite,
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
