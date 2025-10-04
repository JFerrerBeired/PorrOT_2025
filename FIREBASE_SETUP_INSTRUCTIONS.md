# Firebase Setup Instructions

Follow these steps to connect the Flutter application to your Firebase project.

## 1. Prerequisites

- You must have a Firebase project created.
- You should have the Flutter project open.

## 2. Android Setup

1.  In the [Firebase console](https://console.firebase.google.com/), go to **Project Overview** and click the **Android** icon to add an Android app.
2.  For the **Android package name**, use: `com.example.porrot_2025`.
3.  Register the app.
4.  Download the `google-services.json` file.
5.  Place the downloaded `google-services.json` file in the `android/app/` directory of the project.

## 3. iOS Setup

1.  In the Firebase console, go to **Project Settings** > **Your apps** and click **Add app**, then select **iOS**.
2.  For the **Apple bundle ID**, use: `com.example.porrot2025`.
3.  Register the app.
4.  Download the `GoogleService-Info.plist` file.
5.  Place the downloaded `GoogleService-Info.plist` file in the `ios/Runner/` directory of the project.

## 4. Web Setup

1.  In the Firebase console, go to **Project Settings** > **Your apps** and click **Add app**, then select **Web** (`</>`).
2.  Register the app.
3.  You will be shown a `firebaseConfig` object. You will need this for the web integration.

## 5. Initialize Firebase in the App

The application code expects to be initialized with the Firebase configuration. In `lib/main.dart`, you will need to ensure Firebase is initialized before the app runs. The code will look something like this, but you will need to replace the placeholder values with your actual web configuration from step 4.

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// IMPORTANT: Replace with your actual Firebase project configuration
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
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Porrot 2025',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Text('App Initialized'), // Replace with your home screen
    );
  }
}
```

Once you have completed these steps, the app will be connected to your Firebase project.