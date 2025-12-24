import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

import '../data/models/food_recognition_result.dart';
import '../data/models/nutrition_model.dart';

class AIRecognitionService {
  Interpreter? _interpreter;
  List<String>? _turkishFoodLabels;
  final Dio _dio = Dio();

  // TODO: Add your Calorie Mama API key
  static const String _calorieMamaApiKey = String.fromEnvironment(
    'CALORIE_MAMA_API_KEY',
    defaultValue: 'YOUR_API_KEY',
  );

  // Turkish food labels for on-device model
  static const List<String> _defaultTurkishFoodLabels = [
    'döner',
    'lahmacun',
    'pide',
    'mantı',
    'köfte',
    'iskender',
    'menemen',
    'dolma',
    'sarma',
    'börek',
    'baklava',
    'künefe',
    'mercimek_corbasi',
    'kuru_fasulye',
    'pilav',
    'karniyarik',
    'imam_bayildi',
    'adana_kebap',
    'simit',
    'pogaca',
    'sucuklu_yumurta',
    'ezogelin_corbasi',
    'tarhana_corbasi',
    'kazandibi',
    'sutlac',
  ];

  // Confidence threshold for using local model
  static const double _confidenceThreshold = 0.80;

  /// Initialize the TFLite model for Turkish food recognition
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/ml_models/turkish_food_model.tflite',
      );
      _turkishFoodLabels = _defaultTurkishFoodLabels;
      print('✅ TFLite model loaded successfully');
    } catch (e) {
      print('⚠️ TFLite model not found, using API only: $e');
      _interpreter = null;
    }
  }

  /// Recognize food from image file
  /// 1. Try on-device TFLite model first (fast, free, offline)
  /// 2. If confidence < 80%, call Calorie Mama API
  Future<FoodRecognitionResult> recognizeFood(File imageFile) async {
    // 1. Try local model first
    final localResult = await _runLocalModel(imageFile);

    if (localResult != null && localResult.confidence > _confidenceThreshold) {
      print('✅ Using local TFLite result (${localResult.confidence.toStringAsFixed(2)})');
      return localResult;
    }

    // 2. Fall back to API
    print('⚠️ Low confidence, calling Calorie Mama API...');
    return await _callCalorieMamaAPI(imageFile);
  }

  /// Run on-device TFLite model
  Future<FoodRecognitionResult?> _runLocalModel(File imageFile) async {
    if (_interpreter == null || _turkishFoodLabels == null) {
      return null;
    }

    try {
      // Read and preprocess image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      // Resize to 224x224 (standard for MobileNet)
      final resized = img.copyResize(image, width: 224, height: 224);

      // Normalize pixel values to [-1, 1] for MobileNet
      final input = _imageToByteList(resized);

      // Run inference
      final output = List.filled(1 * _turkishFoodLabels!.length, 0.0)
          .reshape([1, _turkishFoodLabels!.length]);

      _interpreter!.run(input, output);

      // Get top prediction
      final probabilities = output[0] as List<double>;
      double maxProb = 0;
      int maxIndex = 0;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      final foodName = _turkishFoodLabels![maxIndex];

      // Get nutrition info from local database for Turkish foods
      final nutrition = _getTurkishFoodNutrition(foodName);

      return FoodRecognitionResult(
        foodName: _formatFoodName(foodName),
        confidence: maxProb,
        nutrition: nutrition,
        servingSize: 1.0,
        servingUnit: 'porsiyon',
        source: 'tflite',
        category: _getCategoryForFood(foodName),
      );
    } catch (e) {
      print('❌ Error running local model: $e');
      return null;
    }
  }

  /// Call Calorie Mama API for food recognition
  Future<FoodRecognitionResult> _callCalorieMamaAPI(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _dio.post(
        'https://api.caloriemama.ai/v1/foodrecognition',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_calorieMamaApiKey',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Parse Calorie Mama response
        final results = data['results'] as List<dynamic>;
        if (results.isEmpty) {
          throw Exception('No food detected');
        }

        final topResult = results[0];
        final foodName = topResult['name'] ?? 'Unknown Food';
        final confidence = (topResult['confidence'] ?? 0.5).toDouble();

        // Extract nutrition info
        final nutrition = NutritionInfo(
          calories: (topResult['calories'] ?? 0).toDouble(),
          protein: (topResult['protein'] ?? 0).toDouble(),
          carbohydrates: (topResult['carbohydrates'] ?? 0).toDouble(),
          fat: (topResult['fat'] ?? 0).toDouble(),
          fiber: topResult['fiber']?.toDouble(),
          sugar: topResult['sugar']?.toDouble(),
          sodium: topResult['sodium']?.toDouble(),
          saturatedFat: topResult['saturated_fat']?.toDouble(),
        );

        return FoodRecognitionResult(
          foodName: foodName,
          confidence: confidence,
          nutrition: nutrition,
          servingSize: (topResult['serving_size'] ?? 100).toDouble(),
          servingUnit: topResult['serving_unit'] ?? 'gram',
          source: 'calorie_mama',
        );
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Calorie Mama API error: $e');

      // Fallback to default values
      return FoodRecognitionResult(
        foodName: 'Tanınmayan Yemek',
        confidence: 0.0,
        nutrition: const NutritionInfo(
          calories: 0,
          protein: 0,
          carbohydrates: 0,
          fat: 0,
        ),
        servingSize: 100,
        servingUnit: 'gram',
        source: 'manual',
      );
    }
  }

  /// Convert image to normalized byte list for TFLite
  Uint8List _imageToByteList(img.Image image) {
    final convertedBytes = Float32List(1 * 224 * 224 * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = image.getPixel(x, y);

        // Normalize to [-1, 1] for MobileNet
        buffer[pixelIndex++] = ((pixel.r) / 127.5) - 1.0;
        buffer[pixelIndex++] = ((pixel.g) / 127.5) - 1.0;
        buffer[pixelIndex++] = ((pixel.b) / 127.5) - 1.0;
      }
    }

    return convertedBytes.buffer.asUint8List();
  }

  /// Get nutrition info for Turkish foods
  /// TODO: This should query the local database or TürKomp API
  NutritionInfo _getTurkishFoodNutrition(String foodKey) {
    // Hardcoded values for common Turkish foods
    // In production, this should query Supabase or local Hive cache
    final nutritionMap = {
      'döner': const NutritionInfo(
        calories: 450,
        protein: 28,
        carbohydrates: 35,
        fat: 22,
      ),
      'lahmacun': const NutritionInfo(
        calories: 270,
        protein: 12,
        carbohydrates: 38,
        fat: 8,
      ),
      'menemen': const NutritionInfo(
        calories: 250,
        protein: 12,
        carbohydrates: 8,
        fat: 18,
      ),
      'iskender': const NutritionInfo(
        calories: 650,
        protein: 45,
        carbohydrates: 35,
        fat: 38,
      ),
      'köfte': const NutritionInfo(
        calories: 350,
        protein: 28,
        carbohydrates: 5,
        fat: 24,
      ),
      'mercimek_corbasi': const NutritionInfo(
        calories: 150,
        protein: 8,
        carbohydrates: 22,
        fat: 4,
      ),
      'baklava': const NutritionInfo(
        calories: 280,
        protein: 4,
        carbohydrates: 32,
        fat: 16,
      ),
    };

    return nutritionMap[foodKey] ??
        const NutritionInfo(
          calories: 200,
          protein: 10,
          carbohydrates: 20,
          fat: 10,
        );
  }

  /// Format food name for display
  String _formatFoodName(String key) {
    final nameMap = {
      'döner': 'Döner',
      'lahmacun': 'Lahmacun',
      'menemen': 'Menemen',
      'iskender': 'İskender Kebap',
      'köfte': 'Izgara Köfte',
      'mercimek_corbasi': 'Mercimek Çorbası',
      'baklava': 'Baklava',
      'künefe': 'Künefe',
      'pide': 'Pide',
      'mantı': 'Mantı',
      'dolma': 'Dolma',
      'sarma': 'Sarma',
      'börek': 'Börek',
    };

    return nameMap[key] ?? key;
  }

  /// Get category for Turkish food
  String _getCategoryForFood(String foodKey) {
    if (foodKey.contains('corba')) return 'corba';
    if (foodKey.contains('tatli') ||
        ['baklava', 'künefe', 'sutlac', 'kazandibi'].contains(foodKey)) {
      return 'tatli';
    }
    if (['menemen', 'sucuklu_yumurta', 'simit', 'pogaca'].contains(foodKey)) {
      return 'kahvalti';
    }
    return 'ana_yemek';
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
  }
}
