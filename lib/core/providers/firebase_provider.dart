import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Async provider that reports Firebase initialization status.
/// True = Firebase.initializeApp() completed successfully.
final firebaseConnectionProvider = FutureProvider<bool>((ref) async {
  return Firebase.apps.isNotEmpty;
});
