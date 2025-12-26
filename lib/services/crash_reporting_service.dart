import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Firebase Crashlytics Service
/// Handles crash reporting, error logging, and user tracking for debugging
class CrashReportingService {
  static FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  // ==================== Initialization ====================

  /// Initialize Firebase Crashlytics
  /// Sets up Flutter error handlers and async error handlers
  static Future<void> initialize() async {
    try {
      // Enable Crashlytics collection
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      // Pass all uncaught Flutter errors to Crashlytics
      FlutterError.onError = (FlutterErrorDetails details) {
        _crashlytics.recordFlutterFatalError(details);
        // Also print to console in debug mode
        if (kDebugMode) {
          FlutterError.presentError(details);
        }
      };

      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      print('✅ Firebase Crashlytics initialized');
    } catch (e) {
      print('❌ Error initializing Firebase Crashlytics: $e');
    }
  }

  // ==================== Error Logging ====================

  /// Log a non-fatal error with stack trace
  /// Use this for caught exceptions that you want to track
  static Future<void> logError(
    dynamic error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
    Map<String, dynamic>? information,
  }) async {
    try {
      // Add custom keys if provided
      if (information != null) {
        for (final entry in information.entries) {
          await setCustomKey(entry.key, entry.value.toString());
        }
      }

      // Record the error
      await _crashlytics.recordError(
        error,
        stack,
        fatal: fatal,
        reason: reason,
      );

      // Log to console in debug mode
      if (kDebugMode) {
        print('🔴 Error logged to Crashlytics: $error');
        if (reason != null) print('   Reason: $reason');
        if (stack != null) print('   Stack: $stack');
      }
    } catch (e) {
      print('❌ Failed to log error to Crashlytics: $e');
    }
  }

  /// Log a Flutter error
  static Future<void> logFlutterError(FlutterErrorDetails details) async {
    try {
      await _crashlytics.recordFlutterError(details);
    } catch (e) {
      print('❌ Failed to log Flutter error: $e');
    }
  }

  // ==================== User Tracking ====================

  /// Set user identifier for crash reports
  /// Helps identify which user experienced the crash
  static Future<void> setUserIdentifier(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      print('👤 Crashlytics user ID set: $userId');
    } catch (e) {
      print('❌ Failed to set user identifier: $e');
    }
  }

  /// Clear user identifier (e.g., on logout)
  static Future<void> clearUserIdentifier() async {
    try {
      await _crashlytics.setUserIdentifier('');
      print('👤 Crashlytics user ID cleared');
    } catch (e) {
      print('❌ Failed to clear user identifier: $e');
    }
  }

  // ==================== Custom Keys ====================

  /// Set a custom key-value pair
  /// Useful for tracking app state at the time of crash
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      if (value is String) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is int) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is double) {
        await _crashlytics.setCustomKey(key, value);
      } else if (value is bool) {
        await _crashlytics.setCustomKey(key, value);
      } else {
        await _crashlytics.setCustomKey(key, value.toString());
      }
    } catch (e) {
      print('❌ Failed to set custom key: $e');
    }
  }

  /// Set multiple custom keys at once
  static Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    for (final entry in keys.entries) {
      await setCustomKey(entry.key, entry.value);
    }
  }

  // ==================== Logging & Breadcrumbs ====================

  /// Log a message to Crashlytics
  /// Creates a breadcrumb trail for debugging
  static Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
      if (kDebugMode) {
        print('📝 Crashlytics log: $message');
      }
    } catch (e) {
      print('❌ Failed to log message: $e');
    }
  }

  /// Record a breadcrumb for debugging crash context
  static Future<void> recordBreadcrumb(String message, {String? category}) async {
    try {
      final breadcrumb = category != null ? '[$category] $message' : message;
      await _crashlytics.log(breadcrumb);
    } catch (e) {
      print('❌ Failed to record breadcrumb: $e');
    }
  }

  // ==================== Screen Tracking ====================

  /// Log screen view
  static Future<void> logScreenView(String screenName) async {
    await setCustomKey('last_screen', screenName);
    await log('Screen: $screenName');
  }

  // ==================== App State ====================

  /// Set subscription tier
  static Future<void> setSubscriptionTier(String tier) async {
    await setCustomKey('subscription_tier', tier);
  }

  /// Set app version
  static Future<void> setAppVersion(String version) async {
    await setCustomKey('app_version', version);
  }

  /// Set device info
  static Future<void> setDeviceInfo({
    required String platform,
    required String osVersion,
    String? deviceModel,
  }) async {
    await setCustomKeys({
      'platform': platform,
      'os_version': osVersion,
      if (deviceModel != null) 'device_model': deviceModel,
    });
  }

  // ==================== Network Errors ====================

  /// Log network error
  static Future<void> logNetworkError(
    String endpoint,
    int? statusCode,
    String? errorMessage,
  ) async {
    await logError(
      'Network Error',
      StackTrace.current,
      reason: 'API call failed: $endpoint',
      information: {
        'endpoint': endpoint,
        if (statusCode != null) 'status_code': statusCode,
        if (errorMessage != null) 'error_message': errorMessage,
      },
    );
  }

  // ==================== Auth Errors ====================

  /// Log authentication error
  static Future<void> logAuthError(String errorType, String? message) async {
    await logError(
      'Auth Error: $errorType',
      StackTrace.current,
      reason: message ?? 'Authentication failed',
      information: {
        'error_type': errorType,
      },
    );
  }

  // ==================== Database Errors ====================

  /// Log database error
  static Future<void> logDatabaseError(
    String operation,
    String table,
    dynamic error,
    StackTrace stack,
  ) async {
    await logError(
      error,
      stack,
      reason: 'Database operation failed',
      information: {
        'operation': operation,
        'table': table,
      },
    );
  }

  // ==================== Payment Errors ====================

  /// Log payment error
  static Future<void> logPaymentError(
    String paymentMethod,
    double amount,
    String errorMessage,
  ) async {
    await logError(
      'Payment Error',
      StackTrace.current,
      reason: errorMessage,
      information: {
        'payment_method': paymentMethod,
        'amount': amount,
      },
    );
  }

  // ==================== Testing ====================

  /// Force a crash for testing (ONLY USE IN DEBUG MODE)
  static void forceCrash() {
    if (kDebugMode) {
      throw Exception('Test crash from CrashReportingService');
    } else {
      print('⚠️ forceCrash() is only available in debug mode');
    }
  }

  /// Send a test crash report
  static Future<void> sendTestCrash() async {
    if (kDebugMode) {
      await logError(
        Exception('Test crash report'),
        StackTrace.current,
        fatal: false,
        reason: 'Testing Crashlytics integration',
      );
      print('✅ Test crash report sent');
    } else {
      print('⚠️ sendTestCrash() is only available in debug mode');
    }
  }

  // ==================== Crash-Free Statistics ====================

  /// Check if crash reporting is enabled
  static Future<bool> isCrashlyticsCollectionEnabled() async {
    return await _crashlytics.isCrashlyticsCollectionEnabled();
  }

  /// Enable/disable crash reporting
  static Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  /// Check if there are any unsent crash reports
  static Future<bool> checkForUnsentReports() async {
    return await _crashlytics.checkForUnsentReports();
  }

  /// Send unsent crash reports
  static Future<void> sendUnsentReports() async {
    await _crashlytics.sendUnsentReports();
  }

  /// Delete unsent crash reports
  static Future<void> deleteUnsentReports() async {
    await _crashlytics.deleteUnsentReports();
  }
}
