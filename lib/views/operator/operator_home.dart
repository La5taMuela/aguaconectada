import 'package:flutter/material.dart';
import 'package:aguaconectada/views/operator/reports_page.dart';
import 'package:aguaconectada/views/operator/add_user_page.dart';
import 'package:aguaconectada/views/operator/user_list_page.dart';
import 'package:aguaconectada/controllers/operator_controller.dart';
import 'package:badges/badges.dart' as badges;
import '../../models/user.dart';
import 'notification_report_operator.dart';
import '../../widgets/profile_witget.dart';

class OperatorHome extends StatefulWidget {
  final String userType;
  final String userName;
  final User user;

  const OperatorHome({
    Key? key,
    required this.userType,
    required this.userName,
    required this.user,
  }) : super(key: key);

  @override
  _OperatorHomeState createState() => _OperatorHomeState();
}

class _OperatorHomeState extends State<OperatorHome> {
  int currentPageIndex = 3;
  final OperatorController _operatorController = OperatorController();
  String? selectedReportId;

  List<Widget> get pages => [
    ReportsPage(reportId: selectedReportId ?? ''),
    ProfileWidget(
      user: widget.user,
      onLogout: () {
        Navigator.of(context).pushReplacementNamed('/login');
      },
    ),
    const AddUserPage(),
    const UserListPage(),
  ];

  void _showReportModal(BuildContext context, List reports) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NotificationModal(
          reports: reports,
          onReportTap: (reportId) {
            _operatorController.updateNotificationState(reportId);
            Navigator.of(context).pop();
            setState(() {
              selectedReportId = reportId;
              currentPageIndex = 0;
            });
          },
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
              leading: const Icon(Icons.report),
              title: const Text('Reportes'),
              onTap: () {
                setState(() {
                  currentPageIndex = 0;
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
                  currentPageIndex = 1;
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
                  currentPageIndex = 2;
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
                  currentPageIndex = 3;
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