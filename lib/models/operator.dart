class Operator {
  final int idOperator;
  final String nombre;
  final String segundoNombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String tarifaUrls;
  final String rut;
  final int socio;
  final Map<String, Map<String, int>> Locacion;

  Operator({
    required this.idOperator,
    required this.nombre,
    required this.segundoNombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.tarifaUrls,
    required this.rut,
    required this.socio,
    required this.Locacion,
  });

}
