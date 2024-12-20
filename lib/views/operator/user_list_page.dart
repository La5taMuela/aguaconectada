import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../controllers/operator_controller.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true, // Permitir cerrar tocando afuera
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // CircularProgressIndicator mientras carga
                const CircularProgressIndicator(),
                // Imagen cargada
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showConsumptionModal(BuildContext context, String rut) {
    final OperatorController controller = OperatorController();
    final Map<String, TextEditingController> controllers = {};

    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    for (var month in months) {
      controllers[month] = TextEditingController();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, Map<String, dynamic>>>(
          future: Future.wait([
            controller.getMonthlyConsumption(rut),
            controller.verifyUserConsumption(rut)
          ]).then((results) => {
            'monthlyConsumption': results[0],
            'verifiedConsumption': results[1],
          }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData) {
              final monthlyConsumption = snapshot.data!['monthlyConsumption']!;
              final verifiedConsumption = snapshot.data!['verifiedConsumption'] as Map<String, dynamic>;

              for (var month in months) {
                controllers[month]!.text = monthlyConsumption[month]?.toString() ?? '';
              }

              return Dialog(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Ingresar Consumo Mensual',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Header row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 40), // Space for icon
                            Expanded(
                              child: Text('Mes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text('Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Scrollable content
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: months.map((month) {
                              final consumoData = verifiedConsumption[month];
                              final hasImage = consumoData != null && consumoData['imageUrl'] != null;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    // Icon container
                                    SizedBox(
                                      width: 40,
                                      child: hasImage
                                          ? IconButton(
                                        icon: Icon(Icons.image,
                                            color: Colors.blue,
                                            size: 24),
                                        onPressed: () => _showImageDialog(
                                            context, consumoData['imageUrl']),
                                      )
                                          : null,
                                    ),
                                    // Month input
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: TextFormField(
                                          controller: controllers[month],
                                          decoration: InputDecoration(
                                            labelText: month,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Total field
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: FutureBuilder<double>(
                                          future: controller.calculateMonthlyPayment(
                                              rut, month,
                                              int.tryParse(controllers[month]!.text) ?? 0),
                                          builder: (context, snapshot) {
                                            return TextFormField(
                                              controller: TextEditingController(
                                                  text: snapshot.data?.toString() ?? '0'),
                                              enabled: false,
                                              decoration: InputDecoration(
                                                labelText: 'Total',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                filled: true,
                                                fillColor: Colors.grey[200],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      // Buttons
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar',
                                  style: TextStyle(color: Colors.black)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              onPressed: () async {
                                Map<String, int> consumoData = {};
                                for (var month in months) {
                                  final value =
                                      int.tryParse(controllers[month]!.text) ?? 0;
                                  consumoData[month] = value;
                                }

                                try {
                                  await controller.saveMonthlyConsumption(
                                      rut, consumoData);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                        Text('Consumo guardado exitosamente')),
                                  );
                                  Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                              child: const Text(
                                'Guardar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text(snapshot.error.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuarios'),
        backgroundColor: Colors.green[600],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Usuarios')
            .orderBy('socio')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          final usuarios = snapshot.data!.docs;

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index].data() as Map<String, dynamic>;
              final nombreCompleto =
                  '${usuario['nombre'] ?? ''} ${usuario['apellidoPaterno'] ?? ''}';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[400],
                    child: Text(
                      usuario['nombre']?.substring(0, 1) ?? '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(nombreCompleto),
                  subtitle: Text(
                      'RUT: ${usuario['rut']} - Socio: ${usuario['socio']}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                    ),
                    onPressed: () {
                      _showConsumptionModal(context, usuario['rut']);
                    },
                    child: const Text ('Consumo'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}