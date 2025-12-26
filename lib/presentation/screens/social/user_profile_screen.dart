import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/post_model.dart';
import '../../../services/social_service.dart';
import '../../widgets/social/post_card.dart';
import 'edit_profile_screen.dart';
import 'followers_screen.dart';

// Providers
final userProfileProvider =
    FutureProvider.autoDispose.family<UserProfile?, String>((ref, userId) async {
  return await SocialService.getUserProfile(userId);
});

final userPostsProvider =
    FutureProvider.autoDispose.family<List<Post>, String>((ref, userId) async {
  return await SocialService.getUserPosts(userId: userId);
});

final isFollowingProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, userId) async {
  final currentUserId = SupabaseConfig.currentUser?.id;
  if (currentUserId == null) return false;
  return await SocialService.isFollowing(
    followerId: currentUserId,
    followingId: userId,
  );
});

class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isOwnProfile {
    return widget.userId == SupabaseConfig.currentUser?.id;
  }

  Future<void> _toggleFollow(UserProfile user) async {
    if (_isProcessing) return;

    final currentUserId = SupabaseConfig.currentUser?.id;
    if (currentUserId == null) return;

    setState(() => _isProcessing = true);

    final isFollowing = await ref.read(isFollowingProvider(widget.userId).future);

    bool success;
    if (isFollowing) {
      success = await SocialService.unfollowUser(
        followerId: currentUserId,
        followingId: widget.userId,
      );
    } else {
      success = await SocialService.followUser(
        followerId: currentUserId,
        followingId: widget.userId,
      );
    }

    if (success) {
      ref.invalidate(isFollowingProvider(widget.userId));
      ref.invalidate(userProfileProvider(widget.userId));
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider(widget.userId));

    return Scaffold(
      body: userProfileAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('Kullanıcı bulunamadı'),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                pinned: true,
                expandedHeight: 60,
                title: Text(user.username),
                actions: [
                  if (_isOwnProfile)
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        // Navigate to settings
                      },
                    ),
                ],
              ),

              // Profile Header
              SliverToBoxAdapter(
                child: _buildProfileHeader(user),
              ),

              // Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on), text: 'Gönderiler'),
                      Tab(icon: Icon(Icons.leaderboard), text: 'İstatistikler'),
                    ],
                  ),
                ),
              ),

              // Tab Views
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPostsTab(),
                    _buildStatsTab(user),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hata: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    final isFollowingAsync = ref.watch(isFollowingProvider(widget.userId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar and Stats Row
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundImage: user.avatarUrl != null
                    ? CachedNetworkImageProvider(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(
                        user.username[0].toUpperCase(),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 20),

              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('Gönderi', user.postsCount),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FollowersScreen(
                              userId: widget.userId,
                              username: user.username,
                              initialTab: 0,
                            ),
                          ),
                        );
                      },
                      child: _buildStatColumn('Takipçi', user.followersCount),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FollowersScreen(
                              userId: widget.userId,
                              username: user.username,
                              initialTab: 1,
                            ),
                          ),
                        );
                      },
                      child: _buildStatColumn('Takip', user.followingCount),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Name and Bio
          if (user.fullName != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                user.fullName!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (user.bio != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                user.bio!,
                style: const TextStyle(fontSize: 14),
              ),
            ),

          const SizedBox(height: 12),

          // Streak Badge
          if (user.streakDays > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    '${user.streakDays} Gün Seri',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _isOwnProfile
                    ? ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(user: user),
                            ),
                          ).then((_) {
                            // Refresh profile after editing
                            ref.invalidate(userProfileProvider(widget.userId));
                          });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Profili Düzenle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.text,
                        ),
                      )
                    : isFollowingAsync.when(
                        data: (isFollowing) => ElevatedButton(
                          onPressed: _isProcessing
                              ? null
                              : () => _toggleFollow(user),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? AppColors.surface
                                : AppColors.primary,
                            foregroundColor: isFollowing
                                ? AppColors.text
                                : Colors.white,
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(isFollowing ? 'Takip Ediliyor' : 'Takip Et'),
                        ),
                        loading: () => const SizedBox(
                          height: 40,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (_, __) => const SizedBox(),
                      ),
              ),
              if (!_isOwnProfile) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    // Message user (future feature)
                  },
                  child: const Icon(Icons.message_outlined),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPostsTab() {
    final postsAsync = ref.watch(userPostsProvider(widget.userId));

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined,
                    size: 64, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  _isOwnProfile
                      ? 'Henüz gönderin yok'
                      : 'Henüz gönderi yok',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(post: posts[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Hata: $error')),
    );
  }

  Widget _buildStatsTab(UserProfile user) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          'Hedefler',
          [
            _buildStatRow('Günlük Kalori', '${user.dailyCalorieGoal} kcal'),
            _buildStatRow('Protein', '${user.dailyProteinGoal} g'),
            _buildStatRow('Karbonhidrat', '${user.dailyCarbsGoal} g'),
            _buildStatRow('Yağ', '${user.dailyFatGoal} g'),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'Aktivite',
          [
            _buildStatRow('Toplam Gönderi', user.postsCount.toString()),
            _buildStatRow('Seri Günü', '${user.streakDays} gün'),
            _buildStatRow(
              'Kayıt Tarihi',
              '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// Custom SliverPersistentHeaderDelegate for TabBar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
