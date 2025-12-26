import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/subscription_model.dart';
import '../config/supabase_config.dart';

/// Payment service for handling subscription payments
/// Note: This is a MVP implementation. For production, integrate with:
/// - Stripe (recommended for Turkey)
/// - Iyzico (Turkish payment provider)
/// - PayPal
class PaymentService {
  static final _supabase = SupabaseConfig.client;

  // ==================== Payment Methods ====================

  /// Initialize payment for subscription
  static Future<PaymentIntent?> createPaymentIntent({
    required String userId,
    required SubscriptionTier tier,
    required bool isYearly,
  }) async {
    try {
      // Get plan details
      final plan = SubscriptionPlan.getPlans()
          .firstWhere((p) => p.tier == tier);

      final amount = isYearly ? plan.priceYearly : plan.priceMonthly;

      // Create payment intent in database
      final response = await _supabase.from('payment_intents').insert({
        'user_id': userId,
        'tier': tier.name,
        'amount': amount,
        'currency': 'TRY',
        'is_yearly': isYearly,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return PaymentIntent.fromJson(response);
    } catch (e) {
      print('Error creating payment intent: $e');
      return null;
    }
  }

  /// Process payment (Mock implementation)
  static Future<PaymentResult> processPayment({
    required String paymentIntentId,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      // In production, call payment provider API (Stripe, Iyzico, etc.)
      // For MVP, simulate successful payment

      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Update payment intent status
      await _supabase.from('payment_intents').update({
        'status': 'succeeded',
        'payment_method': paymentMethod.type,
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', paymentIntentId);

      return PaymentResult(
        success: true,
        paymentIntentId: paymentIntentId,
        message: 'Ödeme başarılı',
      );
    } catch (e) {
      print('Error processing payment: $e');
      return PaymentResult(
        success: false,
        paymentIntentId: paymentIntentId,
        message: 'Ödeme başarısız: $e',
      );
    }
  }

  /// Verify payment
  static Future<bool> verifyPayment(String paymentIntentId) async {
    try {
      final response = await _supabase
          .from('payment_intents')
          .select()
          .eq('id', paymentIntentId)
          .single();

      return response['status'] == 'succeeded';
    } catch (e) {
      print('Error verifying payment: $e');
      return false;
    }
  }

  // ==================== Payment Methods Management ====================

  /// Save payment method
  static Future<bool> savePaymentMethod({
    required String userId,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      await _supabase.from('payment_methods').insert({
        'user_id': userId,
        'type': paymentMethod.type,
        'last4': paymentMethod.last4,
        'brand': paymentMethod.brand,
        'exp_month': paymentMethod.expMonth,
        'exp_year': paymentMethod.expYear,
        'is_default': true,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error saving payment method: $e');
      return false;
    }
  }

  /// Get user's payment methods
  static Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    try {
      final response = await _supabase
          .from('payment_methods')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PaymentMethod.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching payment methods: $e');
      return [];
    }
  }

  /// Delete payment method
  static Future<bool> deletePaymentMethod(String paymentMethodId) async {
    try {
      await _supabase
          .from('payment_methods')
          .delete()
          .eq('id', paymentMethodId);

      return true;
    } catch (e) {
      print('Error deleting payment method: $e');
      return false;
    }
  }

  // ==================== Billing History ====================

  /// Get user's billing history
  static Future<List<BillingRecord>> getBillingHistory(String userId) async {
    try {
      final response = await _supabase
          .from('payment_intents')
          .select()
          .eq('user_id', userId)
          .eq('status', 'succeeded')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => BillingRecord.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching billing history: $e');
      return [];
    }
  }

  // ==================== Refunds ====================

  /// Request refund
  static Future<bool> requestRefund({
    required String paymentIntentId,
    required String reason,
  }) async {
    try {
      await _supabase.from('refund_requests').insert({
        'payment_intent_id': paymentIntentId,
        'reason': reason,
        'status': 'pending',
        'requested_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error requesting refund: $e');
      return false;
    }
  }

  // ==================== Webhooks (Server-side) ====================

  /// Handle payment webhook (should be called from server)
  static Future<void> handlePaymentWebhook(Map<String, dynamic> event) async {
    try {
      final eventType = event['type'] as String;

      switch (eventType) {
        case 'payment_intent.succeeded':
          await _handlePaymentSuccess(event['data']);
          break;
        case 'payment_intent.failed':
          await _handlePaymentFailure(event['data']);
          break;
        case 'subscription.cancelled':
          await _handleSubscriptionCancelled(event['data']);
          break;
      }
    } catch (e) {
      print('Error handling webhook: $e');
    }
  }

  static Future<void> _handlePaymentSuccess(Map<String, dynamic> data) async {
    // Activate subscription
    print('Payment successful: $data');
  }

  static Future<void> _handlePaymentFailure(Map<String, dynamic> data) async {
    // Send notification to user
    print('Payment failed: $data');
  }

  static Future<void> _handleSubscriptionCancelled(Map<String, dynamic> data) async {
    // Update subscription status
    print('Subscription cancelled: $data');
  }

  // ==================== Invoice Generation ====================

  /// Generate invoice PDF (URL)
  static Future<String?> generateInvoice(String paymentIntentId) async {
    try {
      // In production, generate PDF invoice
      // For MVP, return mock URL
      return 'https://turkkalori.com/invoices/$paymentIntentId.pdf';
    } catch (e) {
      print('Error generating invoice: $e');
      return null;
    }
  }
}

// ==================== Models ====================

class PaymentIntent {
  final String id;
  final String userId;
  final SubscriptionTier tier;
  final double amount;
  final String currency;
  final bool isYearly;
  final String status;
  final DateTime createdAt;

  PaymentIntent({
    required this.id,
    required this.userId,
    required this.tier,
    required this.amount,
    required this.currency,
    required this.isYearly,
    required this.status,
    required this.createdAt,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['tier'],
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      isYearly: json['is_yearly'] as bool,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class PaymentMethod {
  final String? id;
  final String type; // card, bank_transfer, etc.
  final String? last4;
  final String? brand; // visa, mastercard, etc.
  final int? expMonth;
  final int? expYear;
  final bool isDefault;

  PaymentMethod({
    this.id,
    required this.type,
    this.last4,
    this.brand,
    this.expMonth,
    this.expYear,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String?,
      type: json['type'] as String,
      last4: json['last4'] as String?,
      brand: json['brand'] as String?,
      expMonth: json['exp_month'] as int?,
      expYear: json['exp_year'] as int?,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type,
      if (last4 != null) 'last4': last4,
      if (brand != null) 'brand': brand,
      if (expMonth != null) 'exp_month': expMonth,
      if (expYear != null) 'exp_year': expYear,
      'is_default': isDefault,
    };
  }

  String get displayName {
    if (last4 != null && brand != null) {
      return '$brand •••• $last4';
    }
    return type;
  }
}

class PaymentResult {
  final bool success;
  final String paymentIntentId;
  final String message;

  PaymentResult({
    required this.success,
    required this.paymentIntentId,
    required this.message,
  });
}

class BillingRecord {
  final String id;
  final double amount;
  final String currency;
  final String tier;
  final DateTime createdAt;
  final String status;

  BillingRecord({
    required this.id,
    required this.amount,
    required this.currency,
    required this.tier,
    required this.createdAt,
    required this.status,
  });

  factory BillingRecord.fromJson(Map<String, dynamic> json) {
    return BillingRecord(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      tier: json['tier'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String,
    );
  }
}
