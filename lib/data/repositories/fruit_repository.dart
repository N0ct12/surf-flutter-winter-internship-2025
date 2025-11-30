import 'package:collection/collection.dart';

import '../datasources/fruityvice_api_service.dart';
import '../datasources/local_storage_service.dart';
import '../models/fruit.dart';
import '../../domain/repositories/fruit_repository_base.dart';

class FruitRepository implements FruitRepositoryBase {
  final FruityviceApiService api;
  final LocalStorageService storage;

  List<Fruit>? _cache;

  FruitRepository({
    required this.api,
    required this.storage,
  });

  @override
  Future<List<Fruit>> getAllFruits() async {
    // если уже загружали в этом запуске — просто вернуть
    if (_cache != null) return _cache!;

    // 1. Пытаемся сходить в интернет
    try {
      final list = await api.fetchAllFruits();
      _cache = list;

      // сохраняем кэш локально
      final raw = list.map((f) => f.toJson()).toList();
      await storage.saveFruitsRaw(raw);

      return _cache!;
    } catch (_) {
      // 2. Интернет не сработал — пробуем прочитать кэш
      final raw = await storage.loadFruitsRaw();
      if (raw.isNotEmpty) {
        _cache = raw.map((e) => Fruit.fromJson(e)).toList();
        return _cache!;
      }
      // 3. Кэш пустой — значит ни разу не было успешной загрузки
      rethrow;
    }
  }

  @override
  Future<List<int>> getFavoriteIds() async {
    return storage.loadFavoriteIds();
  }

  @override
  Future<void> toggleFavorite(int fruitId) async {
    final ids = await storage.loadFavoriteIds();
    final idx = ids.indexOf(fruitId);
    if (idx >= 0) {
      ids.removeAt(idx);
    } else {
      ids.add(fruitId);
    }
    await storage.saveFavoriteIds(ids);
  }

  Future<List<Fruit>> getFavoriteFruits() async {
    final all = await getAllFruits();
    final favIds = await getFavoriteIds();
    final favSet = favIds.toSet();
    return all.where((f) => favSet.contains(f.id)).toList();
  }

  Fruit? findById(int id) {
    return _cache?.firstWhereOrNull((f) => f.id == id);
  }
}
