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
        return 'Estado desconocido';
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
                title: Text(_getStatusMessage(report['status'] ?? ''),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,

                ),),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report['title'] ?? 'Sin título'),
                    const SizedBox(height: 4),
                    Text(report['description'] ?? 'Sin descripción'),
                    if (report['operatorComment'] == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Comentario del operador: ${report['operatorComment']}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () {
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