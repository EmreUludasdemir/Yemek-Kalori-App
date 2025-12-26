# Firebase Crashlytics - Usage Guide

This document explains how to use the `CrashReportingService` to track crashes, log errors, and debug issues in production for the TürkKalori app.

## Table of Contents
- [Setup](#setup)
- [Basic Error Logging](#basic-error-logging)
- [User Tracking](#user-tracking)
- [Custom Keys](#custom-keys)
- [Breadcrumbs](#breadcrumbs)
- [Screen Tracking](#screen-tracking)
- [Specialized Error Logging](#specialized-error-logging)
- [Testing](#testing)
- [Best Practices](#best-practices)

## Setup

The Crashlytics service is automatically initialized in `main.dart`:

```dart
await CrashReportingService.initialize();
```

This sets up:
- Flutter error handler (catches all uncaught Flutter errors)
- Async error handler (catches all uncaught async errors)
- Automatic crash reporting to Firebase Console

## Basic Error Logging

### Log Non-Fatal Errors

Use this for caught exceptions that you want to track:

```dart
try {
  await someRiskyOperation();
} catch (e, stack) {
  await CrashReportingService.logError(
    e,
    stack,
    fatal: false,
    reason: 'Failed to load user data',
    information: {
      'user_id': userId,
      'operation': 'load_user_data',
    },
  );
  // Show user-friendly error message
}
```

### Log Fatal Errors

```dart
try {
  await criticalOperation();
} catch (e, stack) {
  await CrashReportingService.logError(
    e,
    stack,
    fatal: true,
    reason: 'Critical operation failed',
  );
  rethrow; // Or handle appropriately
}
```

### Log Flutter Errors

```dart
FlutterError.onError = (FlutterErrorDetails details) {
  CrashReportingService.logFlutterError(details);
};
```

## User Tracking

### Set User Identifier

Set the user ID when user logs in:

```dart
// On login
await CrashReportingService.setUserIdentifier(user.id);
```

### Clear User Identifier

Clear the user ID when user logs out:

```dart
// On logout
await CrashReportingService.clearUserIdentifier();
```

### Example: Login Flow

```dart
class AuthService {
  static Future<void> login(String email, String password) async {
    try {
      final user = await supabase.auth.signIn(email: email, password: password);

      // Set Crashlytics user ID
      await CrashReportingService.setUserIdentifier(user.id);

      // Set subscription tier
      final subscription = await PremiumService.getUserSubscription(user.id);
      await CrashReportingService.setSubscriptionTier(
        subscription?.tier.name ?? 'free',
      );
    } catch (e, stack) {
      await CrashReportingService.logAuthError('login_failed', e.toString());
      rethrow;
    }
  }
}
```

## Custom Keys

### Set Single Custom Key

```dart
await CrashReportingService.setCustomKey('last_action', 'add_food');
await CrashReportingService.setCustomKey('calories_today', 1500);
await CrashReportingService.setCustomKey('is_premium', true);
```

### Set Multiple Custom Keys

```dart
await CrashReportingService.setCustomKeys({
  'screen': 'home',
  'meal_type': 'breakfast',
  'food_count': 3,
  'has_network': true,
});
```

### App State Tracking

```dart
// Set app version
await CrashReportingService.setAppVersion('1.0.0+1');

// Set device info
await CrashReportingService.setDeviceInfo(
  platform: 'android',
  osVersion: '12',
  deviceModel: 'Pixel 6',
);

// Set subscription tier
await CrashReportingService.setSubscriptionTier('premium');
```

## Breadcrumbs

Use breadcrumbs to create a trail of events leading up to a crash:

```dart
// Navigation breadcrumb
await CrashReportingService.recordBreadcrumb(
  'User navigated to Profile Screen',
  category: 'navigation',
);

// User action breadcrumb
await CrashReportingService.recordBreadcrumb(
  'User added Menemen to breakfast',
  category: 'user_action',
);

// API call breadcrumb
await CrashReportingService.recordBreadcrumb(
  'Fetching food logs for today',
  category: 'api',
);
```

### Simple Logging

```dart
await CrashReportingService.log('User tapped Add Food button');
await CrashReportingService.log('Loading recipes from cache');
await CrashReportingService.log('Syncing offline data');
```

## Screen Tracking

Track the last screen user was on before a crash:

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Log screen view
    CrashReportingService.logScreenView('home_screen');

    return Scaffold(/* ... */);
  }
}
```

Or use a route observer:

```dart
class CrashlyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      CrashReportingService.logScreenView(route.settings.name ?? 'unknown');
    }
  }
}
```

## Specialized Error Logging

### Network Errors

```dart
try {
  final response = await dio.get('/api/foods');
} catch (e) {
  await CrashReportingService.logNetworkError(
    '/api/foods',
    response?.statusCode,
    e.toString(),
  );
}
```

### Authentication Errors

```dart
try {
  await supabase.auth.signIn(email: email, password: password);
} catch (e) {
  await CrashReportingService.logAuthError(
    'invalid_credentials',
    e.toString(),
  );
}
```

### Database Errors

```dart
try {
  await supabase.from('food_logs').insert(data);
} catch (e, stack) {
  await CrashReportingService.logDatabaseError(
    'insert',
    'food_logs',
    e,
    stack,
  );
}
```

### Payment Errors

```dart
try {
  await PaymentService.processPayment(paymentIntent);
} catch (e) {
  await CrashReportingService.logPaymentError(
    'credit_card',
    49.99,
    e.toString(),
  );
}
```

## Testing

### Send Test Crash Report (Debug Only)

```dart
await CrashReportingService.sendTestCrash();
```

### Force Crash (Debug Only)

```dart
// This will crash the app to test crash reporting
CrashReportingService.forceCrash();
```

### Check for Unsent Reports

```dart
final hasUnsent = await CrashReportingService.checkForUnsentReports();
if (hasUnsent) {
  await CrashReportingService.sendUnsentReports();
}
```

### Enable/Disable Crash Reporting

```dart
// Disable (e.g., for privacy settings)
await CrashReportingService.setCrashlyticsCollectionEnabled(false);

// Enable
await CrashReportingService.setCrashlyticsCollectionEnabled(true);

// Check status
final isEnabled = await CrashReportingService.isCrashlyticsCollectionEnabled();
```

## Best Practices

### 1. Always Log Context

```dart
// Good ✅
await CrashReportingService.logError(
  e,
  stack,
  reason: 'Failed to sync recipes',
  information: {
    'recipe_count': recipes.length,
    'category': category,
    'user_id': userId,
  },
);

// Bad ❌
await CrashReportingService.logError(e, stack);
```

### 2. Use Breadcrumbs for User Flow

```dart
await CrashReportingService.log('App started');
await CrashReportingService.log('User logged in');
await CrashReportingService.log('Navigated to Recipes');
await CrashReportingService.log('Selected recipe: Menemen');
await CrashReportingService.log('Started cooking mode');
// If crash happens here, you have full context
```

### 3. Track Important State

```dart
// Update custom keys as state changes
await CrashReportingService.setCustomKey('current_meal_plan_id', planId);
await CrashReportingService.setCustomKey('offline_queue_size', queueSize);
await CrashReportingService.setCustomKey('last_sync_timestamp', timestamp);
```

### 4. Don't Log Sensitive Data

```dart
// Don't log:
// - Passwords
// - API keys
// - Credit card numbers
// - Personal health data (beyond anonymous aggregates)
// - Email addresses (use hashed user IDs instead)

// Good ✅
await CrashReportingService.setUserIdentifier(hashedUserId);

// Bad ❌
await CrashReportingService.setCustomKey('user_email', email);
await CrashReportingService.setCustomKey('password', password);
```

### 5. Use Try-Catch Strategically

```dart
// Wrap risky operations
try {
  await performComplexOperation();
} catch (e, stack) {
  // Log to Crashlytics
  await CrashReportingService.logError(e, stack);

  // Show user-friendly message
  showErrorDialog(context, 'Something went wrong. Please try again.');

  // Don't rethrow unless necessary
}
```

### 6. Track API Errors

```dart
class ApiService {
  static Future<Response> get(String endpoint) async {
    try {
      await CrashReportingService.log('API GET: $endpoint');
      final response = await dio.get(endpoint);
      return response;
    } catch (e) {
      await CrashReportingService.logNetworkError(
        endpoint,
        (e as DioError).response?.statusCode,
        e.message,
      );
      rethrow;
    }
  }
}
```

### 7. Track Feature Usage

```dart
// Track when features are used (helps prioritize fixes)
await CrashReportingService.log('Feature used: AI Food Recognition');
await CrashReportingService.log('Feature used: Meal Planning');
await CrashReportingService.log('Feature used: Recipe Cooking Mode');
```

## Viewing Crash Reports

1. Go to Firebase Console → Crashlytics
2. View crashes by:
   - Time period
   - App version
   - Device type
   - OS version
3. Click on a crash to see:
   - Stack trace
   - Custom keys
   - Breadcrumbs
   - User count affected
   - First/last occurrence

## Integration with Analytics

Crashlytics works seamlessly with Firebase Analytics:

```dart
// Crashes are automatically linked to Analytics events
await AnalyticsService.logEvent('food_log_created', {
  'meal_type': 'breakfast',
  'food_name': 'Menemen',
});

// If a crash happens, you can correlate it with recent events
```

## Privacy Considerations

- User IDs are hashed before being sent to Crashlytics
- No personal data (email, name, etc.) is logged
- Crash reports can be disabled via app settings
- Compliant with KVKK (Turkish data protection law)

## Common Use Cases

### Food Logging Error

```dart
try {
  await FoodLogService.addFoodLog(foodLog);
  await CrashReportingService.log('Food log created successfully');
} catch (e, stack) {
  await CrashReportingService.logError(
    e,
    stack,
    reason: 'Failed to create food log',
    information: {
      'food_id': foodLog.foodId,
      'meal_type': foodLog.mealType,
      'calories': foodLog.calories,
    },
  );
}
```

### Recipe Loading Error

```dart
try {
  await CrashReportingService.log('Loading recipes...');
  final recipes = await RecipeService.fetchRecipes();
  await CrashReportingService.log('Recipes loaded: ${recipes.length}');
} catch (e, stack) {
  await CrashReportingService.logDatabaseError(
    'select',
    'recipes',
    e,
    stack,
  );
}
```

### Offline Sync Error

```dart
try {
  await OfflineSyncService.syncPendingOperations();
} catch (e, stack) {
  await CrashReportingService.logError(
    e,
    stack,
    reason: 'Offline sync failed',
    information: {
      'pending_operations': pendingCount,
      'has_network': ConnectivityService.isConnected,
    },
  );
}
```

## Troubleshooting

### Crashes not appearing in console?

1. Wait 5-10 minutes (Crashlytics has a delay)
2. Check if collection is enabled: `isCrashlyticsCollectionEnabled()`
3. Verify Firebase is initialized before Crashlytics
4. Check `google-services.json` / `GoogleService-Info.plist` are present

### Test crashes not working?

- Test crashes only work in release builds
- Use `sendTestCrash()` instead of `forceCrash()` in debug mode
- Check Firebase Console → Crashlytics → Settings

### Too many crashes?

- Review your error handling
- Use try-catch more liberally
- Add null checks before accessing data
- Validate data before processing
