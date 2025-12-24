import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/post_model.dart';
import '../../widgets/social/post_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more posts (pagination)
      // ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.explore),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: AppStrings.following),
            Tab(text: AppStrings.popular),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowingFeed(),
          _buildPopularFeed(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create post
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFollowingFeed() {
    // TODO: Replace with actual data from Supabase
    final mockPosts = _getMockPosts();

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh feed
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: mockPosts.length,
        itemBuilder: (context, index) {
          return PostCard(post: mockPosts[index]);
        },
      ),
    );
  }

  Widget _buildPopularFeed() {
    final mockPosts = _getMockPosts();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: mockPosts.length,
        itemBuilder: (context, index) {
          return PostCard(post: mockPosts[index]);
        },
      ),
    );
  }

  // Mock data for development
  List<Post> _getMockPosts() {
    return [
      Post(
        id: '1',
        userId: 'user1',
        content: 'Bugünkü öğle yemeğim 🥗\nTavuklu Salata - 320 kcal',
        imageUrl: 'https://picsum.photos/seed/food1/400/300',
        likesCount: 24,
        commentsCount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        user: const UserProfile(
          id: 'user1',
          username: 'ayse_y',
          fullName: 'Ayşe Yılmaz',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
          createdAt: '2024-01-01T00:00:00.000Z',
        ),
        isLikedByCurrentUser: false,
      ),
      Post(
        id: '2',
        userId: 'user2',
        content: 'Ev yapımı köfte 😋\nIzgara Köfte - 450 kcal\n\nMalzemeler:\n• Dana kıyma 150g\n• Soğan, maydanoz...',
        imageUrl: 'https://picsum.photos/seed/food2/400/300',
        likesCount: 42,
        commentsCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        user: const UserProfile(
          id: 'user2',
          username: 'mehmet_k',
          fullName: 'Mehmet Kaya',
          avatarUrl: 'https://i.pravatar.cc/150?img=12',
          createdAt: '2024-01-01T00:00:00.000Z',
        ),
        isLikedByCurrentUser: true,
      ),
      Post(
        id: '3',
        userId: 'user3',
        content: 'Kahvaltı keyfi ☕\nMenemen + Simit = 530 kcal',
        imageUrl: 'https://picsum.photos/seed/food3/400/300',
        likesCount: 18,
        commentsCount: 3,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
        user: const UserProfile(
          id: 'user3',
          username: 'zeynep_a',
          fullName: 'Zeynep Arslan',
          avatarUrl: 'https://i.pravatar.cc/150?img=5',
          createdAt: '2024-01-01T00:00:00.000Z',
        ),
        isLikedByCurrentUser: false,
      ),
      Post(
        id: '4',
        userId: 'user4',
        content: '30 günlük seri kırdım! 🔥\nBugün de hedefimin altındayım 💪',
        imageUrl: null,
        likesCount: 56,
        commentsCount: 20,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        user: const UserProfile(
          id: 'user4',
          username: 'can_demir',
          fullName: 'Can Demir',
          avatarUrl: 'https://i.pravatar.cc/150?img=15',
          streakDays: 30,
          createdAt: '2024-01-01T00:00:00.000Z',
        ),
        isLikedByCurrentUser: true,
      ),
    ];
  }
}
