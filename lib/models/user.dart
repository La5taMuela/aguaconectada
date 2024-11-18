class User {
  String apellidoMaterno;
  String apellidoPaterno;
  Map<String, Map<String, dynamic>> consumos;
  Map<String, Map<String, dynamic>> historialPagos;
  int idUsuario;
  Map<String, Map<String, dynamic>> montosMensuales;
  String nombre;
  String nota;
  String rut;
  String segundoNombre;
  int socio;

  // Constructor
  User({
    required this.apellidoMaterno,
    required this.apellidoPaterno,
    required this.consumos,
    required this.historialPagos,
    required this.idUsuario,
    required this.montosMensuales,
    required this.nombre,
    required this.nota,
    required this.rut,
    required this.segundoNombre,
    required this.socio,
  });

  String nombreCompleto() {
    return '$nombre $apellidoPaterno';
  }
  // Getters
  String get getApellidoMaterno => apellidoMaterno;
  String get getApellidoPaterno => apellidoPaterno;
  Map<String, Map<String, dynamic>> get getConsumos => consumos;
  Map<String, Map<String, dynamic>> get getHistorialPagos => historialPagos;
  int get getIdUsuario => idUsuario;
  Map<String, Map<String, dynamic>> get getMontosMensuales => montosMensuales;
  String get getNombre => nombre;
  String get getNota => nota;
  String get getRut => rut;
  String get getSegundoNombre => segundoNombre;
  int get getSocio => socio;

  // Setters
  set setApellidoMaterno(String value) => apellidoMaterno = value;
  set setApellidoPaterno(String value) => apellidoPaterno = value;
  set setConsumos(Map<String, Map<String, dynamic>> value) => consumos = value;
  set setHistorialPagos(Map<String, Map<String, dynamic>> value) =>
      historialPagos = value;
  set setIdUsuario(int value) => idUsuario = value;
  set setMontosMensuales(Map<String, Map<String, dynamic>> value) =>
      montosMensuales = value;
  set setNombre(String value) => nombre = value;
  set setNota(String value) => nota = value;
  set setRut(String value) => rut = value;
  set setSegundoNombre(String value) => segundoNombre = value;
  set setSocio(int value) => socio = value;

  // Método para inicializar desde un Map (por ejemplo, de Firestore)
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      apellidoMaterno: data['apellidoMaterno'] ?? '',
      apellidoPaterno: data['apellidoPaterno'] ?? '',
      consumos: Map<String, Map<String, dynamic>>.from(data['consumos'] ?? {}),
      historialPagos: Map<String, Map<String, dynamic>>.from(data['historialPagos'] ?? {}),
      idUsuario: data['idUsuario'] ?? 0,
      montosMensuales: Map<String, Map<String, dynamic>>.from(data['montosMensuales'] ?? {}),
      nombre: data['nombre'] ?? '',
      nota: data['nota'] ?? '',
      rut: data['rut'] ?? '',
      segundoNombre: data['segundoNombre'] ?? '',
      socio: data['socio'] ?? 0,
    );
  }

  // Método para convertir a Map (para guardar en Firestore o similares)
  Map<String, dynamic> toMap() {
    return {
      'apellidoMaterno': apellidoMaterno,
      'apellidoPaterno': apellidoPaterno,
      'consumos': consumos,
      'historialPagos': historialPagos,
      'idUsuario': idUsuario,
      'montosMensuales': montosMensuales,
      'nombre': nombre,
      'nota': nota,
      'rut': rut,
      'segundoNombre': segundoNombre,
      'socio': socio,
    };
  }
}
