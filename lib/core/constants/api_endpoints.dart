class ApiEndpoints {
  // Supabase Tables
  static const String profilesTable = 'profiles';
  static const String foodsTable = 'foods';
  static const String foodLogsTable = 'food_logs';
  static const String postsTable = 'posts';
  static const String likesTable = 'likes';
  static const String commentsTable = 'comments';
  static const String followsTable = 'follows';
  static const String notificationsTable = 'notifications';
  static const String waterLogsTable = 'water_logs';
  static const String achievementsTable = 'achievements';
  static const String userAchievementsTable = 'user_achievements';

  // Supabase Storage Buckets
  static const String avatarsBucket = 'avatars';
  static const String foodImagesBucket = 'food_images';
  static const String postImagesBucket = 'post_images';

  // External APIs
  static const String calorieMamaBaseUrl = 'https://api.caloriemama.ai/v1';
  static const String fatSecretBaseUrl = 'https://platform.fatsecret.com/rest/server.api';
  static const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org/api/v2';

  // Calorie Mama Endpoints
  static const String calorieMamaRecognition = '$calorieMamaBaseUrl/foodrecognition';

  // FatSecret Endpoints - Uses OAuth 1.0, parameters via query
  static const String fatSecretSearch = fatSecretBaseUrl;
  static const String fatSecretLookup = fatSecretBaseUrl;

  // Open Food Facts Endpoints
  static const String openFoodFactsSearch = '$openFoodFactsBaseUrl/search';
  static const String openFoodFactsProduct = '$openFoodFactsBaseUrl/product';
}
