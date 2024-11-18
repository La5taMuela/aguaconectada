import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import 'validation_controller.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';

class UserController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ValidationController _validationController = ValidationController();

  Future<int> getNextUserId() async {
    try {
      final usuarios = await _firestore
          .collection('Usuarios')
          .orderBy('idUsuario', descending: true)
          .limit(1)
          .get();

      return usuarios.docs.isNotEmpty
          ? usuarios.docs.first['idUsuario'] + 1
          : 1;
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

    // Get the current year
    final now = DateTime.now();
    final currentYear = now.year.toString();

    // Create the montosMensuales structure with the months
    final montosMensuales = {
      currentYear: {
        'Enero': 0,
        'Febrero': 0,
        'Marzo': 0,
        'Abril': 0,
        'Mayo': 0,
        'Junio': 0,
        'Julio': 0,
        'Agosto': 0,
        'Septiembre': 0,
        'Octubre': 0,
        'Noviembre': 0,
        'Diciembre': 0,
      }
    };

    // Create the historialPagos structure with months as maps containing 'valor' and 'timestamp'
    final historialPagos = {
      currentYear: {
        'Enero': {'valor': 0, 'fecha': 0},
        'Febrero': {'valor': 0, 'fecha': 0},
        'Marzo': {'valor': 0, 'fecha': 0},
        'Abril': {'valor': 0, 'fecha': 0},
        'Mayo': {'valor': 0, 'fecha': 0},
        'Junio': {'valor': 0, 'fecha': 0},
        'Julio': {'valor': 0, 'fecha': 0},
        'Agosto': {'valor': 0, 'fecha': 0},
        'Septiembre': {'valor': 0, 'fecha': 0},
        'Octubre': {'valor': 0, 'fecha': 0},
        'Noviembre': {'valor': 0, 'fecha': 0},
        'Diciembre': {'valor': 0, 'fecha': 0},
      }
    };

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
      'montosMensuales':
      montosMensuales, // Add montosMensuales with just months
      'historialPagos':
      historialPagos, // Add historialPagos with valor and timestamp
    };

    try {
      await _firestore.collection('Usuarios').doc(formattedRut).set(userData);
      return {}; // Indicate success without error messages
    } catch (e) {
      return {'general': 'Error al agregar el usuario: $e'};
    }
  }

  Map<String, String?> _validateUserData(User user) {
    final validations = {
      'nombre': _validationController.isValidName(user.nombre)
          ? null
          : 'El nombre debe tener al menos 1 letra.',
      'apellidoPaterno': _validationController.isValidName(user.apellidoPaterno)
          ? null
          : 'El apellido paterno debe tener al menos 3 letras.',
      'rut': _validationController.isValidRut(user.rut)
          ? null
          : 'El RUT es obligatorio y no puede contener símbolos.',
    };
    return validations..removeWhere((key, value) => value == null);
  }

  Future<void> saveMonthlyConsumption(
      String rut, Map<String, int> consumptionData) async {
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

  Future<void> updateMonthlyConsumption(
      String rut, String mes, int newValue) async {
    if (!await verificarRutExistente(rut)) {
      throw Exception('El RUT no está registrado.');
    }

    try {
      final userRef = _firestore.collection('Usuarios').doc(rut);
      final userDoc = await userRef.get();
      final userData = userDoc.data() as Map<String, dynamic>;

      final currentYear = DateTime.now().year.toString();
      final currentConsumption = userData['consumos'][currentYear][mes] ?? 0;

      // Calculate the difference
      final difference = newValue - currentConsumption;

      // Update the consumption
      await userRef.update({'consumos.$currentYear.$mes': newValue});

      // Update montosMensuales
      final currentAmount = userData['montosMensuales'][currentYear][mes] ?? 0;
      final newAmount = currentAmount + difference;
      await userRef.update({'montosMensuales.$currentYear.$mes': newAmount});

      notifyListeners();
    } catch (e) {
      throw Exception('Error al actualizar el consumo: $e');
    }
  }

  Future<int?> getCurrentMonthConsumption(String rut) async {
    if (rut.isEmpty) {
      print('Error: RUT is empty');
      return null;
    }

    try {
      await initializeDateFormatting('es_ES', null);

      final now = DateTime.now();
      final year = now.year.toString();
      final month = DateFormat.MMMM('es_ES').format(now).capitalize();

      print('Buscando consumo para el mes: $month, año: $year, RUT: $rut');

      final userDoc = await _firestore.collection('Usuarios').doc(rut).get();
      if (userDoc.exists) {
        final monthlyAmount = userDoc.data()?['montosMensuales']?[year]?[month];

        // Ensure we return an integer
        if (monthlyAmount != null) {
          return monthlyAmount.toInt();
        }
      } else {
        print('Error: User document not found for RUT: $rut');
      }
      return null;
    } catch (e) {
      print('Error al obtener el consumo del mes actual: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getPaymentStatusByMonth(String rut) async {
    try {
      final userDoc = await _firestore.collection('Usuarios').doc(rut).get();
      if (userDoc.exists) {
        final currentYear = DateTime.now().year.toString();
        final paymentData = userDoc.data()?['historialPagos'][currentYear] ?? {};
        final Map<String, dynamic> result = {};

        for (var month in [
          'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
          'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
        ]) {
          result[month] = paymentData[month] ?? {'valor': 0, 'fecha': null};
        }

        return result;
      } else {
        throw Exception('Usuario no encontrado');
      }
    } catch (e) {
      throw Exception('Error al obtener el estado de pago por mes: $e');
    }
  }
  String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }
}

// Extensión para capitalizar la primera letra
extension StringCapitalize on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + this.substring(1);
  }
}