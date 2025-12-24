import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../data/models/food_log_model.dart';

// Provider for weekly nutrition data
final weeklyNutritionProvider = FutureProvider.autoDispose<WeeklyNutritionData>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return WeeklyNutritionData.empty();

  try {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final response = await SupabaseConfig.client
        .from('food_logs')
        .select('logged_at, calories, protein, carbohydrates, fat')
        .eq('user_id', userId)
        .gte('logged_at', startDate.toIso8601String())
        .order('logged_at', ascending: true);

    final logs = (response as List).map((e) => FoodLog.fromJson(e)).toList();
    return WeeklyNutritionData.fromLogs(logs);
  } catch (e) {
    print('Error fetching weekly nutrition: $e');
    return WeeklyNutritionData.empty();
  }
});

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int _selectedTab = 0; // 0: Week, 1: Month

  @override
  Widget build(BuildContext context) {
    final weeklyDataAsync = ref.watch(weeklyNutritionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(weeklyNutritionProvider),
          ),
        ],
      ),
      body: weeklyDataAsync.when(
        data: (weeklyData) => _buildContent(weeklyData),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(error.toString()),
      ),
    );
  }

  Widget _buildContent(WeeklyNutritionData weeklyData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab selector
          Row(
            children: [
              Expanded(
                child: _buildTabButton('Hafta', 0),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTabButton('Ay', 1),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weekly calorie chart
          const Text(
            'Haftalık Kalori Grafiği',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: LineChart(
                  _buildLineChartData(weeklyData),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Macro distribution
          const Text(
            'Makro Besin Dağılımı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: PieChart(
                      _buildPieChartData(weeklyData),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMacroLegendItem(
                          'Protein',
                          weeklyData.totalProtein,
                          AppColors.protein,
                        ),
                        const SizedBox(height: 8),
                        _buildMacroLegendItem(
                          'Karbonhidrat',
                          weeklyData.totalCarbs,
                          AppColors.carbs,
                        ),
                        const SizedBox(height: 8),
                        _buildMacroLegendItem(
                          'Yağ',
                          weeklyData.totalFat,
                          AppColors.fat,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Weekly summary
          const Text(
            'Haftalık Özet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Günlük Ort.',
                  '${weeklyData.averageDailyCalories.toStringAsFixed(0)} kcal',
                  Icons.local_fire_department,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Toplam',
                  '${weeklyData.totalCalories.toStringAsFixed(0)} kcal',
                  Icons.dining,
                  AppColors.accent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'En Yüksek',
                  '${weeklyData.maxDailyCalories.toStringAsFixed(0)} kcal',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'En Düşük',
                  '${weeklyData.minDailyCalories.toStringAsFixed(0)} kcal',
                  Icons.trending_down,
                  AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tips card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.accent.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İpucu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tutarlı kalori alımı için günlük hedeflerinize yakın kalın.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  LineChartData _buildLineChartData(WeeklyNutritionData data) {
    final spots = <FlSpot>[];
    for (var i = 0; i < data.dailyCalories.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.dailyCalories[i]));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 500,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
              if (value.toInt() >= 0 && value.toInt() < days.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    days[value.toInt()],
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: (data.maxDailyCalories * 1.2).ceilToDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.3),
                AppColors.primaryLight.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  PieChartData _buildPieChartData(WeeklyNutritionData data) {
    final total = data.totalProtein + data.totalCarbs + data.totalFat;
    if (total == 0) {
      return PieChartData(sections: []);
    }

    return PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 30,
      sections: [
        PieChartSectionData(
          color: AppColors.protein,
          value: data.totalProtein,
          title: '${((data.totalProtein / total) * 100).toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: AppColors.carbs,
          value: data.totalCarbs,
          title: '${((data.totalCarbs / total) * 100).toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: AppColors.fat,
          value: data.totalFat,
          title: '${((data.totalFat / total) * 100).toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroLegendItem(String label, double grams, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        const Spacer(),
        Text(
          '${grams.toStringAsFixed(0)}g',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Bir hata oluştu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// Weekly nutrition data model
class WeeklyNutritionData {
  final List<double> dailyCalories; // 7 days (Mon-Sun)
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  WeeklyNutritionData({
    required this.dailyCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  factory WeeklyNutritionData.empty() {
    return WeeklyNutritionData(
      dailyCalories: List.filled(7, 0),
      totalProtein: 0,
      totalCarbs: 0,
      totalFat: 0,
    );
  }

  factory WeeklyNutritionData.fromLogs(List<FoodLog> logs) {
    final dailyCalories = List<double>.filled(7, 0);
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    for (final log in logs) {
      final logDate = log.loggedAt;
      final dayIndex = logDate.difference(startDate).inDays;

      if (dayIndex >= 0 && dayIndex < 7) {
        dailyCalories[dayIndex] += log.calories;
      }

      totalProtein += log.protein;
      totalCarbs += log.carbohydrates;
      totalFat += log.fat;
    }

    return WeeklyNutritionData(
      dailyCalories: dailyCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
    );
  }

  double get totalCalories => dailyCalories.fold(0, (sum, cal) => sum + cal);

  double get averageDailyCalories {
    final nonZeroDays = dailyCalories.where((cal) => cal > 0).length;
    return nonZeroDays > 0 ? totalCalories / nonZeroDays : 0;
  }

  double get maxDailyCalories {
    return dailyCalories.reduce((a, b) => a > b ? a : b);
  }

  double get minDailyCalories {
    final nonZero = dailyCalories.where((cal) => cal > 0);
    return nonZero.isNotEmpty ? nonZero.reduce((a, b) => a < b ? a : b) : 0;
  }
}
