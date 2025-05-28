// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkdeals/auth/checking_auth.dart';
import 'package:talkdeals/firebase_options.dart';
import 'package:talkdeals/theme/color_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDkkq4iCJ-eCn0WqRB9Hq8Pn0QSEpWLsyM',
        appId: '1:133529124403:android:d37a1d051e2550ce5aad46',
        messagingSenderId: '133529124403',
        projectId: 'talkdeals-ddaa8',
        storageBucket: 'talkdeals-ddaa8.firebasestorage.app',
        authDomain: 'bookymet.firebaseapp.com',
      ),
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else if (defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.fuchsia) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TalkDeals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const CheckingAuth(), // your auth-gate screen
    );
  }
}
