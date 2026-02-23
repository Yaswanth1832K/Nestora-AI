import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_rental/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/foundation.dart';

/// Provider to manage FCM token synchronization.
/// This listens to auth state changes and updates the token in Firestore.
final fcmTokenSyncProvider = Provider.autoDispose<void>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user != null) {
    _syncToken(ref);
  }
});

Future<void> _syncToken(Ref ref) async {
  try {
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();
    
    if (token != null) {
      await ref.read(updateFcmTokenUseCaseProvider)(token);
      debugPrint('FCM Token synced successfully: $token');
    }
  } catch (e) {
    debugPrint('Error syncing FCM Token: $e');
  }
}
