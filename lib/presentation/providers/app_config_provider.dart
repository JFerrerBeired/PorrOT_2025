import 'package:flutter/foundation.dart';
import '../../domain/usecases/get_active_gala_id_usecase.dart';
import '../../domain/usecases/set_active_gala_id_usecase.dart';

enum AppConfigState { initial, loading, loaded, error }

class AppConfigProvider with ChangeNotifier {
  final GetActiveGalaIdUseCase _getActiveGalaIdUseCase;
  final SetActiveGalaIdUseCase _setActiveGalaIdUseCase;

  AppConfigProvider(this._getActiveGalaIdUseCase, this._setActiveGalaIdUseCase);

  AppConfigState _state = AppConfigState.initial;
  AppConfigState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String? _activeGalaId;
  String? get activeGalaId => _activeGalaId;

  Future<void> loadActiveGalaId() async {
    try {
      _state = AppConfigState.loading;
      notifyListeners();
      _activeGalaId = await _getActiveGalaIdUseCase();
      _state = AppConfigState.loaded;
      notifyListeners();
    } catch (e) {
      _state = AppConfigState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> setActiveGalaId(String galaId) async {
    try {
      _state = AppConfigState.loading;
      notifyListeners();
      await _setActiveGalaIdUseCase(galaId);
      _activeGalaId = galaId;
      _state = AppConfigState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AppConfigState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
