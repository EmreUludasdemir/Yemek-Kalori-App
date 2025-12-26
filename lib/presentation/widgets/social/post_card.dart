import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../data/models/post_model.dart';
import '../../../services/social_service.dart';
import 'comments_bottom_sheet.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLikedByCurrentUser ?? false;
    _likesCount = widget.post.likesCount;
  }

  Future<void> _toggleLike() async {
    // Optimistic update
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likesCount--;
      } else {
        _isLiked = true;
        _likesCount++;
      }
    });

    // Call API
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return;

    final success = await SocialService.togglePostLike(
      userId: userId,
      postId: widget.post.id,
    );

    // Revert on failure
    if (!success) {
      setState(() {
        if (_isLiked) {
          _isLiked = false;
          _likesCount--;
        } else {
          _isLiked = true;
          _likesCount++;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Setup Turkish locale for timeago
    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - User info
          _buildHeader(),

          // Content - Text
          if (widget.post.content != null) _buildContent(),

          // Image
          if (widget.post.imageUrl != null) _buildImage(),

          // Actions - Like, Comment, Share
          _buildActions(),

          // Likes count
          if (_likesCount > 0) _buildLikesCount(),

          const Divider(height: 1, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final user = widget.post.user;
    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: user.avatarUrl != null
                ? CachedNetworkImageProvider(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    user.username[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Username and time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.fullName ?? user.username,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (user.streakDays > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🔥',
                              style: TextStyle(fontSize: 10),
                            ),
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
                Text(
                  timeago.format(
                    widget.post.createdAt,
                    locale: 'tr',
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // More button
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              _showPostOptions(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        widget.post.content!,
        style: const TextStyle(fontSize: 15, height: 1.4),
      ),
    );
  }

  Widget _buildImage() {
    return CachedNetworkImage(
      imageUrl: widget.post.imageUrl!,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: 300,
        color: Colors.grey[200],
        child: const Icon(Icons.error),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          // Like button
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : AppColors.textSecondary,
            ),
            onPressed: _toggleLike,
          ),
          Text(
            _likesCount.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),

          // Comment button
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            color: AppColors.textSecondary,
            onPressed: () {
              CommentsBottomSheet.show(context, widget.post.id);
            },
          ),
          Text(
            widget.post.commentsCount.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),

          // Share button
          IconButton(
            icon: const Icon(Icons.share_outlined),
            color: AppColors.textSecondary,
            onPressed: () {
              // Share post
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLikesCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        '$_likesCount beğeni',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Kaydet'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Bağlantıyı Kopyala'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            if (widget.post.userId == SupabaseConfig.currentUser?.id) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Düzenle'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Sil'),
                onTap: () async {
                  Navigator.pop(context);

                  // Show confirmation dialog
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Gönderiyi Sil'),
                      content: const Text('Bu gönderiyi silmek istediğinizden emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Sil', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final success = await SocialService.deletePost(widget.post.id);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gönderi silindi'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  }
                },
              ),
            ] else
              ListTile(
                leading: const Icon(Icons.report, color: AppColors.error),
                title: const Text('Bildir'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
