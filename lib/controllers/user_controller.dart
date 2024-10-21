import 'package:flutter/material.dart';
import 'package:aguaconectada/models/user.dart';

class UserController extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  // Método para actualizar los datos del usuario
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}
