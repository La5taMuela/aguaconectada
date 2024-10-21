import 'package:cloud_firestore/cloud_firestore.dart';

class OperatorController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(Map<String, dynamic> userData) async {
    await _firestore.collection('Usuarios').add(userData);
  }

  Future<bool> verificarRutExistente(String rut) async {
    final query = await _firestore.collection('Usuarios').where('rut', isEqualTo: rut).get();
    return query.docs.isNotEmpty;
  }

  Future<int> getUltimoSocio() async {
    final query = await _firestore
        .collection('Usuarios')
        .orderBy('socio', descending: true)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return query.docs.first['socio'];
    }
    return 0;
  }

  Future<List<String>> getSugerenciasDirecciones(String query) async {
    final snapshot = await _firestore
        .collection('Usuarios')
        .where('direccion', isGreaterThanOrEqualTo: query)
        .limit(5)
        .get();
    return snapshot.docs.map((doc) => doc['direccion'] as String).toList();
  }
}
