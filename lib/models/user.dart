class User {
  final int idUsuario;
  final String nombre;
  final String segundoNombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String rut;
  final String nota;
  final int socio;
  final Map<String, Map<String, int>> consumos;

  User({
    required this.idUsuario,
    required this.nombre,
    required this.segundoNombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.rut,
    required this.nota,
    required this.socio,
    required this.consumos,
  });

}
