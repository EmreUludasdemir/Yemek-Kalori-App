import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../data/models/food_item_model.dart';
import '../../widgets/common/app_button.dart';

class AddFoodScreen extends StatefulWidget {
  final FoodItem foodItem;
  final String mealType;

  const AddFoodScreen({
    super.key,
    required this.foodItem,
    required this.mealType,
  });

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  double _servingCount = 1.0;
  late String _selectedMealType;
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalCalories => widget.foodItem.calories * _servingCount;
  double get _totalProtein => widget.foodItem.protein * _servingCount;
  double get _totalCarbs => widget.foodItem.carbohydrates * _servingCount;
  double get _totalFat => widget.foodItem.fat * _servingCount;

  Future<void> _saveFoodLog() async {
    setState(() => _isSaving = true);

    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await SupabaseConfig.client.from('food_logs').insert({
        'id': const Uuid().v4(),
        'user_id': userId,
        'food_id': widget.foodItem.id,
        'custom_food_name': widget.foodItem.nameTr,
        'meal_type': _selectedMealType,
        'serving_count': _servingCount,
        'calories': _totalCalories,
        'protein': _totalProtein,
        'carbohydrates': _totalCarbs,
        'fat': _totalFat,
        'image_url': widget.foodItem.imageUrl,
        'ai_recognized': false,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'logged_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Yemek başarıyla eklendi!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );

        // Go back to home (2 screens back)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yemek Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Food image
                        if (widget.foodItem.imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.foodItem.imageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildFoodIcon(),
                            ),
                          )
                        else
                          _buildFoodIcon(),
                        const SizedBox(width: 16),

                        // Food info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.foodItem.displayName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.foodItem.servingSizeDisplay,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.foodItem.categoryDisplay,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Portion adjustment
            const Text(
              'Porsiyon',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _servingCount > 0.25
                          ? () => setState(() => _servingCount -= 0.25)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 32,
                      color: AppColors.primary,
                    ),

                    Column(
                      children: [
                        Text(
                          _servingCount.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'porsiyon',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    IconButton(
                      onPressed: () => setState(() => _servingCount += 0.25),
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 32,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Nutrition info
            const Text(
              'Besin Değerleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 0,
              color: AppColors.primary.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildNutrientRow(
                      'Kalori',
                      _totalCalories,
                      'kcal',
                      AppColors.primary,
                      isBold: true,
                    ),
                    const Divider(height: 24),
                    _buildNutrientRow(
                      'Protein',
                      _totalProtein,
                      'g',
                      AppColors.protein,
                    ),
                    const SizedBox(height: 12),
                    _buildNutrientRow(
                      'Karbonhidrat',
                      _totalCarbs,
                      'g',
                      AppColors.carbs,
                    ),
                    const SizedBox(height: 12),
                    _buildNutrientRow(
                      'Yağ',
                      _totalFat,
                      'g',
                      AppColors.fat,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Meal type selection
            const Text(
              'Öğün Seç',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMealTypeChip('kahvalti', 'Kahvaltı', Icons.wb_sunny_outlined),
                _buildMealTypeChip('ogle', 'Öğle', Icons.wb_sunny),
                _buildMealTypeChip('aksam', 'Akşam', Icons.nightlight_outlined),
                _buildMealTypeChip('ara_ogun', 'Ara Öğün', Icons.coffee_outlined),
              ],
            ),

            const SizedBox(height: 24),

            // Notes
            const Text(
              'Notlar (Opsiyonel)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Not ekleyin...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            AppButton(
              text: 'Kaydet',
              onPressed: _isSaving ? null : _saveFoodLog,
              isLoading: _isSaving,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.divider.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.restaurant,
        color: AppColors.textSecondary,
        size: 40,
      ),
    );
  }

  Widget _buildNutrientRow(
    String label,
    double value,
    String unit,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '${value.toStringAsFixed(isBold ? 0 : 1)} $unit',
          style: TextStyle(
            fontSize: isBold ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeChip(String mealType, String label, IconData icon) {
    final isSelected = _selectedMealType == mealType;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedMealType = mealType);
        }
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
