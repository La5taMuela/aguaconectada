import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:aguaconectada/controllers/operator_controller.dart';

class ConsumoControllerUser extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final OperatorController _operatorController = OperatorController();

  Future<void> uploadConsumo({
    required String rut,
    required String nombre,
    required String apellidoPaterno,
    required String socio,
    required int consumo,
    required DateTime fecha,
    required dynamic image,
  }) async {
    try {
      // Upload image to Firebase Storage
      final String fileName = '${rut}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('consumo_images/$fileName');

      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = ref.putData(await image.readAsBytes());
      } else {
        uploadTask = ref.putFile(image);
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String imageUrl = await snapshot.ref.getDownloadURL();

      // Register consumption data in Firestore
      await _firestore.collection('consumo_usuario').add({
        'rut': rut,
        'nombre': nombre,
        'apellidoPaterno': apellidoPaterno,
        'socio': socio,
        'consumo': consumo,
        'fecha': fecha.toIso8601String(),
        'imageUrl': imageUrl,
      });

      // Update user's consumption in Usuarios collection
      final String month = _getMonthName(fecha.month);
      final String year = fecha.year.toString();

      await _firestore.collection('Usuarios').doc(rut).update({
        'consumos.$year.$month': consumo,
      });

      // Calculate and update payment amount
      await _calculateAndUpdatePayment(rut, month, year, consumo);

      notifyListeners();
    } catch (e) {
      print('Error uploading consumo: $e');
      rethrow;
    }
  }

  Future<void> _calculateAndUpdatePayment(String rut, String month, String year, int consumo) async {
    try {
      double paymentAmount = await _operatorController.calculateMonthlyPayment(rut, month, consumo);

      await _firestore.collection('Usuarios').doc(rut).update({
        'montosMensuales.$year.$month': paymentAmount,
      });
    } catch (e) {
      print('Error calculating and updating payment: $e');
      rethrow;
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return monthNames[month - 1];
  }

  Future<int?> getCurrentMonthConsumption(String rut) async {
    try {

      final consumoSnapshot = await _firestore
          .collection('consumo_usuario')
          .where('rut', isEqualTo: rut)
          .where('fecha', isGreaterThanOrEqualTo: DateTime(DateTime.now().year, DateTime.now().month, 1).toIso8601String())
          .where('fecha', isLessThan: DateTime(DateTime.now().year, DateTime.now().month + 1, 1).toIso8601String())
          .orderBy('fecha', descending: true)
          .limit(1)
          .get();

      if (consumoSnapshot.docs.isNotEmpty) {
        return consumoSnapshot.docs.first.data()['consumo'] as int?;
      }
      return null;
    } catch (e) {
      print('Error getting current month consumption: $e');
      rethrow;
    }
  }
}

