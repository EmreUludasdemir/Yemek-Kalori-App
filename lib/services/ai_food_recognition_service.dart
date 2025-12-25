import 'dart:io';
import 'package:dio/dio.dart';

import '../data/models/food_item_model.dart';

/// AI-powered food recognition service
/// Supports both on-device TFLite and cloud-based Calorie Mama API
class AIFoodRecognitionService {
  final Dio _dio = Dio();

  // Calorie Mama API credentials
  // Free tier: 5,000 requests/month
  static const String _calorieMamaApiKey = String.fromEnvironment(
    'CALORIE_MAMA_API_KEY',
    defaultValue: '',
  );
  static const String _calorieMamaApiUrl =
      'https://api-2445582032290.production.gw.apicast.io/v1/foodrecognition';

  /// Recognize food from image
  /// Returns a list of possible food matches with confidence scores
  Future<FoodRecognitionResult> recognizeFood(File imageFile) async {
    try {
      // Try on-device TFLite first (faster, offline)
      final tfliteResult = await _recognizeWithTFLite(imageFile);
      if (tfliteResult != null) {
        return tfliteResult;
      }

      // Fallback to Calorie Mama API
      return await _recognizeWithCalorieMama(imageFile);
    } catch (e) {
      print('❌ Food recognition error: $e');
      return FoodRecognitionResult(
        success: false,
        error: 'Yemek tanıma başarısız: $e',
        predictions: [],
      );
    }
  }

  /// On-device food recognition using TFLite
  /// Requires trained model file: assets/models/turkish_food_model.tflite
  Future<FoodRecognitionResult?> _recognizeWithTFLite(File imageFile) async {
    try {
      // TODO: Implement TFLite model inference
      // This requires:
      // 1. Training a model on TurkishFoods-15 dataset
      // 2. Converting to TFLite format
      // 3. Adding tflite_flutter package integration

      // For now, return null to fallback to API
      return null;
    } catch (e) {
      print('⚠️ TFLite recognition failed: $e');
      return null;
    }
  }

  /// Cloud-based food recognition using Calorie Mama API
  Future<FoodRecognitionResult> _recognizeWithCalorieMama(
      File imageFile) async {
    if (_calorieMamaApiKey.isEmpty) {
      return FoodRecognitionResult(
        success: false,
        error: 'Calorie Mama API anahtarı yapılandırılmamış',
        predictions: [],
      );
    }

    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'food.jpg',
        ),
      });

      final response = await _dio.post(
        _calorieMamaApiUrl,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_calorieMamaApiKey',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return _parseCalorieMamaResponse(response.data);
      } else {
        return FoodRecognitionResult(
          success: false,
          error: 'API hatası: ${response.statusCode}',
          predictions: [],
        );
      }
    } catch (e) {
      return FoodRecognitionResult(
        success: false,
        error: 'API isteği başarısız: $e',
        predictions: [],
      );
    }
  }

  /// Parse Calorie Mama API response
  FoodRecognitionResult _parseCalorieMamaResponse(dynamic data) {
    try {
      final results = data['results'] as List;
      if (results.isEmpty) {
        return FoodRecognitionResult(
          success: false,
          error: 'Yemek tanımlanamadı',
          predictions: [],
        );
      }

      final predictions = results.map((item) {
        final items = item['items'] as List;
        if (items.isEmpty) return null;

        final foodData = items[0];
        return FoodPrediction(
          name: foodData['name'] as String,
          confidence: (item['score'] as num).toDouble(),
          calories: (foodData['nutrition']['calories'] as num).toDouble(),
          protein: (foodData['nutrition']['protein'] as num).toDouble(),
          carbs: (foodData['nutrition']['carbs'] as num).toDouble(),
          fat: (foodData['nutrition']['fat'] as num).toDouble(),
          servingSize: (foodData['serving_size'] as num?)?.toDouble() ?? 100,
          servingUnit: foodData['serving_unit'] as String? ?? 'g',
        );
      }).whereType<FoodPrediction>().toList();

      return FoodRecognitionResult(
        success: true,
        predictions: predictions,
      );
    } catch (e) {
      return FoodRecognitionResult(
        success: false,
        error: 'Yanıt ayrıştırma hatası: $e',
        predictions: [],
      );
    }
  }

  /// Mock recognition for testing (returns Turkish foods)
  Future<FoodRecognitionResult> mockRecognition() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    return FoodRecognitionResult(
      success: true,
      predictions: [
        FoodPrediction(
          name: 'Döner Kebap',
          confidence: 0.92,
          calories: 265,
          protein: 18,
          carbs: 12,
          fat: 16,
          servingSize: 150,
          servingUnit: 'g',
        ),
        FoodPrediction(
          name: 'Tavuk Döner',
          confidence: 0.78,
          calories: 220,
          protein: 22,
          carbs: 10,
          fat: 10,
          servingSize: 150,
          servingUnit: 'g',
        ),
        FoodPrediction(
          name: 'İskender Kebap',
          confidence: 0.65,
          calories: 380,
          protein: 25,
          carbs: 20,
          fat: 22,
          servingSize: 200,
          servingUnit: 'g',
        ),
      ],
    );
  }
}

/// Food recognition result
class FoodRecognitionResult {
  final bool success;
  final String? error;
  final List<FoodPrediction> predictions;

  FoodRecognitionResult({
    required this.success,
    this.error,
    required this.predictions,
  });

  bool get hasPredictions => predictions.isNotEmpty;
  FoodPrediction? get topPrediction =>
      predictions.isNotEmpty ? predictions.first : null;
}

/// Individual food prediction
class FoodPrediction {
  final String name;
  final double confidence; // 0.0 to 1.0
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSize;
  final String servingUnit;

  FoodPrediction({
    required this.name,
    required this.confidence,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    required this.servingUnit,
  });

  /// Convert to FoodItem for adding to food log
  FoodItem toFoodItem() {
    return FoodItem(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      nameTr: name,
      nameEn: null,
      brand: null,
      barcode: null,
      servingSize: servingSize,
      servingUnit: servingUnit,
      calories: calories,
      protein: protein,
      carbohydrates: carbs,
      fat: fat,
      fiber: 0,
      sugar: 0,
      sodium: 0,
      category: null,
      imageUrl: null,
      source: 'ai',
      isVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String get confidencePercentage => '${(confidence * 100).toStringAsFixed(0)}%';
}
