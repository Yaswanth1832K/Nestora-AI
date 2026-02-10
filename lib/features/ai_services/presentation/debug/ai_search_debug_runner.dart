import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ai_providers.dart';

class AISearchDebugRunner {
  static Future<void> run(ProviderContainer container) async {
    debugPrint('🤖 Starting AI Search Debug Runner...');

    // 1. Authenticate anonymously (required for Firestore)
    User? user;
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      user = userCredential.user;
      debugPrint('🔑 Authenticated anonymously. UID: ${user?.uid}');
    } catch (e) {
      debugPrint('❌ Authentication failed: $e');
      return;
    }

    final searchUseCase = container.read(naturalLanguageSearchUseCaseProvider);
    const query = "2bhk near college under 15000";

    debugPrint('🗣️ Sending Query: "$query"');

    final result = await searchUseCase(query: query);

    result.fold(
      (failure) => debugPrint('❌ Search failed: ${failure.message}'),
      (listings) {
        debugPrint('✅ Google AI Extraction Successful!');
        debugPrint('🏠 Found ${listings.length} matching listings in Firestore.');
        for (final listing in listings) {
          debugPrint(' - ${listing.title} (₹${listing.price})');
        }
      },
    );
  }
}
