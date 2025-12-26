class Recipe {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty; // kolay, orta, zor
  final String category; // Ana Yemek, Çorba, Tatlı, etc.
  final List<String> tags;
  final NutritionInfo nutritionInfo;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.category,
    this.tags = const [],
    required this.nutritionInfo,
    this.isPremium = false,
    required this.createdAt,
    this.updatedAt,
  });

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      prepTimeMinutes: json['prep_time_minutes'] as int? ?? 0,
      cookTimeMinutes: json['cook_time_minutes'] as int? ?? 0,
      servings: json['servings'] as int? ?? 1,
      difficulty: json['difficulty'] as String? ?? 'orta',
      category: json['category'] as String? ?? 'Ana Yemek',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      nutritionInfo: json['nutrition_info'] != null
          ? NutritionInfo.fromJson(json['nutrition_info'] as Map<String, dynamic>)
          : NutritionInfo.empty(),
      isPremium: json['is_premium'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps.map((e) => e.toJson()).toList(),
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'category': category,
      'tags': tags,
      'nutrition_info': nutritionInfo.toJson(),
      'is_premium': isPremium,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    List<RecipeIngredient>? ingredients,
    List<RecipeStep>? steps,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    String? difficulty,
    String? category,
    List<String>? tags,
    NutritionInfo? nutritionInfo,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RecipeIngredient {
  final String name;
  final double amount;
  final String unit; // gr, ml, adet, su bardağı, çay kaşığı, yemek kaşığı, etc.
  final String? notes;

  RecipeIngredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.notes,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'notes': notes,
    };
  }

  String get displayText {
    final amountStr = amount % 1 == 0 ? amount.toInt().toString() : amount.toString();
    return '$amountStr $unit $name${notes != null ? " ($notes)" : ""}';
  }
}

class RecipeStep {
  final int stepNumber;
  final String instruction;
  final String? imageUrl;
  final int? durationMinutes;
  final String? tip;

  RecipeStep({
    required this.stepNumber,
    required this.instruction,
    this.imageUrl,
    this.durationMinutes,
    this.tip,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      stepNumber: json['step_number'] as int,
      instruction: json['instruction'] as String,
      imageUrl: json['image_url'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      tip: json['tip'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step_number': stepNumber,
      'instruction': instruction,
      'image_url': imageUrl,
      'duration_minutes': durationMinutes,
      'tip': tip,
    };
  }
}

class NutritionInfo {
  final double caloriesPerServing;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double fiberGrams;
  final double sugarGrams;
  final double sodiumMg;

  NutritionInfo({
    required this.caloriesPerServing,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.fiberGrams = 0,
    this.sugarGrams = 0,
    this.sodiumMg = 0,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      caloriesPerServing: (json['calories_per_serving'] as num?)?.toDouble() ?? 0,
      proteinGrams: (json['protein_grams'] as num?)?.toDouble() ?? 0,
      carbsGrams: (json['carbs_grams'] as num?)?.toDouble() ?? 0,
      fatGrams: (json['fat_grams'] as num?)?.toDouble() ?? 0,
      fiberGrams: (json['fiber_grams'] as num?)?.toDouble() ?? 0,
      sugarGrams: (json['sugar_grams'] as num?)?.toDouble() ?? 0,
      sodiumMg: (json['sodium_mg'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories_per_serving': caloriesPerServing,
      'protein_grams': proteinGrams,
      'carbs_grams': carbsGrams,
      'fat_grams': fatGrams,
      'fiber_grams': fiberGrams,
      'sugar_grams': sugarGrams,
      'sodium_mg': sodiumMg,
    };
  }

  factory NutritionInfo.empty() {
    return NutritionInfo(
      caloriesPerServing: 0,
      proteinGrams: 0,
      carbsGrams: 0,
      fatGrams: 0,
    );
  }
}

/// User's saved recipes
class SavedRecipe {
  final String id;
  final String userId;
  final String recipeId;
  final DateTime savedAt;
  final String? notes;

  SavedRecipe({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.savedAt,
    this.notes,
  });

  factory SavedRecipe.fromJson(Map<String, dynamic> json) {
    return SavedRecipe(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      recipeId: json['recipe_id'] as String,
      savedAt: DateTime.parse(json['saved_at'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'saved_at': savedAt.toIso8601String(),
      'notes': notes,
    };
  }
}
