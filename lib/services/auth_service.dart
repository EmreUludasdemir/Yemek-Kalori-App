import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../data/models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      // 1. Sign up with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'full_name': fullName,
        },
      );

      // 2. If sign up successful, create profile
      if (response.user != null) {
        await _createProfile(
          userId: response.user!.id,
          username: username,
          fullName: fullName,
          email: email,
        );
      }

      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Kayıt olurken bir hata oluştu: $e');
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Giriş yaparken bir hata oluştu: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Çıkış yaparken bir hata oluştu: $e');
    }
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Şifre sıfırlama hatası: $e');
    }
  }

  /// Update password
  Future<UserResponse> updatePassword({required String newPassword}) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Şifre güncelleme hatası: $e');
    }
  }

  /// Get user profile from database
  Future<UserProfile?> getUserProfile({String? userId}) async {
    try {
      final id = userId ?? currentUser?.id;
      if (id == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile.fromJson(response);
    } catch (e) {
      print('❌ Error fetching profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? username,
    String? fullName,
    String? bio,
    String? avatarUrl,
    int? dailyCalorieGoal,
    int? dailyProteinGoal,
    int? dailyCarbsGoal,
    int? dailyFatGoal,
    int? heightCm,
    double? weightKg,
    DateTime? birthDate,
    String? gender,
    String? activityLevel,
    bool? isPublic,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı girişi gerekli');

      final updates = <String, dynamic>{};

      if (username != null) updates['username'] = username;
      if (fullName != null) updates['full_name'] = fullName;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (dailyCalorieGoal != null) {
        updates['daily_calorie_goal'] = dailyCalorieGoal;
      }
      if (dailyProteinGoal != null) {
        updates['daily_protein_goal'] = dailyProteinGoal;
      }
      if (dailyCarbsGoal != null) updates['daily_carbs_goal'] = dailyCarbsGoal;
      if (dailyFatGoal != null) updates['daily_fat_goal'] = dailyFatGoal;
      if (heightCm != null) updates['height_cm'] = heightCm;
      if (weightKg != null) updates['weight_kg'] = weightKg;
      if (birthDate != null) {
        updates['birth_date'] = birthDate.toIso8601String().split('T')[0];
      }
      if (gender != null) updates['gender'] = gender;
      if (activityLevel != null) updates['activity_level'] = activityLevel;
      if (isPublic != null) updates['is_public'] = isPublic;

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      throw Exception('Profil güncelleme hatası: $e');
    }
  }

  /// Create profile after sign up
  Future<void> _createProfile({
    required String userId,
    required String username,
    required String fullName,
    required String email,
  }) async {
    try {
      await _supabase.from('profiles').insert({
        'id': userId,
        'username': username,
        'full_name': fullName,
        'daily_calorie_goal': 2000,
        'daily_protein_goal': 50,
        'daily_carbs_goal': 250,
        'daily_fat_goal': 65,
        'daily_water_goal': 8,
        'is_public': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('✅ Profile created for user: $username');
    } catch (e) {
      print('❌ Error creating profile: $e');
      throw Exception('Profil oluşturma hatası: $e');
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı girişi gerekli');

      // Profile will be deleted automatically due to CASCADE
      await _supabase.auth.admin.deleteUser(userId);
    } catch (e) {
      throw Exception('Hesap silme hatası: $e');
    }
  }
}
