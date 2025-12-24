import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Replace with your actual Supabase credentials
  // Get these from: https://app.supabase.com/project/_/settings/api
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Helper getter for Supabase client
  static SupabaseClient get client => Supabase.instance.client;

  // Helper getter for current user
  static User? get currentUser => client.auth.currentUser;

  // Helper getter for current session
  static Session? get currentSession => client.auth.currentSession;
}
