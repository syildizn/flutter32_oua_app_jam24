// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
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
    apiKey: 'AIzaSyAdZsgt_CgSFMUivHdxIHWbVURDIu0bTU4',
    appId: '1:664883077975:web:811dd120110369aeb05412',
    messagingSenderId: '664883077975',
    projectId: 'ouaappjam24',
    authDomain: 'ouaappjam24.firebaseapp.com',
    storageBucket: 'ouaappjam24.appspot.com',
    measurementId: 'G-X01N87QKDN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBC6iy_iBHI6xO59sZxjJkZu2uyAFIdYqM',
    appId: '1:664883077975:android:60244e2f714ad900b05412',
    messagingSenderId: '664883077975',
    projectId: 'ouaappjam24',
    storageBucket: 'ouaappjam24.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDMTCZzeauBog0nqFrtzPxxhSUmEPg-GyA',
    appId: '1:664883077975:ios:2378f84a84c577ccb05412',
    messagingSenderId: '664883077975',
    projectId: 'ouaappjam24',
    storageBucket: 'ouaappjam24.appspot.com',
    iosBundleId: 'com.example.flutter32OuaAppJam24',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDMTCZzeauBog0nqFrtzPxxhSUmEPg-GyA',
    appId: '1:664883077975:ios:a5ab4e066bd836dab05412',
    messagingSenderId: '664883077975',
    projectId: 'ouaappjam24',
    storageBucket: 'ouaappjam24.appspot.com',
    iosBundleId: 'com.example.flutter32OuaAppJam24.RunnerTests',
  );
}