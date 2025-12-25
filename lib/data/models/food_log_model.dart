import 'package:equatable/equatable.dart';

class FoodLog extends Equatable {
  final String id;
  final String userId;
  final String? foodId;
  final String? customFoodName;
  final String mealType; // 'kahvalti', 'ogle', 'aksam', 'ara_ogun'
  final double servingCount;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final String? imageUrl;
  final bool aiRecognized;
  final double? aiConfidence;
  final String? notes;
  final DateTime loggedAt;
  final DateTime createdAt;

  const FoodLog({
    required this.id,
    required this.userId,
    this.foodId,
    this.customFoodName,
    required this.mealType,
    this.servingCount = 1.0,
    required this.calories,
    this.protein = 0,
    this.carbohydrates = 0,
    this.fat = 0,
    this.imageUrl,
    this.aiRecognized = false,
    this.aiConfidence,
    this.notes,
    required this.loggedAt,
    required this.createdAt,
  });

  factory FoodLog.fromJson(Map<String, dynamic> json) {
    return FoodLog(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      foodId: json['food_id'],
      customFoodName: json['custom_food_name'],
      mealType: json['meal_type'] ?? 'ara_ogun',
      servingCount: (json['serving_count'] ?? 1.0).toDouble(),
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbohydrates: (json['carbohydrates'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
      aiRecognized: json['ai_recognized'] ?? false,
      aiConfidence: json['ai_confidence']?.toDouble(),
      notes: json['notes'],
      loggedAt: DateTime.parse(json['logged_at'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'food_id': foodId,
      'custom_food_name': customFoodName,
      'meal_type': mealType,
      'serving_count': servingCount,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'image_url': imageUrl,
      'ai_recognized': aiRecognized,
      'ai_confidence': aiConfidence,
      'notes': notes,
      'logged_at': loggedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get foodName => customFoodName ?? 'Yemek';

  String get mealTypeDisplay {
    switch (mealType) {
      case 'kahvalti':
        return 'Kahvaltı';
      case 'ogle':
        return 'Öğle Yemeği';
      case 'aksam':
        return 'Akşam Yemeği';
      case 'ara_ogun':
        return 'Ara Öğün';
      default:
        return mealType;
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        foodId,
        customFoodName,
        mealType,
        servingCount,
        calories,
        protein,
        carbohydrates,
        fat,
        imageUrl,
        aiRecognized,
        aiConfidence,
        notes,
        loggedAt,
        createdAt,
      ];
}

class DailyNutrition extends Equatable {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int mealCount;
  final List<FoodLog> foodLogs;

  const DailyNutrition({
    this.totalCalories = 0,
    this.totalProtein = 0,
    this.totalCarbs = 0,
    this.totalFat = 0,
    this.mealCount = 0,
    this.foodLogs = const [],
  });

  factory DailyNutrition.fromFoodLogs(List<FoodLog> logs) {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;

    for (var log in logs) {
      calories += log.calories;
      protein += log.protein;
      carbs += log.carbohydrates;
      fat += log.fat;
    }

    return DailyNutrition(
      totalCalories: calories,
      totalProtein: protein,
      totalCarbs: carbs,
      totalFat: fat,
      mealCount: logs.length,
      foodLogs: logs,
    );
  }

  @override
  List<Object?> get props => [
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFat,
        mealCount,
        foodLogs,
      ];
}
