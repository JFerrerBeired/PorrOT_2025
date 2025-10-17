import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'data/repositories/app_config_repository_impl.dart'; // New import
import 'data/repositories/contestant_repository_impl.dart';
import 'data/repositories/gala_repository_impl.dart';
import 'data/repositories/prediction_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/app_config_repository.dart'; // New import
import 'domain/repositories/contestant_repository.dart';
import 'domain/repositories/gala_repository.dart';
import 'domain/repositories/prediction_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/usecases/create_user_usecase.dart';
import 'domain/usecases/get_active_contestants_usecase.dart';
import 'domain/usecases/get_active_gala_id_usecase.dart'; // New import
import 'domain/usecases/get_all_galas_usecase.dart'; // New import
import 'domain/usecases/get_gala_details_usecase.dart';
import 'domain/usecases/get_prediction_for_gala_usecase.dart'; // New import
import 'domain/usecases/get_users_usecase.dart';
import 'domain/usecases/set_active_gala_id_usecase.dart'; // New import
import 'domain/usecases/submit_prediction_usecase.dart';
import 'presentation/providers/app_config_provider.dart'; // New import
import 'presentation/providers/gala_manager_provider.dart'; // New import
import 'presentation/providers/player_selection_provider.dart';
import 'presentation/providers/prediction_provider.dart';
import 'presentation/providers/session_provider.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/player_selection_screen.dart';
import 'presentation/screens/prediction_screen.dart';
import 'presentation/screens/admin_panel_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Infrastructure
        Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),

        // Repositories
        Provider<UserRepository>(
          create: (context) =>
              UserRepositoryImpl(context.read<FirebaseFirestore>()),
        ),
        Provider<ContestantRepository>(
          create: (context) =>
              ContestantRepositoryImpl(context.read<FirebaseFirestore>()),
        ),
        Provider<GalaRepository>(
          create: (context) =>
              GalaRepositoryImpl(context.read<FirebaseFirestore>()),
        ),
        Provider<PredictionRepository>(
          create: (context) =>
              PredictionRepositoryImpl(context.read<FirebaseFirestore>()),
        ),
        Provider<AppConfigRepository>(
          // New AppConfigRepository
          create: (context) =>
              AppConfigRepositoryImpl(context.read<FirebaseFirestore>()),
        ),

        // User Use Cases
        Provider<GetUsersUseCase>(
          create: (context) => GetUsersUseCase(context.read<UserRepository>()),
        ),
        Provider<CreateUserUseCase>(
          create: (context) =>
              CreateUserUseCase(context.read<UserRepository>()),
        ),

        // Gala Use Cases
        Provider<GetAllGalasUseCase>(
          // New GetAllGalasUseCase
          create: (context) =>
              GetAllGalasUseCase(context.read<GalaRepository>()),
        ),
        Provider<GetGalaDetailsUseCase>(
          create: (context) =>
              GetGalaDetailsUseCase(context.read<GalaRepository>()),
        ),

        // AppConfig Use Cases
        Provider<GetActiveGalaIdUseCase>(
          // New GetActiveGalaIdUseCase
          create: (context) =>
              GetActiveGalaIdUseCase(context.read<AppConfigRepository>()),
        ),
        Provider<SetActiveGalaIdUseCase>(
          // New SetActiveGalaIdUseCase
          create: (context) =>
              SetActiveGalaIdUseCase(context.read<AppConfigRepository>()),
        ),

        // Prediction Use Cases
        Provider<GetActiveContestantsUseCase>(
          create: (context) =>
              GetActiveContestantsUseCase(context.read<ContestantRepository>()),
        ),
        Provider<SubmitPredictionUseCase>(
          create: (context) =>
              SubmitPredictionUseCase(context.read<PredictionRepository>()),
        ),
        Provider<GetPredictionForGalaUseCase>(
          // New GetPredictionForGalaUseCase
          create: (context) =>
              GetPredictionForGalaUseCase(context.read<PredictionRepository>()),
        ),

        // View Models / State Notifiers
        ChangeNotifierProvider<SessionProvider>(
          create: (_) => SessionProvider(),
        ),
        ChangeNotifierProvider<PlayerSelectionProvider>(
          create: (context) => PlayerSelectionProvider(
            context.read<GetUsersUseCase>(),
            context.read<CreateUserUseCase>(),
          ),
        ),
        ChangeNotifierProvider<AppConfigProvider>(
          // New AppConfigProvider
          create: (context) => AppConfigProvider(
            context.read<GetActiveGalaIdUseCase>(),
            context.read<SetActiveGalaIdUseCase>(),
          ),
        ),
        ChangeNotifierProvider<GalaManagerProvider>(
          // New GalaManagerProvider
          create: (context) =>
              GalaManagerProvider(context.read<GetAllGalasUseCase>()),
        ),
        ChangeNotifierProvider<PredictionProvider>(
          create: (context) => PredictionProvider(
            context.read<GetActiveContestantsUseCase>(),
            context.read<GetGalaDetailsUseCase>(),
            context.read<SubmitPredictionUseCase>(),
            context.read<GetPredictionForGalaUseCase>(), // New dependency
            context.read<AppConfigProvider>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'PorrOT 2025',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        home: const PlayerSelectionScreen(),
        routes: {
          DashboardScreen.routeName: (ctx) => const DashboardScreen(),
          PredictionScreen.routeName: (ctx) => const PredictionScreen(),
          AdminPanelScreen.routeName: (ctx) =>
              const AdminPanelScreen(), // Use actual screen
        },
      ),
    );
  }
}
