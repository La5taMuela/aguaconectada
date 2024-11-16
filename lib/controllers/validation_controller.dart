class ValidationController {
  bool isValidName(String name) =>
      name.length >= 1 && _hasNoSpecialCharacters(name);

  bool isValidRut(String rut) {
    String cleanRut = rut.replaceAll(RegExp(r'[.-]'), ''); // Clean RUT
    return cleanRut.length == 9 && _hasNoSpecialCharacters(cleanRut);
  }

  bool _hasNoSpecialCharacters(String value) =>
      RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚÑñ0-9]+$').hasMatch(value);
}
