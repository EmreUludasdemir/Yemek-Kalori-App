import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/ai_food_recognition_service.dart';
import '../food_log/add_food_screen.dart';

class FoodRecognitionResultScreen extends StatefulWidget {
  final String imagePath;
  final FoodRecognitionResult recognitionResult;

  const FoodRecognitionResultScreen({
    super.key,
    required this.imagePath,
    required this.recognitionResult,
  });

  @override
  State<FoodRecognitionResultScreen> createState() =>
      _FoodRecognitionResultScreenState();
}

class _FoodRecognitionResultScreenState
    extends State<FoodRecognitionResultScreen> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Auto-select top prediction if confidence is high
    if (widget.recognitionResult.hasPredictions &&
        widget.recognitionResult.topPrediction!.confidence >= 0.8) {
      _selectedIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tanıma Sonucu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: widget.recognitionResult.success
          ? _buildSuccessView()
          : _buildErrorView(),
    );
  }

  Widget _buildSuccessView() {
    final predictions = widget.recognitionResult.predictions;

    if (!widget.recognitionResult.hasPredictions) {
      return _buildNoResultsView();
    }

    return Column(
      children: [
        // Image preview
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: FileImage(File(widget.imagePath)),
              fit: BoxFit.contain,
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Tahminleri',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${predictions.length} yemek bulundu',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Predictions list
                ...predictions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final prediction = entry.value;
                  return _buildPredictionCard(index, prediction);
                }),

                const SizedBox(height: 16),

                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Doğru yemeği seçin ve porsiyonu ayarlayın',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom button
        if (_selectedIndex != null)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continueWithSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Devam Et',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPredictionCard(int index, FoodPrediction prediction) {
    final isSelected = _selectedIndex == index;
    final isTopPrediction = index == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Selection indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Food name
                  Expanded(
                    child: Text(
                      prediction.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Top prediction badge
                  if (isTopPrediction)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'En Olası',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Confidence bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: prediction.confidence,
                        minHeight: 6,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          prediction.confidence >= 0.8
                              ? AppColors.success
                              : prediction.confidence >= 0.6
                                  ? AppColors.warning
                                  : AppColors.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    prediction.confidencePercentage,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nutrition info
              Row(
                children: [
                  _buildNutrientChip(
                    '${prediction.calories.toStringAsFixed(0)} kcal',
                    AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildNutrientChip(
                    'P: ${prediction.protein.toStringAsFixed(0)}g',
                    AppColors.protein,
                  ),
                  const SizedBox(width: 8),
                  _buildNutrientChip(
                    'K: ${prediction.carbs.toStringAsFixed(0)}g',
                    AppColors.carbs,
                  ),
                  const SizedBox(width: 8),
                  _buildNutrientChip(
                    'Y: ${prediction.fat.toStringAsFixed(0)}g',
                    AppColors.fat,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Serving size
              Text(
                '${prediction.servingSize.toStringAsFixed(0)} ${prediction.servingUnit} porsiyon',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Yemek Tanımlanamadı',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Fotoğrafta yemek bulunamadı.\nManuel arama yapabilirsiniz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.search),
              label: const Text('Manuel Ara'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            const Text(
              'Bir Hata Oluştu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.recognitionResult.error ?? 'Bilinmeyen hata',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Geri'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _continueWithSelection() {
    if (_selectedIndex == null) return;

    final prediction = widget.recognitionResult.predictions[_selectedIndex!];
    final foodItem = prediction.toFoodItem();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFoodScreen(
          foodItem: foodItem,
          mealType: _getMealTypeFromTime(),
        ),
      ),
    );
  }

  String _getMealTypeFromTime() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) return 'kahvalti';
    if (hour >= 11 && hour < 16) return 'ogle';
    if (hour >= 16 && hour < 21) return 'aksam';
    return 'ara_ogun';
  }
}
