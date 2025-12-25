import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../data/models/weight_entry_model.dart';

/// Service for tracking weight and body measurements
class WeightTrackingService {
  static const _uuid = Uuid();

  // ========== Weight Entries ==========

  /// Add new weight entry
  static Future<WeightEntry> addWeightEntry({
    required String userId,
    required double weight,
    DateTime? loggedAt,
    String? notes,
    String? photoUrl,
    Map<String, double>? measurements,
  }) async {
    final id = _uuid.v4();
    final timestamp = loggedAt ?? DateTime.now();

    final entry = WeightEntry(
      id: id,
      userId: userId,
      weight: weight,
      loggedAt: timestamp,
      notes: notes,
      photoUrl: photoUrl,
      measurements: measurements,
    );

    await SupabaseConfig.client.from('weight_entries').insert(entry.toJson());

    // Update current weight in active goal
    await _updateGoalCurrentWeight(userId, weight);

    return entry;
  }

  /// Get all weight entries for user
  static Future<List<WeightEntry>> getWeightEntries(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    var query = SupabaseConfig.client
        .from('weight_entries')
        .select()
        .eq('user_id', userId)
        .order('logged_at', ascending: false);

    if (startDate != null) {
      query = query.gte('logged_at', startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.lte('logged_at', endDate.toIso8601String());
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query;
    return (response as List).map((e) => WeightEntry.fromJson(e)).toList();
  }

  /// Get latest weight entry
  static Future<WeightEntry?> getLatestWeightEntry(String userId) async {
    final entries = await getWeightEntries(userId, limit: 1);
    return entries.isNotEmpty ? entries.first : null;
  }

  /// Update weight entry
  static Future<void> updateWeightEntry(WeightEntry entry) async {
    await SupabaseConfig.client
        .from('weight_entries')
        .update(entry.toJson())
        .eq('id', entry.id);
  }

  /// Delete weight entry
  static Future<void> deleteWeightEntry(String entryId) async {
    await SupabaseConfig.client
        .from('weight_entries')
        .delete()
        .eq('id', entryId);
  }

  /// Get weight statistics
  static Future<WeightStats> getWeightStats(String userId) async {
    final entries = await getWeightEntries(userId);
    return WeightStats.fromEntries(entries);
  }

  /// Get weight entries for date range (for charts)
  static Future<List<WeightEntry>> getWeightEntriesForPeriod(
    String userId,
    Duration period,
  ) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(period);

    return getWeightEntries(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // ========== Weight Goals ==========

  /// Create weight goal
  static Future<WeightGoal> createWeightGoal({
    required String userId,
    required double startWeight,
    required double targetWeight,
    DateTime? startDate,
    DateTime? targetDate,
    required String goalType,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    // Deactivate existing active goal
    await _deactivateActiveGoal(userId);

    final goal = WeightGoal(
      id: id,
      userId: userId,
      startWeight: startWeight,
      targetWeight: targetWeight,
      currentWeight: startWeight,
      startDate: startDate ?? now,
      targetDate: targetDate,
      goalType: goalType,
      isActive: true,
      createdAt: now,
    );

    await SupabaseConfig.client.from('weight_goals').insert(goal.toJson());

    return goal;
  }

  /// Get active weight goal
  static Future<WeightGoal?> getActiveWeightGoal(String userId) async {
    final response = await SupabaseConfig.client
        .from('weight_goals')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return WeightGoal.fromJson(response);
  }

  /// Get all weight goals
  static Future<List<WeightGoal>> getWeightGoals(String userId) async {
    final response = await SupabaseConfig.client
        .from('weight_goals')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => WeightGoal.fromJson(e)).toList();
  }

  /// Update weight goal
  static Future<void> updateWeightGoal(WeightGoal goal) async {
    await SupabaseConfig.client
        .from('weight_goals')
        .update(goal.toJson())
        .eq('id', goal.id);
  }

  /// Deactivate weight goal
  static Future<void> deactivateWeightGoal(String goalId) async {
    await SupabaseConfig.client.from('weight_goals').update({
      'is_active': false,
    }).eq('id', goalId);
  }

  /// Delete weight goal
  static Future<void> deleteWeightGoal(String goalId) async {
    await SupabaseConfig.client
        .from('weight_goals')
        .delete()
        .eq('id', goalId);
  }

  // ========== Helper Methods ==========

  /// Deactivate all active goals for user
  static Future<void> _deactivateActiveGoal(String userId) async {
    await SupabaseConfig.client.from('weight_goals').update({
      'is_active': false,
    }).eq('user_id', userId).eq('is_active', true);
  }

  /// Update current weight in active goal
  static Future<void> _updateGoalCurrentWeight(String userId, double weight) async {
    final activeGoal = await getActiveWeightGoal(userId);
    if (activeGoal != null) {
      await SupabaseConfig.client.from('weight_goals').update({
        'current_weight': weight,
      }).eq('id', activeGoal.id);
    }
  }

  /// Calculate BMI
  static double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Zayıf';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Fazla Kilolu';
    return 'Obez';
  }

  /// Calculate ideal weight range (based on BMI 18.5-25)
  static Map<String, double> getIdealWeightRange(double heightCm) {
    final heightM = heightCm / 100;
    return {
      'min': 18.5 * heightM * heightM,
      'max': 25 * heightM * heightM,
    };
  }

  /// Predict weight loss timeline
  static DateTime? predictGoalDate({
    required double currentWeight,
    required double targetWeight,
    required double weeklyChangeKg,
  }) {
    if (weeklyChangeKg == 0) return null;

    final totalChange = (targetWeight - currentWeight).abs();
    final weeks = totalChange / weeklyChangeKg.abs();

    return DateTime.now().add(Duration(days: (weeks * 7).ceil()));
  }

  /// Check if weight change is healthy (0.5-1 kg per week)
  static bool isHealthyWeightChange(double weeklyChangeKg) {
    final abs = weeklyChangeKg.abs();
    return abs >= 0.5 && abs <= 1.0;
  }

  /// Get weight change trend (last 30 days)
  static Future<String> getWeightTrend(String userId) async {
    final entries = await getWeightEntriesForPeriod(
      userId,
      const Duration(days: 30),
    );

    if (entries.length < 2) return 'Yetersiz Veri';

    final sortedEntries = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

    final firstWeight = sortedEntries.first.weight;
    final lastWeight = sortedEntries.last.weight;
    final change = lastWeight - firstWeight;

    if (change.abs() < 0.5) return 'Stabil';
    if (change > 0) return 'Artış';
    return 'Azalış';
  }

  /// Calculate average weight for period
  static Future<double?> getAverageWeight(
    String userId,
    Duration period,
  ) async {
    final entries = await getWeightEntriesForPeriod(userId, period);

    if (entries.isEmpty) return null;

    final total = entries.fold(0.0, (sum, entry) => sum + entry.weight);
    return total / entries.length;
  }

  /// Get weight progress data for charts (weekly averages)
  static Future<Map<DateTime, double>> getWeeklyAverages(
    String userId, {
    int weeks = 12,
  }) async {
    final entries = await getWeightEntriesForPeriod(
      userId,
      Duration(days: weeks * 7),
    );

    if (entries.isEmpty) return {};

    // Group by week
    final weeklyData = <DateTime, List<double>>{};

    for (final entry in entries) {
      final weekStart = _getWeekStart(entry.loggedAt);

      if (!weeklyData.containsKey(weekStart)) {
        weeklyData[weekStart] = [];
      }

      weeklyData[weekStart]!.add(entry.weight);
    }

    // Calculate averages
    final averages = <DateTime, double>{};
    weeklyData.forEach((date, weights) {
      final avg = weights.reduce((a, b) => a + b) / weights.length;
      averages[date] = avg;
    });

    return averages;
  }

  /// Get start of week (Monday)
  static DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday;
    final daysToSubtract = dayOfWeek - 1;
    final weekStart = date.subtract(Duration(days: daysToSubtract));
    return DateTime(weekStart.year, weekStart.month, weekStart.day);
  }

  /// Export weight data as CSV
  static Future<String> exportWeightDataCSV(String userId) async {
    final entries = await getWeightEntries(userId);

    final csv = StringBuffer();
    csv.writeln('Tarih,Kilo (kg),Notlar');

    for (final entry in entries.reversed) {
      csv.writeln(
        '${entry.loggedAt.toIso8601String()},${entry.weight},${entry.notes ?? ""}',
      );
    }

    return csv.toString();
  }
}
