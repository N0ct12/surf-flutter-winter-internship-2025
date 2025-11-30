class Nutrition {
  final num calories;
  final num fat;
  final num sugar;
  final num carbohydrates;
  final num protein;

  const Nutrition({
    required this.calories,
    required this.fat,
    required this.sugar,
    required this.carbohydrates,
    required this.protein,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      calories: json['calories'] ?? 0,
      fat: json['fat'] ?? 0,
      sugar: json['sugar'] ?? 0,
      carbohydrates: json['carbohydrates'] ?? 0,
      protein: json['protein'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'fat': fat,
    'sugar': sugar,
    'carbohydrates': carbohydrates,
    'protein': protein,
  };
}
