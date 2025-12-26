import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../data/models/weight_entry_model.dart';
import '../../../services/weight_tracking_service.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/loading/skeleton_loader.dart';
import '../../widgets/animations/page_transitions.dart';
import '../../widgets/common/swipeable_item.dart';
import '../../widgets/modals/custom_dialog.dart';
import 'add_weight_entry_screen.dart';
import 'weight_goal_screen.dart';

// Provider for weight entries
final weightEntriesProvider = FutureProvider.autoDispose<List<WeightEntry>>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return [];

  try {
    return await WeightTrackingService.getWeightEntries(userId, limit: 30);
  } catch (e) {
    print('Error fetching weight entries: $e');
    return [];
  }
});

// Provider for active goal
final activeGoalProvider = FutureProvider.autoDispose<WeightGoal?>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return null;

  try {
    return await WeightTrackingService.getActiveWeightGoal(userId);
  } catch (e) {
    print('Error fetching active goal: $e');
    return null;
  }
});

// Provider for weight stats
final weightStatsProvider = FutureProvider.autoDispose<WeightStats>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return WeightStats(totalEntries: 0);

  try {
    return await WeightTrackingService.getWeightStats(userId);
  } catch (e) {
    print('Error fetching weight stats: $e');
    return WeightStats(totalEntries: 0);
  }
});

class WeightTrackingScreen extends ConsumerStatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  ConsumerState<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends ConsumerState<WeightTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(weightEntriesProvider);
    ref.invalidate(activeGoalProvider);
    ref.invalidate(weightStatsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kilo Takibi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Grafik'),
            Tab(text: 'Geçmiş'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'Hedef Belirle',
            onPressed: () {
              Navigator.push(
                context,
                PageTransitions.slideFromRight(const WeightGoalScreen()),
              ).then((_) => _refresh());
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChartTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransitions.slideFromBottom(const AddWeightEntryScreen()),
          ).then((_) => _refresh());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChartTab() {
    final entriesAsync = ref.watch(weightEntriesProvider);
    final goalAsync = ref.watch(activeGoalProvider);
    final statsAsync = ref.watch(weightStatsProvider);

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return EmptyState(
            type: EmptyStateType.noStats,
            title: 'Kilo Kaydı Yok',
            message: 'İlk kilo kaydınızı ekleyin ve ilerlemenizi takip edin!',
            actionText: 'Kilo Ekle',
            onAction: () {
              Navigator.push(
                context,
                PageTransitions.slideFromBottom(const AddWeightEntryScreen()),
              ).then((_) => _refresh());
            },
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active goal card
              goalAsync.when(
                data: (goal) {
                  if (goal != null) {
                    return _buildGoalCard(goal);
                  }
                  return _buildNoGoalCard();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Stats cards
              statsAsync.when(
                data: (stats) => _buildStatsCards(stats),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Weight chart
              const Text(
                'Kilo Grafiği (Son 30 Gün)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildWeightChart(entries),
            ],
          ),
        );
      },
      loading: () => const SkeletonLoader(
        type: SkeletonType.chart,
        itemCount: 2,
      ),
      error: (error, _) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }

  Widget _buildGoalCard(WeightGoal goal) {
    final progressColor = goal.progressPercentage >= 75
        ? AppColors.success
        : goal.progressPercentage >= 50
            ? AppColors.primary
            : AppColors.warning;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: progressColor.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.flag, color: progressColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.goalTypeDisplay,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hedef: ${goal.targetWeight.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${goal.progressPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: goal.progressPercentage / 100,
                minHeight: 8,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation(progressColor),
              ),
            ),
            const SizedBox(height: 12),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGoalStat(
                  'Başlangıç',
                  '${goal.startWeight.toStringAsFixed(1)} kg',
                  Icons.start,
                ),
                _buildGoalStat(
                  'Şu An',
                  '${(goal.currentWeight ?? goal.startWeight).toStringAsFixed(1)} kg',
                  Icons.show_chart,
                ),
                _buildGoalStat(
                  'Kalan',
                  '${goal.weightRemaining.abs().toStringAsFixed(1)} kg',
                  Icons.trending_down,
                ),
              ],
            ),
            if (goal.daysRemaining != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Text(
                      '${goal.daysRemaining} gün kaldı',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNoGoalCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageTransitions.slideFromRight(const WeightGoalScreen()),
          ).then((_) => _refresh());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flag_outlined, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hedef Belirle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Kilo hedefi oluşturun',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(WeightStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'En Yüksek',
            stats.highestWeight != null
                ? '${stats.highestWeight!.toStringAsFixed(1)} kg'
                : '-',
            Icons.trending_up,
            AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'En Düşük',
            stats.lowestWeight != null
                ? '${stats.lowestWeight!.toStringAsFixed(1)} kg'
                : '-',
            Icons.trending_down,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Ortalama',
            stats.averageWeight != null
                ? '${stats.averageWeight!.toStringAsFixed(1)} kg'
                : '-',
            Icons.show_chart,
            AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
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

  Widget _buildWeightChart(List<WeightEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    // Sort by date ascending for chart
    final sortedEntries = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

    final spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    final weights = sortedEntries.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b) - 2;
    final maxWeight = weights.reduce((a, b) => a > b ? a : b) + 2;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              minY: minWeight,
              maxY: maxWeight,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
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
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= sortedEntries.length) return const Text('');
                      final entry = sortedEntries[value.toInt()];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat('dd/MM').format(entry.loggedAt),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.divider,
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    final entriesAsync = ref.watch(weightEntriesProvider);

    return entriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return EmptyState(
            type: EmptyStateType.noStats,
            title: 'Kayıt Yok',
            message: 'Henüz kilo kaydınız bulunmuyor.',
            actionText: 'İlk Kaydı Ekle',
            onAction: () {
              Navigator.push(
                context,
                PageTransitions.slideFromBottom(const AddWeightEntryScreen()),
              ).then((_) => _refresh());
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final previousEntry = index < entries.length - 1 ? entries[index + 1] : null;
            final change = previousEntry != null
                ? entry.weight - previousEntry.weight
                : null;

            return SwipeableItem(
              onDelete: () async {
                try {
                  await WeightTrackingService.deleteWeightEntry(entry.id);
                  _refresh();
                } catch (e) {
                  if (mounted) {
                    CustomDialog.showError(
                      context: context,
                      title: 'Hata',
                      message: 'Kayıt silinemedi: $e',
                    );
                  }
                }
              },
              deleteConfirmMessage: 'Bu kayıt silinsin mi?',
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Date
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('dd').format(entry.loggedAt),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              DateFormat('MMM', 'tr').format(entry.loggedAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Weight info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.weightDisplay,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (entry.notes != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                entry.notes!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Change indicator
                      if (change != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: change >= 0
                                ? AppColors.error.withOpacity(0.1)
                                : AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 14,
                                color: change >= 0 ? AppColors.error : AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${change.abs().toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: change >= 0 ? AppColors.error : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const SkeletonLoader(
        type: SkeletonType.foodList,
        itemCount: 10,
      ),
      error: (error, _) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }
}
