import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:porrot_2025/presentation/screens/admin_panel_screen.dart';
import 'firebase_options.dart'; // Import the generated file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with the auto-generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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