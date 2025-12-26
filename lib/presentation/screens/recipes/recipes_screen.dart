import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/recipe_model.dart';
import '../../../services/recipe_service.dart';
import '../../../config/supabase_config.dart';
import 'recipe_detail_screen.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  String? _selectedCategory;
  String? _selectedDifficulty;
  String _searchQuery = '';
  bool _showOnlySaved = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Recipe>> _fetchRecipes() async {
    final userId = SupabaseConfig.currentUser?.id;

    if (_showOnlySaved && userId != null) {
      return RecipeService.getSavedRecipes(userId);
    }

    if (_searchQuery.isNotEmpty) {
      return RecipeService.searchRecipes(_searchQuery);
    }

    return RecipeService.fetchRecipes(
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarifler'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tarif ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),

              // Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Saved Recipes Toggle
                    FilterChip(
                      label: const Text('Kaydedilenler'),
                      selected: _showOnlySaved,
                      onSelected: (value) {
                        setState(() => _showOnlySaved = value);
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                    ),

                    const SizedBox(width: 8),

                    // Category Filter
                    DropdownButton<String?>(
                      value: _selectedCategory,
                      hint: const Text('Kategori'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Tümü')),
                        ...RecipeService.getCategories().map(
                          (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      underline: const SizedBox(),
                    ),

                    const SizedBox(width: 8),

                    // Difficulty Filter
                    DropdownButton<String?>(
                      value: _selectedDifficulty,
                      hint: const Text('Zorluk'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Tümü')),
                        ...RecipeService.getDifficultyLevels().map(
                          (diff) => DropdownMenuItem(value: diff, child: Text(diff)),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedDifficulty = value);
                      },
                      underline: const SizedBox(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _fetchRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Hata: ${snapshot.error}'),
                ],
              ),
            );
          }

          final recipes = snapshot.data ?? [];

          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showOnlySaved ? Icons.bookmark_border : Icons.receipt_long,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showOnlySaved
                        ? 'Henüz kayıtlı tarifiniz yok'
                        : 'Tarif bulunamadı',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return _RecipeCard(recipe: recipe);
            },
          );
        },
      ),
    );
  }
}

class _RecipeCard extends ConsumerStatefulWidget {
  final Recipe recipe;

  const _RecipeCard({required this.recipe});

  @override
  ConsumerState<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends ConsumerState<_RecipeCard> {
  bool _isSaved = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
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

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSaved ? 'Tarif kaydedildi' : 'Kayıt kaldırıldı'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: widget.recipe),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                widget.recipe.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: widget.recipe.imageUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 48),
                        ),
                      )
                    : Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Icon(Icons.restaurant, size: 48),
                      ),

                // Premium Badge
                if (widget.recipe.isPremium)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Save Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: Icon(
                              _isSaved ? Icons.bookmark : Icons.bookmark_border,
                              size: 18,
                              color: _isSaved ? AppColors.primary : Colors.grey[600],
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: _toggleSave,
                          ),
                  ),
                ),
              ],
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.recipe.totalTimeMinutes} dk',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.local_fire_department,
                            size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.recipe.nutritionInfo.caloriesPerServing.toInt()} kcal',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(widget.recipe.difficulty)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.recipe.difficulty,
                        style: TextStyle(
                          fontSize: 10,
                          color: _getDifficultyColor(widget.recipe.difficulty),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
