import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConsumptionController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, double> consumptionData = {};
  Map<String, double> monthlyDifferences = {}; // Agregamos este mapa para las diferencias
  bool isLoading = true;
  String error = '';
  String? userRut;

  ConsumptionController();

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

          // Procesar los consumos mensuales
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

          // Calcular las diferencias mensuales
          final months = [
            'Enero',
            'Febrero',
            'Marzo',
            'Abril',
            'Mayo',
            'Junio',
            'Julio',
            'Agosto',
            'Septiembre',
            'Octubre',
            'Noviembre',
            'Diciembre',
          ];

          monthlyDifferences = {};
          for (int i = 0; i < months.length; i++) {
            final currentMonth = months[i];
            final currentValue = consumptionData[currentMonth] ?? 0;

            if (i == 0) {
              // Para el primer mes, no hay un mes anterior, usar el valor original
              monthlyDifferences[currentMonth] = currentValue;
            } else {
              final previousMonth = months[i - 1];
              final previousValue = consumptionData[previousMonth] ?? 0;
              final difference = currentValue - previousValue;

              // Evitar valores negativos, si la diferencia es menor a 0, forzar a 0
              monthlyDifferences[currentMonth] = difference < 0 ? 0 : difference;
            }
          }



          print("Processed monthlyDifferences: $monthlyDifferences"); // Debug log
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
