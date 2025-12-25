import 'package:equatable/equatable.dart';
import 'user_model.dart';

class Follow extends Equatable {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  // Relational data (populated with joins)
  final UserProfile? follower;
  final UserProfile? following;

  const Follow({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
    this.follower,
    this.following,
  });

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      id: json['id'] ?? '',
      followerId: json['follower_id'] ?? '',
      followingId: json['following_id'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      follower: json['follower'] != null
          ? UserProfile.fromJson(json['follower'])
          : null,
      following: json['following'] != null
          ? UserProfile.fromJson(json['following'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        followerId,
        followingId,
        createdAt,
        follower,
        following,
      ];
}
