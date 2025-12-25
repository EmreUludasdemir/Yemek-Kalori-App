import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  // TODO: Replace with your actual Firebase configuration
  // Get these from: https://console.firebase.google.com/project/_/settings/general

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_AUTH_DOMAIN',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    measurementId: 'YOUR_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmWfH0JcS4HMsBetQs_czzOBQWu5aC3uU',
    appId: '1:851570875992:android:a06b4eb6667cfc86f4b42d',
    messagingSenderId: '851570875992',
    projectId: 'turkkalori',
    storageBucket: 'turkkalori.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB-BGTsuwG6aDjs6uA-fLMn5O1IHIUNVOI',
    appId: '1:851570875992:ios:a4854dc84269bb26f4b42d',
    messagingSenderId: '851570875992',
    projectId: 'turkkalori',
    storageBucket: 'turkkalori.firebasestorage.app',
    iosBundleId: 'comTurkkalori.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'com.example.turkKalori',
  );
}
