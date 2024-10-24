import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController {
  String _formatRut(String rut) {
    String cleanRut = rut.replaceAll(RegExp(r'[.-]'), '');
    return cleanRut.replaceAll('K', 'k');
  }

  Future<Map<String, dynamic>> login(String rut, String numeroSocio) async {
    if (rut.isEmpty || numeroSocio.isEmpty) {
      return {'success': false, 'message': 'Por favor, complete todos los campos.'};
    }

    String formattedRut = _formatRut(rut);
    int? socio = int.tryParse(numeroSocio);

    if (socio == null) {
      return {'success': false, 'message': 'Número de socio inválido.'};
    }

    try {
      List<String> collections = ['Administrador', 'Operador', 'Usuarios'];

      for (String collection in collections) {
        var querySnapshot = await FirebaseFirestore.instance
            .collection(collection)
            .where('rut', isEqualTo: formattedRut)
            .where('socio', isEqualTo: socio)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData = querySnapshot.docs.first.data();
          String userName = userData['nombre'] ?? 'Usuario';
          return {
            'success': true,
            'userType': collection,
            'nombre': userName,
            'rut': formattedRut, // Add this line to return the RUT
          };
        }
      }

      return {'success': false, 'message': 'Datos incorrectos, verifique su RUT o número de socio.'};
    } catch (e) {
      return {'success': false, 'message': 'Error al iniciar sesión: $e'};
    }
  }
}