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

        print('Raw user data from Firestore: $userData'); // Add this line for debugging

        User user = User.fromMap(userData);
        print('Parsed User object: ${user.toMap()}'); // Add this line for debugging

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(userData));

        return {
          'success': true,
          'userType': 'Usuarios',
          'userData': user,
          'nombre': user.nombreCompleto(),
          'rut': formattedRut,
        };


      }

      // Si no es un usuario normal, verificamos las otras colecciones
      List<String> collections = ['Administrador', 'Operador'];

      for (String collection in collections) {
        var querySnapshot = await FirebaseFirestore.instance
            .collection(collection)
            .where('rut', isEqualTo: formattedRut)
            .where('socio', isEqualTo: socio)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData = querySnapshot.docs.first.data();
          User user = User.fromMap(userData);

          // Almacena todos los datos del usuario en SharedPreferences como JSON
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userData', jsonEncode(userData));

          return {
            'success': true,
            'userType': collection,
            'userData': user,
            'nombre': user.nombreCompleto(),
            'rut': formattedRut,
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

  // Método para obtener los datos del usuario actual
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userDataString = prefs.getString('userData');

      if (userDataString == null) return null;

      Map<String, dynamic> userDataMap = jsonDecode(userDataString);
      print('Retrieved user data from SharedPreferences: $userDataMap'); // Add this line for debugging

      User user = User.fromMap(userDataMap);
      print('Parsed User object: ${user.toMap()}'); // Add this line for debugging

      return user;
    } catch (e) {
      print('Error al obtener usuario actual: $e');
      return null;
    }
  }
}