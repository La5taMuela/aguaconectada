import 'package:flutter/material.dart';
import 'package:aguaconectada/controllers/operator_controller.dart';

class NotificationModal extends StatelessWidget {
  final List reports;
  final Function onReportTap;

  const NotificationModal({Key? key, required this.reports, required this.onReportTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Notificaciones"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            var report = reports[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(report['nombre'] ?? 'Sin nombre'),
                subtitle: Text(report['description'] ?? 'Sin descripción'),
                onTap: () {
                  onReportTap(report['documentId']);
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cerrar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
