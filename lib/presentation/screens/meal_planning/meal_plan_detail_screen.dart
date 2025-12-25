import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/meal_plan_model.dart';
import '../../../services/meal_planning_service.dart';
import '../../widgets/loading/skeleton_loader.dart';
import '../../widgets/common/swipeable_item.dart';
import '../../widgets/animations/page_transitions.dart';
import '../../widgets/modals/custom_dialog.dart';
import '../food_log/food_search_screen.dart';

// Provider for meal plan detail
final mealPlanDetailProvider = FutureProvider.autoDispose.family<MealPlan?, String>((ref, planId) async {
  try {
    return await MealPlanningService.getMealPlan(planId);
  } catch (e) {
    print('Error fetching meal plan: $e');
    return null;
  }
});

class MealPlanDetailScreen extends ConsumerStatefulWidget {
  final String planId;
  final DateTime? initialDate;

  const MealPlanDetailScreen({
    super.key,
    required this.planId,
    this.initialDate,
  });

  @override
  ConsumerState<MealPlanDetailScreen> createState() => _MealPlanDetailScreenState();
}

class _MealPlanDetailScreenState extends ConsumerState<MealPlanDetailScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  void _refresh() {
    ref.invalidate(mealPlanDetailProvider);
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(mealPlanDetailProvider(widget.planId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: planAsync.when(
        data: (plan) {
          if (plan == null) {
            return const Center(
              child: Text('Plan bulunamadı'),
            );
          }

          return _buildContent(plan);
        },
        loading: () => const SkeletonLoader(
          type: SkeletonType.foodList,
          itemCount: 5,
        ),
        error: (error, _) => Center(
          child: Text('Hata: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(MealPlan plan) {
    final dailyPlan = plan.getDailyPlan(_selectedDate);

    return Column(
      children: [
        // Date selector
        _buildDateSelector(plan),

        // Meals list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Daily stats
              _buildDailyStats(dailyPlan),

              const SizedBox(height: 24),

              // Breakfast
              _buildMealTypeSection(
                plan,
                dailyPlan,
                'kahvalti',
                'Kahvaltı',
                Icons.wb_sunny_outlined,
                AppColors.breakfast,
              ),

              const SizedBox(height: 16),

              // Lunch
              _buildMealTypeSection(
                plan,
                dailyPlan,
                'ogle',
                'Öğle Yemeği',
                Icons.wb_sunny,
                AppColors.lunch,
              ),

              const SizedBox(height: 16),

              // Dinner
              _buildMealTypeSection(
                plan,
                dailyPlan,
                'aksam',
                'Akşam Yemeği',
                Icons.nightlight_outlined,
                AppColors.dinner,
              ),

              const SizedBox(height: 16),

              // Snacks
              _buildMealTypeSection(
                plan,
                dailyPlan,
                'ara_ogun',
                'Ara Öğün',
                Icons.coffee_outlined,
                AppColors.snack,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(MealPlan plan) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: plan.dailyPlans.length,
        itemBuilder: (context, index) {
          final date = plan.dailyPlans[index].date;
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'tr').format(date).substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d', 'tr').format(date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyStats(DailyMealPlan? dailyPlan) {
    if (dailyPlan == null || dailyPlan.meals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn(
              'Kalori',
              '${dailyPlan.totalCalories.toStringAsFixed(0)}',
              'kcal',
              Icons.local_fire_department,
              AppColors.error,
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.divider,
            ),
            _buildStatColumn(
              'Protein',
              '${dailyPlan.totalProtein.toStringAsFixed(0)}',
              'g',
              Icons.fitness_center,
              AppColors.protein,
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.divider,
            ),
            _buildStatColumn(
              'Karb.',
              '${dailyPlan.totalCarbs.toStringAsFixed(0)}',
              'g',
              Icons.grain,
              AppColors.carbs,
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.divider,
            ),
            _buildStatColumn(
              'Yağ',
              '${dailyPlan.totalFat.toStringAsFixed(0)}',
              'g',
              Icons.opacity,
              AppColors.fat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, String unit, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeSection(
    MealPlan plan,
    DailyMealPlan? dailyPlan,
    String mealType,
    String mealTypeDisplay,
    IconData icon,
    Color color,
  ) {
    final meals = dailyPlan?.getMealsByType(mealType) ?? [];
    final totalCalories = meals.fold(0.0, (sum, meal) => sum + meal.calories);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: meals.isEmpty ? AppColors.divider : color.withOpacity(0.3),
        ),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealTypeDisplay,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (meals.isNotEmpty)
                        Text(
                          '${totalCalories.toStringAsFixed(0)} kcal',
                          style: TextStyle(
                            fontSize: 14,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: color),
                  onPressed: () => _addMeal(plan.id, mealType),
                ),
              ],
            ),
            if (meals.isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Henüz yemek eklenmedi',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              ...meals.map((meal) => _buildMealItem(plan.id, meal)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(String planId, PlannedMeal meal) {
    return SwipeableItem(
      onDelete: () async {
        try {
          await MealPlanningService.removeMealFromPlan(
            planId: planId,
            date: _selectedDate,
            mealId: meal.id,
          );
          _refresh();
        } catch (e) {
          if (mounted) {
            CustomDialog.showError(
              context: context,
              title: 'Hata',
              message: 'Yemek silinemedi: $e',
            );
          }
        }
      },
      deleteConfirmMessage: '${meal.foodName} silinsin mi?',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            // Food image
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.divider.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                image: meal.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(meal.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: meal.imageUrl == null
                  ? const Icon(
                      Icons.restaurant,
                      color: AppColors.textSecondary,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Food info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.foodName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (meal.servingCount != 1.0)
                    Text(
                      '${meal.servingCount}x porsiyon',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),

            // Calories
            Text(
              '${meal.calories.toStringAsFixed(0)} kcal',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMeal(String planId, String mealType) {
    Navigator.push(
      context,
      PageTransitions.slideFromRight(
        FoodSearchScreen(mealType: mealType),
      ),
    ).then((selectedFood) {
      if (selectedFood != null) {
        // TODO: Add food to meal plan
        _refresh();
      }
    });
  }
}
