import 'package:firebase_analytics/firebase_analytics.dart';

/// Service for tracking analytics events
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ==========================================
  // USER EVENTS
  // ==========================================

  /// Log user login
  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Log user signup
  static Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  /// Set user ID
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Set user property
  static Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // ==========================================
  // FOOD LOGGING EVENTS
  // ==========================================

  /// Log food added
  static Future<void> logFoodAdded({
    required String foodName,
    required String mealType,
    required double calories,
  }) async {
    await _analytics.logEvent(
      name: 'food_added',
      parameters: {
        'food_name': foodName,
        'meal_type': mealType,
        'calories': calories,
      },
    );
  }

  /// Log food search
  static Future<void> logFoodSearch(String query) async {
    await _analytics.logSearch(searchTerm: query);
  }

  /// Log barcode scan
  static Future<void> logBarcodeScan(String barcode) async {
    await _analytics.logEvent(
      name: 'barcode_scan',
      parameters: {'barcode': barcode},
    );
  }

  // ==========================================
  // SOCIAL EVENTS
  // ==========================================

  /// Log post created
  static Future<void> logPostCreated({
    bool hasImage = false,
    int contentLength = 0,
  }) async {
    await _analytics.logEvent(
      name: 'post_created',
      parameters: {
        'has_image': hasImage,
        'content_length': contentLength,
      },
    );
  }

  /// Log post liked
  static Future<void> logPostLiked() async {
    await _analytics.logEvent(name: 'post_liked');
  }

  /// Log comment added
  static Future<void> logCommentAdded() async {
    await _analytics.logEvent(name: 'comment_added');
  }

  /// Log user followed
  static Future<void> logUserFollowed() async {
    await _analytics.logEvent(name: 'user_followed');
  }

  /// Log profile viewed
  static Future<void> logProfileViewed({required bool isOwnProfile}) async {
    await _analytics.logEvent(
      name: 'profile_viewed',
      parameters: {'is_own': isOwnProfile},
    );
  }

  // ==========================================
  // ACHIEVEMENT EVENTS
  // ==========================================

  /// Log achievement unlocked
  static Future<void> logAchievementUnlocked(String achievementId) async {
    await _analytics.logEvent(
      name: 'achievement_unlocked',
      parameters: {'achievement_id': achievementId},
    );
  }

  /// Log streak milestone
  static Future<void> logStreakMilestone(int days) async {
    await _analytics.logEvent(
      name: 'streak_milestone',
      parameters: {'days': days},
    );
  }

  // ==========================================
  // MEAL PLANNING EVENTS
  // ==========================================

  /// Log meal plan created
  static Future<void> logMealPlanCreated({
    required int daysCount,
    required int mealsCount,
  }) async {
    await _analytics.logEvent(
      name: 'meal_plan_created',
      parameters: {
        'days_count': daysCount,
        'meals_count': mealsCount,
      },
    );
  }

  /// Log meal template saved
  static Future<void> logMealTemplateSaved() async {
    await _analytics.logEvent(name: 'meal_template_saved');
  }

  // ==========================================
  // WEIGHT TRACKING EVENTS
  // ==========================================

  /// Log weight entry added
  static Future<void> logWeightEntryAdded() async {
    await _analytics.logEvent(name: 'weight_entry_added');
  }

  /// Log weight goal set
  static Future<void> logWeightGoalSet({
    required String goalType,
    required double targetWeight,
  }) async {
    await _analytics.logEvent(
      name: 'weight_goal_set',
      parameters: {
        'goal_type': goalType,
        'target_weight': targetWeight,
      },
    );
  }

  // ==========================================
  // WATER TRACKING EVENTS
  // ==========================================

  /// Log water logged
  static Future<void> logWaterLogged(int glasses) async {
    await _analytics.logEvent(
      name: 'water_logged',
      parameters: {'glasses': glasses},
    );
  }

  /// Log water reminder set
  static Future<void> logWaterReminderSet(int intervalMinutes) async {
    await _analytics.logEvent(
      name: 'water_reminder_set',
      parameters: {'interval_minutes': intervalMinutes},
    );
  }

  // ==========================================
  // SCREEN VIEW EVENTS
  // ==========================================

  /// Log screen view
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ==========================================
  // ERROR EVENTS
  // ==========================================

  /// Log error
  static Future<void> logError({
    required String error,
    String? stackTrace,
    bool fatal = false,
  }) async {
    await _analytics.logEvent(
      name: 'error',
      parameters: {
        'error': error,
        'stack_trace': stackTrace ?? '',
        'fatal': fatal,
      },
    );
  }

  // ==========================================
  // CUSTOM EVENTS
  // ==========================================

  /// Log custom event
  static Future<void> logCustomEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}
