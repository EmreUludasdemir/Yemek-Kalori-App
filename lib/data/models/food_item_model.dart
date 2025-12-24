import 'package:equatable/equatable.dart';

class FoodItem extends Equatable {
  final String id;
  final String nameTr;
  final String? nameEn;
  final String? brand;
  final String? barcode;
  final double servingSize;
  final String servingUnit;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final double? saturatedFat;
  final double? cholesterol;
  final String? category;
  final String? source; // 'turkomp', 'fatsecret', 'openfoodfacts', 'user'
  final bool isVerified;
  final String? createdBy;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FoodItem({
    required this.id,
    required this.nameTr,
    this.nameEn,
    this.brand,
    this.barcode,
    required this.servingSize,
    required this.servingUnit,
    required this.calories,
    this.protein = 0,
    this.carbohydrates = 0,
    this.fat = 0,
    this.fiber,
    this.sugar,
    this.sodium,
    this.saturatedFat,
    this.cholesterol,
    this.category,
    this.source,
    this.isVerified = false,
    this.createdBy,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] ?? '',
      nameTr: json['name_tr'] ?? '',
      nameEn: json['name_en'],
      brand: json['brand'],
      barcode: json['barcode'],
      servingSize: (json['serving_size'] ?? 100).toDouble(),
      servingUnit: json['serving_unit'] ?? 'gram',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbohydrates: (json['carbohydrates'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: json['fiber']?.toDouble(),
      sugar: json['sugar']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
      saturatedFat: json['saturated_fat']?.toDouble(),
      cholesterol: json['cholesterol']?.toDouble(),
      category: json['category'],
      source: json['source'],
      isVerified: json['is_verified'] ?? false,
      createdBy: json['created_by'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_tr': nameTr,
      'name_en': nameEn,
      'brand': brand,
      'barcode': barcode,
      'serving_size': servingSize,
      'serving_unit': servingUnit,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'saturated_fat': saturatedFat,
      'cholesterol': cholesterol,
      'category': category,
      'source': source,
      'is_verified': isVerified,
      'created_by': createdBy,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName {
    if (brand != null && brand!.isNotEmpty) {
      return '$brand - $nameTr';
    }
    return nameTr;
  }

  String get categoryDisplay {
    switch (category) {
      case 'ana_yemek':
        return 'Ana Yemek';
      case 'corba':
        return 'Çorba';
      case 'salata':
        return 'Salata';
      case 'tatli':
        return 'Tatlı';
      case 'icecek':
        return 'İçecek';
      case 'meze':
        return 'Meze';
      case 'kahvalti':
        return 'Kahvaltılık';
      default:
        return category ?? 'Diğer';
    }
  }

  String get servingSizeDisplay {
    return '${servingSize.toStringAsFixed(0)} $servingUnit';
  }

  @override
  List<Object?> get props => [
        id,
        nameTr,
        nameEn,
        brand,
        barcode,
        servingSize,
        servingUnit,
        calories,
        protein,
        carbohydrates,
        fat,
        fiber,
        sugar,
        sodium,
        saturatedFat,
        cholesterol,
        category,
        source,
        isVerified,
        createdBy,
        imageUrl,
        createdAt,
        updatedAt,
      ];
}
