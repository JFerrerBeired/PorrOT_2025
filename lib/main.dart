import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:porrot_2025/presentation/screens/admin_panel_screen.dart';

// IMPORTANT: Replace with your actual Firebase project configuration
// See FIREBASE_SETUP_INSTRUCTIONS.md for details.
const firebaseOptions = FirebaseOptions(
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // You need to configure Firebase for this to work.
  // For now, this will throw an exception, but it's set up for when you do configure it.
  try {
    await Firebase.initializeApp(options: firebaseOptions);
  } catch (e) {
    // ignore: avoid_print
    print(
      "Firebase initialization failed. Please follow FIREBASE_SETUP_INSTRUCTIONS.md",
    );
    // ignore: avoid_print
    print(e);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Porrot 2025 Admin',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AdminPanelScreen(),
    );
  }
}
