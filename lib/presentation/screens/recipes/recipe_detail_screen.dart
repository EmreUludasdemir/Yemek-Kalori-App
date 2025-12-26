import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/recipe_model.dart';
import '../../../services/recipe_service.dart';
import '../../../config/supabase_config.dart';
import 'cooking_mode_screen.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSaved = false;
  bool _isLoading = false;
  final Set<int> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkIfSaved();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkIfSaved() async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return;

    final saved = await RecipeService.isRecipeSaved(
      userId: userId,
      recipeId: widget.recipe.id,
    );

    if (mounted) {
      setState(() => _isSaved = saved);
    }
  }

  Future<void> _toggleSave() async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oturum açmanız gerekiyor')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = _isSaved
        ? await RecipeService.unsaveRecipe(userId: userId, recipeId: widget.recipe.id)
        : await RecipeService.saveRecipe(userId: userId, recipeId: widget.recipe.id);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (success) _isSaved = !_isSaved;
      });
    }
  }

  void _startCookingMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CookingModeScreen(recipe: widget.recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.recipe.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              background: widget.recipe.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.recipe.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.restaurant, size: 64),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant, size: 64),
                    ),
            ),
            actions: [
              if (widget.recipe.isPremium)
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white,
                      ),
                onPressed: _toggleSave,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description & Stats
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),

                      // Stats Row
                      Row(
                        children: [
                          _StatCard(
                            icon: Icons.schedule,
                            label: 'Toplam',
                            value: '${widget.recipe.totalTimeMinutes} dk',
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.restaurant,
                            label: 'Porsiyon',
                            value: '${widget.recipe.servings}',
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.local_fire_department,
                            label: 'Kalori',
                            value:
                                '${widget.recipe.nutritionInfo.caloriesPerServing.toInt()}',
                            color: AppColors.error,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Difficulty & Category
                      Row(
                        children: [
                          _Chip(
                            label: widget.recipe.difficulty,
                            color: _getDifficultyColor(widget.recipe.difficulty),
                          ),
                          const SizedBox(width: 8),
                          _Chip(
                            label: widget.recipe.category,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),

                      // Tags
                      if (widget.recipe.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.recipe.tags
                              .map((tag) => _Chip(
                                    label: tag,
                                    color: AppColors.primary.withOpacity(0.7),
                                    small: true,
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                const Divider(),

                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Malzemeler'),
                    Tab(text: 'Talimatlar'),
                    Tab(text: 'Besin Değerleri'),
                  ],
                ),
              ],
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIngredientsTab(),
                _buildInstructionsTab(),
                _buildNutritionTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startCookingMode,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Pişirmeye Başla'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.recipe.ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = widget.recipe.ingredients[index];
        final isChecked = _checkedIngredients.contains(index);

        return CheckboxListTile(
          value: isChecked,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _checkedIngredients.add(index);
              } else {
                _checkedIngredients.remove(index);
              }
            });
          },
          title: Text(
            ingredient.displayText,
            style: TextStyle(
              decoration: isChecked ? TextDecoration.lineThrough : null,
              color: isChecked ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.success,
        );
      },
    );
  }

  Widget _buildInstructionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.recipe.steps.length,
      itemBuilder: (context, index) {
        final step = widget.recipe.steps[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        '${step.stepNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (step.durationMinutes != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              '${step.durationMinutes} dk',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(step.instruction),
                if (step.tip != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            size: 16, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.tip!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutritionTab() {
    final nutrition = widget.recipe.nutritionInfo;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _NutritionCard(
            label: 'Kalori',
            value: '${nutrition.caloriesPerServing.toInt()} kcal',
            icon: Icons.local_fire_department,
            color: AppColors.error,
          ),
          _NutritionCard(
            label: 'Protein',
            value: '${nutrition.proteinGrams.toStringAsFixed(1)}g',
            icon: Icons.egg,
            color: AppColors.protein,
          ),
          _NutritionCard(
            label: 'Karbonhidrat',
            value: '${nutrition.carbsGrams.toStringAsFixed(1)}g',
            icon: Icons.rice_bowl,
            color: AppColors.carbs,
          ),
          _NutritionCard(
            label: 'Yağ',
            value: '${nutrition.fatGrams.toStringAsFixed(1)}g',
            icon: Icons.water_drop,
            color: AppColors.fat,
          ),
          if (nutrition.fiberGrams > 0)
            _NutritionCard(
              label: 'Lif',
              value: '${nutrition.fiberGrams.toStringAsFixed(1)}g',
              icon: Icons.grass,
              color: AppColors.success,
            ),
          if (nutrition.sugarGrams > 0)
            _NutritionCard(
              label: 'Şeker',
              value: '${nutrition.sugarGrams.toStringAsFixed(1)}g',
              icon: Icons.cake,
              color: AppColors.warning,
            ),
          if (nutrition.sodiumMg > 0)
            _NutritionCard(
              label: 'Sodyum',
              value: '${nutrition.sodiumMg.toStringAsFixed(0)}mg',
              icon: Icons.science,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'kolay':
        return AppColors.success;
      case 'orta':
        return AppColors.warning;
      case 'zor':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const _Chip({
    required this.label,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 12 : 14,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _NutritionCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
