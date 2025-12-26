import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/image_picker_service.dart';

class AIFoodRecognitionScreen extends ConsumerStatefulWidget {
  const AIFoodRecognitionScreen({super.key});

  @override
  ConsumerState<AIFoodRecognitionScreen> createState() =>
      _AIFoodRecognitionScreenState();
}

class _AIFoodRecognitionScreenState
    extends ConsumerState<AIFoodRecognitionScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  List<RecognizedFood> _recognizedFoods = [];

  Future<void> _pickImage(bool fromCamera) async {
    final image = fromCamera
        ? await ImagePickerService.pickFromCamera()
        : await ImagePickerService.pickFromGallery();

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _recognizedFoods = [];
      });
      _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _isAnalyzing = true);

    // Simulate AI analysis (2-3 seconds)
    await Future.delayed(const Duration(seconds: 2));

    // Mock recognized foods
    // In production, call AI backend API
    final mockResults = [
      RecognizedFood(
        name: 'Mercimek Çorbası',
        confidence: 0.92,
        calories: 180,
        protein: 9,
        carbs: 28,
        fat: 4,
        portion: '1 kase (250ml)',
      ),
      RecognizedFood(
        name: 'Ekmek',
        confidence: 0.88,
        calories: 120,
        protein: 4,
        carbs: 22,
        fat: 2,
        portion: '1 dilim (40g)',
      ),
    ];

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _recognizedFoods = mockResults;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Yemek Tanıma'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.psychology, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text('AI Yemek Tanıma'),
                    ],
                  ),
                  content: const Text(
                    'Yemek fotoğrafını çekin veya galerinizden seçin. '
                    'Yapay zeka yemeği tanıyacak ve besin değerlerini otomatik hesaplayacak.\n\n'
                    'Not: Bu özellik şu anda geliştirme aşamasındadır. '
                    'Gösterilen sonuçlar örnek verilerdir.',
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image Selection Section
            if (_selectedImage == null) ...[
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_camera,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Yemek Fotoğrafı Ekle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kamera ile çek veya galeriden seç',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(true),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Kamera'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(false),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeri'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Image Preview & Results
            if (_selectedImage != null) ...[
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _selectedImage!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 16),

              // Retry Button
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    _recognizedFoods = [];
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Farklı Fotoğraf Seç'),
              ),

              const SizedBox(height: 24),

              // Analysis Status
              if (_isAnalyzing)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text(
                          'Fotoğraf Analiz Ediliyor...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AI yemeği tanıyor',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Results
              if (!_isAnalyzing && _recognizedFoods.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      '${_recognizedFoods.length} Yemek Tanındı',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                ..._recognizedFoods.map((food) => _FoodCard(
                      food: food,
                      onAdd: () => _addFood(food),
                    )),

                const SizedBox(height: 16),

                // Add All Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addAllFoods,
                    icon: const Icon(Icons.add),
                    label: const Text('Tümünü Ekle'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
              ],
            ],

            // Beta Notice
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Beta Özellik',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AI yemek tanıma özelliği beta aşamasındadır. '
                          'Sonuçları kontrol edip düzeltebilirsiniz.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
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
      ),
    );
  }

  void _addFood(RecognizedFood food) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food.name} eklendi'),
        duration: const Duration(seconds: 1),
      ),
    );
    // TODO: Navigate to add food screen with pre-filled data
  }

  void _addAllFoods() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_recognizedFoods.length} yemek eklendi'),
        duration: const Duration(seconds: 2),
      ),
    );
    // TODO: Add all foods to meal log
    Navigator.pop(context);
  }
}

class _FoodCard extends StatelessWidget {
  final RecognizedFood food;
  final VoidCallback onAdd;

  const _FoodCard({
    required this.food,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Name & Confidence
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        food.portion,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(food.confidence).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: _getConfidenceColor(food.confidence),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(food.confidence * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getConfidenceColor(food.confidence),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Nutrition Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NutritionBadge(
                  label: 'Kalori',
                  value: '${food.calories}',
                  color: AppColors.error,
                  icon: Icons.local_fire_department,
                ),
                _NutritionBadge(
                  label: 'Protein',
                  value: '${food.protein}g',
                  color: AppColors.protein,
                  icon: Icons.egg,
                ),
                _NutritionBadge(
                  label: 'Karb',
                  value: '${food.carbs}g',
                  color: AppColors.carbs,
                  icon: Icons.rice_bowl,
                ),
                _NutritionBadge(
                  label: 'Yağ',
                  value: '${food.fat}g',
                  color: AppColors.fat,
                  icon: Icons.water_drop,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Add Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return AppColors.success;
    if (confidence >= 0.7) return AppColors.warning;
    return AppColors.error;
  }
}

class _NutritionBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _NutritionBadge({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// ==================== Models ====================

class RecognizedFood {
  final String name;
  final double confidence;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String portion;

  RecognizedFood({
    required this.name,
    required this.confidence,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.portion,
  });
}
