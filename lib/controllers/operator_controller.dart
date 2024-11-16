import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class TariffData {
  final int m3;
  final double variable1;
  final double totalAPagar1;

  TariffData(this.m3, this.variable1, this.totalAPagar1);
}

class OperatorController extends ChangeNotifier{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static List<TariffData>? _cachedTariffData;
  static DateTime? _lastFetchTime;
  static const cacheDuration = Duration(hours: 1);


  Future<void> updatePaymentHistory(
      String rut,
      String month,
      Map<String, dynamic> paymentData
      ) async {
    try {
      final currentYear = DateTime.now().year.toString();

      final userRef = _firestore.collection('Usuarios').doc(rut);
      await userRef.update({
        'historialPagos.$currentYear.$month': paymentData
      });

      notifyListeners();
    } catch (e) {
      print('Error updating payment history: $e');
      rethrow;
    }
  }

  Future<void> saveMonthlyConsumption(String rut, Map<String, int> consumptionData) async {
    final currentYear = DateTime.now().year.toString();

    try {
      final userRef = _firestore.collection('Usuarios').doc(rut);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado');
      }

      Map<String, dynamic> updates = {};

      for (var entry in consumptionData.entries) {
        final String month = entry.key;
        final int newValue = entry.value;

        updates['consumos.$currentYear.$month'] = newValue;

        try {
          final payment = await calculateMonthlyPayment(rut, month, newValue);
          updates['montosMensuales.$currentYear.$month'] = payment;
        } catch (e) {
          print('Error calculating payment for $month: $e');
        }
      }

      if (updates.isNotEmpty) {
        await userRef.update(updates);
        notifyListeners();
      }

    } catch (e) {
      print('Error saving consumption data: $e');
      rethrow;
    }
  }

  Future<List<TariffData>> _getTariffData() async {
    if (_cachedTariffData != null && _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
      return _cachedTariffData!;
    }

    try {
      // Configure Firebase Storage for public access
      final tariffRef = _storage.ref('tarifas/san miguel/tabla de tarifas san miguel de ablemo.json');
      final downloadUrl = await tariffRef.getDownloadURL();

      // Add cache-control headers to prevent CORS issues
      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: {
          'Cache-Control': 'no-cache',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al obtener archivo de tarifas (${response.statusCode})');
      }

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final List<TariffData> tariffData = [];

      for (var item in (jsonData['tarifas'] as List)) {
        final m3 = item['M3'] as int;
        final variable1 = (item['Variable_1'] as num).toDouble();
        final totalAPagar1 = (item['Total_a_Pagar_1'] as num).toDouble();

        tariffData.add(TariffData(m3, variable1, totalAPagar1));
      }

      _cachedTariffData = tariffData;
      _lastFetchTime = DateTime.now();
      return tariffData;
    } catch (e) {
      print('Error fetching tariff data: $e');
      rethrow;
    }
  }

  int _getPreviousMonthConsumption(Map<String, dynamic> yearConsumption, String currentMonth) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    final currentIndex = months.indexOf(currentMonth);
    if (currentIndex <= 0) return 0;

    final prevMonth = months[currentIndex - 1];
    return (yearConsumption[prevMonth] as num?)?.toInt() ?? 0;
  }

  Future<double> calculateMonthlyPayment(String rut, String month, int consumption) async {
    try {
      final tariffData = await _getTariffData();

      final userData = await _firestore.collection('Usuarios').doc(rut).get();
      if (!userData.exists) {
        throw Exception('Usuario no encontrado');
      }

      final currentYear = DateTime.now().year.toString();
      final consumos = userData.data()?['consumos']?[currentYear] as Map<String, dynamic>? ?? {};

      final previousConsumption = _getPreviousMonthConsumption(consumos, month);
      final difference = consumption - previousConsumption;

      // Only calculate payment if there's consumption
      if (difference <= 0) return 0;

      // Base fee only added when there's consumption
      double payment = 4460.0;

      // Find the corresponding tariff for the consumption difference
      for (var tariff in tariffData) {
        if (difference <= tariff.m3) {
          payment += tariff.variable1;
          break;
        }
      }

      return payment;
    } catch (e) {
      print('Error calculating monthly payment: $e');
      rethrow;
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
