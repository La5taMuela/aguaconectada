class Admin {
  String nombre;
  String apellidoPaterno;
  String rut;
  int id;
  String email;

  Admin({
    required this.nombre,
    required this.apellidoPaterno,
    required this.rut,
    required this.id,
    required this.email,
  });

  String nombreCompleto() {
    return '$nombre $apellidoPaterno';
  }

  factory Admin.fromMap(Map<String, dynamic> data) {
    return Admin(
      nombre: data['nombre'] ?? '',
      apellidoPaterno: data['apellidoPaterno'] ?? '',
      rut: data['rut'] ?? '',
      id: data['id'] ?? 0,
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'rut': rut,
      'id': id,
      'email': email,
    };
  }
}
