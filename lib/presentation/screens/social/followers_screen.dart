import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../data/models/user_model.dart';
import '../../../services/social_service.dart';
import 'user_profile_screen.dart';

// Providers
final followersProvider =
    FutureProvider.autoDispose.family<List<UserProfile>, String>((ref, userId) async {
  return await SocialService.getFollowers(userId: userId);
});

final followingProvider =
    FutureProvider.autoDispose.family<List<UserProfile>, String>((ref, userId) async {
  return await SocialService.getFollowing(userId: userId);
});

class FollowersScreen extends ConsumerStatefulWidget {
  final String userId;
  final String username;
  final int initialTab; // 0 = Followers, 1 = Following

  const FollowersScreen({
    super.key,
    required this.userId,
    required this.username,
    this.initialTab = 0,
  });

  @override
  ConsumerState<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends ConsumerState<FollowersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Takipçiler'),
            Tab(text: 'Takip Edilenler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowersList(),
          _buildFollowingList(),
        ],
      ),
    );
  }

  Widget _buildFollowersList() {
    final followersAsync = ref.watch(followersProvider(widget.userId));

    return followersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline,
            message: 'Henüz takipçi yok',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: users.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _buildUserTile(users[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }

  Widget _buildFollowingList() {
    final followingAsync = ref.watch(followingProvider(widget.userId));

    return followingAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return _buildEmptyState(
            icon: Icons.person_add_outlined,
            message: 'Henüz kimseyi takip etmiyor',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: users.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _buildUserTile(users[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }

  Widget _buildUserTile(UserProfile user) {
    final isOwnProfile = user.id == SupabaseConfig.currentUser?.id;

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: user.avatarUrl != null
            ? CachedNetworkImageProvider(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null
            ? Text(
                user.username[0].toUpperCase(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.fullName ?? user.username,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (user.streakDays > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 2),
                  Text(
                    '${user.streakDays}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        user.bio ?? '@${user.username}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      trailing: isOwnProfile
          ? null
          : _FollowButton(user: user),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(userId: user.id),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// Follow Button Widget
class _FollowButton extends ConsumerStatefulWidget {
  final UserProfile user;

  const _FollowButton({required this.user});

  @override
  ConsumerState<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<_FollowButton> {
  bool _isProcessing = false;

  Future<void> _toggleFollow() async {
    if (_isProcessing) return;

    final currentUserId = SupabaseConfig.currentUser?.id;
    if (currentUserId == null) return;

    setState(() => _isProcessing = true);

    final isFollowing = await SocialService.isFollowing(
      followerId: currentUserId,
      followingId: widget.user.id,
    );

    bool success;
    if (isFollowing) {
      success = await SocialService.unfollowUser(
        followerId: currentUserId,
        followingId: widget.user.id,
      );
    } else {
      success = await SocialService.followUser(
        followerId: currentUserId,
        followingId: widget.user.id,
      );
    }

    if (success && mounted) {
      // Refresh the lists
      ref.invalidate(followersProvider);
      ref.invalidate(followingProvider);
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SocialService.isFollowing(
        followerId: SupabaseConfig.currentUser?.id ?? '',
        followingId: widget.user.id,
      ),
      builder: (context, snapshot) {
        final isFollowing = snapshot.data ?? false;

        return OutlinedButton(
          onPressed: _isProcessing ? null : _toggleFollow,
          style: OutlinedButton.styleFrom(
            backgroundColor:
                isFollowing ? Colors.transparent : AppColors.primary,
            foregroundColor: isFollowing ? AppColors.text : Colors.white,
            side: BorderSide(
              color: isFollowing ? AppColors.textSecondary : AppColors.primary,
            ),
            minimumSize: const Size(90, 32),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  isFollowing ? 'Takiptesin' : 'Takip Et',
                  style: const TextStyle(fontSize: 13),
                ),
        );
      },
    );
  }
}
