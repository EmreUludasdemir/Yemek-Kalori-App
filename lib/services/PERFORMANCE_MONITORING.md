# Firebase Performance Monitoring - Usage Guide

This document explains how to use the `PerformanceService` to track app performance metrics and custom traces throughout the TürkKalori app.

## Table of Contents
- [Setup](#setup)
- [Basic Usage](#basic-usage)
- [Screen Traces](#screen-traces)
- [Food Log Operations](#food-log-operations)
- [Recipe Operations](#recipe-operations)
- [Social Features](#social-features)
- [Sync Operations](#sync-operations)
- [Network Requests](#network-requests)
- [Premium Features](#premium-features)
- [Best Practices](#best-practices)

## Setup

The Performance Service is automatically initialized in `main.dart`:

```dart
await PerformanceService.initialize();
```

## Basic Usage

### Starting and Stopping Custom Traces

```dart
// Start a trace
await PerformanceService.startTrace('my_operation');

// Do work...

// Stop the trace
await PerformanceService.stopTrace('my_operation');
```

### Adding Metrics and Attributes

```dart
await PerformanceService.startTrace('data_load');

// Add metric (numeric value)
await PerformanceService.setTraceMetric('data_load', 'item_count', 50);

// Add attribute (string value)
await PerformanceService.setTraceAttribute('data_load', 'data_type', 'recipes');

await PerformanceService.stopTrace('data_load');
```

### Track Complete Operations

Use `trackOperation` for automatic start/stop:

```dart
final result = await PerformanceService.trackOperation(
  'load_user_profile',
  () async {
    return await fetchUserProfile(userId);
  },
  attributes: {
    'user_id': userId,
    'cache': 'enabled',
  },
  metrics: {
    'cache_hits': 10,
  },
);
```

## Screen Traces

Track screen load times:

```dart
class MyScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    // Start trace when screen initializes
    PerformanceService.startScreenTrace('my_screen');
  }

  void _loadData() async {
    await fetchData();

    // Stop trace when data is loaded
    await PerformanceService.stopScreenTrace('my_screen');
  }
}
```

## Food Log Operations

### Food Log Creation

```dart
await PerformanceService.startFoodLogTrace();

try {
  await createFoodLog(foodData);
  await PerformanceService.stopFoodLogTrace(success: true);
} catch (e) {
  await PerformanceService.stopFoodLogTrace(success: false);
  rethrow;
}
```

### Barcode Scanning

```dart
await PerformanceService.startBarcodeScanTrace();

final product = await scanBarcode();

await PerformanceService.stopBarcodeScanTrace(
  found: product != null,
  productName: product?.name,
);
```

### AI Food Recognition

```dart
await PerformanceService.startAIRecognitionTrace();

final recognizedFoods = await recognizeFoodsFromImage(image);

final avgConfidence = recognizedFoods
    .map((f) => f.confidence)
    .reduce((a, b) => a + b) / recognizedFoods.length;

await PerformanceService.stopAIRecognitionTrace(
  foodsRecognized: recognizedFoods.length,
  avgConfidence: avgConfidence,
);
```

## Recipe Operations

### Recipe Loading

```dart
await PerformanceService.startRecipeLoadTrace(category: 'Ana Yemek');

final recipes = await RecipeService.fetchRecipes(category: 'Ana Yemek');

await PerformanceService.stopRecipeLoadTrace(recipeCount: recipes.length);
```

### Cooking Session

```dart
await PerformanceService.startCookingSessionTrace();

// User cooks...

await PerformanceService.stopCookingSessionTrace(
  totalSteps: recipe.steps.length,
  completedSteps: completedCount,
  durationMinutes: sessionDuration,
);
```

## Social Features

### Feed Loading

```dart
await PerformanceService.startFeedLoadTrace(feedType: 'following');

final posts = await SocialService.getFeedPosts(feedType: 'following');

await PerformanceService.stopFeedLoadTrace(postCount: posts.length);
```

### Post Creation

```dart
await PerformanceService.startPostCreateTrace();

final images = await pickImages();
await createPost(content, images);

await PerformanceService.stopPostCreateTrace(
  hasImage: images.isNotEmpty,
  imageCount: images.length,
);
```

## Sync Operations

### Offline Sync (Example Implementation)

See `offline_sync_service.dart` for complete example:

```dart
await PerformanceService.startOfflineSyncTrace();

int syncedCount = 0;
int failedCount = 0;

// Perform sync operations...

await PerformanceService.stopOfflineSyncTrace(
  operationsSynced: syncedCount,
  operationsFailed: failedCount,
);
```

### Health App Sync

```dart
await PerformanceService.startHealthSyncTrace();

final dataPoints = await HealthSyncService.syncWeight();

await PerformanceService.stopHealthSyncTrace(
  dataPointsSynced: dataPoints.length,
  source: 'Apple Health',
);
```

## Network Requests

### API Calls

```dart
await PerformanceService.startApiTrace('get_user_stats');

final response = await dio.get('/api/user/stats');

await PerformanceService.stopApiTrace(
  'get_user_stats',
  statusCode: response.statusCode ?? 500,
  responseSize: response.data.toString().length ~/ 1024, // KB
);
```

### HTTP Metrics (Automatic)

```dart
final data = await PerformanceService.trackHttpRequest(
  'https://api.example.com/data',
  HttpMethod.Get,
  () async {
    return await fetchData();
  },
  requestPayloadSize: 1024,
  contentType: 'application/json',
);
```

### Database Queries

```dart
await PerformanceService.startDatabaseTrace('get_food_logs');

final logs = await supabase
    .from('food_logs')
    .select()
    .eq('user_id', userId);

await PerformanceService.stopDatabaseTrace(
  'get_food_logs',
  rowCount: logs.length,
);
```

## Premium Features

### Subscription Purchase

```dart
await PerformanceService.startSubscriptionTrace();

try {
  await PremiumService.subscribe(
    userId: userId,
    tier: SubscriptionTier.premium,
    isYearly: true,
  );

  await PerformanceService.stopSubscriptionTrace(
    success: true,
    tier: 'premium',
    isYearly: true,
  );
} catch (e) {
  await PerformanceService.stopSubscriptionTrace(
    success: false,
    tier: 'premium',
    isYearly: true,
  );
  rethrow;
}
```

### Payment Processing

```dart
await PerformanceService.startPaymentTrace();

final result = await PaymentService.processPayment(
  paymentIntentId: intentId,
  paymentMethod: PaymentMethod(type: 'credit_card'),
);

await PerformanceService.stopPaymentTrace(
  success: result.success,
  paymentMethod: 'credit_card',
  amount: 49.99,
);
```

## Best Practices

### 1. Always Stop Traces

Use try-finally to ensure traces are stopped even on errors:

```dart
await PerformanceService.startTrace('my_operation');
try {
  await performOperation();
  await PerformanceService.stopTrace('my_operation');
} catch (e) {
  await PerformanceService.setTraceAttribute('my_operation', 'error', e.toString());
  await PerformanceService.stopTrace('my_operation');
  rethrow;
}
```

### 2. Use Meaningful Names

```dart
// Good
await PerformanceService.startTrace('recipe_detail_load');

// Bad
await PerformanceService.startTrace('load1');
```

### 3. Add Context with Attributes

```dart
await PerformanceService.setTraceAttribute('recipe_load', 'category', 'Tatlı');
await PerformanceService.setTraceAttribute('recipe_load', 'is_premium', 'true');
```

### 4. Track Important Metrics

```dart
await PerformanceService.setTraceMetric('data_sync', 'items_synced', 25);
await PerformanceService.setTraceMetric('data_sync', 'items_failed', 2);
```

### 5. Use User Journeys for Complex Flows

```dart
// Start when user begins onboarding
await PerformanceService.startUserJourneyTrace('onboarding');

// Track through multiple screens...

// Complete when onboarding finishes
await PerformanceService.stopUserJourneyTrace(
  'onboarding',
  completed: true,
  steps: 5,
);
```

### 6. Clean Up Active Traces

If needed (e.g., when user logs out):

```dart
await PerformanceService.cancelAllTraces();
```

### 7. Don't Over-Track

Track important operations, but don't add traces to every function:

```dart
// Good - track important UI operations
await PerformanceService.startScreenTrace('home_screen');

// Bad - don't track trivial operations
// await PerformanceService.startTrace('format_date'); ❌
```

## Monitoring Results

View performance data in the Firebase Console:
1. Go to Firebase Console → Performance
2. View automatic traces (app start, screen rendering)
3. View custom traces you've added
4. Analyze metrics and attributes
5. Set up alerts for performance regressions

## Common Trace Names

Here are the standardized trace names used in TürkKalori:

### Screens
- `screen_home`
- `screen_food_log`
- `screen_recipes`
- `screen_social_feed`
- `screen_profile`

### Operations
- `food_log_create`
- `barcode_scan`
- `ai_food_recognition`
- `recipe_load`
- `cooking_session`
- `feed_load`
- `post_create`
- `offline_sync`
- `health_sync`

### Network
- `api_get_user_stats`
- `api_create_post`
- `api_upload_image`

### Database
- `db_get_food_logs`
- `db_get_recipes`
- `db_get_posts`

### Premium
- `subscription_purchase`
- `payment_process`

### User Journeys
- `journey_onboarding`
- `journey_first_food_log`
- `journey_first_recipe`
- `journey_social_signup`
