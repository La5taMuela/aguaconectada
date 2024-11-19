import 'package:flutter/material.dart';
import 'package:aguaconectada/controllers/user_controller.dart';
import 'package:aguaconectada/models/user.dart';
import '../../controllers/validation_controller.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final UserController _userController = UserController();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController segundoNombreController = TextEditingController();
  final TextEditingController apellidoPaternoController = TextEditingController();
  final TextEditingController apellidoMaternoController = TextEditingController();
  final TextEditingController rutController = TextEditingController();
  final TextEditingController notaController = TextEditingController();

  int? _siguienteIdUsuario;
  Map<String, String?> _errorMessages = {};

  @override
  void initState() {
    super.initState();
    _cargarSiguienteId();
  }

  Future<void> _cargarSiguienteId() async {
    final id = await _userController.getNextUserId();
    setState(() {
      _siguienteIdUsuario = id;
    });
  }

  Future<void> _saveUser() async {
    setState(() {
      _errorMessages.clear();
    });

    if (_formKey.currentState!.validate()) {
      final user = User(
        apellidoMaterno: apellidoMaternoController.text.trim(),
        apellidoPaterno: apellidoPaternoController.text.trim(),
        consumos: {
          DateTime.now().year.toString(): {
            'Enero': 0,
            'Febrero': 0,
            'Marzo': 0,
            'Abril': 0,
            'Mayo': 0,
            'Junio': 0,
            'Julio': 0,
            'Agosto': 0,
            'Septiembre': 0,
            'Octubre': 0,
            'Noviembre': 0,
            'Diciembre': 0,
          }
        },
        historialPagos: {},
        idUsuario: _siguienteIdUsuario!,
        montosMensuales: {},
        nombre: nombreController.text.trim(),
        nota: notaController.text.trim(),
        rut: rutController.text.trim(),
        segundoNombre: segundoNombreController.text.trim(),
        socio: _siguienteIdUsuario!,
      );

      final errorResponse = await _userController.addUserWithInitialConsumption(user);

      if (errorResponse.isEmpty) {
        _mostrarDialogoExito();
        _limpiarCampos();
        await _cargarSiguienteId();
      } else {
        setState(() {
          _errorMessages = errorResponse;
        });
      }
    }
  }

  void _limpiarCampos() {
    nombreController.clear();
    segundoNombreController.clear();
    apellidoPaternoController.clear();
    apellidoMaternoController.clear();
    rutController.clear();
    notaController.clear();
  }

  void _mostrarDialogoExito() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Éxito'),
        content: const Text('Usuario agregado exitosamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(nombreController, 'Nombre', _validateName),
              if (_errorMessages['nombre'] != null)
                _buildErrorText(_errorMessages['nombre']),
              const SizedBox(height: 10),
              _buildTextField(segundoNombreController, 'Segundo Nombre (Opcional)'),
              const SizedBox(height: 10),
              _buildTextField(apellidoPaternoController, 'Apellido Paterno', _validateName),
              if (_errorMessages['apellidoPaterno'] != null)
                _buildErrorText(_errorMessages['apellidoPaterno']),
              const SizedBox(height: 10),
              _buildTextField(apellidoMaternoController, 'Apellido Materno (Opcional)'),
              const SizedBox(height: 10),
              _buildTextField(
                rutController,
                'RUT',
                    (value) {
                  if (!ValidationController().isValidRut(value!)) {
                    return 'El RUT es obligatorio y debe tener 9 caracteres sin símbolos.';
                  }
                  return null;
                },
              ),
              if (_errorMessages['rut'] != null)
                _buildErrorText(_errorMessages['rut']),
              const SizedBox(height: 10),
              _buildTextField(notaController, 'Nota (Opcional)'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                child: const Text(
                  'Agregar usuario',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obligatorio';
    }
    if (value.isEmpty) {
      return 'El nombre debe tener al menos 1 letras.';
    }
    return null;
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, [
        String? Function(String?)? validator,
      ]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildErrorText(String? error) {
    return Text(
      error ?? '',
      style: const TextStyle(color: Colors.red),
    );
  }
}
