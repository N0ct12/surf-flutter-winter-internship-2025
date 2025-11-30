import '../../data/models/recipe.dart';

abstract class RecipeRepositoryBase {
  Future<List<Recipe>> getAllRecipes();
  Future<void> createRecipe(Recipe recipe);
  Future<void> deleteRecipe(String id);
}
