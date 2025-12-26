import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/premium_service.dart';
import '../../../config/supabase_config.dart';
import '../premium/premium_screen.dart';

class AdvancedAnalyticsScreen extends ConsumerStatefulWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  ConsumerState<AdvancedAnalyticsScreen> createState() =>
      _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState
    extends ConsumerState<AdvancedAnalyticsScreen> {
  bool _isPremium = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final isPremium = await PremiumService.isPremiumUser(userId);

    if (mounted) {
      setState(() {
        _isPremium = isPremium;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isPremium) {
      return _buildPremiumPaywall();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelişmiş Analitikler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Gelişmiş Analitikler'),
                  content: const Text(
                    'Beslenme alışkanlıklarınızı daha detaylı analiz edin. '
                    'Trendler, tahminler ve kişiselleştirilmiş öneriler.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tamam'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrendAnalysis(),
            const SizedBox(height: 24),
            _buildNutritionBreakdown(),
            const SizedBox(height: 24),
            _buildMealTimingAnalysis(),
            const SizedBox(height: 24),
            _buildGoalProgress(),
            const SizedBox(height: 24),
            _buildPredictions(),
            const SizedBox(height: 24),
            _buildRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumPaywall() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelişmiş Analitikler'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              const Text(
                'Gelişmiş Analitikler',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Beslenme alışkanlıklarınızı daha detaylı analiz edin. '
                'Trendler, tahminler ve kişiselleştirilmiş öneriler.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PremiumScreen()),
                  );
                },
                icon: const Icon(Icons.star),
                label: const Text('Premium\'a Geç'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: AppColors.warning,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    return _AnalyticsCard(
      title: 'Kalori Trendi (30 Gün)',
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() % 7 == 0) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: _generateSampleTrendData(),
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
              // Goal line
              LineChartBarData(
                spots: List.generate(
                  30,
                  (i) => FlSpot(i.toDouble(), 2000),
                ),
                isCurved: false,
                color: AppColors.success,
                barWidth: 2,
                dotData: FlDotData(show: false),
                dashArray: [5, 5],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionBreakdown() {
    return _AnalyticsCard(
      title: 'Besin Değerleri Dağılımı',
      child: Column(
        children: [
          _NutrientBar(
            label: 'Protein',
            value: 25,
            color: AppColors.protein,
            unit: '%',
          ),
          const SizedBox(height: 12),
          _NutrientBar(
            label: 'Karbonhidrat',
            value: 50,
            color: AppColors.carbs,
            unit: '%',
          ),
          const SizedBox(height: 12),
          _NutrientBar(
            label: 'Yağ',
            value: 25,
            color: AppColors.fat,
            unit: '%',
          ),
          const SizedBox(height: 16),
          const Text(
            'Önerilen: 25% Protein, 50% Karbonhidrat, 25% Yağ',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTimingAnalysis() {
    return _AnalyticsCard(
      title: 'Öğün Zamanlaması Analizi',
      child: Column(
        children: [
          _MealTimeCard(
            meal: 'Kahvaltı',
            avgTime: '08:30',
            avgCalories: 450,
            color: AppColors.breakfast,
          ),
          const SizedBox(height: 8),
          _MealTimeCard(
            meal: 'Öğle',
            avgTime: '13:00',
            avgCalories: 650,
            color: AppColors.lunch,
          ),
          const SizedBox(height: 8),
          _MealTimeCard(
            meal: 'Akşam',
            avgTime: '19:30',
            avgCalories: 700,
            color: AppColors.dinner,
          ),
          const SizedBox(height: 8),
          _MealTimeCard(
            meal: 'Ara Öğün',
            avgTime: '16:00',
            avgCalories: 200,
            color: AppColors.snack,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgress() {
    return _AnalyticsCard(
      title: 'Hedef İlerlemeniz',
      child: Column(
        children: [
          _ProgressIndicator(
            label: 'Günlük Kalori Hedefi',
            current: 1850,
            target: 2000,
            unit: 'kcal',
          ),
          const SizedBox(height: 16),
          _ProgressIndicator(
            label: 'Haftalık Düzenlilik',
            current: 6,
            target: 7,
            unit: 'gün',
          ),
          const SizedBox(height: 16),
          _ProgressIndicator(
            label: 'Aylık Ortalama',
            current: 25,
            target: 30,
            unit: 'gün',
          ),
        ],
      ),
    );
  }

  Widget _buildPredictions() {
    return _AnalyticsCard(
      title: 'Tahminler & İçgörüler',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InsightCard(
            icon: Icons.trending_up,
            color: AppColors.success,
            title: 'Hedef Üstü Performans',
            description:
                'Son 7 günde hedeflerinizi %95 oranında tuttunuz. Harika gidiyorsunuz!',
          ),
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.lightbulb_outline,
            color: AppColors.warning,
            title: 'Akşam Yemekleri',
            description:
                'Akşam yemekleriniz ortalama 100 kalori yüksek. Porsiyon kontrolü düşünün.',
          ),
          const SizedBox(height: 12),
          _InsightCard(
            icon: Icons.analytics,
            color: AppColors.primary,
            title: 'Hafta Sonu Eğilimi',
            description:
                'Hafta sonları kalori alımınız %15 artıyor. Planlı beslenmeye dikkat edin.',
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return _AnalyticsCard(
      title: 'Kişiselleştirilmiş Öneriler',
      child: Column(
        children: [
          _RecommendationCard(
            icon: Icons.restaurant_menu,
            title: 'Protein Alımını Artır',
            description:
                'Günlük protein alımınız hedefin %20 altında. Yumurta, tavuk veya baklagil ekleyin.',
          ),
          const SizedBox(height: 12),
          _RecommendationCard(
            icon: Icons.schedule,
            title: 'Kahvaltıyı Atlamayın',
            description:
                'Son 2 haftada 5 gün kahvaltı atladınız. Günlük enerjiniz için kahvaltı önemli.',
          ),
          const SizedBox(height: 12),
          _RecommendationCard(
            icon: Icons.water_drop,
            title: 'Su Tüketimini Artır',
            description:
                'Günlük 8 bardak su hedefine ulaşamıyorsunuz. Hatırlatıcıları açın.',
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSampleTrendData() {
    return List.generate(30, (i) {
      final base = 2000.0;
      final variation = (i % 7 == 0 || i % 7 == 6) ? 200 : 0;
      final random = (i * 37) % 100 - 50;
      return FlSpot(i.toDouble(), base + variation + random);
    });
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _AnalyticsCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _NutrientBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String unit;

  const _NutrientBar({
    required this.label,
    required this.value,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('$value$unit',
                style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 8,
        ),
      ],
    );
  }
}

class _MealTimeCard extends StatelessWidget {
  final String meal;
  final String avgTime;
  final int avgCalories;
  final Color color;

  const _MealTimeCard({
    required this.meal,
    required this.avgTime,
    required this.avgCalories,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: color, size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Ort. Saat: $avgTime',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '$avgCalories kcal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final String unit;

  const _ProgressIndicator({
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = current / target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '${current.toInt()} / ${target.toInt()} $unit',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation(
            progress >= 1.0 ? AppColors.success : AppColors.primary,
          ),
          minHeight: 8,
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _InsightCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _RecommendationCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
