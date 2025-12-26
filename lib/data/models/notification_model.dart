import 'package:equatable/equatable.dart';
import 'user_model.dart';

class AppNotification extends Equatable {
  final String id;
  final String userId;
  final String actorId;
  final String type; // 'like', 'comment', 'follow', 'mention', 'achievement'
  final String? targetType; // 'post', 'comment', 'profile'
  final String? targetId;
  final String? message;
  final bool isRead;
  final DateTime createdAt;

  // Relational data
  final UserProfile? actor;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.actorId,
    required this.type,
    this.targetType,
    this.targetId,
    this.message,
    this.isRead = false,
    required this.createdAt,
    this.actor,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      actorId: json['actor_id'] ?? '',
      type: json['type'] ?? '',
      targetType: json['target_type'],
      targetId: json['target_id'],
      message: json['message'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      actor: json['actor'] != null
          ? UserProfile.fromJson(json['actor'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'actor_id': actorId,
      'type': type,
      'target_type': targetType,
      'target_id': targetId,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? actorId,
    String? type,
    String? targetType,
    String? targetId,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    UserProfile? actor,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      actorId: actorId ?? this.actorId,
      type: type ?? this.type,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actor: actor ?? this.actor,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        actorId,
        type,
        targetType,
        targetId,
        message,
        isRead,
        createdAt,
        actor,
      ];
}
