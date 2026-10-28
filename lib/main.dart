import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'core/theme/bookstore_theme_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    if (const bool.fromEnvironment('USE_FIREBASE_EMULATORS')) {
      const host = String.fromEnvironment(
        'FIREBASE_EMULATOR_HOST',
        defaultValue: 'localhost',
      );
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    }
    // Restore the persisted session before routing private deep links.
    await FirebaseAuth.instance.authStateChanges().first;
  } catch (e) {
    runApp(
      MaterialApp(
        theme: BookstoreThemeData.lightTheme,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to connect to the bookstore. Check the Firebase configuration and try again.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: main, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }
  runApp(const ProviderScope(child: BookStoreApp()));
}
