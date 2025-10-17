import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:porrot_2025/data/repositories/gala_repository_impl.dart';
import 'package:porrot_2025/data/repositories/prediction_repository_impl.dart';
import 'package:porrot_2025/data/repositories/user_repository_impl.dart';
import 'package:porrot_2025/domain/entities/gala.dart';
import 'package:porrot_2025/domain/repositories/gala_repository.dart';
import 'package:porrot_2025/domain/services/score_calculator.dart';
import 'package:porrot_2025/domain/usecases/calculate_scores_usecase.dart';

class AdminGalaResultsScreen extends StatefulWidget {
  static const routeName = '/admin-gala-results';

  final Gala gala;

  const AdminGalaResultsScreen({super.key, required this.gala});

  @override
  _AdminGalaResultsScreenState createState() => _AdminGalaResultsScreenState();
}

class _AdminGalaResultsScreenState extends State<AdminGalaResultsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final _favoriteIdController = TextEditingController();
  final _eliminatedIdController = TextEditingController();
  final _nomineeProposalIdsController = TextEditingController();
  final _savedByProfessorsIdController = TextEditingController();
  final _savedByPeersIdController = TextEditingController();

  late final GalaRepository _galaRepository;
  late final CalculateScoresUseCase _calculateScoresUseCase;

  @override
  void initState() {
    super.initState();
    _galaRepository = GalaRepositoryImpl(FirebaseFirestore.instance);
    final predictionRepository =
        PredictionRepositoryImpl(FirebaseFirestore.instance);
    final userRepository = UserRepositoryImpl(FirebaseFirestore.instance);
    final scoreCalculator = ScoreCalculator();
    _calculateScoresUseCase = CalculateScoresUseCase(
      _galaRepository,
      predictionRepository,
      userRepository,
      scoreCalculator,
    );

    // Pre-fill the form with existing results, if any
    _favoriteIdController.text = widget.gala.results['favoriteId'] ?? '';
    _eliminatedIdController.text = widget.gala.results['eliminatedId'] ?? '';
    _nomineeProposalIdsController.text =
        (widget.gala.results['nomineeProposalIds'] as List<dynamic>?)
                ?.join(', ') ??
            '';
    _savedByProfessorsIdController.text =
        widget.gala.results['savedByProfessorsId'] ?? '';
    _savedByPeersIdController.text =
        widget.gala.results['savedByPeersId'] ?? '';
  }

  void _saveResults() async {
    if (_formKey.currentState!.validate()) {
      final results = {
        'favoriteId': _favoriteIdController.text,
        'eliminatedId': _eliminatedIdController.text,
        'nomineeProposalIds': _nomineeProposalIdsController.text
            .split(',')
            .map((e) => e.trim())
            .toList(),
        'savedByProfessorsId': _savedByProfessorsIdController.text,
        'savedByPeersId': _savedByPeersIdController.text,
      };

      final updatedGala = Gala(
        galaId: widget.gala.galaId,
        galaNumber: widget.gala.galaNumber,
        date: widget.gala.date,
        nominatedContestants: widget.gala.nominatedContestants,
        results: results,
      );

      try {
        await _galaRepository.updateGala(updatedGala);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Results saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save results: $e')),
        );
      }
    }
  }

  void _calculateScores() async {
    try {
      await _calculateScoresUseCase.execute(widget.gala.galaId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scores calculated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to calculate scores: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gala ${widget.gala.galaNumber} Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _favoriteIdController,
                decoration: const InputDecoration(labelText: 'Favorite ID'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an ID' : null,
              ),
              TextFormField(
                controller: _eliminatedIdController,
                decoration: const InputDecoration(labelText: 'Eliminated ID'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an ID' : null,
              ),
              TextFormField(
                controller: _nomineeProposalIdsController,
                decoration: const InputDecoration(
                    labelText: 'Nominee Proposal IDs (comma-separated)'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter IDs' : null,
              ),
              TextFormField(
                controller: _savedByProfessorsIdController,
                decoration:
                    const InputDecoration(labelText: 'Saved by Professors ID'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an ID' : null,
              ),
              TextFormField(
                controller: _savedByPeersIdController,
                decoration:
                    const InputDecoration(labelText: 'Saved by Peers ID'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an ID' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveResults,
                child: const Text('Save Results'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateScores,
                child: const Text('Calculate Scores'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}