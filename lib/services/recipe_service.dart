import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/recipe_model.dart';
import '../data/models/paginated_response.dart';
import '../config/supabase_config.dart';

/// Service for managing recipes
class RecipeService {
  static final _supabase = SupabaseConfig.client;

  // ==================== Recipe CRUD ====================

  /// Fetch all recipes with optional filters
  static Future<List<Recipe>> fetchRecipes({
    String? category,
    String? difficulty,
    bool? isPremium,
    List<String>? tags,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('recipes')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      if (category != null) {
        query = query.eq('category', category);
      }

      if (difficulty != null) {
        query = query.eq('difficulty', difficulty);
      }

      if (isPremium != null) {
        query = query.eq('is_premium', isPremium);
      }

      final response = await query;
      return (response as List).map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching recipes: $e');
      return [];
    }
  }

  /// Get recipe by ID
  static Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .eq('id', recipeId)
          .single();

      return Recipe.fromJson(response);
    } catch (e) {
      print('Error fetching recipe: $e');
      return null;
    }
  }

  /// Search recipes by name or ingredients
  static Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('name')
          .limit(20);

      return (response as List).map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      print('Error searching recipes: $e');
      return [];
    }
  }

  /// Get recipes by category
  static Future<List<Recipe>> getRecipesByCategory(String category) async {
    return fetchRecipes(category: category);
  }

  /// Get popular recipes (most saved)
  static Future<List<Recipe>> getPopularRecipes({int limit = 10}) async {
    try {
      // Get most saved recipe IDs
      final savedCounts = await _supabase.rpc('get_popular_recipes', params: {
        'limit_count': limit,
      });

      if (savedCounts == null || (savedCounts as List).isEmpty) {
        return fetchRecipes(limit: limit);
      }

      final recipeIds = (savedCounts as List).map((r) => r['recipe_id'] as String).toList();

      final response = await _supabase
          .from('recipes')
          .select()
          .in_('id', recipeIds);

      return (response as List).map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching popular recipes: $e');
      return fetchRecipes(limit: limit);
    }
  }

  /// Get recommended recipes based on user's dietary preferences
  static Future<List<Recipe>> getRecommendedRecipes({
    required String userId,
    int limit = 10,
  }) async {
    try {
      // Get user's calorie goal and preferences
      final userProfile = await _supabase
          .from('profiles')
          .select('daily_calorie_goal')
          .eq('id', userId)
          .single();

      final calorieGoal = userProfile['daily_calorie_goal'] as int? ?? 2000;

      // Find recipes with appropriate calorie range (per serving)
      final targetCalories = calorieGoal / 3; // Approximate per meal
      final minCal = targetCalories * 0.7;
      final maxCal = targetCalories * 1.3;

      final response = await _supabase
          .from('recipes')
          .select()
          .gte('nutrition_info->calories_per_serving', minCal)
          .lte('nutrition_info->calories_per_serving', maxCal)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching recommended recipes: $e');
      return fetchRecipes(limit: limit);
    }
  }

  // ==================== Saved Recipes ====================

  /// Save recipe for user
  static Future<bool> saveRecipe({
    required String userId,
    required String recipeId,
    String? notes,
  }) async {
    try {
      await _supabase.from('saved_recipes').insert({
        'user_id': userId,
        'recipe_id': recipeId,
        'notes': notes,
        'saved_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error saving recipe: $e');
      return false;
    }
  }

  /// Unsave recipe for user
  static Future<bool> unsaveRecipe({
    required String userId,
    required String recipeId,
  }) async {
    try {
      await _supabase
          .from('saved_recipes')
          .delete()
          .eq('user_id', userId)
          .eq('recipe_id', recipeId);

      return true;
    } catch (e) {
      print('Error unsaving recipe: $e');
      return false;
    }
  }

  /// Check if recipe is saved by user
  static Future<bool> isRecipeSaved({
    required String userId,
    required String recipeId,
  }) async {
    try {
      final response = await _supabase
          .from('saved_recipes')
          .select()
          .eq('user_id', userId)
          .eq('recipe_id', recipeId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking saved recipe: $e');
      return false;
    }
  }

  /// Get user's saved recipes
  static Future<List<Recipe>> getSavedRecipes(String userId) async {
    try {
      final response = await _supabase
          .from('saved_recipes')
          .select('recipe_id, recipes(*)')
          .eq('user_id', userId)
          .order('saved_at', ascending: false);

      return (response as List)
          .map((item) => Recipe.fromJson(item['recipes']))
          .toList();
    } catch (e) {
      print('Error fetching saved recipes: $e');
      return [];
    }
  }

  // ==================== Cooking Mode ====================

  /// Start cooking session
  static Future<String?> startCookingSession({
    required String userId,
    required String recipeId,
  }) async {
    try {
      final response = await _supabase.from('cooking_sessions').insert({
        'user_id': userId,
        'recipe_id': recipeId,
        'started_at': DateTime.now().toIso8601String(),
        'current_step': 1,
        'is_completed': false,
      }).select().single();

      return response['id'] as String;
    } catch (e) {
      print('Error starting cooking session: $e');
      return null;
    }
  }

  /// Update cooking session step
  static Future<bool> updateCookingStep({
    required String sessionId,
    required int stepNumber,
  }) async {
    try {
      await _supabase.from('cooking_sessions').update({
        'current_step': stepNumber,
      }).eq('id', sessionId);

      return true;
    } catch (e) {
      print('Error updating cooking step: $e');
      return false;
    }
  }

  /// Complete cooking session
  static Future<bool> completeCookingSession(String sessionId) async {
    try {
      await _supabase.from('cooking_sessions').update({
        'is_completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', sessionId);

      return true;
    } catch (e) {
      print('Error completing cooking session: $e');
      return false;
    }
  }

  /// Get active cooking session for recipe
  static Future<Map<String, dynamic>?> getActiveCookingSession({
    required String userId,
    required String recipeId,
  }) async {
    try {
      final response = await _supabase
          .from('cooking_sessions')
          .select()
          .eq('user_id', userId)
          .eq('recipe_id', recipeId)
          .eq('is_completed', false)
          .order('started_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching cooking session: $e');
      return null;
    }
  }

  // ==================== Categories & Tags ====================

  /// Get all recipe categories
  static List<String> getCategories() {
    return [
      'Ana Yemek',
      'Çorba',
      'Tatlı',
      'Salata',
      'Aperatif',
      'Kahvaltı',
      'İçecek',
      'Atıştırmalık',
    ];
  }

  /// Get difficulty levels
  static List<String> getDifficultyLevels() {
    return ['Kolay', 'Orta', 'Zor'];
  }

  /// Get popular tags
  static List<String> getPopularTags() {
    return [
      'Türk Mutfağı',
      'Vejeteryan',
      'Vegan',
      'Glutensiz',
      'Laktosuz',
      'Düşük Kalorili',
      'Yüksek Protein',
      'Hızlı',
      'Ekonomik',
      'Ramazan',
      'Bayram',
    ];
  }

  // ==================== Recipe Statistics ====================

  /// Get recipe stats (saves, completions)
  static Future<Map<String, int>> getRecipeStats(String recipeId) async {
    try {
      // Get save count
      final saveCount = await _supabase
          .from('saved_recipes')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('recipe_id', recipeId);

      // Get completion count
      final completionCount = await _supabase
          .from('cooking_sessions')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('recipe_id', recipeId)
          .eq('is_completed', true);

      return {
        'saves': saveCount.count ?? 0,
        'completions': completionCount.count ?? 0,
      };
    } catch (e) {
      print('Error fetching recipe stats: $e');
      return {'saves': 0, 'completions': 0};
    }
  }

  /// Get user's cooking history
  static Future<List<Map<String, dynamic>>> getCookingHistory(String userId) async {
    try {
      final response = await _supabase
          .from('cooking_sessions')
          .select('*, recipes(*)')
          .eq('user_id', userId)
          .eq('is_completed', true)
          .order('completed_at', ascending: false)
          .limit(20);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching cooking history: $e');
      return [];
    }
  }

  // ==================== Admin Functions (for seed data) ====================

  /// Create sample Turkish recipes (admin only)
  static Future<bool> seedSampleRecipes() async {
    try {
      final recipes = _getSampleRecipes();

      for (final recipe in recipes) {
        await _supabase.from('recipes').insert(recipe.toJson());
      }

      return true;
    } catch (e) {
      print('Error seeding recipes: $e');
      return false;
    }
  }

  static List<Recipe> _getSampleRecipes() {
    return [
      Recipe(
        id: 'recipe_1',
        name: 'Mercimek Çorbası',
        description: 'Geleneksel Türk mercimek çorbası. Sağlıklı ve doyurucu.',
        ingredients: [
          RecipeIngredient(name: 'Kırmızı mercimek', amount: 1, unit: 'su bardağı'),
          RecipeIngredient(name: 'Soğan', amount: 1, unit: 'adet'),
          RecipeIngredient(name: 'Havuç', amount: 1, unit: 'adet'),
          RecipeIngredient(name: 'Sıvı yağ', amount: 2, unit: 'yemek kaşığı'),
          RecipeIngredient(name: 'Tuz', amount: 1, unit: 'çay kaşığı'),
          RecipeIngredient(name: 'Su', amount: 6, unit: 'su bardağı'),
        ],
        steps: [
          RecipeStep(
            stepNumber: 1,
            instruction: 'Mercimekleri yıkayın ve süzün.',
            durationMinutes: 2,
          ),
          RecipeStep(
            stepNumber: 2,
            instruction: 'Soğan ve havucu küp küp doğrayın.',
            durationMinutes: 5,
          ),
          RecipeStep(
            stepNumber: 3,
            instruction: 'Tencerede yağı kızdırın, soğan ve havucu kavurun.',
            durationMinutes: 5,
          ),
          RecipeStep(
            stepNumber: 4,
            instruction: 'Mercimek ve suyu ekleyin, kaynatın.',
            durationMinutes: 3,
          ),
          RecipeStep(
            stepNumber: 5,
            instruction: 'Kısık ateşte 20 dakika pişirin.',
            durationMinutes: 20,
            tip: 'Mercimekler yumuşayana kadar pişirin.',
          ),
          RecipeStep(
            stepNumber: 6,
            instruction: 'Blender ile püre yapın, tuz ekleyin.',
            durationMinutes: 3,
          ),
        ],
        prepTimeMinutes: 10,
        cookTimeMinutes: 28,
        servings: 4,
        difficulty: 'Kolay',
        category: 'Çorba',
        tags: ['Türk Mutfağı', 'Vejeteryan', 'Düşük Kalorili'],
        nutritionInfo: NutritionInfo(
          caloriesPerServing: 180,
          proteinGrams: 9,
          carbsGrams: 28,
          fatGrams: 4,
          fiberGrams: 7,
        ),
        isPremium: false,
        createdAt: DateTime.now(),
      ),
      Recipe(
        id: 'recipe_2',
        name: 'Tavuk Şiş',
        description: 'Marine edilmiş tavuk göğsü şiş. Izgara veya fırında.',
        ingredients: [
          RecipeIngredient(name: 'Tavuk göğsü', amount: 500, unit: 'gr'),
          RecipeIngredient(name: 'Yoğurt', amount: 3, unit: 'yemek kaşığı'),
          RecipeIngredient(name: 'Zeytinyağı', amount: 2, unit: 'yemek kaşığı'),
          RecipeIngredient(name: 'Sarımsak', amount: 2, unit: 'diş'),
          RecipeIngredient(name: 'Kekik', amount: 1, unit: 'çay kaşığı'),
          RecipeIngredient(name: 'Pul biber', amount: 1, unit: 'çay kaşığı'),
          RecipeIngredient(name: 'Tuz, karabiber', amount: 1, unit: 'çay kaşığı'),
        ],
        steps: [
          RecipeStep(
            stepNumber: 1,
            instruction: 'Tavukları küp küp doğrayın.',
            durationMinutes: 5,
          ),
          RecipeStep(
            stepNumber: 2,
            instruction: 'Marine malzemelerini karıştırın.',
            durationMinutes: 2,
          ),
          RecipeStep(
            stepNumber: 3,
            instruction: 'Tavukları marine edin, 2 saat bekletin.',
            durationMinutes: 120,
            tip: 'Daha uzun beklettikçe lezzet artar.',
          ),
          RecipeStep(
            stepNumber: 4,
            instruction: 'Şişlere dizin.',
            durationMinutes: 5,
          ),
          RecipeStep(
            stepNumber: 5,
            instruction: 'Izgara veya fırında pişirin (200°C, 25 dk).',
            durationMinutes: 25,
          ),
        ],
        prepTimeMinutes: 132,
        cookTimeMinutes: 25,
        servings: 4,
        difficulty: 'Orta',
        category: 'Ana Yemek',
        tags: ['Türk Mutfağı', 'Yüksek Protein', 'Düşük Kalorili'],
        nutritionInfo: NutritionInfo(
          caloriesPerServing: 220,
          proteinGrams: 32,
          carbsGrams: 4,
          fatGrams: 8,
        ),
        isPremium: false,
        createdAt: DateTime.now(),
      ),
    ];
  }

  // ==================== Pagination Methods ====================

  /// Fetch recipes with pagination
  static Future<PaginatedResponse<Recipe>> fetchRecipesPaginated({
    String? category,
    String? difficulty,
    bool? isPremium,
    required PaginationParams params,
  }) async {
    try {
      // Build base query for count
      var countQuery = _supabase
          .from('recipes')
          .select('id', const FetchOptions(count: CountOption.exact));

      if (category != null) {
        countQuery = countQuery.eq('category', category);
      }
      if (difficulty != null) {
        countQuery = countQuery.eq('difficulty', difficulty);
      }
      if (isPremium != null) {
        countQuery = countQuery.eq('is_premium', isPremium);
      }

      final countResponse = await countQuery;
      final totalCount = countResponse.count ?? 0;

      // Fetch recipes
      final recipes = await fetchRecipes(
        category: category,
        difficulty: difficulty,
        isPremium: isPremium,
        limit: params.limit,
        offset: params.offset,
      );

      final hasMore = (params.offset + recipes.length) < totalCount;

      return PaginatedResponse<Recipe>(
        items: recipes,
        currentPage: params.page,
        pageSize: params.pageSize,
        totalCount: totalCount,
        hasMore: hasMore,
      );
    } catch (e) {
      print('Error fetching paginated recipes: $e');
      return PaginatedResponse.empty();
    }
  }

  /// Get saved recipes with pagination
  static Future<PaginatedResponse<Recipe>> getSavedRecipesPaginated({
    required String userId,
    required PaginationParams params,
  }) async {
    try {
      // Get total count
      final countResponse = await _supabase
          .from('saved_recipes')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('user_id', userId);

      final totalCount = countResponse.count ?? 0;

      // Fetch saved recipes with pagination
      final response = await _supabase
          .from('saved_recipes')
          .select('recipe_id, recipes(*)')
          .eq('user_id', userId)
          .order('saved_at', ascending: false)
          .range(params.offset, params.offset + params.limit - 1);

      final recipes = (response as List)
          .map((item) => Recipe.fromJson(item['recipes']))
          .toList();

      final hasMore = (params.offset + recipes.length) < totalCount;

      return PaginatedResponse<Recipe>(
        items: recipes,
        currentPage: params.page,
        pageSize: params.pageSize,
        totalCount: totalCount,
        hasMore: hasMore,
      );
    } catch (e) {
      print('Error fetching paginated saved recipes: $e');
      return PaginatedResponse.empty();
    }
  }
}
