import 'package:cloud_firestore/cloud_firestore.dart';

class UserOperationException implements Exception {
  final String message;
  UserOperationException([this.message = '']);
}

class OperatorController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Validations for user data
  bool _isValidName(String name) => name.length >= 1 && _hasNoSpecialCharacters(name);
  bool _isValidRut(String rut) => rut.length == 9 && _hasNoSpecialCharacters(rut);
  bool _hasNoSpecialCharacters(String value) => RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚÑñ0-9]+$').hasMatch(value);

  /// Helper to verify if RUT exists and throw an exception if not
  Future<void> _checkRutExists(String rut) async {
    if (!await verificarRutExistente(rut)) {
      throw UserOperationException('El RUT no está registrado.');
    }
  }

  /// Retrieves the next user ID
  Future<int> getNextUserId() async {
    try {
      final usuarios = await _firestore
          .collection('Usuarios')
          .orderBy('idUsuario', descending: true)
          .limit(1)
          .get();

      return usuarios.docs.isNotEmpty ? usuarios.docs.first['idUsuario'] + 1 : 1;
    } catch (e) {
      throw UserOperationException('Error al obtener el próximo ID de usuario.');
    }
  }

  /// Checks if a RUT already exists in the 'Usuarios' collection
  Future<bool> verificarRutExistente(String rut) async {
    try {
      final result = await _firestore.collection('Usuarios').doc(rut).get();
      return result.exists;
    } catch (e) {
      throw UserOperationException('Error al verificar la existencia del RUT.');
    }
  }

  /// Validate user data and return error messages if any
  Map<String, String?> _validateUserData(Map<String, dynamic> userData) {
    final errorMessages = <String, String?>{};

    if (!_isValidName(userData['nombre'])) {
      errorMessages['nombre'] = 'El nombre debe tener al menos 1 letra.';
    }
    if (!_isValidName(userData['apellidoPaterno'])) {
      errorMessages['apellidoPaterno'] = 'El apellido paterno debe tener al menos 3 letras.';
    }
    if (!_isValidRut(userData['rut'])) {
      errorMessages['rut'] = 'El RUT es obligatorio y no puede contener símbolos.';
    }

    return errorMessages;
  }

  /// Adds a user with initialized consumptions if they don't exist
  Future<Map<String, String?>> addUserWithInitialConsumption(Map<String, dynamic> userData) async {
    final errorMessages = _validateUserData(userData);

    if (errorMessages.isNotEmpty) return errorMessages;

    // Formatear el RUT eliminando puntos y guiones
    final rut = userData['rut'].replaceAll(RegExp(r'[.-]'), '');
    userData['rut'] = rut;

    if (await verificarRutExistente(rut)) {
      errorMessages['rut'] = 'El RUT ya está registrado.';
      return errorMessages;
    }

    // Obtiene el año actual
    final currentYear = DateTime.now().year;

    // Mapa para consumos inicializados con el año actual
    Map<String, dynamic> consumptionData = {
      'consumos': {
        currentYear.toString(): {
          'Enero': 0, 'Febrero': 0, 'Marzo': 0, 'Abril': 0,
          'Mayo': 0, 'Junio': 0, 'Julio': 0, 'Agosto': 0,
          'Septiembre': 0, 'Octubre': 0, 'Noviembre': 0, 'Diciembre': 0,
        }
      }
    };
    userData['consumos'] = consumptionData;

    try {
      await _firestore.collection('Usuarios').doc(rut).set(userData);
      return {}; // Indicate success without error messages
    } catch (e) {
      return {'general': 'Error al agregar el usuario: $e'};
    }
  }


  /// Retrieves the last registered member number
  Future<int> getUltimoSocio() async {
    try {
      final result = await _firestore
          .collection('Usuarios')
          .orderBy('socio', descending: true)
          .limit(1)
          .get();

      return result.docs.isNotEmpty ? result.docs.first['socio'] : 0;
    } catch (e) {
      throw UserOperationException('Error al obtener el último número de socio.');
    }
  }

  /// Saves monthly consumption for a user
  /// Saves monthly consumption for a user
  Future<void> saveMonthlyConsumption(String rut, Map<String, int> consumptionData) async {
    final existe = await verificarRutExistente(rut);
    if (!existe) {
      throw UserOperationException('El RUT no está registrado.');
    }

    // Obtiene el año actual
    final currentYear = DateTime.now().year.toString();

    try {
      final userRef = _firestore.collection('Usuarios').doc(rut);
      Map<String, dynamic> updateData = {
        for (var entry in consumptionData.entries)
          'consumos.$currentYear.${entry.key}': entry.value
      };
      await userRef.update(updateData);
    } catch (e) {
      throw UserOperationException('Error al guardar el consumo mensual: $e');
    }
  }


  /// Retrieves monthly consumption for a user
  /// Retrieves monthly consumption for a user
  Future<Map<String, int>> getMonthlyConsumption(String rut) async {
    final consumptionData = <String, int>{};

    try {
      // Fetch the user's document from the Usuarios collection
      final userDoc = await _firestore.collection('Usuarios').doc(rut).get();

      // Check if the document exists
      if (!userDoc.exists) {
        throw UserOperationException('El usuario no existe.');
      }

      // Get the consumption data
      final data = userDoc.data()?['consumos'] as Map<String, dynamic>? ?? {};
      final currentYear = DateTime.now().year.toString(); // Get the current year

      // Retrieve monthly consumption for the current year
      final monthlyData = data[currentYear] as Map<String, dynamic>? ?? {};
      for (var month in ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo',
        'Junio', 'Julio', 'Agosto', 'Septiembre',
        'Octubre', 'Noviembre', 'Diciembre']) {
        consumptionData[month] = (monthlyData[month] as int?) ?? 0; // Ensure it's an int
      }
    } catch (e) {
      throw UserOperationException('Error al obtener el consumo mensual: $e');
    }

    return consumptionData;
  }




  /// Actualiza el consumo de un mes específico.
  Future<void> updateMonthlyConsumption(String rut, String mes, int newValue) async {
    final existe = await verificarRutExistente(rut);
    if (!existe) {
      throw UserOperationException('El RUT no está registrado.');
    }

    try {
      final userRef = _firestore.collection('Usuarios').doc(rut);
      await userRef.update({'consumos.$mes': newValue});
    } catch (e) {
      throw UserOperationException('Error al actualizar el consumo: $e');
    }
  }


  /// Deletes all consumptions for a user
  Future<void> deleteAllConsumos(String rut) async {
    await _checkRutExists(rut);

    try {
      final userRef = _firestore.collection('Usuarios').doc(rut);
      await userRef.update({
        'consumos': {
          'Enero': 0, 'Febrero': 0, 'Marzo': 0, 'Abril': 0,
          'Mayo': 0, 'Junio': 0, 'Julio': 0, 'Agosto': 0,
          'Septiembre': 0, 'Octubre': 0, 'Noviembre': 0, 'Diciembre': 0,
        }
      });
    } catch (e) {
      throw UserOperationException('Error al eliminar los consumos: $e');
    }
  }
  // Method to update notification state
  Future<void> updateNotificationState(String documentId) async {
    await _firestore.collection('reportes').doc(documentId).update({
      'notificationState': true,
    });
  }

  // Stream to fetch only unseen notifications
  Stream<QuerySnapshot> get reportStream {
    return _firestore.collection('reportes')
        .where('notificationState', isEqualTo: false)
        .snapshots();
  }

}
