
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'validation_controller.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ValidationController _validationController = ValidationController();

  Future<int> getNextUserId() async {
    try {
      final usuarios = await _firestore
          .collection('Usuarios')
          .orderBy('idUsuario', descending: true)
          .limit(1)
          .get();

      return usuarios.docs.isNotEmpty ? usuarios.docs.first['idUsuario'] + 1 : 1;
    } catch (e) {
      throw Exception('Error al obtener el próximo ID de usuario.');
    }
  }

  Future<bool> verificarRutExistente(String rut) async {
    try {
      final result = await _firestore.collection('Usuarios').doc(rut).get();
      return result.exists;
    } catch (e) {
      throw Exception('Error al verificar la existencia del RUT.');
    }
  }

  Future<Map<String, String?>> addUserWithInitialConsumption(User user) async {
    final errorMessages = _validateUserData(user);

    if (errorMessages.isNotEmpty) return errorMessages;

    // Format the RUT by removing dots and dashes
    final formattedRut = user.rut.replaceAll(RegExp(r'[.-]'), '');

    if (await verificarRutExistente(formattedRut)) {
      errorMessages['rut'] = 'El RUT ya está registrado.';
      return errorMessages;
    }

    // Prepare the user data to save in Firestore
    final userData = {
      'idUsuario': user.idUsuario,
      'nombre': user.nombre,
      'segundoNombre': user.segundoNombre,
      'apellidoPaterno': user.apellidoPaterno,
      'apellidoMaterno': user.apellidoMaterno,
      'rut': formattedRut,
      'nota': user.nota,
      'socio': user.socio,
      'consumos': user.consumos,
    };

    try {
      await _firestore.collection('Usuarios').doc(formattedRut).set(userData);
      return {}; // Indicate success without error messages
    } catch (e) {
      return {'general': 'Error al agregar el usuario: $e'};
    }
  }


  Map<String, String?> _validateUserData(User user) {
    final errorMessages = <String, String?>{};

    if (!_validationController.isValidName(user.nombre)) {
      errorMessages['nombre'] = 'El nombre debe tener al menos 1 letra.';
    }
    if (!_validationController.isValidName(user.apellidoPaterno)) {
      errorMessages['apellidoPaterno'] = 'El apellido paterno debe tener al menos 3 letras.';
    }
    if (!_validationController.isValidRut(user.rut)) {
      errorMessages['rut'] = 'El RUT es obligatorio y no puede contener símbolos.';
    }

    return errorMessages;
  }

  Future<void> saveMonthlyConsumption(String rut, Map<String, int> consumptionData) async {
    if (!await verificarRutExistente(rut)) {
      throw Exception('El RUT no está registrado.');
    }

    try {
      final userRef = _firestore.collection('Usuarios').doc(rut);
      await userRef.update({
        for (var entry in consumptionData.entries)
          'consumos.${entry.key}': entry.value
      });
    } catch (e) {
      throw Exception('Error al guardar el consumo mensual: $e');
    }
  }

  Future<void> updateMonthlyConsumption(String rut, String mes, int newValue) async {
    if (!await verificarRutExistente(rut)) {
      throw Exception('El RUT no está registrado.');
    }

    try {
      final userRef = _firestore.collection('Usuarios').doc(rut);
      await userRef.update({'consumos.$mes': newValue});
    } catch (e) {
      throw Exception('Error al actualizar el consumo: $e');
    }
  }
}
