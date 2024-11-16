import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'operator_controller.dart';

class PaymentController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OperatorController _operatorController = OperatorController();

  double? currentMonthAmount;
  String? selectedYear;
  bool isProcessingPayment = false;
  String _userRut = '';

  String get userRut => _userRut;

  void setUserRut(String rut) {
    _userRut = rut;
    _listenToMonthlyAmount();
  }

  Future<void> initializeData(String userRut) async {
    setUserRut(userRut);
    await getCurrentMonthAmount(userRut);
    setAvailableYears();
  }

  Future<void> getCurrentMonthAmount(String userRut) async {
    try {
      final userData = await _firestore.collection('Usuarios').doc(userRut).get();
      if (userData.exists) {
        final montosMensuales = userData.data()?['montosMensuales'] as Map<String, dynamic>?;
        if (montosMensuales != null) {
          final currentYear = DateTime.now().year.toString();
          final currentMonth = _getCurrentMonth();
          currentMonthAmount = montosMensuales[currentYear]?[currentMonth]?.toDouble() ?? 0.0;
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error al obtener el monto del mes actual: $e');
    }
  }

  void setAvailableYears() {
    final currentYear = DateTime.now().year;
    final availableYears = List.generate(5, (index) => (currentYear - index).toString());
    selectedYear = availableYears.first;
    notifyListeners();
  }
  void _listenToMonthlyAmount() {
    if (_userRut.isEmpty) return;

    final currentYear = DateTime.now().year.toString();
    final currentMonth = _getCurrentMonth();

    _firestore.collection('Usuarios').doc(_userRut).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        currentMonthAmount = data['montosMensuales']?[currentYear]?[currentMonth]?.toDouble() ?? 0.0;
        notifyListeners();
      }
    });
  }
  Future<void> handlePayment(String userRut) async {
    if (isProcessingPayment || currentMonthAmount == null || currentMonthAmount == 0) {
      return;
    }

    try {
      isProcessingPayment = true;
      notifyListeners();

      final currentMonth = _getCurrentMonth();
      final now = DateTime.now();

      await _operatorController.updatePaymentHistory(
        _userRut,
        currentMonth,
        {
          'valor': currentMonthAmount,
          'fecha': DateFormat('dd/MM/yyyy HH:mm:ss').format(now),
        },
      );

      await _resetCurrentMonthAmount();

      notifyListeners();
    } catch (e) {
      print('Error processing payment: $e');
      rethrow;
    } finally {
      isProcessingPayment = false;
      notifyListeners();
    }
  }

  Future<void> _resetCurrentMonthAmount() async {
    final currentYear = DateTime.now().year.toString();
    final currentMonth = _getCurrentMonth();

    await _firestore.collection('Usuarios').doc(_userRut).update({
      'montosMensuales.$currentYear.$currentMonth': 0
    });
  }

  String _getCurrentMonth() {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[DateTime.now().month - 1];
  }

  List<String> getAvailableYears() {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => (currentYear - index).toString());
  }
}