import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../services/achievement_service.dart';

// Provider for user achievements
final userAchievementsProvider =
    FutureProvider.autoDispose<List<UserAchievement>>((ref) async {
  final userId = SupabaseConfig.currentUser?.id;
  if (userId == null) return [];

  final service = AchievementService();
  return await service.getUserAchievements(userId);
});

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  AchievementCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(userAchievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarılar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(userAchievementsProvider),
          ),
        ],
      ),
      body: achievementsAsync.when(
        data: (achievements) => _buildContent(achievements),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(error.toString()),
      ),
    );
  }

  Widget _buildContent(List<UserAchievement> achievements) {
    final filtered = _selectedCategory == null
        ? achievements
        : achievements
            .where((a) => a.achievement.category == _selectedCategory)
            .toList();

    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final total = achievements.length;
    final totalPoints =
        achievements.where((a) => a.isUnlocked).fold<int>(0, (sum, a) => sum + a.achievement.points);

    return Column(
      children: [
        // Stats header
        Container(
          padding: const EdgeInsets.all(20),
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
              // Progress ring
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    '$unlocked/$total',
                    'Kilitsiz',
                    Icons.emoji_events,
                    AppColors.warning,
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value: unlocked / total,
                          strokeWidth: 8,
                          backgroundColor: AppColors.divider,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.warning,
                          ),
                        ),
                        Center(
                          child: Text(
                            '${((unlocked / total) * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatCard(
                    '$totalPoints',
                    'Puan',
                    Icons.star,
                    AppColors.accent,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Category filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildCategoryChip('Tümü', null),
              const SizedBox(width: 8),
              _buildCategoryChip('Yemekler', AchievementCategory.meals),
              const SizedBox(width: 8),
              _buildCategoryChip('Seriler', AchievementCategory.streak),
              const SizedBox(width: 8),
              _buildCategoryChip('Sosyal', AchievementCategory.social),
              const SizedBox(width: 8),
              _buildCategoryChip('Beslenme', AchievementCategory.nutrition),
            ],
          ),
        ),

        // Achievements list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Henüz başarı yok',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildAchievementCard(filtered[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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
    );
  }

  Widget _buildCategoryChip(String label, AchievementCategory? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedCategory = selected ? category : null);
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildAchievementCard(UserAchievement userAchievement) {
    final achievement = userAchievement.achievement;
    final isUnlocked = userAchievement.isUnlocked;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUnlocked
              ? achievement.color.withOpacity(0.5)
              : AppColors.divider,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isUnlocked
              ? LinearGradient(
                  colors: [
                    achievement.color.withOpacity(0.1),
                    achievement.color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? achievement.color.withOpacity(0.2)
                      : AppColors.divider.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icon,
                  color: isUnlocked ? achievement.color : AppColors.textSecondary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: achievement.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: achievement.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${achievement.points}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: achievement.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnlocked
                            ? AppColors.textSecondary
                            : AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                    if (isUnlocked && userAchievement.unlockedAt != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: achievement.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kilidi açıldı: ${_formatDate(userAchievement.unlockedAt!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: achievement.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Lock/unlock indicator
              if (!isUnlocked)
                const Icon(
                  Icons.lock,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
            ],
          ),
        ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} hafta önce';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
