import 'package:equatable/equatable.dart';

class NutritionInfo extends Equatable {
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final double? saturatedFat;
  final double? cholesterol;

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.saturatedFat,
    this.cholesterol,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbohydrates: (json['carbohydrates'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: json['fiber']?.toDouble(),
      sugar: json['sugar']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
      saturatedFat: json['saturated_fat']?.toDouble(),
      cholesterol: json['cholesterol']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'saturated_fat': saturatedFat,
      'cholesterol': cholesterol,
    };
  }

  @override
  List<Object?> get props => [
        calories,
        protein,
        carbohydrates,
        fat,
        fiber,
        sugar,
        sodium,
        saturatedFat,
        cholesterol,
      ];
}
