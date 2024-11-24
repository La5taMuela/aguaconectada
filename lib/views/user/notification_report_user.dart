import 'package:flutter/material.dart';

class NotificationModal extends StatelessWidget {
  final List<Map<String, dynamic>> reports;
  final Function(String) onReportTap;

  const NotificationModal({
    Key? key,
    required this.reports,
    required this.onReportTap,
  }) : super(key: key);

  String _getStatusMessage(String status) {
    switch (status) {
      case 'en proceso':
        return 'Su reporte está siendo revisado por un operador';
      case 'revisado':
        return 'Su reporte ha sido resuelto';
      default:
        return 'Su reporte esta esperando ser revisado por un operador';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Notificaciones"),
      content: SizedBox(
        width: double.maxFinite,
        height: 450,
        child: ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            var report = reports[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(
                  _getStatusMessage(report['status'] ?? ''),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: report['read'] == true ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Titulo:  ${report['title']}',

                      style: TextStyle(
                        color: report['read'] == true ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Descripcion: ${report['description'] ?? 'Sin descripción'}',
                      style: TextStyle(
                        color: report['read'] == true ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                    if (report['operatorComment'] != null) ...[  // Changed from == null to != null
                      const SizedBox(height: 4),
                      Text(
                        'Comentario del operador: ${report['operatorComment']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: report['read'] == true ? Colors.grey[600] : Colors.grey[800],
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  onReportTap(report['reportId']);
                },
              ),
            );
          },
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
          ),
          child: const Text('Cerrar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }
}

