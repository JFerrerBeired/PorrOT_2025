import 'package:flutter/material.dart';
import '../widgets/admin/contestant_manager.dart';
import '../widgets/admin/gala_manager.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Contestants'),
              Tab(icon: Icon(Icons.event), text: 'Galas'),
            ],
          ),
        ),
        body: const TabBarView(children: [ContestantManager(), GalaManager()]),
      ),
    );
  }
}
