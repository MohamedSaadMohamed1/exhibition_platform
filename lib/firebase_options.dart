import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// TODO: Replace these placeholder values with your actual Firebase configuration.
/// You can get these values from the Firebase Console:
/// 1. Go to https://console.firebase.google.com/
/// 2. Select your project (or create a new one)
/// 3. Click on the gear icon -> Project settings
/// 4. Scroll down to "Your apps" section
/// 5. Add a Web app and copy the configuration values
///
/// Alternatively, run: flutterfire configure
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

  // Firebase Web configuration (update apiKey and appId after adding web app in Firebase Console)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD9x-MSWyX11Ts8wHo0OsY73HWqykKrBLY',
    appId: '1:835919913167:web:0000000000000000000000', // TODO: Update after adding web app
    messagingSenderId: '835919913167',
    projectId: 'mo219-caed7',
    authDomain: 'mo219-caed7.firebaseapp.com',
    storageBucket: 'mo219-caed7.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
  );

  // Firebase Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD9x-MSWyX11Ts8wHo0OsY73HWqykKrBLY',
    appId: '1:835919913167:android:699b2a21114c2f729657ba',
    messagingSenderId: '835919913167',
    projectId: 'mo219-caed7',
    storageBucket: 'mo219-caed7.firebasestorage.app',
  );

  // TODO: Replace with your actual Firebase iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.exhibitionPlatform',
  );

  // TODO: Replace with your actual Firebase macOS configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.exhibitionPlatform',
  );

  // Firebase Windows configuration (uses web config)
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD9x-MSWyX11Ts8wHo0OsY73HWqykKrBLY',
    appId: '1:835919913167:web:0000000000000000000000', // TODO: Update after adding web app
    messagingSenderId: '835919913167',
    projectId: 'mo219-caed7',
    authDomain: 'mo219-caed7.firebaseapp.com',
    storageBucket: 'mo219-caed7.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
  );
}
