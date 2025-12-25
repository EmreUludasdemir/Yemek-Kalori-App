import 'package:flutter/material.dart';
import '../data/models/food_item_model.dart';
import '../config/supabase_config.dart';

/// Service for providing smart food suggestions
class SmartSuggestionsService {
  /// Get meal time suggestions based on current time
  static String getCurrentMealTime() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 11) {
      return 'breakfast';
    } else if (hour >= 11 && hour < 16) {
      return 'lunch';
    } else if (hour >= 16 && hour < 21) {
      return 'dinner';
    } else {
      return 'snack';
    }
  }

  /// Get meal time display name in Turkish
  static String getMealTimeDisplayName(String mealTime) {
    switch (mealTime) {
      case 'breakfast':
        return 'Kahvaltı';
      case 'lunch':
        return 'Öğle Yemeği';
      case 'dinner':
        return 'Akşam Yemeği';
      case 'snack':
        return 'Ara Öğün';
      default:
        return 'Öğün';
    }
  }

  /// Get meal time icon
  static IconData getMealTimeIcon(String mealTime) {
    switch (mealTime) {
      case 'breakfast':
        return Icons.wb_sunny_outlined;
      case 'lunch':
        return Icons.lunch_dining_outlined;
      case 'dinner':
        return Icons.dinner_dining_outlined;
      case 'snack':
        return Icons.cookie_outlined;
      default:
        return Icons.restaurant;
    }
  }

  /// Suggest foods based on meal time
  static Future<List<FoodItem>> getSuggestedFoods({
    String? mealTime,
    int limit = 5,
  }) async {
    final targetMealTime = mealTime ?? getCurrentMealTime();
    final category = _getMealTimeCategory(targetMealTime);

    try {
      var query = SupabaseConfig.client.from('foods').select();

      if (category != null) {
        query = query.eq('category', category);
      }

      final response = await query.limit(limit);

      return (response as List)
          .map((json) => FoodItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting suggested foods: $e');
      return [];
    }
  }

  /// Get category for meal time
  static String? _getMealTimeCategory(String mealTime) {
    switch (mealTime) {
      case 'breakfast':
        return 'Kahvaltı';
      case 'lunch':
      case 'dinner':
        return 'Ana Yemek';
      case 'snack':
        return 'Tatlı';
      default:
        return null;
    }
  }

  /// Get similar foods based on a food item
  static Future<List<FoodItem>> getSimilarFoods(
    FoodItem food, {
    int limit = 5,
  }) async {
    try {
      // Get foods from same category with similar calories
      final calorieRange = food.calories * 0.2; // ±20%

      final response = await SupabaseConfig.client
          .from('foods')
          .select()
          .eq('category', food.category)
          .gte('calories', food.calories - calorieRange)
          .lte('calories', food.calories + calorieRange)
          .neq('id', food.id) // Exclude the current food
          .limit(limit);

      return (response as List)
          .map((json) => FoodItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting similar foods: $e');
      return [];
    }
  }

  /// Get complementary foods (good pairings)
  static Future<List<FoodItem>> getComplementaryFoods(
    FoodItem food, {
    int limit = 5,
  }) async {
    try {
      // Logic: If high protein, suggest carbs; if high carbs, suggest protein
      String? targetCategory;

      if (food.protein > food.carbohydrates && food.protein > food.fat) {
        // High protein food -> suggest carbs
        targetCategory = 'Tahıllar';
      } else if (food.carbohydrates > food.protein &&
          food.carbohydrates > food.fat) {
        // High carbs food -> suggest protein
        targetCategory = 'Et & Tavuk';
      }

      if (targetCategory == null) {
        // Default to different category
        final response = await SupabaseConfig.client
            .from('foods')
            .select()
            .neq('category', food.category)
            .limit(limit);

        return (response as List)
            .map((json) => FoodItem.fromJson(json))
            .toList();
      }

      final response = await SupabaseConfig.client
          .from('foods')
          .select()
          .eq('category', targetCategory)
          .limit(limit);

      return (response as List)
          .map((json) => FoodItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting complementary foods: $e');
      return [];
    }
  }

  /// Get popular foods (most frequently logged)
  static Future<List<FoodItem>> getPopularFoods({int limit = 10}) async {
    try {
      // Get most logged foods from food_logs
      final response = await SupabaseConfig.client
          .from('food_logs')
          .select('food_id, foods!inner(*)')
          .limit(100);

      // Count frequency
      final foodCounts = <String, int>{};
      for (var log in response as List) {
        final foodId = log['food_id'] as String;
        foodCounts[foodId] = (foodCounts[foodId] ?? 0) + 1;
      }

      // Sort by frequency
      final sortedFoodIds = foodCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Get top foods
      final topFoodIds = sortedFoodIds.take(limit).map((e) => e.key).toList();

      if (topFoodIds.isEmpty) {
        return [];
      }

      final foodsResponse = await SupabaseConfig.client
          .from('foods')
          .select()
          .in_('id', topFoodIds);

      return (foodsResponse as List)
          .map((json) => FoodItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting popular foods: $e');
      return [];
    }
  }

  /// Get balanced meal suggestion
  static Future<Map<String, List<FoodItem>>> getBalancedMeal() async {
    try {
      // Suggest: 1 protein + 1 carb + 1 vegetable
      final protein = await SupabaseConfig.client
          .from('foods')
          .select()
          .eq('category', 'Et & Tavuk')
          .limit(1);

      final carb = await SupabaseConfig.client
          .from('foods')
          .select()
          .eq('category', 'Tahıllar')
          .limit(1);

      final vegetable = await SupabaseConfig.client
          .from('foods')
          .select()
          .eq('category', 'Sebzeler')
          .limit(1);

      return {
        'protein': (protein as List).map((j) => FoodItem.fromJson(j)).toList(),
        'carb': (carb as List).map((j) => FoodItem.fromJson(j)).toList(),
        'vegetable': (vegetable as List).map((j) => FoodItem.fromJson(j)).toList(),
      };
    } catch (e) {
      print('Error getting balanced meal: $e');
      return {};
    }
  }

  /// Get calorie budget suggestion
  static String getCalorieBudgetSuggestion({
    required double consumed,
    required double target,
  }) {
    final remaining = target - consumed;
    final percentage = (consumed / target) * 100;

    if (percentage < 50) {
      return 'Günün yarısından azını tükettin. Düzenli öğün yapmayı unutma! 💪';
    } else if (percentage >= 50 && percentage < 80) {
      return 'İyi gidiyorsun! Kalan ${remaining.toInt()} kcal için dengeli atıştırmalıklar seçebilirsin. 🥗';
    } else if (percentage >= 80 && percentage < 100) {
      return 'Hedefe yaklaşıyorsun! Kalan ${remaining.toInt()} kcal için hafif atıştırmalıklar önerilir. 🍎';
    } else if (percentage >= 100 && percentage < 110) {
      return 'Günlük hedefini tamamladın! Dengeli beslenmeye devam et. ✅';
    } else {
      final excess = consumed - target;
      return 'Hedefin ${excess.toInt()} kcal üzerindesin. Yarın daha dikkatli olabilirsin. 😊';
    }
  }

  /// Get hydration reminder
  static String getHydrationReminder(int glassesConsumed) {
    if (glassesConsumed == 0) {
      return 'Bugün henüz su içmedin! Hemen bir bardak su iç. 💧';
    } else if (glassesConsumed < 4) {
      return '${8 - glassesConsumed} bardak daha! Su içmeyi unutma. 💦';
    } else if (glassesConsumed < 8) {
      return 'İyi gidiyorsun! ${8 - glassesConsumed} bardak kaldı. 💙';
    } else {
      return 'Harika! Günlük su hedefini tamamladın! 🎉';
    }
  }

  /// Get motivational message based on streak
  static String getStreakMotivation(int streak) {
    if (streak == 0) {
      return 'Yeni bir başlangıç! İlk günün hayırlı olsun. 🌟';
    } else if (streak < 7) {
      return '$streak gün! Harika gidiyorsun! 🔥';
    } else if (streak < 30) {
      return '$streak günlük seri! İnanılmaz bir disiplin! 💪';
    } else if (streak < 100) {
      return 'WOW! $streak gün! Bir efsanesin! 🏆';
    } else {
      return '🌟 $streak GÜN! Sen bir süperstarsin! 🌟';
    }
  }

  /// Get workout suggestion based on calories
  static String getWorkoutSuggestion({
    required double excessCalories,
  }) {
    if (excessCalories < 100) {
      return '10 dakika yürüyüş yeterli! 🚶';
    } else if (excessCalories < 200) {
      return '20 dakika koşu veya 30 dakika yürüyüş önerilir. 🏃';
    } else if (excessCalories < 300) {
      return '30 dakika koşu veya 45 dakika bisiklet sürmeyi dene. 🚴';
    } else {
      return '1 saat aktif egzersiz (koşu, yüzme, bisiklet) önerilir. 💪';
    }
  }
}
