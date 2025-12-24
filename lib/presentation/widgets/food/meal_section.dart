import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/food_log_model.dart';

class MealSection extends StatelessWidget {
  final String mealType;
  final List<FoodLog> foodLogs;
  final VoidCallback onAddFood;

  const MealSection({
    super.key,
    required this.mealType,
    required this.foodLogs,
    required this.onAddFood,
  });

  String get mealTypeDisplay {
    switch (mealType) {
      case 'kahvalti':
        return 'Kahvaltı';
      case 'ogle':
        return 'Öğle Yemeği';
      case 'aksam':
        return 'Akşam Yemeği';
      case 'ara_ogun':
        return 'Ara Öğün';
      default:
        return mealType;
    }
  }

  IconData get mealIcon {
    switch (mealType) {
      case 'kahvalti':
        return Icons.wb_sunny_outlined;
      case 'ogle':
        return Icons.wb_sunny;
      case 'aksam':
        return Icons.nightlight_outlined;
      case 'ara_ogun':
        return Icons.coffee_outlined;
      default:
        return Icons.restaurant;
    }
  }

  Color get mealColor {
    switch (mealType) {
      case 'kahvalti':
        return AppColors.breakfast;
      case 'ogle':
        return AppColors.lunch;
      case 'aksam':
        return AppColors.dinner;
      case 'ara_ogun':
        return AppColors.snack;
      default:
        return AppColors.primary;
    }
  }

  double get totalCalories {
    return foodLogs.fold(0, (sum, log) => sum + log.calories);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: foodLogs.isEmpty
              ? AppColors.divider
              : mealColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onAddFood,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: mealColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      mealIcon,
                      color: mealColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Meal type
                  Expanded(
                    child: Text(
                      mealTypeDisplay,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Calories
                  if (foodLogs.isNotEmpty)
                    Text(
                      '${totalCalories.toStringAsFixed(0)} kcal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: mealColor,
                      ),
                    ),

                  // Add button
                  const SizedBox(width: 8),
                  Icon(
                    foodLogs.isEmpty ? Icons.add_circle_outline : Icons.edit_outlined,
                    color: mealColor,
                    size: 20,
                  ),
                ],
              ),

              // Food list
              if (foodLogs.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...foodLogs.map((log) => _buildFoodItem(log)),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'Henüz eklenmedi',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodItem(FoodLog log) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          // Food image or icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.divider.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              image: log.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(log.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: log.imageUrl == null
                ? Icon(
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
                  log.foodName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (log.servingCount != 1.0)
                  Text(
                    '${log.servingCount}x porsiyon',
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
            '${log.calories.toStringAsFixed(0)} kcal',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
