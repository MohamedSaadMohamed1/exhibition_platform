import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Firebase project: candoo-7ddfc
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
        return windows;
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

  // Firebase Web configuration
  // TODO: Add web app in Firebase Console and update appId
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAo9oFzl6DvKAatjFJHig_DWTBw47VxnNA',
    appId: '1:810206757302:web:0000000000000000000000', // TODO: Update after adding web app
    messagingSenderId: '810206757302',
    projectId: 'candoo-7ddfc',
    authDomain: 'candoo-7ddfc.firebaseapp.com',
    storageBucket: 'candoo-7ddfc.firebasestorage.app',
  );

  // Firebase Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAo9oFzl6DvKAatjFJHig_DWTBw47VxnNA',
    appId: '1:810206757302:android:eb38b062f2c646997b4117',
    messagingSenderId: '810206757302',
    projectId: 'candoo-7ddfc',
    storageBucket: 'candoo-7ddfc.firebasestorage.app',
  );

  // TODO: Replace with your actual Firebase iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:810206757302:ios:0000000000000000000000',
    messagingSenderId: '810206757302',
    projectId: 'candoo-7ddfc',
    storageBucket: 'candoo-7ddfc.firebasestorage.app',
    iosBundleId: 'com.example.exhibitionPlatform',
  );

  // TODO: Replace with your actual Firebase macOS configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: '1:810206757302:ios:0000000000000000000000',
    messagingSenderId: '810206757302',
    projectId: 'candoo-7ddfc',
    storageBucket: 'candoo-7ddfc.firebasestorage.app',
    iosBundleId: 'com.example.exhibitionPlatform',
  );

  // Firebase Windows configuration (uses web config)
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAo9oFzl6DvKAatjFJHig_DWTBw47VxnNA',
    appId: '1:810206757302:web:0000000000000000000000', // TODO: Update after adding web app
    messagingSenderId: '810206757302',
    projectId: 'candoo-7ddfc',
    authDomain: 'candoo-7ddfc.firebaseapp.com',
    storageBucket: 'candoo-7ddfc.firebasestorage.app',
  );
}
