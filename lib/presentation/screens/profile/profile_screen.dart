import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../data/models/user_model.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/profile/stats_screen.dart';
import '../auth/login_screen.dart';

// Provider for user profile
final profileProvider = FutureProvider.autoDispose<UserProfile?>((ref) async {
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
    print('Error fetching profile: $e');
    return null;
  }
});

// Provider for user statistics
final userStatsProvider = FutureProvider.autoDispose<UserStats>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return const UserStats();

  try {
    // Get total food logs count and calories
    final logsResponse = await SupabaseConfig.client
        .from('food_logs')
        .select('id, calories')
        .eq('user_id', userId);

    final totalLogs = (logsResponse as List).length;
    final totalCalories = logsResponse.fold<double>(
      0,
      (sum, log) => sum + (log['calories'] as num).toDouble(),
    );

    // Get posts count
    final postsResponse = await SupabaseConfig.client
        .from('posts')
        .select('id')
        .eq('user_id', userId);

    final totalPosts = (postsResponse as List).length;

    // Get followers count
    final followersResponse = await SupabaseConfig.client
        .from('follows')
        .select('id')
        .eq('following_id', userId);

    final followersCount = (followersResponse as List).length;

    // Get following count
    final followingResponse = await SupabaseConfig.client
        .from('follows')
        .select('id')
        .eq('follower_id', userId);

    final followingCount = (followingResponse as List).length;

    return UserStats(
      totalMealsLogged: totalLogs,
      totalCaloriesLogged: totalCalories,
      totalPosts: totalPosts,
      followersCount: followersCount,
      followingCount: followingCount,
    );
  } catch (e) {
    print('Error fetching user stats: $e');
    return const UserStats();
  }
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
          ref.invalidate(userStatsProvider);
        },
        child: profileAsync.when(
          data: (profile) => statsAsync.when(
            data: (stats) => _buildContent(context, ref, profile, stats),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildError(error.toString()),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildError(error.toString()),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserProfile? profile,
    UserStats stats,
  ) {
    if (profile == null) {
      return const Center(child: Text('Profil bulunamadı'));
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header with avatar and basic info
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.accent.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? Text(
                              profile.username[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name and username
                Text(
                  profile.fullName ?? profile.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${profile.username}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                // Streak badge
                if (profile.streakDays > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.warning],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          '${profile.streakDays} Günlük Seri',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '${stats.totalMealsLogged}',
                    'Yemek',
                    Icons.restaurant,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '${(stats.totalCaloriesLogged / 1000).toStringAsFixed(1)}k',
                    'Kalori',
                    Icons.local_fire_department,
                    AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '${stats.totalPosts}',
                    'Gönderi',
                    Icons.photo_camera,
                    AppColors.protein,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Social stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSocialStatCard(
                    '${stats.followersCount}',
                    'Takipçi',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSocialStatCard(
                    '${stats.followingCount}',
                    'Takip',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Daily goals section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Günlük Hedefler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                    child: Column(
                      children: [
                        _buildGoalRow(
                          'Kalori',
                          '${profile.dailyCalorieGoal} kcal',
                          Icons.local_fire_department,
                          AppColors.primary,
                        ),
                        const Divider(height: 24),
                        _buildGoalRow(
                          'Protein',
                          '${profile.dailyProteinGoal}g',
                          Icons.fitness_center,
                          AppColors.protein,
                        ),
                        const Divider(height: 24),
                        _buildGoalRow(
                          'Karbonhidrat',
                          '${profile.dailyCarbsGoal}g',
                          Icons.grain,
                          AppColors.carbs,
                        ),
                        const Divider(height: 24),
                        _buildGoalRow(
                          'Yağ',
                          '${profile.dailyFatGoal}g',
                          Icons.water_drop,
                          AppColors.fat,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(profile: profile),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Profili Düzenle'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('İstatistikler ve Grafikler'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Çıkış Yap'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.error),
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialStatCard(String value, String label) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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
            const Text(
              'Bir hata oluştu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await SupabaseConfig.client.auth.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}

// User statistics model
class UserStats {
  final int totalMealsLogged;
  final double totalCaloriesLogged;
  final int totalPosts;
  final int followersCount;
  final int followingCount;

  const UserStats({
    this.totalMealsLogged = 0,
    this.totalCaloriesLogged = 0,
    this.totalPosts = 0,
    this.followersCount = 0,
    this.followingCount = 0,
  });
}
