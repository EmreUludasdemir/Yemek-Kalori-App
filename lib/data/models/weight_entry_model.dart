/// Weight entry model for tracking weight progress
class WeightEntry {
  final String id;
  final String userId;
  final double weight; // in kg
  final DateTime loggedAt;
  final String? notes;
  final String? photoUrl;
  final Map<String, double>? measurements; // neck, waist, hips, chest, etc.

  WeightEntry({
    required this.id,
    required this.userId,
    required this.weight,
    required this.loggedAt,
    this.notes,
    this.photoUrl,
    this.measurements,
  });

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      weight: (json['weight'] as num).toDouble(),
      loggedAt: DateTime.parse(json['logged_at'] as String),
      notes: json['notes'] as String?,
      photoUrl: json['photo_url'] as String?,
      measurements: json['measurements'] != null
          ? Map<String, double>.from(json['measurements'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'weight': weight,
      'logged_at': loggedAt.toIso8601String(),
      'notes': notes,
      'photo_url': photoUrl,
      'measurements': measurements,
    };
  }

  /// Get formatted weight display
  String get weightDisplay => '${weight.toStringAsFixed(1)} kg';

  /// Copy with
  WeightEntry copyWith({
    String? id,
    String? userId,
    double? weight,
    DateTime? loggedAt,
    String? notes,
    String? photoUrl,
    Map<String, double>? measurements,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weight: weight ?? this.weight,
      loggedAt: loggedAt ?? this.loggedAt,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      measurements: measurements ?? this.measurements,
    );
  }
}

/// Weight goal model
class WeightGoal {
  final String id;
  final String userId;
  final double startWeight;
  final double targetWeight;
  final double? currentWeight;
  final DateTime startDate;
  final DateTime? targetDate;
  final String goalType; // lose, gain, maintain
  final bool isActive;
  final DateTime createdAt;

  WeightGoal({
    required this.id,
    required this.userId,
    required this.startWeight,
    required this.targetWeight,
    this.currentWeight,
    required this.startDate,
    this.targetDate,
    required this.goalType,
    this.isActive = true,
    required this.createdAt,
  });

  factory WeightGoal.fromJson(Map<String, dynamic> json) {
    return WeightGoal(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      startWeight: (json['start_weight'] as num).toDouble(),
      targetWeight: (json['target_weight'] as num).toDouble(),
      currentWeight: (json['current_weight'] as num?)?.toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'] as String)
          : null,
      goalType: json['goal_type'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_weight': startWeight,
      'target_weight': targetWeight,
      'current_weight': currentWeight,
      'start_date': startDate.toIso8601String(),
      'target_date': targetDate?.toIso8601String(),
      'goal_type': goalType,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Calculate weight difference from start
  double get weightDifference => (currentWeight ?? startWeight) - startWeight;

  /// Calculate weight remaining to goal
  double get weightRemaining => targetWeight - (currentWeight ?? startWeight);

  /// Calculate progress percentage (0-100)
  double get progressPercentage {
    final totalChange = targetWeight - startWeight;
    if (totalChange == 0) return 100;

    final currentChange = (currentWeight ?? startWeight) - startWeight;
    return (currentChange / totalChange * 100).clamp(0, 100);
  }

  /// Check if goal is reached
  bool get isReached => (currentWeight ?? startWeight) == targetWeight;

  /// Get goal type display name
  String get goalTypeDisplay {
    switch (goalType) {
      case 'lose':
        return 'Kilo Ver';
      case 'gain':
        return 'Kilo Al';
      case 'maintain':
        return 'Koruma';
      default:
        return goalType;
    }
  }

  /// Get days remaining to target date
  int? get daysRemaining {
    if (targetDate == null) return null;
    return targetDate!.difference(DateTime.now()).inDays;
  }

  /// Get recommended weekly weight change (kg/week)
  double? get recommendedWeeklyChange {
    if (targetDate == null) return null;

    final weeksRemaining = daysRemaining! / 7;
    if (weeksRemaining <= 0) return null;

    return weightRemaining / weeksRemaining;
  }
}

/// Weight statistics model
class WeightStats {
  final double? currentWeight;
  final double? previousWeight;
  final double? highestWeight;
  final double? lowestWeight;
  final double? averageWeight;
  final double? weightChange; // vs previous entry
  final int totalEntries;
  final DateTime? firstEntryDate;
  final DateTime? lastEntryDate;

  WeightStats({
    this.currentWeight,
    this.previousWeight,
    this.highestWeight,
    this.lowestWeight,
    this.averageWeight,
    this.weightChange,
    required this.totalEntries,
    this.firstEntryDate,
    this.lastEntryDate,
  });

  factory WeightStats.fromEntries(List<WeightEntry> entries) {
    if (entries.isEmpty) {
      return WeightStats(totalEntries: 0);
    }

    final sortedEntries = List<WeightEntry>.from(entries)
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

    final weights = entries.map((e) => e.weight).toList();
    final current = sortedEntries.first.weight;
    final previous = sortedEntries.length > 1 ? sortedEntries[1].weight : null;

    return WeightStats(
      currentWeight: current,
      previousWeight: previous,
      highestWeight: weights.reduce((a, b) => a > b ? a : b),
      lowestWeight: weights.reduce((a, b) => a < b ? a : b),
      averageWeight: weights.reduce((a, b) => a + b) / weights.length,
      weightChange: previous != null ? current - previous : null,
      totalEntries: entries.length,
      firstEntryDate: sortedEntries.last.loggedAt,
      lastEntryDate: sortedEntries.first.loggedAt,
    );
  }

  /// Get weight change display with sign
  String? get weightChangeDisplay {
    if (weightChange == null) return null;

    final sign = weightChange! >= 0 ? '+' : '';
    return '$sign${weightChange!.toStringAsFixed(1)} kg';
  }

  /// Check if weight is increasing
  bool get isIncreasing => weightChange != null && weightChange! > 0;

  /// Check if weight is decreasing
  bool get isDecreasing => weightChange != null && weightChange! < 0;

  /// Check if weight is stable
  bool get isStable => weightChange != null && weightChange!.abs() < 0.1;
}
