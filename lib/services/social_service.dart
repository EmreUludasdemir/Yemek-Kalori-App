import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../data/models/post_model.dart';
import '../data/models/follow_model.dart';
import '../data/models/notification_model.dart';
import '../data/models/user_model.dart';

/// Service for all social features (posts, likes, comments, follows, notifications)
class SocialService {
  static final _supabase = SupabaseConfig.client;

  // ==========================================
  // POSTS
  // ==========================================

  /// Get posts for feed (following + popular)
  /// [feedType]: 'following', 'popular', or 'all'
  /// [limit]: Number of posts to fetch
  /// [offset]: Pagination offset
  static Future<List<Post>> getFeedPosts({
    required String feedType,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      SupabaseQueryBuilder query = _supabase.from('posts').select('''
          *,
          user:profiles!posts_user_id_fkey(
            id, username, full_name, avatar_url, streak_days, created_at
          )
        ''');

      if (feedType == 'following') {
        // Get posts from users that current user follows
        final userId = SupabaseConfig.currentUser?.id;
        if (userId == null) return [];

        final followingIds = await getFollowingIds(userId);
        if (followingIds.isEmpty) return [];

        query = query.in_('user_id', followingIds);
      }

      // Apply filters and ordering
      query = query
          .eq('is_public', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final response = await query;
      final List<dynamic> data = response as List<dynamic>;

      final List<Post> posts = [];
      for (final item in data) {
        final post = Post.fromJson(item);

        // Check if current user liked this post
        final isLiked = await isPostLikedByCurrentUser(post.id);
        posts.add(post.copyWith(isLikedByCurrentUser: isLiked));
      }

      return posts;
    } catch (e) {
      print('Error fetching feed posts: $e');
      return [];
    }
  }

  /// Get posts by a specific user
  static Future<List<Post>> getUserPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            user:profiles!posts_user_id_fkey(
              id, username, full_name, avatar_url, streak_days, created_at
            )
          ''')
          .eq('user_id', userId)
          .eq('is_public', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final List<dynamic> data = response as List<dynamic>;

      final List<Post> posts = [];
      for (final item in data) {
        final post = Post.fromJson(item);
        final isLiked = await isPostLikedByCurrentUser(post.id);
        posts.add(post.copyWith(isLikedByCurrentUser: isLiked));
      }

      return posts;
    } catch (e) {
      print('Error fetching user posts: $e');
      return [];
    }
  }

  /// Get a single post by ID
  static Future<Post?> getPostById(String postId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            user:profiles!posts_user_id_fkey(
              id, username, full_name, avatar_url, streak_days, created_at
            )
          ''')
          .eq('id', postId)
          .single();

      final post = Post.fromJson(response);
      final isLiked = await isPostLikedByCurrentUser(post.id);
      return post.copyWith(isLikedByCurrentUser: isLiked);
    } catch (e) {
      print('Error fetching post: $e');
      return null;
    }
  }

  /// Create a new post
  static Future<Post?> createPost({
    required String userId,
    String? content,
    String? imageUrl,
    String? foodLogId,
    bool isPublic = true,
  }) async {
    try {
      final response = await _supabase.from('posts').insert({
        'user_id': userId,
        'content': content,
        'image_url': imageUrl,
        'food_log_id': foodLogId,
        'is_public': isPublic,
      }).select('''
          *,
          user:profiles!posts_user_id_fkey(
            id, username, full_name, avatar_url, streak_days, created_at
          )
        ''').single();

      return Post.fromJson(response);
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  /// Update a post
  static Future<bool> updatePost({
    required String postId,
    String? content,
    bool? isPublic,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (content != null) updates['content'] = content;
      if (isPublic != null) updates['is_public'] = isPublic;

      await _supabase.from('posts').update(updates).eq('id', postId);
      return true;
    } catch (e) {
      print('Error updating post: $e');
      return false;
    }
  }

  /// Delete a post
  static Future<bool> deletePost(String postId) async {
    try {
      await _supabase.from('posts').delete().eq('id', postId);
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  // ==========================================
  // LIKES
  // ==========================================

  /// Toggle like on a post
  static Future<bool> togglePostLike({
    required String userId,
    required String postId,
  }) async {
    try {
      // Check if already liked
      final existing = await _supabase
          .from('likes')
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();

      if (existing != null) {
        // Unlike
        await _supabase
            .from('likes')
            .delete()
            .eq('user_id', userId)
            .eq('post_id', postId);
        return false;
      } else {
        // Like
        await _supabase.from('likes').insert({
          'user_id': userId,
          'post_id': postId,
        });
        return true;
      }
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  /// Check if current user liked a post
  static Future<bool> isPostLikedByCurrentUser(String postId) async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('likes')
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  /// Get users who liked a post
  static Future<List<UserProfile>> getPostLikes(String postId) async {
    try {
      final response = await _supabase.from('likes').select('''
          user:profiles!likes_user_id_fkey(
            id, username, full_name, avatar_url, streak_days, created_at
          )
        ''').eq('post_id', postId).order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((item) => UserProfile.fromJson(item['user']))
          .toList();
    } catch (e) {
      print('Error fetching post likes: $e');
      return [];
    }
  }

  // ==========================================
  // COMMENTS
  // ==========================================

  /// Get comments for a post
  static Future<List<Comment>> getPostComments({
    required String postId,
    int limit = 50,
  }) async {
    try {
      final response = await _supabase.from('comments').select('''
          *,
          user:profiles!comments_user_id_fkey(
            id, username, full_name, avatar_url, streak_days, created_at
          )
        ''').eq('post_id', postId).order('created_at', ascending: true).limit(limit);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => Comment.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  /// Create a comment
  static Future<Comment?> createComment({
    required String userId,
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final response = await _supabase.from('comments').insert({
        'user_id': userId,
        'post_id': postId,
        'content': content,
        'parent_comment_id': parentCommentId,
      }).select('''
          *,
          user:profiles!comments_user_id_fkey(
            id, username, full_name, avatar_url, streak_days, created_at
          )
        ''').single();

      return Comment.fromJson(response);
    } catch (e) {
      print('Error creating comment: $e');
      return null;
    }
  }

  /// Update a comment
  static Future<bool> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      await _supabase
          .from('comments')
          .update({'content': content})
          .eq('id', commentId);
      return true;
    } catch (e) {
      print('Error updating comment: $e');
      return false;
    }
  }

  /// Delete a comment
  static Future<bool> deleteComment(String commentId) async {
    try {
      await _supabase.from('comments').delete().eq('id', commentId);
      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

  /// Toggle like on a comment
  static Future<bool> toggleCommentLike({
    required String userId,
    required String commentId,
  }) async {
    try {
      final existing = await _supabase
          .from('comment_likes')
          .select()
          .eq('user_id', userId)
          .eq('comment_id', commentId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('comment_likes')
            .delete()
            .eq('user_id', userId)
            .eq('comment_id', commentId);
        return false;
      } else {
        await _supabase.from('comment_likes').insert({
          'user_id': userId,
          'comment_id': commentId,
        });
        return true;
      }
    } catch (e) {
      print('Error toggling comment like: $e');
      return false;
    }
  }

  // ==========================================
  // FOLLOWS
  // ==========================================

  /// Follow a user
  static Future<bool> followUser({
    required String followerId,
    required String followingId,
  }) async {
    try {
      if (followerId == followingId) return false;

      await _supabase.from('follows').insert({
        'follower_id': followerId,
        'following_id': followingId,
      });
      return true;
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }

  /// Unfollow a user
  static Future<bool> unfollowUser({
    required String followerId,
    required String followingId,
  }) async {
    try {
      await _supabase
          .from('follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
      return true;
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }

  /// Check if user is following another user
  static Future<bool> isFollowing({
    required String followerId,
    required String followingId,
  }) async {
    try {
      final response = await _supabase
          .from('follows')
          .select()
          .eq('follower_id', followerId)
          .eq('following_id', followingId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  /// Get followers of a user
  static Future<List<UserProfile>> getFollowers({
    required String userId,
    int limit = 100,
  }) async {
    try {
      final response = await _supabase.from('follows').select('''
          follower:profiles!follows_follower_id_fkey(
            id, username, full_name, avatar_url, followers_count, following_count,
            posts_count, streak_days, is_public, created_at
          )
        ''').eq('following_id', userId).limit(limit);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((item) => UserProfile.fromJson(item['follower']))
          .toList();
    } catch (e) {
      print('Error fetching followers: $e');
      return [];
    }
  }

  /// Get users that a user is following
  static Future<List<UserProfile>> getFollowing({
    required String userId,
    int limit = 100,
  }) async {
    try {
      final response = await _supabase.from('follows').select('''
          following:profiles!follows_following_id_fkey(
            id, username, full_name, avatar_url, followers_count, following_count,
            posts_count, streak_days, is_public, created_at
          )
        ''').eq('follower_id', userId).limit(limit);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((item) => UserProfile.fromJson(item['following']))
          .toList();
    } catch (e) {
      print('Error fetching following: $e');
      return [];
    }
  }

  /// Get following IDs (for feed filtering)
  static Future<List<String>> getFollowingIds(String userId) async {
    try {
      final response = await _supabase
          .from('follows')
          .select('following_id')
          .eq('follower_id', userId);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => item['following_id'] as String).toList();
    } catch (e) {
      print('Error fetching following IDs: $e');
      return [];
    }
  }

  /// Get suggested users to follow
  static Future<List<UserProfile>> getSuggestedUsers({
    required String userId,
    int limit = 10,
  }) async {
    try {
      // Get users with most followers that current user doesn't follow
      final followingIds = await getFollowingIds(userId);

      SupabaseQueryBuilder query = _supabase.from('profiles').select();

      // Exclude current user and already following
      query = query.neq('id', userId);
      if (followingIds.isNotEmpty) {
        query = query.not('id', 'in', '(${followingIds.join(',')})');
      }

      final response = await query
          .eq('is_public', true)
          .order('followers_count', ascending: false)
          .limit(limit);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => UserProfile.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching suggested users: $e');
      return [];
    }
  }

  // ==========================================
  // USER PROFILE
  // ==========================================

  /// Get a user's profile
  static Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', userId).single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<bool> updateUserProfile({
    required String userId,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    bool? isPublic,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (bio != null) updates['bio'] = bio;
      if (isPublic != null) updates['is_public'] = isPublic;

      await _supabase.from('profiles').update(updates).eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  /// Search users by username or name
  static Future<List<UserProfile>> searchUsers({
    required String query,
    int limit = 20,
  }) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .or('username.ilike.%$query%,full_name.ilike.%$query%')
          .eq('is_public', true)
          .limit(limit);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => UserProfile.fromJson(item)).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Get leaderboard (top users by streak, posts, followers)
  /// [leaderboardType]: 'streak', 'posts', or 'followers'
  static Future<List<UserProfile>> getLeaderboard({
    required String leaderboardType,
    int limit = 100,
  }) async {
    try {
      String orderBy;
      switch (leaderboardType) {
        case 'streak':
          orderBy = 'streak_days';
          break;
        case 'posts':
          orderBy = 'posts_count';
          break;
        case 'followers':
          orderBy = 'followers_count';
          break;
        default:
          orderBy = 'streak_days';
      }

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('is_public', true)
          .order(orderBy, ascending: false)
          .limit(limit);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => UserProfile.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }

  // ==========================================
  // NOTIFICATIONS
  // ==========================================

  /// Get user notifications
  static Future<List<AppNotification>> getNotifications({
    required String userId,
    int limit = 50,
    bool unreadOnly = false,
  }) async {
    try {
      SupabaseQueryBuilder query = _supabase.from('notifications').select('''
          *,
          actor:profiles!notifications_actor_id_fkey(
            id, username, full_name, avatar_url, streak_days, created_at
          )
        ''').eq('user_id', userId);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) => AppNotification.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('user_id', userId)
          .eq('is_read', false);

      return response.count ?? 0;
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  /// Mark notification as read
  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  static Future<bool> markAllNotificationsAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // ==========================================
  // STORAGE - Image Upload
  // ==========================================

  /// Upload post image to Supabase Storage
  static Future<String?> uploadPostImage({
    required String userId,
    required String filePath,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId\_$timestamp.jpg';

      await _supabase.storage.from('post_images').upload(fileName, filePath);

      final publicUrl =
          _supabase.storage.from('post_images').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading post image: $e');
      return null;
    }
  }

  /// Upload avatar image to Supabase Storage
  static Future<String?> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId\_$timestamp.jpg';

      await _supabase.storage.from('avatars').upload(fileName, filePath);

      final publicUrl =
          _supabase.storage.from('avatars').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }
}
