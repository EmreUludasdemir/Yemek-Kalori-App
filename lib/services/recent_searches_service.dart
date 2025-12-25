import 'package:hive_flutter/hive_flutter.dart';

/// Service for managing recent searches
class RecentSearchesService {
  static const String _boxName = 'recent_searches';
  static const int _maxItems = 10;

  /// Get recent searches
  static Future<List<String>> getRecentSearches() async {
    final box = await Hive.openBox<String>(_boxName);
    return box.values.toList();
  }

  /// Add search term
  static Future<void> addSearch(String term) async {
    if (term.trim().isEmpty) return;

    final box = await Hive.openBox<String>(_boxName);

    // Remove if already exists
    final index = box.values.toList().indexOf(term);
    if (index != -1) {
      await box.deleteAt(index);
    }

    // Add to beginning
    await box.add(term);

    // Keep only max items
    if (box.length > _maxItems) {
      await box.deleteAt(0);
    }
  }

  /// Clear all recent searches
  static Future<void> clearAll() async {
    final box = await Hive.openBox<String>(_boxName);
    await box.clear();
  }

  /// Remove specific search
  static Future<void> removeSearch(String term) async {
    final box = await Hive.openBox<String>(_boxName);
    final index = box.values.toList().indexOf(term);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }
}

/// Service for managing favorite foods
class FavoriteFoodsService {
  static const String _boxName = 'favorite_foods';

  /// Get all favorites
  static Future<List<String>> getFavorites() async {
    final box = await Hive.openBox<String>(_boxName);
    return box.values.toList();
  }

  /// Check if food is favorite
  static Future<bool> isFavorite(String foodId) async {
    final box = await Hive.openBox<String>(_boxName);
    return box.values.contains(foodId);
  }

  /// Toggle favorite
  static Future<void> toggleFavorite(String foodId) async {
    final box = await Hive.openBox<String>(_boxName);

    if (box.values.contains(foodId)) {
      // Remove
      final index = box.values.toList().indexOf(foodId);
      await box.deleteAt(index);
    } else {
      // Add
      await box.add(foodId);
    }
  }

  /// Add favorite
  static Future<void> addFavorite(String foodId) async {
    final box = await Hive.openBox<String>(_boxName);
    if (!box.values.contains(foodId)) {
      await box.add(foodId);
    }
  }

  /// Remove favorite
  static Future<void> removeFavorite(String foodId) async {
    final box = await Hive.openBox<String>(_boxName);
    final index = box.values.toList().indexOf(foodId);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }

  /// Clear all favorites
  static Future<void> clearAll() async {
    final box = await Hive.openBox<String>(_boxName);
    await box.clear();
  }
}

/// Service for tracking frequent foods
class FrequentFoodsService {
  static const String _boxName = 'frequent_foods';
  static const int _maxItems = 20;

  /// Get frequent foods (sorted by count)
  static Future<List<FrequentFood>> getFrequentFoods({int limit = 10}) async {
    final box = await Hive.openBox<Map>(_boxName);
    final foods = <FrequentFood>[];

    for (var item in box.values) {
      foods.add(FrequentFood.fromMap(Map<String, dynamic>.from(item)));
    }

    // Sort by count descending
    foods.sort((a, b) => b.count.compareTo(a.count));

    return foods.take(limit).toList();
  }

  /// Increment food count
  static Future<void> incrementFood(String foodId, String foodName) async {
    final box = await Hive.openBox<Map>(_boxName);

    // Find existing
    int? existingIndex;
    for (var i = 0; i < box.length; i++) {
      final item = box.getAt(i);
      if (item?['foodId'] == foodId) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex != null) {
      // Update count
      final existing = box.getAt(existingIndex);
      final count = (existing?['count'] as int? ?? 0) + 1;
      await box.putAt(existingIndex, {
        'foodId': foodId,
        'foodName': foodName,
        'count': count,
        'lastUsed': DateTime.now().toIso8601String(),
      });
    } else {
      // Add new
      await box.add({
        'foodId': foodId,
        'foodName': foodName,
        'count': 1,
        'lastUsed': DateTime.now().toIso8601String(),
      });
    }

    // Remove oldest if exceeds max
    if (box.length > _maxItems) {
      // Find item with lowest count
      int lowestIndex = 0;
      int lowestCount = 999999;
      for (var i = 0; i < box.length; i++) {
        final item = box.getAt(i);
        final count = item?['count'] as int? ?? 0;
        if (count < lowestCount) {
          lowestCount = count;
          lowestIndex = i;
        }
      }
      await box.deleteAt(lowestIndex);
    }
  }

  /// Clear all
  static Future<void> clearAll() async {
    final box = await Hive.openBox<Map>(_boxName);
    await box.clear();
  }
}

class FrequentFood {
  final String foodId;
  final String foodName;
  final int count;
  final DateTime lastUsed;

  FrequentFood({
    required this.foodId,
    required this.foodName,
    required this.count,
    required this.lastUsed,
  });

  factory FrequentFood.fromMap(Map<String, dynamic> map) {
    return FrequentFood(
      foodId: map['foodId'] as String,
      foodName: map['foodName'] as String,
      count: map['count'] as int,
      lastUsed: DateTime.parse(map['lastUsed'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'count': count,
      'lastUsed': lastUsed.toIso8601String(),
    };
  }
}
