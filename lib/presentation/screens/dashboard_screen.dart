import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import 'player_selection_screen.dart';
import 'prediction_screen.dart'; // New import
import 'admin_panel_screen.dart'; // New import

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final currentUser = sessionProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Change User',
            onPressed: () {
              sessionProvider.clearSession();
              Navigator.of(
                context,
              ).pushReplacementNamed(PlayerSelectionScreen.routeName);
            },
          ),
          IconButton(
            // New Admin Button
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Admin Panel',
            onPressed: () {
              Navigator.of(context).pushNamed(AdminPanelScreen.routeName);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentUser != null)
              Text(
                'Bienvenido, ${currentUser.displayName}!',
                style: Theme.of(context).textTheme.headlineMedium,
              )
            else
              const Text('No user selected'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(PredictionScreen.routeName);
              },
              child: const Text('¡Haz tu predicción!'),
            ),
          ],
        ),
      ),
    );
  }
}
