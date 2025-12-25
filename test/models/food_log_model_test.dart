import 'package:flutter_test/flutter_test.dart';
import 'package:yemek_kalori_app/data/models/food_log_model.dart';

void main() {
  group('FoodLog Model Tests', () {
    test('FoodLog should be created from JSON correctly', () {
      final json = {
        'id': 'test-id-123',
        'user_id': 'user-123',
        'food_id': 'food-456',
        'meal_type': 'kahvalti',
        'food_name': 'Menemen',
        'serving_count': 1.5,
        'serving_size': 150.0,
        'serving_unit': 'g',
        'calories': 225.0,
        'protein': 12.5,
        'carbohydrates': 8.0,
        'fat': 15.0,
        'fiber': 2.0,
        'logged_at': '2024-01-15T08:30:00Z',
        'ai_recognized': false,
      };

      final foodLog = FoodLog.fromJson(json);

      expect(foodLog.id, 'test-id-123');
      expect(foodLog.mealType, 'kahvalti');
      expect(foodLog.foodName, 'Menemen');
      expect(foodLog.servingCount, 1.5);
      expect(foodLog.calories, 225.0);
      expect(foodLog.protein, 12.5);
      expect(foodLog.aiRecognized, false);
    });

    test('FoodLog should convert to JSON correctly', () {
      final foodLog = FoodLog(
        id: 'test-id-123',
        userId: 'user-123',
        foodId: 'food-456',
        mealType: 'ogle',
        foodName: 'Döner',
        servingCount: 2.0,
        servingSize: 150.0,
        servingUnit: 'g',
        calories: 530.0,
        protein: 36.0,
        carbohydrates: 24.0,
        fat: 32.0,
        fiber: 0.0,
        sugar: 2.0,
        sodium: 800.0,
        loggedAt: DateTime.parse('2024-01-15T12:30:00Z'),
        aiRecognized: true,
        aiConfidence: 0.95,
        createdAt: DateTime.parse('2024-01-15T12:30:00Z'),
      );

      final json = foodLog.toJson();

      expect(json['id'], 'test-id-123');
      expect(json['meal_type'], 'ogle');
      expect(json['food_name'], 'Döner');
      expect(json['serving_count'], 2.0);
      expect(json['calories'], 530.0);
      expect(json['ai_recognized'], true);
      expect(json['ai_confidence'], 0.95);
    });
  });

  group('DailyNutrition Model Tests', () {
    test('DailyNutrition should aggregate from food logs correctly', () {
      final logs = [
        FoodLog(
          id: '1',
          userId: 'user-1',
          foodId: 'food-1',
          mealType: 'kahvalti',
          foodName: 'Yumurta',
          servingCount: 2.0,
          servingSize: 50.0,
          servingUnit: 'adet',
          calories: 140.0,
          protein: 12.0,
          carbohydrates: 2.0,
          fat: 10.0,
          fiber: 0.0,
          sugar: 0.0,
          sodium: 140.0,
          loggedAt: DateTime.now(),
          aiRecognized: false,
          createdAt: DateTime.now(),
        ),
        FoodLog(
          id: '2',
          userId: 'user-1',
          foodId: 'food-2',
          mealType: 'ogle',
          foodName: 'Pilav',
          servingCount: 1.0,
          servingSize: 200.0,
          servingUnit: 'g',
          calories: 280.0,
          protein: 6.0,
          carbohydrates: 60.0,
          fat: 2.0,
          fiber: 1.0,
          sugar: 0.0,
          sodium: 200.0,
          loggedAt: DateTime.now(),
          aiRecognized: false,
          createdAt: DateTime.now(),
        ),
      ];

      final dailyNutrition = DailyNutrition.fromFoodLogs(logs);

      expect(dailyNutrition.totalCalories, 420.0);
      expect(dailyNutrition.totalProtein, 18.0);
      expect(dailyNutrition.totalCarbs, 62.0);
      expect(dailyNutrition.totalFat, 12.0);
      expect(dailyNutrition.mealCount, 2);
      expect(dailyNutrition.foodLogs.length, 2);
    });

    test('Empty DailyNutrition should have zero values', () {
      const dailyNutrition = DailyNutrition();

      expect(dailyNutrition.totalCalories, 0.0);
      expect(dailyNutrition.totalProtein, 0.0);
      expect(dailyNutrition.totalCarbs, 0.0);
      expect(dailyNutrition.totalFat, 0.0);
      expect(dailyNutrition.mealCount, 0);
      expect(dailyNutrition.foodLogs.isEmpty, true);
    });
  });
}
