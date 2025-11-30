import 'package:flutter/foundation.dart';

import '../../data/models/fruit.dart';
import '../../data/models/nutrition.dart';
import '../../data/models/recipe.dart';
import '../../data/repositories/fruit_repository.dart';
import '../../data/repositories/recipe_repository.dart';

enum RecipesStatus { initial, loading, loaded, error }

class RecipeWithDetails {
  final Recipe recipe;
  final List<Fruit> fruits;
  final Nutrition totalNutrition;

  RecipeWithDetails({
    required this.recipe,
    required this.fruits,
    required this.totalNutrition,
  });
}

class RecipesViewModel extends ChangeNotifier {
  final RecipeRepository recipeRepository;
  final FruitRepository fruitRepository;

  RecipesStatus status = RecipesStatus.initial;
  String? errorMessage;

  List<RecipeWithDetails> items = [];

  RecipesViewModel({
    required this.recipeRepository,
    required this.fruitRepository,
  });

  Future<void> load() async {
    status = RecipesStatus.loading;
    notifyListeners();
    try {
      final allFruits = await fruitRepository.getAllFruits();
      final recipes = await recipeRepository.getAllRecipes();

      items = recipes.map((recipe) {
        final recipeFruits = <Fruit>[];
        for (final id in recipe.fruitIds) {
          final f = _findFruitById(allFruits, id);
          if (f != null) {
            recipeFruits.add(f);
          }
        }
        final total = _sumNutrition(recipeFruits);
        return RecipeWithDetails(
          recipe: recipe,
          fruits: recipeFruits,
          totalNutrition: total,
        );
      }).toList();

      status = RecipesStatus.loaded;
    } catch (e) {
      errorMessage = e.toString();
      status = RecipesStatus.error;
    }
    notifyListeners();
  }

  Future<void> deleteRecipe(String id) async {
    await recipeRepository.deleteRecipe(id);
    await load();
  }

  Fruit? _findFruitById(List<Fruit> fruits, int id) {
    for (final f in fruits) {
      if (f.id == id) return f;
    }
    return null;
  }

  Nutrition _sumNutrition(List<Fruit> fruits) {
    num cal = 0, fat = 0, sugar = 0, carbs = 0, protein = 0;
    for (final f in fruits) {
      cal += f.nutritions.calories;
      fat += f.nutritions.fat;
      sugar += f.nutritions.sugar;
      carbs += f.nutritions.carbohydrates;
      protein += f.nutritions.protein;
    }
    return Nutrition(
      calories: cal,
      fat: fat,
      sugar: sugar,
      carbohydrates: carbs,
      protein: protein,
    );
  }
}
