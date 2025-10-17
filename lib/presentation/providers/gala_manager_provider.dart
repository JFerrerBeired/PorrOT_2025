import 'package:flutter/foundation.dart';
import '../../domain/entities/gala.dart';
import '../../domain/usecases/get_all_galas_usecase.dart';

enum GalaManagerState { initial, loading, loaded, error }

class GalaManagerProvider with ChangeNotifier {
  final GetAllGalasUseCase _getAllGalasUseCase;

  GalaManagerProvider(this._getAllGalasUseCase);

  GalaManagerState _state = GalaManagerState.initial;
  GalaManagerState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<Gala> _galas = [];
  List<Gala> get galas => _galas;

  Future<void> loadGalas() async {
    try {
      _state = GalaManagerState.loading;
      notifyListeners();
      _galas = await _getAllGalasUseCase();
      _state = GalaManagerState.loaded;
      notifyListeners();
    } catch (e) {
      _state = GalaManagerState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
