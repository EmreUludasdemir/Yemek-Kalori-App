import 'package:flutter_test/flutter_test.dart';
import 'package:yemek_kalori_app/services/achievement_service.dart';

void main() {
  group('Achievement Service Tests', () {
    test('All achievements should be defined', () {
      expect(allAchievements.isNotEmpty, true);
      expect(allAchievements.length, greaterThan(10));
    });

    test('Achievement IDs should be unique', () {
      final ids = allAchievements.map((a) => a.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length);
    });

    test('First meal achievement should unlock with 1 meal', () {
      final firstMealAchievement = allAchievements.firstWhere(
        (a) => a.id == 'first_meal',
      );

      final stats = UserStats(totalMealsLogged: 1);
      expect(firstMealAchievement.checkCondition(stats), true);

      final noMealStats = UserStats(totalMealsLogged: 0);
      expect(firstMealAchievement.checkCondition(noMealStats), false);
    });

    test('Streak achievements should have correct thresholds', () {
      final streak3 = allAchievements.firstWhere((a) => a.id == 'streak_3');
      final streak7 = allAchievements.firstWhere((a) => a.id == 'streak_7');
      final streak30 = allAchievements.firstWhere((a) => a.id == 'streak_30');

      final stats3 = UserStats(streakDays: 3);
      final stats7 = UserStats(streakDays: 7);
      final stats30 = UserStats(streakDays: 30);

      expect(streak3.checkCondition(stats3), true);
      expect(streak7.checkCondition(stats7), true);
      expect(streak30.checkCondition(stats30), true);

      final stats2 = UserStats(streakDays: 2);
      expect(streak3.checkCondition(stats2), false);
    });

    test('Meal achievements should have ascending points', () {
      final meal10 = allAchievements.firstWhere((a) => a.id == 'meal_10');
      final meal50 = allAchievements.firstWhere((a) => a.id == 'meal_50');
      final meal100 = allAchievements.firstWhere((a) => a.id == 'meal_100');

      expect(meal10.points < meal50.points, true);
      expect(meal50.points < meal100.points, true);
    });

    test('Achievement categories should be valid', () {
      for (final achievement in allAchievements) {
        expect(
          [
            AchievementCategory.meals,
            AchievementCategory.streak,
            AchievementCategory.social,
            AchievementCategory.nutrition,
          ].contains(achievement.category),
          true,
        );
      }
    });

    test('Social achievements should check posts count', () {
      final firstPost = allAchievements.firstWhere((a) => a.id == 'first_post');

      final stats = UserStats(totalPosts: 1);
      expect(firstPost.checkCondition(stats), true);

      final noPostStats = UserStats(totalPosts: 0);
      expect(firstPost.checkCondition(noPostStats), false);
    });
  });

  group('UserStats Tests', () {
    test('UserStats should have default values', () {
      const stats = UserStats();

      expect(stats.totalMealsLogged, 0);
      expect(stats.streakDays, 0);
      expect(stats.totalPosts, 0);
    });

    test('UserStats should accept custom values', () {
      const stats = UserStats(
        totalMealsLogged: 50,
        streakDays: 15,
        totalPosts: 5,
      );

      expect(stats.totalMealsLogged, 50);
      expect(stats.streakDays, 15);
      expect(stats.totalPosts, 5);
    });
  });
}
