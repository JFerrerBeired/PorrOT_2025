import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_selection_provider.dart';
import '../providers/session_provider.dart';
import 'dashboard_screen.dart';

class PlayerSelectionScreen extends StatefulWidget {
  const PlayerSelectionScreen({super.key});

  static const routeName = '/';

  @override
  State<PlayerSelectionScreen> createState() => _PlayerSelectionScreenState();
}

class _PlayerSelectionScreenState extends State<PlayerSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlayerSelectionProvider>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PorrOT 2025 - Selecciona tu Perfil')),
      body: Consumer<PlayerSelectionProvider>(
        builder: (context, provider, child) {
          switch (provider.state) {
            case PlayerSelectionState.loading:
              return const Center(child: CircularProgressIndicator());
            case PlayerSelectionState.error:
              return Center(child: Text('Error: ${provider.errorMessage}'));
            case PlayerSelectionState.loaded:
              return ListView.builder(
                itemCount: provider.users.length,
                itemBuilder: (context, index) {
                  final user = provider.users[index];
                  return ListTile(
                    title: Text(user.displayName),
                    onTap: () {
                      Provider.of<SessionProvider>(
                        context,
                        listen: false,
                      ).setUser(user);
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(DashboardScreen.routeName);
                    },
                  );
                },
              );
            default:
              return const Center(child: Text('Inicia la selección'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Jugador'),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Añadir Nuevo Jugador'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Introduce tu nombre"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('Crear'),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final playerProvider = Provider.of<PlayerSelectionProvider>(
                    context,
                    listen: false,
                  );
                  final sessionProvider = Provider.of<SessionProvider>(
                    context,
                    listen: false,
                  );

                  Navigator.of(dialogContext).pop();

                  final newUser = await playerProvider.createUser(name);
                  if (!mounted) return; // Add this check
                  if (newUser != null) {
                    sessionProvider.setUser(newUser);
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(DashboardScreen.routeName);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al crear el usuario.'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
