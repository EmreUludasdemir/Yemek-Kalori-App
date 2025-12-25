import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_theme.dart';
import '../../../services/recent_searches_service.dart';
import '../../../data/models/food_item_model.dart';
import '../../../config/supabase_config.dart';

/// Quick add section for recent, favorites, and frequent foods
class QuickAddSection extends ConsumerStatefulWidget {
  final Function(FoodItem) onFoodSelected;

  const QuickAddSection({
    super.key,
    required this.onFoodSelected,
  });

  @override
  ConsumerState<QuickAddSection> createState() => _QuickAddSectionState();
}

class _QuickAddSectionState extends ConsumerState<QuickAddSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Son Kullanılan'),
            Tab(text: 'Favoriler'),
            Tab(text: 'Sık Kullanılan'),
          ],
        ),
        SizedBox(
          height: 200,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFrequentFoods(),
              _buildFavorites(),
              _buildFrequentFoods(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequentFoods() {
    return FutureBuilder<List<FrequentFood>>(
      future: FrequentFoodsService.getFrequentFoods(limit: 5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Henüz veri yok',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final frequentFood = snapshot.data![index];
            return _QuickAddItem(
              foodName: frequentFood.foodName,
              subtitle: '${frequentFood.count}x kullanıldı',
              icon: Icons.restaurant,
              onTap: () {
                // Load full food data and select
                _loadAndSelectFood(frequentFood.foodId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFavorites() {
    return FutureBuilder<List<String>>(
      future: FavoriteFoodsService.getFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 48,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Henüz favori yok',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Yıldız ikonuna tıklayarak favori ekle',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final foodId = snapshot.data![index];
            return FutureBuilder<FoodItem?>(
              future: _loadFoodById(foodId),
              builder: (context, foodSnapshot) {
                if (!foodSnapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final food = foodSnapshot.data!;
                return _QuickAddItem(
                  foodName: food.name,
                  subtitle: '${food.calories.toInt()} kcal',
                  icon: Icons.favorite,
                  iconColor: AppColors.accent,
                  onTap: () => widget.onFoodSelected(food),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<FoodItem?> _loadFoodById(String foodId) async {
    try {
      final response = await SupabaseConfig.client
          .from('foods')
          .select()
          .eq('id', foodId)
          .maybeSingle();

      if (response == null) return null;
      return FoodItem.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadAndSelectFood(String foodId) async {
    final food = await _loadFoodById(foodId);
    if (food != null) {
      widget.onFoodSelected(food);
    }
  }
}

class _QuickAddItem extends StatelessWidget {
  final String foodName;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _QuickAddItem({
    required this.foodName,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodName,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent searches widget
class RecentSearchesWidget extends ConsumerWidget {
  final Function(String) onSearchSelected;

  const RecentSearchesWidget({
    super.key,
    required this.onSearchSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<String>>(
      future: RecentSearchesService.getRecentSearches(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Son Aramalar',
                    style: AppTheme.h4.copyWith(color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () async {
                      await RecentSearchesService.clearAll();
                      // Refresh
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Temizle'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final search = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(search),
                      avatar: const Icon(Icons.history, size: 16),
                      onPressed: () => onSearchSelected(search),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () async {
                        await RecentSearchesService.removeSearch(search);
                        (context as Element).markNeedsBuild();
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
