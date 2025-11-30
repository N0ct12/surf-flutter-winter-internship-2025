import 'package:flutter/foundation.dart';
import '../../data/models/fruit.dart';
import '../../data/repositories/fruit_repository.dart';
import 'fruit_filters.dart';

enum FruitsStatus { initial, loading, loaded, error }

class FruitsViewModel extends ChangeNotifier {
  final FruitRepository repository;

  FruitsStatus status = FruitsStatus.initial;
  String? errorMessage;

  List<Fruit> _all = [];
  List<Fruit> _visible = [];
  List<Fruit> get fruits => _visible;

  // ДОБАВЛЕНО: доступ ко всем фруктам (для экрана "Избранное")
  List<Fruit> get allFruits => _all;

  FruitSortType sortType = FruitSortType.nameAsc;
  final List<FruitFilter> availableFilters;
  final Set<String> _activeFilterIds = {};

  // публично — чтобы FavoritesScreen мог увидеть
  Set<int> favoriteIds = {};

  FruitsViewModel({
    required this.repository,
    required this.availableFilters,
  });

  Future<void> load() async {
    status = FruitsStatus.loading;
    notifyListeners();
    try {
      _all = await repository.getAllFruits();
      favoriteIds = (await repository.getFavoriteIds()).toSet();
      _applyFiltersAndSort();
      status = FruitsStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = FruitsStatus.error;
    }
    notifyListeners();
  }

  void setSortType(FruitSortType type) {
    sortType = type;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void toggleFilter(String id) {
    if (_activeFilterIds.contains(id)) {
      _activeFilterIds.remove(id);
    } else {
      _activeFilterIds.add(id);
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  bool isFilterActive(String id) => _activeFilterIds.contains(id);

  bool isFavorite(int id) => favoriteIds.contains(id);

  Future<void> toggleFavorite(int id) async {
    await repository.toggleFavorite(id);
    if (favoriteIds.contains(id)) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }
    notifyListeners();
  }

  void _applyFiltersAndSort() {
    Iterable<Fruit> list = _all;

    if (_activeFilterIds.isNotEmpty) {
      final activePredicates = availableFilters
          .where((f) => _activeFilterIds.contains(f.id))
          .map((f) => f.predicate)
          .toList();
      list = list.where((fruit) {
        for (final p in activePredicates) {
          if (!p(fruit)) return false;
        }
        return true;
      });
    }

    final mutable = list.toList();

    mutable.sort((a, b) {
      switch (sortType) {
        case FruitSortType.nameAsc:
          return a.name.compareTo(b.name);
        case FruitSortType.nameDesc:
          return b.name.compareTo(a.name);
        case FruitSortType.caloriesAsc:
          return a.nutritions.calories.compareTo(b.nutritions.calories);
        case FruitSortType.caloriesDesc:
          return b.nutritions.calories.compareTo(a.nutritions.calories);
      }
    });

    _visible = mutable;
  }
}
