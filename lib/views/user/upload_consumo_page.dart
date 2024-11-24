import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:aguaconectada/controllers/consumo_controller_user.dart';
import 'package:aguaconectada/controllers/operator_controller.dart';

class UploadConsumoPage extends StatefulWidget {
  final String rut;
  final String nombre;
  final String apellidoPaterno;
  final String socio;

  const UploadConsumoPage({
    Key? key,
    required this.rut,
    required this.nombre,
    required this.apellidoPaterno,
    required this.socio,
  }) : super(key: key);

  @override
  _UploadConsumoPageState createState() => _UploadConsumoPageState();
}

class _UploadConsumoPageState extends State<UploadConsumoPage> {
  final _formKey = GlobalKey<FormState>();
  final _consumoController = TextEditingController();
  final ConsumoControllerUser _consumoControllerUser = ConsumoControllerUser();
  final OperatorController _operatorController = OperatorController();
  dynamic _image;
  bool _isSubmitting = false;
  bool _canSubmit = true;

  @override
  void initState() {
    super.initState();
    _checkCurrentMonthConsumption();
  }

  Future<void> _checkCurrentMonthConsumption() async {
    final currentMonth = _getMonthName(DateTime.now().month);

    try {
      final Map<String, int> userConsumption = await _operatorController.getMonthlyConsumption(widget.rut);
      final int? consumoUsuario = await _consumoControllerUser.getCurrentMonthConsumption(widget.rut);

      if (userConsumption[currentMonth] == consumoUsuario && consumoUsuario != null) {
        setState(() {
          _canSubmit = false;
        });
      }
    } catch (e) {
      print('Error checking current month consumption: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _image = pickedFile;
        } else {
          _image = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar origen de imagen'),
          content: SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt, size: 40),
                      onPressed: () {
                        Navigator.pop(context, ImageSource.camera);
                      },
                    ),
                    const Text('Cámara'),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo, size: 40),
                      onPressed: () {
                        Navigator.pop(context, ImageSource.gallery);
                      },
                    ),
                    const Text('Galería'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source != null) {
      _pickImage(source);
    }
  }

  Future<void> _submitConsumo() async {
    if (_formKey.currentState!.validate() && _image != null) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await _consumoControllerUser.uploadConsumo(
          rut: widget.rut,
          nombre: widget.nombre,
          apellidoPaterno: widget.apellidoPaterno,
          socio: widget.socio,
          consumo: int.parse(_consumoController.text),
          fecha: DateTime.now(),
          image: _image,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consumo subido con éxito')),
        );

        _consumoController.clear();
        setState(() {
          _image = null;
          _canSubmit = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir el consumo: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Consumo'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _consumoController,
                  decoration: const InputDecoration(labelText: 'Consumo (m³)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el consumo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showImageSourceDialog,
                  child: const Text('Seleccionar Imagen'),
                ),
                if (_image != null) ...[
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: kIsWeb
                                ? NetworkImage((_image as XFile).path)
                                : FileImage(_image) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 15,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red, size: 18),
                            onPressed: () {
                              setState(() {
                                _image = null;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _canSubmit && !_isSubmitting ? _submitConsumo : null,
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(_canSubmit ? 'Subir Consumo' : 'Ya subió el consumo de este mes'),
                ),
                const Divider(
                  thickness: 4,
                  color: Colors.black54,
                  indent: 40,
                  endIndent: 40,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Instrucciones',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• El consumo ingresado debe corresponder al mes en curso.\n'
                            '• La foto es obligatoria y debera ser del medidor, para mantener un registro adecuado.\n'
                            '• Una vez subido el consumo, no será posible modificarlo ni registrar otro hasta que finalice el mes.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _getMonthName(int month) {
  const monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
  return monthNames[month - 1];
}

