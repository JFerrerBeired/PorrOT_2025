import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/contestant.dart';
import '../providers/prediction_provider.dart';
import '../providers/session_provider.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  static const routeName = '/prediction';

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = Provider.of<SessionProvider>(context, listen: false).currentUser;
      if (currentUser != null) {
        Provider.of<PredictionProvider>(context, listen: false)
            .loadPredictionData(currentUser.id!); // Pass userId
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final currentUser = sessionProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('No hay usuario seleccionado. Por favor, inicia sesión.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Predicción'),
      ),
      body: Consumer<PredictionProvider>(
        builder: (context, provider, child) {
          if (provider.state == PredictionState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.state == PredictionState.error) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }
          if (provider.activeGala == null) {
            return const Center(
                child: Text('No hay gala activa para predecir.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gala ${provider.activeGala?.galaNumber ?? 'N/A'} - Apuestas Abiertas',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),

                // Sección "Eliminado"
                _buildSectionTitle('Eliminado'),
                // Only show if there are nominated contestants
                if (provider.activeGala!.nominatedContestants.isNotEmpty)
                  _buildEliminatedSelection(provider)
                else
                  const Text('No hay concursantes nominados para esta gala.'),
                const SizedBox(height: 20),

                // Sección "Favorito"
                _buildSectionTitle('Favorito'),
                _buildFavoriteSelection(provider),
                const SizedBox(height: 20),

                // Sección "Propuestos a Nominado"
                _buildSectionTitle('Propuestos a Nominado (Selecciona hasta 4)'), // Changed text
                _buildNomineeProposalsSelection(provider),
                const SizedBox(height: 20),

                // Sección "Asigna a los Salvados" (condicional)
                // Only show if 4 nominees are selected
                if (provider.selectedNomineeProposals.length == 4)
                  _buildSavedBySelection(provider),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón "Guardar Borrador"
                    ElevatedButton(
                      onPressed: () async {
                        final success = await provider.savePrediction(currentUser.id!, isFinalSubmission: false);
                        if (!mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Borrador guardado con éxito!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.errorMessage)),
                          );
                        }
                      },
                      child: const Text('Guardar Borrador'),
                    ),

                    // Botón "Guardar Predicción" (Envío Final)
                    ElevatedButton(
                      onPressed: provider.isValidPredictionForSubmission()
                          ? () async {
                              final success = await provider.savePrediction(currentUser.id!, isFinalSubmission: true);
                              if (!mounted) return;
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Predicción enviada con éxito!')),
                                );
                                Navigator.of(context).pop(); // Go back to dashboard
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(provider.errorMessage)),
                                );
                              }
                            }
                          : null, // Disable button if prediction is not valid for submission
                      child: const Text('Enviar Predicción'), // Changed text
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildEliminatedSelection(PredictionProvider provider) {
    final nominatedContestants = provider.activeGala?.nominatedContestants
            .map((id) => provider.activeContestants
                .firstWhere((c) => c.contestantId == id))
            .toList() ??
        [];

    // This check is now handled in the main build method
    // if (nominatedContestants.isEmpty) {
    //   return const Text('No hay concursantes nominados para esta gala.');
    // }

    return Column(
      children: nominatedContestants.map((contestant) {
        return RadioListTile<Contestant>(
          title: Text(contestant.name),
          value: contestant,
          groupValue: provider.selectedEliminated,
          onChanged: (Contestant? value) {
            if (value != null) {
              provider.setSelectedEliminated(value);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildFavoriteSelection(PredictionProvider provider) {
    // Filter out nominated contestants from the list of active contestants for the favorite selection
    final List<String> nominatedIds = provider.activeGala?.nominatedContestants ?? [];
    final List<Contestant> selectableContestants = provider.activeContestants
        .where((contestant) => !nominatedIds.contains(contestant.contestantId))
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: selectableContestants.length,
      itemBuilder: (context, index) {
        final contestant = selectableContestants[index];
        final isSelected = provider.selectedFavorite == contestant;
        return GestureDetector(
          onTap: () => provider.setSelectedFavorite(contestant),
          child: Card(
            color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.3) : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TODO: Add actual image loading
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(contestant.name[0]),
                ),
                const SizedBox(height: 8),
                Text(
                  contestant.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNomineeProposalsSelection(PredictionProvider provider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: provider.activeContestants.length,
      itemBuilder: (context, index) {
        final contestant = provider.activeContestants[index];
        final isSelected = provider.selectedNomineeProposals.contains(contestant);
        return GestureDetector(
          onTap: () => provider.toggleNomineeProposal(contestant),
          child: Card(
            color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.3) : null,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      child: Text(contestant.name[0]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      contestant.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                if (isSelected)
                  const Positioned(
                    top: 5,
                    right: 5,
                    child: Icon(Icons.check_circle, color: Colors.green),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedBySelection(PredictionProvider provider) {
    final selectedNominees = provider.selectedNomineeProposals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Asigna a los Salvados'),
        Text('Toca un concursante para asignarle un rol de salvado.', style: Theme.of(context).textTheme.bodySmall,),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns for easier selection
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: selectedNominees.length,
          itemBuilder: (context, index) {
            final contestant = selectedNominees[index];
            final isSavedByProfessors = provider.savedByProfessors == contestant;
            final isSavedByPeers = provider.savedByPeers == contestant;

            Color? cardColor;
            String? roleText;
            if (isSavedByProfessors) {
              cardColor = Colors.blue.withValues(alpha: 0.2);
              roleText = 'Profesores';
            } else if (isSavedByPeers) {
              cardColor = Colors.green.withValues(alpha: 0.2);
              roleText = 'Compañeros';
            }

            return GestureDetector(
              onTap: () => _showRoleSelectionDialog(context, provider, contestant),
              child: Card(
                elevation: isSavedByProfessors || isSavedByPeers ? 4 : 1,
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade200,
                        child: Text(contestant.name[0]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contestant.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11),
                      ),
                      if (roleText != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Salvado por $roleText',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSavedByProfessors ? Colors.blue : Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showRoleSelectionDialog(BuildContext context, PredictionProvider provider, Contestant contestant) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Asignar rol a ${contestant.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Salvado por Profesores'),
                leading: const Icon(Icons.school),
                onTap: () {
                  provider.setSavedByProfessors(contestant);
                  Navigator.of(dialogContext).pop();
                },
              ),
              ListTile(
                title: const Text('Salvado por Compañeros'),
                leading: const Icon(Icons.people),
                onTap: () {
                  provider.setSavedByPeers(contestant);
                  Navigator.of(dialogContext).pop();
                },
              ),
              ListTile(
                title: const Text('Ninguno'),
                leading: const Icon(Icons.cancel),
                onTap: () {
                  // Clear both roles if this contestant had them
                  if (provider.savedByProfessors == contestant) {
                    provider.setSavedByProfessors(contestant); // Toggles off
                  }
                  if (provider.savedByPeers == contestant) {
                    provider.setSavedByPeers(contestant); // Toggles off
                  }
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
