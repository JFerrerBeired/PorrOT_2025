import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../domain/entities/contestant.dart';
import '../providers/prediction_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/voting/contestant_card.dart';
import '../widgets/voting/unified_nomination_panel.dart';

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
      final currentUser = Provider.of<SessionProvider>(
        context,
        listen: false,
      ).currentUser;
      if (currentUser != null) {
        Provider.of<PredictionProvider>(
          context,
          listen: false,
        ).loadPredictionData(currentUser.id!);
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
      appBar: AppBar(title: const Text('Tu Predicción')),
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
              child: Text('No hay gala activa para predecir.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Gala ${provider.activeGala?.galaNumber ?? 'N/A'} - Apuestas Abiertas',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Sección "Eliminado"
                _buildSectionTitle('Elige al Eliminado'),
                if (provider.activeGala!.nominatedContestants.isNotEmpty)
                  _buildEliminatedSelection(context, provider)
                else
                  const Text('No hay concursantes nominados para esta gala.'),
                const SizedBox(height: 24),

                // Sección "Favorito"
                _buildSectionTitle('Elige al Favorito'),
                _buildFavoriteSelection(context, provider),
                const SizedBox(height: 24),

                // Sección "Propuestos a Nominado"
                _buildSectionTitle('Elige 4 Propuestos a Nominado'),
                const UnifiedNominationPanel(),
                const SizedBox(height: 32),

                // Botones de acción
                _buildActionButtons(context, provider, currentUser.id!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildEliminatedSelection(
    BuildContext context,
    PredictionProvider provider,
  ) {
    final nominatedContestants =
        provider.activeGala?.nominatedContestants
            .map(
              (id) => provider.activeContestants.firstWhereOrNull(
                (c) => c.contestantId == id,
              ),
            )
            .nonNulls
            .toList() ??
        [];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: nominatedContestants.length,
      itemBuilder: (context, index) {
        final contestant = nominatedContestants[index];
        return ContestantCard(
          contestant: contestant,
          isSelected: provider.selectedEliminated == contestant,
          onTap: () => provider.setSelectedEliminated(contestant),
        );
      },
    );
  }

  Widget _buildFavoriteSelection(
    BuildContext context,
    PredictionProvider provider,
  ) {
    final List<String> nominatedIds =
        provider.activeGala?.nominatedContestants ?? [];
    final List<Contestant> selectableContestants = provider.activeContestants
        .where((c) => !nominatedIds.contains(c.contestantId))
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: selectableContestants.length,
      itemBuilder: (context, index) {
        final contestant = selectableContestants[index];
        return ContestantCard(
          contestant: contestant,
          isSelected: provider.selectedFavorite == contestant,
          onTap: () => provider.setSelectedFavorite(contestant),
        );
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    PredictionProvider provider,
    String userId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: provider.isValidPredictionForSubmission()
              ? () async {
                  final success = await provider.savePrediction(
                    userId,
                    isFinalSubmission: true,
                  );
                  if (!mounted) return;
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Predicción enviada con éxito!'),
                      ),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(provider.errorMessage)),
                    );
                  }
                }
              : null,
          child: const Text('Enviar Predicción Final'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () async {
            final success = await provider.savePrediction(
              userId,
              isFinalSubmission: false,
            );
            if (!mounted) return;
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Borrador guardado con éxito!')),
              );
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(provider.errorMessage)));
            }
          },
          child: const Text('Guardar como Borrador'),
        ),
      ],
    );
  }
}
