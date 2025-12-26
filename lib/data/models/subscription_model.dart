enum SubscriptionTier {
  free,
  premium,
  premiumPlus,
}

enum SubscriptionStatus {
  active,
  cancelled,
  expired,
  trial,
}

class Subscription {
  final String id;
  final String userId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? trialEndDate;
  final bool autoRenew;
  final double priceMonthly;
  final String currency;
  final Map<String, bool> features;

  Subscription({
    required this.id,
    required this.userId,
    required this.tier,
    required this.status,
    required this.startDate,
    this.endDate,
    this.trialEndDate,
    this.autoRenew = true,
    required this.priceMonthly,
    this.currency = 'TRY',
    this.features = const {},
  });

  bool get isActive => status == SubscriptionStatus.active || status == SubscriptionStatus.trial;
  bool get isPremium => tier != SubscriptionTier.free && isActive;
  bool get isInTrial => status == SubscriptionStatus.trial;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.expired,
      ),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      trialEndDate: json['trial_end_date'] != null
          ? DateTime.parse(json['trial_end_date'] as String)
          : null,
      autoRenew: json['auto_renew'] as bool? ?? true,
      priceMonthly: (json['price_monthly'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'TRY',
      features: json['features'] != null
          ? Map<String, bool>.from(json['features'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tier': tier.name,
      'status': status.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'trial_end_date': trialEndDate?.toIso8601String(),
      'auto_renew': autoRenew,
      'price_monthly': priceMonthly,
      'currency': currency,
      'features': features,
    };
  }

  Subscription copyWith({
    String? id,
    String? userId,
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? trialEndDate,
    bool? autoRenew,
    double? priceMonthly,
    String? currency,
    Map<String, bool>? features,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      autoRenew: autoRenew ?? this.autoRenew,
      priceMonthly: priceMonthly ?? this.priceMonthly,
      currency: currency ?? this.currency,
      features: features ?? this.features,
    );
  }

  /// Check if user has access to a specific feature
  bool hasFeature(String featureKey) {
    return features[featureKey] == true;
  }

  /// Get free tier subscription
  factory Subscription.free(String userId) {
    return Subscription(
      id: 'free_$userId',
      userId: userId,
      tier: SubscriptionTier.free,
      status: SubscriptionStatus.active,
      startDate: DateTime.now(),
      priceMonthly: 0,
      features: {
        'basic_food_tracking': true,
        'basic_stats': true,
        'limited_recipes': true,
        'ads': true,
      },
    );
  }
}

class SubscriptionPlan {
  final SubscriptionTier tier;
  final String name;
  final String description;
  final double priceMonthly;
  final double priceYearly;
  final String currency;
  final List<String> features;
  final bool isMostPopular;

  SubscriptionPlan({
    required this.tier,
    required this.name,
    required this.description,
    required this.priceMonthly,
    required this.priceYearly,
    this.currency = 'TRY',
    required this.features,
    this.isMostPopular = false,
  });

  double get yearlySavings => (priceMonthly * 12) - priceYearly;
  double get yearlySavingsPercent => (yearlySavings / (priceMonthly * 12)) * 100;

  static List<SubscriptionPlan> getPlans() {
    return [
      SubscriptionPlan(
        tier: SubscriptionTier.free,
        name: 'Ücretsiz',
        description: 'Temel özellikler',
        priceMonthly: 0,
        priceYearly: 0,
        features: [
          'Kalori takibi',
          'Temel istatistikler',
          'Sınırlı tarif erişimi (10 tarif)',
          'Reklamlar',
        ],
      ),
      SubscriptionPlan(
        tier: SubscriptionTier.premium,
        name: 'Premium',
        description: 'Tam özellikler, reklamsız',
        priceMonthly: 49.99,
        priceYearly: 499.99,
        features: [
          'Tüm tarifler (100+ Türk yemeği)',
          'Pişirme modu',
          'Gelişmiş analitikler',
          'Öğün planlama',
          'Reklamsız deneyim',
          'Öncelikli destek',
        ],
        isMostPopular: true,
      ),
      SubscriptionPlan(
        tier: SubscriptionTier.premiumPlus,
        name: 'Premium Plus',
        description: 'Tam özellikler + diyetisyen danışmanlığı',
        priceMonthly: 99.99,
        priceYearly: 999.99,
        features: [
          'Tüm Premium özellikleri',
          'Kişisel diyet planları',
          'Aylık diyetisyen danışmanlığı (1 saat)',
          'Özel beslenme önerileri',
          'VIP destek',
        ],
      ),
    ];
  }
}
