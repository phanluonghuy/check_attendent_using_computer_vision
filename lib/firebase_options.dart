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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAK4umtRvCfyAnJqx_VJI_811RPzColfYE',
    appId: '1:945066306171:android:1baa62b817f155b785d0de',
    messagingSenderId: '945066306171',
    projectId: 'final-computer-vision',
    databaseURL: 'https://final-computer-vision-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'final-computer-vision.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAilep4JRv6hXs_SsCYKFBtXDfPMYFUTWI',
    appId: '1:859879349110:ios:5647d24cfbe0019aa4b857',
    messagingSenderId: '859879349110',
    projectId: 'my-dep-project',
    databaseURL: 'https://my-dep-project-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'my-dep-project.appspot.com',
    androidClientId: '859879349110-aotsll549sir5s7r356bcsp0qnjq0ia5.apps.googleusercontent.com',
    iosClientId: '859879349110-cf6fctkp3vb4vr71kliulqri9mf5mrl5.apps.googleusercontent.com',
    iosBundleId: 'com.example.ClassMate',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDS10v4UHSmauR5ew5RF-2r9nbkX34Qbvs',
    appId: '1:945066306171:web:247498db1fa8271a85d0de',
    messagingSenderId: '945066306171',
    projectId: 'final-computer-vision',
    authDomain: 'final-computer-vision.firebaseapp.com',
    databaseURL: 'https://final-computer-vision-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'final-computer-vision.firebasestorage.app',
    measurementId: 'G-NYF3CMDVZR',
  );

}