class ValidationController {
  // Valida que un nombre sea válido
  bool isValidName(String name) =>
      name.isNotEmpty && _hasNoSpecialCharacters(name);

  // Valida el formato del RUT
  bool isValidRut(String rut) {
    String cleanRut = rut.replaceAll(RegExp(r'[.-]'), '').toLowerCase();
    if (cleanRut.length < 8 || cleanRut.length > 9) {
      return false;
    }

    return _isNumeric(cleanRut.substring(0, cleanRut.length - 1)) &&
        _isValidRutDigit(cleanRut);
  }

  // Valida si un número de socio es válido
  bool isNumeric(String value) => _isNumeric(value);

  // Comprueba que no haya caracteres especiales
  bool _hasNoSpecialCharacters(String value) =>
      RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚÑñ0-9\s]+$').hasMatch(value);

  // Comprueba si un valor contiene solo dígitos
  bool _isNumeric(String value) => RegExp(r'^\d+$').hasMatch(value);

  // Verifica que el dígito verificador del RUT sea válido
  bool _isValidRutDigit(String rut) {
    int sum = 0;
    int multiplier = 2;
    for (int i = rut.length - 2; i >= 0; i--) {
      sum += int.parse(rut[i]) * multiplier;
      multiplier = (multiplier == 7) ? 2 : multiplier + 1;
    }

    int remainder = 11 - (sum % 11);
    String checkDigit = (remainder == 11) ? '0' : (remainder == 10) ? 'k' : '$remainder';

    return checkDigit == rut[rut.length - 1];
  }
}
