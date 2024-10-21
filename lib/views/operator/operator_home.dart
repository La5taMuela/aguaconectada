import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:aguaconectada/controllers/operator_controller.dart'; // Importar controlador
import 'package:aguaconectada/views/operator/profile_page.dart'; // Importar view de perfil
import 'package:aguaconectada/views/operator/reports_page.dart'; // Importar view de reportes
import 'package:aguaconectada/views/operator/tasks_page.dart'; // Importar view de tareas
import 'package:aguaconectada/views/operator/add_user_page.dart'; // Importar view de añadir usuario


class OperatorHome extends StatefulWidget {
  final String userType;
  final String userName;
  const OperatorHome({super.key, required this.userType, required this.userName});

  @override
  _OperatorHomeState createState() => _OperatorHomeState();
}

class _OperatorHomeState extends State<OperatorHome> {
  int currentPageIndex = 0; // Control del índice de la página actual

  // Lista de páginas disponibles
  final List<Widget> pages = [
    const TasksPage(),
    const ReportsPage(),
    const ProfilePage(),
    const AddUserPage(), // Agregar Usuario
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de ${widget.userName}'),
        backgroundColor: Colors.green[600],
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
                });
                Navigator.pop(context); // Cierra el drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Reportes'),
              onTap: () {
                setState(() {
                  currentPageIndex = 1;
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
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Agregar Usuario'),
              onTap: () {
                setState(() {
                  currentPageIndex = 3; // Índice de la pantalla "Agregar Usuario"
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: pages[currentPageIndex], // Muestra la página correspondiente al índice seleccionado
    );
  }
}
