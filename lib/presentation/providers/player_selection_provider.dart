import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/create_user_usecase.dart';

enum PlayerSelectionState { initial, loading, loaded, error }

class PlayerSelectionProvider with ChangeNotifier {
  final GetUsersUseCase _getUsersUseCase;
  final CreateUserUseCase _createUserUseCase;

  PlayerSelectionProvider(this._getUsersUseCase, this._createUserUseCase);

  PlayerSelectionState _state = PlayerSelectionState.initial;
  PlayerSelectionState get state => _state;

  List<User> _users = [];
  List<User> get users => _users;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    try {
      _state = PlayerSelectionState.loading;
      notifyListeners();
      _users = await _getUsersUseCase.call();
      _state = PlayerSelectionState.loaded;
      notifyListeners();
    } catch (e) {
      _state = PlayerSelectionState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<User?> createUser(String displayName) async {
    try {
      final newUser = await _createUserUseCase.call(displayName: displayName);
      await fetchUsers(); 
      return newUser;
    } catch (e) {
      _errorMessage = e.toString();
      _state = PlayerSelectionState.error;
      notifyListeners();
      return null;
    }
  }
}
