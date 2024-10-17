import 'package:flutter/material.dart';
import 'package:aguaconectada/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserController extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  // Método para actualizar los datos del usuario
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}
