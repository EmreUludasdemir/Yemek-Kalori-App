import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../data/models/meal_plan_model.dart';
import '../data/models/food_item_model.dart';

/// Service for managing meal plans
class MealPlanningService {
  static const _uuid = Uuid();

  /// Create a new meal plan
  static Future<MealPlan> createMealPlan({
    required String userId,
    required String name,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    // Generate daily plans for the date range
    final dailyPlans = <DailyMealPlan>[];
    var currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
           (currentDate.year == endDate.year &&
            currentDate.month == endDate.month &&
            currentDate.day == endDate.day)) {
      dailyPlans.add(DailyMealPlan.empty(currentDate));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    final mealPlan = MealPlan(
      id: id,
      userId: userId,
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      dailyPlans: dailyPlans,
      isActive: true,
      createdAt: now,
    );

    await SupabaseConfig.client.from('meal_plans').insert({
      'id': mealPlan.id,
      'user_id': mealPlan.userId,
      'name': mealPlan.name,
      'description': mealPlan.description,
      'start_date': mealPlan.startDate.toIso8601String(),
      'end_date': mealPlan.endDate.toIso8601String(),
      'daily_plans': mealPlan.dailyPlans.map((e) => e.toJson()).toList(),
      'is_active': mealPlan.isActive,
      'created_at': mealPlan.createdAt.toIso8601String(),
    });

    return mealPlan;
  }

  /// Get active meal plan for user
  static Future<MealPlan?> getActiveMealPlan(String userId) async {
    final response = await SupabaseConfig.client
        .from('meal_plans')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return MealPlan.fromJson(response);
  }

  /// Get all meal plans for user
  static Future<List<MealPlan>> getMealPlans(String userId) async {
    final response = await SupabaseConfig.client
        .from('meal_plans')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => MealPlan.fromJson(e)).toList();
  }

  /// Get meal plan by ID
  static Future<MealPlan?> getMealPlan(String planId) async {
    final response = await SupabaseConfig.client
        .from('meal_plans')
        .select()
        .eq('id', planId)
        .maybeSingle();

    if (response == null) return null;
    return MealPlan.fromJson(response);
  }

  /// Update meal plan
  static Future<void> updateMealPlan(MealPlan mealPlan) async {
    await SupabaseConfig.client.from('meal_plans').update({
      'name': mealPlan.name,
      'description': mealPlan.description,
      'daily_plans': mealPlan.dailyPlans.map((e) => e.toJson()).toList(),
      'is_active': mealPlan.isActive,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', mealPlan.id);
  }

  /// Delete meal plan
  static Future<void> deleteMealPlan(String planId) async {
    await SupabaseConfig.client.from('meal_plans').delete().eq('id', planId);
  }

  /// Add meal to plan
  static Future<PlannedMeal> addMealToPlan({
    required String planId,
    required DateTime date,
    required String mealType,
    required FoodItem food,
    double servingCount = 1.0,
    String? notes,
  }) async {
    final plan = await getMealPlan(planId);
    if (plan == null) throw Exception('Meal plan not found');

    final mealId = _uuid.v4();
    final plannedMeal = PlannedMeal(
      id: mealId,
      mealType: mealType,
      foodId: food.id,
      foodName: food.displayName,
      imageUrl: food.imageUrl,
      servingCount: servingCount,
      calories: food.calories * servingCount,
      protein: food.protein * servingCount,
      carbohydrates: food.carbohydrates * servingCount,
      fat: food.fat * servingCount,
      notes: notes,
    );

    // Find or create daily plan for the date
    var dailyPlan = plan.getDailyPlan(date);
    if (dailyPlan == null) {
      dailyPlan = DailyMealPlan(date: date, meals: [plannedMeal]);
      plan.dailyPlans.add(dailyPlan);
    } else {
      final index = plan.dailyPlans.indexOf(dailyPlan);
      plan.dailyPlans[index] = DailyMealPlan(
        date: dailyPlan.date,
        meals: [...dailyPlan.meals, plannedMeal],
      );
    }

    await updateMealPlan(plan);
    return plannedMeal;
  }

  /// Remove meal from plan
  static Future<void> removeMealFromPlan({
    required String planId,
    required DateTime date,
    required String mealId,
  }) async {
    final plan = await getMealPlan(planId);
    if (plan == null) throw Exception('Meal plan not found');

    final dailyPlan = plan.getDailyPlan(date);
    if (dailyPlan == null) return;

    final index = plan.dailyPlans.indexOf(dailyPlan);
    plan.dailyPlans[index] = DailyMealPlan(
      date: dailyPlan.date,
      meals: dailyPlan.meals.where((m) => m.id != mealId).toList(),
    );

    await updateMealPlan(plan);
  }

  /// Create meal template from actual meals
  static Future<MealTemplate> createTemplate({
    required String userId,
    required String name,
    String? description,
    String? category,
    required List<FoodItem> foods,
    bool isPublic = false,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final templateMeals = foods.map((food) {
      return TemplateMeal(
        foodId: food.id,
        foodName: food.displayName,
        imageUrl: food.imageUrl,
        servingCount: 1.0,
        calories: food.calories,
        protein: food.protein,
        carbohydrates: food.carbohydrates,
        fat: food.fat,
      );
    }).toList();

    final template = MealTemplate(
      id: id,
      userId: userId,
      name: name,
      description: description,
      category: category,
      meals: templateMeals,
      isPublic: isPublic,
      createdAt: now,
    );

    await SupabaseConfig.client.from('meal_templates').insert({
      'id': template.id,
      'user_id': template.userId,
      'name': template.name,
      'description': template.description,
      'category': template.category,
      'meals': template.meals.map((e) => e.toJson()).toList(),
      'is_public': template.isPublic,
      'use_count': 0,
      'created_at': template.createdAt.toIso8601String(),
    });

    return template;
  }

  /// Get user's meal templates
  static Future<List<MealTemplate>> getTemplates(String userId) async {
    final response = await SupabaseConfig.client
        .from('meal_templates')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => MealTemplate.fromJson(e)).toList();
  }

  /// Get public meal templates
  static Future<List<MealTemplate>> getPublicTemplates() async {
    final response = await SupabaseConfig.client
        .from('meal_templates')
        .select()
        .eq('is_public', true)
        .order('use_count', ascending: false)
        .limit(20);

    return (response as List).map((e) => MealTemplate.fromJson(e)).toList();
  }

  /// Apply template to meal plan
  static Future<void> applyTemplate({
    required String planId,
    required DateTime date,
    required String mealType,
    required MealTemplate template,
  }) async {
    final plan = await getMealPlan(planId);
    if (plan == null) throw Exception('Meal plan not found');

    // Add all meals from template
    for (final templateMeal in template.meals) {
      final mealId = _uuid.v4();
      final plannedMeal = PlannedMeal(
        id: mealId,
        mealType: mealType,
        foodId: templateMeal.foodId,
        foodName: templateMeal.foodName,
        imageUrl: templateMeal.imageUrl,
        servingCount: templateMeal.servingCount,
        calories: templateMeal.calories,
        protein: templateMeal.protein,
        carbohydrates: templateMeal.carbohydrates,
        fat: templateMeal.fat,
      );

      var dailyPlan = plan.getDailyPlan(date);
      if (dailyPlan == null) {
        dailyPlan = DailyMealPlan(date: date, meals: [plannedMeal]);
        plan.dailyPlans.add(dailyPlan);
      } else {
        final index = plan.dailyPlans.indexOf(dailyPlan);
        plan.dailyPlans[index] = DailyMealPlan(
          date: dailyPlan.date,
          meals: [...dailyPlan.meals, plannedMeal],
        );
      }
    }

    await updateMealPlan(plan);

    // Increment template use count
    await SupabaseConfig.client.from('meal_templates').update({
      'use_count': template.useCount + 1,
    }).eq('id', template.id);
  }

  /// Copy meal plan to food logs
  static Future<void> copyPlanToLogs({
    required String planId,
    required DateTime date,
  }) async {
    final plan = await getMealPlan(planId);
    if (plan == null) throw Exception('Meal plan not found');

    final dailyPlan = plan.getDailyPlan(date);
    if (dailyPlan == null || dailyPlan.meals.isEmpty) return;

    final userId = plan.userId;
    final now = DateTime.now();

    // Create food logs for each planned meal
    for (final meal in dailyPlan.meals) {
      await SupabaseConfig.client.from('food_logs').insert({
        'user_id': userId,
        'food_id': meal.foodId,
        'food_name': meal.foodName,
        'image_url': meal.imageUrl,
        'meal_type': meal.mealType,
        'serving_count': meal.servingCount,
        'calories': meal.calories,
        'protein': meal.protein,
        'carbohydrates': meal.carbohydrates,
        'fat': meal.fat,
        'logged_at': now.toIso8601String(),
        'notes': meal.notes,
      });
    }
  }

  /// Generate smart meal plan based on calorie target
  static Future<MealPlan> generateSmartMealPlan({
    required String userId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required double dailyCalorieTarget,
    required List<FoodItem> availableFoods,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    // Simple algorithm: distribute calories across meals (30% breakfast, 40% lunch, 30% dinner)
    final breakfastCalories = dailyCalorieTarget * 0.30;
    final lunchCalories = dailyCalorieTarget * 0.40;
    final dinnerCalories = dailyCalorieTarget * 0.30;

    final dailyPlans = <DailyMealPlan>[];
    var currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
           (currentDate.year == endDate.year &&
            currentDate.month == endDate.month &&
            currentDate.day == endDate.day)) {
      final meals = <PlannedMeal>[];

      // Add breakfast
      meals.addAll(_selectMealsForTarget(
        availableFoods,
        'kahvalti',
        breakfastCalories,
      ));

      // Add lunch
      meals.addAll(_selectMealsForTarget(
        availableFoods,
        'ogle',
        lunchCalories,
      ));

      // Add dinner
      meals.addAll(_selectMealsForTarget(
        availableFoods,
        'aksam',
        dinnerCalories,
      ));

      dailyPlans.add(DailyMealPlan(
        date: currentDate,
        meals: meals,
      ));

      currentDate = currentDate.add(const Duration(days: 1));
    }

    final mealPlan = MealPlan(
      id: id,
      userId: userId,
      name: name,
      description: 'Otomatik oluşturuldu ($dailyCalorieTarget kcal/gün)',
      startDate: startDate,
      endDate: endDate,
      dailyPlans: dailyPlans,
      isActive: true,
      createdAt: now,
    );

    await SupabaseConfig.client.from('meal_plans').insert({
      'id': mealPlan.id,
      'user_id': mealPlan.userId,
      'name': mealPlan.name,
      'description': mealPlan.description,
      'start_date': mealPlan.startDate.toIso8601String(),
      'end_date': mealPlan.endDate.toIso8601String(),
      'daily_plans': mealPlan.dailyPlans.map((e) => e.toJson()).toList(),
      'is_active': mealPlan.isActive,
      'created_at': mealPlan.createdAt.toIso8601String(),
    });

    return mealPlan;
  }

  /// Select meals to match target calories
  static List<PlannedMeal> _selectMealsForTarget(
    List<FoodItem> foods,
    String mealType,
    double targetCalories,
  ) {
    final meals = <PlannedMeal>[];
    var currentCalories = 0.0;

    // Filter foods suitable for meal type
    final suitableFoods = foods.where((food) {
      // Simple categorization based on meal type
      if (mealType == 'kahvalti') {
        return food.category == 'breakfast' ||
               food.displayName.toLowerCase().contains('kahvaltı') ||
               food.displayName.toLowerCase().contains('yumurta') ||
               food.displayName.toLowerCase().contains('peynir');
      } else if (mealType == 'ara_ogun') {
        return food.calories < 300; // Light snacks
      }
      return true;
    }).toList();

    // Randomly select foods to match target (simple algorithm)
    final random = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < suitableFoods.length && currentCalories < targetCalories * 0.9; i++) {
      final food = suitableFoods[(random + i) % suitableFoods.length];

      meals.add(PlannedMeal(
        id: _uuid.v4(),
        mealType: mealType,
        foodId: food.id,
        foodName: food.displayName,
        imageUrl: food.imageUrl,
        servingCount: 1.0,
        calories: food.calories,
        protein: food.protein,
        carbohydrates: food.carbohydrates,
        fat: food.fat,
      ));

      currentCalories += food.calories;
    }

    return meals;
  }
}
