import 'package:flutter/foundation.dart';

/// Meal plan model for weekly meal planning
class MealPlan {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyMealPlan> dailyPlans;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MealPlan({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.dailyPlans,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      dailyPlans: (json['daily_plans'] as List? ?? [])
          .map((e) => DailyMealPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'daily_plans': dailyPlans.map((e) => e.toJson()).toList(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get daily plan for a specific date
  DailyMealPlan? getDailyPlan(DateTime date) {
    return dailyPlans.firstWhere(
      (plan) => isSameDay(plan.date, date),
      orElse: () => DailyMealPlan.empty(date),
    );
  }

  /// Check if two dates are the same day
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get total planned calories for the week
  double get totalPlannedCalories {
    return dailyPlans.fold(0, (sum, plan) => sum + plan.totalCalories);
  }

  /// Get average daily calories
  double get averageDailyCalories {
    return dailyPlans.isEmpty ? 0 : totalPlannedCalories / dailyPlans.length;
  }
}

/// Daily meal plan containing all meals for a day
class DailyMealPlan {
  final DateTime date;
  final List<PlannedMeal> meals;

  DailyMealPlan({
    required this.date,
    required this.meals,
  });

  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    return DailyMealPlan(
      date: DateTime.parse(json['date'] as String),
      meals: (json['meals'] as List? ?? [])
          .map((e) => PlannedMeal.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'meals': meals.map((e) => e.toJson()).toList(),
    };
  }

  factory DailyMealPlan.empty(DateTime date) {
    return DailyMealPlan(
      date: date,
      meals: [],
    );
  }

  /// Get meals by type
  List<PlannedMeal> getMealsByType(String mealType) {
    return meals.where((meal) => meal.mealType == mealType).toList();
  }

  /// Get total calories for the day
  double get totalCalories {
    return meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  /// Get total protein for the day
  double get totalProtein {
    return meals.fold(0, (sum, meal) => sum + meal.protein);
  }

  /// Get total carbs for the day
  double get totalCarbs {
    return meals.fold(0, (sum, meal) => sum + meal.carbohydrates);
  }

  /// Get total fat for the day
  double get totalFat {
    return meals.fold(0, (sum, meal) => sum + meal.fat);
  }
}

/// Planned meal item
class PlannedMeal {
  final String id;
  final String mealType; // kahvalti, ogle, aksam, ara_ogun
  final String foodId;
  final String foodName;
  final String? imageUrl;
  final double servingCount;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final String? notes;

  PlannedMeal({
    required this.id,
    required this.mealType,
    required this.foodId,
    required this.foodName,
    this.imageUrl,
    this.servingCount = 1.0,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    this.notes,
  });

  factory PlannedMeal.fromJson(Map<String, dynamic> json) {
    return PlannedMeal(
      id: json['id'] as String,
      mealType: json['meal_type'] as String,
      foodId: json['food_id'] as String,
      foodName: json['food_name'] as String,
      imageUrl: json['image_url'] as String?,
      servingCount: (json['serving_count'] as num?)?.toDouble() ?? 1.0,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal_type': mealType,
      'food_id': foodId,
      'food_name': foodName,
      'image_url': imageUrl,
      'serving_count': servingCount,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'notes': notes,
    };
  }

  /// Get meal type display name
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
}

/// Meal template for quick meal planning
class MealTemplate {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? category; // breakfast, lunch, dinner, snack
  final List<TemplateMeal> meals;
  final bool isPublic;
  final int useCount;
  final DateTime createdAt;

  MealTemplate({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.category,
    required this.meals,
    this.isPublic = false,
    this.useCount = 0,
    required this.createdAt,
  });

  factory MealTemplate.fromJson(Map<String, dynamic> json) {
    return MealTemplate(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      meals: (json['meals'] as List? ?? [])
          .map((e) => TemplateMeal.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPublic: json['is_public'] as bool? ?? false,
      useCount: json['use_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'category': category,
      'meals': meals.map((e) => e.toJson()).toList(),
      'is_public': isPublic,
      'use_count': useCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get total calories in template
  double get totalCalories {
    return meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  /// Get total protein in template
  double get totalProtein {
    return meals.fold(0, (sum, meal) => sum + meal.protein);
  }

  /// Get total carbs in template
  double get totalCarbs {
    return meals.fold(0, (sum, meal) => sum + meal.carbohydrates);
  }

  /// Get total fat in template
  double get totalFat {
    return meals.fold(0, (sum, meal) => sum + meal.fat);
  }
}

/// Template meal item
class TemplateMeal {
  final String foodId;
  final String foodName;
  final String? imageUrl;
  final double servingCount;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;

  TemplateMeal({
    required this.foodId,
    required this.foodName,
    this.imageUrl,
    this.servingCount = 1.0,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
  });

  factory TemplateMeal.fromJson(Map<String, dynamic> json) {
    return TemplateMeal(
      foodId: json['food_id'] as String,
      foodName: json['food_name'] as String,
      imageUrl: json['image_url'] as String?,
      servingCount: (json['serving_count'] as num?)?.toDouble() ?? 1.0,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'image_url': imageUrl,
      'serving_count': servingCount,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
    };
  }
}
