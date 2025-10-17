import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/gala.dart';
import '../../providers/app_config_provider.dart';
import '../../providers/gala_manager_provider.dart';

class GalaConfigManager extends StatefulWidget {
  const GalaConfigManager({super.key});

  @override
  State<GalaConfigManager> createState() => _GalaConfigManagerState();
}

class _GalaConfigManagerState extends State<GalaConfigManager> {
  String? _selectedGalaId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GalaManagerProvider>(context, listen: false).loadGalas();
      Provider.of<AppConfigProvider>(
        context,
        listen: false,
      ).loadActiveGalaId().then((_) {
        if (mounted) {
          setState(() {
            _selectedGalaId = Provider.of<AppConfigProvider>(
              context,
              listen: false,
            ).activeGalaId;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GalaManagerProvider, AppConfigProvider>(
      builder: (context, galaProvider, appConfigProvider, child) {
        if (galaProvider.state == GalaManagerState.loading ||
            appConfigProvider.state == AppConfigState.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (galaProvider.state == GalaManagerState.error) {
          return Center(
            child: Text('Error loading galas: ${galaProvider.errorMessage}'),
          );
        }
        if (appConfigProvider.state == AppConfigState.error) {
          return Center(
            child: Text(
              'Error loading app config: ${appConfigProvider.errorMessage}',
            ),
          );
        }

        final List<Gala> allGalas = galaProvider.galas;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuración de Gala Activa',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                // Ensure the value is only set if it exists in the items list
                value: allGalas.any((g) => g.galaId == _selectedGalaId)
                    ? _selectedGalaId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Gala Activa',
                  border: OutlineInputBorder(),
                ),
                items: allGalas.map((gala) {
                  return DropdownMenuItem(
                    value: gala.galaId,
                    child: Text('Gala ${gala.galaNumber} (${gala.galaId})'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGalaId = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _selectedGalaId != null
                    ? () async {
                        final success = await appConfigProvider.setActiveGalaId(
                          _selectedGalaId!,
                        );
                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Gala activa actualizada con éxito!',
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(appConfigProvider.errorMessage),
                              ),
                            );
                          }
                        }
                      }
                    : null,
                child: const Text('Establecer como Gala Activa'),
              ),
            ],
          ),
        );
      },
    );
  }
}
