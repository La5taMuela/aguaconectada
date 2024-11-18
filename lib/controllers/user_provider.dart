import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  void setUser(User user) {
    _user = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Método para actualizar datos específicos del usuario
  void updateUserData(Map<String, dynamic> newData) {
    if (_user != null) {
      // Actualizar los campos necesarios
      if (newData.containsKey('nota')) {
        _user!.setNota = newData['nota'];
      }
      // Agregar más campos según sea necesario

      notifyListeners();
    }
  }
}