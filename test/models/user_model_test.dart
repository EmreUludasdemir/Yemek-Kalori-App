import 'package:flutter_test/flutter_test.dart';
import 'package:turk_kalori/data/models/user_model.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('fromJson should create UserProfile from valid JSON', () {
      // Arrange
      final json = {
        'id': 'user123',
        'username': 'testuser',
        'full_name': 'Test User',
        'bio': 'Test bio',
        'daily_calorie_goal': 2000,
        'is_public': true,
        'followers_count': 10,
        'following_count': 5,
        'posts_count': 3,
        'streak_days': 7,
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final user = UserProfile.fromJson(json);

      // Assert
      expect(user.id, 'user123');
      expect(user.username, 'testuser');
      expect(user.fullName, 'Test User');
      expect(user.bio, 'Test bio');
      expect(user.dailyCalorieGoal, 2000);
      expect(user.isPublic, true);
      expect(user.followersCount, 10);
      expect(user.followingCount, 5);
      expect(user.postsCount, 3);
      expect(user.streakDays, 7);
    });

    test('toJson should convert UserProfile to JSON', () {
      // Arrange
      final user = UserProfile(
        id: 'user123',
        username: 'testuser',
        fullName: 'Test User',
        bio: 'Test bio',
        dailyCalorieGoal: 2000,
        isPublic: true,
        followersCount: 10,
        followingCount: 5,
        postsCount: 3,
        streakDays: 7,
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      // Act
      final json = user.toJson();

      // Assert
      expect(json['id'], 'user123');
      expect(json['username'], 'testuser');
      expect(json['full_name'], 'Test User');
      expect(json['bio'], 'Test bio');
      expect(json['daily_calorie_goal'], 2000);
      expect(json['is_public'], true);
    });

    test('copyWith should create new instance with updated fields', () {
      // Arrange
      final user = UserProfile(
        id: 'user123',
        username: 'testuser',
        createdAt: DateTime.now(),
      );

      // Act
      final updatedUser = user.copyWith(
        username: 'newusername',
        bio: 'New bio',
      );

      // Assert
      expect(updatedUser.id, user.id);
      expect(updatedUser.username, 'newusername');
      expect(updatedUser.bio, 'New bio');
    });

    test('fromJson with missing fields should use defaults', () {
      // Arrange
      final json = {
        'id': 'user123',
        'username': 'testuser',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final user = UserProfile.fromJson(json);

      // Assert
      expect(user.dailyCalorieGoal, 2000);
      expect(user.isPublic, true);
      expect(user.followersCount, 0);
      expect(user.followingCount, 0);
      expect(user.postsCount, 0);
      expect(user.streakDays, 0);
    });
  });
}
