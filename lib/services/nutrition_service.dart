import 'package:dio/dio.dart';
import '../config/supabase_config.dart';
import '../data/models/food_item_model.dart';

class NutritionService {
  final Dio _dio = Dio();

  // TODO: Add your FatSecret API credentials
  static const String _fatSecretApiKey = String.fromEnvironment(
    'FATSECRET_API_KEY',
    defaultValue: '',
  );

  /// Search foods in local database (Turkish foods)
  Future<List<FoodItem>> searchLocalFoods(String query) async {
    try {
      if (query.trim().isEmpty) {
        // Return popular Turkish foods if no query
        final response = await SupabaseConfig.client
            .from('foods')
            .select()
            .or('source.eq.turkomp,is_verified.eq.true')
            .limit(20);

        return (response as List).map((e) => FoodItem.fromJson(e)).toList();
      }

      // Search by name (using PostgreSQL full-text search)
      final response = await SupabaseConfig.client
          .from('foods')
          .select()
          .textSearch('name_tr', query, config: 'turkish')
          .limit(50);

      if (response.isNotEmpty) {
        return (response as List).map((e) => FoodItem.fromJson(e)).toList();
      }

      // Fallback: Use ilike for partial matching
      final fallbackResponse = await SupabaseConfig.client
          .from('foods')
          .select()
          .ilike('name_tr', '%$query%')
          .limit(50);

      return (fallbackResponse as List)
          .map((e) => FoodItem.fromJson(e))
          .toList();
    } catch (e) {
      print('❌ Error searching local foods: $e');
      return [];
    }
  }

  /// Search foods by category
  Future<List<FoodItem>> getFoodsByCategory(String category) async {
    try {
      final response = await SupabaseConfig.client
          .from('foods')
          .select()
          .eq('category', category)
          .limit(50);

      return (response as List).map((e) => FoodItem.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error fetching foods by category: $e');
      return [];
    }
  }

  /// Get popular Turkish foods
  Future<List<FoodItem>> getPopularTurkishFoods() async {
    try {
      final response = await SupabaseConfig.client
          .from('foods')
          .select()
          .eq('source', 'turkomp')
          .limit(20);

      return (response as List).map((e) => FoodItem.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error fetching popular foods: $e');
      return [];
    }
  }

  /// Get recently added foods by user
  Future<List<FoodItem>> getRecentFoods(String userId) async {
    try {
      // Get food IDs from recent logs
      final logsResponse = await SupabaseConfig.client
          .from('food_logs')
          .select('food_id')
          .eq('user_id', userId)
          .not('food_id', 'is', null)
          .order('created_at', ascending: false)
          .limit(10);

      if (logsResponse.isEmpty) return [];

      final foodIds = (logsResponse as List)
          .map((e) => e['food_id'] as String)
          .toSet()
          .toList();

      if (foodIds.isEmpty) return [];

      // Get food details
      final foodsResponse = await SupabaseConfig.client
          .from('foods')
          .select()
          .in_('id', foodIds);

      return (foodsResponse as List).map((e) => FoodItem.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error fetching recent foods: $e');
      return [];
    }
  }

  /// Search food by barcode
  Future<FoodItem?> searchByBarcode(String barcode) async {
    try {
      // 1. Search in local database first
      final localResponse = await SupabaseConfig.client
          .from('foods')
          .select()
          .eq('barcode', barcode)
          .maybeSingle();

      if (localResponse != null) {
        return FoodItem.fromJson(localResponse);
      }

      // 2. TODO: Search in Open Food Facts API
      // For now, return null
      return null;
    } catch (e) {
      print('❌ Error searching by barcode: $e');
      return null;
    }
  }

  /// Search foods using FatSecret API
  /// Note: Requires API key setup
  Future<List<FoodItem>> searchFatSecret(String query) async {
    if (_fatSecretApiKey.isEmpty) {
      print('⚠️ FatSecret API key not configured');
      return [];
    }

    try {
      // TODO: Implement FatSecret API OAuth 1.0 authentication
      // This is a placeholder for future implementation

      // FatSecret API requires OAuth 1.0 which is complex
      // For MVP, we'll use local database only

      return [];
    } catch (e) {
      print('❌ FatSecret API error: $e');
      return [];
    }
  }

  /// Create a custom food item
  Future<FoodItem?> createCustomFood({
    required String name,
    required double servingSize,
    required String servingUnit,
    required double calories,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
  }) async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await SupabaseConfig.client.from('foods').insert({
        'name_tr': name,
        'serving_size': servingSize,
        'serving_unit': servingUnit,
        'calories': calories,
        'protein': protein,
        'carbohydrates': carbs,
        'fat': fat,
        'source': 'user',
        'is_verified': false,
        'created_by': userId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();

      return FoodItem.fromJson(response);
    } catch (e) {
      print('❌ Error creating custom food: $e');
      return null;
    }
  }

  /// Get food categories
  List<String> getCategories() {
    return [
      'kahvalti',
      'ana_yemek',
      'corba',
      'salata',
      'tatli',
      'icecek',
      'meze',
    ];
  }

  /// Get category display name
  String getCategoryDisplay(String category) {
    switch (category) {
      case 'kahvalti':
        return 'Kahvaltılık';
      case 'ana_yemek':
        return 'Ana Yemek';
      case 'corba':
        return 'Çorba';
      case 'salata':
        return 'Salata';
      case 'tatli':
        return 'Tatlı';
      case 'icecek':
        return 'İçecek';
      case 'meze':
        return 'Meze';
      default:
        return category;
    }
  }
}
