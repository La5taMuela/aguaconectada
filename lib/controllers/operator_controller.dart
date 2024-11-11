import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class TariffData {
  final int m3;
  final double variable1;
  final double totalAPagar1;

  TariffData(this.m3, this.variable1, this.totalAPagar1);
}

class OperatorController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static List<TariffData>? _cachedTariffData;
  static DateTime? _lastFetchTime;
  static const cacheDuration = Duration(hours: 1);

  Future<void> saveMonthlyConsumption(String rut, Map<String, int> consumptionData) async {
    final currentYear = DateTime.now().year.toString();
    print('Saving monthly consumption for $rut, year: $currentYear');

    try {
      final userRef = _firestore.collection('Usuarios').doc(rut);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado');
      }

      final userData = userDoc.data()!;
      final currentConsumption = (userData['consumos'] as Map<String, dynamic>?)?[currentYear] as Map<String, dynamic>? ?? {};
      print('Current consumption data: $currentConsumption');

      Map<String, dynamic> updates = {};

      for (var entry in consumptionData.entries) {
        final String month = entry.key;
        final int newValue = entry.value;
        final int oldValue = (currentConsumption[month] as int?) ?? 0;
        print('Month: $month, New Value: $newValue, Old Value: $oldValue');

        if (newValue != oldValue) {
          updates['consumos.$currentYear.$month'] = newValue;

          try {
            final payment = await calculateMonthlyPayment(rut, month, newValue);


            updates['montosMensuales.$currentYear.$month'] = payment;

            print('Calculated payment for $month: $payment');
          } catch (e) {
            print('Error calculating payment for $month: $e');
          }
        }
      }

      if (updates.isNotEmpty) {
        await userRef.update(updates);
        print('Updated user consumption and payment data: $updates');
      } else {
        print('No updates needed for consumption data');
      }

    } catch (e) {
      print('Error saving consumption data: $e');
      throw Exception('Error al guardar el consumo y calcular pagos: $e');
    }
  }

  Future<List<TariffData>> _getTariffData() async {
    if (_cachedTariffData != null && _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
      print('Using cached tariff data');
      return _cachedTariffData!;
    }

    try {
      print('Fetching tariff data from Firebase Storage...');
      final tariffRef = _storage.ref('tarifas/san miguel/tabla de tarifas san miguel de ablemo.json');
      final downloadUrl = await tariffRef.getDownloadURL();

      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode != 200) {
        throw Exception('Error al obtener archivo de tarifas (${response.statusCode})');
      }

      final data = response.body;
      final Map<String, dynamic> jsonData = jsonDecode(data);
      print('Raw JSON data: $jsonData');

      List<TariffData> tariffData = [];
      for (var item in jsonData['tarifas']) {
        final m3 = item['M3']?.toInt() ?? 0;
        final variable1 = (item['Variable_1'] as num).toDouble();
        final totalAPagar1 = (item['Total_a_Pagar_1'] as num).toDouble();

        if (m3 > 0 && variable1 > 0) {
          tariffData.add(TariffData(m3, variable1, totalAPagar1));
          print('Added tariff data: M3: $m3, Variable1: $variable1, TotalAPagar1: $totalAPagar1');
        }
      }

      _cachedTariffData = tariffData;
      _lastFetchTime = DateTime.now();
      print('Tariff data fetched and cached: $_cachedTariffData');

      return tariffData;
    } catch (e) {
      print('Error fetching tariff data: $e');
      throw Exception('Error al obtener datos de tarifa: $e');
    }
  }

  int _getPreviousMonthConsumption(Map<String, dynamic> yearConsumption, String currentMonth) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    final currentIndex = months.indexOf(currentMonth);
    if (currentIndex <= 0) return 0;

    final prevConsumption = yearConsumption[months[currentIndex - 1]] ?? 0;
    print('Previous month consumption for $currentMonth: $prevConsumption');
    return prevConsumption;
  }

  Future<double> calculateMonthlyPayment(String rut, String month, int consumption) async {
    try {
      final tariffData = await _getTariffData();
      print('Calculating monthly payment for RUT: $rut, Month: $month, Consumption: $consumption');

      final userData = await _firestore.collection('Usuarios').doc(rut).get();
      if (!userData.exists) {
        throw Exception('Usuario no encontrado');
      }

      final consumos = userData.data()?['consumos'] as Map<String, dynamic>?;
      if (consumos == null) {
        throw Exception('Datos de consumo no encontrados');
      }

      final currentYear = DateTime.now().year.toString();
      final yearConsumption = consumos[currentYear] as Map<String, dynamic>?;
      if (yearConsumption == null) {
        throw Exception('Datos del año actual no encontrados');
      }

      final previousConsumption = _getPreviousMonthConsumption(yearConsumption, month);
      final difference = consumption - previousConsumption;
      print('Consumption difference for $month: $difference');

      double payment = 4460.0;

      if (difference > 0) {
        payment += _calculateVariablePayment(difference, tariffData);
      }

      print('Final calculated payment for $month: $payment');
      return payment;

    } catch (e) {
      print('Error calculating monthly payment: $e');
      throw Exception('Error en el cálculo del pago: $e');
    }
  }

  double _calculateVariablePayment(int consumption, List<TariffData> tariffData) {
    if (consumption <= 0) return 0;
    if (consumption > 360) consumption = 360;

    for (var tariff in tariffData) {
      if (consumption <= tariff.m3) {
        print('Variable payment found for consumption $consumption: ${tariff.variable1}');
        return tariff.variable1;
      }
    }

    print('Using last total payment as fallback: ${tariffData.last.totalAPagar1}');
    return tariffData.isEmpty ? 0 : tariffData.last.totalAPagar1;
  }

  Future<Map<String, int>> getMonthlyConsumption(String rut) async {
    try {
      print('Fetching monthly consumption for RUT: $rut');
      final userDoc = await _firestore.collection('Usuarios').doc(rut).get();
      if (!userDoc.exists) {
        throw Exception('El usuario no existe.');
      }

      final data = userDoc.data()?['consumos'] as Map<String, dynamic>? ?? {};
      final currentYear = DateTime.now().year.toString();
      final monthlyData = data[currentYear] as Map<String, dynamic>? ?? {};

      print('Monthly consumption data retrieved: $monthlyData');
      return Map<String, int>.from(monthlyData);
    } catch (e) {
      print('Error fetching monthly consumption: $e');
      throw Exception('Error al obtener el consumo mensual: $e');
    }
  }

  Future<void> updateNotificationState(String documentId) async {
    print('Updating notification state for document ID: $documentId');
    await _firestore.collection('reportes').doc(documentId).update({
      'notificationState': true,
    });
  }

  Stream<QuerySnapshot> get reportStream {
    print('Fetching report stream for pending notifications');
    return _firestore.collection('reportes')
        .where('notificationState', isEqualTo: false)
        .snapshots();
  }
}
