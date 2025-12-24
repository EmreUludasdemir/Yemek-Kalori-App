import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Supabase Project: turk-kalori
  // Project URL: https://mpyxfuthhsufpecqhxyp.supabase.co
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mpyxfuthhsufpecqhxyp.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1weXhmdXRoaHN1ZnBlY3FoeHlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY1ODEwNjQsImV4cCI6MjA4MjE1NzA2NH0.02I2GK7Kset8_eKYOT4GRG9Cl5NLfh-6PqqcJuVk0Ns',
  );

  // Helper getter for Supabase client
  static SupabaseClient get client => Supabase.instance.client;

  // Helper getter for current user
  static User? get currentUser => client.auth.currentUser;

  // Helper getter for current session
  static Session? get currentSession => client.auth.currentSession;
}
