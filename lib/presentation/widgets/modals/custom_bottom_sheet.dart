import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';

/// Modern bottom sheet with drag handle
class CustomBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            if (enableDrag)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

            // Title
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTheme.h3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

            // Content
            Flexible(
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  /// Quick add food bottom sheet
  static Future<T?> showQuickAdd<T>({
    required BuildContext context,
    required Function(String mealType) onMealTypeSelected,
  }) {
    return show<T>(
      context: context,
      title: 'Hızlı Ekle',
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _MealTypeOption(
            icon: Icons.wb_sunny_outlined,
            title: 'Kahvaltı',
            color: AppColors.breakfast,
            onTap: () {
              onMealTypeSelected('breakfast');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _MealTypeOption(
            icon: Icons.lunch_dining_outlined,
            title: 'Öğle Yemeği',
            color: AppColors.lunch,
            onTap: () {
              onMealTypeSelected('lunch');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _MealTypeOption(
            icon: Icons.dinner_dining_outlined,
            title: 'Akşam Yemeği',
            color: AppColors.dinner,
            onTap: () {
              onMealTypeSelected('dinner');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          _MealTypeOption(
            icon: Icons.cookie_outlined,
            title: 'Ara Öğün',
            color: AppColors.snack,
            onTap: () {
              onMealTypeSelected('snack');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Filter options bottom sheet
  static Future<T?> showFilters<T>({
    required BuildContext context,
    required List<FilterOption> options,
    required Function(String) onFilterSelected,
    String? selectedFilter,
  }) {
    return show<T>(
      context: context,
      title: 'Filtrele',
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: options.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option.value == selectedFilter;

          return ListTile(
            leading: Icon(
              option.icon,
              color: isSelected ? AppColors.primary : null,
            ),
            title: Text(
              option.label,
              style: AppTheme.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              onFilterSelected(option.value);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  /// Date picker bottom sheet
  static Future<DateTime?> showDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    DateTime? selectedDate = initialDate ?? DateTime.now();

    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text('Tarih Seç', style: AppTheme.h3),
            ),

            // Calendar
            CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: firstDate ?? DateTime(2020),
              lastDate: lastDate ?? DateTime.now(),
              onDateChanged: (date) {
                selectedDate = date;
              },
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, selectedDate),
                      child: const Text('Seç'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealTypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MealTypeOption({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTheme.h4.copyWith(color: color),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

class FilterOption {
  final String label;
  final String value;
  final IconData icon;

  FilterOption({
    required this.label,
    required this.value,
    required this.icon,
  });
}
