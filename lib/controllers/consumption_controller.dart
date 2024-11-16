import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsumptionController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, double> consumptionData = {};
  bool isLoading = true;
  String error = '';
  String? userRut;

  ConsumptionController() {
    // We'll call fetchConsumptionData after setting the userRut
  }

  void setUserRut(String rut) {
    print("Setting userRut: $rut"); // Debug log
    userRut = rut;
    fetchConsumptionData();
  }

  Future<void> fetchConsumptionData() async {
    if (userRut == null || userRut!.isEmpty) {
      error = 'RUT de usuario no establecido o vacío';
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      error = '';
      notifyListeners();

      print("Setting up listener for userRut: $userRut"); // Debug log

      // Use a snapshot listener
      _firestore
          .collection('Usuarios')
          .doc(userRut)
          .snapshots()
          .listen((DocumentSnapshot userDoc) {
        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          // Access the 'consumos' map and then the specific year (e.g., '2024')
          Map<String, dynamic> consumos =
              userData['consumos'] as Map<String, dynamic>? ?? {};
          Map<String, dynamic> yearData =
              consumos['2024'] as Map<String, dynamic>? ?? {};

          print("Fetched yearData for 2024: $yearData"); // Debug log

          consumptionData = {
            'Enero': (yearData['Enero'] ?? 0).toDouble(),
            'Febrero': (yearData['Febrero'] ?? 0).toDouble(),
            'Marzo': (yearData['Marzo'] ?? 0).toDouble(),
            'Abril': (yearData['Abril'] ?? 0).toDouble(),
            'Mayo': (yearData['Mayo'] ?? 0).toDouble(),
            'Junio': (yearData['Junio'] ?? 0).toDouble(),
            'Julio': (yearData['Julio'] ?? 0).toDouble(),
            'Agosto': (yearData['Agosto'] ?? 0).toDouble(),
            'Septiembre': (yearData['Septiembre'] ?? 0).toDouble(),
            'Octubre': (yearData['Octubre'] ?? 0).toDouble(),
            'Noviembre': (yearData['Noviembre'] ?? 0).toDouble(),
            'Diciembre': (yearData['Diciembre'] ?? 0).toDouble(),
          };

          print("Processed consumptionData: $consumptionData"); // Debug log
        } else {
          error = 'No se encontraron datos de consumo para este usuario';
        }

        isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      print('Error setting up listener: $e');
      error = 'Error al cargar los datos de consumo: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  List<String> getAvailableYears() {
    // This method can return the available years.
    // For demonstration, let's assume the years are hardcoded.
    return ['2024']; // You can expand this logic based on your data structure
  }
}
