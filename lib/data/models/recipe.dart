import 'fruit.dart';

class Recipe {
  final String id;          // UUID / timestamp string
  final String title;
  final String? description;
  final List<int> fruitIds; // список id фруктов

  const Recipe({
    required this.id,
    required this.title,
    this.description,
    required this.fruitIds,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      fruitIds: (json['fruitIds'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'fruitIds': fruitIds,
  };
}
