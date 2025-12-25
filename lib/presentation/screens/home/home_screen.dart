import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../config/supabase_config.dart';
import '../../../data/models/food_log_model.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/food/calorie_progress_ring.dart';
import '../../widgets/food/macro_bar.dart';
import '../../widgets/food/meal_section.dart';
import '../food_log/food_search_screen.dart';

// Provider for daily nutrition data
final dailyNutritionProvider = FutureProvider.autoDispose<DailyNutrition>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return const DailyNutrition();

  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  try {
    final response = await SupabaseConfig.client
        .from('food_logs')
        .select()
        .eq('user_id', userId)
        .gte('logged_at', startOfDay.toIso8601String())
        .lt('logged_at', endOfDay.toIso8601String())
        .order('logged_at', ascending: true);

    final logs = (response as List).map((e) => FoodLog.fromJson(e)).toList();
    return DailyNutrition.fromFoodLogs(logs);
  } catch (e) {
    print('Error fetching daily nutrition: $e');
    return const DailyNutrition();
  }
});

// Provider for user profile
final userProfileProvider = FutureProvider.autoDispose<UserProfile?>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return null;

  try {
    final response = await SupabaseConfig.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  } catch (e) {
    print('Error fetching user profile: $e');
    return null;
  }
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _waterGlasses = 0;

  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
  }

  Future<void> _loadWaterIntake() async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final response = await SupabaseConfig.client
          .from('water_logs')
          .select('glasses')
          .eq('user_id', userId)
          .gte('logged_at', startOfDay.toIso8601String())
          .lt('logged_at', endOfDay.toIso8601String());

      if (response.isNotEmpty) {
        final total = (response as List).fold<int>(
          0,
          (sum, log) => sum + (log['glasses'] as int),
        );
        setState(() => _waterGlasses = total);
      }
    } catch (e) {
      print('Error loading water intake: $e');
    }
  }

  Future<void> _addWaterGlass() async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return;

    try {
      await SupabaseConfig.client.from('water_logs').insert({
        'user_id': userId,
        'glasses': 1,
        'logged_at': DateTime.now().toIso8601String(),
      });

      setState(() => _waterGlasses++);
    } catch (e) {
      print('Error adding water glass: $e');
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(dailyNutritionProvider);
    ref.invalidate(userProfileProvider);
    await _loadWaterIntake();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final dailyNutritionAsync = ref.watch(dailyNutritionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getGreeting()),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: userProfileAsync.when(
          data: (profile) => dailyNutritionAsync.when(
            data: (nutrition) => _buildContent(profile, nutrition),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildError(error.toString()),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildError(error.toString()),
        ),
      ),
    );
  }

  Widget _buildContent(UserProfile? profile, DailyNutrition nutrition) {
    final calorieGoal = profile?.dailyCalorieGoal.toDouble() ?? 2000;
    final proteinGoal = profile?.dailyProteinGoal.toDouble() ?? 50;
    final carbsGoal = profile?.dailyCarbsGoal.toDouble() ?? 250;
    final fatGoal = profile?.dailyFatGoal.toDouble() ?? 65;
    final waterGoal = profile?.dailyWaterGoal ?? 8;

    // Group food logs by meal type
    final foodLogsByMeal = <String, List<FoodLog>>{
      'kahvalti': [],
      'ogle': [],
      'aksam': [],
      'ara_ogun': [],
    };

    for (var log in nutrition.foodLogs) {
      foodLogsByMeal[log.mealType]?.add(log);
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          if (profile != null) ...[
            Text(
              'Merhaba, ${profile.fullName ?? profile.username}! 👋',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Calorie progress ring
          Center(
            child: CalorieProgressRing(
              current: nutrition.totalCalories,
              goal: calorieGoal,
            ),
          ),
          const SizedBox(height: 32),

          // Macros
          const Text(
            'Makro Besinler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          MacroBar(
            label: AppStrings.protein,
            current: nutrition.totalProtein,
            goal: proteinGoal,
            color: AppColors.protein,
          ),
          const SizedBox(height: 12),

          MacroBar(
            label: AppStrings.carbs,
            current: nutrition.totalCarbs,
            goal: carbsGoal,
            color: AppColors.carbs,
          ),
          const SizedBox(height: 12),

          MacroBar(
            label: AppStrings.fat,
            current: nutrition.totalFat,
            goal: fatGoal,
            color: AppColors.fat,
          ),
          const SizedBox(height: 32),

          // Today's meals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.todaysMeals,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (nutrition.mealCount > 0)
                Text(
                  '${nutrition.mealCount} öğün',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Meal sections
          MealSection(
            mealType: 'kahvalti',
            foodLogs: foodLogsByMeal['kahvalti']!,
            onAddFood: () => _addFood('kahvalti'),
          ),

          MealSection(
            mealType: 'ogle',
            foodLogs: foodLogsByMeal['ogle']!,
            onAddFood: () => _addFood('ogle'),
          ),

          MealSection(
            mealType: 'aksam',
            foodLogs: foodLogsByMeal['aksam']!,
            onAddFood: () => _addFood('aksam'),
          ),

          MealSection(
            mealType: 'ara_ogun',
            foodLogs: foodLogsByMeal['ara_ogun']!,
            onAddFood: () => _addFood('ara_ogun'),
          ),

          const SizedBox(height: 16),

          // Water tracker
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.water_drop, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Su Tüketimi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$_waterGlasses / $waterGoal bardak',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Water glasses
                  Wrap(
                    spacing: 8,
                    children: List.generate(
                      waterGoal,
                      (index) => GestureDetector(
                        onTap: index < _waterGlasses ? null : _addWaterGlass,
                        child: Icon(
                          index < _waterGlasses
                              ? Icons.water_drop
                              : Icons.water_drop_outlined,
                          color: index < _waterGlasses
                              ? Colors.blue
                              : AppColors.divider,
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                  if (_waterGlasses < waterGoal) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addWaterGlass,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Bardak Ekle'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Streak info
          if (profile != null && profile.streakDays > 0) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: AppColors.accent.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${profile.streakDays} Günlük Seri!',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Harika gidiyorsun! Devam et 💪',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Bir hata oluştu',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refresh,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın';
    if (hour < 17) return 'İyi Günler';
    if (hour < 21) return 'İyi Akşamlar';
    return 'İyi Geceler';
  }

  void _addFood(String mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodSearchScreen(mealType: mealType),
      ),
    );
  }
}
