import '../../data/models/fruit.dart';

abstract class FruitRepositoryBase {
  Future<List<Fruit>> getAllFruits();
  Future<List<int>> getFavoriteIds();
  Future<void> toggleFavorite(int fruitId);
}
