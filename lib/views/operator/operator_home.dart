import 'package:flutter/material.dart';
import 'package:aguaconectada/views/operator/profile_page.dart';
import 'package:aguaconectada/views/operator/reports_page.dart';
import 'package:aguaconectada/views/operator/tasks_page.dart';
import 'package:aguaconectada/views/operator/add_user_page.dart';
import 'package:aguaconectada/views/operator/user_list_page.dart';
import 'package:aguaconectada/controllers/operator_controller.dart';
import 'package:badges/badges.dart' as badges;

class OperatorHome extends StatefulWidget {
  final String userType;
  final String userName;

  const OperatorHome({
    super.key,
    required this.userType,
    required this.userName,
  });

  @override
  _OperatorHomeState createState() => _OperatorHomeState();
}

class _OperatorHomeState extends State<OperatorHome> {
  int currentPageIndex = 4; // Página inicial (Lista de usuarios)
  final OperatorController _operatorController = OperatorController();
  String? selectedReportId;

  // Lista de páginas disponibles
  List<Widget> get pages => [
    const TasksPage(),
    ReportsPage(reportId: selectedReportId ?? ''),
    const ProfilePage(),
    const AddUserPage(),
    const UserListPage(),
  ];

  void _showReportModal(BuildContext context, List reports) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                      // Update Firestore to mark notification as viewed
                      _operatorController.updateNotificationState(report['documentId']);

                      Navigator.of(context).pop(); // Close modal

                      // Set the selected report ID and navigate to ReportsPage
                      setState(() {
                        selectedReportId = report['documentId'];
                        currentPageIndex = 1; // Index of ReportsPage in the pages list
                      });
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de ${widget.userName}'),
        backgroundColor: Colors.green[600],
        actions: [
          StreamBuilder(
            stream: _operatorController.reportStream,
            builder: (context, snapshot) {
              int nuevosReportes = 0;
              List reports = [];
              if (snapshot.hasData) {
                reports = snapshot.data!.docs.map((doc) {
                  return {
                    'documentId': doc.id,
                    'nombre': doc['nombre'],
                    'description': doc['description'],
                  };
                }).toList();
                nuevosReportes = reports.length;
              }
              return badges.Badge(
                badgeContent: Text(
                  '$nuevosReportes',
                  style: const TextStyle(color: Colors.white),
                ),
                position: badges.BadgePosition.topEnd(top: 0, end: 3),
                showBadge: nuevosReportes > 0,
                child: IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.black87),
                  iconSize: 40.0,
                  onPressed: () {
                    if (nuevosReportes > 0) {
                      _showReportModal(context, reports);
                    } else {
                      print('No hay nuevos reportes');
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[600]),
              child: const Text(
                'Menú Principal',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tareas'),
              onTap: () {
                setState(() {
                  currentPageIndex = 0;
                  selectedReportId = null;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Reportes'),
              onTap: () {
                setState(() {
                  currentPageIndex = 1;
                  selectedReportId = null;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                setState(() {
                  currentPageIndex = 2;
                  selectedReportId = null;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Agregar Usuario'),
              onTap: () {
                setState(() {
                  currentPageIndex = 3;
                  selectedReportId = null;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Lista de Usuarios'),
              onTap: () {
                setState(() {
                  currentPageIndex = 4;
                  selectedReportId = null;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: pages[currentPageIndex],
    );
  }
}