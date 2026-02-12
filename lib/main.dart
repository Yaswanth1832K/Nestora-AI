import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:house_rental/app.dart';
import 'package:house_rental/firebase_options.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // AUTO ANONYMOUS LOGIN
  if (FirebaseAuth.instance.currentUser == null) {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      debugPrint("Signed in anonymously: ${FirebaseAuth.instance.currentUser!.uid}");
    } catch (e) {
      debugPrint("Anonymous sign-in error: $e");
    }
  }

  runApp(
    const ProviderScope(
      child: HouseRentalApp(),
    ),
  );
}
