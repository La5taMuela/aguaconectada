  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import 'dart:io';
  import 'package:flutter/foundation.dart' show kIsWeb;
  import 'package:aguaconectada/controllers/report_controller.dart';
  
  class CreateReportPage extends StatefulWidget {
    final String userRut;
    final String nombre;
    final String apellidoPaterno;
    final String socio;
  
    const CreateReportPage({
      Key? key,
      required this.userRut,
      required this.nombre,
      required this.apellidoPaterno,
      required this.socio,
    }) : super(key: key);
  
    @override
    _CreateReportPageState createState() => _CreateReportPageState();
  }
  
  class _CreateReportPageState extends State<CreateReportPage> {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    List<dynamic> _images = [];
    final ReportController _reportController = ReportController();
    bool _isSubmitting = false;

    Future<void> _pickImage() async {
      // Mostrar un diálogo para elegir entre cámara o galería
      final pickedSource = await showDialog<ImageSource>(
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

      if (pickedSource != null) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: pickedSource);

        if (pickedFile != null) {
          setState(() {
            if (kIsWeb) {
              _images.add(pickedFile);
            } else {
              _images.add(File(pickedFile.path));
            }
          });
        }
      }
    }



    Future<void> _submitReport() async {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isSubmitting = true;
        });
  
        try {
          await _reportController.createReport(
            widget.userRut,
            widget.nombre,
            widget.apellidoPaterno,
            widget.socio,
            _titleController.text,
            _descriptionController.text,
            _images,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reporte enviado con éxito')),
          );
          _descriptionController.clear();
          setState(() {
            _images.clear();
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al enviar el reporte: $e')),
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
          title: const Text('Crear Reporte'),
          backgroundColor: Colors.blue[700],
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[700]!, Colors.blue[100]!],
            ),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Título del Reporte',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 8),



                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Ingrese un título para el reporte...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese un título';
                            }
                            return null;
                          },
                        ),
                        Text(
                          'Descripción del Reporte',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Describe el problema aquí...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese una descripción';
                            }
                            return null;
                          },
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Agregar Imagen'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_images.isNotEmpty)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Imágenes Adjuntas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _images.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemBuilder: (context, index) {
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: kIsWeb
                                    ? Image.network(
                                  (_images[index] as XFile).path,
                                  fit: BoxFit.cover,
                                )
                                    : Image.file(
                                  _images[index] as File,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Enviar Reporte',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
