import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:aguaconectada/controllers/report_controller.dart';

class ReportsPage extends StatefulWidget {
  final String reportId;

  const ReportsPage({Key? key, required this.reportId}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportController _reportController = ReportController();

  @override
  void initState() {
    super.initState();
    if (widget.reportId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSpecificReport(context, widget.reportId);
      });
    }
  }

  void _showSpecificReport(BuildContext context, String reportId) {
    FirebaseFirestore.instance
        .collection('reportes')
        .doc(reportId)
        .get()
        .then((doc) {
      if (doc.exists && mounted) {
        final reporte = doc.data() as Map<String, dynamic>;
        final imagenes = List<String>.from(reporte['imageUrls'] ?? []);
        _showReportDetails(context, reporte, imagenes);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        backgroundColor: Colors.blue[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!, Colors.blue[100]!],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reportes')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.report_problem, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No hay reportes disponibles.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            final reportes = snapshot.data!.docs;
            return ListView.builder(
              itemCount: reportes.length,
              itemBuilder: (context, index) {
                final reporte = reportes[index].data() as Map<String, dynamic>;
                final nombreCompleto =
                    '${reporte['nombre'] ?? ''} ${reporte['apellidoPaterno'] ?? ''}';
                final imagenes = List<String>.from(reporte['imageUrls'] ?? []);
                final fecha = reporte['timestamp'] as Timestamp?;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      nombreCompleto,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(reporte['description'] ?? ''),
                        const SizedBox(height: 8),
                        Text(
                          'Estado: ${reporte['status']}',
                          style: TextStyle(
                            color: reporte['status'] == 'pendiente'
                                ? Colors.orange
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fecha: ${fecha != null ? DateFormat('dd/MM/yyyy HH:mm').format(fecha.toDate()) : 'No disponible'}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (imagenes.isNotEmpty)
                          Icon(Icons.image, color: Colors.blue[700]),
                        ElevatedButton(
                          onPressed: () => _showReportDetails(context, reporte, imagenes),
                          child: const Text('Revisar reporte'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showReportDetails(
      BuildContext context, Map<String, dynamic> reporte, List<String> imagenes) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Reporte de ${reporte['nombre']} ${reporte['apellidoPaterno'] ?? ''}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('RUT: ${reporte['userRut']}'),
                  Text('Socio: ${reporte['socio'] ?? 'No disponible'}'),
                  const SizedBox(height: 8),
                  Text('Descripción: ${reporte['description']}'),
                  const SizedBox(height: 16),
                  if (imagenes.isNotEmpty) ...[
                    const Text('Imágenes:',
                        style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imagenes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Image.network(
                              imagenes[index],
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                    child: Text('Imagen no disponible')
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Comentario del operador',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await _reportController.reviewReport(
                            reporte['id'],
                            commentController.text,
                          );
                          Navigator.of(context).pop();
                        },
                        child: const Text('Marcar como revisado'),
                      ),
                      if (reporte['status'] == 'revisado')
                        ElevatedButton(
                          onPressed: () async {
                            await _reportController.deleteReport(reporte['id']);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Eliminar reporte'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
