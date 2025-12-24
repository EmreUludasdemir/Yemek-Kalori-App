import 'package:equatable/equatable.dart';
import 'user_model.dart';

class Post extends Equatable {
  final String id;
  final String userId;
  final String? foodLogId;
  final String? content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relational data (populated with joins)
  final UserProfile? user;
  final bool? isLikedByCurrentUser;

  const Post({
    required this.id,
    required this.userId,
    this.foodLogId,
    this.content,
    this.imageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isPublic = true,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.isLikedByCurrentUser,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      foodLogId: json['food_log_id'],
      content: json['content'],
      imageUrl: json['image_url'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isPublic: json['is_public'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
      isLikedByCurrentUser: json['is_liked_by_current_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'food_log_id': foodLogId,
      'content': content,
      'image_url': imageUrl,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? foodLogId,
    String? content,
    String? imageUrl,
    int? likesCount,
    int? commentsCount,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? user,
    bool? isLikedByCurrentUser,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodLogId: foodLogId ?? this.foodLogId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        foodLogId,
        content,
        imageUrl,
        likesCount,
        commentsCount,
        isPublic,
        createdAt,
        updatedAt,
        user,
        isLikedByCurrentUser,
      ];
}

class Comment extends Equatable {
  final String id;
  final String userId;
  final String postId;
  final String? parentCommentId;
  final String content;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relational data
  final UserProfile? user;

  const Comment({
    required this.id,
    required this.userId,
    required this.postId,
    this.parentCommentId,
    required this.content,
    this.likesCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      postId: json['post_id'] ?? '',
      parentCommentId: json['parent_comment_id'],
      content: json['content'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'parent_comment_id': parentCommentId,
      'content': content,
      'likes_count': likesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        postId,
        parentCommentId,
        content,
        likesCount,
        createdAt,
        updatedAt,
        user,
      ];
}
