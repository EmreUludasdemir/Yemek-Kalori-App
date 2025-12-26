import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/subscription_model.dart';
import '../../../services/premium_service.dart';
import '../../../config/supabase_config.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _isYearly = true;
  bool _isLoading = false;

  Future<void> _subscribe(SubscriptionTier tier) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oturum açmanız gerekiyor')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final subscription = await PremiumService.subscribe(
      userId: userId,
      tier: tier,
      isYearly: _isYearly,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (subscription != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Premium üyeliğiniz aktif!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Abonelik başlatılamadı'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _startTrial(SubscriptionTier tier) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oturum açmanız gerekiyor')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final subscription = await PremiumService.startFreeTrial(
      userId: userId,
      tier: tier,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (subscription != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 7 günlük deneme süreniz başladı!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deneme süresi başlatılamadı'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = SubscriptionPlan.getPlans()
        .where((p) => p.tier != SubscriptionTier.free)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Hero Section
                const Icon(
                  Icons.star,
                  size: 80,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Premium ile Daha Fazlası',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sınırsız tarif, gelişmiş analitik ve daha fazlası',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Billing Period Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _PeriodButton(
                          label: 'Aylık',
                          isSelected: !_isYearly,
                          onTap: () => setState(() => _isYearly = false),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _PeriodButton(
                              label: 'Yıllık',
                              isSelected: _isYearly,
                              onTap: () => setState(() => _isYearly = true),
                            ),
                            Positioned(
                              top: -8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '%17 İndirim',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Plans
                ...plans.map((plan) => _PlanCard(
                      plan: plan,
                      isYearly: _isYearly,
                      onSubscribe: () => _subscribe(plan.tier),
                      onStartTrial: () => _startTrial(plan.tier),
                      isLoading: _isLoading,
                    )),

                const SizedBox(height: 24),

                // Features List
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Premium Özellikler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...[
                          '100+ Türk yemeği tarifi',
                          'Adım adım pişirme modu',
                          'Gelişmiş analitikler ve raporlar',
                          'Haftalık öğün planlama',
                          'Reklamsız deneyim',
                          'Öncelikli destek',
                        ].map((feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: AppColors.success, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Fine Print
                Text(
                  'İstediğiniz zaman iptal edebilirsiniz. Otomatik yenileme.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isYearly;
  final VoidCallback onSubscribe;
  final VoidCallback onStartTrial;
  final bool isLoading;

  const _PlanCard({
    required this.plan,
    required this.isYearly,
    required this.onSubscribe,
    required this.onStartTrial,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final price = isYearly ? plan.priceYearly : plan.priceMonthly;
    final monthlyPrice = isYearly ? plan.priceYearly / 12 : plan.priceMonthly;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: plan.isMostPopular
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        plan.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (plan.isMostPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Popüler',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₺${monthlyPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      '/ay',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              if (isYearly) ...[
                const SizedBox(height: 4),
                Text(
                  '₺${price.toStringAsFixed(2)} / yıl',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Features
              ...plan.features.take(3).map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check, color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

              const SizedBox(height: 16),

              // CTA Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onSubscribe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: plan.isMostPopular
                            ? AppColors.primary
                            : AppColors.secondary,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Başlat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: isLoading ? null : onStartTrial,
                    child: const Text('7 Gün Ücretsiz Dene'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
