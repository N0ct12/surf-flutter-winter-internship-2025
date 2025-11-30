import '../../data/models/fruit.dart';

enum FruitSortType {
  nameAsc,
  nameDesc,
  caloriesAsc,
  caloriesDesc,
}

// Примеры фильтров – под свои цели можно допилить
class FruitFilter {
  final String id;
  final String title;
  final bool Function(Fruit fruit) predicate;

  FruitFilter({
    required this.id,
    required this.title,
    required this.predicate,
  });
}

List<FruitFilter> buildDefaultFilters() {
  return [
    FruitFilter(
      id: 'low_calories',
      title: 'До 50 ккал',
      predicate: (f) => f.nutritions.calories <= 50,
    ),
    FruitFilter(
      id: 'high_protein',
      title: 'Белок ≥ 2 г',
      predicate: (f) => f.nutritions.protein >= 2,
    ),
    FruitFilter(
      id: 'low_sugar',
      title: 'Сахар ≤ 6 г',
      predicate: (f) => f.nutritions.sugar <= 6,
    ),
  ];
}