import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../controllers/operator_controller.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

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
                    child: const Text('Consumo'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showConsumptionModal(BuildContext context, String rut) {
    final OperatorController controller = OperatorController();
    final Map<String, TextEditingController> controllers = {};

    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    for (var month in months) {
      controllers[month] = TextEditingController();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, int>>(
          future: controller.getMonthlyConsumption(rut),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData) {
              final consumptionData = snapshot.data!;
              for (var month in months) {
                controllers[month]!.text =
                    consumptionData[month]?.toString() ?? '';
              }
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

            return AlertDialog(
              title: const Text('Ingresar Consumo Mensual'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text('Mes', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    // Month rows
                    ...months.map((month) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            // Month input
                            Expanded(
                              flex: 1,
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
                            SizedBox(width: 16),
                            // Total display (non-editable)
                            Expanded(
                              flex: 1,
                              child: FutureBuilder<double>(
                                future: controller.calculateMonthlyPayment(rut, month, int.tryParse(controllers[month]!.text) ?? 0),
                                builder: (context, snapshot) {
                                  return TextFormField(
                                    controller: TextEditingController(
                                        text: snapshot.data?.toString() ?? '0'
                                    ),
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
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Map<String, int> consumoData = {};
                    for (var month in months) {
                      final value = int.tryParse(controllers[month]!.text) ?? 0;
                      consumoData[month] = value;
                    }

                    try {
                      await controller.saveMonthlyConsumption(rut, consumoData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Consumo guardado exitosamente')),
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
            );
          },
        );
      },
    );
  }
}
