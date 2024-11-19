import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class ReportController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> createReport(
    String userRut,
    String nombre,
    String apellidoPaterno,
    String socio,
    String title,
    String description,
    List<dynamic> images,
  ) async {
    try {
      print('Creating report with:');
      print(
          'userRut: $userRut, nombre: $nombre, apellidoPaterno: $apellidoPaterno, socio: $socio');

      // Create a new document reference with an auto-generated ID
      DocumentReference reportRef = _firestore.collection('reportes').doc();
      String reportId = reportRef.id; // Get the auto-generated ID

      List<String> imageUrls = await Future.wait(
          images.map((image) => _uploadImage(reportRef.id, image)));

      await reportRef.set({
        'id': reportId, // Add the ID to the document
        'userRut': userRut,
        'nombre': nombre,
        'apellidoPaterno': apellidoPaterno,
        'socio': socio,
        'title': title,
        'timestamp': FieldValue.serverTimestamp(),
        'description': description,
        'status': 'pendiente',
        'imageUrls': imageUrls,
        'notificationState': false,
      });

      print('Reporte creado exitosamente');
    } catch (e) {
      print('Error al crear el reporte: $e');
      rethrow;
    }
  }

  Future<String> _uploadImage(String reportId, dynamic image) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('reportes/$reportId/$fileName');

      if (kIsWeb) {
        await ref.putData(await (image as XFile).readAsBytes());
      } else {
        await ref.putFile(image as File);
      }

      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir la imagen: $e');
      rethrow;
    }
  }

  Future<void> reviewReport(
      String reportId, String operatorComment, String status) async {
    try {
      await _firestore.collection('reportes').doc(reportId).update({
        'status': status,
        'operatorComment': operatorComment,
        'notificationState': true,
      });
      print('Reporte marcado como $status exitosamente');
    } catch (e) {
      print('Error al actualizar el estado del reporte: $e');
      rethrow;
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      // Delete images from storage
      final report =
          await _firestore.collection('reportes').doc(reportId).get();
      final imageUrls = List<String>.from(report.data()?['imageUrls'] ?? []);
      for (var imageUrl in imageUrls) {
        await _storage.refFromURL(imageUrl).delete();
      }

      // Delete report document
      await _firestore.collection('reportes').doc(reportId).delete();
      print('Reporte eliminado exitosamente');
    } catch (e) {
      print('Error al eliminar el reporte: $e');
      rethrow;
    }
  }
}
