class UserModel {
  final String firstName;
  final String? secondName;
  final String lastName;
  final String motherLastName;
  final String address;
  final String rut;
  final int socio;

  UserModel({
    required this.firstName,
    this.secondName,
    required this.lastName,
    required this.motherLastName,
    required this.address,
    required this.rut,
    required this.socio,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': firstName,
      'segundoNombre': secondName,
      'apellidoPaterno': lastName,
      'apellidoMaterno': motherLastName,
      'direccion': address,
      'rut': rut,
      'socio': socio,
    };
  }
}
