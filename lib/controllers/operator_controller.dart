import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene el próximo ID para los usuarios.
  Future<int> getNextUserId() async {
    final usuarios = await _firestore
        .collection('Usuarios')
        .orderBy('idUsuario', descending: true)
        .limit(1)
        .get();

    final int lastIdUsuario = usuarios.docs.isNotEmpty ? usuarios.docs.first['idUsuario'] : 0;
    return lastIdUsuario + 1;
  }

  /// Agrega un usuario con consumos inicializados a Firestore.
  Future<void> addUserWithInitialConsumption(Map<String, dynamic> userData) async {
    final userRef = _firestore.collection('Usuarios').doc(userData['rut']);

    Map<String, dynamic> consumptionData = {
      'Enero': 0, 'Febrero': 0, 'Marzo': 0, 'Abril': 0,
      'Mayo': 0, 'Junio': 0, 'Julio': 0, 'Agosto': 0,
      'Septiembre': 0, 'Octubre': 0, 'Noviembre': 0, 'Diciembre': 0
    };

    userData['consumos'] = consumptionData;

    await userRef.set(userData);
  }

  /// Verifica si un RUT ya existe en la colección 'Usuarios'.
  Future<bool> verificarRutExistente(String rut) async {
    final result = await _firestore.collection('Usuarios').doc(rut).get();
    return result.exists;
  }

  /// Obtiene el último número de socio registrado.
  Future<int> getUltimoSocio() async {
    final result = await _firestore
        .collection('Usuarios')
        .orderBy('socio', descending: true)
        .limit(1)
        .get();
    return result.docs.isNotEmpty ? result.docs.first['socio'] : 0;
  }

  /// Guarda el consumo mensual de un usuario actualizando su documento.
  Future<void> saveMonthlyConsumption(String rut, Map<String, int> consumptionData) async {
    final userRef = _firestore.collection('Usuarios').doc(rut);

    Map<String, dynamic> updateData = {};
    consumptionData.forEach((month, value) {
      updateData['consumos.$month'] = value;
    });

    await userRef.update(updateData);
  }

  /// Obtiene el consumo mensual de un usuario por RUT.
  Future<Map<String, int>> getMonthlyConsumption(String rut) async {
    final userDoc = await _firestore.collection('Usuarios').doc(rut).get();

    if (!userDoc.exists) {
      throw Exception('Usuario no encontrado');
    }

    final consumptionData = userDoc.data()?['consumos'] as Map<String, dynamic>?;

    if (consumptionData == null) {
      return {};
    }

    return consumptionData.map((key, value) => MapEntry(key, value as int));
  }

  /// Actualiza el consumo de un mes específico para un usuario.
  Future<void> updateMonthlyConsumption(String rut, String mes, int newValue) async {
    final userRef = _firestore.collection('Usuarios').doc(rut);
    await userRef.update({'consumos.$mes': newValue});
  }

  /// Elimina todos los consumos de un usuario por RUT.
  Future<void> deleteAllConsumos(String rut) async {
    final userRef = _firestore.collection('Usuarios').doc(rut);

    Map<String, dynamic> resetConsumptionData = {
      'Enero': 0, 'Febrero': 0, 'Marzo': 0, 'Abril': 0,
      'Mayo': 0, 'Junio': 0, 'Julio': 0, 'Agosto': 0,
      'Septiembre': 0, 'Octubre': 0, 'Noviembre': 0, 'Diciembre': 0
    };

    await userRef.update({'consumos': resetConsumptionData});
  }
}