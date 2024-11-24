import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthController {
  String _formatRut(String rut) {
    String cleanRut = rut.replaceAll(RegExp(r'[.-]'), '');
    return cleanRut.replaceAll('K', 'k');
  }

  Future<Map<String, dynamic>> login(String rut, String numeroSocio) async {
    if (rut.isEmpty || numeroSocio.isEmpty) {
      return {
        'success': false,
        'message': 'Por favor, complete todos los campos.'
      };
    }

    String formattedRut = _formatRut(rut);
    int? socio = int.tryParse(numeroSocio);
    if (socio == null) {
      return {'success': false, 'message': 'Número de socio inválido.'};
    }

    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .where('rut', isEqualTo: formattedRut)
          .where('socio', isEqualTo: socio)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        var userData = userSnapshot.docs.first.data();
        User user = User.fromMap(userData);
        await _saveUserData(user);
        return {
          'success': true,
          'userType': 'Usuarios',
          'user': user,
        };
      }

      List<String> collections = ['Operador'];
      for (String collection in collections) {
        var querySnapshot = await FirebaseFirestore.instance
            .collection(collection)
            .where('rut', isEqualTo: formattedRut)
            .where('socio', isEqualTo: socio)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData = querySnapshot.docs.first.data();
          User user = User.fromMap(userData);
          await _saveUserData(user);
          return {
            'success': true,
            'userType': collection,
            'user': user,
          };
        }
      }

      return {
        'success': false,
        'message': 'Datos incorrectos, verifique su RUT o número de socio.'
      };
    } catch (e) {
      print('Error durante el login: $e');
      return {'success': false, 'message': 'Error al iniciar sesión: $e'};
    }
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(user.toMap()));
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');
      if (userDataString == null) return null;

      Map<String, dynamic> userDataMap = jsonDecode(userDataString);
      User user = User.fromMap(userDataMap);
      return user;
    } catch (e) {
      print('Error al obtener usuario actual: $e');
      return null;
    }
  }
}