import 'dart:collection';

/// In-memory cache service with LRU eviction policy
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Cache storage with expiration
  final Map<String, _CacheEntry> _cache = {};

  // LRU tracking
  final LinkedHashMap<String, DateTime> _lruTracker = LinkedHashMap();

  // Maximum cache size (number of entries)
  int maxSize = 100;

  // Default TTL (Time To Live) in seconds
  int defaultTTL = 300; // 5 minutes

  /// Get value from cache
  T? get<T>(String key) {
    final entry = _cache[key];

    if (entry == null) return null;

    // Check if expired
    if (entry.isExpired()) {
      _cache.remove(key);
      _lruTracker.remove(key);
      return null;
    }

    // Update LRU tracker
    _lruTracker.remove(key);
    _lruTracker[key] = DateTime.now();

    return entry.value as T?;
  }

  /// Set value in cache
  void set<T>(String key, T value, {int? ttlSeconds}) {
    // Evict oldest if cache is full
    if (_cache.length >= maxSize && !_cache.containsKey(key)) {
      _evictOldest();
    }

    final ttl = ttlSeconds ?? defaultTTL;
    final expiration = DateTime.now().add(Duration(seconds: ttl));

    _cache[key] = _CacheEntry(value, expiration);
    _lruTracker.remove(key);
    _lruTracker[key] = DateTime.now();
  }

  /// Remove value from cache
  void remove(String key) {
    _cache.remove(key);
    _lruTracker.remove(key);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
    _lruTracker.clear();
  }

  /// Clear expired entries
  void clearExpired() {
    final keysToRemove = <String>[];

    _cache.forEach((key, entry) {
      if (entry.isExpired()) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _cache.remove(key);
      _lruTracker.remove(key);
    }
  }

  /// Check if key exists and is not expired
  bool contains(String key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (entry.isExpired()) {
      _cache.remove(key);
      _lruTracker.remove(key);
      return false;
    }

    return true;
  }

  /// Get cache size
  int get size => _cache.length;

  /// Evict oldest entry (LRU)
  void _evictOldest() {
    if (_lruTracker.isEmpty) return;

    final oldestKey = _lruTracker.keys.first;
    _cache.remove(oldestKey);
    _lruTracker.remove(oldestKey);
  }

  /// Get or set pattern
  Future<T> getOrSet<T>({
    required String key,
    required Future<T> Function() fetcher,
    int? ttlSeconds,
  }) async {
    // Try to get from cache
    final cached = get<T>(key);
    if (cached != null) return cached;

    // Fetch and cache
    final value = await fetcher();
    set(key, value, ttlSeconds: ttlSeconds);
    return value;
  }

  /// Invalidate keys matching pattern
  void invalidatePattern(String pattern) {
    final keysToRemove = _cache.keys
        .where((key) => key.contains(pattern))
        .toList();

    for (final key in keysToRemove) {
      _cache.remove(key);
      _lruTracker.remove(key);
    }
  }

  /// Get cache stats
  Map<String, dynamic> getStats() {
    return {
      'size': _cache.length,
      'max_size': maxSize,
      'oldest_entry': _lruTracker.isNotEmpty
          ? _lruTracker.values.first.toString()
          : null,
      'newest_entry': _lruTracker.isNotEmpty
          ? _lruTracker.values.last.toString()
          : null,
    };
  }
}

/// Cache entry with expiration
class _CacheEntry<T> {
  final T value;
  final DateTime expiration;

  _CacheEntry(this.value, this.expiration);

  bool isExpired() => DateTime.now().isAfter(expiration);
}
