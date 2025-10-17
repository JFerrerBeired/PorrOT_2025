import 'package:flutter/foundation.dart';
import '../../domain/entities/contestant.dart';
import '../../domain/entities/gala.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/usecases/get_active_contestants_usecase.dart';
import '../../domain/usecases/get_gala_details_usecase.dart';
import '../../domain/usecases/submit_prediction_usecase.dart';
import '../providers/app_config_provider.dart'; // New import

enum PredictionState { initial, loading, loaded, error }

class PredictionProvider with ChangeNotifier {
  final GetActiveContestantsUseCase _getActiveContestantsUseCase;
  final GetGalaDetailsUseCase _getGalaDetailsUseCase;
  final SubmitPredictionUseCase _submitPredictionUseCase;
  final AppConfigProvider _appConfigProvider; // New dependency

  PredictionProvider(
    this._getActiveContestantsUseCase,
    this._getGalaDetailsUseCase,
    this._submitPredictionUseCase,
    this._appConfigProvider, // New dependency
  );

  PredictionState _state = PredictionState.initial;
  PredictionState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<Contestant> _activeContestants = [];
  List<Contestant> get activeContestants => _activeContestants;

  Gala? _activeGala;
  Gala? get activeGala => _activeGala;

  // Prediction selections
  Contestant? _selectedEliminated;
  Contestant? get selectedEliminated => _selectedEliminated;

  Contestant? _selectedFavorite;
  Contestant? get selectedFavorite => _selectedFavorite;

  final List<Contestant> _selectedNomineeProposals = [];
  List<Contestant> get selectedNomineeProposals => _selectedNomineeProposals;

  Contestant? _savedByProfessors;
  Contestant? get savedByProfessors => _savedByProfessors;

  Contestant? _savedByPeers;
  Contestant? get savedByPeers => _savedByPeers;

  Future<void> loadPredictionData(String galaId) async {
    try {
      _state = PredictionState.loading;
      notifyListeners();

      _activeContestants = await _getActiveContestantsUseCase();
      final activeGalaId = _appConfigProvider.activeGalaId;
      if (activeGalaId != null && activeGalaId.isNotEmpty) {
        _activeGala = await _getGalaDetailsUseCase(activeGalaId);
      } else {
        _activeGala = null; // No active gala set
      }

      // TODO: If there's an existing prediction for this user/gala, load it here.

      _state = PredictionState.loaded;
      notifyListeners();
    } catch (e) {
      _state = PredictionState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void setSelectedEliminated(Contestant contestant) {
    _selectedEliminated = contestant;
    notifyListeners();
  }

  void setSelectedFavorite(Contestant contestant) {
    _selectedFavorite = contestant;
    notifyListeners();
  }

  void toggleNomineeProposal(Contestant contestant) {
    if (_selectedNomineeProposals.contains(contestant)) {
      _selectedNomineeProposals.remove(contestant);
    } else {
      if (_selectedNomineeProposals.length < 4) {
        _selectedNomineeProposals.add(contestant);
      }
    }
    // Clear saved by professors/peers if they are no longer in the proposals
    if (!_selectedNomineeProposals.contains(_savedByProfessors)) {
      _savedByProfessors = null;
    }
    if (!_selectedNomineeProposals.contains(_savedByPeers)) {
      _savedByPeers = null;
    }
    notifyListeners();
  }

  void setSavedByProfessors(Contestant contestant) {
    if (_savedByProfessors == contestant) {
      _savedByProfessors = null; // Deselect if already selected
    } else if (_savedByPeers == contestant) {
      // If already saved by peers, swap roles
      _savedByPeers = _savedByProfessors;
      _savedByProfessors = contestant;
    } else {
      _savedByProfessors = contestant;
    }
    notifyListeners();
  }

  void setSavedByPeers(Contestant contestant) {
    if (_savedByPeers == contestant) {
      _savedByPeers = null; // Deselect if already selected
    } else if (_savedByProfessors == contestant) {
      // If already saved by professors, swap roles
      _savedByProfessors = _savedByPeers;
      _savedByPeers = contestant;
    } else {
      _savedByPeers = contestant;
    }
    notifyListeners();
  }

  bool isValidPrediction() {
    return _selectedEliminated != null &&
        _selectedFavorite != null &&
        _selectedNomineeProposals.length == 4 &&
        _savedByProfessors != null &&
        _savedByPeers != null &&
        _savedByProfessors != _savedByPeers; // Ensure different contestants for roles
  }

  Future<bool> submitPrediction(String userId) async {
    if (!isValidPrediction()) {
      _errorMessage = 'Por favor, completa todos los campos de la predicción.';
      _state = PredictionState.error;
      notifyListeners();
      return false;
    }

    if (_activeGala == null) {
      _errorMessage = 'No hay gala activa para realizar la predicción.';
      _state = PredictionState.error;
      notifyListeners();
      return false;
    }

    try {
      _state = PredictionState.loading;
      notifyListeners();

      final prediction = Prediction(
        userId: userId,
        galaId: _activeGala!.galaId!,
        favoriteId: _selectedFavorite!.contestantId!,
        eliminatedId: _selectedEliminated!.contestantId!,
        nomineeProposalIds: _selectedNomineeProposals
            .map((c) => c.contestantId!)
            .toList(),
        savedByProfessorsId: _savedByProfessors!.contestantId!,
        savedByPeersId: _savedByPeers!.contestantId!,
      );

      await _submitPredictionUseCase(prediction);
      _state = PredictionState.loaded; // Or a success state
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar la predicción: ${e.toString()}';
      _state = PredictionState.error;
      notifyListeners();
      return false;
    }
  }
}
