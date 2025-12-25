import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../config/supabase_config.dart';
import '../../../data/models/post_model.dart';
import '../../../services/social_service.dart';

// Provider for comments
final commentsProvider =
    FutureProvider.autoDispose.family<List<Comment>, String>((ref, postId) async {
  return await SocialService.getPostComments(postId: postId);
});

class CommentsBottomSheet extends ConsumerStatefulWidget {
  final String postId;

  const CommentsBottomSheet({
    super.key,
    required this.postId,
  });

  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsBottomSheet(postId: postId),
    );
  }

  @override
  ConsumerState<CommentsBottomSheet> createState() =>
      _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  bool _isPosting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return;

    setState(() => _isPosting = true);

    final comment = await SocialService.createComment(
      userId: userId,
      postId: widget.postId,
      content: content,
    );

    setState(() => _isPosting = false);

    if (comment != null) {
      _commentController.clear();
      _commentFocus.unfocus();

      // Refresh comments
      ref.invalidate(commentsProvider(widget.postId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorum eklendi'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorum eklenemedi'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.postId));

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Yorumlar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    commentsAsync.when(
                      data: (comments) => Text(
                        '${comments.length}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Comments List
              Expanded(
                child: commentsAsync.when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz yorum yok',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'İlk yorum yapan sen ol!',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: comments.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 64),
                      itemBuilder: (context, index) {
                        return _buildCommentTile(comments[index]);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Hata: $error'),
                  ),
                ),
              ),

              // Comment Input
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 18,
                        backgroundImage:
                            SupabaseConfig.currentUser?.userMetadata?['avatar_url'] != null
                                ? CachedNetworkImageProvider(
                                    SupabaseConfig.currentUser!
                                        .userMetadata!['avatar_url'],
                                  )
                                : null,
                        child:
                            SupabaseConfig.currentUser?.userMetadata?['avatar_url'] == null
                                ? const Icon(Icons.person, size: 18)
                                : null,
                      ),
                      const SizedBox(width: 12),

                      // Text Field
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          focusNode: _commentFocus,
                          decoration: InputDecoration(
                            hintText: 'Yorum yaz...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _postComment(),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Send Button
                      IconButton(
                        onPressed: _isPosting ? null : _postComment,
                        icon: _isPosting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentTile(Comment comment) {
    final user = comment.user;
    if (user == null) return const SizedBox();

    // Setup Turkish locale for timeago
    timeago.setLocaleMessages('tr', timeago.TrMessages());

    final isOwnComment = user.id == SupabaseConfig.currentUser?.id;

    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage:
            user.avatarUrl != null ? CachedNetworkImageProvider(user.avatarUrl!) : null,
        child: user.avatarUrl == null
            ? Text(
                user.username[0].toUpperCase(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Row(
        children: [
          Text(
            user.fullName ?? user.username,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeago.format(comment.createdAt, locale: 'tr'),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          comment.content,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
      ),
      trailing: isOwnComment
          ? IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {
                _showCommentOptions(comment);
              },
            )
          : null,
    );
  }

  void _showCommentOptions(Comment comment) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Yorumu Sil'),
              onTap: () async {
                Navigator.pop(context);

                final success = await SocialService.deleteComment(comment.id);
                if (success) {
                  ref.invalidate(commentsProvider(widget.postId));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Yorum silindi'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('İptal'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
