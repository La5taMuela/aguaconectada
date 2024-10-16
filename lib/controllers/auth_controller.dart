import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController {
  Future<Map<String, dynamic>> login(String rut, String numeroSocio) async {
    if (rut.isEmpty || numeroSocio.isEmpty) {
      return {'success': false, 'message': 'Por favor, complete todos los campos.'};
    }

    int? socio = int.tryParse(numeroSocio);

    if (socio == null) {
      return {'success': false, 'message': 'Número de socio inválido.'};
    }

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .where('rut', isEqualTo: rut)
          .where('socio', isEqualTo: socio)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data();
        String userType = userData['tipo'] ?? 'usuario';
        return {'success': true, 'userType': userType};
      } else {
        return {'success': false, 'message': 'Datos incorrectos, verifique su RUT o número de socio.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error al iniciar sesión: $e'};
    }
  }
}