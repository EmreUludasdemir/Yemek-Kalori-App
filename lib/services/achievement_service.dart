import 'package:flutter/material.dart';

import '../config/supabase_config.dart';
import '../core/constants/app_colors.dart';

/// Achievement service for tracking and unlocking user achievements
class AchievementService {
  /// Check and unlock achievements for a user
  Future<List<Achievement>> checkAndUnlockAchievements(String userId) async {
    final newlyUnlocked = <Achievement>[];

    try {
      // Get user stats
      final stats = await _getUserStats(userId);

      // Check each achievement
      for (final achievement in allAchievements) {
        final isUnlocked = await _isAchievementUnlocked(userId, achievement.id);
        if (!isUnlocked && achievement.checkCondition(stats)) {
          await _unlockAchievement(userId, achievement.id);
          newlyUnlocked.add(achievement);
        }
      }
    } catch (e) {
      print('Error checking achievements: $e');
    }

    return newlyUnlocked;
  }

  /// Get all achievements for a user (with unlock status)
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    try {
      final unlockedResponse = await SupabaseConfig.client
          .from('user_achievements')
          .select('achievement_id, unlocked_at')
          .eq('user_id', userId);

      final unlockedIds = (unlockedResponse as List)
          .map((e) => e['achievement_id'] as String)
          .toSet();

      final unlockedDates = Map.fromEntries(
        (unlockedResponse).map((e) => MapEntry(
              e['achievement_id'] as String,
              DateTime.parse(e['unlocked_at'] as String),
            )),
      );

      return allAchievements.map((achievement) {
        return UserAchievement(
          achievement: achievement,
          isUnlocked: unlockedIds.contains(achievement.id),
          unlockedAt: unlockedDates[achievement.id],
        );
      }).toList();
    } catch (e) {
      print('Error getting user achievements: $e');
      return allAchievements
          .map((a) => UserAchievement(achievement: a, isUnlocked: false))
          .toList();
    }
  }

  Future<bool> _isAchievementUnlocked(String userId, String achievementId) async {
    try {
      final response = await SupabaseConfig.client
          .from('user_achievements')
          .select('id')
          .eq('user_id', userId)
          .eq('achievement_id', achievementId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> _unlockAchievement(String userId, String achievementId) async {
    try {
      await SupabaseConfig.client.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': achievementId,
        'unlocked_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error unlocking achievement: $e');
    }
  }

  Future<UserStats> _getUserStats(String userId) async {
    try {
      // Get total meals
      final logsResponse = await SupabaseConfig.client
          .from('food_logs')
          .select('id')
          .eq('user_id', userId);

      final totalMeals = (logsResponse as List).length;

      // Get streak
      final profileResponse = await SupabaseConfig.client
          .from('profiles')
          .select('streak_days')
          .eq('id', userId)
          .maybeSingle();

      final streakDays = profileResponse?['streak_days'] as int? ?? 0;

      // Get total posts
      final postsResponse = await SupabaseConfig.client
          .from('posts')
          .select('id')
          .eq('user_id', userId);

      final totalPosts = (postsResponse as List).length;

      return UserStats(
        totalMealsLogged: totalMeals,
        streakDays: streakDays,
        totalPosts: totalPosts,
      );
    } catch (e) {
      print('Error getting user stats: $e');
      return UserStats();
    }
  }
}

/// Achievement model
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int points;
  final AchievementCategory category;
  final bool Function(UserStats stats) checkCondition;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.points,
    required this.category,
    required this.checkCondition,
  });
}

/// User achievement with unlock status
class UserAchievement {
  final Achievement achievement;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  UserAchievement({
    required this.achievement,
    required this.isUnlocked,
    this.unlockedAt,
  });
}

/// Achievement categories
enum AchievementCategory {
  meals,
  streak,
  social,
  nutrition,
}

/// User statistics for achievement checking
class UserStats {
  final int totalMealsLogged;
  final int streakDays;
  final int totalPosts;

  UserStats({
    this.totalMealsLogged = 0,
    this.streakDays = 0,
    this.totalPosts = 0,
  });
}

/// All available achievements
final List<Achievement> allAchievements = [
  // Meal logging achievements
  Achievement(
    id: 'first_meal',
    title: 'İlk Adım',
    description: 'İlk yemeğini kaydet',
    icon: Icons.restaurant,
    color: AppColors.primary,
    points: 10,
    category: AchievementCategory.meals,
    checkCondition: (stats) => stats.totalMealsLogged >= 1,
  ),
  Achievement(
    id: 'meal_10',
    title: 'On Yemek',
    description: '10 yemek kaydet',
    icon: Icons.restaurant_menu,
    color: AppColors.primary,
    points: 25,
    category: AchievementCategory.meals,
    checkCondition: (stats) => stats.totalMealsLogged >= 10,
  ),
  Achievement(
    id: 'meal_50',
    title: 'Elli Yemek',
    description: '50 yemek kaydet',
    icon: Icons.dinner_dining,
    color: AppColors.accent,
    points: 50,
    category: AchievementCategory.meals,
    checkCondition: (stats) => stats.totalMealsLogged >= 50,
  ),
  Achievement(
    id: 'meal_100',
    title: 'Yüz Yemek',
    description: '100 yemek kaydet',
    icon: Icons.celebration,
    color: AppColors.warning,
    points: 100,
    category: AchievementCategory.meals,
    checkCondition: (stats) => stats.totalMealsLogged >= 100,
  ),

  // Streak achievements
  Achievement(
    id: 'streak_3',
    title: '3 Günlük Seri',
    description: '3 gün üst üste kayıt yap',
    icon: Icons.local_fire_department,
    color: AppColors.accent,
    points: 20,
    category: AchievementCategory.streak,
    checkCondition: (stats) => stats.streakDays >= 3,
  ),
  Achievement(
    id: 'streak_7',
    title: 'Bir Hafta',
    description: '7 gün üst üste kayıt yap',
    icon: Icons.whatshot,
    color: AppColors.accent,
    points: 50,
    category: AchievementCategory.streak,
    checkCondition: (stats) => stats.streakDays >= 7,
  ),
  Achievement(
    id: 'streak_30',
    title: 'Ateş Topu',
    description: '30 gün üst üste kayıt yap',
    icon: Icons.fireplace,
    color: AppColors.error,
    points: 150,
    category: AchievementCategory.streak,
    checkCondition: (stats) => stats.streakDays >= 30,
  ),
  Achievement(
    id: 'streak_100',
    title: 'Efsane',
    description: '100 gün üst üste kayıt yap',
    icon: Icons.military_tech,
    color: AppColors.warning,
    points: 500,
    category: AchievementCategory.streak,
    checkCondition: (stats) => stats.streakDays >= 100,
  ),

  // Social achievements
  Achievement(
    id: 'first_post',
    title: 'İlk Paylaşım',
    description: 'İlk gönderini paylaş',
    icon: Icons.photo_camera,
    color: AppColors.protein,
    points: 15,
    category: AchievementCategory.social,
    checkCondition: (stats) => stats.totalPosts >= 1,
  ),
  Achievement(
    id: 'social_10',
    title: 'Sosyal Kelebek',
    description: '10 gönderi paylaş',
    icon: Icons.share,
    color: AppColors.protein,
    points: 50,
    category: AchievementCategory.social,
    checkCondition: (stats) => stats.totalPosts >= 10,
  ),

  // Nutrition achievements
  Achievement(
    id: 'balanced_week',
    title: 'Dengeli Beslenme',
    description: 'Bir hafta hedeflerine ulaş',
    icon: Icons.balance,
    color: AppColors.success,
    points: 75,
    category: AchievementCategory.nutrition,
    checkCondition: (stats) => false, // Complex logic needed
  ),
];
