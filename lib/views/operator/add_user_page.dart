import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aguaconectada/controllers/operator_controller.dart'; // Controlador de Firebase

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final OperatorController _operatorController = OperatorController();

  // Controladores para los campos del formulario
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController segundoNombreController = TextEditingController();
  final TextEditingController apellidoPaternoController = TextEditingController();
  final TextEditingController apellidoMaternoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController rutController = TextEditingController();

  List<String> _direccionesSugeridas = []; // Lista de sugerencias de direcciones
  int _siguienteSocio = 1; // Número del próximo socio disponible

  @override
  void initState() {
    super.initState();
    _cargarSiguienteSocio(); // Cargar el próximo número de socio al abrir la pantalla
  }

  Future<void> _cargarSiguienteSocio() async {
    int ultimoSocio = await _operatorController.getUltimoSocio();
    setState(() {
      _siguienteSocio = ultimoSocio + 1;
    });
  }

  // Función para validar y normalizar el RUT
  String _formatRut(String rut) {
    return rut.replaceAll('.', '').replaceAll('-', '').toUpperCase();
  }

  String _capitalize(String input) {
    return input.trim().split(' ').map((str) {
      return '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}';
    }).join(' ');
  }

  // Validaciones
  String? _validateRequiredField(String? value, String fieldName) {
    return (value == null || value.trim().isEmpty)
        ? 'El campo $fieldName es obligatorio'
        : null;
  }

  String? _validateRut(String? value) {
    final cleanedRut = _formatRut(value ?? '');
    if (cleanedRut.length < 8 || cleanedRut.length > 10) {
      return 'RUT inválido';
    }
    return null;
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      String nombre = _capitalize(nombreController.text);
      String segundoNombre = _capitalize(segundoNombreController.text);
      String apellidoPaterno = _capitalize(apellidoPaternoController.text);
      String apellidoMaterno = _capitalize(apellidoMaternoController.text);
      String direccion = direccionController.text.trim();
      String rut = _formatRut(rutController.text);

      // Verificar que el RUT no exista
      bool rutExiste = await _operatorController.verificarRutExistente(rut);
      if (rutExiste) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El RUT ya está registrado')),
        );
        return;
      }

      // Crear los datos del usuario
      Map<String, dynamic> userData = {
        'nombre': nombre,
        'segundoNombre': segundoNombre.isNotEmpty ? segundoNombre : null,
        'apellidoPaterno': apellidoPaterno,
        'apellidoMaterno': apellidoMaterno.isNotEmpty ? apellidoMaterno : null,
        'direccion': direccion,
        'rut': rut,
        'socio': _siguienteSocio,
      };

      try {
        await _operatorController.addUser(userData);
        _mostrarDialogoExito(); // Mostrar diálogo de éxito
        _limpiarCampos(); // Limpiar los campos
        await _cargarSiguienteSocio(); // Actualizar el siguiente socio disponible
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
    direccionController.clear();
    rutController.clear();
  }

  void _mostrarDialogoExito() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Éxito'),
        content: const Text('Usuario agregado exitosamente'),
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
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => _validateRequiredField(value, 'Nombre'),
              ),
              TextFormField(
                controller: segundoNombreController,
                decoration: const InputDecoration(labelText: 'Segundo Nombre (Opcional)'),
              ),
              TextFormField(
                controller: apellidoPaternoController,
                decoration: const InputDecoration(labelText: 'Apellido Paterno'),
                validator: (value) => _validateRequiredField(value, 'Apellido Paterno'),
              ),
              TextFormField(
                controller: apellidoMaternoController,
                decoration: const InputDecoration(labelText: 'Apellido Materno (Opcional)'),
              ),
              TextFormField(
                controller: direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                onChanged: (value) async {
                  List<String> sugerencias = await _operatorController.getSugerenciasDirecciones(value);
                  setState(() {
                    _direccionesSugeridas = sugerencias;
                  });
                },
              ),
              if (_direccionesSugeridas.isNotEmpty)
                DropdownButton<String>(
                  items: _direccionesSugeridas.map((direccion) {
                    return DropdownMenuItem(
                      value: direccion,
                      child: Text(direccion),
                    );
                  }).toList(),
                  onChanged: (value) {
                    direccionController.text = value!;
                  },
                ),
              TextFormField(
                controller: rutController,
                decoration: const InputDecoration(labelText: 'RUT'),
                validator: _validateRut,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blue[800],
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Agregar usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
