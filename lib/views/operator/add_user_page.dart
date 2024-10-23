import 'package:flutter/material.dart';
import 'package:aguaconectada/controllers/operator_controller.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final OperatorController _operatorController = OperatorController();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController segundoNombreController = TextEditingController();
  final TextEditingController apellidoPaternoController = TextEditingController();
  final TextEditingController apellidoMaternoController = TextEditingController();
  final TextEditingController rutController = TextEditingController();
  final TextEditingController notaController = TextEditingController();

  int? _siguienteIdUsuario;

  @override
  void initState() {
    super.initState();
    _cargarSiguienteId();
  }

  Future<void> _cargarSiguienteId() async {
    final id = await _operatorController.getNextUserId();
    setState(() {
      _siguienteIdUsuario = id;
    });
  }

  String _formatRut(String rut) {
    // Remove dots and dashes
    String cleanRut = rut.replaceAll(RegExp(r'[.-]'), '');
    // Convert 'K' to lowercase 'k'
    return cleanRut.replaceAll('K', 'k');
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'idUsuario': _siguienteIdUsuario,
        'nombre': nombreController.text.trim(),
        'segundoNombre': segundoNombreController.text.trim(),
        'apellidoPaterno': apellidoPaternoController.text.trim(),
        'apellidoMaterno': apellidoMaternoController.text.trim(),
        'rut': _formatRut(rutController.text.trim()),
        'nota': notaController.text.trim(),
        'socio': _siguienteIdUsuario,
      };

      try {
        await _operatorController.addUserWithInitialConsumption(userData);
        _mostrarDialogoExito();
        _limpiarCampos();
        await _cargarSiguienteId();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar usuario: $e')),
        );
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
        content: const Text('Usuario agregado exitosamente con consumos inicializados.'),
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
              _buildTextField(nombreController, 'Nombre'),
              const SizedBox(height: 10),
              _buildTextField(segundoNombreController, 'Segundo Nombre (Opcional)'),
              const SizedBox(height: 10),
              _buildTextField(apellidoPaternoController, 'Apellido Paterno'),
              const SizedBox(height: 10),
              _buildTextField(apellidoMaternoController, 'Apellido Materno (Opcional)'),
              const SizedBox(height: 10),
              _buildTextField(rutController, 'RUT'),
              const SizedBox(height: 10),
              _buildTextField(notaController, 'Nota (Opcional)'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                child: const Text('Agregar usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        String? Function(String?)? validator,
      }) {
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
}