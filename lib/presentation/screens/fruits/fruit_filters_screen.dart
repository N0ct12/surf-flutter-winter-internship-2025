import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/fruits_view_model.dart';
import '../../state/fruit_filters.dart';

class FruitFiltersScreen extends StatelessWidget {
  const FruitFiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FruitsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильтры'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Сортировка', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _SortRadio(
            title: 'По названию (A-Z)',
            value: FruitSortType.nameAsc,
            groupValue: vm.sortType,
            onChanged: (v) => vm.setSortType(v),
          ),
          _SortRadio(
            title: 'По названию (Z-A)',
            value: FruitSortType.nameDesc,
            groupValue: vm.sortType,
            onChanged: (v) => vm.setSortType(v),
          ),
          _SortRadio(
            title: 'По калориям (по возрастанию)',
            value: FruitSortType.caloriesAsc,
            groupValue: vm.sortType,
            onChanged: (v) => vm.setSortType(v),
          ),
          _SortRadio(
            title: 'По калориям (по убыванию)',
            value: FruitSortType.caloriesDesc,
            groupValue: vm.sortType,
            onChanged: (v) => vm.setSortType(v),
          ),
          const SizedBox(height: 16),
          const Text('Фильтры', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...vm.availableFilters.map(
                (f) => CheckboxListTile(
              title: Text(f.title),
              value: vm.isFilterActive(f.id),
              onChanged: (_) => vm.toggleFilter(f.id),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // изменения уже применены
            },
            child: const Text('Применить'),
          ),
        ],
      ),
    );
  }
}

class _SortRadio extends StatelessWidget {
  final String title;
  final FruitSortType value;
  final FruitSortType groupValue;
  final void Function(FruitSortType) onChanged;

  const _SortRadio({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<FruitSortType>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
