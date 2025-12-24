import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/food_item_model.dart';
import '../../../services/nutrition_service.dart';
import '../../../config/supabase_config.dart';
import 'add_food_screen.dart';
import 'barcode_scanner_screen.dart';

final nutritionServiceProvider = Provider((ref) => NutritionService());

class FoodSearchScreen extends ConsumerStatefulWidget {
  final String mealType;

  const FoodSearchScreen({
    super.key,
    required this.mealType,
  });

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<FoodItem> _searchResults = [];
  List<FoodItem> _recentFoods = [];
  List<FoodItem> _popularFoods = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    final nutritionService = ref.read(nutritionServiceProvider);
    final userId = SupabaseConfig.currentUser?.id;

    try {
      final futures = await Future.wait([
        nutritionService.getPopularTurkishFoods(),
        if (userId != null) nutritionService.getRecentFoods(userId),
      ]);

      setState(() {
        _popularFoods = futures[0];
        if (userId != null && futures.length > 1) {
          _recentFoods = futures[1];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading initial data: $e');
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    final nutritionService = ref.read(nutritionServiceProvider);

    try {
      final results = await nutritionService.searchLocalFoods(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      print('Search error: $e');
    }
  }

  Future<void> _searchByCategory(String category) async {
    setState(() {
      _selectedCategory = category;
      _isSearching = true;
    });

    final nutritionService = ref.read(nutritionServiceProvider);

    try {
      final results = await nutritionService.getFoodsByCategory(category);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      print('Category search error: $e');
    }
  }

  void _clearCategoryFilter() {
    setState(() {
      _selectedCategory = null;
      _searchResults = [];
    });
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yemek Ara'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Ara'),
            Tab(text: 'Barkod'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSearchTab(),
          BarcodeScannerScreen(mealType: widget.mealType),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Yemek ara... (örn: döner, baklava)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _search('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {});
              if (value.length >= 2) {
                _search(value);
              } else if (value.isEmpty) {
                _search('');
              }
            },
          ),
        ),

        // Category filters
        if (_selectedCategory == null && _searchController.text.isEmpty)
          _buildCategoryFilters(),

        // Selected category badge
        if (_selectedCategory != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Chip(
                  label: Text(
                    ref.read(nutritionServiceProvider).getCategoryDisplay(_selectedCategory!),
                  ),
                  onDeleted: _clearCategoryFilter,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    final nutritionService = ref.read(nutritionServiceProvider);
    final categories = nutritionService.getCategories();

    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          return FilterChip(
            label: Text(nutritionService.getCategoryDisplay(category)),
            selected: _selectedCategory == category,
            onSelected: (selected) {
              if (selected) {
                _searchByCategory(category);
              } else {
                _clearCategoryFilter();
              }
            },
            selectedColor: AppColors.primary.withOpacity(0.2),
            labelStyle: TextStyle(
              color: _selectedCategory == category
                  ? AppColors.primary
                  : AppColors.textPrimary,
              fontWeight: _selectedCategory == category
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isNotEmpty || _selectedCategory != null) {
      return _buildSearchResults();
    }

    return _buildDefaultView();
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              'Yemek bulunamadı',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Farklı bir arama deneyin',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildFoodItem(_searchResults[index]);
      },
    );
  }

  Widget _buildDefaultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent foods
          if (_recentFoods.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Son Eklenenler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._ recentFoods.map((food) => _buildFoodItem(food)),
            const SizedBox(height: 24),
          ],

          // Popular Turkish foods
          const Text(
            'Popüler Türk Yemekleri',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._popularFoods.map((food) => _buildFoodItem(food)),
        ],
      ),
    );
  }

  Widget _buildFoodItem(FoodItem food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFoodScreen(
                foodItem: food,
                mealType: widget.mealType,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Food image or icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.divider.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  image: food.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(food.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: food.imageUrl == null
                    ? const Icon(
                        Icons.restaurant,
                        color: AppColors.textSecondary,
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Food info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${food.servingSizeDisplay} • ${food.categoryDisplay}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildNutrientChip(
                          'P: ${food.protein.toStringAsFixed(0)}g',
                          AppColors.protein,
                        ),
                        const SizedBox(width: 4),
                        _buildNutrientChip(
                          'K: ${food.carbohydrates.toStringAsFixed(0)}g',
                          AppColors.carbs,
                        ),
                        const SizedBox(width: 4),
                        _buildNutrientChip(
                          'Y: ${food.fat.toStringAsFixed(0)}g',
                          AppColors.fat,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Calories
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${food.calories.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    'kcal',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
