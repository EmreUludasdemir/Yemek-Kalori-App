import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/subscription_model.dart';
import '../config/supabase_config.dart';

/// Service for managing premium subscriptions
class PremiumService {
  static final _supabase = SupabaseConfig.client;

  // ==================== Subscription Management ====================

  /// Get user's current subscription
  static Future<Subscription?> getUserSubscription(String userId) async {
    try {
      final response = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return Subscription.free(userId);
      }

      return Subscription.fromJson(response);
    } catch (e) {
      print('Error fetching subscription: $e');
      return Subscription.free(userId);
    }
  }

  /// Check if user is premium
  static Future<bool> isPremiumUser(String userId) async {
    final subscription = await getUserSubscription(userId);
    return subscription?.isPremium ?? false;
  }

  /// Check if user has access to a specific feature
  static Future<bool> hasFeatureAccess({
    required String userId,
    required String featureKey,
  }) async {
    final subscription = await getUserSubscription(userId);

    if (subscription == null) return false;

    // Premium users have access to all features
    if (subscription.isPremium) return true;

    // Check specific feature access
    return subscription.hasFeature(featureKey);
  }

  /// Start free trial
  static Future<Subscription?> startFreeTrial({
    required String userId,
    required SubscriptionTier tier,
    int trialDays = 7,
  }) async {
    try {
      // Check if user already had a trial
      final existingTrial = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('status', SubscriptionStatus.trial.name)
          .maybeSingle();

      if (existingTrial != null) {
        throw Exception('Deneme sürümü daha önce kullanıldı');
      }

      final now = DateTime.now();
      final trialEnd = now.add(Duration(days: trialDays));

      final subscription = Subscription(
        id: '', // Will be set by database
        userId: userId,
        tier: tier,
        status: SubscriptionStatus.trial,
        startDate: now,
        trialEndDate: trialEnd,
        priceMonthly: tier == SubscriptionTier.premium ? 49.99 : 99.99,
        features: _getFeaturesByTier(tier),
      );

      final response = await _supabase
          .from('subscriptions')
          .insert(subscription.toJson())
          .select()
          .single();

      return Subscription.fromJson(response);
    } catch (e) {
      print('Error starting trial: $e');
      return null;
    }
  }

  /// Subscribe to a plan
  static Future<Subscription?> subscribe({
    required String userId,
    required SubscriptionTier tier,
    required bool isYearly,
  }) async {
    try {
      // In real app, this would integrate with payment provider
      // For MVP, we'll just create the subscription record

      final now = DateTime.now();
      final endDate = isYearly
          ? now.add(const Duration(days: 365))
          : now.add(const Duration(days: 30));

      final plan = SubscriptionPlan.getPlans()
          .firstWhere((p) => p.tier == tier);

      final subscription = Subscription(
        id: '', // Will be set by database
        userId: userId,
        tier: tier,
        status: SubscriptionStatus.active,
        startDate: now,
        endDate: endDate,
        priceMonthly: plan.priceMonthly,
        features: _getFeaturesByTier(tier),
      );

      final response = await _supabase
          .from('subscriptions')
          .insert(subscription.toJson())
          .select()
          .single();

      return Subscription.fromJson(response);
    } catch (e) {
      print('Error subscribing: $e');
      return null;
    }
  }

  /// Cancel subscription
  static Future<bool> cancelSubscription(String userId) async {
    try {
      await _supabase
          .from('subscriptions')
          .update({
            'status': SubscriptionStatus.cancelled.name,
            'auto_renew': false,
          })
          .eq('user_id', userId)
          .eq('status', SubscriptionStatus.active.name);

      return true;
    } catch (e) {
      print('Error cancelling subscription: $e');
      return false;
    }
  }

  /// Renew subscription
  static Future<Subscription?> renewSubscription({
    required String userId,
    required bool isYearly,
  }) async {
    try {
      final currentSub = await getUserSubscription(userId);
      if (currentSub == null) return null;

      final now = DateTime.now();
      final endDate = isYearly
          ? now.add(const Duration(days: 365))
          : now.add(const Duration(days: 30));

      await _supabase
          .from('subscriptions')
          .update({
            'status': SubscriptionStatus.active.name,
            'start_date': now.toIso8601String(),
            'end_date': endDate.toIso8601String(),
            'auto_renew': true,
          })
          .eq('user_id', userId);

      return getUserSubscription(userId);
    } catch (e) {
      print('Error renewing subscription: $e');
      return null;
    }
  }

  // ==================== Feature Checks ====================

  /// Check if user can access premium recipes
  static Future<bool> canAccessPremiumRecipes(String userId) async {
    return hasFeatureAccess(
      userId: userId,
      featureKey: 'premium_recipes',
    );
  }

  /// Check if user can access advanced analytics
  static Future<bool> canAccessAdvancedAnalytics(String userId) async {
    return hasFeatureAccess(
      userId: userId,
      featureKey: 'advanced_analytics',
    );
  }

  /// Check if user has ad-free experience
  static Future<bool> isAdFree(String userId) async {
    return hasFeatureAccess(
      userId: userId,
      featureKey: 'ad_free',
    );
  }

  // ==================== Helper Functions ====================

  static Map<String, bool> _getFeaturesByTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return {
          'basic_food_tracking': true,
          'basic_stats': true,
          'limited_recipes': true,
          'ads': true,
        };

      case SubscriptionTier.premium:
        return {
          'basic_food_tracking': true,
          'basic_stats': true,
          'premium_recipes': true,
          'cooking_mode': true,
          'advanced_analytics': true,
          'meal_planning': true,
          'ad_free': true,
          'priority_support': true,
        };

      case SubscriptionTier.premiumPlus:
        return {
          'basic_food_tracking': true,
          'basic_stats': true,
          'premium_recipes': true,
          'cooking_mode': true,
          'advanced_analytics': true,
          'meal_planning': true,
          'ad_free': true,
          'priority_support': true,
          'custom_diet_plans': true,
          'nutritionist_consultation': true,
          'vip_support': true,
        };
    }
  }

  /// Get subscription stats for user
  static Future<Map<String, dynamic>> getSubscriptionStats(String userId) async {
    try {
      final subscription = await getUserSubscription(userId);

      if (subscription == null || !subscription.isPremium) {
        return {
          'is_premium': false,
          'tier': 'free',
          'days_remaining': 0,
        };
      }

      final daysRemaining = subscription.endDate != null
          ? subscription.endDate!.difference(DateTime.now()).inDays
          : 0;

      return {
        'is_premium': true,
        'tier': subscription.tier.name,
        'status': subscription.status.name,
        'days_remaining': daysRemaining,
        'is_trial': subscription.isInTrial,
        'auto_renew': subscription.autoRenew,
      };
    } catch (e) {
      print('Error fetching subscription stats: $e');
      return {'is_premium': false};
    }
  }

  /// Get all available plans
  static List<SubscriptionPlan> getAvailablePlans() {
    return SubscriptionPlan.getPlans();
  }

  /// Get benefits of upgrading from current tier
  static Future<List<String>> getUpgradeBenefits({
    required String userId,
    required SubscriptionTier targetTier,
  }) async {
    final currentSub = await getUserSubscription(userId);
    final currentTier = currentSub?.tier ?? SubscriptionTier.free;

    if (currentTier == targetTier) {
      return [];
    }

    final targetFeatures = _getFeaturesByTier(targetTier);
    final currentFeatures = _getFeaturesByTier(currentTier);

    final newFeatures = <String>[];

    targetFeatures.forEach((key, value) {
      if (value && !currentFeatures.containsKey(key)) {
        newFeatures.add(_formatFeatureName(key));
      }
    });

    return newFeatures;
  }

  static String _formatFeatureName(String key) {
    final formatted = key.replaceAll('_', ' ');
    return formatted[0].toUpperCase() + formatted.substring(1);
  }
}
