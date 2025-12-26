import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'config/supabase_config.dart';
import 'config/firebase_config.dart';
import 'services/performance_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseConfig.currentPlatform,
  );

  // Initialize Firebase Performance Monitoring
  await PerformanceService.initialize();

  runApp(
    const ProviderScope(
      child: TurkKaloriApp(),
    ),
  );
}
