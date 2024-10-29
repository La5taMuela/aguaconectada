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
      String description,
      List<dynamic> images,
      ) async {
    try {
      DocumentReference reportRef = _firestore.collection('reportes').doc();

      List<String> imageUrls = await Future.wait(
          images.map((image) => _uploadImage(reportRef.id, image))
      );

      await reportRef.set({
        'userRut': userRut,
        'nombre': nombre,
        'apellidoPaterno': apellidoPaterno,
        'socio': socio,
        'timestamp': FieldValue.serverTimestamp(),
        'description': description,
        'status': 'pendiente',
        'imageUrls': imageUrls,
      });

      print('Reporte creado exitosamente');
    } catch (e) {
      print('Error al crear el reporte: $e');
      throw e;
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
      throw e;
    }
  }
}
