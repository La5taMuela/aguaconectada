import 'package:intl/intl.dart';

/// Devuelve el nombre del mes actual en español con la primera letra mayúscula.
String getCurrentMonthName() {
  return toBeginningOfSentenceCase(DateFormat.MMMM('es_ES').format(DateTime.now()))!;
}
