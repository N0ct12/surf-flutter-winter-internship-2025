import '../datasources/local_storage_service.dart';
import '../models/recipe.dart';
import '../../domain/repositories/recipe_repository_base.dart';

class RecipeRepository implements RecipeRepositoryBase {
  final LocalStorageService storage;

  RecipeRepository({required this.storage});

  @override
  Future<List<Recipe>> getAllRecipes() async {
    final raw = await storage.loadRecipesRaw();
    return raw.map((e) => Recipe.fromJson(e)).toList();
  }

  @override
  Future<void> createRecipe(Recipe recipe) async {
    final raw = await storage.loadRecipesRaw();
    raw.add(recipe.toJson());
    await storage.saveRecipesRaw(raw);
  }

  @override
  Future<void> deleteRecipe(String id) async {
    final raw = await storage.loadRecipesRaw();
    raw.removeWhere((e) => e['id'] == id);
    await storage.saveRecipesRaw(raw);
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    final raw = await storage.loadRecipesRaw();
    final index = raw.indexWhere((e) => e['id'] == recipe.id);
    if (index >= 0) {
      raw[index] = recipe.toJson();
    } else {
      // на всякий случай, если не нашли - добавим как новый
      raw.add(recipe.toJson());
    }
    await storage.saveRecipesRaw(raw);
  }
}
