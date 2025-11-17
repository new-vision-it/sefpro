import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../firebase_options.dart';

/// Initializes Firebase for the app. Call before running the app.
Future<void> initFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    await messaging.getToken();
  } catch (_) {
    // Messaging permissions can fail silently in unsupported environments.
  }
}
