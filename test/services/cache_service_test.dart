import 'package:flutter_test/flutter_test.dart';
import 'package:turk_kalori/services/cache_service.dart';

void main() {
  group('CacheService Tests', () {
    late CacheService cache;

    setUp(() {
      cache = CacheService();
      cache.clear();
    });

    tearDown(() {
      cache.clear();
    });

    test('set and get should store and retrieve values', () {
      // Arrange
      const key = 'test_key';
      const value = 'test_value';

      // Act
      cache.set(key, value);
      final result = cache.get<String>(key);

      // Assert
      expect(result, value);
    });

    test('get should return null for non-existent key', () {
      // Act
      final result = cache.get<String>('non_existent');

      // Assert
      expect(result, null);
    });

    test('remove should delete value', () {
      // Arrange
      const key = 'test_key';
      cache.set(key, 'value');

      // Act
      cache.remove(key);
      final result = cache.get<String>(key);

      // Assert
      expect(result, null);
    });

    test('clear should remove all values', () {
      // Arrange
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');

      // Act
      cache.clear();

      // Assert
      expect(cache.size, 0);
      expect(cache.get<String>('key1'), null);
      expect(cache.get<String>('key2'), null);
    });

    test('contains should return true for existing key', () {
      // Arrange
      const key = 'test_key';
      cache.set(key, 'value');

      // Act & Assert
      expect(cache.contains(key), true);
      expect(cache.contains('non_existent'), false);
    });

    test('size should return correct count', () {
      // Arrange & Act
      expect(cache.size, 0);

      cache.set('key1', 'value1');
      expect(cache.size, 1);

      cache.set('key2', 'value2');
      expect(cache.size, 2);

      cache.remove('key1');
      expect(cache.size, 1);
    });

    test('should evict oldest entry when max size reached', () {
      // Arrange
      cache.maxSize = 3;

      // Act
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      cache.set('key3', 'value3');
      cache.set('key4', 'value4'); // Should evict key1

      // Assert
      expect(cache.size, 3);
      expect(cache.get<String>('key1'), null); // Evicted
      expect(cache.get<String>('key2'), 'value2');
      expect(cache.get<String>('key3'), 'value3');
      expect(cache.get<String>('key4'), 'value4');
    });

    test('invalidatePattern should remove matching keys', () {
      // Arrange
      cache.set('user_123', 'value1');
      cache.set('user_456', 'value2');
      cache.set('post_789', 'value3');

      // Act
      cache.invalidatePattern('user_');

      // Assert
      expect(cache.get<String>('user_123'), null);
      expect(cache.get<String>('user_456'), null);
      expect(cache.get<String>('post_789'), 'value3');
    });

    test('getOrSet should fetch and cache if not exists', () async {
      // Arrange
      const key = 'test_key';
      var fetchCount = 0;

      Future<String> fetcher() async {
        fetchCount++;
        return 'fetched_value';
      }

      // Act
      final result1 = await cache.getOrSet(key: key, fetcher: fetcher);
      final result2 = await cache.getOrSet(key: key, fetcher: fetcher);

      // Assert
      expect(result1, 'fetched_value');
      expect(result2, 'fetched_value');
      expect(fetchCount, 1); // Should only fetch once
    });
  });
}
