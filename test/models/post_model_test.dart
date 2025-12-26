import 'package:flutter_test/flutter_test.dart';
import 'package:turk_kalori/data/models/post_model.dart';

void main() {
  group('Post Model Tests', () {
    test('fromJson should create Post from valid JSON', () {
      // Arrange
      final json = {
        'id': 'post123',
        'user_id': 'user123',
        'content': 'Test post content',
        'image_url': 'https://example.com/image.jpg',
        'likes_count': 5,
        'comments_count': 3,
        'is_public': true,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final post = Post.fromJson(json);

      // Assert
      expect(post.id, 'post123');
      expect(post.userId, 'user123');
      expect(post.content, 'Test post content');
      expect(post.imageUrl, 'https://example.com/image.jpg');
      expect(post.likesCount, 5);
      expect(post.commentsCount, 3);
      expect(post.isPublic, true);
    });

    test('toJson should convert Post to JSON', () {
      // Arrange
      final post = Post(
        id: 'post123',
        userId: 'user123',
        content: 'Test post content',
        imageUrl: 'https://example.com/image.jpg',
        likesCount: 5,
        commentsCount: 3,
        isPublic: true,
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      // Act
      final json = post.toJson();

      // Assert
      expect(json['id'], 'post123');
      expect(json['user_id'], 'user123');
      expect(json['content'], 'Test post content');
      expect(json['image_url'], 'https://example.com/image.jpg');
    });

    test('copyWith should create new instance with updated fields', () {
      // Arrange
      final post = Post(
        id: 'post123',
        userId: 'user123',
        content: 'Original content',
        likesCount: 5,
        commentsCount: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final updatedPost = post.copyWith(
        content: 'Updated content',
        likesCount: 10,
      );

      // Assert
      expect(updatedPost.id, post.id);
      expect(updatedPost.content, 'Updated content');
      expect(updatedPost.likesCount, 10);
      expect(updatedPost.commentsCount, 3);
    });
  });

  group('Comment Model Tests', () {
    test('fromJson should create Comment from valid JSON', () {
      // Arrange
      final json = {
        'id': 'comment123',
        'user_id': 'user123',
        'post_id': 'post123',
        'content': 'Test comment',
        'likes_count': 2,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final comment = Comment.fromJson(json);

      // Assert
      expect(comment.id, 'comment123');
      expect(comment.userId, 'user123');
      expect(comment.postId, 'post123');
      expect(comment.content, 'Test comment');
      expect(comment.likesCount, 2);
    });

    test('toJson should convert Comment to JSON', () {
      // Arrange
      final comment = Comment(
        id: 'comment123',
        userId: 'user123',
        postId: 'post123',
        content: 'Test comment',
        likesCount: 2,
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      // Act
      final json = comment.toJson();

      // Assert
      expect(json['id'], 'comment123');
      expect(json['user_id'], 'user123');
      expect(json['post_id'], 'post123');
      expect(json['content'], 'Test comment');
    });
  });
}
