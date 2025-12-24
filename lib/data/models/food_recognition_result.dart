import 'package:equatable/equatable.dart';
import 'nutrition_model.dart';

class Ingredient extends Equatable {
  final String name;
  final double quantity;
  final String unit;
  final NutritionInfo? nutrition;

  const Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.nutrition,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'gram',
      nutrition: json['nutrition'] != null
          ? NutritionInfo.fromJson(json['nutrition'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'nutrition': nutrition?.toJson(),
    };
  }

  @override
  List<Object?> get props => [name, quantity, unit, nutrition];
}

class FoodRecognitionResult extends Equatable {
  final String foodName;
  final String? foodNameEn;
  final double confidence;
  final NutritionInfo nutrition;
  final String? imageUrl;
  final List<Ingredient> suggestedIngredients;
  final double servingSize;
  final String servingUnit;
  final String? category;
  final String source; // 'tflite', 'calorie_mama', 'manual'

  const FoodRecognitionResult({
    required this.foodName,
    this.foodNameEn,
    required this.confidence,
    required this.nutrition,
    this.imageUrl,
    this.suggestedIngredients = const [],
    required this.servingSize,
    required this.servingUnit,
    this.category,
    required this.source,
  });

  factory FoodRecognitionResult.fromJson(Map<String, dynamic> json) {
    return FoodRecognitionResult(
      foodName: json['food_name'] ?? '',
      foodNameEn: json['food_name_en'],
      confidence: (json['confidence'] ?? 0).toDouble(),
      nutrition: NutritionInfo.fromJson(json['nutrition'] ?? {}),
      imageUrl: json['image_url'],
      suggestedIngredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e))
              .toList() ??
          [],
      servingSize: (json['serving_size'] ?? 100).toDouble(),
      servingUnit: json['serving_unit'] ?? 'gram',
      category: json['category'],
      source: json['source'] ?? 'manual',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'food_name_en': foodNameEn,
      'confidence': confidence,
      'nutrition': nutrition.toJson(),
      'image_url': imageUrl,
      'ingredients': suggestedIngredients.map((e) => e.toJson()).toList(),
      'serving_size': servingSize,
      'serving_unit': servingUnit,
      'category': category,
      'source': source,
    };
  }

  FoodRecognitionResult copyWith({
    String? foodName,
    String? foodNameEn,
    double? confidence,
    NutritionInfo? nutrition,
    String? imageUrl,
    List<Ingredient>? suggestedIngredients,
    double? servingSize,
    String? servingUnit,
    String? category,
    String? source,
  }) {
    return FoodRecognitionResult(
      foodName: foodName ?? this.foodName,
      foodNameEn: foodNameEn ?? this.foodNameEn,
      confidence: confidence ?? this.confidence,
      nutrition: nutrition ?? this.nutrition,
      imageUrl: imageUrl ?? this.imageUrl,
      suggestedIngredients: suggestedIngredients ?? this.suggestedIngredients,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      category: category ?? this.category,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [
        foodName,
        foodNameEn,
        confidence,
        nutrition,
        imageUrl,
        suggestedIngredients,
        servingSize,
        servingUnit,
        category,
        source,
      ];
}
