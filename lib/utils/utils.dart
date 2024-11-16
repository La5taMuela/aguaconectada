String formatRut(String rut) {
  // Eliminar puntos y guiones existentes
  String cleanRut = rut.replaceAll(RegExp(r'[.-]'), '');

  // Asegurarse de que el RUT tenga al menos 2 caracteres para agregar el guion
  if (cleanRut.length < 2) return rut;

  // Agregar el guion antes del último dígito
  String formattedRut = cleanRut.substring(0, cleanRut.length - 1) +
      '-' +
      cleanRut.substring(cleanRut.length - 1);

  // Agregar puntos cada tres dígitos desde el final
  formattedRut = formattedRut.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

  return formattedRut;
}
