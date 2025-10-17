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
      // TODO: Get activeGalaId from somewhere (e.g., AppConfigProvider)
      // For now, using a placeholder. This will be implemented in Hito 5.
      Provider.of<PredictionProvider>(context, listen: false)
          .loadPredictionData('gala_01'); // Placeholder galaId
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
                  'Gala ${provider.activeGala!.galaNumber} - Apuestas Abiertas',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),

                // Sección "Eliminado"
                _buildSectionTitle('Eliminado'),
                _buildEliminatedSelection(provider),
                const SizedBox(height: 20),

                // Sección "Favorito"
                _buildSectionTitle('Favorito'),
                _buildFavoriteSelection(provider),
                const SizedBox(height: 20),

                // Sección "Propuestos a Nominado"
                _buildSectionTitle('Propuestos a Nominado (Selecciona 4)'),
                _buildNomineeProposalsSelection(provider),
                const SizedBox(height: 20),

                // Sección "Asigna a los Salvados" (condicional)
                if (provider.selectedNomineeProposals.length == 4)
                  _buildSavedBySelection(provider),
                const SizedBox(height: 20),

                // Botón "Guardar Predicción"
                Center(
                  child: ElevatedButton(
                    onPressed: provider.isValidPrediction()
                        ? () async {
                            final success = await provider.submitPrediction(currentUser.id!); 
                            if (!mounted) return; // Add this check
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Predicción guardada con éxito!')),
                              );
                              Navigator.of(context).pop(); // Go back to dashboard
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(provider.errorMessage)),
                              );
                            }
                          }
                        : null, // Disable button if prediction is not valid
                    child: const Text('Guardar Predicción'),
                  ),
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

    if (nominatedContestants.isEmpty) {
      return const Text('No hay concursantes nominados para esta gala.');
    }

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
        final isSelected = provider.selectedFavorite == contestant;
        return GestureDetector(
          onTap: () => provider.setSelectedFavorite(contestant),
          child: Card(
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.3) : null,
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
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.3) : null,
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
        Text('Selecciona quién es salvado por los profesores y quién por los compañeros de entre tus 4 propuestos.', style: Theme.of(context).textTheme.bodySmall,),
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

            return Card(
              elevation: isSavedByProfessors || isSavedByPeers ? 4 : 1,
              color: isSavedByProfessors || isSavedByPeers
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                  : null,
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
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.school,
                            color: isSavedByProfessors ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () => provider.setSavedByProfessors(contestant),
                          tooltip: 'Salvado por Profesores',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.people,
                            color: isSavedByPeers ? Colors.green : Colors.grey,
                          ),
                          onPressed: () => provider.setSavedByPeers(contestant),
                          tooltip: 'Salvado por Compañeros',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
