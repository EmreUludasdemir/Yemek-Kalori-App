import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../config/supabase_config.dart';
import 'connectivity_service.dart';

/// Offline sync service for local-first architecture
/// Stores data locally and syncs when online
class OfflineSyncService {
  static late Box _offlineQueue;
  static late Box _localData;
  static bool _isInitialized = false;
  static bool _isSyncing = false;

  // ==================== Initialization ====================

  /// Initialize offline sync
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _offlineQueue = await Hive.openBox('offline_queue');
      _localData = await Hive.openBox('local_data');

      _isInitialized = true;
      print('✅ Offline sync initialized');

      // Auto sync when connection is restored
      ConnectivityService.initialize();
      ConnectivityService.connectivityStream.listen((isConnected) {
        if (isConnected) {
          syncPendingOperations();
        }
      });
    } catch (e) {
      print('❌ Error initializing offline sync: $e');
    }
  }

  // ==================== Queue Operations ====================

  /// Add operation to offline queue
  static Future<void> queueOperation({
    required String type,
    required String table,
    required Map<String, dynamic> data,
    String? id,
  }) async {
    final operation = {
      'id': id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type, // insert, update, delete
      'table': table,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'pending',
    };

    await _offlineQueue.add(operation);
    print('➕ Operation queued: $type on $table');
  }

  /// Get pending operations count
  static int getPendingCount() {
    return _offlineQueue.values
        .where((op) => op['status'] == 'pending')
        .length;
  }

  /// Clear completed operations
  static Future<void> clearCompleted() async {
    final toRemove = <dynamic>[];

    for (var key in _offlineQueue.keys) {
      final op = _offlineQueue.get(key);
      if (op['status'] == 'completed') {
        toRemove.add(key);
      }
    }

    for (var key in toRemove) {
      await _offlineQueue.delete(key);
    }

    print('🗑️ Cleared ${toRemove.length} completed operations');
  }

  // ==================== Sync Operations ====================

  /// Sync pending operations to server
  static Future<void> syncPendingOperations() async {
    if (_isSyncing) {
      print('⏳ Sync already in progress');
      return;
    }

    if (!ConnectivityService.isConnected) {
      print('📵 No internet connection');
      return;
    }

    _isSyncing = true;
    print('🔄 Starting sync...');

    try {
      final operations = _offlineQueue.values
          .where((op) => op['status'] == 'pending')
          .toList();

      print('📦 Syncing ${operations.length} operations');

      for (var i = 0; i < operations.length; i++) {
        final op = operations[i];

        try {
          await _executeOperation(op);

          // Mark as completed
          final key = _offlineQueue.keys.firstWhere(
            (k) => _offlineQueue.get(k)['id'] == op['id'],
          );
          await _offlineQueue.put(key, {...op, 'status': 'completed'});

          print('✅ Synced operation ${i + 1}/${operations.length}');
        } catch (e) {
          print('❌ Failed to sync operation: $e');
          // Mark as failed
          final key = _offlineQueue.keys.firstWhere(
            (k) => _offlineQueue.get(k)['id'] == op['id'],
          );
          await _offlineQueue.put(key, {
            ...op,
            'status': 'failed',
            'error': e.toString(),
          });
        }
      }

      // Clean up completed operations
      await clearCompleted();

      print('✅ Sync completed');
    } catch (e) {
      print('❌ Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Execute a queued operation
  static Future<void> _executeOperation(Map<String, dynamic> op) async {
    final type = op['type'] as String;
    final table = op['table'] as String;
    final data = op['data'] as Map<String, dynamic>;

    switch (type) {
      case 'insert':
        await SupabaseConfig.client.from(table).insert(data);
        break;
      case 'update':
        final id = data.remove('id');
        await SupabaseConfig.client.from(table).update(data).eq('id', id);
        break;
      case 'delete':
        await SupabaseConfig.client.from(table).delete().eq('id', data['id']);
        break;
    }
  }

  // ==================== Local Data Management ====================

  /// Save data to local storage
  static Future<void> saveLocal({
    required String key,
    required dynamic data,
  }) async {
    await _localData.put(key, data);
  }

  /// Get data from local storage
  static dynamic getLocal(String key) {
    return _localData.get(key);
  }

  /// Delete local data
  static Future<void> deleteLocal(String key) async {
    await _localData.delete(key);
  }

  /// Check if data exists locally
  static bool hasLocal(String key) {
    return _localData.containsKey(key);
  }

  // ==================== Cached Queries ====================

  /// Cache query result
  static Future<void> cacheQuery({
    required String queryKey,
    required List<Map<String, dynamic>> data,
    int ttlMinutes = 60,
  }) async {
    final cachedData = {
      'data': data,
      'cachedAt': DateTime.now().toIso8601String(),
      'ttlMinutes': ttlMinutes,
    };

    await saveLocal(key: 'query_$queryKey', data: cachedData);
  }

  /// Get cached query result
  static List<Map<String, dynamic>>? getCachedQuery(String queryKey) {
    final cached = getLocal('query_$queryKey');
    if (cached == null) return null;

    final cachedAt = DateTime.parse(cached['cachedAt'] as String);
    final ttl = cached['ttlMinutes'] as int;

    // Check if expired
    if (DateTime.now().difference(cachedAt).inMinutes > ttl) {
      deleteLocal('query_$queryKey');
      return null;
    }

    return (cached['data'] as List).cast<Map<String, dynamic>>();
  }

  /// Invalidate cached query
  static Future<void> invalidateQuery(String queryKey) async {
    await deleteLocal('query_$queryKey');
  }

  // ==================== Food Logs (Example) ====================

  /// Queue food log for offline sync
  static Future<void> queueFoodLog(Map<String, dynamic> foodLog) async {
    await queueOperation(
      type: 'insert',
      table: 'food_logs',
      data: foodLog,
    );

    // Also save locally for immediate display
    final localLogs = getLocal('offline_food_logs') ?? [];
    localLogs.add(foodLog);
    await saveLocal(key: 'offline_food_logs', data: localLogs);
  }

  /// Get local food logs
  static List<Map<String, dynamic>> getLocalFoodLogs() {
    return (getLocal('offline_food_logs') ?? [])
        .cast<Map<String, dynamic>>();
  }

  /// Clear synced food logs
  static Future<void> clearSyncedFoodLogs() async {
    await deleteLocal('offline_food_logs');
  }

  // ==================== Status ====================

  /// Check if sync is in progress
  static bool get isSyncing => _isSyncing;

  /// Get sync status
  static Map<String, dynamic> getSyncStatus() {
    return {
      'pending': getPendingCount(),
      'is_syncing': _isSyncing,
      'is_online': ConnectivityService.isConnected,
      'last_sync': getLocal('last_sync_time'),
    };
  }
}
