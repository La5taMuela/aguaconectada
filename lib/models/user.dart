class UserModel {
  final String nombre;
  final String rut;
  final String socio;

  UserModel({
    required this.nombre,
    required this.rut,
    required this.socio,
  });

  // Método para convertir un mapa (de Firestore) en una instancia de UserModel
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      nombre: data['nombre'] ?? '',
      rut: data['rut'] ?? '',
      socio: data['socio'] ?? '',
    );
  }

  // Método para convertir una instancia de UserModel en un mapa
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'rut': rut,
      'socio': socio,
    };
  }
}
