import 'package:flutter/material.dart';
import '../widgets/admin/contestant_manager.dart';
import '../widgets/admin/gala_manager.dart';
import '../widgets/admin/gala_config_manager.dart'; // New import

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  static const routeName = '/admin'; // Add this line

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Increased length for new tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Contestants'),
              Tab(icon: Icon(Icons.event), text: 'Galas'),
              Tab(icon: Icon(Icons.settings), text: 'Config'), // New tab
            ],
          ),
        ),
        body: const TabBarView(children: [
          ContestantManager(),
          GalaManager(),
          GalaConfigManager(), // New widget
        ]),
      ),
    );
  }
}
