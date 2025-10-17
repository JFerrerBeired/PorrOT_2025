import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';

class SessionProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearSession() {
    _currentUser = null;
    notifyListeners();
  }
}
