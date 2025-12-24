import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final int dailyCalorieGoal;
  final int dailyProteinGoal;
  final int dailyCarbsGoal;
  final int dailyFatGoal;
  final bool isPublic;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final int streakDays;
  final DateTime? lastLogDate;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.dailyCalorieGoal = 2000,
    this.dailyProteinGoal = 50,
    this.dailyCarbsGoal = 250,
    this.dailyFatGoal = 65,
    this.isPublic = true,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.streakDays = 0,
    this.lastLogDate,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      dailyCalorieGoal: json['daily_calorie_goal'] ?? 2000,
      dailyProteinGoal: json['daily_protein_goal'] ?? 50,
      dailyCarbsGoal: json['daily_carbs_goal'] ?? 250,
      dailyFatGoal: json['daily_fat_goal'] ?? 65,
      isPublic: json['is_public'] ?? true,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      streakDays: json['streak_days'] ?? 0,
      lastLogDate: json['last_log_date'] != null
          ? DateTime.parse(json['last_log_date'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'daily_calorie_goal': dailyCalorieGoal,
      'daily_protein_goal': dailyProteinGoal,
      'daily_carbs_goal': dailyCarbsGoal,
      'daily_fat_goal': dailyFatGoal,
      'is_public': isPublic,
      'followers_count': followersCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'streak_days': streakDays,
      'last_log_date': lastLogDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    int? dailyCalorieGoal,
    int? dailyProteinGoal,
    int? dailyCarbsGoal,
    int? dailyFatGoal,
    bool? isPublic,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    int? streakDays,
    DateTime? lastLogDate,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyProteinGoal: dailyProteinGoal ?? this.dailyProteinGoal,
      dailyCarbsGoal: dailyCarbsGoal ?? this.dailyCarbsGoal,
      dailyFatGoal: dailyFatGoal ?? this.dailyFatGoal,
      isPublic: isPublic ?? this.isPublic,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      streakDays: streakDays ?? this.streakDays,
      lastLogDate: lastLogDate ?? this.lastLogDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        fullName,
        avatarUrl,
        bio,
        dailyCalorieGoal,
        dailyProteinGoal,
        dailyCarbsGoal,
        dailyFatGoal,
        isPublic,
        followersCount,
        followingCount,
        postsCount,
        streakDays,
        lastLogDate,
        createdAt,
      ];
}
