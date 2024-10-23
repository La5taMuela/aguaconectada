import 'package:flutter/material.dart';
import 'package:aguaconectada/views/operator/profile_page.dart';
import 'package:aguaconectada/views/operator/reports_page.dart';
import 'package:aguaconectada/views/operator/tasks_page.dart';
import 'package:aguaconectada/views/operator/add_user_page.dart';
import 'package:aguaconectada/views/operator/user_list_page.dart'; // Nueva página de lista de usuarios

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

  // Lista de páginas disponibles
  final List<Widget> pages = [
    const TasksPage(),
    const ReportsPage(),
    const ProfilePage(),
    const AddUserPage(),
    const UserListPage(), // Nueva página
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
                Navigator.pop(context);
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
                  currentPageIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Lista de Usuarios'),
              onTap: () {
                setState(() {
                  currentPageIndex = 4; // Índice de la lista de usuarios
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: pages[currentPageIndex], // Mostrar la página seleccionada
    );
  }
}
