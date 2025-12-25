import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../data/models/meal_plan_model.dart';
import '../../../services/meal_planning_service.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/loading/skeleton_loader.dart';
import '../../widgets/animations/page_transitions.dart';
import 'create_meal_plan_screen.dart';
import 'meal_plan_detail_screen.dart';

// Provider for active meal plan
final activeMealPlanProvider = FutureProvider.autoDispose<MealPlan?>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return null;

  try {
    return await MealPlanningService.getActiveMealPlan(userId);
  } catch (e) {
    print('Error fetching active meal plan: $e');
    return null;
  }
});

// Provider for all meal plans
final allMealPlansProvider = FutureProvider.autoDispose<List<MealPlan>>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return [];

  try {
    return await MealPlanningService.getMealPlans(userId);
  } catch (e) {
    print('Error fetching meal plans: $e');
    return [];
  }
});

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğün Planlaması'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aktif Plan'),
            Tab(text: 'Tüm Planlar'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                PageTransitions.slideFromRight(const CreateMealPlanScreen()),
              ).then((_) {
                // Refresh plans after creation
                ref.invalidate(activeMealPlanProvider);
                ref.invalidate(allMealPlansProvider);
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActivePlanTab(),
          _buildAllPlansTab(),
        ],
      ),
    );
  }

  Widget _buildActivePlanTab() {
    final activePlanAsync = ref.watch(activeMealPlanProvider);

    return activePlanAsync.when(
      data: (plan) {
        if (plan == null) {
          return EmptyState(
            type: EmptyStateType.noMeals,
            title: 'Aktif Plan Yok',
            message: 'Haftalık öğün planı oluşturun ve sağlıklı beslenin!',
            actionText: 'Plan Oluştur',
            onAction: () {
              Navigator.push(
                context,
                PageTransitions.slideFromRight(const CreateMealPlanScreen()),
              ).then((_) {
                ref.invalidate(activeMealPlanProvider);
              });
            },
          );
        }

        return _buildActivePlanContent(plan);
      },
      loading: () => const SkeletonLoader(
        type: SkeletonType.foodList,
        itemCount: 7,
      ),
      error: (error, _) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }

  Widget _buildActivePlanContent(MealPlan plan) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan header
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
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
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('d MMM', 'tr').format(plan.startDate)} - ${DateFormat('d MMM', 'tr').format(plan.endDate)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransitions.slideFromRight(
                              MealPlanDetailScreen(planId: plan.id),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (plan.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      plan.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Ortalama',
                        '${plan.averageDailyCalories.toStringAsFixed(0)} kcal',
                        Icons.restaurant,
                        AppColors.primary,
                      ),
                      _buildStatItem(
                        'Günler',
                        '${plan.dailyPlans.length}',
                        Icons.calendar_today,
                        AppColors.success,
                      ),
                      _buildStatItem(
                        'Toplam',
                        '${plan.totalPlannedCalories.toStringAsFixed(0)} kcal',
                        Icons.local_fire_department,
                        AppColors.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Daily plans
          const Text(
            'Haftalık Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...plan.dailyPlans.map((dailyPlan) {
            final isToday = dailyPlan.date.year == today.year &&
                dailyPlan.date.month == today.month &&
                dailyPlan.date.day == today.day;

            return _buildDailyPlanCard(dailyPlan, isToday, plan.id);
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
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
    );
  }

  Widget _buildDailyPlanCard(DailyMealPlan dailyPlan, bool isToday, String planId) {
    final dayName = DateFormat('EEEE', 'tr').format(dailyPlan.date);
    final dateStr = DateFormat('d MMMM', 'tr').format(dailyPlan.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isToday
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.divider,
          width: isToday ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageTransitions.slideFromRight(
              MealPlanDetailScreen(
                planId: planId,
                initialDate: dailyPlan.date,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'BUGÜN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (isToday) const SizedBox(width: 8),
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isToday ? AppColors.primary : null,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              if (dailyPlan.meals.isEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Henüz öğün eklenmedi',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dailyPlan.meals.length} öğün',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dailyPlan.totalCalories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Nutrition breakdown
                Row(
                  children: [
                    _buildNutrientTag('P: ${dailyPlan.totalProtein.toStringAsFixed(0)}g', AppColors.protein),
                    const SizedBox(width: 8),
                    _buildNutrientTag('K: ${dailyPlan.totalCarbs.toStringAsFixed(0)}g', AppColors.carbs),
                    const SizedBox(width: 8),
                    _buildNutrientTag('Y: ${dailyPlan.totalFat.toStringAsFixed(0)}g', AppColors.fat),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAllPlansTab() {
    final allPlansAsync = ref.watch(allMealPlansProvider);

    return allPlansAsync.when(
      data: (plans) {
        if (plans.isEmpty) {
          return EmptyState(
            type: EmptyStateType.noMeals,
            title: 'Plan Yok',
            message: 'Henüz hiç öğün planı oluşturmadınız.',
            actionText: 'İlk Planı Oluştur',
            onAction: () {
              Navigator.push(
                context,
                PageTransitions.slideFromRight(const CreateMealPlanScreen()),
              ).then((_) {
                ref.invalidate(allMealPlansProvider);
              });
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return _buildPlanListItem(plan);
          },
        );
      },
      loading: () => const SkeletonLoader(
        type: SkeletonType.foodList,
        itemCount: 5,
      ),
      error: (error, _) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }

  Widget _buildPlanListItem(MealPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: plan.isActive
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.divider,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageTransitions.slideFromRight(
              MealPlanDetailScreen(planId: plan.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (plan.isActive) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'AKTİF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('d MMM', 'tr').format(plan.startDate)} - ${DateFormat('d MMM', 'tr').format(plan.endDate)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              if (plan.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  plan.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${plan.dailyPlans.length} gün',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ort. ${plan.averageDailyCalories.toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
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
