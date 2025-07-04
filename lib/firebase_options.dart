import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCXy3DvKjBnoJ8oi9LbouF8hQaGRLgYdxE',
    appId: '1:1052236350369:web:91671822f0eecdb80f41e0',
    messagingSenderId: '1052236350369',
    projectId: 'travel-genie-494f7',
    authDomain: 'travel-genie-494f7.firebaseapp.com',
    storageBucket: 'travel-genie-494f7.firebasestorage.app',
    measurementId: 'G-L9XKCH5BQJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAundy5AWpE4Lw6a7Xa8VIDxOOcj7vzvvk',
    appId: '1:1052236350369:android:4d67912c0c8197800f41e0',
    messagingSenderId: '1052236350369',
    projectId: 'travel-genie-494f7',
    storageBucket: 'travel-genie-494f7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDdbEiygNYXKImKNlLurXgMu0wr9VjLysQ',
    appId: '1:1052236350369:ios:a710f989e50859920f41e0',
    messagingSenderId: '1052236350369',
    projectId: 'travel-genie-494f7',
    storageBucket: 'travel-genie-494f7.firebasestorage.app',
    iosBundleId: 'tech.linard.travelgenieapp.travelGenie',
  );
}
