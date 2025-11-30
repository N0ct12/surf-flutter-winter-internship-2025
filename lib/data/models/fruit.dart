import 'nutrition.dart';

class Fruit {
  final int id;
  final String name;
  final String family;
  final String order;
  final String genus;
  final Nutrition nutritions;

  const Fruit({
    required this.id,
    required this.name,
    required this.family,
    required this.order,
    required this.genus,
    required this.nutritions,
  });

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      family: json['family']?.toString().trim() ?? '',
      order: json['order']?.toString().trim() ?? '',
      genus: json['genus'] ?? '',
      nutritions: Nutrition.fromJson(json['nutritions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'family': family,
    'order': order,
    'genus': genus,
    'nutritions': nutritions.toJson(),
  };
}
