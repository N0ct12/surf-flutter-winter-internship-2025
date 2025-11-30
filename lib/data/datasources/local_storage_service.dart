import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _favoritesKey = 'favorites_fruit_ids';
  static const _recipesKey = 'recipes';
  static const _fruitsKey = 'cached_fruits'; // НОВЫЙ ключ

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // --- избранное ---

  Future<List<int>> loadFavoriteIds() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_favoritesKey);
    if (jsonStr == null) return [];
    final List<dynamic> decoded = json.decode(jsonStr);
    return decoded.map((e) => e as int).toList();
  }

  Future<void> saveFavoriteIds(List<int> ids) async {
    final prefs = await _prefs;
    await prefs.setString(_favoritesKey, json.encode(ids));
  }

  // --- рецепты ---

  Future<List<Map<String, dynamic>>> loadRecipesRaw() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_recipesKey);
    if (jsonStr == null) return [];
    final List<dynamic> decoded = json.decode(jsonStr);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> saveRecipesRaw(List<Map<String, dynamic>> recipes) async {
    final prefs = await _prefs;
    await prefs.setString(_recipesKey, json.encode(recipes));
  }

  // --- КЭШ ФРУКТОВ ---

  Future<List<Map<String, dynamic>>> loadFruitsRaw() async {
    final prefs = await _prefs;
    final jsonStr = prefs.getString(_fruitsKey);
    if (jsonStr == null) return [];
    final List<dynamic> decoded = json.decode(jsonStr);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> saveFruitsRaw(List<Map<String, dynamic>> fruits) async {
    final prefs = await _prefs;
    await prefs.setString(_fruitsKey, json.encode(fruits));
  }
}
