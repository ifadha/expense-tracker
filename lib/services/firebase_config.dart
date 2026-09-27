import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseConfig {
  static Future<FirebaseApp> initialize({
    FirebaseOptions? customOptions,
    String? name,
  }) async {
    return Firebase.initializeApp(
      name: name,
      options: customOptions ?? DefaultFirebaseOptions.currentPlatform,
    );
  }
}
