import 'package:cloud_firestore/cloud_firestore.dart';

class UserOperationException implements Exception {
  final String message;
  UserOperationException([this.message = '']);
}

class OperatorController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Validaciones de los datos del usuario
  bool _isValidName(String name) => name.length >= 3 && _hasNoSpecialCharacters(name);
  bool _isValidRut(String rut) => rut.length == 9 && _hasNoSpecialCharacters(rut);
  bool _hasNoSpecialCharacters(String value) => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value);

  /// Obtiene el próximo ID para los usuarios.
  Future<int> getNextUserId() async {
    try {
      final usuarios = await _firestore
          .collection('Usuarios')
          .orderBy('idUsuario', descending: true)
          .limit(1)
          .get();

      final int lastIdUsuario = usuarios.docs.isNotEmpty
          ? usuarios.docs.first['idUsuario']
          : 0;
      return lastIdUsuario + 1;
    } catch (e) {
      throw UserOperationException('Error al obtener el próximo ID de usuario.');
    }
  }

  /// Verifica si un RUT ya existe en la colección 'Usuarios'.
  Future<bool> verificarRutExistente(String rut) async {
    try {
      final result = await _firestore.collection('Usuarios').doc(rut).get();
      return result.exists;
    } catch (e) {
      throw UserOperationException('Error al verificar la existencia del RUT.');
    }
  }

  /// Agrega un usuario con consumos inicializados, si no existe.
  Future<Map<String, String?>> addUserWithInitialConsumption(Map<String, dynamic> userData) async {
    final nombre = userData['nombre'];
    final apellidoPaterno = userData['apellidoPaterno'];
    final rut = userData['rut'];

    // Mapa para almacenar mensajes de error
    Map<String, String?> errorMessages = {};

    if (!_isValidName(nombre)) {
      errorMessages['nombre'] = 'El nombre debe tener al menos 3 letras';
    }
    if (!_isValidName(apellidoPaterno)) {
      errorMessages['apellidoPaterno'] = 'El apellido paterno debe tener al menos 3 letras';
    }
    if (!_isValidRut(rut)) {
      errorMessages['rut'] = 'El RUT es obligatorio y no puede contener símbolos.';
    }

    // Si hay errores, devolver el mapa de mensajes
    if (errorMessages.isNotEmpty) {
      return errorMessages;
    }

    final existe = await verificarRutExistente(rut);
    if (existe) {
      errorMessages['rut'] = 'El RUT ya está registrado.';
      return errorMessages;
    }

    final userRef = _firestore.collection('Usuarios').doc(rut);

    // Obtiene el año actual
    final currentYear = DateTime.now().year;

    // Mapa para consumos inicializados con el año actual
    Map<String, dynamic> consumptionData = {
      currentYear.toString(): {
        'Enero': 0, 'Febrero': 0, 'Marzo': 0, 'Abril': 0,
        'Mayo': 0, 'Junio': 0, 'Julio': 0, 'Agosto': 0,
        'Septiembre': 0, 'Octubre': 0, 'Noviembre': 0, 'Diciembre': 0,
      }
    };
    userData['consumos'] = consumptionData;

    try {
      await userRef.set(userData);
      return {}; // Indica éxito sin mensajes de error
    } catch (e) {
      errorMessages['general'] = 'Error al agregar el usuario: $e';
      return errorMessages;
    }
  }

  /// Obtiene el último número de socio registrado.
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

  /// Guarda el consumo mensual de un usuario.
  Future<void> saveMonthlyConsumption(String rut, Map<String, int> consumptionData) async {
    final existe = await verificarRutExistente(rut);
    if (!existe) {
      throw UserOperationException('El RUT no está registrado.');
    }

    try {
      final userRef = _firestore.collection('Usuarios').doc(rut);
      Map<String, dynamic> updateData = {
        for (var entry in consumptionData.entries)
          'consumos.${entry.key}': entry.value
      };
      await userRef.update(updateData);
    } catch (e) {
      throw UserOperationException('Error al guardar el consumo mensual: $e');
    }
  }

  /// Obtiene el consumo mensual de un usuario.
  Future<Map<String, int>> getMonthlyConsumption(String rut) async {
    try {
      final userDoc = await _firestore.collection('Usuarios').doc(rut).get();

      if (!userDoc.exists) {
        throw UserOperationException('El usuario no existe.');
      }

      final consumptionData = userDoc.data()?['consumos'] as Map<String, dynamic>? ?? {};
      return consumptionData.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      throw UserOperationException('Error al obtener el consumo mensual: $e');
    }
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

  /// Elimina todos los consumos de un usuario.
  Future<void> deleteAllConsumos(String rut) async {
    final existe = await verificarRutExistente(rut);
    if (!existe) {
      throw UserOperationException('El RUT no está registrado.');
    }

    try {
      final userRef = _firestore.collection('Usuarios').doc(rut);
      Map<String, dynamic> resetConsumptionData = {
        'Enero': 0, 'Febrero': 0, 'Marzo': 0, 'Abril': 0,
        'Mayo': 0, 'Junio': 0, 'Julio': 0, 'Agosto': 0,
        'Septiembre': 0, 'Octubre': 0, 'Noviembre': 0, 'Diciembre': 0,
      };
      await userRef.update({'consumos': resetConsumptionData});
    } catch (e) {
      throw UserOperationException('Error al eliminar los consumos: $e');
    }
  }
}
