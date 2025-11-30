import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/datasources/fruityvice_api_service.dart';
import 'data/datasources/local_storage_service.dart';
import 'data/repositories/fruit_repository.dart';
import 'data/repositories/recipe_repository.dart';
import 'presentation/state/fruit_filters.dart';
import 'presentation/state/fruits_view_model.dart';
import 'presentation/state/recipes_view_model.dart';
import 'presentation/screens/root_tabs_screen.dart';

void main() {
  final api = FruityviceApiService();
  final storage = LocalStorageService();

  final fruitRepository = FruitRepository(api: api, storage: storage);
  final recipeRepository = RecipeRepository(storage: storage);

  runApp(FruitApp(
    fruitRepository: fruitRepository,
    recipeRepository: recipeRepository,
  ));
}

class FruitApp extends StatelessWidget {
  final FruitRepository fruitRepository;
  final RecipeRepository recipeRepository;

  const FruitApp({
    super.key,
    required this.fruitRepository,
    required this.recipeRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // пробрасываем репозитории вниз по дереву
        Provider<FruitRepository>.value(value: fruitRepository),
        Provider<RecipeRepository>.value(value: recipeRepository),

        // список фруктов + фильтры/избранное
        ChangeNotifierProvider(
          create: (_) => FruitsViewModel(
            repository: fruitRepository,
            availableFilters: buildDefaultFilters(),
          )..load(),
        ),

        // список рецептов
        ChangeNotifierProvider(
          create: (_) => RecipesViewModel(
            recipeRepository: recipeRepository,
            fruitRepository: fruitRepository,
          )..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Fruit App',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
        ),
        home: const RootTabsScreen(),
      ),
    );
  }
}
