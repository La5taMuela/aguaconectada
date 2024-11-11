import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import 'validation_controller.dart';
import 'package:intl/date_symbol_data_local.dart';
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
        'Enero': {'valor': 0, 'timestamp': 0},
        'Febrero': {'valor': 0, 'timestamp': 0},
        'Marzo': {'valor': 0, 'timestamp': 0},
        'Abril': {'valor': 0, 'timestamp': 0},
        'Mayo': {'valor': 0, 'timestamp': 0},
        'Junio': {'valor': 0, 'timestamp': 0},
        'Julio': {'valor': 0, 'timestamp': 0},
        'Agosto': {'valor': 0, 'timestamp': 0},
        'Septiembre': {'valor': 0, 'timestamp': 0},
        'Octubre': {'valor': 0, 'timestamp': 0},
        'Noviembre': {'valor': 0, 'timestamp': 0},
        'Diciembre': {'valor': 0, 'timestamp': 0},
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
      'montosMensuales': montosMensuales, // Add montosMensuales with just months
      'historialPagos': historialPagos,   // Add historialPagos with valor and timestamp
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
  Future<int?> getCurrentMonthConsumption(String rut) async {
    try {
      // Inicializa los datos de localización para el idioma español
      await initializeDateFormatting('es_ES', null);

      final now = DateTime.now();
      final year = now.year.toString();
      final month = DateFormat.MMMM('es_ES').format(now).capitalize(); // Nombre del mes en español con la primera letra en mayúscula

      // Imprimir los valores de mes y año para ver qué se está buscando
      print('Buscando consumo para el mes: $month, año: $year');

      final userDoc = await _firestore.collection('Usuarios').doc(rut).get();
      if (userDoc.exists) {
        // Accede a "montosMensuales" en lugar de "consumosMensuales"
        final monthlyConsumption = userDoc.data()?['montosMensuales']?[year]?[month];

        // Imprimir el consumo obtenido (si existe)
        print('Consumo encontrado: $monthlyConsumption');

        return monthlyConsumption;
      }
      return null;
    } catch (e) {
      print('Error al obtener el consumo del mes actual: $e');
      throw Exception('Error al obtener el consumo del mes actual: $e');
    }
  }
}

// Extensión para capitalizar la primera letra
extension StringCapitalize on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + this.substring(1);
  }
}