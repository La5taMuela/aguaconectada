import 'package:cloud_firestore/cloud_firestore.dart';

class TutorialController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkTutorialStatus(String userRut) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('Usuarios')
          .doc(userRut)
          .get();

      // Explicitly handle the case where the field doesn't exist
      if (!doc.exists || !doc.data().toString().contains('tutorialCompleted')) {
        return false;
      }

      return doc.get('tutorialCompleted') ?? false;
    } catch (e) {
      print('Error checking tutorial status: $e');
      return false;
    }
  }

  Future<void> completeTutorial(String userRut) async {
    try {
      await _firestore
          .collection('Usuarios')
          .doc(userRut)
          .update({'tutorialCompleted': true});
    } catch (e) {
      print('Error completing tutorial: $e');
      throw Exception('No se pudo actualizar el estado del tutorial');
    }
  }
}