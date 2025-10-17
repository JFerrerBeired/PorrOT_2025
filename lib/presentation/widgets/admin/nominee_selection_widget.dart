import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:porrot_2025/data/repositories/contestant_repository_impl.dart';
import 'package:porrot_2025/data/repositories/gala_repository_impl.dart';
import 'package:porrot_2025/domain/entities/contestant.dart';
import 'package:porrot_2025/domain/usecases/update_gala_nominees_usecase.dart';

class NomineeSelectionWidget extends StatefulWidget {
  final String galaId;

  const NomineeSelectionWidget({super.key, required this.galaId});

  @override
  _NomineeSelectionWidgetState createState() => _NomineeSelectionWidgetState();
}

class _NomineeSelectionWidgetState extends State<NomineeSelectionWidget> {
  List<Contestant> _activeContestants = [];
  final List<String> _selectedContestantIds = [];
  bool _isLoading = true;

  late final UpdateGalaNomineesUseCase _updateGalaNomineesUseCase;

  @override
  void initState() {
    super.initState();
    final galaRepository = GalaRepositoryImpl(FirebaseFirestore.instance);
    _updateGalaNomineesUseCase = UpdateGalaNomineesUseCase(galaRepository);
    _loadActiveContestants();
  }

  Future<void> _loadActiveContestants() async {
    try {
      // In a real app, use a use case for this
      final contestantRepository = ContestantRepositoryImpl(
        FirebaseFirestore.instance,
      );
      final allContestants = await contestantRepository.getAllContestants();
      setState(() {
        _activeContestants = allContestants
            .where((c) => c.status == ContestantStatus.active)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load contestants: $e')),
        );
      }
    }
  }

  void _onContestantSelected(bool? selected, String contestantId) {
    setState(() {
      if (selected == true) {
        _selectedContestantIds.add(contestantId);
      } else {
        _selectedContestantIds.remove(contestantId);
      }
    });
  }

  void _saveNominations() {
    if (_selectedContestantIds.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select exactly 2 nominees.')),
      );
      return;
    }

    _updateGalaNomineesUseCase
        .execute(widget.galaId, _selectedContestantIds)
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nominations saved successfully!')),
          );
          Navigator.of(context).pop();
        })
        .catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save nominations: $e')),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Nominees'),
      content: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ListBody(
                children: _activeContestants.map((contestant) {
                  return CheckboxListTile(
                    title: Text(contestant.name),
                    value: _selectedContestantIds.contains(
                      contestant.contestantId,
                    ),
                    onChanged: (bool? selected) {
                      _onContestantSelected(selected, contestant.contestantId!);
                    },
                  );
                }).toList(),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveNominations, child: const Text('Save')),
      ],
    );
  }
}
