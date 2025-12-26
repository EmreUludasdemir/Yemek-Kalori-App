import 'package:firebase_performance/firebase_performance.dart';

/// Firebase Performance Monitoring Service
/// Tracks app performance metrics and custom traces
class PerformanceService {
  static FirebasePerformance get _performance => FirebasePerformance.instance;
  static final Map<String, Trace> _activeTraces = {};

  // ==================== Initialization ====================

  /// Initialize performance monitoring
  static Future<void> initialize() async {
    try {
      await _performance.setPerformanceCollectionEnabled(true);
      print('✅ Firebase Performance initialized');
    } catch (e) {
      print('❌ Error initializing Firebase Performance: $e');
    }
  }

  // ==================== Custom Traces ====================

  /// Start a custom trace
  static Future<void> startTrace(String traceName) async {
    try {
      if (_activeTraces.containsKey(traceName)) {
        print('⚠️ Trace "$traceName" already started');
        return;
      }

      final trace = _performance.newTrace(traceName);
      await trace.start();
      _activeTraces[traceName] = trace;
      print('▶️ Started trace: $traceName');
    } catch (e) {
      print('❌ Error starting trace "$traceName": $e');
    }
  }

  /// Stop a custom trace
  static Future<void> stopTrace(String traceName) async {
    try {
      final trace = _activeTraces.remove(traceName);
      if (trace == null) {
        print('⚠️ Trace "$traceName" not found');
        return;
      }

      await trace.stop();
      print('⏹️ Stopped trace: $traceName');
    } catch (e) {
      print('❌ Error stopping trace "$traceName": $e');
    }
  }

  /// Add metric to active trace
  static Future<void> setTraceMetric(
    String traceName,
    String metricName,
    int value,
  ) async {
    try {
      final trace = _activeTraces[traceName];
      if (trace == null) {
        print('⚠️ Trace "$traceName" not found');
        return;
      }

      trace.setMetric(metricName, value);
      print('📊 Set metric "$metricName" = $value for trace "$traceName"');
    } catch (e) {
      print('❌ Error setting metric for "$traceName": $e');
    }
  }

  /// Increment metric on active trace
  static Future<void> incrementTraceMetric(
    String traceName,
    String metricName,
  ) async {
    try {
      final trace = _activeTraces[traceName];
      if (trace == null) {
        print('⚠️ Trace "$traceName" not found');
        return;
      }

      trace.incrementMetric(metricName, 1);
    } catch (e) {
      print('❌ Error incrementing metric for "$traceName": $e');
    }
  }

  /// Add attribute to active trace
  static Future<void> setTraceAttribute(
    String traceName,
    String attributeName,
    String value,
  ) async {
    try {
      final trace = _activeTraces[traceName];
      if (trace == null) {
        print('⚠️ Trace "$traceName" not found');
        return;
      }

      trace.putAttribute(attributeName, value);
      print('🏷️ Set attribute "$attributeName" = $value for trace "$traceName"');
    } catch (e) {
      print('❌ Error setting attribute for "$traceName": $e');
    }
  }

  // ==================== Convenience Methods ====================

  /// Track a complete operation with automatic start/stop
  static Future<T> trackOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
    Map<String, int>? metrics,
  }) async {
    await startTrace(operationName);

    // Add attributes
    if (attributes != null) {
      for (final entry in attributes.entries) {
        await setTraceAttribute(operationName, entry.key, entry.value);
      }
    }

    // Add metrics
    if (metrics != null) {
      for (final entry in metrics.entries) {
        await setTraceMetric(operationName, entry.key, entry.value);
      }
    }

    try {
      final result = await operation();
      await stopTrace(operationName);
      return result;
    } catch (e) {
      await setTraceAttribute(operationName, 'error', e.toString());
      await stopTrace(operationName);
      rethrow;
    }
  }

  // ==================== Screen Traces ====================

  /// Track screen load time
  static Future<void> startScreenTrace(String screenName) async {
    await startTrace('screen_$screenName');
    await setTraceAttribute('screen_$screenName', 'screen_name', screenName);
  }

  /// Stop screen trace
  static Future<void> stopScreenTrace(String screenName) async {
    await stopTrace('screen_$screenName');
  }

  // ==================== Food Log Traces ====================

  /// Track food log creation
  static Future<void> startFoodLogTrace() async {
    await startTrace('food_log_create');
  }

  /// Stop food log creation trace
  static Future<void> stopFoodLogTrace({bool success = true}) async {
    await setTraceAttribute('food_log_create', 'success', success.toString());
    await stopTrace('food_log_create');
  }

  /// Track barcode scan
  static Future<void> startBarcodeScanTrace() async {
    await startTrace('barcode_scan');
  }

  /// Stop barcode scan trace
  static Future<void> stopBarcodeScanTrace({
    bool found = false,
    String? productName,
  }) async {
    await setTraceAttribute('barcode_scan', 'product_found', found.toString());
    if (productName != null) {
      await setTraceAttribute('barcode_scan', 'product_name', productName);
    }
    await stopTrace('barcode_scan');
  }

  /// Track AI food recognition
  static Future<void> startAIRecognitionTrace() async {
    await startTrace('ai_food_recognition');
  }

  /// Stop AI recognition trace
  static Future<void> stopAIRecognitionTrace({
    required int foodsRecognized,
    double? avgConfidence,
  }) async {
    await setTraceMetric('ai_food_recognition', 'foods_recognized', foodsRecognized);
    if (avgConfidence != null) {
      await setTraceMetric(
        'ai_food_recognition',
        'avg_confidence',
        (avgConfidence * 100).toInt(),
      );
    }
    await stopTrace('ai_food_recognition');
  }

  // ==================== Recipe Traces ====================

  /// Track recipe load
  static Future<void> startRecipeLoadTrace({String? category}) async {
    await startTrace('recipe_load');
    if (category != null) {
      await setTraceAttribute('recipe_load', 'category', category);
    }
  }

  /// Stop recipe load trace
  static Future<void> stopRecipeLoadTrace({required int recipeCount}) async {
    await setTraceMetric('recipe_load', 'recipe_count', recipeCount);
    await stopTrace('recipe_load');
  }

  /// Track cooking session
  static Future<void> startCookingSessionTrace() async {
    await startTrace('cooking_session');
  }

  /// Stop cooking session trace
  static Future<void> stopCookingSessionTrace({
    required int totalSteps,
    required int completedSteps,
    required int durationMinutes,
  }) async {
    await setTraceMetric('cooking_session', 'total_steps', totalSteps);
    await setTraceMetric('cooking_session', 'completed_steps', completedSteps);
    await setTraceMetric('cooking_session', 'duration_minutes', durationMinutes);
    await setTraceAttribute(
      'cooking_session',
      'completion_rate',
      '${((completedSteps / totalSteps) * 100).toInt()}%',
    );
    await stopTrace('cooking_session');
  }

  // ==================== Social Traces ====================

  /// Track feed load
  static Future<void> startFeedLoadTrace({required String feedType}) async {
    await startTrace('feed_load');
    await setTraceAttribute('feed_load', 'feed_type', feedType);
  }

  /// Stop feed load trace
  static Future<void> stopFeedLoadTrace({required int postCount}) async {
    await setTraceMetric('feed_load', 'post_count', postCount);
    await stopTrace('feed_load');
  }

  /// Track post creation
  static Future<void> startPostCreateTrace() async {
    await startTrace('post_create');
  }

  /// Stop post creation trace
  static Future<void> stopPostCreateTrace({
    bool hasImage = false,
    int? imageCount,
  }) async {
    await setTraceAttribute('post_create', 'has_image', hasImage.toString());
    if (imageCount != null) {
      await setTraceMetric('post_create', 'image_count', imageCount);
    }
    await stopTrace('post_create');
  }

  // ==================== Sync Traces ====================

  /// Track offline sync
  static Future<void> startOfflineSyncTrace() async {
    await startTrace('offline_sync');
  }

  /// Stop offline sync trace
  static Future<void> stopOfflineSyncTrace({
    required int operationsSynced,
    required int operationsFailed,
  }) async {
    await setTraceMetric('offline_sync', 'operations_synced', operationsSynced);
    await setTraceMetric('offline_sync', 'operations_failed', operationsFailed);
    await setTraceAttribute(
      'offline_sync',
      'success_rate',
      '${((operationsSynced / (operationsSynced + operationsFailed)) * 100).toInt()}%',
    );
    await stopTrace('offline_sync');
  }

  /// Track health sync
  static Future<void> startHealthSyncTrace() async {
    await startTrace('health_sync');
  }

  /// Stop health sync trace
  static Future<void> stopHealthSyncTrace({
    required int dataPointsSynced,
    required String source,
  }) async {
    await setTraceMetric('health_sync', 'data_points', dataPointsSynced);
    await setTraceAttribute('health_sync', 'source', source);
    await stopTrace('health_sync');
  }

  // ==================== Network Traces ====================

  /// Track API call
  static Future<void> startApiTrace(String endpoint) async {
    await startTrace('api_$endpoint');
    await setTraceAttribute('api_$endpoint', 'endpoint', endpoint);
  }

  /// Stop API call trace
  static Future<void> stopApiTrace(
    String endpoint, {
    required int statusCode,
    int? responseSize,
  }) async {
    await setTraceMetric('api_$endpoint', 'status_code', statusCode);
    if (responseSize != null) {
      await setTraceMetric('api_$endpoint', 'response_size_kb', responseSize);
    }
    await setTraceAttribute(
      'api_$endpoint',
      'success',
      (statusCode >= 200 && statusCode < 300).toString(),
    );
    await stopTrace('api_$endpoint');
  }

  // ==================== Database Traces ====================

  /// Track database query
  static Future<void> startDatabaseTrace(String queryName) async {
    await startTrace('db_$queryName');
    await setTraceAttribute('db_$queryName', 'query_name', queryName);
  }

  /// Stop database query trace
  static Future<void> stopDatabaseTrace(
    String queryName, {
    required int rowCount,
  }) async {
    await setTraceMetric('db_$queryName', 'row_count', rowCount);
    await stopTrace('db_$queryName');
  }

  // ==================== Premium Features ====================

  /// Track subscription purchase flow
  static Future<void> startSubscriptionTrace() async {
    await startTrace('subscription_purchase');
  }

  /// Stop subscription trace
  static Future<void> stopSubscriptionTrace({
    required bool success,
    required String tier,
    required bool isYearly,
  }) async {
    await setTraceAttribute('subscription_purchase', 'success', success.toString());
    await setTraceAttribute('subscription_purchase', 'tier', tier);
    await setTraceAttribute('subscription_purchase', 'is_yearly', isYearly.toString());
    await stopTrace('subscription_purchase');
  }

  /// Track payment processing
  static Future<void> startPaymentTrace() async {
    await startTrace('payment_process');
  }

  /// Stop payment trace
  static Future<void> stopPaymentTrace({
    required bool success,
    required String paymentMethod,
    required double amount,
  }) async {
    await setTraceAttribute('payment_process', 'success', success.toString());
    await setTraceAttribute('payment_process', 'payment_method', paymentMethod);
    await setTraceMetric('payment_process', 'amount_try', amount.toInt());
    await stopTrace('payment_process');
  }

  // ==================== Analytics Integration ====================

  /// Track user journey
  static Future<void> startUserJourneyTrace(String journeyName) async {
    await startTrace('journey_$journeyName');
    await setTraceAttribute('journey_$journeyName', 'journey_name', journeyName);
  }

  /// Stop user journey trace
  static Future<void> stopUserJourneyTrace(
    String journeyName, {
    required bool completed,
    int? steps,
  }) async {
    await setTraceAttribute('journey_$journeyName', 'completed', completed.toString());
    if (steps != null) {
      await setTraceMetric('journey_$journeyName', 'steps', steps);
    }
    await stopTrace('journey_$journeyName');
  }

  // ==================== Utility ====================

  /// Get all active traces
  static List<String> getActiveTraces() {
    return _activeTraces.keys.toList();
  }

  /// Cancel all active traces (for cleanup)
  static Future<void> cancelAllTraces() async {
    final traceNames = _activeTraces.keys.toList();
    for (final traceName in traceNames) {
      await stopTrace(traceName);
    }
    print('🧹 Cancelled ${traceNames.length} active traces');
  }

  // ==================== HTTP Metrics ====================

  /// Create HTTP metric for network requests
  static HttpMetric createHttpMetric(
    String url,
    HttpMethod method,
  ) {
    return _performance.newHttpMetric(url, method);
  }

  /// Track HTTP request automatically
  static Future<T> trackHttpRequest<T>(
    String url,
    HttpMethod method,
    Future<T> Function() request, {
    int? requestPayloadSize,
    String? contentType,
  }) async {
    final metric = createHttpMetric(url, method);

    if (requestPayloadSize != null) {
      metric.requestPayloadSize = requestPayloadSize;
    }

    await metric.start();

    try {
      final response = await request();
      metric.httpResponseCode = 200;

      if (contentType != null) {
        metric.responseContentType = contentType;
      }

      await metric.stop();
      return response;
    } catch (e) {
      metric.httpResponseCode = 500;
      await metric.stop();
      rethrow;
    }
  }
}
