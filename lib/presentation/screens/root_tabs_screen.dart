import 'package:flutter/material.dart';
import 'fruits/fruits_list_screen.dart';
import 'favorites/favorites_screen.dart';
import 'recipes/recipes_list_screen.dart';

class RootTabsScreen extends StatefulWidget {
  const RootTabsScreen({super.key});

  @override
  State<RootTabsScreen> createState() => _RootTabsScreenState();
}

class _RootTabsScreenState extends State<RootTabsScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      FruitsListScreen(),
      FavoritesScreen(),
      RecipesListScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Фрукты',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Избранное',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu),
            label: 'Рецепты',
          ),
        ],
        onDestinationSelected: (i) {
          setState(() => _index = i);
        },
      ),
    );
  }
}
